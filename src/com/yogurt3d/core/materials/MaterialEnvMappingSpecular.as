/*
* MaterialEnvMappingSpecular.as
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
	import com.yogurt3d.core.materials.shaders.ShaderEnvMapping;
	import com.yogurt3d.core.materials.shaders.ShaderSpecular;
	import com.yogurt3d.core.materials.shaders.ShaderTexture;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	
	/**
	 * 
	 * @author Yogurt3D Corp. Core Team
	 *  
	 */
	public class MaterialEnvMappingSpecular extends Material
	{
		private var m_lightShader:ShaderSpecular;
		private var m_envShader:ShaderEnvMapping;
		private var m_ambShader:ShaderAmbient;
		public  var m_decalShader:ShaderTexture;
		
		public function MaterialEnvMappingSpecular( _envMap:CubeTextureMap, 
													_colorMap:TextureMap=null,
													_normalMap:TextureMap=null,
													_specularMap:TextureMap=null,
													_reflectivityMap:TextureMap=null,
													_alpha:Number=1.0,_opacity:Number=1.0,
													_initInternals:Boolean=true)
		{
			super(_initInternals);
			
			
			m_envShader = new ShaderEnvMapping(_envMap, _normalMap, _reflectivityMap, _alpha);
			m_ambShader = new ShaderAmbient(_opacity);
			
			shaders = new Vector.<com.yogurt3d.core.materials.shaders.base.Shader>;
			
			shaders.push(m_ambShader);	
			shaders.push(m_lightShader = new ShaderSpecular());
			
			
			if(_colorMap != null){
				m_decalShader = new ShaderTexture(_colorMap);
				m_decalShader.params.blendEnabled = true;
				m_decalShader.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
				m_decalShader.params.blendDestination = Context3DBlendFactor.ZERO;
				m_decalShader.params.depthFunction = Context3DCompareMode.EQUAL;
				shaders.push(m_decalShader);
				this.texture = _colorMap;
			}
			
			shaders.push(m_envShader);
			
			normalMap = _normalMap;
			specularMap = _specularMap;
			reflectivityMap = _reflectivityMap;
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
			if(m_decalShader)
				return m_decalShader.texture;
			return null;
		}
		public function set texture(value:TextureMap):void
		{
			if( value )
			{
				if(value.transparent){
					m_ambShader.texture = value;
					m_envShader.texture = value;
				}
				if( m_decalShader )
				{
					m_decalShader.texture = value;
				}else{
					if(value != null){
						m_decalShader = new ShaderTexture(value);
						shaders.splice(shaders.indexOf(m_envShader), 1);
						m_decalShader.params.blendEnabled = true;
						m_decalShader.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
						m_decalShader.params.blendDestination = Context3DBlendFactor.ZERO;
						m_decalShader.params.depthFunction = Context3DCompareMode.EQUAL;
						shaders.push(m_decalShader);
						shaders.push(m_envShader);
					}
				}
			}else{
				if( m_decalShader )
				{
					shaders.splice(2,1);
					m_decalShader.dispose();
					m_decalShader = null;
				}
			}
		}
		
		public function get normalMap():TextureMap
		{
			return m_envShader.normalMap;
		}
		public function set normalMap(value:TextureMap):void
		{
			m_envShader.normalMap = value;
			m_lightShader.normalMap = value;
		}
		
		public function get specularMap():TextureMap
		{
			return m_lightShader.specularMap;
		}
		public function set specularMap(value:TextureMap):void
		{
			m_lightShader.specularMap = value;
		}
		
		public function get reflectivityMap():TextureMap
		{
			return m_envShader.reflectivityMap;
		}
		public function set reflectivityMap(value:TextureMap):void
		{
			m_envShader.reflectivityMap = value;
		}
		
		public function get alpha():Number
		{
			return m_envShader.alpha;
		}
		public function set alpha(_alpha:Number):void{
			m_envShader.alpha = _alpha;	
		}
		
		public function get shininess():Number{
			return m_lightShader.shininess;
		}
		public function set shininess(_value:Number):void{
			m_lightShader.shininess = _value;
		}
		
		public function get opacity():Number{
			return m_envShader.alpha;
		}
		
		public function set opacity(_value:Number):void{
			m_ambShader.opacity = _value;
			m_envShader.alpha = _value;
			
			YOGURT3D_INTERNAL::m_transparent = (m_envShader.alpha < 1);
		}
	
	}
}