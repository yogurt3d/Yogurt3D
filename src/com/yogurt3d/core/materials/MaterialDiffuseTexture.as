/*
 * MaterialDiffuseTexture.as
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
 
package com.yogurt3d.core.materials
{
	
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.materials.shaders.ShaderAmbient;
	import com.yogurt3d.core.materials.shaders.ShaderDiffuse;
	import com.yogurt3d.core.materials.shaders.ShaderTexture;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.osflash.signals.Signal;
	
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class MaterialDiffuseTexture extends Material
	{
		private var m_lightShader:ShaderDiffuse;
		private var m_decalShader:ShaderTexture;
		private var m_ambientShader:ShaderAmbient;
		private var m_normalMap:TextureMap;
		
		public function MaterialDiffuseTexture( _texture:TextureMap = null, _opacity:Number = 1,_initInternals:Boolean=true)
		{
			super(_initInternals);
			
			m_decalShader = new ShaderTexture(_texture);
			m_decalShader.params.blendEnabled = true;
			if( _texture && !_texture.transparent )
			{
				m_decalShader.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
				m_decalShader.params.blendDestination = Context3DBlendFactor.ZERO;
			}else{
				m_decalShader.params.blendSource = Context3DBlendFactor.ONE;
				m_decalShader.params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			}
			m_decalShader.params.depthFunction = Context3DCompareMode.EQUAL;
			
			m_lightShader = new ShaderDiffuse(_opacity);
			
			shaders = Vector.<com.yogurt3d.core.materials.shaders.base.Shader>([
				m_ambientShader = new ShaderAmbient( _opacity),
				m_lightShader,  
				m_decalShader
			]);
			
			if(_texture && _texture.transparent){
				m_ambientShader.texture = _texture;
			}
			
			opacity = _opacity;
		}
		
		public function get killThreshold():Number{
			return m_decalShader.killThreshold;
		}
		
		public function set killThreshold(value:Number):void{
			m_decalShader.killThreshold = value;
			m_ambientShader.killThreshold = value;
		}
		
		public function get texture():TextureMap{
			return m_decalShader.texture as TextureMap;
		}
		public function set texture(_value:TextureMap):void{
			m_decalShader.texture = _value;
			
			if( _value && !_value.transparent )
			{
				m_decalShader.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
				m_decalShader.params.blendDestination = Context3DBlendFactor.ZERO;
			}else{
				m_decalShader.params.blendSource = Context3DBlendFactor.ONE;
				m_decalShader.params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			}
			
			if( _value )
			{
				m_ambientShader.texture = m_decalShader.texture as TextureMap;
				
				YOGURT3D_INTERNAL::m_transparent = m_ambientShader.texture.transparent || (m_ambientShader.opacity < 1);
			}
		}
		public function get uvOffset():Point{
			return m_decalShader.uVOffset;
		}
		public function set uvOffset(_value:Point):void{
			m_decalShader.uVOffset = _value;
		}
		public function get normalMap():TextureMap
		{
			return m_normalMap;
		}
		
		public function set normalMap(value:TextureMap):void
		{
			m_normalMap = value;
			m_lightShader.normalMap = m_normalMap;
		}
		
		public function get opacity():Number{
			return m_ambientShader.opacity;
		}
		
		public function set opacity(_value:Number):void{
			m_ambientShader.opacity = _value;
			m_decalShader.opacity = _value;
			m_lightShader.opacity = _value;
			
			YOGURT3D_INTERNAL::m_transparent = (m_ambientShader.texture && m_ambientShader.texture.transparent ) || (m_ambientShader.opacity < 1);
		}
		
		public override function dispose():void{
			super.dispose();
			
			normalMap = null
			texture = null;
		}
		
		public override function disposeDeep():void{
			if( normalMap )
			{
				normalMap.disposeDeep();
			}
			if( texture )
			{
				texture.disposeDeep();
			}
			dispose();
		}
		public override function disposeGPU():void{
			if( normalMap )
			{
				normalMap.disposeGPU();
			}
			if( texture )
			{
				texture.disposeGPU();
			}
			super.disposeGPU();
		}
		
	}
}
