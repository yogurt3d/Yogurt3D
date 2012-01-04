package com.yogurt3d.core.scenetree
{
	import com.yogurt3d.core.cameras.interfaces.ICamera;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObject;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	import com.yogurt3d.core.managers.scenetreemanager.SceneTreeManager;
	
	import flash.utils.Dictionary;
	
	public interface IRenderableManager
	{
		function addChild(_child:ISceneObjectRenderable, _scene:IScene, index:int = -1):void;
		function removeChildFromTree(_child:ISceneObjectRenderable, _scene:IScene):void;
		function getSceneRenderableSet(_scene:IScene, _camera:ICamera):Vector.<ISceneObjectRenderable>;
		function getSceneRenderableSetLight(_scene:IScene, _light:Light, lightIndex:int):Vector.<ISceneObjectRenderable>;
		function getIlluminatorLightIndexes(_scene:IScene, _objectRenderable:ISceneObjectRenderable):Vector.<int>;
		function clearIlluminatorLightIndexes(_scene:IScene, _objectRenderable:ISceneObjectRenderable):void;
		function getListOfVisibilityTesterByScene():Dictionary;
	}
}