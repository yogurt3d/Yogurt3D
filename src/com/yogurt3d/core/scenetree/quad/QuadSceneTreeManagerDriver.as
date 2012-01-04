package com.yogurt3d.core.scenetree.quad
{
	import com.yogurt3d.core.scenetree.IRenderableManager;
	import com.yogurt3d.core.scenetree.SceneTreeManagerDriver;
	
	public class QuadSceneTreeManagerDriver extends com.yogurt3d.core.scenetree.SceneTreeManagerDriver
	{
		public function QuadSceneTreeManagerDriver()
		{
			super();
		}
		public override function get name():String{
			return "QuadSceneTreeManagerDriver";
		}
		public override function createTreeManager():com.yogurt3d.core.scenetree.IRenderableManager{
			return new QuadSceneTreeManager();
		}
	}
}