/*
* Shader.as
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

package com.yogurt3d.core.materials.shaders.base
{
	import com.yogurt3d.core.geoms.Mesh;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.managers.materialmanager.MaterialManager;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderParameters;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	use namespace YOGURT3D_INTERNAL;
	
	/**
	 * This class represents a shader pass. You can extend this class and create your own shaders. 
	 *
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class Shader
	{		
		use namespace YOGURT3D_INTERNAL;
		
		
		
		YOGURT3D_INTERNAL var m_params				: ShaderParameters;

		private var m_key:String								= "";
		
		private var m_registeredShaders:Dictionary	;
		
		YOGURT3D_INTERNAL var m_attributes:Vector.<EVertexAttribute>			= new Vector.<EVertexAttribute>();
		
		/**
		 * Constructor of the shader class. You must call this constructor using super() from your own class that extends Shader. 
		 * 
		 */		
		public function Shader()
		{
			m_params = new ShaderParameters();
			
			key = getQualifiedClassName( this );
			
			m_registeredShaders = new Dictionary();
		}		
		
		public function get attributes():Vector.<EVertexAttribute>
		{
			return m_attributes;
		}
		
		/**
		 * Key string of a shader. This key is used to cache Program3D objects, when the same shader is used several times.
		 * This key must be unique for every shader program you write. So this means if the AGAL changes you must change the key accordingly.
		 * @return 
		 * 
		 */		
		public function get key():String
		{
			return m_key;
		}
		
		/**
		 * @private 
		 * @param value
		 * 
		 */
		public function set key(value:String):void
		{
			m_key = value;
		}
		
		/**
		 * 
		 * @param _meshKey
		 * @return 
		 * 
		 */
		public function getVertexProgram( _meshKey:String, _lightType:ELightType = null ):ByteArray{
			throw new Error("getVertexProgram() must be overriden in shader!");
		}
		
		/**
		 * 
		 * @param _lightType
		 * @return 
		 * 
		 */
		public function getFragmentProgram( _lightType:ELightType = null ):ByteArray{
			throw new Error("getFragmentProgram() must be overriden in shader!");
		}
		
		
		/**
		 * Returns the Program3D object for this shader. \n
		 * This function uses it's parameters to determine to fetch the appropiate Program3D object.\n
		 * 
		 * @param _context3D
		 * @param _lightType
		 * @param _meshKey
		 * @return 
		 * 
		 */
		public function getProgram( _context3D:Context3D, _lightType:ELightType = null, _meshKey:String = "" ):Program3D{
			var _key:String = getKey(_lightType, _meshKey);
			
			if( m_registeredShaders[_key] != true )
			{
				MaterialManager.registerShader( getVertexProgram( _meshKey, _lightType ), getFragmentProgram(_lightType), _key );
				m_registeredShaders[ _key ] = true;
			}
			
			return MaterialManager.getProgram( _key, _context3D );
		}
		
		private final function getKey( _lightType:ELightType = null, _meshKey:String = null ):String{
			if( m_key == null )
			{
				m_key = Math.random().toString();
			}
			return _meshKey + "$" + m_key  + "@" + _lightType;
		}
		
		/**
		 * Returns the shader parameters. 
		 * @return 
		 * @see com.yogurt3d.core.materials.shaders.ShaderParameters
		 */
		public final function get params():ShaderParameters
		{
			return m_params;
		}
		
		/**
		 * @private 
		 */
		public final function set params(value:ShaderParameters):void
		{
			m_params = value;
		}
		
		public function dispose():void{
			disposeShaders();
		}
		public function disposeDeep():void{
			dispose();
		}
		
		/**
		 * 
		 * 
		 */
		public function disposeShaders():void{
			for( var key:String in m_registeredShaders )
			{
				MaterialManager.unregisterShader( m_registeredShaders[key] );
				m_registeredShaders[key] = false;
			}
		}
		
		
	}
}
