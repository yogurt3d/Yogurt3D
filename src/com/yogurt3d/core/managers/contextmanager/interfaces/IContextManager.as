/*
 * IContextManager.as
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
 
 
package com.yogurt3d.core.managers.contextmanager.interfaces
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	import com.yogurt3d.core.renderers.interfaces.IRenderer;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.viewports.Viewport;
	
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public interface IContextManager extends IEngineObject
	{
		/**
		 * Returns the registered viewports
		 * @return 
		 * 
		 */
		function get viewports():Vector.<Viewport>;
		/**
		 * Returns the registered renderers
		 * @return 
		 * 
		 */
		function get renderers():Vector.<IRenderer>;
		/**
		 * Returns the registered scenes
		 * @return 
		 * 
		 */
		function get scenes():Vector.<IScene>;
		/**
		 * Returns the registered cameras
		 * @return 
		 * 
		 */
		function get cameras():Vector.<Camera>;
		/**
		 * Returns the registered contexts
		 * @return 
		 * 
		 */
		function get contexts():Vector.<IContext>;
		/**
		 * Returns the registered context count
		 * @return 
		 * 
		 */
		function get contextCount():int;
		
		/**
		 * Registers a <code>IContext</code> object.
		 * @param _value The <code>IContext</code> object to be registered.
		 * 
		 * @see com.yogurt3d.core.managers.contextmanager.interfaces.IContext
		 */
		function addContext(_value:IContext):void;
		/**
		 * Creates and registeres a new <code>Context</code> object.
		 * @param _scene
		 * @param _camera
		 * @param _viewport
		 * @param _renderer
		 * @return 
		 * 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.IScene
		 * @see com.yogurt3d.core.cameras.interfaces.Camera
		 * @see com.yogurt3d.core.renderers.interfaces.IRenderer
		 */
		function addNewContext(_scene:IScene, _camera:Camera, _viewport:Viewport, _renderer:IRenderer):String;
		
		/**
		 * Unregisters a <code>Context</code> 
		 * @param _value <code>Context</code> object that is going to be unregistered
		 * 
		 */
		function removeContext(_value:IContext):void;
		/**
		 * Unregisters a <code>Context</code> object by it's system id
		 * @param _value
		 * 
		 */
		function removeContextBySystemID(_value:String):void;
		/**
		 * Unregisters a <code>Context</code> object by it's user id
		 * @param _value
		 * 
		 */
		function removeContextByUserID(_value:String):void;
		
		/**
		 * Fetches a registered <code>Context</code> object using it's system id
		 * @param _value
		 * @return 
		 * 
		 */
		function getContextBySystemID(_value:String):IContext;
		/**
		 * Fetches a registered <code>Context</code> object using it's user id
		 * @param _value User id
		 * @return 
		 * 
		 */
		function getContextByUserID(_value:String):IContext;
		
		/**
		 * Unregisters the <code>Context</code> object allocated to the <code>IEngineObject</code> 
		 * @param _value
		 * @see com.yogurt3d.core.objects.interfaces.IEngineObject
		 */
		function removeAllRelatedTo(_value:IEngineObject):void;
		/**
		 * Unregisters the <code>Context</code> object allocated to the <code>IRenderer</code> 
		 * @param _value
		 * @see com.yogurt3d.core.renderers.interfaces.IRenderer
		 */
		function removeAllRelatedToRenderer(_value:IRenderer):void;
		/**
		 * Unregisters the <code>Context</code> object allocated to the <code>Viewport</code> 
		 * @param _value
		 * @see com.yogurt3d.core.viewports.Viewport
		 */
		function removeAllRelatedToViewport(_value:Viewport):void;
		/**
		 * Unregisters the <code>Context</code> object allocated to the <code>IScene</code> 
		 * @param _value
		 * @see com.yogurt3d.core.sceneobjects.interfaces.IScene
		 */
		function removeAllRelatedToScene(_value:IScene):void;
		/**
		 * Unregisters the <code>Context</code> object allocated to the <code>Camera</code> 
		 * @param _value
		 * @see com.yogurt3d.core.cameras.interfaces.Camera
		 */
		function removeAllRelatedToCamera(_value:Camera):void;
	}
}
