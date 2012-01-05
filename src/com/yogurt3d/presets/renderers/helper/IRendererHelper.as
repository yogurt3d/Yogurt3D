/*
 * IRendererHelper.as
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
 
 
package com.yogurt3d.presets.renderers.helper
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderParameters;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	
	import flash.display3D.Context3D;

/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public interface IRendererHelper
	{
		/**
		 * Cleans the cached data.<br/>This function must be called on every frame. 
		 * 
		 */
		function endScene():void;
		
		function beginScene(_camera:Camera=null):void;
		
		
		/**
		 * Cleans the texture streams currently used. 
		 * @param _context3D
		 * 
		 */
		function clearTextures( _context3D:Context3D ):void;
		/**
		 * Uploads the shader constants; both the vertex and fragment.
		 *  
		 * @param _context3d Context3D object to upload to.
		 * @param _params ShaderParameters
		 * @param _light The current light on the pass
		 * @param _camera Camera object
		 * @param _object Renderable object
		 * @param _subMesh Currently parsed SubMesh of the renderable object's geometry
		 * 
		 */
		function setProgramConstants(_context3d:Context3D, _params:ShaderParameters, _light:Light=null, _camera:Camera=null, _object:SceneObjectRenderable=null, _subMesh:SubMesh = null):Boolean
	}
}
