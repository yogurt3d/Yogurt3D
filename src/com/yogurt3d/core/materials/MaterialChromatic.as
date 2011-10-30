/*
* MaterialParticle.as
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
	import com.yogurt3d.core.materials.shaders.ShaderChromatic;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.geom.Vector3D;
	
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class MaterialChromatic extends Material
	{
		private var m_chroShader:ShaderChromatic;
		private var m_texture:TextureMap;
		private var m_envMap:CubeTextureMap;
		private var m_glossMap:TextureMap;
		private var m_Io:Vector3D;
		private var m_fresnel:Vector3D;
		private var m_opacity:Number;
	
		
		public function MaterialChromatic( _envMap:CubeTextureMap,
										   _glossMap:TextureMap=null,
										   _baseMap:TextureMap=null, 
										   _IoValues:Vector3D=null, 
										   _fresnelVal:Vector3D=null,
										   _opacity:Number=1.0, _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			m_envMap = _envMap;
			m_texture = _baseMap;
			m_glossMap = _glossMap;
		
			if( (m_texture != null && m_glossMap == null)||
				(m_texture == null && m_glossMap != null)){
				throw new Error( "MaterialChromatic: You should give base texture and gloss map!" );
			}
				
			m_Io = _IoValues;
			m_fresnel = _fresnelVal;
			
			m_chroShader = new ShaderChromatic(_envMap, _glossMap, _baseMap, _IoValues, _fresnelVal);
			shaders.push(m_chroShader);
			
			super.opacity = _opacity;
		}
		
		public function get envMap():CubeTextureMap{
			return m_envMap; 
		}
		public function set envMap(_value:CubeTextureMap):void{
			
			m_envMap = _value;
			m_chroShader.envMap = _value;
		}
		
		public function get glossMap():TextureMap{
			return m_glossMap; 
		}
		
		public function set glossMap(_value:TextureMap):void{
			
			m_glossMap = _value;
			m_chroShader.glossMap = _value;
		}
		
		public function get Io():Vector3D{
			return m_Io; 
		}
		public function get fresnel():Vector3D{
			return m_fresnel; 
		}
		
		public function set Io(_val:Vector3D):void{
			m_Io = _val; 
			m_chroShader.Io = _val;
		}
		public function set fresnel(_val:Vector3D):void{
			m_fresnel = _val; 
			m_chroShader.fresnel = _val;
		}
		
		public function get texture():TextureMap{
			return m_texture; 
		}
		
		public function set texture(_value:TextureMap):void{
			
			m_texture = _value;
			m_chroShader.texture = _value;
		}
		
		
		public override function set opacity(value:Number):void{
			super.opacity = value;
			m_chroShader.opacity = value;
			// TODO
		}
	}
}
