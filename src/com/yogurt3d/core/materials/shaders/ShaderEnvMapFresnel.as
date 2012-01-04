/*
* ShaderEnvMapFresnel.as
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
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public class ShaderEnvMapFresnel extends Shader
	{
		
		private var m_cubeMap						:CubeTextureMap;
	
		private var m_envMapTexture					:ShaderConstants;
		public  var m_alphaConsts					:ShaderConstants;
		public  var m_fresnelConsts					:ShaderConstants;
		
		private var m_normalMap						:TextureMap;
		private var m_reflectivityMap				:TextureMap;
		private var m_alpha							:Number;
		private var m_colorMap						:TextureMap;
		
		private var m_normalMapDirty				:Boolean = false;
		private var m_normalMapConst				:ShaderConstants;
		private var m_colorMapDirty					:Boolean = false;
		private var m_colorMapConst					:ShaderConstants;
		private var m_reflectivityMapDirty			:Boolean = false;
		private var m_reflectivityMapConst			:ShaderConstants;
		
		private var m_fresnelReflectance:Number;
		private var m_fresnelPower:uint;
		
		private var m_normalMapUVOffset:Point;
		private var m_normalMapUVOffsetDirty:Boolean = false;
		private var m_normalMapUVOffsetConst:ShaderConstants;
		
		private var m_normalMapUVOffsetVector:Vector.<Number> = new Vector.<Number>(4);
		
		/**
		 * 
		 * 
		 * @author Yogurt3D Engine Core Team
		 * @company Yogurt3D Corp.
		 **/
		public function ShaderEnvMapFresnel(_cubeMap:CubeTextureMap, 
											_normalMap:TextureMap=null,  
											_reflectivityMap:TextureMap=null,
											_alpha:Number=1.0,
											_fresnelReflectance:Number=0.028,
											_fresnelPower:Number=5)
		{
			key = "Yogurt3DOriginalsShaderEnvMappingFresnel";
									
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling			= Context3DTriangleFace.FRONT;
			
			params.requiresLight				= false;
			
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.NORMAL, EVertexAttribute.TANGENT, EVertexAttribute.BONE_DATA);
			
			params.vertexShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.MVP_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(4, EShaderConstantsType.MODEL_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(8, EShaderConstantsType.BONE_MATRICES));
			
			// environmental map // FS0
			m_envMapTexture 							= new ShaderConstants(0,EShaderConstantsType.TEXTURE);
			m_envMapTexture.texture 					= _cubeMap;
			params.fragmentShaderConstants.push(m_envMapTexture);
			
			
			var _fragmentShaderConsts:ShaderConstants;
			
			// fc0: camera pos
			params.fragmentShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.CAMERA_POSITION));
			
			// fc1 : alpha
			m_alphaConsts   							= new ShaderConstants(1, EShaderConstantsType.CUSTOM_VECTOR);
			m_alphaConsts.vector						= Vector.<Number>([ _alpha, 2.0, 0.2, -1.0 ]);
			params.fragmentShaderConstants.push(m_alphaConsts);
			
			// fc2 : custom vector for normal map based vertex normal calculation
			_fragmentShaderConsts   							= new ShaderConstants(2, EShaderConstantsType.CUSTOM_VECTOR);
			_fragmentShaderConsts.vector						= Vector.<Number>([ 1.0, 1.0, 1.0, 1.0 ]);
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			// fc3 : fresnel custom vector
			m_fresnelConsts   							= new ShaderConstants(3, EShaderConstantsType.CUSTOM_VECTOR);
			m_fresnelConsts.vector						= Vector.<Number>([ _fresnelReflectance, _fresnelPower, 1.0, 1 - _fresnelReflectance ]);
			params.fragmentShaderConstants.push(m_fresnelConsts);
		
			envMap						= _cubeMap;
			normalMap 					= _normalMap;
			reflectivityMap			    = _reflectivityMap;
			alpha 						= _alpha;
			
			fresnelReflectance = _fresnelReflectance;
			fresnelPower = _fresnelPower;
			
		}
		public function get envMap():CubeTextureMap{
			return m_cubeMap;
		}
		public function set envMap(_value:CubeTextureMap):void{
			m_cubeMap = _value;
			m_envMapTexture.texture = m_cubeMap;
		}
		
		public function get texture():TextureMap
		{
			return m_colorMap;
		}
		public function set texture(value:TextureMap):void
		{
			m_colorMap = value;
			m_colorMapDirty = true;
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
			
			m_fresnelConsts.vector = Vector.<Number>([ m_fresnelReflectance, m_fresnelPower, 1.0, 1 - m_fresnelReflectance ]);
		}
		
		public function get fresnelPower():uint{
			return m_fresnelPower;
		}
		public function set fresnelPower(value:uint):void{
			m_fresnelPower = value;
			m_fresnelConsts.vector = Vector.<Number>([ m_fresnelReflectance, m_fresnelPower, 1.0, 1 - m_fresnelReflectance ]);		
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
				"crs vt1.xyz va2.xyz va3.xyz",
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
			var _colorMapAGAL:String;
			
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
			
			if(m_colorMap != null){
				_colorMapAGAL = [
					("tex ft5 v2 fs3<2d,wrap,linear>"), 
					((m_colorMap.transparent)?"sub ft1.w ft5.w fc1.z\nkil ft1.w":""),
					//"add ft0 ft5 ft0",
					
				].join("\n");
			
			}else
				_colorMapAGAL = "";
			
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
				
				"tex ft0 ft4 fs0<3d,cube,linear> ",   // get envMap
				"mul ft0 ft0 ft5",
				_colorMapAGAL,
				_reflectivityAGAL,                    // set alpha
				"mov oc ft0"
				
			].join("\n");
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, _environmentalMappingFS);
		}
		
		public override function getProgram(_context3D:Context3D, _lightType:ELightType=null, _meshType:String = null):Program3D{
			
			if(m_colorMapDirty )
			{
				if(m_colorMap != null ){
					if( m_colorMapConst == null )
					{
						m_colorMapConst 						= new ShaderConstants();
						m_colorMapConst.type					= EShaderConstantsType.TEXTURE;
						m_colorMapConst.firstRegister			= 3;// FS1
						params.fragmentShaderConstants.push(m_colorMapConst);	
					}
					m_colorMapConst.texture = m_colorMap;
				}else{
					if(m_colorMapConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_colorMapConst ), 1 );
						m_colorMapConst = null;
					}
				}
				disposeShaders();
				m_colorMapDirty = false;
			}
			
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
				m_normalMapUVOffsetVector[0] = m_normalMapUVOffset.x;
				m_normalMapUVOffsetVector[1] = m_normalMapUVOffset.y;
				m_normalMapUVOffsetConst.vector = m_normalMapUVOffsetVector;
			}
			
			key = "Yogurt3DOriginalsShaderEnvFresnel" + ((m_normalMap)?"WithNormal":"") +
				((m_normalMap && m_normalMap.mipmap)?"WithNormalMip":"")+
				((m_reflectivityMap)?"WithReflectivity":"") + 
				((m_reflectivityMap && m_reflectivityMap.mipmap)?"WithRefMip":"")+
				((m_normalMapUVOffset)?"WithNormalUVOffset":"")+
				((m_colorMap)?"WithTexture":"")+
				((m_colorMap && m_colorMap.transparent)?"WithTextureAlpha":"");
			
			return super.getProgram( _context3D, _lightType, _meshType );
		}
	}
}