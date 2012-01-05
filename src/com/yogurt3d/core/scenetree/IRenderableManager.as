package com.yogurt3d.core.scenetree
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.managers.scenetreemanager.SceneTreeManager;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	
	import flash.utils.Dictionary;
	
	public interface IRenderableManager
	{
		function addChild(_child:SceneObjectRenderable, _scene:IScene, index:int = -1):void;
		function removeChildFromTree(_child:SceneObjectRenderable, _scene:IScene):void;
		function getSceneRenderableSet(_scene:IScene, _camera:Camera):Vector.<SceneObjectRenderable>;
		function getSceneRenderableSetLight(_scene:IScene, _light:Light, lightIndex:int):Vector.<SceneObjectRenderable>;
		function getIlluminatorLightIndexes(_scene:IScene, _objectRenderable:SceneObjectRenderable):Vector.<int>;
		function clearIlluminatorLightIndexes(_scene:IScene, _objectRenderable:SceneObjectRenderable):void;
		function getListOfVisibilityTesterByScene():Dictionary;
	}
}