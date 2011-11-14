package com.yogurt3d.core.scenetree.quad
{
	import com.yogurt3d.core.frustum.Frustum;
	import com.yogurt3d.core.cameras.interfaces.ICamera;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.Scene;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	import com.yogurt3d.core.scenetree.IRenderableManager;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	use namespace YOGURT3D_INTERNAL;
	
	public class QuadSceneTreeManager implements IRenderableManager
	{
		YOGURT3D_INTERNAL static var s_quadByScene:Dictionary;
		private static var s_childrenByScene:Dictionary;
		
		private static var s_dynamicChildrenByScene:Dictionary;
		
		public function QuadSceneTreeManager()
		{
			if( s_quadByScene == null )
			{
				s_quadByScene = new Dictionary(false);
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
			
			if( s_quadByScene[_scene] == null )
			{
				if( Scene(_scene).YOGURT3D_INTERNAL::m_args != null && 
					"x" in Scene(_scene).YOGURT3D_INTERNAL::m_args && 
					"z" in Scene(_scene).YOGURT3D_INTERNAL::m_args && 
					"width" in Scene(_scene).YOGURT3D_INTERNAL::m_args && 
					"height" in Scene(_scene).YOGURT3D_INTERNAL::m_args
				)
				{
					s_quadByScene[_scene] = new QuadTree( new Rectangle(
						Scene(_scene).YOGURT3D_INTERNAL::m_args.x,
						Scene(_scene).YOGURT3D_INTERNAL::m_args.z,
						Scene(_scene).YOGURT3D_INTERNAL::m_args.width ,
						Scene(_scene).YOGURT3D_INTERNAL::m_args.height
					), 3, 4 );
					Y3DCONFIG::TRACE
					{
						trace("QUAD ",Scene(_scene).YOGURT3D_INTERNAL::m_args.x,
							Scene(_scene).YOGURT3D_INTERNAL::m_args.z,
							Scene(_scene).YOGURT3D_INTERNAL::m_args.width ,
							Scene(_scene).YOGURT3D_INTERNAL::m_args.height);
					}
				}
				else{
					s_quadByScene[_scene] = new QuadTree( new Rectangle(-10000,-10000,20000,20000), 3, 2 );
				}
				
			}
			if( _child.isStatic )
			{
				//_child.axisAlignedBoundingBox.update( SceneObjectRenderable(_child).YOGURT3D_INTERNAL::m_transformation.matrixGlobal );
				//_child.boundingSphere.YOGURT3D_INTERNAL::m_center =  SceneObjectRenderable(_child).YOGURT3D_INTERNAL::m_transformation.matrixGlobal.position;
				s_quadByScene[_scene].insert(_child);
			}else{
				if( s_dynamicChildrenByScene[_scene ] == null )
				{
					s_dynamicChildrenByScene[_scene] = new Vector.<ISceneObjectRenderable>();
				}
				s_dynamicChildrenByScene[_scene].push( _child );
			}
			_child.onStaticChanged.add( onStaticChange );
			
		}
		
		private function onStaticChange( _scn:Event ):void{
			var _child:ISceneObjectRenderable = _scn as ISceneObjectRenderable;
			if( _child.isStatic )
			{
				_child.geometry.axisAlignedBoundingBox.update( SceneObjectRenderable(_child).YOGURT3D_INTERNAL::m_transformation.matrixGlobal );
				_child.geometry.boundingSphere.YOGURT3D_INTERNAL::m_center =  SceneObjectRenderable(_child).geometry.axisAlignedBoundingBox.center;
				
				s_quadByScene[_child.scene].insert(_child);
				_removeChildFromDynamicList( _child, _child.scene );
			}else{
				s_quadByScene[_child.scene].removeItem(_child);
				
				if( s_dynamicChildrenByScene[_child.scene ] == null )
				{
					s_dynamicChildrenByScene[_child.scene] = new Vector.<ISceneObjectRenderable>();
				}
				s_dynamicChildrenByScene[_child.scene].push( _child );
			}
		}
		
		public function getSceneRenderableSet(_scene:IScene, _camera:ICamera):Vector.<ISceneObjectRenderable>
		{
			var temp :Vector3D;
			
			var camera:ICamera =  _camera;
			
			if( s_quadByScene[_scene] != null && s_dynamicChildrenByScene[_scene] != null )
			{
				camera.frustum.extractPlanes(camera.transformation);
				
				temp = camera.transformation.matrixGlobal.transformVector(camera.frustum.m_bSCenterOrginal);
				
				camera.frustum.boundingSphere.YOGURT3D_INTERNAL::m_center = temp;
				
				s_quadByScene[_scene].visibilityProcess( _camera );
				
				var remove:Array = [];
				var len:uint = s_quadByScene[_scene].list.length;
				for( var i:int = 0; i < len; i++ )
				{
					var item:ISceneObjectRenderable = s_quadByScene[_scene].list[i];
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
					s_quadByScene[_scene].list.splice( remove[i], 1 );
				}
				
				return s_dynamicChildrenByScene[_scene].concat( s_quadByScene[_scene].list );
			}else if( s_quadByScene[_scene] )
			{
				camera.frustum.extractPlanes(camera.transformation);
				
				temp = camera.transformation.matrixGlobal.transformVector(camera.frustum.m_bSCenterOrginal);
				
				camera.frustum.boundingSphere.YOGURT3D_INTERNAL::m_center = temp;
				
				s_quadByScene[_scene].visibilityProcess( _camera );
				
				return s_quadByScene[_scene].list;
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
				s_quadByScene[_scene].removeItem(_child);
			}else{
				_removeChildFromDynamicList( _child, _scene );
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
		
	}
}