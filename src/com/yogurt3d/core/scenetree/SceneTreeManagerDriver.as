package com.yogurt3d.core.scenetree
{
	import com.yogurt3d.core.plugin.Driver;

	public class SceneTreeManagerDriver extends Driver
	{
		public override function get name():String{
			throw new Error("This is an abstract driver.");
		}
		
		public function createTreeManager():IRenderableManager{
			throw new Error("This function must be overriden by your driver.");
			return null;
		}
	}
}