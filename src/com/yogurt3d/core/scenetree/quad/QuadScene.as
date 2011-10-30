package com.yogurt3d.core.scenetree.quad
{
	import com.yogurt3d.core.sceneobjects.Scene;
	
	public class QuadScene extends Scene
	{
		public function QuadScene( minX:Number, minZ:Number, maxX:Number, maxZ:Number,  _initInternals:Boolean=true)
		{
			var args:Object = new Object();
			args["x"] = minX;
			args["z"] = minZ;
			args["width"] = maxX - minX;
			args["height"] = maxZ - minZ;
			super("QuadSceneTreeManagerDriver", args, _initInternals);
		}
	}
}