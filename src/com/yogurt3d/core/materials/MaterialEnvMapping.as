/*
 * MaterialEnvMapping.as
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
	import com.yogurt3d.core.materials.shaders.ShaderEnvMapping;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	
	/**
	 * 
	 * @author Yogurt3D Corp. Core Team
	 *  
	 */
	public class MaterialEnvMapping extends Material
	{

		private var m_envShader:ShaderEnvMapping;
	
		public function MaterialEnvMapping( _envMap:CubeTextureMap, 
											_normalMap:TextureMap=null,
											_reflectivityMap:TextureMap=null,
											_opacity:Number=1.0,
											_initInternals:Boolean=true)
		{
			super(_initInternals);
			
				
			shaders = Vector.<com.yogurt3d.core.materials.shaders.base.Shader>([
				m_envShader = new ShaderEnvMapping(_envMap, _normalMap,_reflectivityMap, _opacity)
			]);			
			opacity = _opacity;
		}
		
		public function get envMap():CubeTextureMap
		{
			return m_envShader.envMap;
		}
		public function set envMap(value:CubeTextureMap):void
		{
			m_envShader.envMap = value;
		}
		
		public function get normalMap():TextureMap
		{
			return m_envShader.normalMap;
		}
		public function set normalMap(value:TextureMap):void
		{
			m_envShader.normalMap = value;
		}
		
		public function get opacity():Number{
			return m_envShader.alpha;
		}
		
		public function set opacity(_value:Number):void{
			m_envShader.alpha = _value;
			
			YOGURT3D_INTERNAL::m_transparent = (m_envShader.alpha < 1);
		}
		
		public function get reflectivityMap():TextureMap
		{
			return m_envShader.reflectivityMap;
		}
		public function set reflectivityMap(value:TextureMap):void
		{
			m_envShader.reflectivityMap = value;
		}
		
	}
}