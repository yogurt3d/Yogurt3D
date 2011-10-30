package com.yogurt3d.core.scenetree.simple
{
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObject;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
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
		
		public function addChild(_child:ISceneObjectRenderable, _scene:IScene, index:int=-1):void
		{
			var _renderableObjectsByScene :Vector.<ISceneObjectRenderable> = s_renderableObjectsByScene[_scene];
			
			if(!_renderableObjectsByScene)
			{
				_renderableObjectsByScene			= new Vector.<ISceneObjectRenderable>();
				s_renderableObjectsByScene[_scene]	= _renderableObjectsByScene;
			}
			if( index == -1 )
			{
				_renderableObjectsByScene[_renderableObjectsByScene.length] = _child;
			}else{
				_renderableObjectsByScene.splice( index, 0, _child );
			}
		}
		
		public function removeChild(_child:ISceneObjectRenderable, _scene:IScene):void
		{
			var _renderableObjectsByScene 	:Vector.<ISceneObjectRenderable>	= s_renderableObjectsByScene[_scene];
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
		
		public function getSceneRenderableSet(_scene:IScene):Vector.<ISceneObjectRenderable>
		{
			return s_renderableObjectsByScene[_scene];
		}
	}
}