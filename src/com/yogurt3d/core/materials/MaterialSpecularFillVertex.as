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
	
	import com.yogurt3d.core.materials.base.Color;
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.materials.shaders.ShaderHemisphere;
	import com.yogurt3d.core.materials.shaders.ShaderSolidFill;
	import com.yogurt3d.core.materials.shaders.ShaderSpecular;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.texture.TextureMap;
	
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
		private var m_lightShader:ShaderSpecular;
		private var m_decalShader:ShaderSolidFill;
		private var m_ambientShader:ShaderHemisphere;
		
		public function MaterialSpecularFillVertex( _color:uint, _opacity:Number = 1, _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			m_decalShader = new ShaderSolidFill(_color,_opacity);
			m_decalShader.params.blendEnabled = true;
			m_decalShader.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
			m_decalShader.params.blendDestination = Context3DBlendFactor.ZERO;
			m_decalShader.params.depthFunction = Context3DCompareMode.EQUAL;
			
			shaders = Vector.<com.yogurt3d.core.materials.shaders.base.Shader>([
				m_ambientShader = new ShaderHemisphere(_opacity),
				m_lightShader = new ShaderSpecular(_opacity),
				m_decalShader
			]);
			
			super.opacity = _opacity;
			super.ambientColor = new Color(0.3, 0.3, 0.3, 1.0);
		}
		public function get color():uint{
			return m_decalShader.color;
		}
		
		public function set color(_val:uint):void{
			m_decalShader.color = _val;
		}
		public override function set opacity(value:Number):void{
			super.opacity = value;
			m_decalShader.opacity = value;
			m_ambientShader.opacity = value;
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
