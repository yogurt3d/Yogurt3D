/*
 * MaterialFill.as
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
	import com.yogurt3d.core.materials.shaders.ShaderSolidFill;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;

	/**
	 * Material for backward compability. This material is used for basic fill, without light of self shadowing.
	 * 
	 * @example Here is a sample usage to assign a texture to a <code>SceneObject</code>.
	 * <listing version="3.0" >
	 *	    sceneObgject.material = new MaterialFill( 0xFF0000, 0,5 );
	 * </listing>
 	 * 
  	 * @author Yogurt3D Engine Core Team
  	 * @company Yogurt3D Corp.
  	 **/
	public class MaterialFill extends Material
	{
		private var m_shader:ShaderSolidFill;
		/**
		 * Constructor 
		 * @param _color color in RGB 
		 * @param _alpha Alpha value between 0-1
		 * @param _initInternals
		 * 
		 */
		public function MaterialFill(_color:uint = 0xFFFFFF, _opacity:Number = 1,_initInternals:Boolean=true)
		{
			super(_initInternals);
			shaders.push( m_shader = new ShaderSolidFill( _color, _opacity ) );
			
			opacity = _opacity;
		}
		
		public function get color():uint{
			return m_shader.color;
		}
		
		public function set color(_val:uint):void{
			m_shader.color = _val;
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
