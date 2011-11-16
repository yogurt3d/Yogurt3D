/*
* MaterialHemisphereTexture.as
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
	import com.yogurt3d.core.materials.shaders.ShaderHemisphereTexture;
	import com.yogurt3d.core.texture.TextureMap;
	
	public class MaterialHemisphereTexture extends Material
	{
		public function MaterialHemisphereTexture(texture:TextureMap, _initInternals:Boolean=true)
		{
			super(_initInternals);
			shaders.push( hemi = new ShaderHemisphereTexture(texture) );
			m_texture = texture;
			ambientColor.a = 1;
		}
		
		public function get alphaTexture():Boolean
		{
			return hemi.alphaTexture;
		}

		public function set alphaTexture(value:Boolean):void
		{
			hemi.alphaTexture = value;
		}

		public function get texture():TextureMap
		{
			return m_texture;
		}

		public function set texture(value:TextureMap):void
		{
			m_texture = value;
		}

		private var m_texture:TextureMap;
		public var hemi:ShaderHemisphereTexture;
		
		
		
	}
}