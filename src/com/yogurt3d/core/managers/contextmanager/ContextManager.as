/*
 * ContextManager.as
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
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.managers.contextmanager.interfaces.IContext;
	import com.yogurt3d.core.managers.contextmanager.interfaces.IContextManager;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	import com.yogurt3d.core.renderers.interfaces.IRenderer;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.utils.Dictionary;
	
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class ContextManager extends EngineObject implements IContextManager
	{
		private static const SCENE_PROPERTY		:String					= "scene";
		private static const CAMERA_PROPERTY	:String					= "camera";
		private static const RENDERER_PROPERTY	:String					= "renderer";
		private static const VIEWPORT_PROPERTY	:String					= "viewport";
		
		YOGURT3D_INTERNAL var m_viewports				:Vector.<Viewport>;
		YOGURT3D_INTERNAL var m_renderers				:Vector.<IRenderer>;
		YOGURT3D_INTERNAL var m_scenes					:Vector.<IScene>;
		YOGURT3D_INTERNAL var m_cameras					:Vector.<Camera>;
		YOGURT3D_INTERNAL var m_contexts				:Vector.<IContext>;
		YOGURT3D_INTERNAL var m_contextCount 			:int;
		YOGURT3D_INTERNAL var m_contextBySystemID		:Dictionary;
		YOGURT3D_INTERNAL var m_counter					:Dictionary;
		
		use namespace YOGURT3D_INTERNAL;
		
		/**
		 * 
		 * @param _initInternals
		 * 
		 */
		public function ContextManager(_initInternals:Boolean = true)
		{
			super(_initInternals);
		}
		
		/**
		 * @inheritDoc 
		 */
		public function get viewports():Vector.<Viewport>
		{
			return m_viewports;
		}
		
		/**
		 * @inheritDoc 
		 */
		public function get renderers():Vector.<IRenderer>
		{
			return m_renderers;
		}
		
		/**
		 * @inheritDoc 
		 */
		public function get scenes():Vector.<IScene>
		{
			return m_scenes;
		}
		
		/**
		 * @inheritDoc 
		 */
		public function get cameras():Vector.<Camera>
		{
			return m_cameras;
		}
		/**
		 * @inheritDoc 
		 */
		public function get contexts():Vector.<IContext>
		{
			return m_contexts;
		}
		/**
		 * @inheritDoc 
		 */
		public function get contextCount():int
		{
			return m_contextCount;
		}
		/**
		 * @inheritDoc 
		 */
		public function addContext(_value:IContext):void
		{
			if(_value.camera.scene != _value.scene)
			{
				throw new Error("Context Error, Camera must be a child of given Scene object");
			}
			
			if(m_contexts.indexOf(_value) == -1)
			{
				m_contexts[m_contexts.length]			= _value;
				m_contextBySystemID[_value.systemID]	= _value;
				m_contextCount++;
				
				if(m_viewports.indexOf(_value.viewport) == -1)
				{
					m_viewports[m_viewports.length]		= _value.viewport;
					m_counter[_value.viewport]			= 1;
				} else {
					m_counter[_value.viewport]++;
				}
				
				if(m_renderers.indexOf(_value.renderer) == -1)
				{
					m_renderers[m_renderers.length]		= _value.renderer;
					m_counter[_value.renderer]			= 1;
				} else {
					m_counter[_value.renderer]++;
				}
				
				if(m_scenes.indexOf(_value.scene) == -1)
				{
					m_scenes[m_scenes.length]			= _value.scene;
					m_counter[_value.scene]				= 1;
				} else {
					m_counter[_value.scene]++;
				}
				
				if(m_cameras.indexOf(_value.camera) == -1)
				{
					m_cameras[m_cameras.length]			= _value.camera;
					m_counter[_value.camera]			= 1;
				} else {
					m_counter[_value.camera]++;
				}
			}
		}
		
		/**
		 * @inheritDoc 
		 */
		public function addNewContext(_scene:IScene, _camera:Camera, _viewport:Viewport, _renderer:IRenderer):String
		{
			if(_camera.scene == _scene)
			{
				var _context:Context	= new Context();
				
				_context.scene			= _scene;
				_context.camera			= _camera;
				//_context.viewport		= _viewport;
				_context.renderer		= _renderer;
				
				this.addContext(_context);
				
				return _context.systemID;
				
			} else {
				throw new Error("Context Error, Camera must be a child of given Scene object");
			}
			
			return null;
		}
		/**
		 * @inheritDoc 
		 */
		public function removeContext(_value:IContext):void
		{
			var _contextIndex	:int = m_contexts.indexOf(_value);
			
			if(_contextIndex != -1)
			{
				m_contexts.splice(_contextIndex, 1);
				m_contextCount--;
				
				//m_counter[_value.viewport]--;
				m_counter[_value.renderer]--;
				m_counter[_value.scene]--;
				m_counter[_value.camera]--;
				
				_value.viewport.visible = false;
				
				if(m_counter[_value.viewport] == 0)
				{
					m_viewports.splice(m_viewports.indexOf(_value.viewport), 1);
				}
				
				if(m_counter[_value.renderer] == 0)
				{
					m_renderers.splice(m_renderers.indexOf(_value.renderer), 1);
				}
				
				if(m_counter[_value.scene] == 0)
				{
					m_scenes.splice(m_scenes.indexOf(_value.scene), 1);
				}
				
				if(m_counter[_value.camera] == 0)
				{
					m_cameras.splice(m_cameras.indexOf(_value.camera), 1);
				}
			}
		}
		/**
		 * @inheritDoc 
		 */
		public function removeContextBySystemID(_value:String):void
		{
			var _context	:IContext	= m_contextBySystemID[_value];
			
			if(_context)
			{
				removeContext(_context);
			}
		}
		/**
		 * @inheritDoc 
		 */
		public function removeContextByUserID(_value:String):void
		{
			var _systemID :String = IDManager.getSystemIDByUserID(_value);
			
			if(_systemID)
			{
				var _context :IContext = m_contextBySystemID[_systemID];
				
				if(_context)
				{
					removeContext(_context);
				}
			}
		}
		/**
		 * @inheritDoc 
		 */
		public function getContextBySystemID(_value:String):IContext
		{
			return m_contextBySystemID[_value];
		}
		/**
		 * @inheritDoc 
		 */
		public function getContextByUserID(_value:String):IContext
		{
			var _systemID	:String			= IDManager.getSystemIDByUserID(_value);
			
			if(_systemID)
			{
				return m_contextBySystemID[_systemID];
			}
			
			return null;
		}
		/**
		 * @inheritDoc 
		 */
		public function removeAllRelatedTo(_value:IEngineObject):void
		{
			if(_value is Camera)
			{
				removeContextsByProperty(ContextManager.CAMERA_PROPERTY, _value);
			}
			
			if(_value is IScene)
			{
				removeContextsByProperty(ContextManager.SCENE_PROPERTY, _value);
			}
			
			if(_value is IRenderer)
			{
				removeContextsByProperty(ContextManager.RENDERER_PROPERTY, _value);
			}
			
			if(_value is Viewport)
			{
				removeContextsByProperty(ContextManager.VIEWPORT_PROPERTY, _value);
			}
		}
		/**
		 * @inheritDoc 
		 */
		public function removeAllRelatedToRenderer(_value:IRenderer):void
		{
			removeContextsByProperty(ContextManager.RENDERER_PROPERTY, _value);
		}
		/**
		 * @inheritDoc 
		 */
		public function removeAllRelatedToViewport(_value:Viewport):void
		{
			removeContextsByProperty(ContextManager.VIEWPORT_PROPERTY, _value);
		}
		/**
		 * @inheritDoc 
		 */
		public function removeAllRelatedToScene(_value:IScene):void
		{
			removeContextsByProperty(ContextManager.SCENE_PROPERTY, _value);
		}
		/**
		 * @inheritDoc 
		 */
		public function removeAllRelatedToCamera(_value:Camera):void
		{
			removeContextsByProperty(ContextManager.CAMERA_PROPERTY, _value);
		}
		/**
		 * @inheritDoc 
		 */
		override protected function trackObject():void
		{
			IDManager.trackObject(this, ContextManager);
		}
		/**
		 * @inheritDoc 
		 */
		override protected function initInternals():void
		{
			super.initInternals();
			
			m_viewports				= new Vector.<Viewport>();
			m_renderers				= new Vector.<IRenderer>();
			m_scenes				= new Vector.<IScene>();
			m_cameras				= new Vector.<Camera>();
			m_contexts				= new Vector.<IContext>();
			m_contextCount			= 0;
			m_contextBySystemID		= new Dictionary();
			m_counter				= new Dictionary();
		}
		/**
		 * @inheritDoc 
		 */
		private function removeContextsByProperty(_property:String, _value:IEngineObject):void
		{
			for(var i:int = 0; i < m_contextCount; i++)
			{
				if(m_contexts[i][_property] == _value)
				{
					removeContext(m_contexts[i]);
				}
			}
		}
	}
}
