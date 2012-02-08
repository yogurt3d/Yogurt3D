/*
 * ShaderAmbient.as
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
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;

	/**
	 * Ambient pass for multi-pass rendering pipeline.
	 * 
  	 * @author Yogurt3D Engine Core Team
  	 * @company Yogurt3D Corp.
  	 **/
	public class ShaderAmbient extends Shader
	{
		
		private var vaPos:uint = 0;
		private var vaUV:uint = 1;
		private var vaBoneIndices:uint = 2;
		private var vaBoneWeight:uint = 4;
		
		private var vcProjection:uint   = 0;
		private var vcModel:uint = 4;
		private var vcBoneMatrices:uint = 8;
		
		private var fcMaterialOpacity:uint			= 0;
		private var fcMaterialEmissive:uint			= 5;
		private var fcMaterialAmbient:uint			= 6;
		
		private var _alphaShaderConsts:ShaderConstants;
		private var _alphaTextureConst:ShaderConstants;
		private var _alphaDirty:Boolean = false;
		private var m_texture:TextureMap;
		
		public function ShaderAmbient( _alpha:Number = 1)
		{
			super();
			
			key = "Yogurt3DOriginalsShaderAmbient";
			
			params.blendEnabled			= true;
			params.blendSource			= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination		= Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.writeDepth			= true;
			params.depthFunction		= Context3DCompareMode.LESS;
			params.colorMaskEnabled		= false;
			params.colorMaskR			= true;
			params.colorMaskG			= true;
			params.colorMaskB			= true;
			params.colorMaskA			= true;
			params.culling				= Context3DTriangleFace.FRONT;
			params.loopCount			= 1;
			params.requiresLight				= false;
			
			attributes.push(EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.BONE_DATA );
			
			// Vertex Shader Constants
			var _vertexShaderConsts:ShaderConstants;
					
			params.vertexShaderConstants.push( new ShaderConstants(vcProjection, EShaderConstantsType.MVP_TRANSPOSED) );
						
			params.vertexShaderConstants.push(new ShaderConstants(vcModel, EShaderConstantsType.MODEL_TRANSPOSED));
			
			params.vertexShaderConstants.push(new ShaderConstants(vcBoneMatrices, EShaderConstantsType.BONE_MATRICES));
			
			_alphaShaderConsts 				= new ShaderConstants(fcMaterialOpacity, EShaderConstantsType.CUSTOM_VECTOR);
			_alphaShaderConsts.vector		= Vector.<Number>([_alpha,0.0001,1,0.1]);
			
			params.fragmentShaderConstants.push(_alphaShaderConsts);
		
			// Fragment Shader Constants
			params.fragmentShaderConstants.push(new ShaderConstants(fcMaterialEmissive, EShaderConstantsType.MATERIAL_EMISSIVE_COLOR));
			
			params.fragmentShaderConstants.push(new ShaderConstants(fcMaterialAmbient, EShaderConstantsType.MATERIAL_AMBIENT_COLOR));
		}
		public function get killThreshold():Number{
			return _alphaShaderConsts.vector[3];
		}
		
		public function set killThreshold(value:Number):void{
			_alphaShaderConsts.vector[3] = value;
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
		public function get opacity():Number{
			return _alphaShaderConsts.vector[0];
		}
		public function set opacity(_alpha:Number):void{
			_alphaShaderConsts.vector[0] = _alpha;
		}
		public override function getProgram(_context3D:Context3D, _lightType:ELightType=null, _meshKey:String=""):Program3D{
			if(_alphaDirty )
			{
				
				if(texture != null ){
					
					if( _alphaTextureConst == null )
					{
						_alphaTextureConst 	= new ShaderConstants(0, EShaderConstantsType.TEXTURE);
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
			
			key = "Yogurt3DOriginalsShaderAmbient"+
				((texture && texture.transparent)?"WithAlphaTexture":"");
		
			return super.getProgram( _context3D, _lightType, _meshKey );
		}
		
		public override function getVertexProgram( _meshKey:String, _lightType:ELightType = null ):ByteArray{
			if( _meshKey == "SkinnedMesh" )
			{
				var boneCount:uint = uint( _meshKey.replace( "SkinnedMesh_", "") );
				var code:String = ShaderUtils.getSkeletalAnimationVertexShader( 
					vaPos, vaUV, 0, 
					vaBoneIndices, vaBoneWeight, 
					vcProjection, vcModel, vcBoneMatrices, 
					0, false, false, false );
				code += "mov v0, va" + vaUV + "\n"; // float4 temp1 = vertexNormal;
				// Vertex Program
				return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, 	code );
			}
			return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, 
				"m44 op, va" + vaPos + ", vc" + vcProjection + "\n" + 
				"mov v0, va" + vaUV + "\n" // float4 temp1 = vertexNormal;
			);
		}
		
		public override function getFragmentProgram( _lightType:ELightType=null ):ByteArray{
			return ShaderUtils.fragmentAssambler.assemble(Context3DProgramType.FRAGMENT, 
				"mov ft0, fc" + fcMaterialEmissive + "\n"+ // emissive = emissiveColor;
				"mov ft1, fc" +fcMaterialAmbient+ "\n" + // // ambient = ambientColor;
				
				"add ft0, ft0, ft1\n" + // float4 color = emissive + ambient;
				
				"mov ft0.w, fc" + fcMaterialOpacity + ".x\n" + // color.w = opacity;
				((texture && texture.transparent)?"tex ft1, v0.xy, fs0<2d,wrap,linear>\n" +
					"sub ft1.w, ft1.w, fc"+fcMaterialOpacity+".w\n" +
					"kil ft1.w\n":"" )+ 
				"mov oc, ft0\n" // outputColor = color;
			);
		}
	}
}
