/*
* MaterialToonTexture.as
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
	import com.yogurt3d.core.materials.shaders.ShaderToonTexture;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.texture.TextureMap;
	
	
	public class MaterialToonTexture extends Material
	{
		private var m_shader:ShaderToonTexture;
		
		public function MaterialToonTexture(_texture:TextureMap,
									 _contourColor:uint = 0x000000,
									 _contourThickness:Number=0.3,
									 _opacity:Number=1.0,_initInternals:Boolean=true)
		{
			super(_initInternals);
			shaders.push( m_shader = new ShaderToonTexture( _texture, _contourColor, _contourThickness, _opacity ) );
			
			opacity = _opacity;
		}
		
		public function get texture():TextureMap{
			return m_shader.texture;
		}
		
		public function set texture(_val:TextureMap):void{
			m_shader.texture = _val;
		}
		
		public function get contourThickness():Number{
			return m_shader.contourThickness;
		}
		
		public function set contourThickness(_val:Number):void{
			m_shader.contourThickness = _val;
		}
		
		public function get contourColor():uint{
			return m_shader.contourColor;
		}
		
		public function set contourColor(_val:uint):void{
			m_shader.contourColor = _val;
		}
		
		public function get opacity():Number{
			return m_shader.opacity;
		}
		
		public function set opacity(_value:Number):void{
			m_shader.opacity = _value;
			
			YOGURT3D_INTERNAL::m_transparent = (_value < 1);
		}
	}
}
