package com.yogurt3d.core.scenetree.simple
{
	import com.yogurt3d.core.plugin.Driver;
	import com.yogurt3d.core.scenetree.IRenderableManager;
	import com.yogurt3d.core.scenetree.SceneTreeManagerDriver;
	
	public class SimpleSceneTreeManagerDriver extends SceneTreeManagerDriver
	{
		public function SimpleSceneTreeManagerDriver()
		{
			super();
		}
		public override function get name():String{
			return "SimpleSceneTreeManagerDriver";
		}
		public override function createTreeManager():IRenderableManager{
			return new SimpleSceneTreeManager();
		}
	}
}