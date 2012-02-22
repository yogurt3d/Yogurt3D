package com.yogurt3d.core.scenetree.quad
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.frustum.Frustum;
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.managers.scenetreemanager.SceneTreeManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.Scene;
	import com.yogurt3d.core.sceneobjects.SceneObject;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	
	
	import com.yogurt3d.core.scenetree.IRenderableManager;
	import com.yogurt3d.core.transformations.Transformation;
	import com.yogurt3d.core.lights.ELightType;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	use namespace YOGURT3D_INTERNAL;
	
	public class QuadSceneTreeManager implements IRenderableManager
	{
		YOGURT3D_INTERNAL static var s_quadTreeByScene:Dictionary;
		private static var s_staticChildrenByScene:Dictionary;
		
		private static var s_dynamicChildrenByScene:Dictionary;
		
		//the list for storing recursive "visibilityProcess" results for the testers like camera or light
		private static var listOfVisibilityTesterByScene:Dictionary;
		
		private static var s_transformedDynamicChildren:Vector.<SceneObjectRenderable> = new Vector.<SceneObjectRenderable>();
		private static var s_marktransformedDynamicChildren:Dictionary = new Dictionary();
		
		public function QuadSceneTreeManager()
		{
			if( s_quadTreeByScene == null )
			{
				s_quadTreeByScene = new Dictionary(false);
				s_staticChildrenByScene = new Dictionary(true);
				s_dynamicChildrenByScene = new Dictionary(true);
				listOfVisibilityTesterByScene = new Dictionary();
			}
		}
		
		public function addChild(_child:SceneObjectRenderable, _scene:IScene, index:int=-1):void
		{
			SceneTreeManager.initRenSetIlluminatorLightIndexes(_scene, _child);
			
			if( s_quadTreeByScene[_scene] == null )
			{
				if( Scene(_scene).YOGURT3D_INTERNAL::m_args != null && 
					"x" in Scene(_scene).YOGURT3D_INTERNAL::m_args && 
					"y" in Scene(_scene).YOGURT3D_INTERNAL::m_args && 
					"z" in Scene(_scene).YOGURT3D_INTERNAL::m_args && 
					"width" in Scene(_scene).YOGURT3D_INTERNAL::m_args && 
					"height" in Scene(_scene).YOGURT3D_INTERNAL::m_args &&
					"depth" in Scene(_scene).YOGURT3D_INTERNAL::m_args 
				)
				{
					s_quadTreeByScene[_scene] = new QuadTree( 
						new AxisAlignedBoundingBox( 
							new Vector3D(
								Scene(_scene).YOGURT3D_INTERNAL::m_args.x,
								Scene(_scene).YOGURT3D_INTERNAL::m_args.y,
								Scene(_scene).YOGURT3D_INTERNAL::m_args.z),
							new Vector3D(
								Scene(_scene).YOGURT3D_INTERNAL::m_args.width ,
								Scene(_scene).YOGURT3D_INTERNAL::m_args.height,
								Scene(_scene).YOGURT3D_INTERNAL::m_args.depth
							)
						)
					);
					Y3DCONFIG::TRACE
					{
						trace("OCTREE ",
							"x", Scene(_scene).YOGURT3D_INTERNAL::m_args.x,
							"y", Scene(_scene).YOGURT3D_INTERNAL::m_args.y,
							"z", Scene(_scene).YOGURT3D_INTERNAL::m_args.z,
							"width", Scene(_scene).YOGURT3D_INTERNAL::m_args.width ,
							"height", Scene(_scene).YOGURT3D_INTERNAL::m_args.height,
							"depth", Scene(_scene).YOGURT3D_INTERNAL::m_args.depth);
					}
				}
				else{
					s_quadTreeByScene[_scene] = new QuadTree( 
						new AxisAlignedBoundingBox(
							new Vector3D(-10000,-10000,-10000),
							new Vector3D(20000,20000,20000)
						)
					);
				}
				
			}
			
			if( listOfVisibilityTesterByScene[_scene] == null )
			{
				listOfVisibilityTesterByScene[_scene] = new Dictionary();
			}
			
			
			if( s_staticChildrenByScene[_scene] == null )
			{
				s_staticChildrenByScene[_scene] = new Vector.<SceneObjectRenderable>();
			}
			
			if( s_dynamicChildrenByScene[_scene] == null )
			{
				s_dynamicChildrenByScene[_scene] = new Vector.<SceneObjectRenderable>();
			}
			
			
			if( _child.isStatic )
			{
				//if( s_staticChildrenByScene[_scene] == null )
				//{
					//s_staticChildrenByScene[_scene] = new Vector.<SceneObjectRenderable>();
				//}
				s_staticChildrenByScene[_scene].push(_child);
			}
			else
			{
/*				if( s_dynamicChildrenByScene[_scene] == null )
				{
					s_dynamicChildrenByScene[_scene] = new Vector.<SceneObjectRenderable>();
				}*/
				s_dynamicChildrenByScene[_scene].push( _child );
				
				_child.transformation.onChange.add( onChildTransChanged );
			}

	        s_quadTreeByScene[_scene].insert(_child);
			
			_child.onStaticChanged.add(onStaticChange );
			
		}
		
		private function onChildTransChanged(tras:Transformation):void{
			if( tras.m_isAddedToSceneRefreshList == false)
			{
				s_transformedDynamicChildren[s_transformedDynamicChildren.length] = SceneObjectRenderable(tras.m_ownerSceneObject);
				tras.m_isAddedToSceneRefreshList = true;
			}
		}
		
		public function getListOfVisibilityTesterByScene():Dictionary{
			return listOfVisibilityTesterByScene;
		}
		
		
		private function onStaticChange( _scn:SceneObject ):void{
			var _child:SceneObjectRenderable = _scn as SceneObjectRenderable;
			
			if( _child.isStatic )
			{
				_removeChildFromDynamicList( _child, _child.scene );
				
				_child.transformation.onChange.remove( onChildTransChanged );
				
				s_staticChildrenByScene[_child.scene].push( _child );
				
				
			}else
			{
				_removeChildFromStaticList( _child, _child.scene );
				
				_child.transformation.onChange.add( onChildTransChanged );
				
				s_dynamicChildrenByScene[_child.scene].push( _child );
			}
		}
		
		private function _removeChildFromDynamicList( _child:SceneObjectRenderable, _scene:IScene ):void{
			if( s_dynamicChildrenByScene[_scene ] )
			{
				var _renderableObjectsByScene 	:Vector.<SceneObjectRenderable>	= s_dynamicChildrenByScene[_scene];
				var _index						:int								= _renderableObjectsByScene.indexOf(_child);
				
				if(_index != -1)
				{
					_renderableObjectsByScene.splice(_index, 1);
				}
				
				if(_renderableObjectsByScene.length == 0)
				{
					s_dynamicChildrenByScene[_scene] = null;
				}
			}
			
		}
		
		
		private function _removeChildFromStaticList( _child:SceneObjectRenderable, _scene:IScene ):void{
			if( s_dynamicChildrenByScene[_scene ] )
			{
				var _renderableObjectsByScene 	:Vector.<SceneObjectRenderable>	= s_staticChildrenByScene[_scene];
				var _index						:int								= _renderableObjectsByScene.indexOf(_child);
				
				if(_index != -1)
				{
					_renderableObjectsByScene.splice(_index, 1);
				}
				
				if(_renderableObjectsByScene.length == 0)
				{
					s_staticChildrenByScene[_scene] = null;
				}
			}
			
		}
		
		
		public function getSceneRenderableSet(_scene:IScene, _camera:Camera):Vector.<SceneObjectRenderable>
		{
			var camera:Camera =  _camera;

			if( s_quadTreeByScene[_scene] )
			{
				s_quadTreeByScene[_scene].updateTree(s_transformedDynamicChildren );
				
				camera.frustum.extractPlanes(camera.transformation);

				camera.frustum.boundingSphere.YOGURT3D_INTERNAL::m_center = camera.transformation.matrixGlobal.transformVector(camera.frustum.m_bSCenterOrginal);
				
				s_quadTreeByScene[_scene].list = listOfVisibilityTesterByScene[_scene][_camera];
				
				s_quadTreeByScene[_scene].visibilityProcess( _camera );
			
				return s_quadTreeByScene[_scene].list;
			}
			
			return null;
		}
		
		public function getSceneRenderableSetLight(_scene:IScene, _light:Light, lightIndex:int):Vector.<SceneObjectRenderable>
		{
			if(_light.type == ELightType.DIRECTIONAL)
			{
				if(s_staticChildrenByScene[_scene] == null)
					return null;
					
				return s_dynamicChildrenByScene[_scene].concat(s_staticChildrenByScene[_scene]);
			}
			
			if( s_quadTreeByScene[_scene] )
			{
				
				if(_light.type != ELightType.POINT)
					_light.frustum.extractPlanes(_light.transformation);
				
				_light.frustum.boundingSphere.YOGURT3D_INTERNAL::m_center = _light.transformation.matrixGlobal.transformVector(_light.frustum.m_bSCenterOrginal);
				
				s_quadTreeByScene[_scene].list = listOfVisibilityTesterByScene[_scene][_light];
				
				s_quadTreeByScene[_scene].visibilityProcessLight( _light, lightIndex, _scene);
				
				return s_quadTreeByScene[_scene].list;
			}
			
			return null;
		}
		
		public function removeChildFromTree(_child:SceneObjectRenderable, _scene:IScene):void
		{
			var _renderableObjectsByScene 	:Vector.<SceneObjectRenderable>;
			var _index						:int;
			var _dictionary                 :Dictionary;
			
			
			if(_child.isStatic)
			{
				_renderableObjectsByScene	= s_staticChildrenByScene[_scene];
			    _index	= _renderableObjectsByScene.indexOf(_child);
				_dictionary = s_staticChildrenByScene;
			}
			else
			{
				_renderableObjectsByScene	= s_dynamicChildrenByScene[_scene];
				_index	= _renderableObjectsByScene.indexOf(_child);
				_dictionary = s_dynamicChildrenByScene;
				s_transformedDynamicChildren.splice(s_transformedDynamicChildren.indexOf(_child), 1);
			}
            
			if(_index != -1)
			{
				_renderableObjectsByScene.splice(_index, 1);
				SceneTreeManager.s_renSetIlluminatorLightIndexes[_scene][_child] = null;
			}
				
			if(_renderableObjectsByScene.length == 0)
			{
				_dictionary[_scene] = null;
			}

			s_quadTreeByScene[_scene].removeFromNode(_child);
			delete s_quadTreeByScene[_scene].sceneObjectToQuadrant[ _child ];
		
		}
		
		public function getIlluminatorLightIndexes(_scene:IScene, _objectRenderable:SceneObjectRenderable):Vector.<int>
		{
			return SceneTreeManager.s_renSetIlluminatorLightIndexes[_scene][_objectRenderable].concat(SceneTreeManager.s_sceneDirectionalLightIndexes[_scene]);
		}
		
		public function clearIlluminatorLightIndexes(_scene:IScene, _objectRenderable:SceneObjectRenderable):void
		{
			SceneTreeManager.s_renSetIlluminatorLightIndexes[_scene][_objectRenderable].length = 0;
		}
		
		
		
	}
}