/*
* MaterialTextureColorFresnel.as
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
	import com.yogurt3d.core.materials.shaders.ShaderTextureColorFresnel;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
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
	public class MaterialTextureColorFresnel extends Material
	{
//		private var m_colorMap:TextureMap;
//		private var m_normalMap:TextureMap;
//		private var m_fresnelReflectance:Number;
//		private var m_fresnelPower:uint;
//		private var m_reflectivityMap:TextureMap;
//		private var m_color:uint;
//		private var m_gain:Number;
		
		private var m_freShader:ShaderTextureColorFresnel;
		
		public function MaterialTextureColorFresnel(_colorMap:TextureMap,
													_color:uint=0xFFFFFF,
													_normalMap:TextureMap=null,
													_gain:Number=0,
													_fresnelReflectance:Number=0.028,
													_fresnelPower:uint=5,
													_reflectivityMap:TextureMap=null,
													_opacity:Number=1.0,
													_initInternals:Boolean=true)
		{
			super(_initInternals);
			
			m_freShader = new ShaderTextureColorFresnel(
				_normalMap, 
				_reflectivityMap, _opacity,
				_fresnelReflectance, _fresnelPower, 
				_color, _colorMap, _gain);
			
			shaders.push(m_freShader);
			
			opacity = _opacity;
		}
		
		public function get texture():TextureMap
		{
			return m_freShader.texture;
		}
		public function set texture(value:TextureMap):void
		{
			m_freShader.texture = value;
			
		}
		
		public function get normalMap():TextureMap
		{
			return m_freShader.normalMap;
		}
		public function set normalMap(value:TextureMap):void
		{
			m_freShader.normalMap = value;
		}
		
		public function get normalMapUVOffset( ):Point{
			return m_freShader.normalMapUVOffset;
		}
		public function set normalMapUVOffset( _point:Point ):void{
			m_freShader.normalMapUVOffset = _point;
		}
		
		public function get fresnelReflectance():Number{
			return m_freShader.fresnelReflectance;
		}
		public function set fresnelReflectance(value:Number):void{
			m_freShader.fresnelReflectance = value;
		}
		
		public function get fresnelPower():uint{
			return m_freShader.fresnelPower;
		} 
		public function set fresnelPower(value:uint):void{
			m_freShader.fresnelPower = value;
		}
		
		public function get reflectivityMap():TextureMap
		{
			return m_freShader.reflectivityMap;
		}
		
		public function set reflectivityMap(value:TextureMap):void
		{
			m_freShader.reflectivityMap = value;
		}
		
		public function get color():uint{
			return m_freShader.color1;
		}
		public function set color(_value:uint):void{
			m_freShader.color1 = _value;
		}
		
		public function get gain():Number{
			return m_freShader.gain;
		}
		public function set gain(_value:Number):void{
			m_freShader.gain = _value;
		}
		
		
		public function get opacity():Number{
			return m_freShader.alpha;
		}
		
		public function set opacity(_value:Number):void{
			m_freShader.alpha = _value;
			
			YOGURT3D_INTERNAL::m_transparent = (_value < 1);
		}
	}
}