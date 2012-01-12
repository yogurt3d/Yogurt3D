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
	import com.yogurt3d.core.frustum.Frustum;
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.managers.scenetreemanager.SceneTreeManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	use namespace YOGURT3D_INTERNAL;
	
	public class OctTree
	{
		public var m_root:OctNode;
		
		public var m_maxDepth:int;
		public var preAllocateNodes:Boolean;
		public var list:Vector.<SceneObjectRenderable>;
		public var listlength:int = 0;
		

		
		public var sceneObjectToOctant:Dictionary;
		
		public function OctTree( _bound:AxisAlignedBoundingBox, _maxDepth:int = 3, _preAllocateNodes:Boolean = true )
		{
			m_root = new OctNode(null);
			
			m_maxDepth = _maxDepth;
			
			m_root.m_min = _bound.minGlobal;
			
			m_root.m_max = _bound.maxGlobal;
			
			m_root.m_looseMin = _bound.minGlobal;
			
			m_root.m_looseMax = _bound.maxGlobal;
			
			m_root.m_center = m_root.m_max.add( m_root.m_min );
			
			m_root.m_center.scaleBy(.5);
			
			m_root.m_testSizeVector = m_root.m_max.subtract( m_root.m_min );
			
			m_root.m_testSizeVector.scaleBy(.5);
			
			m_root.m_halfSizeVector = new Vector3D(m_root.m_testSizeVector.x, m_root.m_testSizeVector.y, m_root.m_testSizeVector.z);
			
			m_root.m_testSizeVectorLength = m_root.m_testSizeVector.length;
			
			preAllocateNodes = _preAllocateNodes;
			
			if(preAllocateNodes)
				_allocateNodes(m_root);
			
			sceneObjectToOctant = new Dictionary();
			
		}
		
		public function insert( octant:SceneObjectRenderable ):void
		{
			var oct:Octant = new Octant(octant);
			sceneObjectToOctant[octant] = oct;
			_insert( oct, m_root, 0 );
		}
		
		private function _allocateNodes( node:OctNode, depth:int = 0 ):void
		{
			
			var nodeMin:Vector3D = node.m_min;
			var nodeMax:Vector3D = node.m_max;
			
			if ( depth < m_maxDepth )
			{
				for(var i:int = 0; i < 8; i++)
				{
					var min:Vector3D = new Vector3D;
					var max:Vector3D = new Vector3D;
					
					switch(i)
					{
						case 0:
							min.x = nodeMin.x;
							max.x = ( nodeMin.x + nodeMax.x ) * 0.5;
							min.y = nodeMin.y;
							max.y = ( nodeMin.y + nodeMax.y ) * 0.5;
							min.z = nodeMin.z;
							max.z = ( nodeMin.z + nodeMax.z ) * 0.5;
							break;
						case 1:
							min.x = nodeMin.x;
							max.x = ( nodeMin.x + nodeMax.x ) * 0.5;
							min.y = nodeMin.y;
							max.y = ( nodeMin.y + nodeMax.y ) * 0.5;
							min.z = ( nodeMin.z + nodeMax.z ) * 0.5;
							max.z = nodeMax.z;
							break;
						case 2:
							min.x = ( nodeMin.x + nodeMax.x ) * 0.5;
							max.x = nodeMax.x;
							min.y = nodeMin.y;
							max.y = ( nodeMin.y + nodeMax.y ) * 0.5;
							min.z = nodeMin.z;
							max.z = ( nodeMin.z + nodeMax.z ) * 0.5;
							break;
						case 3:
							min.x = ( nodeMin.x + nodeMax.x ) * 0.5;
							max.x = nodeMax.x;
							min.y = nodeMin.y;
							max.y = ( nodeMin.y + nodeMax.y ) * 0.5;
							min.z = ( nodeMin.z + nodeMax.z ) * 0.5;
							max.z = nodeMax.z;
							break;
						case 4:
							min.x = nodeMin.x;
							max.x = ( nodeMin.x + nodeMax.x ) * 0.5;
							min.y = ( nodeMin.y + nodeMax.y ) * 0.5;
							max.y = nodeMax.y;
							min.z = nodeMin.z;
							max.z = ( nodeMin.z + nodeMax.z ) * 0.5;
							break;
						case 5:
							min.x = nodeMin.x;
							max.x = ( nodeMin.x + nodeMax.x ) * 0.5;
							min.y = ( nodeMin.y + nodeMax.y ) * 0.5;
							max.y = nodeMax.y;
							min.z = ( nodeMin.z + nodeMax.z ) * 0.5;
							max.z = nodeMax.z;
							break;
						case 6:
							min.x = ( nodeMin.x + nodeMax.x ) * 0.5;
							max.x = nodeMax.x;
							min.y = ( nodeMin.y + nodeMax.y ) * 0.5;
							max.y = nodeMax.y;
							min.z = nodeMin.z;
							max.z = ( nodeMin.z + nodeMax.z ) * 0.5;
							break;
						case 7:
							min.x = ( nodeMin.x + nodeMax.x ) * 0.5;
							max.x = nodeMax.x;
							min.y = ( nodeMin.y + nodeMax.y ) * 0.5;
							max.y = nodeMax.y;
							min.z = ( nodeMin.z + nodeMax.z ) * 0.5;
							max.z = nodeMax.z;
							break;
					}
					
					node.m_numNodes++;
					
					node.nodes[ i ] = new OctNode(node);
					var octNode:OctNode = node.nodes[ i ];
					
					octNode.m_center = max.add( min );
					octNode.m_center.scaleBy(.5);
					octNode.m_testSizeVector = max.subtract(min);
					octNode.m_halfSizeVector = new Vector3D(octNode.m_testSizeVector.x*0.5, octNode.m_testSizeVector.y*0.5, octNode.m_testSizeVector.z*0.5);
					octNode.m_max = max;
					octNode.m_min = min;
					octNode.m_looseMax = max.add(octNode.m_halfSizeVector);
					octNode.m_looseMin = min.subtract(octNode.m_halfSizeVector);
					octNode.m_testSizeVectorLength = octNode.m_testSizeVector.length;
					
					_allocateNodes( octNode, depth+1 );
				}
			}
		}
		
		
		
		private function _insert( octant:Octant, node:OctNode, depth:int = 0 ):void
		{
			if ( ( depth < m_maxDepth ) && node.isTwiceSize( octant.sceneObject.axisAlignedBoundingBox) )//nod depth
			{
				var indexX:int = 0;
				var indexY:int = 0;
				var indexZ:int = 0;
				
				var nodeBoxCenter:Vector3D = node.m_center;
				var octantBoxCenter:Vector3D = octant.sceneObject.axisAlignedBoundingBox.centerGlobal;
				
				//get indexes
				if ( octantBoxCenter.x > nodeBoxCenter.x )
					indexX = 2;
				
				
				if ( octantBoxCenter.y > nodeBoxCenter.y )
					indexY = 4;
				
				
				if ( octantBoxCenter.z > nodeBoxCenter.z )
					indexZ = 1;
				
				var index:int = indexX+indexY+indexZ;
				
				var octNode:OctNode = node.nodes[ index ];
				
				if ( !preAllocateNodes && octNode == null )
				{
					node.nodes[ index ] = new OctNode(node);
					
					octNode = node.nodes[ index ];
					
					node.m_numNodes++;
					
					var nodeMin:Vector3D = node.m_min;
					
					var nodeMax:Vector3D = node.m_max;
					
					var min:Vector3D = new Vector3D;
					var max:Vector3D = new Vector3D;
					
					if ( indexX == 0 )
					{
						min.x = nodeMin.x;
						max.x = ( nodeMin.x + nodeMax.x ) * 0.5;
					}
					else
					{
						min.x = ( nodeMin.x + nodeMax.x ) * 0.5;
						max.x = nodeMax.x;
					}
					
					if ( indexY == 0 )
					{
						min.y = nodeMin.y;
						max.y = ( nodeMin.y + nodeMax.y ) * 0.5;
					}
					else
					{
						min.y = ( nodeMin.y + nodeMax.y ) * 0.5;
						max.y = nodeMax.y;
					}
					
					if ( indexZ == 0 )
					{
						min.z = nodeMin.z;
						max.z = ( nodeMin.z + nodeMax.z ) * 0.5;
					}
					else
					{
						min.z = ( nodeMin.z + nodeMax.z ) * 0.5;
						max.z = nodeMax.z;
					}

					octNode.m_center = max.add( min );
					octNode.m_center.scaleBy(.5);
					octNode.m_testSizeVector = max.subtract(min);
					octNode.m_halfSizeVector = new Vector3D(octNode.m_testSizeVector.x*0.5, octNode.m_testSizeVector.y*0.5, octNode.m_testSizeVector.z*0.5);
					octNode.m_max = max;
					octNode.m_min = min;
					octNode.m_looseMax = max.add(octNode.m_halfSizeVector);
					octNode.m_looseMin = min.subtract(octNode.m_halfSizeVector);
					octNode.m_testSizeVectorLength = octNode.m_testSizeVector.length;
					
					
					
				}
				
				_insert(octant, octNode, ++depth );
				node.m_sumChildren++;
			}
				
			else
			{
				node.children.push( octant );
				octant.m_parentNode = node;
				node.m_sumChildren++;
			}
		}
		
		
		public function updateTree(childrenDynamic:Vector.<SceneObjectRenderable> ):void
		{
			var len:int = childrenDynamic.length;
			var octant:Octant;
			for(var i:int = 0; i < len; i++)
			{
				var scn:SceneObjectRenderable = childrenDynamic.pop();
				scn.transformation.m_isAddedToSceneRefreshList = false;
				octant = sceneObjectToOctant[scn];
				
				if(octant && !octant.isInParent())
				{
					removeFromNode( scn );
					_insert(octant, m_root);
				}
			}
		}
		
		
		public function removeFromNode(sceneObject:SceneObjectRenderable):void
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
				parent = null;

			}
			
		}
		
		public function visibilityProcess( camera:Camera):void{
			listlength = 0;
			list.length = 0;
			
			
			_visibilityProcess(camera.frustum, m_root, true);
		}
		
		
		public function visibilityProcessLight( light:Light, lightIndex:int, _scene:IScene):void{
			listlength = 0;
			list.length = 0;
			
			_visibilityProcessLight(light.frustum, m_root, true, lightIndex, _scene);
		}
		
		
		// recursive
		private function _visibilityProcess( frustum:Frustum, node:OctNode, bTestChildren:Boolean) :void
		{		
			var i:int;
			
			var octantSceneObject:SceneObjectRenderable;
			var axis:AxisAlignedBoundingBox;
			
			if(bTestChildren) 
			{
				//if(!frustum.boundingSphere.intersectTestSphereParam(node.m_center, node.m_testSizeVectorLength))
					//return;
				
				switch( frustum.containmentTestOctant(node.m_testSizeVector, node.m_center) ) 
				{
					case (Frustum.OUT):
						return;
					case (Frustum.IN):
						var lena:int = node.children.length;
						if(lena > 0)
						{
							for(i = 0; i < lena; i++)
							{
								octantSceneObject = node.children[i].sceneObject;
								octantSceneObject.m_isInFrustum = true;
								list[listlength] = octantSceneObject;
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

								octantSceneObject = node.children[i].sceneObject;
								axis = octantSceneObject.axisAlignedBoundingBox;
								
								//if(!frustum.boundingSphere.intersectTestSphereParam(axis.center, oct.sceneObject.boundingSphere.m_radius))
									//continue;
								if( frustum.containmentTestOctant(axis.halfSizeGlobal, axis.centerGlobal) == 0 /*Frustum.OUT */)
								{
									continue;
								}
								octantSceneObject.m_isInFrustum = true;
								list[listlength] = octantSceneObject;
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
						octantSceneObject = node.children[i].sceneObject;
						octantSceneObject.m_isInFrustum = true;
						
						list[listlength] = octantSceneObject;
						listlength++;
					}
				}
			}
			
			
			
			var childNode:OctNode;
			var nodesOfNode:Vector.<OctNode> = node.nodes;
			
			if(node.m_numNodes)
			{
				if ( (childNode = nodesOfNode[0]) != null && childNode.m_sumChildren)
					_visibilityProcess( frustum, childNode, bTestChildren);
				
				if ( (childNode = nodesOfNode[1]) != null && childNode.m_sumChildren)
					_visibilityProcess( frustum, childNode, bTestChildren);
				
				if ( (childNode = nodesOfNode[2] )!= null && childNode.m_sumChildren)
					_visibilityProcess( frustum, childNode, bTestChildren);
				
				if ( (childNode = nodesOfNode[3])!= null && childNode.m_sumChildren)
					_visibilityProcess( frustum, childNode, bTestChildren);
				
				if ( (childNode = nodesOfNode[4] )!= null && childNode.m_sumChildren)
					_visibilityProcess( frustum, childNode, bTestChildren);
				
				if ( (childNode = nodesOfNode[5])!= null && childNode.m_sumChildren)
					_visibilityProcess( frustum, childNode, bTestChildren);
				
				if ( (childNode = nodesOfNode[6] )!= null && childNode.m_sumChildren)
					_visibilityProcess( frustum, childNode, bTestChildren);
				
				if ( (childNode = nodesOfNode[7] )!= null && childNode.m_sumChildren)
					_visibilityProcess( frustum, childNode, bTestChildren);
			}
		}
		
		// recursive
		private function _visibilityProcessLight( frustum:Frustum, node:OctNode, bTestChildren:Boolean, lightIndex:int, _scene:IScene) :void
		{		
			var i:int;
			
			var octantSceneObject:SceneObjectRenderable;
			var axis:AxisAlignedBoundingBox;
			
			if(bTestChildren) 
			{
				var result:int;
				
				if(frustum.sphereCheck)
					result = frustum.boundingSphere.intersectTestAABB(node.m_looseMin, node.m_looseMax);
				else
					result = frustum.containmentTestOctant(node.m_testSizeVector, node.m_center);
				
				switch( result ) 
				{
					case (Frustum.OUT):
						return;
					case (Frustum.IN):
						var lena:int = node.children.length;
						if(lena > 0)
						{
							for(i = 0; i < lena; i++)
							{
								octantSceneObject = node.children[i].sceneObject;
								if(octantSceneObject.m_isInFrustum)
									SceneTreeManager.s_renSetIlluminatorLightIndexes[_scene][octantSceneObject].push(lightIndex);
								
								list[listlength] = octantSceneObject;
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
								octantSceneObject = node.children[i].sceneObject;
								axis = octantSceneObject.axisAlignedBoundingBox;
								if(frustum.sphereCheck)
								{
									if(frustum.boundingSphere.intersectTestAABB(axis.minGlobal, axis.maxGlobal) == Frustum.OUT)
										continue;
									
								}
								else
								{
									if(frustum.containmentTestOctant(axis.halfSizeGlobal, axis.centerGlobal) == Frustum.OUT)
										continue;
								}
								
								if(octantSceneObject.m_isInFrustum)
									SceneTreeManager.s_renSetIlluminatorLightIndexes[_scene][octantSceneObject].push(lightIndex);
								
								list[listlength] = octantSceneObject;
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
						octantSceneObject = node.children[i].sceneObject;
						if(octantSceneObject.m_isInFrustum)
							SceneTreeManager.s_renSetIlluminatorLightIndexes[_scene][octantSceneObject].push(lightIndex);
						
						list[listlength] = octantSceneObject;
						listlength++;
					}
				}
			}
			
			
			
			var childNode:OctNode;
			var nodesOfNode:Vector.<OctNode> = node.nodes;
			if(node.m_numNodes)
			{
				if ( (childNode = nodesOfNode[0]) != null && childNode.m_sumChildren)
					_visibilityProcessLight( frustum, childNode, bTestChildren, lightIndex, _scene);
				
				if ( (childNode = nodesOfNode[1]) != null && childNode.m_sumChildren)
					_visibilityProcessLight( frustum, childNode, bTestChildren, lightIndex, _scene );
				
				if ( (childNode = nodesOfNode[2] )!= null && childNode.m_sumChildren)
					_visibilityProcessLight( frustum, childNode, bTestChildren, lightIndex, _scene );
				
				if ( (childNode = nodesOfNode[3])!= null && childNode.m_sumChildren)
					_visibilityProcessLight( frustum, childNode, bTestChildren, lightIndex, _scene);
				
				if ( (childNode = nodesOfNode[4] )!= null && childNode.m_sumChildren)
					_visibilityProcessLight( frustum, childNode, bTestChildren, lightIndex, _scene );
				
				if ( (childNode = nodesOfNode[5])!= null && childNode.m_sumChildren)
					_visibilityProcessLight( frustum, childNode, bTestChildren, lightIndex, _scene);
				
				if ( (childNode = nodesOfNode[6] )!= null && childNode.m_sumChildren)
					_visibilityProcessLight( frustum, childNode, bTestChildren, lightIndex, _scene );
				
				if ( (childNode = nodesOfNode[7] )!= null && childNode.m_sumChildren)
					_visibilityProcessLight( frustum, childNode, bTestChildren, lightIndex, _scene );
					
			}
		}
		
	}
}