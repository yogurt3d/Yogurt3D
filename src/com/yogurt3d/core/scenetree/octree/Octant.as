/*
* Octant.as
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
	import com.yogurt3d.core.helpers.boundingvolumes.*;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	
	import flash.geom.Vector3D;
	
	public class Octant
	{
        public var m_box:AxisAlignedBoundingBox;

		public var m_isUpdated:Boolean;

		public var m_parentNode:OctNode = null;
		
		public var sceneObject:ISceneObjectRenderable;
		
		public function Octant(sceneObject:ISceneObjectRenderable)
		{
			this.sceneObject = sceneObject;
			m_box = sceneObject.axisAlignedBoundingBox;
		}

	}
}