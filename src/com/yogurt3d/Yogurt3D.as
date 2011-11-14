/*
 * Yogurt3D.as
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

package com.yogurt3d {
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.cameras.interfaces.ICamera;
	import com.yogurt3d.core.enums.EngineDefaults;
	import com.yogurt3d.core.events.Yogurt3DEvent;
	import com.yogurt3d.core.managers.contextmanager.Context;
	import com.yogurt3d.core.managers.contextmanager.ContextManager;
	import com.yogurt3d.core.managers.contextmanager.interfaces.IContext;
	import com.yogurt3d.core.managers.contextmanager.interfaces.IContextManager;
	import com.yogurt3d.core.managers.scenetreemanager.SceneTreeManager;
	import com.yogurt3d.core.managers.tickmanager.TickManager;
	import com.yogurt3d.core.plugin.Kernel;
	import com.yogurt3d.core.plugin.Server;
	import com.yogurt3d.core.renderers.interfaces.IRenderer;
	import com.yogurt3d.core.sceneobjects.Scene;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.scenetree.SceneTreePlugins;
	import com.yogurt3d.core.viewports.Viewport;
	import com.yogurt3d.presets.renderers.molehill.MolehillRenderer;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	[Event(name="ready", type="com.yogurt3d.core.events.Yogurt3DEvent")]
	/**
	 * This class is the main container of the Yogurt3D engine.
	 * 
	 * <p> it it implemented as a singleton object, so you cannot create it simply refer it as
	 * <code>Yogurt3D.instance</code></p>
	 * 
	 * <p>You can create a new context using this class. But for basic scene initialization we 
	 * included a <code>defaultSetup</code> ethod which creates a new context and initializez it for you.</p>
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 * 
	 * @example The following code is a basic initialization of Yogurt3D Engine
	 * 
	 * <listing version="3.0"> 
	 * package
{
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.events.Yogurt3DEvent;
	
	
	[SWF(width="800", height="600", frameRate="24")]
	public class BasicInitialization extends Sprite
	{
		public function YOA()
		{
			Yogurt3D.instance.addEventListener(Yogurt3DEvent.READY, onReady);
			Yogurt3D.instance.init( this.stage );
			
		}
		public function onReady( _e:Yogurt3DEvent ):void{
			Yogurt3D.instance.defaultSetup( 800, 600 );

 			Yogurt3D.instance.defaultScene.sceneColor = 0xFF0000;

			Yogurt3D.instance.startAutoUpdate();
			
		}
	}
}
	 * </listing>
	 **/
	public class Yogurt3D extends EventDispatcher
	{
		public static var DEBUG_TEXT			:String 			= "";
		private static const THOUSAND_MS		:int				= 1000;
		
		
		private var m_fps						:int;
		private var m_contextManager			:IContextManager;
		private var m_defaultContext			:Context;
		private var m_updateTimer				:Timer;
		
		public var enginePreUpdateCallback		:Function;
		public var enginePostUpdateCallback		:Function;
		
		public static var CONTEXT3D						:Dictionary;
		
		private static var m_instance:Yogurt3D;
		/**
		 *
		 **/
		public function Yogurt3D(_enforcer:SingletonEnforcer) 
		{
			m_fps					= EngineDefaults.DEFAULT_FRAMERATE;
			m_contextManager		= new ContextManager();
			m_updateTimer			= new Timer(THOUSAND_MS / m_fps);
			
			CONTEXT3D = new Dictionary;
			
			initPlugins();			
			
			m_updateTimer.addEventListener(TimerEvent.TIMER, handleUpdateTimer);
		}
		
		private function initPlugins():void{
			var kernel:Kernel = Kernel.instance;
			
			kernel.addServer( new Server(SceneTreeManager.SERVERNAME, SceneTreeManager.SERVERVERSION) );
			
			kernel.loadPluginFromClass( SceneTreePlugins );
		}
		
		/**
		 * Not used anymore
		 * Creates and readies GPU Hardware.
		 * @param event
		 * 
		 */	
		public function init(/*_stage:Stage*/):void {						
			dispatchEvent( new Yogurt3DEvent( Yogurt3DEvent.READY ) );
		}
		
		public static function get instance():Yogurt3D {			
			if (!m_instance) m_instance = new Yogurt3D( new SingletonEnforcer() );			
			return m_instance;			
		}
		/**
		 * Update is the main rendering loop. When called it renders all the active contexts registered to the ContextManager.<br/>
		 * The loop consists of: <br/>
		 * <ul>
		 * 	<li>enginePreUpdateCallback</li>
		 * 	<li>TickManager.update()</li>
		 * 	<li>context.update</li>
		 * 	<li>enginePostUpdateCallback</li>
		 * </ul>
		 * in the specified order.
		 **/
		public function defaultSetup(_viewportWidth:int=800, _viewportHeight:int=600, x:Number = 0, y:Number = 0):void 
		{
			var _scene:IScene 			= new Scene();
			var _camera:ICamera 		= new Camera();
			var _renderer:IRenderer 	= new MolehillRenderer();	
			var _viewport:Viewport		= new Viewport();
			_scene.addChild(_camera);
			
			m_defaultContext 			= new Context();
			m_defaultContext.renderer 	= _renderer;
			m_defaultContext.scene		= _scene;
			m_defaultContext.camera 	= _camera;
			m_defaultContext.viewport	= _viewport;			
			
			_viewport.setViewport( x,y, _viewportWidth, _viewportHeight );
			
			m_contextManager.addContext( m_defaultContext );
		}
	
		public function update():void
		{
			//var start:uint = getTimer();
			if( enginePreUpdateCallback != null ) enginePreUpdateCallback();
			
			TickManager.update();
			
			var _contextLength	:int = m_contextManager.contexts.length;
			
			for(var i:int = 0; i < _contextLength; i++)
			{
				var context		:IContext	= m_contextManager.contexts[i];
				
				context.update();
			}
			
			if( enginePostUpdateCallback != null ) enginePostUpdateCallback();
			//trace("[YOGURT3D][update]", getTimer() - start);
		}
		/**
		 * Enables the timer object that calls the update function on every frame.
		 */
		public function startAutoUpdate():void
		{
			m_updateTimer.start();
		}
		/**
		 * Disables the timer object that calls the update function on every frame.
		 */
		public function stopAutoUpdate():void
		{
			m_updateTimer.stop();
		}
		/**
		 * Returns the default context which the defaultSetup method creates.
		 */
		public function get defaultContext():Context
		{
			return m_defaultContext;
		}
		/**
		 * Returns the default scene which the defaultSetup method creates.
		 */
		public function get defaultScene():IScene
		{
			return m_defaultContext.scene;
		}
		/**
		 * Returns the default camera which the defaultSetup method creates.
		 */
		public function get defaultCamera():ICamera
		{
			return m_defaultContext.camera;
		}
		/**
		 * Returns the default viewport which the defaultSetup method creates.
		 */
		public function get defaultViewport():Viewport
		{
			return m_defaultContext.viewport;
		}
		/**
		 * Returns the default renderer which the defaultSetup method creates.
		 */
		public function get defaultRenderer():IRenderer
		{
			return m_defaultContext.renderer;
		}
		/**
		 * Returns the context manager. This class can be used to register new contexts to the system.
		 */
		public function get contextManager():IContextManager
		{
			return m_contextManager;
		}
		/**
		 * The rendering speed of the system. Yogurt3D will use this frame per second speed to update it's rendering 
		 * differing from the player fps. This value cannot exceed the layer fps even if set to greater values.
		 * @default 60
		 */
		public function get fps():int
		{
			return m_fps;
		}
		/**
		 * @private
		 **/
		public function set fps(_value:int):void
		{
			m_fps					= _value;
			
			m_updateTimer.delay		= THOUSAND_MS / m_fps;
		}
		
		private function staticInitializer():Boolean
		{
			m_fps					= EngineDefaults.DEFAULT_FRAMERATE;
			m_contextManager		= new ContextManager();
			m_updateTimer			= new Timer(THOUSAND_MS / m_fps);
			
			m_updateTimer.addEventListener(TimerEvent.TIMER, handleUpdateTimer);
			
			return true;
		}
		
		private function handleUpdateTimer(event:TimerEvent):void
		{
			update();
		}
		
			
	}
}

internal class SingletonEnforcer {}
