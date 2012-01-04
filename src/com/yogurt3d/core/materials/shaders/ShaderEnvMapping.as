/*
 * ShaderEnvMapping.as
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
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class ShaderEnvMapping extends Shader
	{
		private var m_cubeMap						:CubeTextureMap;
		private var m_alpha							:Number;
		private var m_envMapTexture					:ShaderConstants;
		public  var m_alphaConsts					:ShaderConstants;
		private var m_normalMap						:TextureMap;
		private var m_reflectivityMap				:TextureMap;
		
		private var m_normalMapDirty				:Boolean = false;
		private var m_normalMapConst				:ShaderConstants;
		private var m_reflectivityMapDirty			:Boolean = false;
		private var m_reflectivityMapConst			:ShaderConstants;

		private var _alphaTextureConst:ShaderConstants;
		private var _alphaDirty:Boolean = false;
		private var m_texture:TextureMap;
	
		/**
		 * 
		 * 
		 * @author Yogurt3D Engine Core Team
		 * @company Yogurt3D Corp.
		 **/
		public function ShaderEnvMapping(_cubeMap:CubeTextureMap, _normalMap:TextureMap=null,
										 _reflectivityMap:TextureMap=null,
										 _alpha:Number=1.0 ){
			key = "Yogurt3DOriginalsShaderEnvMapping";
			
			params.writeDepth 		= true;
			params.depthFunction 	= Context3DCompareMode.LESS_EQUAL;
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling			= Context3DTriangleFace.FRONT;
			
			params.requiresLight			= false;

			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.NORMAL, EVertexAttribute.TANGENT, EVertexAttribute.BONE_DATA);
			
			params.vertexShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.MVP_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(4, EShaderConstantsType.MODEL_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(8, EShaderConstantsType.BONE_MATRICES));
			
			// environmental map // FS0
			m_envMapTexture 							= new ShaderConstants(0, EShaderConstantsType.TEXTURE);
			m_envMapTexture.texture 					= _cubeMap;
			params.fragmentShaderConstants.push(m_envMapTexture);
			

			var _fragmentShaderConsts:ShaderConstants;
			
			// fc0: camera pos
			params.fragmentShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.CAMERA_POSITION));
				
			// fc1 : alpha
			m_alphaConsts   							= new ShaderConstants(1,EShaderConstantsType.CUSTOM_VECTOR );
			m_alphaConsts.vector						= Vector.<Number>([ _alpha, 1.0, 0.2, -1.0 ]);
			params.fragmentShaderConstants.push(m_alphaConsts);
			
			envMap					= _cubeMap;
			alpha 					= _alpha;
			normalMap 				= _normalMap;
			reflectivityMap			= _reflectivityMap;

		}
		
		public function get texture():TextureMap
		{
			return m_texture;
		}

		public function set texture(value:TextureMap):void
		{
			m_texture = value;
			_alphaDirty = true;
		}

		public function get envMap():CubeTextureMap{
			return m_cubeMap;
		}
		public function set envMap(_value:CubeTextureMap):void{
			m_cubeMap = _value;
			m_envMapTexture.texture = m_cubeMap;
		}
		
		public function get alpha():Number{
			return m_alpha;
		}
		public function set alpha(_value:Number):void{
			m_alpha = _value;
			m_alphaConsts.vector[0] =  m_alpha;	
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
			
			if(m_normalMap != null){
				
				_normalAGAL = [   
					
					((!normalMap.mipmap)?"tex ft1 v2 fs1<2d,wrap,linear>":"tex ft1 v2 fs1<2d,wrap,linear,miplinear>"),
					// lookup normal from normal map, move from [0,1] to  [-1, 1] range, normalize
					// texNormal = texNormal * 2 - 1;
					"add ft1 ft1 ft1",
					"sub ft1 ft1 fc1.y",
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
				
					((!reflectivityMap.mipmap)?"tex ft2 v2 fs2<2d,wrap,linear>":"tex ft2 v2 fs2<2d,wrap,linear,miplinear>"),     // get reflection map
					"mul ft0.w ft2.xyz fc1.x"
				
				].join("\n");
			
			}else{
				_reflectivityAGAL =  "mov ft0.w fc1.x"; 
			}
			
			// V: view vector
			// N: normal
			// T: tangent
			// B: binormal
			
			var _environmentalMappingFS:String = [   
					"mov ft3 v3",					      // ft3 = T 
					"mov ft4 v4",                         // ft4 = B
					_normalAGAL,					      // decide normal: texture or vertex normal?
					"sub ft7 fc0 v0" ,                    // ft7 = V
					"nrm ft7.xyz ft7",				      // norm(V)
					"dp3 ft0 ft7 ft1", 				      // V.N
					"add ft0 ft0 ft0",                    // 2(V.N)
					"mul ft0 ft0 ft1",   			      // 2(V.N)N
					"sub ft0 ft0 ft7",   				  // 2(V.N)N - V
					"tex ft0 ft0 fs0<3d,cube,linear> ",   // get envMap
					((texture && texture.transparent)?"tex ft1, v2.xy, fs3<2d,wrap,linear>\n" +
						"sub ft1.w ft1.w fc1.z\nkil ft1.w":""),
					_reflectivityAGAL,                    // set alpha
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
			
			if(_alphaDirty )
			{
				
				if(texture != null ){
					
					if( _alphaTextureConst == null )
					{
						_alphaTextureConst 	= new ShaderConstants(3, EShaderConstantsType.TEXTURE);
						params.fragmentShaderConstants.push(_alphaTextureConst);	
					}
					_alphaTextureConst.texture = texture;
				}else{
					
					if(_alphaTextureConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( _alphaTextureConst ), 1 );
						_alphaTextureConst = null;
					}
				}
				disposeShaders();
				_alphaDirty = false;
				
			}
			
			key = "Yogurt3DOriginalsShaderEnvMapping" + ((m_normalMap)?"WithNormal":"") +
				((m_normalMap && m_normalMap.mipmap)?"WithNormalMipmap":"") + 
				((m_reflectivityMap && m_reflectivityMap.mipmap)?"WithRefMipmap":"") + 
				((m_reflectivityMap)?"WithReflectivity":"")+
				((m_texture && m_texture.transparent)?"WithTextureAlpha":"");
			return super.getProgram( _context3D, _lightType, _meshType );
		}
	}
}