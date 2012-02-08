/*
* MaterialHalfLambert.as
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
	import com.yogurt3d.core.materials.shaders.ShaderHalfLambert;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.texture.TextureMap;
	
	public class MaterialHalfLambert extends Material
	{
		
		private var m_shader:ShaderHalfLambert;
		
		public function MaterialHalfLambert(_texture:TextureMap=null,
											_alpha:Number=0.5,
											_beta:Number=0.5,
											_gamma:Number=1.0,
											_opacity:Number=1.0,
											_initInternals:Boolean=true)
		{
			super(_initInternals);
			
			shaders = Vector.<com.yogurt3d.core.materials.shaders.base.Shader>([
				m_shader = new ShaderHalfLambert(_texture,_alpha, _beta, _gamma,_opacity),
				
			]);
			
			opacity = _opacity;
		}
		
		public function get alpha():Number{
			return m_shader.alpha;
		}
		public function set alpha(_value:Number):void{
			m_shader.alpha = _value;
		}
		
		public function get beta():Number{
			return m_shader.beta;
		}
		public function set beta(_value:Number):void{
			m_shader.beta = _value;
		}
		
		public function get gamma():Number{
			return m_shader.gamma;
		}
		public function set gamma(_value:Number):void{
			m_shader.gamma = _value;
		}
		
		public function get opacity():Number{
			return m_shader.opacity;
		}
		
		public function set opacity(_value:Number):void{
			m_shader.opacity = _value;
			
			YOGURT3D_INTERNAL::m_transparent = (_value < 1);
		}
		
		public function get texture():TextureMap{
			return m_shader.texture;
		}
		public function set texture(_value:TextureMap):void{
			m_shader.texture = _value;
		}
	}
}