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
package com.yogurt3d.core.scenetree.quad
{
	import com.yogurt3d.core.helpers.boundingvolumes.*;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	
	import flash.geom.Vector3D;
	
	public class Quadrant
	{
		public var m_parentNode:QuadNode = null;
		
		public var sceneObject:SceneObjectRenderable;
		
		public function Quadrant(sceneObject:SceneObjectRenderable)
		{
			this.sceneObject = sceneObject;
			
		}
		
		public function isInParent():Boolean
		{
			
			var parentNodeMax:Vector3D =  m_parentNode.m_looseMax;
			var parentNodeMin:Vector3D =  m_parentNode.m_looseMin;
			
			var quadrantMax:Vector3D =  sceneObject.axisAlignedBoundingBox.maxGlobal;
			var quadrantMin:Vector3D =  sceneObject.axisAlignedBoundingBox.minGlobal;
			
			if ( (  
					parentNodeMax.x > quadrantMax.x && 
					//parentNodeMax.y > quadrantMax.y && 
					parentNodeMax.z > quadrantMax.z  
				  ) && 
				 (  
					parentNodeMin.x < quadrantMin.x && 
					//parentNodeMin.y < quadrantMin.y && 
					parentNodeMin.z < quadrantMin.z  
				 ) 
			)
				return true;
			
			
			return false;
		}
	}
}