/*
* MaterialEnvMapFresnel.as
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
	import com.yogurt3d.core.materials.shaders.ShaderEnvMapFresnel;
	import com.yogurt3d.core.materials.shaders.ShaderTexture;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Yogurt3D Corp. Core Team
	 *  
	 */
	public class MaterialEnvMapFresnel extends Material
	{
		private var m_envMap:CubeTextureMap;
		private var m_colorMap:TextureMap;
		private var m_normalMap:TextureMap;
		private var m_alpha:Number;
		private var m_fresnelReflectance:Number;
		private var m_fresnelPower:uint;
		private var m_reflectivityMap:TextureMap;
		
		//		public  var decal:ShaderTexture;
		private var m_envShader:ShaderEnvMapFresnel;
		//		private var m_ambShader:ShaderAmbient;
		//		private var m_diffShader:ShaderDiffuse;
		
		public function MaterialEnvMapFresnel( _envMap:CubeTextureMap=null, 
											   _colorMap:TextureMap=null,
											   _normalMap:TextureMap=null,
											   _reflectivityMap:TextureMap=null,
											   _fresnelReflectance:Number=0.028,
											   _fresnelPower:uint=5,
											   _alpha:Number=1.0,
											   _opacity:Number=1.0,
											   _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			super.opacity = _opacity;
			
			m_envMap = _envMap;		
			m_colorMap = _colorMap;
			m_normalMap = _normalMap;
			
			m_reflectivityMap = _reflectivityMap;
			m_alpha = _alpha;
			m_fresnelReflectance = _fresnelReflectance;
			m_fresnelPower = _fresnelPower;
			
			//			shaders.push(m_ambShader = new ShaderAmbient());
			//			shaders.push(m_diffShader = new ShaderDiffuse());
			
			m_envShader = new ShaderEnvMapFresnel(m_envMap, m_colorMap, m_normalMap, 
				m_reflectivityMap, m_alpha,
				m_fresnelReflectance, m_fresnelPower );
			
			//			if(m_colorMap != null){
			//				decal = new ShaderTexture(m_colorMap);
			//				decal.params.blendEnabled = true;
			//				decal.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
			//				decal.params.blendDestination = Context3DBlendFactor.ZERO;
			//				shaders.push(decal);
			//			}
			shaders.push(m_envShader);
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
		
		public function get texture():TextureMap
		{
			return m_colorMap;
		}
		public function set texture(value:TextureMap):void
		{
			m_colorMap = value;
			m_envShader.texture = value;
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
		
		public function get normalMapUVOffset( ):Point{
			return m_envShader.normalMapUVOffset;
		}
		public function set normalMapUVOffset( _point:Point ):void{
			m_envShader.normalMapUVOffset = _point;
		}
		
		public function get alpha():Number{
			return m_alpha;
		}
		public function set alpha(_value:Number):void{
			m_alpha = _value;
			m_envShader.alpha = _value;
		}
		
		public function get fresnelReflectance():Number{
			return m_fresnelReflectance;
		}
		public function set fresnelReflectance(value:Number):void{
			m_fresnelReflectance = value;
			m_envShader.fresnelReflectance = value;
		}
		
		public function get fresnelPower():uint{
			return m_fresnelPower;
		} 
		public function set fresnelPower(value:uint):void{
			m_fresnelPower = value;
			m_envShader.fresnelPower = value;
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
			//m_ambShader.opacity = value;
		}
		
	}
}