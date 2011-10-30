/*
 * SceneTreeManager.as
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

package com.yogurt3d.core.managers.scenetreemanager
{
	import com.yogurt3d.core.cameras.interfaces.ICamera;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.plugin.Driver;
	import com.yogurt3d.core.plugin.Kernel;
	import com.yogurt3d.core.plugin.Server;
	import com.yogurt3d.core.sceneobjects.Scene;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObject;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	import com.yogurt3d.core.scenetree.IRenderableManager;
	import com.yogurt3d.core.scenetree.SceneTreeManagerDriver;
	
	import flash.utils.Dictionary;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class SceneTreeManager
	{
		public static const SERVERNAME:String = "sceneTreeManagerServer";
		public static const SERVERVERSION:uint = 1;
		
		private static var s_init							:Boolean		= staticInitializer();
		private static var s_childrenByContainer			:Dictionary;
		private static var s_childBySystemIDByContainer		:Dictionary;
		private static var s_childCountByContainer			:Dictionary;
		private static var s_parentBySceneObjects			:Dictionary;
		private static var s_sceneBySceneObjects			:Dictionary;
		private static var s_sceneObjectsByScene			:Dictionary;
		//private static var s_renderableObjectsByScene		:Dictionary;
		private static var s_lightsByScene					:Dictionary;
		private static var s_cameraObjectsByScene			:Dictionary;
		private static var s_sceneTreeManagerByScene		:Dictionary;
		
		public static function setSceneRootObject(_rootObject:ISceneObject, _scene:IScene):void
		{
			s_sceneBySceneObjects[_rootObject]	= _scene;
			
			if(!s_sceneObjectsByScene[_scene])
			{
				s_sceneObjectsByScene[_scene]	= new Vector.<ISceneObject>;
				
				var kernel:Kernel = Kernel.instance;
				var server:Server = kernel.getServer( SERVERNAME );
				var drivers:Vector.<Driver> = server.getDriverByName( _scene.YOGURT3D_INTERNAL::m_driver );
				if( !s_sceneTreeManagerByScene )
				{
					s_sceneTreeManagerByScene = new Dictionary();
				}
				s_sceneTreeManagerByScene[ _scene ] = ( drivers.length > 0 )?SceneTreeManagerDriver(drivers[0]).createTreeManager():null;
			}
		}
		
		public static function getParent(_sceneObject:ISceneObject):ISceneObject
		{
			return s_parentBySceneObjects[_sceneObject];
		}
		
		public static function getRoot(_sceneObject:ISceneObject):ISceneObject
		{
			var _currentParent	:ISceneObject	= s_parentBySceneObjects[_sceneObject];
			
			if(_currentParent)
			{
				while(s_parentBySceneObjects[_currentParent])
				{
					_currentParent = s_parentBySceneObjects[_currentParent];
				}
				
				return _currentParent;
			}
			
			return null;
		}
		
		public static function getScene(_sceneObject:ISceneObject):Scene
		{
			if(_sceneObject.root)
			{
				return s_sceneBySceneObjects[_sceneObject.root];
			} else {
				return s_sceneBySceneObjects[_sceneObject];
			}
			
			return null;
		}
		
		public static function getSceneObjectSet(_scene:IScene):Vector.<ISceneObject>
		{
			return s_sceneObjectsByScene[_scene];
		}
		
		public static function getSceneRenderableSet(_scene:IScene):Vector.<ISceneObjectRenderable>
		{
			if( s_sceneTreeManagerByScene[ _scene ] )
			{
				return IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).getSceneRenderableSet( _scene );
			}
			return null; // s_renderableObjectsByScene[_scene];
		}
		
		public static function getSceneLightSet(_scene:IScene):Vector.<Light>
		{
			return s_lightsByScene[_scene];
		}
		
		public static function getSceneCameraSet(_scene:IScene):Vector.<ICamera>
		{
			return s_cameraObjectsByScene[_scene];
		}
		
		public static function getChildren(_container:ISceneObject):Vector.<ISceneObject>
		{
			return s_childrenByContainer[_container];
		}
		
		public static function getChildrenCount(_container:ISceneObject):int
		{
			return s_childCountByContainer[_container];
		}
		
		public static function getChildBySystemID(_systemID:String, _container:ISceneObject):ISceneObject
		{
			if(!s_childBySystemIDByContainer[_container])
			{
				return null;
			}
			
			return s_childBySystemIDByContainer[_container][_systemID];
		}
		
		public static function getChildByUserID(_userID:String, _container:ISceneObject):ISceneObject
		{
			if(!s_childBySystemIDByContainer[_container])
			{
				return null;
			}
			
			return s_childBySystemIDByContainer[_container][IDManager.getSystemIDByUserID(_userID)];
		}
		
		public static function addChild(_child:ISceneObject, _container:ISceneObject, index:int = -1):void
		{
			if(	!s_childrenByContainer		 [_container] ||
				!s_childBySystemIDByContainer[_container] ||
				!s_childCountByContainer	 [_container]
			  )
			{
				initContainerDictionaries(_container);
			}
			
			// containers children list
			var _children				:Vector.<ISceneObject>	= s_childrenByContainer		  [_container];
			var _systemIDDictionary		:Dictionary				= s_childBySystemIDByContainer[_container];
			
			// if the container does not contain this scene object
			if(s_parentBySceneObjects[_child] != _container)
			{
				// ADD Object Into Container related lists
				
				// if the child belongs to another container, remove it from that one.
				if(s_parentBySceneObjects[_child])
				{
					removeChild(_child, s_parentBySceneObjects[_child]);
				}
				
				// add child to containers children list
				_children[_children.length]				= _child;
				// add child to systemId dictionaru
				_systemIDDictionary[_child.systemID]	= _child;
				// update containers child count
				s_childCountByContainer[_container]		= _children.length;
				// map the child to the container
				s_parentBySceneObjects[_child]			= _container;
				
				// Add object Into Scene Related Sets
				
				var _containerAsSceneObject	:ISceneObject	= ISceneObject(_container);
				var _rootObject				:ISceneObject	= _containerAsSceneObject.root;
				var _scene					:IScene;
				
				if(!_rootObject)
				{
					_rootObject = _containerAsSceneObject;
				}
				
				_scene = s_sceneBySceneObjects[_rootObject];
				
				if(_scene)
				{
					if(_child is ISceneObjectRenderable)
					{
						addRenderableChildIntoSceneSet(ISceneObjectRenderable(_child), _scene, index);
					}
					
					if(_child is ICamera)
					{
						addCameraChildIntoSceneSet(ICamera(_child), _scene);
					}
					
					if(_child is Light) {
						addLightIntoSceneSet(Light(_child), _scene);
					}
					
					//if(_child is ISceneObjectContainer)
					//{
						addContainerChildsIntoSceneSets(ISceneObject(_child), _scene, index);
					//} else {
						//addChildIntoSceneSet(_child, _scene);
					//}
					_child.addedToScene( _scene );
				}
			}
		}
		
		
		
		
		public static function removeChild(_child:ISceneObject, _container:ISceneObject):void
		{
			var _children	:Vector.<ISceneObject>	= s_childrenByContainer[_container];
			
			if(_children)
			{
				var _childIndex	:int = _children.indexOf(_child);
				
				if(_childIndex != -1)
				{
					_children.splice(_childIndex, 1);
					delete s_childBySystemIDByContainer[_container][_child.systemID];
					s_childCountByContainer[_container]							= _children.length;
					delete s_parentBySceneObjects[_child];
					
					// Remove Object from Scene Sets
					
					var _containerAsSceneObject	:ISceneObject	= ISceneObject(_container);
					var _rootObject				:ISceneObject	= _containerAsSceneObject.root;
					var _scene					:IScene;
					
					if(!_rootObject)
					{
						_rootObject = _containerAsSceneObject;
					}
					
					_scene = s_sceneBySceneObjects[_rootObject];
					
					if(_scene)
					{
						_removeChild( _child, _scene );
						
						if(_children.length == 0)
						{
							clearContainerDictionaries(_container);
						}
					}
				}
			}
		}
		
		
		public static function removeChildBySystemID(_systemID:String, _container:ISceneObject):void
		{
			var _sceneObject:ISceneObject	= getChildBySystemID(_systemID, _container); 
			
			if(_sceneObject)
			{
				removeChild(_sceneObject, _container);
			}
		}
		
		public static function removeChildByUserID(_userID:String, _container:ISceneObject):void
		{
			var _sceneObject:ISceneObject	= getChildByUserID(_userID, _container); 
			
			if(_sceneObject)
			{
				removeChild(_sceneObject, _container);
			}
		}
		
		public static function contains(_sceneObject:ISceneObject, _container:ISceneObject, _recursive:Boolean):Boolean
		{
			if(s_parentBySceneObjects[_sceneObject] == _container)
			{
				return true;
			}
			
			if(_recursive)
			{
				var _children	:Vector.<ISceneObject>	= s_childrenByContainer[_container];
				var _childCount	:int					= _children.length; 
				
				for(var i:int = 0; i < _childCount; i++)
				{
					//if(_children[i] is ISceneObjectContainer)
					{
						if(contains(_sceneObject, ISceneObject(_children[i]), true))
						{
							return true;
						}
					}
				}
			}
			
			return false;
		}
		
		public static function _removeChild(_child:ISceneObject, _scene:IScene):void{
			if(_child is ISceneObjectRenderable)
			{
				removeRenderableChildFromSceneSet(ISceneObjectRenderable(_child), _scene);
			}
			
			if(_child is ICamera)
			{
				removeCameraChildFromSceneSet(ICamera(_child), _scene);
			}
			
			if(_child is Light)
			{
				removeLightFromSceneSet(Light(_child), _scene);
			}
			// [CHECK]
			//if(_child is ISceneObject)
			//{
				removeContainerChildFromSceneSets(ISceneObject(_child), _scene);
			//} else {
				//removeChildFromSceneSet(_child, _scene);
			//}
			_child.removedFromScene(_scene);
		}
		
		private static function removeContainerChildFromSceneSets(_container:ISceneObject, _scene:IScene):void
		{
			removeChildFromSceneSet(ISceneObject(_container), _scene);
			
			if(s_childrenByContainer[_container])
			{
				var _childCount	:int			= s_childCountByContainer[_container];
				var _child		:ISceneObject;
				
				for(var i:int = 0; i < _childCount; i++)
				{
					_child	= s_childrenByContainer[_container][i];
					
					_removeChild( _child, _scene );
				}
			}
		}
		
		private static function addContainerChildsIntoSceneSets(_container:ISceneObject, _scene:IScene, index:int = -1):void
		{
			addChildIntoSceneSet(ISceneObject(_container), _scene);
			
			if(s_childrenByContainer[_container])
			{
				var _childCount	:int			= s_childCountByContainer[_container];
				var _child		:ISceneObject;
				
				for(var i:int = 0; i < _childCount; i++)
				{
					_child	= s_childrenByContainer[_container][i];
					
					if(_child is ISceneObjectRenderable)
					{
						addRenderableChildIntoSceneSet(ISceneObjectRenderable(_child), _scene, index);
					}
					
					if(_child is ICamera)
					{
						addCameraChildIntoSceneSet(ICamera(_child), _scene);
					}
					
					if(_child is Light) {
						addLightIntoSceneSet(Light(_child), _scene);
					}
					
					//if(_child is ISceneObjectContainer)
					//{
						addContainerChildsIntoSceneSets(ISceneObject(_child), _scene, index);
					//} else {
						//addChildIntoSceneSet(_child, _scene);
					//}
				}
			}
			
		}
		
		private static function addLightIntoSceneSet(_light:Light, _scene:IScene):void
		{
			var _sceneLights				:Vector.<Light>		= s_lightsByScene[_scene];
			
			if(!_sceneLights)
			{
				_sceneLights				= new Vector.<Light>();
				s_lightsByScene[_scene] 	= _sceneLights;
			}
			
			_sceneLights[_sceneLights.length]		= _light;
		}
		
		private static  function addChildIntoSceneSet(_sceneObject:ISceneObject, _scene:IScene):void
		{
			var _sceneObjectsByScene		:Vector.<ISceneObject>	= s_sceneObjectsByScene[_scene];
			_sceneObjectsByScene[_sceneObjectsByScene.length]		= _sceneObject;
		}
		
		private static function addRenderableChildIntoSceneSet(_renderableChild:ISceneObjectRenderable, _scene:IScene,index:int = -1):void
		{
			if( s_sceneTreeManagerByScene[ _scene ] )
			{
				IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).addChild(_renderableChild,_scene,index);
			}
		}
		
		private static function addCameraChildIntoSceneSet(_cameraChild:ICamera, _scene:IScene):void
		{
			var _camerasByScene	:Vector.<ICamera> = s_cameraObjectsByScene[_scene];
			
			if(!_camerasByScene)
			{
				_camerasByScene					= new Vector.<ICamera>();
				s_cameraObjectsByScene[_scene]	= _camerasByScene;
			}
			
			_camerasByScene[_camerasByScene.length] = ICamera(_cameraChild);
		}
		
		private static  function removeChildFromSceneSet(_sceneObject:ISceneObject, _scene:IScene):void
		{
			var _sceneObjectsByScene	:Vector.<ISceneObject>	= s_sceneObjectsByScene[_scene];
			var _index					:int					= _sceneObjectsByScene.indexOf(_sceneObject);
			
			if(_index != -1)
			{
				_sceneObjectsByScene.splice(_index, 1);
			}
		}
		
		private static function removeRenderableChildFromSceneSet(_renderableChild:ISceneObjectRenderable, _scene:IScene):void
		{
			if( s_sceneTreeManagerByScene[ _scene ] )
			{
				IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).removeChild( _renderableChild,_scene );
			}
			/*var _renderableObjectsByScene 	:Vector.<ISceneObjectRenderable>	= s_renderableObjectsByScene[_scene];
			var _index						:int								= _renderableObjectsByScene.indexOf(_renderableChild);
			
			if(_index != -1)
			{
				_renderableObjectsByScene.splice(_index, 1);
			}
			
			if(_renderableObjectsByScene.length == 0)
			{
				s_renderableObjectsByScene[_scene] = null;
			}*/
		}
		
		private static function removeLightFromSceneSet(_light:Light, _scene:IScene):void 
		{
			var _sceneLights		:Vector.<Light>	= s_lightsByScene[_scene];
			var _index				:int				= _sceneLights.indexOf(_light);
			
			if (_index != -1) 
			{
				_sceneLights.splice(_index, 1);
			}
			
			if(_sceneLights.length == 0)
			{
				s_lightsByScene[_light] = null;
			}
			
		}
		
		private static function removeCameraChildFromSceneSet(_cameraChild:ICamera, _scene:IScene):void
		{
			var _camerasByScene	:Vector.<ICamera> 	= s_cameraObjectsByScene[_scene];
			var _index			:int				= _camerasByScene.indexOf(_cameraChild);
			
			if(_index != -1)
			{
				_camerasByScene.splice(_index, 1);
			}
			
			if(_camerasByScene.length == 0)
			{
				s_cameraObjectsByScene[_scene] = null;
			}
		}
		
		private static function initContainerDictionaries(_container:ISceneObject):void
		{
			s_childrenByContainer[_container]			= new Vector.<ISceneObject>;
			s_childBySystemIDByContainer[_container]	= new Dictionary();
			s_childCountByContainer[_container]			= 0;
		}
		
		private static function clearContainerDictionaries(_container:ISceneObject):void
		{
			s_childrenByContainer[_container]			= null;
			s_childBySystemIDByContainer[_container]	= null;
			s_childCountByContainer[_container]			= 0;
			
			
		}
		
		private static function staticInitializer():Boolean
		{
			s_childrenByContainer			= new Dictionary(true);
			s_childBySystemIDByContainer	= new Dictionary(true);
			s_childCountByContainer			= new Dictionary(true);
			s_parentBySceneObjects			= new Dictionary(true);
			s_sceneBySceneObjects			= new Dictionary(true);
			s_sceneObjectsByScene			= new Dictionary(true);
			//s_renderableObjectsByScene		= new Dictionary(true);
			s_cameraObjectsByScene			= new Dictionary(true);
			s_lightsByScene					= new Dictionary(true);
			
			return true;
		}
	}
}
