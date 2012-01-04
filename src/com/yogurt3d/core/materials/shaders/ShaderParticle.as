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
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class ShaderParticle extends Shader
	{
		private var m_mipLevel					:uint;
		private var m_opacity					:Number;
		private var m_color						:uint;
		private var m_texture					:TextureMap;
		private var _textureShaderConstants		:ShaderConstants;
		private var _colorShaderConstants		:ShaderConstants;
		private var m_textureMapDirty			:Boolean = false;
		
		/**
		 * 
		 * 
		 * @author Yogurt3D Engine Core Team
		 * @company Yogurt3D Corp.
		 **/
		public function ShaderParticle(_texture:TextureMap=null, _color:uint=0xFF0000, _opacity:Number=1.0, _mipLevel:uint = 0)
		{
			key = "Yogurt3DOriginalsShaderParticle";
			
			m_opacity 		= _opacity;
			m_mipLevel 		= _mipLevel;
			m_color 		= _color;
			
			
			params.writeDepth 		= true;
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling			= Context3DTriangleFace.NONE;
			params.depthFunction	= Context3DCompareMode.ALWAYS;
			


			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV );
		
			params.vertexShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.SPRITE_MATRIX));
	
			// fc0: color + alpha : 
			_colorShaderConstants						= new ShaderConstants();
			_colorShaderConstants.type 					= EShaderConstantsType.CUSTOM_VECTOR;
			_colorShaderConstants.firstRegister			= 0;
			
			var _r:uint = _color >> 16;
			var _g:uint = _color >> 8 & 0xFF;
			var _b:uint = _color & 0xFF;
			
			_colorShaderConstants.vector = Vector.<Number>([_r/255,_g/255,_b/255, m_opacity]);
			
			params.fragmentShaderConstants.push(_colorShaderConstants);
			
			texture = _texture;
			
		}
		
		public function get opacity():Number{
			return m_opacity;
		}
		
		public function set opacity(_value:Number):void{
			
			m_opacity = _value;	
			_colorShaderConstants.vector[3] = m_opacity;
		}
		
		public function get color():uint{
			return m_color;
		}
		
		public function set color(_value:uint):void{
			
			m_color = _value;
			
			var _r:uint = m_color >> 16;
			var _g:uint = m_color >> 8 & 0xFF;
			var _b:uint = m_color & 0xFF;
			
			_colorShaderConstants.vector = Vector.<Number>([_r/255,_g/255,_b/255, m_opacity]);
			
		}
		
		public function get texture():TextureMap{
			return m_texture; 
		}
		
		public function set texture(_value:TextureMap):void{
			
			m_texture = _value;
			m_textureMapDirty = true;
		
		}
			
		
		
		public override function getProgram(_context3D:Context3D, _lightType:ELightType=null, _meshType:String = null):Program3D{
			
			if(m_textureMapDirty )
			{
				if(m_texture != null ){
					if( _textureShaderConstants == null )
					{
						_textureShaderConstants 						= new ShaderConstants();
						_textureShaderConstants.type					= EShaderConstantsType.TEXTURE;
						_textureShaderConstants.firstRegister			= 0;// FS1
						params.fragmentShaderConstants.push(_textureShaderConstants);	
					}
					_textureShaderConstants.texture = m_texture;
				}else{
					if(_textureShaderConstants != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( _textureShaderConstants ), 1 );
						_textureShaderConstants = null;
					}
				}
				disposeShaders();
				m_textureMapDirty = false;
			}
			
			key = "Yogurt3DOriginalsShaderParticle" + ((m_texture)?"WithTexture":"");
			return super.getProgram( _context3D, _lightType, _meshType );
		}
				public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			//va0 : vertex position 
			//va1: uvt
			//va2: normals
			//va3: tangents
							
			var _vertexShader:String = [
					
				"m44 op va0 vc0",	
				//"mov v1 va2",  // pass normals
				"mov v2 va1"  // pass UV
				
			].join("\n");
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, _vertexShader);
		}
	
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			var _fragmentShader:String = [
				(m_texture)?"tex ft1 v2 fs0<2d,linear,repeat>\nmul ft1 ft1 fc0":"mov ft1 fc0",
			//	"mov ft1.w fc0.w",
				"div ft1.xyz, ft1.xyz, fc0.w",
				"mov oc ft1",
				
			].join("\n");
			
			return new AGALMiniAssembler().assemble(AGALMiniAssembler.FRAGMENT, _fragmentShader);
		}
		
	}
}