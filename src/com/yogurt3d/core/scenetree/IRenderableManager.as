package com.yogurt3d.core.scenetree
{
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObject;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;

	public interface IRenderableManager
	{
		function addChild(_child:ISceneObjectRenderable, _scene:IScene, index:int = -1):void;
		function removeChild(_child:ISceneObjectRenderable, _scene:IScene):void;
		function getSceneRenderableSet(_scene:IScene):Vector.<ISceneObjectRenderable>;
	}
}