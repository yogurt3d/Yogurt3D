package com.yogurt3d.core.scenetree.simple
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.managers.scenetreemanager.SceneTreeManager;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.scenetree.IRenderableManager;
	
	import flash.utils.Dictionary;
	
	public class SimpleSceneTreeManager implements IRenderableManager
	{
		private static var s_renderableObjectsByScene		:Dictionary;
		
		public function SimpleSceneTreeManager()
		{
			if( s_renderableObjectsByScene == null )
			{
				s_renderableObjectsByScene = new Dictionary(true);
			}
		}
		
		public function addChild(_child:SceneObjectRenderable, _scene:IScene, index:int=-1):void
		{
			var _renderableObjectsByScene :Vector.<SceneObjectRenderable> = s_renderableObjectsByScene[_scene];
			
			if(!_renderableObjectsByScene)
			{
				_renderableObjectsByScene			= new Vector.<SceneObjectRenderable>();
				s_renderableObjectsByScene[_scene]	= _renderableObjectsByScene;
				
			}
			if( index == -1 )
			{
				_renderableObjectsByScene[_renderableObjectsByScene.length] = _child;
			}else{
				_renderableObjectsByScene.splice( index, 0, _child );
			}
		}
		
		public function removeChildFromTree(_child:SceneObjectRenderable, _scene:IScene):void
		{
			var _renderableObjectsByScene 	:Vector.<SceneObjectRenderable>	= s_renderableObjectsByScene[_scene];
			var _index						:int								= _renderableObjectsByScene.indexOf(_child);
			
			if(_index != -1)
			{
				_renderableObjectsByScene.splice(_index, 1);
			}
			
			if(_renderableObjectsByScene.length == 0)
			{
				s_renderableObjectsByScene[_scene] = null;
			}
		}
		
		public function getSceneRenderableSet(_scene:IScene, _camera:Camera):Vector.<SceneObjectRenderable>
		{
			return s_renderableObjectsByScene[_scene];
		}
		
		public function getSceneRenderableSetLight(_scene:IScene, _light:Light, lightIndex:int):Vector.<SceneObjectRenderable>
		{
			return s_renderableObjectsByScene[_scene];
		}
		
		
		public function getIlluminatorLightIndexes(_scene:IScene, _objectRenderable:SceneObjectRenderable):Vector.<int>
		{
			return SceneTreeManager.s_sceneLightIndexes[_scene];
		}
		
		public function clearIlluminatorLightIndexes(_scene:IScene, _objectRenderable:SceneObjectRenderable):void
		{
		}
		
		public function getListOfVisibilityTesterByScene():Dictionary{
			return null;
		}
	}
}