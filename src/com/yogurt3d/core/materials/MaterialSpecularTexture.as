/*
 * MaterialSpecularTexture.as
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
	import com.yogurt3d.core.materials.shaders.ShaderShadow;
	import com.yogurt3d.core.materials.shaders.ShaderSpecular;
	import com.yogurt3d.core.materials.shaders.ShaderTexture;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class MaterialSpecularTexture extends Material
	{
		private var m_lightShader:ShaderSpecular;
		private var m_ambientShader:ShaderAmbient;
		private var m_decalShader:ShaderTexture;
		
		public function MaterialSpecularTexture( _texture:TextureMap = null, _opacity:Number = 1, _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			m_decalShader = new ShaderTexture(_texture);
			m_decalShader.params.blendEnabled = true;
			m_decalShader.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
			m_decalShader.params.blendDestination = Context3DBlendFactor.ZERO;
			m_decalShader.params.depthFunction = Context3DCompareMode.EQUAL;
			
			shaders = Vector.<com.yogurt3d.core.materials.shaders.base.Shader>([
				m_ambientShader = new ShaderAmbient(_opacity),
				m_lightShader = new ShaderSpecular(_opacity),  
				m_decalShader
			]);
			
			texture = _texture;
			opacity = _opacity;
		}

		
		public function get opacity():Number{
			return m_ambientShader.opacity;
		}
		
		public function set opacity(_value:Number):void{
			m_ambientShader.opacity = _value;
			
			YOGURT3D_INTERNAL::m_transparent = (_value < 1);
		}
		
		public function get shininess():Number{
			return m_lightShader.shininess;
		}
		
		public function set shininess(_value:Number):void{
			m_lightShader.shininess = _value;
		}
		
		public function get normalMap():TextureMap
		{
			return m_lightShader.normalMap;
		}
		
		public function set normalMap(value:TextureMap):void
		{
			m_lightShader.normalMap = value;
		}
		
		public function get specularMap():TextureMap
		{
			return m_lightShader.specularMap;
		}
		
		public function set specularMap(value:TextureMap):void
		{
			m_lightShader.specularMap = value;
		}
			
		public function get texture():TextureMap{
			return m_decalShader.texture as TextureMap;
		}
		
		public function set texture(_value:TextureMap):void{
			m_decalShader.texture = _value;
			if( _value.transparent )
			{
				m_ambientShader.texture = _value;
			}
		}
	}
}
