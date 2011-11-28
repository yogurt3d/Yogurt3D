/*
* MaterialFogDiffuseTexture.as
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
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display3D.Context3DBlendFactor;
	
	/**
	 * 
	 * @author Yogurt3D Corp. Core Team
	 *  
	 */
	public class MaterialFogDiffuseTexture extends Material
	{

		private var m_colorMap:TextureMap;
		private var m_normalMap:TextureMap;
		private var m_alpha:Number;
		
		public  var decal:ShaderTexture;
		private var m_ambShader:ShaderAmbient;
		private var m_diffShader:ShaderDiffuse;
		private var m_fogColor:uint;
		private var m_fogDistance:Number;

		
		public function MaterialFogDiffuseTexture(  _colorMap:TextureMap,
												    _fogDistance:Number,
													_fogColor:uint, 
													_normalMap:TextureMap=null,
													_alpha:Number=1.0,
													_initInternals:Boolean=true)
		{
			super(_initInternals);
			
			m_colorMap = _colorMap;
			m_normalMap = _normalMap;
			m_alpha = _alpha;
			m_fogDistance = _fogDistance;
			m_fogColor = _fogColor;
			
			m_ambShader = new ShaderAmbient();
			m_diffShader = new ShaderDiffuse();
			
			shaders = new Vector.<com.yogurt3d.core.materials.shaders.base.Shader>;
			
			shaders.push(m_ambShader);
			shaders.push(m_diffShader);
			
			if(m_colorMap != null){
				decal = new ShaderTexture(m_colorMap);
				decal.params.blendEnabled = true;
				decal.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
				decal.params.blendDestination = Context3DBlendFactor.ZERO;
				shaders.push(decal);
			}
			//shaders.push(m_envShader);
		}
		
		
		public function get diffShader():ShaderDiffuse
		{
			return m_diffShader;
		}
		
		public function set diffShader(value:ShaderDiffuse):void
		{
			m_diffShader = value;
		}
			
		public function get ambientShader():ShaderAmbient
		{
			return m_ambShader;
		}
		
		public function set ambientShader(value:ShaderAmbient):void
		{
			m_ambShader = value;
		}
		
		public function get normalMap():TextureMap
		{
			return m_normalMap;
		}
		
		public function set normalMap(value:TextureMap):void
		{
			m_normalMap = value;
			m_diffShader.normalMap = value;
		}
		
		public function get colorMap():TextureMap
		{
			return m_colorMap;
		}
		
		public function set colorMap(value:TextureMap):void
		{
			m_colorMap = value;
		}
		
	}
}