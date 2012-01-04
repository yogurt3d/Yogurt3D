/*
* ShaderTwoTextureFresnel.as
* This file is part of Yogurt3D Flash Rendering Engine 
*
* Copyright (C) 2011 - Yogurt3D Corp.
*
* Yogurt3D Flash Rendering Engine is free software; you can redistribute it and/or
* modify it under the terms of the YOGURT3D CLICK-THROUGH AGREEMENT
* License.
* 
* Yogurt3D Flash Rendering Engine is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
* 
* You should have received a copy of the YOGURT3D CLICK-THROUGH AGREEMENT
* License along with this library. If not, see <http://www.yogurt3d.com/yogurt3d/downloads/yogurt3d-click-through-agreement.html>. 
*/

package com.yogurt3d.core.materials.shaders
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public class ShaderTwoTextureFresnel extends Shader
	{
		
		private var m_alphaConsts					:ShaderConstants;
		private var m_fresnelConsts					:ShaderConstants;
		private var m_texture1Consts				:ShaderConstants;
		private var m_texture2Consts				:ShaderConstants;
		private var m_gainConsts					:ShaderConstants;
		
		private var m_normalMap						:TextureMap;
		private var m_reflectivityMap				:TextureMap;
		private var m_alpha							:Number;
		private var m_texture1						:TextureMap;
		private var m_texture2						:TextureMap;
		private var m_gain							:Number;
		
		private var m_normalMapDirty				:Boolean = false;
		private var m_normalMapConst				:ShaderConstants;
		private var m_reflectivityMapDirty			:Boolean = false;
		private var m_reflectivityMapConst			:ShaderConstants;
		
		private var m_fresnelReflectance:Number;
		private var m_fresnelPower:uint;
		
		private var m_normalMapUVOffset:Point;
		private var m_normalMapUVOffsetDirty:Boolean = false;
		private var m_normalMapUVOffsetConst:ShaderConstants;
		
		/**
		 * 
		 * 
		 * @author Yogurt3D Engine Core Team
		 * @company Yogurt3D Corp.
		 **/
		public function ShaderTwoTextureFresnel( _normalMap:TextureMap=null,  
											   _reflectivityMap:TextureMap=null,
											   _alpha:Number=1.0,
											   _fresnelReflectance:Number=0.028,
											   _fresnelPower:Number=5, 
											   _texture1:TextureMap=null, _texture2:TextureMap=null, _gain:Number=0.0)
		{
			key = "Yogurt3DOriginalsShader2TextureFresnel"+
				(_texture1.mipmap?"withTex1Mip":"")+
				(_texture2.mipmap?"withTex2Mip":"");
			
			normalMap 					= _normalMap;
			reflectivityMap			    = _reflectivityMap;
			m_alpha 					= _alpha;
			
			m_fresnelReflectance = _fresnelReflectance;
			m_fresnelPower = _fresnelPower;
			m_texture1 = _texture1;
			m_texture2 = _texture2;
			m_gain	 = _gain;
			
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling			= Context3DTriangleFace.FRONT;
			


			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.NORMAL, EVertexAttribute.TANGENT, EVertexAttribute.BONE_DATA);
			
			params.vertexShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.MVP_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(4, EShaderConstantsType.MODEL_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(8, EShaderConstantsType.BONE_MATRICES));
			
			var _fragmentShaderConsts:ShaderConstants 	= new ShaderConstants();
			
			// fc0: camera pos
			_fragmentShaderConsts						= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.CAMERA_POSITION;
			_fragmentShaderConsts.firstRegister			= 0;
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			// fc1 : alpha
			m_alphaConsts   							= new ShaderConstants();
			m_alphaConsts.type 							= EShaderConstantsType.CUSTOM_VECTOR;
			m_alphaConsts.vector						= Vector.<Number>([ m_alpha, 2.0, 0.5, -1.0 ]);
			m_alphaConsts.firstRegister					= 1;
			params.fragmentShaderConstants.push(m_alphaConsts);
			
			// fc2 : custom vector for normal map based vertex normal calculation
			m_gainConsts   								= new ShaderConstants();
			m_gainConsts.type 							= EShaderConstantsType.CUSTOM_VECTOR;
			m_gainConsts.vector							= Vector.<Number>([ 1.0, m_gain, 0.2, 1.0 ]);
			m_gainConsts.firstRegister					= 2;
			params.fragmentShaderConstants.push(m_gainConsts);
			
			// fc3 : fresnel custom vector
			m_fresnelConsts   							= new ShaderConstants();
			m_fresnelConsts.type 						= EShaderConstantsType.CUSTOM_VECTOR;
			m_fresnelConsts.vector						= Vector.<Number>([ m_fresnelReflectance, m_fresnelPower, 1.0, 1 - m_fresnelReflectance ]);
			m_fresnelConsts.firstRegister				= 3;
			params.fragmentShaderConstants.push(m_fresnelConsts);
			
			// fs0 + fs1
			
			m_texture1Consts 							= new ShaderConstants();
			m_texture1Consts.type						= EShaderConstantsType.TEXTURE;
			m_texture1Consts.firstRegister				= 0; // FS0
			m_texture1Consts.texture 					= m_texture2;
			params.fragmentShaderConstants.push(m_texture1Consts);
			
			m_texture2Consts 							= new ShaderConstants();
			m_texture2Consts.type						= EShaderConstantsType.TEXTURE;
			m_texture2Consts.firstRegister				= 3; // FS0
			m_texture2Consts.texture 					= m_texture1;
			params.fragmentShaderConstants.push(m_texture2Consts);
			
	
			
		}
		
		public function get normalMap():TextureMap
		{
			return m_normalMap;
		}
		public function set normalMap(value:TextureMap):void
		{
			m_normalMap = value;
			m_normalMapDirty = true;
		}
		
		public function get reflectivityMap():TextureMap
		{
			return m_reflectivityMap;
		}
		public function set reflectivityMap(value:TextureMap):void
		{
			m_reflectivityMap = value;
			m_reflectivityMapDirty = true;
		}
		
		public function get alpha():Number{
			return m_alpha;
		}
		public function set alpha(_value:Number):void{
			m_alpha = _value;
			m_alphaConsts.vector = Vector.<Number>([ m_alpha, 2.0, 0.5, -1.0 ]);	
		}
		
		public function get fresnelReflectance():Number{
			return m_fresnelReflectance;
		}
		public function set fresnelReflectance(value:Number):void{
			m_fresnelReflectance = value;
			m_fresnelConsts.vector	= Vector.<Number>([ m_fresnelReflectance, fresnelPower, 1.0, 1 - m_fresnelReflectance ]);		
		}
		
		public function get fresnelPower():uint{
			return m_fresnelPower;
		}
		public function set fresnelPower(value:uint):void{
			m_fresnelPower = value;
			m_fresnelConsts.vector	= Vector.<Number>([ fresnelReflectance, m_fresnelPower, 1.0, 1 - fresnelReflectance ]);		
		}
		
		public function get normalMapUVOffset( ):Point{
			return m_normalMapUVOffset;
		}
		public function set normalMapUVOffset( _point:Point ):void{
			if(m_normalMapUVOffset != _point )
			{
				m_normalMapUVOffset = _point;
				m_normalMapUVOffsetDirty = true;
			}
		}
		
		public function get texture1():TextureMap{
			return m_texture1;
		}
		public function set texture1(_value:TextureMap):void{
			m_texture1 = _value;
			m_texture1Consts.texture = _value;
		}
		public function get texture2():TextureMap{
			return m_texture2;
		}
		public function set texture2(_value:TextureMap):void{
			m_texture2 = _value;
			m_texture2Consts.texture = _value;
		}
		
		public function get gain():Number{
			return m_gain;
		}
		public function set gain(_value:Number):void{
			m_gain = _value;
			m_gainConsts.vector	= Vector.<Number>([ 1.0, m_gain, 1.0, 1.0 ]);
		}
		
		
		public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			
			if( _meshKey == "SkinnedMesh")
			{
				var assembler:AGALMiniAssembler = new AGALMiniAssembler();
				
				var code:String = ShaderUtils.getSkeletalAnimationVertexShader( 
					0, 1, 2, 
					4, 6, 
					0, 4, 8, 
					3, true, true, true  );
				
				code += "mov v" + 0 +".xyzw, vt0.xyzw\n";
				code += "mov v" + 1 + ".xyzw, vt1.xyzw\n";
				code += "mov v" + 2 + ", va1\n";
				code += "mov v" + 3 + ".xyzw, vt2.xyzw\n";
				
				code += "mov vt3.w vt0.w\n";// binormal calculation
				code += "crs vt3.xyz vt1.xyz vt2.xyz\n";
				code += "nrm vt3.xyz vt4.xyz\n";
				code += "mov v4 vt3\n";// pass binormals 
				
				return assembler.assemble(Context3DProgramType.VERTEX, 	code );
			}
			
			//va0 : vertex position 
			//va1: uvt
			//va2: normals
			//va3: tangents
			
			var _environmentalMappingVS:String = [
				
				"m44 op va0 vc0" , 
				"m44 v0 va0 vc4" , 	
				"m33 vt0.xyz va2 vc4",
				"mov v1.w va2.w",
				"nrm vt0.xyz vt0.xyz" ,
				"mov v1.xyz vt0.xyz" ,// pass Normals
				"mov v2 va1",  // pass UV
				"mov v3 va3", // pass Tangent
				"mov vt1.w va0.w",// binormal calculation
				"crs vt1.xyz va1.xyz va3.xyz",
				"nrm vt1.xyz vt1.xyz",
				"mov v4 vt1"// pass binormals 
				
			].join("\n");
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, _environmentalMappingVS);
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			// v0: Pixel Position in world space
			// v1: normal
			// v2: uvt  
			
			
			var _normalAGAL:String;
			var _reflectivityAGAL:String;
			
			if(m_normalMap != null){
				
				_normalAGAL = [   
					(m_normalMapUVOffset)?"add ft1 v2 fc4":"mov ft1 v2",
					((!m_normalMap.mipmap)?"tex ft1 ft1 fs1<2d,wrap,linear>":"tex ft1 ft1 fs1<2d,wrap,linear,miplinear>"),
					// lookup normal from normal map, move from [0,1] to  [-1, 1] range, normalize
					// texNormal = texNormal * 2 - 1;
					"mul ft1 ft1 fc1.y",
					"sub ft1 ft1 fc2.x",
					"nrm ft1.xyz ft1",
					
					//	texNormal = (vecNormalWS * texNormal.z) + (texNormal.x * vecBinormalWS + texNormal.y * -vecTangentWS);
					"mul ft2 v1 ft1.z", // (vecNormalWS * texNormal.z)
					"mul ft5 ft1.x v4", // texNormal.x * vecBinormalWS
					"mul ft6 fc1.w v3", // -vecTangentWS
					"mul ft6 ft1.y ft6", //texNormal.y * -vecTangentWS
					"add ft5 ft5 ft6",//(texNormal.x * vecBinormalWS + texNormal.y * -vecTangentWS)
					"add ft1 ft5 ft2"		
					
				].join("\n");
				
			}else
				_normalAGAL =  "mov ft1 v1"; 
			
			if(m_reflectivityMap != null){
				_reflectivityAGAL = [   
					
					((!m_reflectivityMap.mipmap)?"tex ft2 v2 fs2<2d,wrap,linear>":"tex ft2 v2 fs2<2d,wrap,linear,miplinear>"),     // get reflection map
					"mul ft0.w ft2.xyz ft0.w",
					"mul ft0.w fc1.x ft0.w"
					
				].join("\n");
				
			}else{
				_reflectivityAGAL = [   
					"mul ft0.w fc1.x ft0.w"
				].join("\n");
				
			}
			
			// V: view vector
			// N: normal
			// T: tangent
			// B: binormal
			
			//[ 0.02037, 5.0, 1.0, 1.0 ]
			
			var _environmentalMappingFS:String = [   
				"mov ft3 v3",					      // ft3 = T 
				"mov ft4 v4",                         // ft4 = B
				_normalAGAL,					      // decide normal: texture or vertex normal?
				"mul ft7 v0.xyz fc0.w" ,   			  //V.xyz*E.w                 
				"mul ft4 fc0.xyz v0.w",   	          //E.xyz*V.w
				"sub ft7 ft7 ft4", 			          //V.xyz*E.w - E.xyz*V.w
				"nrm ft7.xyz ft7",			          //ft7 = In  = normalize( -view)
				"nrm ft1.xyz ft1",
				
				//reflect(In, N)
				"dp3 ft6 ft1 ft7",						// dot(N,I)
				"mul ft6 ft6 ft1",						// dot(N,I)*N
				"mul ft6 ft6 fc1.y",					// 2 * dot(N,I) * N
				"sub ft4 ft7 ft6", 						// R = I - 2 * dot(N,I) * N
				
				"sub ft6 ft4 ft7", 						// RH = R-In
				"nrm ft6.xyz ft6",						// ft6 = RH = norm(R-In)
				
				"dp3 ft5 ft7 ft6",						// dot(In,RH)
				"add ft5 fc2.x ft5",					// 1.+dot(In,RH)
				"pow ft5 ft5 fc3.y",					// pow(1.+dot(In,RH),5.)
				"mul ft5 fc3.w ft5",					// (1.-r0)*pow(1.+dot(In,RH),5.)
				"add ft5 ft5 fc3.x",					// fresnel = r0 + (1.-r0)*pow(1.+dot(In,RH),5.) 
				"sub ft6 fc3.z ft5",					// 1 - fresnel
				//	"tex ft0 ft4 fs0<3d,cube,linear>",   	// get envMap
				
				((!texture1.mipmap)?"tex ft7 v2 fs0<wrap,linear>":"tex ft7 v2 fs0<wrap,linear,miplinear>"), 			// get texture 1
				((texture1.transparent)?"sub ft1.x ft7.w fc2.z\nkil ft1.x":""),
				"mul ft5 ft5 ft7",
				
				"sub ft6.xyz ft6.xyz fc2.y",
				((!texture2.mipmap)?"tex ft7 v2 fs3<wrap,linear>":"tex ft7 v2 fs3<wrap,linear,miplinear>"), 			// get texture 2
				((texture2.transparent)?"sub ft1.x ft7.w fc2.z\nkil ft1.x":""),
				"mul ft6 ft6 ft7",
				
				"add ft0 ft5 ft6",
				
				_reflectivityAGAL,                    // set alpha
				//"mul ft0.w fc1.x ft0.w",
				"mov oc ft0"
				
			].join("\n");
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, _environmentalMappingFS);
		}
		
		public override function getProgram(_context3D:Context3D, _lightType:ELightType=null, _meshType:String = null):Program3D{
			
			if(m_normalMapDirty )
			{
				if(m_normalMap != null ){
					if( m_normalMapConst == null )
					{
						m_normalMapConst 						= new ShaderConstants();
						m_normalMapConst.type					= EShaderConstantsType.TEXTURE;
						m_normalMapConst.firstRegister			= 1;// FS1
						params.fragmentShaderConstants.push(m_normalMapConst);	
					}
					m_normalMapConst.texture = m_normalMap;
				}else{
					if(m_normalMapConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_normalMapConst ), 1 );
						m_normalMapConst = null;
					}
				}
				disposeShaders();
				m_normalMapDirty = false;
			}
			
			if(m_reflectivityMapDirty )
			{
				
				if(m_reflectivityMap != null ){
					if( m_reflectivityMapConst == null )
					{
						m_reflectivityMapConst 						= new ShaderConstants();
						m_reflectivityMapConst.type					= EShaderConstantsType.TEXTURE;
						m_reflectivityMapConst.firstRegister		= 2;// FS
						params.fragmentShaderConstants.push(m_reflectivityMapConst);	
					}
					m_reflectivityMapConst.texture = m_reflectivityMap;
				}else{
					if(m_reflectivityMapConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_reflectivityMapConst ), 1 );
						m_reflectivityMapConst = null;
					}
				}
				disposeShaders();
				m_reflectivityMapDirty = false;
			}
			if( m_normalMapUVOffsetDirty )
			{
				if(m_normalMapUVOffset != null ){
					if( m_normalMapUVOffsetConst == null )
					{
						m_normalMapUVOffsetConst 						= new ShaderConstants();
						m_normalMapUVOffsetConst.type					= EShaderConstantsType.CUSTOM_VECTOR;
						m_normalMapUVOffsetConst.firstRegister			= 4;// FS
						params.fragmentShaderConstants.push(m_normalMapUVOffsetConst);	
					}
				}else{
					if(m_normalMapUVOffsetConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_normalMapUVOffsetConst ), 1 );
					}
				}
				disposeShaders();
				m_normalMapUVOffsetDirty = false;
			}
			
			if(m_normalMapUVOffset)
			{
				m_normalMapUVOffsetConst.vector = Vector.<Number>([m_normalMapUVOffset.x,m_normalMapUVOffset.y,0,0]);
			}
			
			key = "Yogurt3DOriginalsShader2TextureFresnel" + 
				(texture1.mipmap?"withTex1Mip":"")+
				(texture2.mipmap?"withTex2Mip":"")+
				((m_normalMap)?"WithNormal":"") + 
				((m_reflectivityMap)?"WithReflectivity":"") + 
				((m_normalMapUVOffset)?"WithNormalUVOffset":"") ;
			return super.getProgram( _context3D, _lightType, _meshType );
		}
	}
}