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
	import com.yogurt3d.core.materials.shaders.ShaderAmbient;
	import com.yogurt3d.core.materials.shaders.ShaderDiffuse;
	import com.yogurt3d.core.materials.shaders.ShaderParticle;
	import com.yogurt3d.core.materials.shaders.ShaderSolidFill;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class MaterialParticle extends Material
	{
		private var m_particleShader:ShaderParticle;
		private var m_texture:TextureMap;
		private var m_color:uint;
		
		public function MaterialParticle( _texture:TextureMap=null, _color:uint=0xFF0000, _opacity:Number=1.0, _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			m_texture = _texture;
			m_color = _color;
		
			m_particleShader = new ShaderParticle(m_texture, _color, _opacity);
			shaders.push(m_particleShader);
		
			super.opacity = _opacity;
		}
		
		override public function clone():IEngineObject{
			var _materialCopy:MaterialParticle = new MaterialParticle;
			_materialCopy.m_color = color;
			_materialCopy.texture = texture;
			_materialCopy.opacity = opacity;
		//	_materialCopy = this.clone();
			
			for( var i:int = 0; i < this.shaders.length;i++)
			{
				_materialCopy.shaders.push(this.shaders[i]);
			}
			
			return _materialCopy;
		}
		
		public function get color():uint{
			return m_color;
		}
		
		public function set color(_value:uint):void{
		
			m_color = _value;
			m_particleShader.color = _value;
			
		}
		
		public function get texture():TextureMap{
			return m_texture; 
		}
		
		public function set texture(_value:TextureMap):void{
		
			m_texture = _value;
			m_particleShader.texture = _value;
		}
		
		public override function set opacity(value:Number):void{
			super.opacity = value;
			m_particleShader.opacity = value;
		
		}
	}
}
