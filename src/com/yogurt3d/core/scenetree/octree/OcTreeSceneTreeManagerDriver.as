package com.yogurt3d.core.scenetree.octree
{
	import com.yogurt3d.core.scenetree.IRenderableManager;
	import com.yogurt3d.core.scenetree.SceneTreeManagerDriver;
	
	public class OcTreeSceneTreeManagerDriver extends com.yogurt3d.core.scenetree.SceneTreeManagerDriver
	{
		public function OcTreeSceneTreeManagerDriver()
		{
			super();
		}
		public override function get name():String{
			return "OcSceneTreeManagerDriver";
		}
		public override function createTreeManager():com.yogurt3d.core.scenetree.IRenderableManager{
			return new OcTreeSceneTreeManager();
		}
	}
}