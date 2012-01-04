/*
* ShaderRefraction.as
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
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class ShaderRefraction extends Shader
	{
		private var m_cubeMap						:CubeTextureMap;
		private var m_contextToTextureMap			:Dictionary;
		
		private var m_envMapTexture					:ShaderConstants;
		public  var m_alphaConsts					:ShaderConstants;
		public  var m_refractiveConsts				:ShaderConstants;
		public  var m_colorShaderConstants			:ShaderConstants;
		public  var m_fresnelShaderConstants		:ShaderConstants;
		private var m_normalMapConst				:ShaderConstants;
		private var m_refractivityMapConst			:ShaderConstants;
		private var m_normalMap						:TextureMap;
		private var m_refractivityMap				:TextureMap;
		
		private var m_normalMapDirty				:Boolean = false;
		private var m_refractivityMapDirty			:Boolean = false;
		
		private var m_refIndex						:Number;
		private var m_alpha							:Number;
		private var m_color							:uint;

		/**
		 * 
		 * 
		 * @author Yogurt3D Engine Core Team
		 * @company Yogurt3D Corp.
		 **/
		public function ShaderRefraction(_cubeMap:CubeTextureMap, 
										 _color:uint = 0xFFFFFF,
										 _refIndex:Number = 1.0,
										 _normalMap:TextureMap=null,
										 _refractivityMap:TextureMap=null,
										 _alpha:Number=1.0)
		{
			key = "Yogurt3DOriginalsShaderRefraction";
			
			m_cubeMap					= _cubeMap;
			m_contextToTextureMap   	= new Dictionary();
			m_alpha 					= _alpha;
			normalMap 					= _normalMap;
			m_refractivityMap			= _refractivityMap;
			m_refIndex					= _refIndex;
			color 						= _color;
				

			
			params.writeDepth 		= true;
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling			= Context3DTriangleFace.FRONT;

			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.NORMAL, EVertexAttribute.TANGENT, EVertexAttribute.BONE_DATA);
			
			params.vertexShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.MVP_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(4, EShaderConstantsType.MODEL_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(8, EShaderConstantsType.BONE_MATRICES));
		
			
			// environmental map
			m_envMapTexture 							= new ShaderConstants();
			m_envMapTexture.type						= EShaderConstantsType.TEXTURE;
			m_envMapTexture.firstRegister				= 0; // FS0
			m_envMapTexture.texture 					= m_cubeMap;
			params.fragmentShaderConstants.push(m_envMapTexture);
			
			
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
			
			// fc2 : custom vector for normal map based vertex normal calculation & eta 
			m_refractiveConsts   					= new ShaderConstants();
			m_refractiveConsts.type 				= EShaderConstantsType.CUSTOM_VECTOR;
			m_refractiveConsts.vector				= Vector.<Number>([ 1.0, m_refIndex, 0.0, m_refIndex * m_refIndex]);
			m_refractiveConsts.firstRegister		= 2;
			params.fragmentShaderConstants.push(m_refractiveConsts);

			
		}
		
		public function get envMap():CubeTextureMap{
			return m_cubeMap;
		}
		public function set envMap(_value:CubeTextureMap):void{
			m_cubeMap = _value;
			m_envMapTexture.texture = m_cubeMap;
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
		
		public function get refractivityMap():TextureMap
		{
			return m_refractivityMap;
		}
		public function set refractivityMap(value:TextureMap):void
		{
			m_refractivityMap = value;
			m_refractivityMapDirty = true;
		}
		
		public function get alpha():Number{
			return m_alpha;
		}
		public function set alpha(_value:Number):void{
			m_alpha = _value;
			m_alphaConsts.vector = Vector.<Number>([ m_alpha, 2.0, 0.5, -1.0 ]);	
		}
		
		public function get color():uint{
			return m_color;
		}
		public function set color(_value:uint):void{
			m_color = _value;
			
			m_colorShaderConstants					= new ShaderConstants();
			m_colorShaderConstants.type 			= EShaderConstantsType.CUSTOM_VECTOR;
			m_colorShaderConstants.firstRegister	= 3;
			
			var _r:uint = m_color >> 16;
			var _g:uint = m_color >> 8 & 0xFF;
			var _b:uint = m_color & 0xFF;
			
			m_colorShaderConstants.vector = Vector.<Number>([_r/255,_g/255,_b/255, 0]);
			
			params.fragmentShaderConstants.push(m_colorShaderConstants);
		}
		
		public function get refIndex():Number{
			return m_refIndex;
		}
		public function set refIndex(_value:Number):void{
			m_refIndex = _value;
			m_refractiveConsts.vector = Vector.<Number>([ 1.0, m_refIndex, 0.0, m_refIndex * m_refIndex]);
			
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
			
			var _vertexShader:String = [
				
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
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, _vertexShader);
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			// v0: Pixel Position in world space
			// v1: normal
			// v2: uvt  
			
			var _normalAGAL:String;
			var _refractivityAGAL:String;
			
			if(m_normalMap != null){
				
				_normalAGAL = [   
					
					((!m_normalMap.mipmap)?"tex ft1 v2 fs1<2d,wrap,linear>":"tex ft1 v2 fs1<2d,wrap,linear,miplinear>"),
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
			
			if(m_refractivityMap != null){
				_refractivityAGAL = [   
					
					((!m_refractivityMap.mipmap)?"tex ft2 v2 fs2<2d,wrap,linear>":"tex ft2 v2 fs2<2d,wrap,linear,miplinear>"),     // get reflection map
					"mul ft0.w ft2.xyz fc1.x"
					
				].join("\n");	
			}else
				_refractivityAGAL =  "mov ft0.w fc1.x"; 
			
			
			// V: view vector
			// N: normal
			// T: tangent
			// B: binormal
			
			var _fragmentShader:String = [   
				"mov ft3 v3",					      // ft3 = T 
				"mov ft4 v4",                         // ft4 = B
				_normalAGAL,					      // decide normal: texture or vertex normal?
				"sub ft7 v0.xyz fc0.xyz" ,            // ft7 = V
				//"sub ft7 fc0.xyz v0.xyz",
				"nrm ft7.xyz ft7",				      // norm(V)
				"nrm ft1.xyz ft1",					  // norm(N)
				
				"neg ft3 ft7.xyz",//   -i
				"dp3 ft3 ft3 ft1",//   cosi = ft3 = dot(-i, n)
				"mul ft2 ft3 ft3",//   dot(-i, n) * dot(-i, n)
				"sub ft2 fc2.x ft2",// 1-dot(-i, n) * dot(-i, n)
				"mul ft2 fc2.w ft2",// eta*eta*(1-dot(-i, n) * dot(-i, n))
				"sub ft2 fc2.x ft2",// cos2 = ft2 = 1 - eta*eta*(1-dot(-i, n) * dot(-i, n))
				
				"abs ft4 ft2",// abs(cos2)
				"sqt ft4 ft4",// sqt(abs(cos2))
				"mul ft5 fc2.y ft3",// eta * cosi
				"sub ft5 ft5 ft4",//(eta*cosi - sqrt(abs(cost2))
				"mul ft5 ft5 ft1",//(eta*cosi - sqrt(abs(cost2))*n
				"mul ft4 fc2.y ft7",//eta*i
				"add ft4 ft4 ft5",// t = eta*i + ((eta*cosi - sqrt(abs(cost2))) * n)
			
				"sge ft5 ft2 fc2.z",// if k >=0 ft5 = 1	
				"mul ft3 ft4 ft5",

				//refract("ft3", "ft4", "ft7", "ft1", "fc2.x", "fc2.y", "fc2.w"),
				"tex ft3 ft3 fs0<3d,cube,linear>",   // get envMap
			
				_refractivityAGAL,                    // set refractivity map
				"mul ft0.xyz ft3.xyz fc3.xyz",		  // set color 
				"mov oc ft0"
				
			].join("\n");
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, _fragmentShader);
		}
		
		public function agCode(_op:String, _target:String, _reg1:String=null, _reg2:String=null):String{
			
			if(_reg1 != null && _reg2 != null)
				return _op + " " + _target + " "+_reg1 + " " + _reg2;
			
			if(_reg1 != null)
				return _op + " " + _target + " "+_reg1;
			
			return _op + " " + _target;
			
		}
		
		public function mix(target:String, temp:String, refract:String, reflect:String, fresnelTerm:String, one:String):String{
		
			var code:String = [ 
			
				agCode("sub", target, one, fresnelTerm), // 1 - fresnel
				agCode("mul", target, target, refract), // (1 - fresnel) * refract
				agCode("mul", temp, reflect, fresnelTerm), // reflect * fresnel
				agCode("add", target, target, temp) //  (1 - fresnel) * refract + reflect * fresnel
				
			].join("\n");
			
			return code;
		}
				
		public function refract(target:String, temp:String,
								view:String, normal:String, 
								one:String, ratio:String,ratioSquare:String):String{

			var code:String = [   
				agCode("dp3", temp, normal, view ),// dot(N.I)
				agCode("mul", temp, temp, temp),// dot(N.I) * dot(N.I)
				agCode("sub", temp, one, temp),// 1 - dot(N.I) * dot(N.I)
				agCode("mul", temp, temp, ratioSquare),// eta*eta(1 - dot(N.I) * dot(N.I))
				agCode("sub", temp, one, temp),// k = 1 - eta*eta(1 - dot(N.I) * dot(N.I))
				agCode("kil", temp+".x"),// if cond :if k < 0.0
			
				
				
				agCode("dp3", target, normal, view ),// dot(N.I)
				agCode("mul", target, ratio, target),// eta * dot(N.I)
				agCode("sqt", temp, temp),// sqt(k)
				agCode("add", target, target, temp ),// eta * dot(N.I) + sqt(k)
				agCode("mul", target, target, normal),//(eta * dot(N.I) + sqt(k)) * N
				agCode("mul", temp, ratio, view),// eta * I
				agCode("sub", target, temp, target)// eta * I - (eta * dot(N.I) + sqt(k)) * N)
				
			].join("\n");
			
			return code;
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
			
			if(m_refractivityMapDirty )
			{
				
				if(m_refractivityMap != null ){
					
					if( m_refractivityMapConst == null )
					{
						m_refractivityMapConst 						= new ShaderConstants();
						m_refractivityMapConst.type					= EShaderConstantsType.TEXTURE;
						m_refractivityMapConst.firstRegister		= 2;// FS
						params.fragmentShaderConstants.push(m_refractivityMapConst);	
					}
					m_refractivityMapConst.texture = m_refractivityMap;
				}else{
					
					if(m_refractivityMapConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_refractivityMapConst ), 1 );
						m_refractivityMapConst = null;
					}
				}
				disposeShaders();
				m_refractivityMapDirty = false;
				
			}
			
			key = "Yogurt3DOriginalsShaderRefraction" + ((m_normalMap)?"WithNormal":"") 
				+ ((m_normalMap && m_normalMap.mipmap)?"WithNormalMip":"") 
				+ ((m_refractivityMap)?"WithRefractivity":"")
				+ ((m_refractivityMap && m_refractivityMap.mipmap)?"WithRefMip":"") ;
			return super.getProgram( _context3D, _lightType, _meshType );
		}
	}
}