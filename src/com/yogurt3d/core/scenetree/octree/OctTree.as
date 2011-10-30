/*
* OctTree.as
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
	
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.cameras.Frustum;
	import com.yogurt3d.core.cameras.interfaces.ICamera;
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	public class OctTree
	{
		public var m_root:OctNode;
		
		public var m_maxDepth:int;
		
		public var list:Vector.<ISceneObjectRenderable> = new Vector.<ISceneObjectRenderable>(1500);
		public var listlength:int = 0;
		
		public var sceneObjectToOctant:Dictionary;
		
		public function OctTree( _bound:AxisAlignedBoundingBox, _maxDepth:int = 4 )
		{
			m_root = new OctNode(null);
			
			m_maxDepth = _maxDepth;
			
			m_root.m_box = _bound;
			
			sceneObjectToOctant = new Dictionary();
			
		}
		
		public function insert( octant:ISceneObjectRenderable ):void
		{
			var oct:Octant = new Octant(octant);
			sceneObjectToOctant[octant] = oct;
			_insert( oct, m_root, 0 );
		}
		
		private function _insert( octant:Octant, node:OctNode, depth:int = 0 ):void
		{
			if ( ( depth < m_maxDepth ) && node.isTwiceSize( octant.m_box ) )//nod depth
			{
				var indexes:Vector.<int> = new Vector.<int>(3, true);
				
				node.getIndexes( octant.m_box, indexes );
				
				if ( node.nodes[ indexes[0] ][ indexes[1] ][ indexes[2] ] == null )
				{
					node.nodes[ indexes[0] ][ indexes[1] ][ indexes[2] ] = new OctNode(node);//****
					node.m_numNodes++;
					
					var nodeMin:Vector3D = node.m_box.min;
					
					var nodeMax:Vector3D = node.m_box.max;
					
					var min:Vector3D = new Vector3D;
					var max:Vector3D = new Vector3D;
					
					if ( indexes[0] == 0 )
					{
						min.x = nodeMin.x;
						max.x = ( nodeMin.x + nodeMax.x ) / 2;
					}
					else
					{
						min.x = ( nodeMin.x + nodeMax.x ) / 2;
						max.x = nodeMax.x;
					}
					
					if ( indexes[1] == 0 )
					{
						min.y = nodeMin.y;
						max.y = ( nodeMin.y + nodeMax.y ) / 2;
					}
					else
					{
						min.y = ( nodeMin.y + nodeMax.y ) / 2;
						max.y = nodeMax.y;
					}
					
					if ( indexes[2] == 0 )
					{
						min.z = nodeMin.z;
						max.z = ( nodeMin.z + nodeMax.z ) / 2;
					}
					else
					{
						min.z = ( nodeMin.z + nodeMax.z ) / 2;
						max.z = nodeMax.z;
					}
					
					OctNode(node.nodes[ indexes[0] ][ indexes[1] ][ indexes[2] ]).m_box = new AxisAlignedBoundingBox( min, max, true );//true for debug
					
					
				}
				
				_insert(octant, node.nodes[ indexes[0] ][ indexes[1] ][ indexes[2] ], ++depth );
				node.m_sumChildren++;
			}
				
			else
			{
				node.children.push( octant );
				// TODO Yagmur: parent Node??
				//octant.m_parentNode = node;
				node.m_sumChildren++;
			}
		}
		
		
		public function remove(sceneObject:ISceneObjectRenderable):void
		{
			var octant:Octant = sceneObjectToOctant[sceneObject];
			if( octant )
			{
				var array:Vector.<Octant> = octant.m_parentNode.children;//dynamic
				array.splice(array.indexOf(octant),1);
				var parent:OctNode = octant.m_parentNode;
				while(parent)
				{
					parent.m_sumChildren--;
					parent = parent.m_parent;
					
				}
				octant.m_parentNode = null;
				delete sceneObjectToOctant[ sceneObject ];
			}
			
		}
		
		public function visibilityProcess( camera:ICamera ):void{
			listlength = 0;
			list.length = 0;
			
			_visibilityProcess(camera, m_root, true);
		}
		
		// recursive
		private function _visibilityProcess( camera:ICamera, node:OctNode, bTestChildren:Boolean) :void
		{		
			var i:int;
			
			
			if(bTestChildren) 
			{
				switch( camera.frustum.containmentTestOctant(node.m_box.size, node.m_box.center) ) 
				{
					case (Frustum.OUT):
						return;
					case (Frustum.IN):
						var lena:int = node.children.length;
						if(lena > 0)
						{
							for(i = 0; i < lena; i++)
							{
								list[listlength] = node.children[i].sceneObject;
								listlength++;
							}
						}
						bTestChildren = false;
						break;
					case (Frustum.INTERSECT):
						//manually test for each item
						//or do not test-
						var len:int = node.children.length;
						if(len > 0)
						{
							for(i = 0; i < len; i++)
							{
								if( camera.frustum.containmentTestOctant(node.children[i].m_box.halfSize, 
									node.children[i].m_box.center) == Frustum.OUT )
								{
									continue;
								}
								list[listlength] = node.children[i].sceneObject;
								listlength++;
							}
							
						}
						break;
				}
			}else
			{
				var lenb:int = node.children.length;
				if(lenb > 0)
				{
					for(i = 0; i < lenb; i++)
					{
						list[listlength] = node.children[i].sceneObject;
						listlength++;
					}
				}
			}
			
			
			
			var childNode:OctNode;
			if(node.m_numNodes)
			{
				var tmpN1:Array = node.nodes[ 0 ];
				var tmpN2:Array = node.nodes[ 1 ];
				
				if ( (childNode = tmpN1[ 0 ][ 0 ]) != null && childNode.m_sumChildren)
					_visibilityProcess( camera, childNode, bTestChildren);
				
				if ( (childNode = tmpN2[ 0 ][ 0 ]) != null && childNode.m_sumChildren)
					_visibilityProcess( camera, childNode, bTestChildren);
				
				if ( (childNode = tmpN1[ 1 ][ 0 ]) != null && childNode.m_sumChildren)
					_visibilityProcess( camera, childNode, bTestChildren);
				
				if ( (childNode = tmpN2[ 1 ][ 0 ]) != null && childNode.m_sumChildren)
					_visibilityProcess( camera, childNode, bTestChildren);
				
				if ( (childNode = tmpN1[ 0 ][ 1 ]) != null && childNode.m_sumChildren)
					_visibilityProcess( camera, childNode, bTestChildren);
				
				if ( (childNode = tmpN2[ 0 ][ 1 ]) != null && childNode.m_sumChildren)
					_visibilityProcess( camera, childNode, bTestChildren);
				
				if ( (childNode = tmpN1[ 1 ][ 1 ]) != null && childNode.m_sumChildren)
					_visibilityProcess( camera, childNode, bTestChildren);
				
				if ( (childNode = tmpN2[ 1 ][ 1 ]) != null && childNode.m_sumChildren)
					_visibilityProcess( camera, childNode, bTestChildren);
			}
		}
		
	}
}