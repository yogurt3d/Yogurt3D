package com.yogurt3d.core.scenetree.quad
{
	import com.yogurt3d.core.scenetree.IRenderableManager;
	import com.yogurt3d.core.scenetree.SceneTreeManagerDriver;
	
	public class QuadSceneTreeManagerDriver extends SceneTreeManagerDriver
	{
		public function QuadSceneTreeManagerDriver()
		{
			super();
		}
		public override function get name():String{
			return "QuadSceneTreeManagerDriver";
		}
		public override function createTreeManager():IRenderableManager{
			return new QuadSceneTreeManager();
		}
	}
}