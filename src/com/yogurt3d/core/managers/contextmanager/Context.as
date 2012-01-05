/*
 * Context.as
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
 
 
package com.yogurt3d.core.managers.contextmanager
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.managers.contextmanager.interfaces.IContext;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.renderers.interfaces.IRenderer;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.viewports.Viewport;
	
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class Context extends EngineObject implements IContext
	{
		YOGURT3D_INTERNAL var m_scene			:IScene;
		YOGURT3D_INTERNAL var m_viewport		:Viewport;
		YOGURT3D_INTERNAL var m_camera			:Camera;
		YOGURT3D_INTERNAL var m_renderer		:IRenderer;
		YOGURT3D_INTERNAL var m_isActive		:Boolean;
		
		use namespace YOGURT3D_INTERNAL;
		
		public function Context(_initInternals:Boolean = true)
		{
			super(_initInternals);
		}
		
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */
		public function get scene():IScene
		{
			return m_scene;
		}
		
		/**
		 * @private 
		 * @param _value
		 * 
		 */
		public function set scene(_value:IScene):void
		{
			m_scene = _value;
		}
		
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */
		public function get camera():Camera
		{
			return m_camera;
		}
		
		/**
		 * @private 
		 * @param _value
		 * 
		 */
		public function set camera(_value:Camera):void
		{
			m_camera = _value;
		}
		
		
		public function get viewport():Viewport
		{
			return m_viewport;
		}
		
		public function set viewport(_value:Viewport):void
		{
			m_viewport = _value;
		}
		
		
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */
		public function get renderer():IRenderer
		{
			return m_renderer;
		}
		
		/**
		 * @private 
		 * @param _value
		 * 
		 */
		public function set renderer(_value:IRenderer):void
		{
			m_renderer = _value;
		}
		
		
		
		/**
		 * @inheritDoc
		 * @return 
		 * 
		 */
		public function get isActive():Boolean{
			return m_isActive;
		}
		/**
		 * @private 
		 * @param _value
		 * 
		 */
		public function set isActive(_value:Boolean):void{
			m_isActive = _value;
		}
		
		/**
		 * @inheritDoc 
		 * 
		 */
		public function update():void
		{
			if( m_isActive && m_viewport.context3d )
			{
				m_scene.preRender( m_camera );
				m_renderer.render( m_scene, m_camera, m_viewport );
			    m_viewport.update( m_scene, m_camera );
				m_scene.postRender();
			}
		}
		
		/**
		 * @inheritDoc 
		 * 
		 */
		protected override function initInternals():void{
			m_isActive = true;
		}
		
		/**
		 * @inheritDoc 
		 * 
		 */
		override protected function trackObject():void
		{
			IDManager.trackObject(this, Context);
		}

	}
}
