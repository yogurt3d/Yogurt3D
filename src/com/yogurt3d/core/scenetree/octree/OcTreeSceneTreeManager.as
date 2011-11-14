package com.yogurt3d.core.scenetree.octree
{
	import com.yogurt3d.core.frustum.Frustum;
	import com.yogurt3d.core.cameras.interfaces.ICamera;
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.Scene;
	import com.yogurt3d.core.sceneobjects.SceneObject;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObject;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	import com.yogurt3d.core.scenetree.IRenderableManager;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	use namespace YOGURT3D_INTERNAL;
	
	public class OcTreeSceneTreeManager implements IRenderableManager
	{
		YOGURT3D_INTERNAL static var s_octantByScene:Dictionary;
		private static var s_childrenByScene:Dictionary;
		
		private static var s_dynamicChildrenByScene:Dictionary;
		
		public function OcTreeSceneTreeManager()
		{
			if( s_octantByScene == null )
			{
				s_octantByScene = new Dictionary(false);
				s_childrenByScene = new Dictionary(true);
				s_dynamicChildrenByScene = new Dictionary(true);
			}
		}
		
		public function addChild(_child:ISceneObjectRenderable, _scene:IScene, index:int=-1):void
		{
			if( s_childrenByScene[_scene] == null )
			{
				s_childrenByScene[_scene] = new Vector.<ISceneObjectRenderable>();
			}
			s_childrenByScene[_scene].push(_child);
			
			if( s_octantByScene[_scene] == null )
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
					s_octantByScene[_scene] = new OctTree( 
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
					s_octantByScene[_scene] = new OctTree( 
						new AxisAlignedBoundingBox(
							new Vector3D(-10000,-10000,-10000),
							new Vector3D(20000,20000,20000)
						)
					);
				}
				
			}
			if( _child.isStatic )
			{
				//_child.geometry.axisAlignedBoundingBox.update( SceneObjectRenderable(_child).YOGURT3D_INTERNAL::m_transformation.matrixGlobal );
				//_child.geometry.boundingSphere.YOGURT3D_INTERNAL::m_center =  SceneObjectRenderable(_child).YOGURT3D_INTERNAL::m_transformation.matrixGlobal.position;
				s_octantByScene[_scene].insert(_child);
			}else{
				if( s_dynamicChildrenByScene[_scene ] == null )
				{
					s_dynamicChildrenByScene[_scene] = new Vector.<ISceneObjectRenderable>();
				}
				s_dynamicChildrenByScene[_scene].push( _child );
			}
			_child.onStaticChanged.add(onStaticChange );
			
		}
		
		private function onStaticChange( _scn:SceneObject ):void{
			var _child:ISceneObjectRenderable = _scn as ISceneObjectRenderable;
			if( _child.isStatic )
			{
				//_child.axisAlignedBoundingBox.update( SceneObjectRenderable(_child).YOGURT3D_INTERNAL::m_transformation.matrixGlobal );
				//_child.boundingSphere.YOGURT3D_INTERNAL::m_center =  SceneObjectRenderable(_child).geometry.axisAlignedBoundingBox.center;
				
				s_octantByScene[_child.scene].insert(_child);
				_removeChildFromDynamicList( _child, _child.scene );
			}else{
				s_octantByScene[_child.scene].remove(_child);
				
				if( s_dynamicChildrenByScene[_child.scene ] == null )
				{
					s_dynamicChildrenByScene[_child.scene] = new Vector.<ISceneObjectRenderable>();
				}
				s_dynamicChildrenByScene[_child.scene].push( _child );
			}
		}
		
		private function _removeChildFromDynamicList( _child:ISceneObjectRenderable, _scene:IScene ):void{
			if( s_dynamicChildrenByScene[_scene ] )
			{
				var _renderableObjectsByScene 	:Vector.<ISceneObjectRenderable>	= s_dynamicChildrenByScene[_scene];
				var _index						:int								= _renderableObjectsByScene.indexOf(_child);
				
				if(_index != -1)
				{
					_renderableObjectsByScene.splice(_index, 1);
				}
				
				if(_renderableObjectsByScene.length == 0)
				{
					s_childrenByScene[_scene] = null;
				}
			}
			
		}
		
		public function getSceneRenderableSet(_scene:IScene, _camera:ICamera):Vector.<ISceneObjectRenderable>
		{
			var temp :Vector3D;
			
			var camera:ICamera =  _camera;
			
			if( s_octantByScene[_scene] != null && s_dynamicChildrenByScene[_scene] != null )
			{
				camera.frustum.extractPlanes(camera.transformation);
				
				temp = camera.transformation.matrixGlobal.transformVector(camera.frustum.m_bSCenterOrginal);
				
				camera.frustum.boundingSphere.YOGURT3D_INTERNAL::m_center = temp;
				
				s_octantByScene[_scene].visibilityProcess( _camera );
				
				var remove:Array = [];
				for( var i:int = 0; i < s_octantByScene[_scene].listlength; i++ )
				{
					var item:ISceneObjectRenderable = s_octantByScene[_scene].list[i];
					/*if( camera.frustum.containmentTestSphere( item.geometry.boundingSphere ) == Frustum.OUT )
					{
					remove.push( i );
					continue;
					}*/
					if( camera.frustum.containmentTestAABB( item.axisAlignedBoundingBox ) == Frustum.OUT )
					{
						remove.push( i );
						continue;
					}
				}
				for( i = remove.length -1; i >= 0; i-- )
				{
					s_octantByScene[_scene].list.splice( remove[i], 1 );
				}
				
				return s_dynamicChildrenByScene[_scene].concat( s_octantByScene[_scene].list );
			}else if( s_octantByScene[_scene] )
			{
				camera.frustum.extractPlanes(camera.transformation);
				
				temp = camera.transformation.matrixGlobal.transformVector(camera.frustum.m_bSCenterOrginal);
				
				camera.frustum.boundingSphere.YOGURT3D_INTERNAL::m_center = temp;
				
				s_octantByScene[_scene].visibilityProcess( _camera );
				
				return s_octantByScene[_scene].list;
			}else if( s_dynamicChildrenByScene[_scene] ){
				return s_dynamicChildrenByScene[_scene];
			}
			
			return null;
		}
		
		public function removeChild(_child:ISceneObjectRenderable, _scene:IScene):void
		{
			var _renderableObjectsByScene 	:Vector.<ISceneObjectRenderable>	= s_childrenByScene[_scene];
			var _index						:int								= _renderableObjectsByScene.indexOf(_child);
			
			if(_index != -1)
			{
				_renderableObjectsByScene.splice(_index, 1);
			}
			
			if(_renderableObjectsByScene.length == 0)
			{
				s_childrenByScene[_scene] = null;
			}
			if( _child.isStatic )
			{
				s_octantByScene[_scene].removeItem(_child);
			}else{
				_removeChildFromDynamicList( _child, _scene );
			}
			
		}
		
		
		
	}
}