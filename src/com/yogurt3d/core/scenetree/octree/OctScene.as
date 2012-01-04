/*
* OctScene.as
* This file is part of Yogurt3D Flash Rendering Engine 
*
* Copyright (C) 2011 - Yogurt3D Corp.
*
* Yogurt3D Flash Rendering Engine is free software; you can redistribute it and/or
* modify it under the terms of the YOGURT3D CLICK-THROUGH AGREEMENT
* License.
* 
* Yogurt3D Flash Rendering Engine is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
* 
* You should have received a copy of the YOGURT3D CLICK-THROUGH AGREEMENT
* License along with this library. If not, see <http://www.yogurt3d.com/yogurt3d/downloads/yogurt3d-click-through-agreement.html>. 
*/
package com.yogurt3d.core.scenetree.octree
{
	import com.yogurt3d.core.sceneobjects.Scene;
	
	public class OctScene extends Scene
	{
		public function OctScene( minX:Number, minY:Number, minZ:Number, maxX:Number,maxY:Number, maxZ:Number, maxDepth:uint = 3, preAllocateNodes:Boolean = true,  _initInternals:Boolean=true)
		{
			var args:Object = new Object();
			args["x"] = minX;
			args["y"] = minY;
			args["z"] = minZ;
			args["width"] = maxX;
			args["height"] = maxY;
			args["depth"] = maxZ;
			args["maxDepth"] = maxDepth;
			args["preAllocateNodes"] = preAllocateNodes;
			super("OcSceneTreeManagerDriver", args, _initInternals);
		}
	}
}