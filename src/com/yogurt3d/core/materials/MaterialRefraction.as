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
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
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
		private var m_fresnelShader:ShaderEnvMapFresnel = null;
		
//		private var m_envMap:CubeTextureMap;
//		private var m_normalMap:TextureMap;
//		private var m_refractivityMap:TextureMap;
//	
//		private var m_refIndex:Number;
//		private var m_fresnelReflectance:Number;
//		
//		private var m_color:uint;
//		private var m_fresnelPower:uint;
//		private var m_hasReflection:Boolean;
		private var m_hasFresnel:Boolean;
		
	
		public function MaterialRefraction( _envMap:CubeTextureMap, 
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
	
			
			m_hasFresnel = _hasFresnel;
						
			shaders.push( 
				m_refShader = new ShaderRefraction(_envMap, _color ,
												   _refIndex,  _normalMap, 
												   _refractivityMap, _alpha));
		
				
			if(m_hasFresnel)
				shaders.push(m_fresnelShader = new ShaderEnvMapFresnel(_envMap, _normalMap, _refractivityMap, _alpha, _fresnelReflectance, _fresnelPower));
			
			opacity = _alpha;
		}
		
		public function get fresnelReflectance():Number{
			if(hasFresnel)
				return m_fresnelShader.fresnelReflectance;
			return -1;
		}
		public function set fresnelReflectance(_value:Number):void{
		
			if(hasFresnel)
				m_fresnelShader.fresnelReflectance = _value;
		}
		
		public function get fresnelPower():uint{
			if(hasFresnel)
				return m_fresnelShader.fresnelPower;
			return 0;
		}
		public function set fresnelPower(_value:uint):void{
			if(hasFresnel)
				m_fresnelShader.fresnelPower = _value;
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
			
			if(m_hasFresnel){
				if(shaders.indexOf(m_fresnelShader) == -1){
					m_fresnelShader = new ShaderEnvMapFresnel(envMap, normalMap, refractivityMap, opacity, fresnelReflectance, fresnelPower);
					shaders.push(m_fresnelShader);
				}
				m_fresnelShader.alpha = this.opacity;
			}else{
				m_fresnelShader.alpha = 0;
			}
		
		}
		
		public function get color():uint{
			return m_refShader.color;
		}
		public function set color(_value:uint):void{
			m_refShader.color = _value;
		}
		
		public function get refIndex():Number{
			return m_refShader.refIndex;
		}
		public function set refIndex(_value:Number):void{
			m_refShader.refIndex = _value;
		}
		
		public function get refractivityMap():TextureMap
		{
			return m_refShader.refractivityMap;
		}
		public function set refractivityMap(value:TextureMap):void
		{

			m_refShader.refractivityMap = value;
			if(hasFresnel)
				m_fresnelShader.reflectivityMap = value;
		}		
		
		public function get opacity():Number{
			return m_refShader.alpha;
		}
		
		public function set opacity(_value:Number):void{
			m_refShader.alpha = _value;
			if(m_hasFresnel)
				m_fresnelShader.alpha = _value;
			
			YOGURT3D_INTERNAL::m_transparent = (_value < 1);
		}
		
		
		public function get normalMap():TextureMap
		{
			return m_refShader.normalMap;
		}
		public function set normalMap(value:TextureMap):void
		{
			m_refShader.normalMap = value;
			if(hasFresnel)
				m_fresnelShader.normalMap = value;
		}
		
		public function get envMap():CubeTextureMap
		{
			return m_fresnelShader.envMap;
		}
		public function set envMap(value:CubeTextureMap):void
		{
			if(hasFresnel)
				m_fresnelShader.envMap = value;
			m_refShader.envMap = value;
		}
	}
}