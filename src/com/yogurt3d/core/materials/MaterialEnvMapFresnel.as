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
	public class MaterialEnvMapFresnel extends Material
	{	
		public  var decal:ShaderTexture = null;
		private var m_envShader:ShaderEnvMapFresnel = null;
		
		public function MaterialEnvMapFresnel( _envMap:CubeTextureMap=null, 
											   _colorMap:TextureMap=null,
											   _normalMap:TextureMap=null,
											   _reflectivityMap:TextureMap=null,
											   _fresnelReflectance:Number=0.028,
											   _fresnelPower:uint=5,
											   _alpha:Number=1.0,
											   _opacity:Number=1.0,
											   _mipLevel:Boolean=false,
											   _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			
					
			m_envShader = new ShaderEnvMapFresnel(_envMap, _normalMap, 
				_reflectivityMap, _alpha,
				_fresnelReflectance, _fresnelPower );
			
			if(_colorMap != null){
				decal = new ShaderTexture(_colorMap);
				decal.params.blendEnabled = true;
				decal.params.blendSource = Context3DBlendFactor.ONE;
				decal.params.blendDestination = Context3DBlendFactor.ZERO;
				decal.params.depthFunction = Context3DCompareMode.LESS_EQUAL;
				shaders.push(decal);
				texture = _colorMap;
			}
			shaders.push(m_envShader);

			opacity = _opacity;
		}

		public function get envMap():CubeTextureMap
		{
			return m_envShader.envMap;
		}
		public function set envMap(value:CubeTextureMap):void
		{
			m_envShader.envMap = value;
		}
		
		public function get texture():TextureMap
		{
			if(decal)
				return decal.texture;
			
			return null;
		}
		public function set texture(value:TextureMap):void
		{
			if(value && value.transparent){
				m_envShader.texture = value;
			}
			
			if(decal && value){
				decal.texture = value;
			}else if(!decal && value){
				decal = new ShaderTexture(value);
				shaders.splice(shaders.indexOf(m_envShader), 1);
				decal.params.blendEnabled = true;
				decal.params.blendSource = Context3DBlendFactor.ONE;
				decal.params.blendDestination = Context3DBlendFactor.ZERO;
				decal.params.depthFunction = Context3DCompareMode.LESS_EQUAL;
				shaders.push(decal);
				shaders.push(m_envShader);
			}else{
				if( decal )
				{
					shaders.splice(2,1);
					decal.dispose();
					decal = null;
				}
			}
			
		}
		
		public function get normalMap():TextureMap
		{
			return m_envShader.normalMap ;
		}
		public function set normalMap(value:TextureMap):void
		{
			m_envShader.normalMap = value;
		}
		
		public function get normalMapUVOffset( ):Point{
			return m_envShader.normalMapUVOffset;
		}
		public function set normalMapUVOffset( _point:Point ):void{
			m_envShader.normalMapUVOffset = _point;
		}
		
		public function get alpha():Number{
			return m_envShader.alpha;
		}
		public function set alpha(_value:Number):void{
			m_envShader.alpha = _value;
		}
		
		public function get fresnelReflectance():Number{
			return m_envShader.fresnelReflectance;
		}
		public function set fresnelReflectance(value:Number):void{
			m_envShader.fresnelReflectance = value;
		}
		
		public function get fresnelPower():uint{
			return m_envShader.fresnelPower;
		} 
		public function set fresnelPower(value:uint):void{
			m_envShader.fresnelPower = value;
		}
		
		
		public function get reflectivityMap():TextureMap
		{
			return m_envShader.reflectivityMap;
		}
		
		public function set reflectivityMap(value:TextureMap):void
		{
			m_envShader.reflectivityMap = value;
		}
		
		public function get opacity():Number{
			return m_envShader.alpha;
		}
		
		public function set opacity(_value:Number):void{
			m_envShader.alpha = _value;
			
			YOGURT3D_INTERNAL::m_transparent = (m_envShader.alpha < 1);
		}
		
	}
}