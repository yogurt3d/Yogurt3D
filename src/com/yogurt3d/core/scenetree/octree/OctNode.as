/*
* OctNode.as
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
	
	public class OctNode
	{
		public var m_box:AxisAlignedBoundingBox;
		
		public var m_sumChildren:int;
		public var m_numNodes:int;
		public var nodes:Array = new Array(null,null);
		public var m_parent:OctNode = null;
		
		public var children:Vector.<Octant> = new Vector.<Octant>();
		//public var childrenDynamic:Vector.<ISceneObjectRenderable> = new Vector.<ISceneObjectRenderable>();
		
		
		public function OctNode(parent:OctNode)
		{
			for(var x:int = 0; x < 2; x++)
			{
				nodes[x] = new Array(null, null);
				for(var y:int = 0; y < 2; y++)
					nodes[x][y] = new Array(null,null);
			}
			m_sumChildren = 0;
			m_numNodes = 0;
			m_parent = parent;
		}
		
		
		
		
		public function isTwiceSize( boxOfOctant:AxisAlignedBoundingBox ):Boolean
		{
			var boxSize:Vector3D =  boxOfOctant.max.subtract(boxOfOctant.min);
			
			return ((boxSize.x <= m_box.halfSize.x) && (boxSize.y <= m_box.halfSize.y) && (boxSize.z <= m_box.halfSize.z));
		}
		
		
		public function getIndexes( boxOfOctant:AxisAlignedBoundingBox, indexes:Vector.<int> ):void
		{
			if ( boxOfOctant.center.x > m_box.center.x )
				indexes[0] = 1;
			else
				indexes[0] = 0;
			
			if ( boxOfOctant.center.y > m_box.center.y )
				indexes[1] = 1;
			else
				indexes[1] = 0;
			
			if ( boxOfOctant.center.z > m_box.center.z )
				indexes[2] = 1;
			else
				indexes[2] = 0;			
		}
		
		public function containsOctant( octant:Octant ):Boolean
		{
			if ( !(( m_box.max.x > octant.m_box.center.x && m_box.max.y > octant.m_box.center.y && 
				m_box.max.z > octant.m_box.center.z  ) && ( m_box.min.x < octant.m_box.center.x  
					&& m_box.min.y < octant.m_box.center.y && m_box.min.x < octant.m_box.center.x)) )
			{
				return false;
			}
			//isTwiceSize can be ignored 
			//the other test is for main size comparison of loose octree ,can be made between actual sizes (not half sizes)
			return (!(isTwiceSize(octant.m_box)) && ( octant.m_box.halfSize.x < m_box.halfSize.x 
				&& octant.m_box.halfSize.y < m_box.halfSize.y && octant.m_box.halfSize.z < m_box.halfSize.z));
		}
		
		
	}
}