/*
 * ShaderBitmapData.as
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
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.core.texture.base.ITexture;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class ShaderTexture extends Shader
	{
		private var _textureMap:Dictionary;
		
		private var _textureShaderConstants:ShaderConstants;
		
		private var m_bitmapData:TextureMap;
		
		private var vaPos:uint = 0;
		private var vaUV:uint = 1;
		private var vaBoneIndices:uint = 2;
		private var vaBoneWeight:uint = 4;
		private var vaUV2:uint = 1;
		
		private var m_lightMapChannel:uint = 0;
		
		private var vcModelToWorld:uint = 1;
		private var vcProjection:uint   = 5;
		private var vcBoneMatrices:uint = 9;
		
		private var m_lightMap:TextureMap;
		private var m_shadowMapDirty:Boolean = false;
		private var m_shadowMapShaderConstants:ShaderConstants;
		
		private var m_alphaTextureDirty:Boolean = false;
		private var m_alphaTexture:Boolean = false;
		private var m_alphaShaderConstant:ShaderConstants;
		
		
		public function ShaderTexture(_texture:TextureMap)
		{
			super();
													
			_textureMap = new Dictionary();
		
			key = "Yogurt3DOriginalsShaderBitmapData"+((_texture &&_texture.mipmap)?"WithMipmap":"");
			
			m_bitmapData = _texture;
		
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.BONE_DATA );
			
			params.depthFunction 	= Context3DCompareMode.LESS;
			params.writeDepth		= true;
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.ONE;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;	
			params.culling = Context3DTriangleFace.FRONT;

			 
			// Shader Parameters
			params.vertexShaderConstants.push(new ShaderConstants(vcProjection, EShaderConstantsType.MVP_TRANSPOSED));
			
			params.vertexShaderConstants.push(new ShaderConstants(vcModelToWorld, EShaderConstantsType.MODEL_TRANSPOSED));
			
			params.vertexShaderConstants.push( new ShaderConstants(vcBoneMatrices, EShaderConstantsType.BONE_MATRICES));
			
			_textureShaderConstants 	= new ShaderConstants(0, EShaderConstantsType.TEXTURE);
			_textureShaderConstants.texture 				= _texture;
			params.fragmentShaderConstants.push(_textureShaderConstants);
			
			m_alphaShaderConstant 	= new ShaderConstants(0, EShaderConstantsType.CUSTOM_VECTOR );
			m_alphaShaderConstant.vector 				= Vector.<Number>([0.2,1.0,0,0]);
			
			
			m_shadowMapShaderConstants = new ShaderConstants(1, EShaderConstantsType.TEXTURE);
		}
				
		public function get alphaTexture():Boolean{
			return m_alphaTexture;
		}
		
		public function set alphaTexture(value:Boolean):void{
			if( m_alphaTexture != value )
			{
				m_alphaTexture = value;
				if( m_alphaTexture )
				{
					params.fragmentShaderConstants.push(m_alphaShaderConstant);
				}else{
					params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_alphaShaderConstant ), 1 );
				}
				m_alphaTextureDirty = true;
			}
		}
		
		public function get lightMap():TextureMap
		{
			return m_lightMap;
		}
		public function set lightMap(value:TextureMap):void
		{
			m_lightMap = value;
			m_shadowMapDirty = true;
		
			if( m_lightMap )
			{
				if( params.fragmentShaderConstants.indexOf( m_shadowMapShaderConstants ) == -1 )
				{
					params.fragmentShaderConstants.push( m_shadowMapShaderConstants );
				}
				m_shadowMapShaderConstants.texture = m_lightMap;
			}else{
				if( params.fragmentShaderConstants.indexOf( m_shadowMapShaderConstants ) > -1 )
				{
					params.fragmentShaderConstants.splice(  params.fragmentShaderConstants.indexOf( m_shadowMapShaderConstants ), 1 );
				}
			}
		}
		
		public function get shadowAndLightMapUVChannel(  ):uint{
			return m_lightMapChannel;
		}
		
		public function set shadowAndLightMapUVChannel( channel:uint ):void{
			if( m_lightMapChannel != channel )
			{
				m_lightMapChannel = channel;
				if( channel == 1 ) {
					vaUV2 = 6;
					attributes.push( EVertexAttribute.UV_2 );
				}else{
					vaUV2 = vaUV;
					attributes.pop();
				}
				disposeShaders();
			}
		}
		
		public override function getProgram(_context3D:Context3D, _lightType:ELightType=null, _meshKey:String=""):Program3D{
			
			key = "Yogurt3DOriginalsShaderBitmapData"+((texture && texture.mipmap)?"WithMipmap":"");
			
			if( m_shadowMapDirty )
			{
				disposeShaders();
				m_shadowMapDirty = false;
				key = "Yogurt3DOriginalsShaderBitmapData" + ((m_lightMap)?"WithShadowMap"+m_lightMapChannel:"") + 
					((m_alphaTexture)?"WithAlphaTexture":"") +((texture.mipmap)?"WithMipmap":"");
				
			}
			
			if( m_alphaTextureDirty )
			{
				disposeShaders();
				m_alphaTextureDirty = false;
				key = "Yogurt3DOriginalsShaderBitmapData" + ((m_lightMap)?"WithShadowMap"+m_lightMapChannel:"") 
					+ ((m_alphaTexture)?"WithAlphaTexture":"") + ((texture.mipmap)?"WithMipmap":"");
			}
			if(!m_bitmapData)
			{
				return null;
			}
			return super.getProgram( _context3D, _lightType, _meshKey );
		}
		
		/**
		 * @inheritDoc
		 * 
		 */
		public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			if( _meshKey == "SkinnedMesh" )
			{
				var code:String = ShaderUtils.getSkeletalAnimationVertexShader( 
					vaPos, vaUV, 0, 
					vaBoneIndices, vaBoneWeight, 
					vcProjection, vcModelToWorld, vcBoneMatrices, 
					0 );
				code += "mov v0, va1\n";
				// Vertex Program
				return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, 	code );
			}
			return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, 	
				"m44 op, va0, vc5\nmov v0, va1.xyzw\n" + ((m_lightMap )?"mov v1 va"+vaUV2+"\n":"")
			);
		}
		/**
		 * @inheritDoc
		 * 
		 */
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			var code:String;
			
			if(texture.mipmap)
				code = "tex ft0, v0, fs0<2d,wrap,linear,miplinear>\n";
			else
				code = "tex ft0, v0, fs0<2d,wrap,linear>\n";
			
			if( m_alphaTexture )
			{
				code += "sub ft1.x, ft0.w, fc0.x\nkil ft1.x\n";
			}
			if(m_lightMap){
				if(m_lightMap.mipmap)
					code += "tex ft1, v1.xy, fs1<2d,wrap,linear,miplinear>\nmul ft0, ft1, ft0\n";
				else
					code += "tex ft1, v1.xy, fs1<2d,wrap,linear>\nmul ft0, ft1, ft0\n";
			}
			
		//	if()
		//	code += "mul ft0.w, ft0.w, fc0.y\n";
			code += "mov oc, ft0";
			return ShaderUtils.fragmentAssambler.assemble(Context3DProgramType.FRAGMENT,code);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get texture():TextureMap
		{
			return m_bitmapData;
		}

		/**
		 * @private 
		 * @param value
		 * 
		 */
		public function set texture(value:TextureMap):void
		{
			if( value )
			{				
				m_bitmapData = value;
				_textureShaderConstants.texture = m_bitmapData;
			}
		}
		
		/**
		 * 
		 * 
		 */
		public function dispose():void{
			super.disposeShaders();
		}
	}
}
