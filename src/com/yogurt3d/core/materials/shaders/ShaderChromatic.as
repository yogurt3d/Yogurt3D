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
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	public class ShaderChromatic extends Shader
	{
		private var m_texture				:TextureMap = null;
		private var m_envMap				:CubeTextureMap;
		private var m_glossMap				:TextureMap = null;
		private var m_Io					:Vector3D = null;
		private var m_fresnel				:Vector3D = null;
		private var m_opacity				:Number;
		
		private var m_envMapTexture			:ShaderConstants;
		private var m_glossTexture			:ShaderConstants;
		private var m_baseTexture			:ShaderConstants;
		private var m_ioConst				:ShaderConstants;
		private var m_fresnelConst			:ShaderConstants;
		
		private var m_glossDirty:Boolean = false;
		private var m_baseDirty:Boolean  = false;
		
		/**
		 * 
		 * 
		 * @author Yogurt3D Engine Core Team
		 * @company Yogurt3D Corp.
		 **/
		public function ShaderChromatic(_envMap:CubeTextureMap,
									   _glossMap:TextureMap=null,
									   _baseMap:TextureMap=null, 
									   _IoValues:Vector3D=null, 
									   _fresnelVal:Vector3D=null,
									   _opacity:Number=1.0)
		{
			key = "Yogurt3DOriginalsShaderChromatic";
			
			m_envMap = _envMap;
			m_opacity = _opacity;
			
			if(m_Io == null)
				m_Io = new Vector3D(1.14,1.12,1.10);
			else
				m_Io = _IoValues;
			if(m_fresnel == null)
				m_fresnel = new Vector3D(0.15,2.0, 0.0 )
			else
				m_fresnel = _fresnelVal;
			
			texture = _baseMap;
			glossMap = _glossMap;
			
			params.writeDepth 		= true;
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling			= Context3DTriangleFace.FRONT;
			params.depthFunction    = Context3DCompareMode.LESS;
			
	
			params.requiresLight			= false;
			
			attributes.push(EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.NORMAL, EVertexAttribute.BONE_DATA);
			
			params.vertexShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.MVP_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(4, EShaderConstantsType.MODEL_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(8, EShaderConstantsType.BONE_MATRICES));
			
			// environmental map
			m_envMapTexture 							= new ShaderConstants(0, EShaderConstantsType.TEXTURE);
			m_envMapTexture.texture 					= m_envMap;
			params.fragmentShaderConstants.push(m_envMapTexture);
						
			// fc0 : ioConst
			m_ioConst   							= new ShaderConstants(0, EShaderConstantsType.CUSTOM_VECTOR);
			m_ioConst.vector						= Vector.<Number>([ m_Io.x, m_Io.y, m_Io.z, m_opacity ]);
			params.fragmentShaderConstants.push(m_ioConst);
			
			// fc1 : fresnel
			m_fresnelConst   							= new ShaderConstants(1, EShaderConstantsType.CUSTOM_VECTOR);
			m_fresnelConst.vector						= Vector.<Number>([ m_fresnel.x, m_fresnel.y, 0.0, 0.2 ]);
			params.fragmentShaderConstants.push(m_fresnelConst);
			
			// fc2: camera pos
			params.fragmentShaderConstants.push(new ShaderConstants(2, EShaderConstantsType.CAMERA_POSITION));
			
			// fc3: dummy constants
			var _fragmentShaderConsts:ShaderConstants;
			_fragmentShaderConsts   				= new ShaderConstants(3, EShaderConstantsType.CUSTOM_VECTOR);
			_fragmentShaderConsts.vector			= Vector.<Number>([ 1.0, 0.0, 2.0, 3.0 ]);
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
	
		}
		
		public function get envMap():CubeTextureMap{
			return m_envMap; 
		}
		public function set envMap(_value:CubeTextureMap):void{
			
			m_envMap = _value;
			m_envMapTexture.texture = m_envMap;
		}
		
		public function get glossMap():TextureMap{
			return m_glossMap; 
		}
		public function set glossMap(_value:TextureMap):void{
			
			m_glossMap = _value;
			m_glossDirty = true;
			//m_glossTexture.texture = m_glossMap;
		}
		
		public function get Io():Vector3D{
			return m_Io; 
		}
		public function get fresnel():Vector3D{
			return m_fresnel; 
		}
		
		public function set Io(_val:Vector3D):void{
			if(_val){
				m_Io = _val; 
				m_ioConst.vector = Vector.<Number>([ m_Io.x, m_Io.y, m_Io.z, m_opacity ]);
			}
			
		}
		public function set fresnel(_val:Vector3D):void{
			if(_val){
				m_fresnel = _val; 
				m_fresnelConst.vector = Vector.<Number>([ m_fresnel.x, m_fresnel.y, m_fresnel.z, 0.2 ]);
			}
			
		}
		
		public function get texture():TextureMap{
			return m_texture; 
		}
		public function set texture(_value:TextureMap):void{
			
			m_texture = _value;
			m_baseDirty = true;
			
		}
		
		public function get opacity():Number{
			return m_opacity;
		}
		public function set opacity(_val:Number):void{
			m_opacity = _val;
			m_ioConst.vector[3]	= m_opacity;
		}
		
		public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			
			if( _meshKey == "SkinnedMesh")
			{
				var assembler:AGALMiniAssembler = new AGALMiniAssembler();
				
				var code:String = ShaderUtils.getSkeletalAnimationVertexShader( 
					0, 1, 2, 
					3, 5, 
					0, 4, 8, 
					0, false, false, false  );
				
				code += "mov v" + 0 +".xyzw, vt0.xyzw\n";
				code += "mov v" + 1 + ".xyzw, vt1.xyzw\n";
				code += "mov v" + 2 + ", va1\n";
	
				return assembler.assemble(Context3DProgramType.VERTEX, 	code );
			}
			
			//va0 : vertex position 
			//va1: uvt
			//va2: normals		
			var _vertexShader:String = [
				
				"m44 op va0 vc0" , 
				"m44 v0 va0 vc4" , 	
				"m33 vt0.xyz va2 vc4",
				"mov v1.w va2.w",
				"nrm vt0.xyz vt0.xyz" ,
				"mov v1.xyz vt0.xyz" ,// pass Normals
				"mov v2 va1",  // pass UV
			
			].join("\n");
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, _vertexShader);
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			//v1: normals
			//v2: uv
			//fs0 : environmental map
			//fs1 : gloss map
			//fs2 : base map
			//fc0: [ m_Io.x, m_Io.y, m_Io.z, m_opacity ]
			//fc1: [ m_fresnel.x, m_fresnel.y, m_fresnel.z, 0.0 ]
			//fc2: camera pos
			//fc3: Vector.<Number>([ 1.0, 0.0, 2.0, 3.0 ]);
			
			if(m_glossMap != null && m_texture != null){
			
				var _fragmentShaderWithGloss:String = [
					"sub ft0 v0 fc2" , 		// E = WorldPos.xyz - CameraPos.xyz;	
					"nrm ft0.xyz ft0.xyz", 	// normalize(E);
					"mov ft1 v1",
					"nrm ft1.xyz ft1.xyz",	// normalize(N);
					
					//------ Find the reflection
					ShaderUtils.reflect("ft2", "ft0", "ft1"),
					"nrm ft2.xyz ft2.xyz",
					"tex ft2 ft2 fs0<3d,cube,linear> ",// ft2 = reflectColor
					
					//------ Find the refraction
					//
					ShaderUtils.refract("ft3", "ft0", "ft1", "fc0.x","fc3.x", "fc3.y","ft4", "ft5"),
					"tex ft3 ft3 fs0<3d,cube,linear> ",
					ShaderUtils.refract("ft4", "ft0", "ft1", "fc0.y","fc3.x", "fc3.y","ft5", "ft6"),
					"tex ft4 ft4 fs0<3d,cube,linear> ",
					ShaderUtils.refract("ft5", "ft0", "ft1", "fc0.z","fc3.x", "fc3.y","ft6", "ft7"),
					"tex ft5 ft5 fs0<3d,cube,linear> ",
					
					"mov ft3.y ft4.y",
					"mov ft3.z ft5.z",
					"mov ft3.w fc3.x", // ft3 = refractColor
					
					//------ Do a gloss map look up and compute the reflectivity
					"mul ft4 v2 fc3.z", 
					((!glossMap.mipmap)?"tex ft4 ft4 fs1<2d,wrap,linear>":"tex ft4 ft4 fs1<2d,wrap,linear,miplinear>"),//glossmap
					"add ft5.x ft4.x ft4.y",
					"add ft5.x ft5.x ft4.z",
					"div ft5.x ft5.x fc3.w",// ft5 = reflectivity = (gloss_color.r + gloss_color.g + gloss_color.b)/3.0;
					
					//------ Find the Fresnel term
					// ft4 = fast_fresnel(-incident, normal, fresnelValues);
					
					"neg ft0 ft0.xyz", 
					ShaderUtils.fastFresnel("ft4", "ft1", "ft0", "fc1", "fc3.x", "ft6"),
					
					//------ Write the final pixel.
					
					"sub ft1 fc3.x ft4",
					
					ShaderUtils.mix("ft6", "ft7", "ft3", "ft2", "ft4", "ft1"),//color = mix(refractColor, reflectColor, fresnelTerm);
					// get basemap
					((!texture.mipmap)?"tex ft4 v2 fs2<2d,wrap,linear>":"tex ft4 v2 fs2<2d,wrap,linear,miplinear>"),//ft4
					((texture.transparent)?"sub ft2.x ft4.w fc1.w\nkil ft2.x":""),
					"sub ft1.x fc3.x ft5.x",
					
					ShaderUtils.mix("ft0", "ft7", "ft4", "ft6", "ft5.x", "ft1.x"),//mix(base_color, color, reflectivity)
					"mul ft0.w fc0.w ft4.w",
					"mov oc ft0"
					
				].join("\n");
				return new AGALMiniAssembler().assemble(AGALMiniAssembler.FRAGMENT, _fragmentShaderWithGloss);
			}
				
			var _fragmentShader:String = [
				"sub ft0 v0 fc2" , 		// E = WorldPos.xyz - CameraPos.xyz;	
				"nrm ft0.xyz ft0.xyz", 	// normalize(E);
				"mov ft1 v1",
				"nrm ft1.xyz ft1.xyz",	// normalize(N);
				
				//------ Find the reflection
				ShaderUtils.reflect("ft2", "ft0", "ft1"),
				"nrm ft2.xyz ft2.xyz",
				"tex ft2 ft2 fs0<3d,cube,linear> ",// ft2 = reflectColor
				
				//------ Find the refraction
				//
				ShaderUtils.refract("ft3", "ft0", "ft1", "fc0.x","fc3.x", "fc3.y","ft4", "ft5"),
				"tex ft3 ft3 fs0<3d,cube,linear> ",
				ShaderUtils.refract("ft4", "ft0", "ft1", "fc0.y","fc3.x", "fc3.y","ft5", "ft6"),
				"tex ft4 ft4 fs0<3d,cube,linear> ",
				ShaderUtils.refract("ft5", "ft0", "ft1", "fc0.z","fc3.x", "fc3.y","ft6", "ft7"),
				"tex ft5 ft5 fs0<3d,cube,linear> ",
				
				"mov ft3.y ft4.y",
				"mov ft3.z ft5.z",
				"mov ft3.w fc3.x", // ft3 = refractColor
				
				//------ Find the Fresnel term
				// ft4 = fast_fresnel(-incident, normal, fresnelValues);
				
				"neg ft0 ft0.xyz", 
				ShaderUtils.fastFresnel("ft4", "ft1", "ft0", "fc1", "fc3.x", "ft6"),
				
				//------ Write the final pixel.
				
				"sub ft1 fc3.x ft4",
				ShaderUtils.mix("ft6", "ft7", "ft3", "ft2", "ft4", "ft1"),//color = mix(refractColor, reflectColor, fresnelTerm);
				
				"mov ft6.w fc0.w",
				"mov oc ft6"
			
			].join("\n");
		
			return new AGALMiniAssembler().assemble(AGALMiniAssembler.FRAGMENT, _fragmentShader);
		}
		
		public override function getProgram(_context3D:Context3D, _lightType:ELightType=null, _meshType:String = null):Program3D{
			if(m_baseDirty )
			{
				if(m_texture != null ){
					
					if( m_baseTexture == null )
					{
						m_baseTexture 						= new ShaderConstants();
						m_baseTexture.type					= EShaderConstantsType.TEXTURE;
						m_baseTexture.firstRegister			= 2;// FS2
						params.fragmentShaderConstants.push(m_baseTexture);	
					}
					m_baseTexture.texture = m_texture;
				}else{
					
					if(m_baseTexture != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_baseTexture ), 1 );
						m_baseTexture = null;
					}
				}
				disposeShaders();
				m_baseDirty = false;
			}
			
			if(m_glossDirty )
			{
				
				if(m_glossMap != null ){
					
					if( m_glossTexture == null )
					{
						m_glossTexture 						= new ShaderConstants();
						m_glossTexture.type					= EShaderConstantsType.TEXTURE;
						m_glossTexture.firstRegister		= 1;// FS1
						params.fragmentShaderConstants.push(m_glossTexture);	
					}
					m_glossTexture.texture = m_glossMap;
				}else{
					
					if(m_glossTexture != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_glossTexture ), 1 );
						m_glossTexture = null;
					}
				}
				disposeShaders();
				m_glossDirty = false;
				
			}
			
			key = "Yogurt3DOriginalsShaderChromatic" + ((m_texture)?"WithBase":"") + 
				((m_glossMap)?"WithGloss":"") + 
				((m_glossMap && m_glossMap.mipmap)?"WithGlossMip":"")+
				((m_texture && m_texture.mipmap)?"WithTexMip":"");
			return super.getProgram( _context3D, _lightType, _meshType );
		}
		
	}
}