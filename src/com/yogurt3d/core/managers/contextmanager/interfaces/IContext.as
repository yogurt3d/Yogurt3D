/*
 * IContext.as
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
	public interface IContext extends IEngineObject
	{
		/**
		 * Scene assigned to this context object.
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.IScene
		 * @default com.yogurt3d.core.sceneobjects.Scene
		 */
		function get scene():IScene;
		/**
		 * @private
		 */
		function set scene(_value:IScene):void;
		
		/**
		 * Camera assigned to this context
		 * @return 
		 * @see com.yogurt3d.core.cameras.interfaces.Camera
		 */
		function get camera():Camera;
		/**
		 * @private
		 */
		function set camera(_value:Camera):void;
		
		function get viewport():Viewport;
		function set viewport(_value:Viewport):void;
		
		/**
		 * Renderer assigned to this context 
		 * @return 
		 * @see com.yogurt3d.core.renderers.interfaces.IRenderer
		 * @default com.yogurt3d.presets.renderers.molehill.MoleHillRenderer
		 */
		function get renderer():IRenderer;
		/**
		 * @private
		 */
		function set renderer(_value:IRenderer):void;
		
		/**
		 * Flag indicatin whether the context is active or not
		 * @return 
		 * @default true
		 */
		function get isActive():Boolean;
		/**
		 * @private
		 */
		function set isActive(_value:Boolean):void;
		
		/**
		 * Updates the Context by calling its renderer
		 * 
		 */
		function update():void;
	}
}
