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
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	
	/**
	 * 
	 * @author Yogurt3D Corp. Core Team
	 *  
	 */
	public class MaterialEnvMapping extends Material
	{

		private var m_envMap:CubeTextureMap;
		private var m_normalMap:TextureMap;
		private var m_alpha:Number;
		private var m_envShader:ShaderEnvMapping;
		private var m_reflectivityMap:TextureMap;

		
		public function MaterialEnvMapping( _envMap:CubeTextureMap, 
											_normalMap:TextureMap=null,
											_reflectivityMap:TextureMap=null,
											_alpha:Number=1.0,
											_opacity:Number=1.0,
											_initInternals:Boolean=true)
		{
			super(_initInternals);
			
			super.opacity = _opacity;
			
			m_envMap = _envMap;		
			m_normalMap = _normalMap;
			m_alpha = _alpha;
			m_reflectivityMap = _reflectivityMap;
					
			shaders = Vector.<com.yogurt3d.core.materials.shaders.base.Shader>([
				m_envShader = new ShaderEnvMapping(m_envMap, m_normalMap,m_reflectivityMap, m_alpha)
			]);			
		}
		
		public function get envMap():CubeTextureMap
		{
			return m_envMap;
		}
		public function set envMap(value:CubeTextureMap):void
		{
			m_envMap = value;
			m_envShader.envMap = value;
		}
		
		public function get normalMap():TextureMap
		{
			return m_normalMap;
		}
		public function set normalMap(value:TextureMap):void
		{
			m_normalMap = value;
			m_envShader.normalMap = value;
		}
		
		public function get alpha():Number{
			return m_envShader.alpha;
		}
		public function set alpha(_alpha:Number):void{
			m_envShader.alpha = _alpha;
		}
		
		public function get reflectivityMap():TextureMap
		{
			return m_reflectivityMap;
		}
		public function set reflectivityMap(value:TextureMap):void
		{
			m_reflectivityMap = value;
			m_envShader.reflectivityMap = value;
		}
		public override function set opacity(value:Number):void{
			super.opacity = value;	
		}	
	}
}