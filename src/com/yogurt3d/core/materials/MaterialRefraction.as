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
	import com.yogurt3d.core.materials.shaders.ShaderAmbient;
	import com.yogurt3d.core.materials.shaders.ShaderEnvMapFresnel;
	import com.yogurt3d.core.materials.shaders.ShaderRefraction;
	import com.yogurt3d.core.materials.shaders.ShaderTexture;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display3D.Context3DBlendFactor;
	
	/**
	 * 
	 * @author Yogurt3D Corp. Core Team
	 *  
	 */
	public class MaterialRefraction extends Material
	{
		
		private var m_refShader:ShaderRefraction;
		private var m_ambShader:ShaderAmbient;
		private var m_fresnelShader:ShaderEnvMapFresnel;
		public  var decal:ShaderTexture;
		
		private var m_envMap:CubeTextureMap;
		private var m_normalMap:TextureMap;
		private var m_refractivityMap:TextureMap;
		private var m_colorMap:TextureMap;
	
		private var m_alpha:Number;
		private var m_refIndex:Number;
		private var m_fresnelReflectance:Number;
		
		private var m_color:uint;
		private var m_fresnelPower:uint;
		private var m_hasReflection:Boolean;
		private var m_hasFresnel:Boolean;
		
	
		public function MaterialRefraction( _envMap:CubeTextureMap=null, 
											_colorMap:TextureMap=null,
											_color:uint = 0xFFFFFF,
											_refIndex:Number = 1.0,
											_normalMap:TextureMap=null,
											_refractivityMap:TextureMap=null,
											_alpha:Number=1.0,
											_hasFresnel:Boolean=false,
											_fresnelReflectance:Number=0.028,
											_fresnelPower:uint=5,
											_initInternals:Boolean=true)
		{
			super(_initInternals);
			
			m_envMap = _envMap;		
			m_normalMap = _normalMap;
			m_alpha = _alpha;
			m_refractivityMap = _refractivityMap;
			m_refIndex = _refIndex;
			m_color = _color;
			m_colorMap = _colorMap;
			
			m_hasFresnel = _hasFresnel;
						
			shaders.push( 
				m_refShader = new ShaderRefraction(m_envMap, m_color ,
												   m_refIndex,  m_normalMap, 
												   m_refractivityMap, m_alpha));
			
			m_fresnelReflectance = _fresnelReflectance;
			m_fresnelPower = _fresnelPower;
			
			if(m_colorMap != null){
				decal = new ShaderTexture(m_colorMap);
				decal.params.blendEnabled = true;
				decal.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
				decal.params.blendDestination = Context3DBlendFactor.ZERO;
				shaders.push(decal);
			}
			
			if(m_hasFresnel)
				shaders.push(m_fresnelShader = new ShaderEnvMapFresnel(m_envMap, null, m_normalMap, m_refractivityMap, _alpha, _fresnelReflectance, _fresnelPower));
			
		}
		
		public function get colorMap():TextureMap{
			return m_colorMap;
		}
		
		public function set colorMap(_value:TextureMap):void{
			m_colorMap = _value;
			decal.texture = _value;
		}
		
		public function get fresnelReflectance():Number{
			return m_fresnelReflectance;
		}
		public function set fresnelReflectance(_value:Number):void{
		
			m_fresnelShader.fresnelReflectance = _value;
			m_fresnelReflectance = _value;
		}
		
		public function get fresnelPower():uint{
			return m_fresnelPower;
		}
		public function set fresnelPower(_value:uint):void{
			m_fresnelShader.fresnelPower = _value;
			m_fresnelPower = _value;
		}
		
		public function get fresnelShader():ShaderEnvMapFresnel{
			return m_fresnelShader;
		}
		public function set fresnelShader(_value:ShaderEnvMapFresnel):void{
			m_fresnelShader = _value;
		}
		
		public function get hasFresnel():Boolean{
			return m_hasFresnel;
		}
		public function set hasFresnel(_value:Boolean):void{
			m_hasFresnel = _value;
		}
		
		public function get color():uint{
			return m_color;
		}
		public function set color(_value:uint):void{
			m_color = _value;
			m_refShader.color = _value;
		}
		
		public function get refIndex():Number{
			return m_refIndex;
		}
		public function set refIndex(_value:Number):void{
			m_refShader.refIndex = _value;
			m_refIndex = _value;
		}
		
		public function get refractivityMap():TextureMap
		{
			return m_refractivityMap;
		}
		public function set refractivityMap(value:TextureMap):void
		{
			m_refractivityMap = value;
			m_refShader.refractivityMap = value;
			m_fresnelShader.reflectivityMap = value;
		}
		
		
		public function get alpha():Number{
			return m_alpha;
		}
		public function set alpha(_alpha:Number):void{
			m_refShader.alpha = _alpha;
			m_fresnelShader.alpha = _alpha;
			m_alpha = _alpha;
		}
		
		public function get normalMap():TextureMap
		{
			return m_normalMap;
		}
		public function set normalMap(value:TextureMap):void
		{
			m_normalMap = value;
			m_refShader.normalMap = value;
			m_fresnelShader.normalMap = value;
		}
		
		public function get envMap():CubeTextureMap
		{
			return m_envMap;
		}
		public function set envMap(value:CubeTextureMap):void
		{
			m_envMap = value;
			m_fresnelShader.envMap = value;
			m_refShader.envMap = value;
		}
	}
}