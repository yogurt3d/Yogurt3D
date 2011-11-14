/*
 * Scene.as
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
 
package com.yogurt3d.core.sceneobjects
{
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.cameras.interfaces.ICamera;
	import com.yogurt3d.core.effects.Effect;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.managers.scenetreemanager.SceneTreeManager;
	import com.yogurt3d.core.materials.base.Color;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObject;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	
	/**
	 * <strong>IScene</strong> interface abstract type.
  	 * @author Yogurt3D Engine Core Team
  	 * @company Yogurt3D Corp.
  	 **/
	public class Scene extends EngineObject implements IScene
	{
		public static const SIMPLE_SCENE:String = "SimpleSceneTreeManagerDriver";
		public static const QUAD_SCENE:String = "QuadSceneTreeManagerDriver";
		public static const OCTREE_SCENE:String = "OcTreeSceneTreeManagerDriver";
		
		YOGURT3D_INTERNAL var m_rootObject		:ISceneObject;
		YOGURT3D_INTERNAL var m_args			:Object;
		
		YOGURT3D_INTERNAL var m_driver:String;
		
		YOGURT3D_INTERNAL var m_postEffects:Vector.<Effect>;
		
		private var m_sceneColor:Color;
		
		private var m_skyBox:SkyBox;
		
		use namespace YOGURT3D_INTERNAL;
		
		public function Scene(_sceneTreeManagerDriver:String = "QuadSceneTreeManagerDriver", args:Object = null, _initInternals:Boolean = true)
		{
			Yogurt3D.instance;
			
			m_driver = _sceneTreeManagerDriver;
			m_args = args;
			super(_initInternals);
		}
		
		public function get postEffects():Vector.<Effect>
		{
			return YOGURT3D_INTERNAL::m_postEffects;
		}


		/**
		 * @inheritDoc
		 * */
		public function get objectSet():Vector.<ISceneObject>
		{
			return SceneTreeManager.getSceneObjectSet(this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function getRenderableSet(_camera:ICamera):Vector.<ISceneObjectRenderable>
		{
			return SceneTreeManager.getSceneRenderableSet(this,_camera);
		}
		
		public function prepareSceneForNewFrame():void
		{
			SceneTreeManager.clearSceneFrameData( this );
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get cameraSet():Vector.<ICamera>
		{
			return SceneTreeManager.getSceneCameraSet(this);
		}
		
		public function get lightSet():Vector.<Light>
		{
			return SceneTreeManager.getSceneLightSet(this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get children():Vector.<ISceneObject>
		{
			return SceneTreeManager.getChildren(m_rootObject);
		}
		
		public function get triangleCount():int
		{
			var _renderableSet		:Vector.<ISceneObjectRenderable>	= SceneTreeManager.getSceneRenderableSet(this, null);
			var _renderableCount	:int								= _renderableSet.length;
			var _triangleCount		:int								= 0;
			
			for( var i:int = 0; i < _renderableCount; i++ )
				_triangleCount		+= _renderableSet[i].geometry.triangleCount;
			
			return _triangleCount;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function addChild(_value:ISceneObject):void {
			if (_value == null) {
				throw new Error("Child can not be null");
				return;
			}
			SceneTreeManager.addChild(_value, m_rootObject);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeChild(_value:ISceneObject):void
		{
			SceneTreeManager.removeChild(_value, m_rootObject);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeChildBySystemID(_value:String):void
		{
			SceneTreeManager.removeChildBySystemID(_value, m_rootObject);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeChildByUserID(_value:String):void
		{
			SceneTreeManager.removeChildByUserID(_value, m_rootObject);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function getChildBySystemID(_value:String):ISceneObject
		{
			return SceneTreeManager.getChildBySystemID(_value, m_rootObject);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function getChildByUserID(_value:String):ISceneObject
		{
			return SceneTreeManager.getChildByUserID(_value, m_rootObject);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function containsChild(_child:ISceneObject, _recursive:Boolean = false):Boolean
		{
			return SceneTreeManager.contains(_child, m_rootObject, _recursive); 
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, Scene);
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			
			m_rootObject 		= new SceneObjectContainer();
			
			m_sceneColor = new Color(1,1,1,1);
			
			m_postEffects = new Vector.<Effect>();
			
			SceneTreeManager.setSceneRootObject(ISceneObject(m_rootObject), this);
		}
		
		public function get sceneColor():Color
		{
			return m_sceneColor;
		}
		
		public function set sceneColor(value:Color):void
		{
			m_sceneColor = value;
		}
		
		public function get skyBox():SkyBox
		{
			return m_skyBox;
		}
		public function set skyBox(_value:SkyBox):void
		{
			if( m_skyBox != null )
			{
				//remove from scene
				removeChild( m_skyBox );
			}
			m_skyBox = _value;
			SceneTreeManager.addChild( m_skyBox, m_rootObject );
		}
		
		public function addPostEffect( _effect:Effect ):void{
			m_postEffects.push( _effect );
		}
		
		public function removePostEffect( _effect:Effect ):void{
			var index:uint;
			if( (index = m_postEffects.indexOf( _effect ) ) != -1 )
			{
				m_postEffects.splice(index,1);
			}
		}
		
	}
}
