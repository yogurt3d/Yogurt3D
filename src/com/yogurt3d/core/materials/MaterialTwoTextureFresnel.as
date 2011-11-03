/*
* MaterialTwoTextureFresnel.as
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
* MERCHANTABILITY or FITNESS FOR A PARTICULA R PURPOSE. 
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
	import com.yogurt3d.core.materials.shaders.ShaderTwoTextureFresnel;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Yogurt3D Corp. Core Team
	 *  
	 */
	public class MaterialTwoTextureFresnel extends Material
	{
		private var m_normalMap:TextureMap;
		private var m_fresnelReflectance:Number;
		private var m_fresnelPower:uint;
		private var m_reflectivityMap:TextureMap;
		private var m_texture1:TextureMap;
		private var m_texture2:TextureMap;
		private var m_gain:Number;
		
		private var m_freShader:ShaderTwoTextureFresnel;
		
		public function MaterialTwoTextureFresnel( _texture1:TextureMap,
												   _texture2:TextureMap,
												   _fresnelReflectance:Number=0.028,
												   _fresnelPower:uint=5,
												   _gain:Number=0,
												   _normalMap:TextureMap=null,
												   _reflectivityMap:TextureMap=null,
												   _opacity:Number=1.0,
												   _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			super.opacity = _opacity;
			
			m_normalMap = _normalMap;
			
			m_reflectivityMap = _reflectivityMap;
			m_fresnelReflectance = _fresnelReflectance;
			m_fresnelPower = _fresnelPower;
			
			m_texture1 = _texture1;
			m_texture2 = _texture2;
			
			m_gain = _gain;
			
			m_freShader = new ShaderTwoTextureFresnel(m_normalMap, 
				m_reflectivityMap, _opacity,
				m_fresnelReflectance, m_fresnelPower, 
				m_texture1, m_texture2);
			
			shaders.push(m_freShader);
		}
		
		public function get normalMap():TextureMap
		{
			return m_normalMap;
		}
		public function set normalMap(value:TextureMap):void
		{
			m_normalMap = value;
			m_freShader.normalMap = value;
		}
		
		public function get normalMapUVOffset( ):Point{
			return m_freShader.normalMapUVOffset;
		}
		public function set normalMapUVOffset( _point:Point ):void{
			m_freShader.normalMapUVOffset = _point;
		}
		
		public function get fresnelReflectance():Number{
			return m_fresnelReflectance;
		}
		public function set fresnelReflectance(value:Number):void{
			m_fresnelReflectance = value;
			m_freShader.fresnelReflectance = value;
		}
		
		public function get fresnelPower():uint{
			return m_fresnelPower;
		} 
		public function set fresnelPower(value:uint):void{
			m_fresnelPower = value;
			m_freShader.fresnelPower = value;
		}
		
		public function get reflectivityMap():TextureMap
		{
			return m_reflectivityMap;
		}
		
		public function set reflectivityMap(value:TextureMap):void
		{
			m_reflectivityMap = value;
			m_freShader.reflectivityMap = value;
		}
		
		public function get texture1():TextureMap{
			return m_texture1;
		}
		public function set texture1(_value:TextureMap):void{
			m_texture1 = _value;
			m_freShader.texture1 = _value;
		}
		
		public function get texture2():TextureMap{
			return m_texture2;
		}
		public function set texture2(_value:TextureMap):void{
			m_texture2 = _value;
			m_freShader.texture2 = _value;
		}
		
		public function get gain():Number{
			return m_gain;
		}
		public function set gain(_value:Number):void{
			m_gain = _value;
			m_freShader.gain = _value;
		}
		
		public override function set opacity(_value:Number):void{
			super.opacity = _value;
			m_freShader.alpha = _value;
		}
	}
}