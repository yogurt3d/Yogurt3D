/*
* MaterialChromatic.as
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
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
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
		
		public function MaterialChromatic( _envMap:CubeTextureMap,
										   _glossMap:TextureMap=null,
										   _baseMap:TextureMap=null, 
										   _IoValues:Vector3D=null, 
										   _fresnelVal:Vector3D=null,
										   _opacity:Number=1.0, _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			if( (_baseMap != null && _glossMap == null)||
				(_baseMap == null && _glossMap != null)){
				throw new Error( "MaterialChromatic: You should give base texture and gloss map!" );
			}
				
			m_chroShader = new ShaderChromatic(_envMap, _glossMap, _baseMap, _IoValues, _fresnelVal);
			shaders.push(m_chroShader);
			
			envMap = _envMap;
			texture = _baseMap;
			glossMap = _glossMap;
			Io = _IoValues;
			fresnel = _fresnelVal;
		
			opacity = _opacity;
		}
		

		public function get envMap():CubeTextureMap{
			return m_chroShader.envMap; 
		}
		public function set envMap(_value:CubeTextureMap):void{
			m_chroShader.envMap = _value;
		}
		
		public function get glossMap():TextureMap{
			return m_chroShader.glossMap; 
		}
		
		public function set glossMap(_value:TextureMap):void{
			
			m_chroShader.glossMap = _value;
		}
		
		public function get Io():Vector3D{
			return m_chroShader.Io; 
		}
		
		public function set Io(_val:Vector3D):void{
			m_chroShader.Io = _val;
		}
		
		public function get fresnel():Vector3D{
			return m_chroShader.fresnel; 
		}
	
		public function set fresnel(_val:Vector3D):void{
			m_chroShader.fresnel = _val;
		}
		
		public function get texture():TextureMap{
			return m_chroShader.texture; 
		}
		
		public function set texture(_value:TextureMap):void{
			
			m_chroShader.texture = _value;
		}
		public function get opacity():Number{
			return m_chroShader.opacity;
		}
		public function set opacity(value:Number):void{
			m_chroShader.opacity = value;
			
			YOGURT3D_INTERNAL::m_transparent = (m_chroShader.opacity < 1);
		}
	}
}
