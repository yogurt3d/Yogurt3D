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
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.plugin.Driver;
	import com.yogurt3d.core.plugin.Kernel;
	import com.yogurt3d.core.plugin.Server;
	import com.yogurt3d.core.sceneobjects.Scene;
	import com.yogurt3d.core.sceneobjects.SceneObject;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
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
		public static var  s_renSetIlluminatorLightIndexes  :Dictionary;
		public static var  s_sceneLightIndexes              :Dictionary;
		public static var  s_scenePointLightIndexes         :Dictionary;
		public static var  s_sceneSpotLightIndexes          :Dictionary;
		public static var  s_sceneDirectionalLightIndexes   :Dictionary;
		public static var  s_intersectedLightsByCamera      :Dictionary;
		
		
		private static var s_renderableSetByScene			:Dictionary;
		
		public static function setSceneRootObject(_rootObject:SceneObject, _scene:IScene):void
		{
			s_sceneBySceneObjects[_rootObject]	= _scene;
			
			if(!s_sceneObjectsByScene[_scene])
			{
				s_sceneObjectsByScene[_scene]	= new Vector.<SceneObject>;
				
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
		
		public static function getParent(_sceneObject:SceneObject):SceneObject
		{
			return s_parentBySceneObjects[_sceneObject];
		}
		
		public static function getSceneLightIndexes(_scene:IScene):Vector.<int>
		{
			return s_sceneLightIndexes[_scene];
		}
		
/*		public static function getRenSetIlluminatorLightIndexes(_scene:IScene, _renderableChild:SceneObjectRenderable):Vector.<int>
		{
			return s_renSetIlluminatorLightIndexes[ _scene ][_renderableChild];
		}*/
		
		public static function initIntersectedLightByCamera(_scene:IScene, _activeCamera:Camera):void
		{
			var lights:Vector.<Light> =  s_lightsByScene[_scene];
			var k:int;
			
			if( lights )
			{				
				if( SceneTreeManager.s_intersectedLightsByCamera[_activeCamera] == null)
					SceneTreeManager.s_intersectedLightsByCamera[_activeCamera] = new Vector.<Light>;
					
				for ( k = 0; k < lights.length; k++) 
				{
					var _light:Light = lights[k];
					
					if(_light.type == ELightType.DIRECTIONAL)
						
						SceneTreeManager.s_intersectedLightsByCamera[_activeCamera].push(_light);
					
					else if(_activeCamera.frustum.containmentTestSphere(_light.frustum.boundingSphere) != 0)
					{
						getSceneRenderableSetLight(_scene, _light, k );
						SceneTreeManager.s_intersectedLightsByCamera[_activeCamera].push(_light);
					}
				}
			}
			
		}
		public static function initRenSetIlluminatorLightIndexes(_scene:IScene, _renderableChild:SceneObjectRenderable):void
		{
			if( s_renSetIlluminatorLightIndexes[ _scene ] == null )
			{
				s_renSetIlluminatorLightIndexes[ _scene ] = new Dictionary();
			}
			
			s_renSetIlluminatorLightIndexes[ _scene ][_renderableChild] = new Vector.<int>;
		}
		
		public static function getIlluminatorLightIndexes(_scene:IScene, _renderableChild:SceneObjectRenderable):Vector.<int>
		{
			return IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).getIlluminatorLightIndexes( _scene, _renderableChild );
			//return s_renSetIlluminatorLightIndexes[_scene][_renderableChild].concat(s_sceneDirectionalLightIndexes);
		}
		
		public static function clearIlluminatorLightIndexes(_scene:IScene, _renderableChild:SceneObjectRenderable):void
		{
			 IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).clearIlluminatorLightIndexes( _scene, _renderableChild );
			//s_renSetIlluminatorLightIndexes[_scene][_renderableChild].length = 0;
		}
		
		public static function getRoot(_sceneObject:SceneObject):SceneObject
		{
			var _currentParent	:SceneObject	= s_parentBySceneObjects[_sceneObject];
			
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
		
		public static function getScene(_sceneObject:SceneObject):Scene
		{
			if(_sceneObject.root)
			{
				return s_sceneBySceneObjects[_sceneObject.root];
			} else {
				return s_sceneBySceneObjects[_sceneObject];
			}
			
			return null;
		}
		
		public static function getSceneObjectSet(_scene:IScene):Vector.<SceneObject>
		{
			return s_sceneObjectsByScene[_scene];
		}
		
		public static function clearSceneFrameData( _scene:IScene, _camera:Camera ):void{
			
			if( s_renderableSetByScene[ _scene ] != null )
			{
				delete s_renderableSetByScene[ _scene ];
			}
			
			if( s_intersectedLightsByCamera[ _camera ] != null )
			{
				delete s_intersectedLightsByCamera[ _camera ];
			}
		}
		
		public static function getSceneRenderableSet(_scene:IScene, _camera:Camera):Vector.<SceneObjectRenderable>
		{
			if( s_renderableSetByScene[ _scene ] && s_renderableSetByScene[ _scene ][_camera] )
			{
				return s_renderableSetByScene[ _scene ][_camera];
			}
			if( s_renderableSetByScene[ _scene ] == null )
			{
				s_renderableSetByScene[ _scene ] = new Dictionary(true);
			}			
			if( s_sceneTreeManagerByScene[ _scene ] )
			{
				return s_renderableSetByScene[ _scene ][_camera] = IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).getSceneRenderableSet( _scene, _camera );
			}
			return null; // s_renderableObjectsByScene[_scene];
		}
		
		
		public static function getSceneRenderableSetLight(_scene:IScene, _light:Light, _lightIndex:int):Vector.<SceneObjectRenderable>
		{
			if( s_renderableSetByScene[ _scene ] && s_renderableSetByScene[ _scene ][_light] )
			{
				return s_renderableSetByScene[ _scene ][_light];
			}
			if( s_renderableSetByScene[ _scene ] == null )
			{
				s_renderableSetByScene[ _scene ] = new Dictionary(true);
			}			
			if( s_sceneTreeManagerByScene[ _scene ] )
			{
				if(_light.type == ELightType.DIRECTIONAL)
					return IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).getSceneRenderableSetLight( _scene, _light, _lightIndex );
				
				return s_renderableSetByScene[ _scene ][_light] = IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).getSceneRenderableSetLight( _scene, _light, _lightIndex );
			}
			return null; // s_renderableObjectsByScene[_scene];
		}
		
		
		public static function getSceneLightSet(_scene:IScene):Vector.<Light>
		{
			return s_lightsByScene[_scene];
		}
		
		public static function getSceneCameraSet(_scene:IScene):Vector.<Camera>
		{
			return s_cameraObjectsByScene[_scene];
		}
		
		public static function getChildren(_container:SceneObject):Vector.<SceneObject>
		{
			return s_childrenByContainer[_container];
		}
		
		public static function getChildrenCount(_container:SceneObject):int
		{
			return s_childCountByContainer[_container];
		}
		
		public static function getChildBySystemID(_systemID:String, _container:SceneObject):SceneObject
		{
			if(!s_childBySystemIDByContainer[_container])
			{
				return null;
			}
			
			return s_childBySystemIDByContainer[_container][_systemID];
		}
		
		public static function getChildByUserID(_userID:String, _container:SceneObject):SceneObject
		{
			if(!s_childBySystemIDByContainer[_container])
			{
				return null;
			}
			
			return s_childBySystemIDByContainer[_container][IDManager.getSystemIDByUserID(_userID)];
		}
		
		public static function addChild(_child:SceneObject, _container:SceneObject, index:int = -1):void
		{
			if(	!s_childrenByContainer		 [_container] ||
				!s_childBySystemIDByContainer[_container] ||
				!s_childCountByContainer	 [_container]
			  )
			{
				initContainerDictionaries(_container);
			}
			
			// containers children list
			var _children				:Vector.<SceneObject>	= s_childrenByContainer		  [_container];
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
				
				var _containerAsSceneObject	:SceneObject	= SceneObject(_container);
				var _rootObject				:SceneObject	= _containerAsSceneObject.root;
				var _scene					:IScene;
				
				if(!_rootObject)
				{
					_rootObject = _containerAsSceneObject;
				}
				
				_scene = s_sceneBySceneObjects[_rootObject];
				
				if(_scene)
				{
					if(_child is SceneObjectRenderable)
					{
						addRenderableChildIntoSceneSet(SceneObjectRenderable(_child), _scene, index);
					}
					
					if(_child is Camera)
					{
						addCameraChildIntoSceneSet(Camera(_child), _scene);
					}
					
					if(_child is Light) {
						addLightIntoSceneSet(Light(_child), _scene);
					}
					
					//if(_child is SceneObjectContainer)
					//{
						addContainerChildsIntoSceneSets( _child, _scene, index);
					//} else {
						//addChildIntoSceneSet(_child, _scene);
					//}
					_child.onAddedToScene.dispatch( _child, _scene );
				}
			}
		}
		
		
		
		
		public static function removeChild(_child:SceneObject, _container:SceneObject):void
		{
			var _children	:Vector.<SceneObject>	= s_childrenByContainer[_container];
			
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
					
					var _containerAsSceneObject	:SceneObject	= SceneObject(_container);
					var _rootObject				:SceneObject	= _containerAsSceneObject.root;
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
		
		
		public static function removeChildBySystemID(_systemID:String, _container:SceneObject):void
		{
			var _sceneObject:SceneObject	= getChildBySystemID(_systemID, _container); 
			
			if(_sceneObject)
			{
				removeChild(_sceneObject, _container);
			}
		}
		
		public static function removeChildByUserID(_userID:String, _container:SceneObject):void
		{
			var _sceneObject:SceneObject	= getChildByUserID(_userID, _container); 
			
			if(_sceneObject)
			{
				removeChild(_sceneObject, _container);
			}
		}
		
		public static function contains(_sceneObject:SceneObject, _container:SceneObject, _recursive:Boolean):Boolean
		{
			if(s_parentBySceneObjects[_sceneObject] == _container)
			{
				return true;
			}
			
			if(_recursive)
			{
				var _children	:Vector.<SceneObject>	= s_childrenByContainer[_container];
				var _childCount	:int					= _children.length; 
				
				for(var i:int = 0; i < _childCount; i++)
				{
					//if(_children[i] is SceneObjectContainer)
					{
						if(contains(_sceneObject, SceneObject(_children[i]), true))
						{
							return true;
						}
					}
				}
			}
			
			return false;
		}
		
		public static function _removeChild(_child:SceneObject, _scene:IScene):void{
			if(_child is SceneObjectRenderable)
			{
				removeRenderableChildFromSceneSet(SceneObjectRenderable(_child), _scene);
			}
			
			if(_child is Camera)
			{
				removeCameraChildFromSceneSet(Camera(_child), _scene);
			}
			
			if(_child is Light)
			{
				removeLightFromSceneSet(Light(_child), _scene);
			}
			// [CHECK]
			//if(_child is SceneObject)
			//{
				removeContainerChildFromSceneSets(SceneObject(_child), _scene);
			//} else {
				//removeChildFromSceneSet(_child, _scene);
			//}
			_child.onRemovedFromScene.dispatch(_child, _scene);
		}
		
		private static function removeContainerChildFromSceneSets(_container:SceneObject, _scene:IScene):void
		{
			removeChildFromSceneSet(SceneObject(_container), _scene);
			
			if(s_childrenByContainer[_container])
			{
				var _childCount	:int			= s_childCountByContainer[_container];
				var _child		:SceneObject;
				
				for(var i:int = 0; i < _childCount; i++)
				{
					_child	= s_childrenByContainer[_container][i];
					
					_removeChild( _child, _scene );
				}
			}
		}
		
		private static function addContainerChildsIntoSceneSets(_container:SceneObject, _scene:IScene, index:int = -1):void
		{
			addChildIntoSceneSet(SceneObject(_container), _scene);
			
			if(s_childrenByContainer[_container])
			{
				var _childCount	:int			= s_childCountByContainer[_container];
				var _child		:SceneObject;
				
				for(var i:int = 0; i < _childCount; i++)
				{
					_child	= s_childrenByContainer[_container][i];
					
					if(_child is SceneObjectRenderable)
					{
						addRenderableChildIntoSceneSet(SceneObjectRenderable(_child), _scene, index);
					}
					
					if(_child is Camera)
					{
						addCameraChildIntoSceneSet(Camera(_child), _scene);
					}
					
					if(_child is Light) {
						addLightIntoSceneSet(Light(_child), _scene);
					}
					
					//if(_child is SceneObjectContainer)
					//{
						addContainerChildsIntoSceneSets(SceneObject(_child), _scene, index);
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
				s_sceneLightIndexes[_scene] = new Vector.<int>();
				
				_sceneLights				= new Vector.<Light>();
				s_lightsByScene[_scene] 	= _sceneLights;
				
				//if(_light.type == ELightType.POINT)
				s_scenePointLightIndexes[_scene] = new Vector.<int>();

				// initialized in class declaration because of some "not null" needs
				//else if(_light.type == ELightType.DIRECTIONAL)
				s_sceneDirectionalLightIndexes[_scene] = new Vector.<int>();

				//else if(_light.type == ELightType.SPOT)
				s_sceneSpotLightIndexes[_scene] = new Vector.<int>();

				
					
			}
			
			if(_light.type == ELightType.POINT)
				s_scenePointLightIndexes[_scene].push(s_sceneLightIndexes[_scene].length);
			
			else if(_light.type == ELightType.DIRECTIONAL)
				s_sceneDirectionalLightIndexes[_scene].push(s_sceneLightIndexes[_scene].length);
			
			else if(_light.type == ELightType.SPOT)
				s_sceneSpotLightIndexes[_scene].push(s_sceneLightIndexes[_scene].length);
			
			s_sceneLightIndexes[_scene].push(s_sceneLightIndexes[_scene].length);
			_sceneLights[_sceneLights.length]		= _light;
		

			var dict:Dictionary = IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).getListOfVisibilityTesterByScene();
			
			if(dict == null)
				return;
			
			if(dict[_scene] == null)
				dict[_scene] = new Dictionary();
			
			if(dict[_scene][_light] == null)
				dict[_scene][_light] = new Vector.<SceneObjectRenderable>(1500);
			
			
		}
		
		private static  function addChildIntoSceneSet(_sceneObject:SceneObject, _scene:IScene):void
		{
			var _sceneObjectsByScene		:Vector.<SceneObject>	= s_sceneObjectsByScene[_scene];
			_sceneObjectsByScene[_sceneObjectsByScene.length]		= _sceneObject;
		}
		
		private static function addRenderableChildIntoSceneSet(_renderableChild:SceneObjectRenderable, _scene:IScene,index:int = -1):void
		{
			if( s_sceneTreeManagerByScene[ _scene ] )
			{
				IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).addChild(_renderableChild, _scene, index);
			}
		}
		
		private static function addCameraChildIntoSceneSet(_cameraChild:Camera, _scene:IScene):void
		{
			var _camerasByScene	:Vector.<Camera> = s_cameraObjectsByScene[_scene];
			
			if(!_camerasByScene)
			{
				_camerasByScene					= new Vector.<Camera>();
				s_cameraObjectsByScene[_scene]	= _camerasByScene;
			}
			
			_camerasByScene[_camerasByScene.length] = Camera(_cameraChild);
			
			var dict:Dictionary = IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).getListOfVisibilityTesterByScene();
			
			if(dict == null)
				return;
			
			if(dict[_scene] == null)
				dict[_scene] = new Dictionary();
			
			if(dict[_scene][_cameraChild] == null)
				dict[_scene][_cameraChild] = new Vector.<SceneObjectRenderable>(1500);
			
			
		}
		
		private static  function removeChildFromSceneSet(_sceneObject:SceneObject, _scene:IScene):void
		{
			var _sceneObjectsByScene	:Vector.<SceneObject>	= s_sceneObjectsByScene[_scene];
			var _index					:int					= _sceneObjectsByScene.indexOf(_sceneObject);
			
			if(_index != -1)
			{
				_sceneObjectsByScene.splice(_index, 1);
			}
		}
		
		private static function removeRenderableChildFromSceneSet(_renderableChild:SceneObjectRenderable, _scene:IScene):void
		{
			if( s_sceneTreeManagerByScene[ _scene ] )
			{
				IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).removeChildFromTree( _renderableChild, _scene );
			}
			/*var _renderableObjectsByScene 	:Vector.<SceneObjectRenderable>	= s_renderableObjectsByScene[_scene];
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
			var _index				:int			= _sceneLights.indexOf(_light);
			
			if (_index != -1) 
			{
				_sceneLights.splice(_index, 1);
				s_sceneLightIndexes[_scene].pop();
				
				var indexes:Vector.<int>;
				
				if(_light.type == ELightType.POINT)
					indexes = s_scenePointLightIndexes[_scene];
				else if(_light.type == ELightType.DIRECTIONAL)
					indexes = s_sceneDirectionalLightIndexes[_scene];
				else if(_light.type == ELightType.SPOT)
					indexes = s_sceneSpotLightIndexes[_scene];
				
				for(var i:int = 0; i < indexes.length; i++)
				{
					if(indexes[i] == _index)
						indexes.splice(indexes[i], 1);
				}
				if(indexes.length == 0)
					indexes = null;
			}
			
			if(_sceneLights.length == 0)
			{
				s_lightsByScene[_scene] = null;
				delete s_sceneLightIndexes[_scene];
				
			}
			
			var dict:Dictionary = IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).getListOfVisibilityTesterByScene();
			
			if(dict == null)
				return;
			
			if(dict[_scene][_light] == null)
				 delete dict[_scene][_light];
			
			
		}
		
		private static function removeCameraChildFromSceneSet(_cameraChild:Camera, _scene:IScene):void
		{
			var _camerasByScene	:Vector.<Camera> 	= s_cameraObjectsByScene[_scene];
			var _index			:int				= _camerasByScene.indexOf(_cameraChild);
			
			if(_index != -1)
			{
				_camerasByScene.splice(_index, 1);
			}
			
			if(_camerasByScene.length == 0)
			{
				s_cameraObjectsByScene[_scene] = null;
			}
			
			var dict:Dictionary = IRenderableManager(s_sceneTreeManagerByScene[ _scene ]).getListOfVisibilityTesterByScene();
			
			if(dict == null)
				return;
			
			if(dict[_scene][_cameraChild])
				delete dict[_scene][_cameraChild];
			
			
		}
		
		private static function initContainerDictionaries(_container:SceneObject):void
		{
			s_childrenByContainer[_container]			= new Vector.<SceneObject>;
			s_childBySystemIDByContainer[_container]	= new Dictionary();
			s_childCountByContainer[_container]			= 0;
		}
		
		private static function clearContainerDictionaries(_container:SceneObject):void
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
			s_renderableSetByScene			= new Dictionary(true);
			s_renSetIlluminatorLightIndexes = new Dictionary(true);
			s_intersectedLightsByCamera     = new Dictionary(true);
			s_sceneLightIndexes				= new Dictionary(true);
			s_scenePointLightIndexes  		= new Dictionary(true);
			s_sceneDirectionalLightIndexes  = new Dictionary(true);
			s_sceneSpotLightIndexes			= new Dictionary(true);
			//s_sceneLightIndexes             = new Vector.<int>;
			return true;
		}
	}
}
