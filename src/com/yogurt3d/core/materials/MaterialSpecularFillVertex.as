/*
* MaterialSpecularFill.as
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
	import com.yogurt3d.core.materials.shaders.ShaderSolidFill;
	import com.yogurt3d.core.materials.shaders.ShaderSpecular;
	import com.yogurt3d.core.materials.shaders.ShaderSpecularVertex;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	
	/**
	 *
	 *
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class MaterialSpecularFillVertex extends Material
	{
		private var m_lightShader:ShaderSpecularVertex;
		private var m_decalShader:ShaderSolidFill;
		private var m_ambientShader:ShaderAmbient;
		
		public function MaterialSpecularFillVertex( _color:uint, _opacity:Number = 1, _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			m_decalShader = new ShaderSolidFill(_color,_opacity);
			m_decalShader.params.blendEnabled = true;
			m_decalShader.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
			m_decalShader.params.blendDestination = Context3DBlendFactor.ZERO;
			m_decalShader.params.depthFunction = Context3DCompareMode.EQUAL;
			
			shaders = Vector.<com.yogurt3d.core.materials.shaders.base.Shader>([
				m_ambientShader = new ShaderAmbient(_opacity),
				m_lightShader = new ShaderSpecularVertex(_opacity),
				m_decalShader
			]);
			
			opacity = _opacity;
		}
		public function get color():uint{
			return m_decalShader.color;
		}
		
		public function set color(_val:uint):void{
			m_decalShader.color = _val;
		}
		
		public function get opacity():Number{
			return m_decalShader.opacity;
		}
		
		public function set opacity(_value:Number):void{
			m_decalShader.opacity = _value;
			m_ambientShader.opacity = _value;
			
			YOGURT3D_INTERNAL::m_transparent = (_value < 1);
		}
		
		public function get shininess():Number{
			return m_lightShader.shininess;
		}
		
		public function set shininess(_value:Number):void{
			m_lightShader.shininess = _value;
		}
		
		public function get specularMap():TextureMap
		{
			return m_lightShader.specularMap;
		}
		
		public function set specularMap(value:TextureMap):void
		{
			m_lightShader.specularMap = value;
		}
	}
}
