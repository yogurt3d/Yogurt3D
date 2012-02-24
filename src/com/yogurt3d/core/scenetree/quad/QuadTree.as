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
package com.yogurt3d.core.scenetree.quad
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
	
	public class QuadTree
	{
		public var m_root:QuadNode;
		
		public var m_maxDepth:int;
		public var preAllocateNodes:Boolean;
		public var list:Vector.<SceneObjectRenderable>;
		public var listlength:int = 0;
		

		
		public var sceneObjectToQuadrant:Dictionary;
		
		public function QuadTree( _bound:AxisAlignedBoundingBox, _maxDepth:int = 3, _preAllocateNodes:Boolean = true )
		{
			m_root = new QuadNode(null);
			
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
			
			sceneObjectToQuadrant = new Dictionary();
			
		}
		
		public function insert( quadrant:SceneObjectRenderable ):void
		{
			var quad:Quadrant = new Quadrant(quadrant);
			sceneObjectToQuadrant[quadrant] = quad;
			_insert( quad, m_root, 0 );
		}
		
		private function _allocateNodes( node:QuadNode, depth:int = 0 ):void
		{
			var nodeMin:Vector3D = node.m_min;
			var nodeMax:Vector3D = node.m_max;
			
			if ( depth < m_maxDepth )
			{
				for(var i:int = 0; i < 4; i++)
				{
					var min:Vector3D = new Vector3D;
					var max:Vector3D = new Vector3D;
					
					switch(i)
					{
						case 0:
							min.x = nodeMin.x;
							max.x = ( nodeMin.x + nodeMax.x ) * 0.5;
							min.z = nodeMin.z;
							max.z = ( nodeMin.z + nodeMax.z ) * 0.5;
							break;
						case 1:
							min.x = nodeMin.x;
							max.x = ( nodeMin.x + nodeMax.x ) * 0.5;
							min.z = ( nodeMin.z + nodeMax.z ) * 0.5;
							max.z = nodeMax.z;
							break;
						case 2:
							min.x = ( nodeMin.x + nodeMax.x ) * 0.5;
							max.x = nodeMax.x;
							min.z = nodeMin.z;
							max.z = ( nodeMin.z + nodeMax.z ) * 0.5;
							break;
						case 3:
							min.x = ( nodeMin.x + nodeMax.x ) * 0.5;
							max.x = nodeMax.x;
							min.z = ( nodeMin.z + nodeMax.z ) * 0.5;
							max.z = nodeMax.z;
							break;
					}
					
					min.y = m_root.m_min.y
					max.y = m_root.m_max.y
					
					node.m_numNodes++;
					
					node.nodes[ i ] = new QuadNode(node);
					var quadNode:QuadNode = node.nodes[ i ];
					
					quadNode.m_center = max.add( min );
					quadNode.m_center.scaleBy(.5);
					quadNode.m_testSizeVector = max.subtract(min);
					quadNode.m_halfSizeVector = new Vector3D(quadNode.m_testSizeVector.x*0.5, quadNode.m_testSizeVector.y*0.5, quadNode.m_testSizeVector.z*0.5);
					quadNode.m_max = max;
					quadNode.m_min = min;
					quadNode.m_looseMax = max.add(quadNode.m_halfSizeVector);
					quadNode.m_looseMin = min.subtract(quadNode.m_halfSizeVector);
					quadNode.m_testSizeVectorLength = quadNode.m_testSizeVector.length;
					
					_allocateNodes( quadNode, depth+1 );
				}
			}
		}
		
		
		
		private function _insert( quadrant:Quadrant, node:QuadNode, depth:int = 0 ):void
		{
			var quadAABB:AxisAlignedBoundingBox = quadrant.sceneObject.axisAlignedBoundingBox;
			
			if ( ( depth < m_maxDepth ) && node.isTwiceSize( quadAABB ) )//nod depth
			{
				var indexX:int = 0;
				var indexZ:int = 0;
				
				var nodeBoxCenter:Vector3D = node.m_center;
				var quadrantBoxCenter:Vector3D = quadrant.sceneObject.axisAlignedBoundingBox.centerGlobal;
				
				//get indexes
				if ( quadrantBoxCenter.x > nodeBoxCenter.x )
					indexX = 2;

				if ( quadrantBoxCenter.z > nodeBoxCenter.z )
					indexZ = 1;
				
				var index:int = indexX+indexZ;
				
				var quadNode:QuadNode = node.nodes[ index ];
				
				if ( !preAllocateNodes && quadNode == null )
				{
					node.nodes[ index ] = new QuadNode(node);
					
					quadNode = node.nodes[ index ];
					
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
					

				    min.y = m_root.m_min.y;
				    max.y = m_root.m_max.y;

					
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

					quadNode.m_center = max.add( min );
					quadNode.m_center.scaleBy(.5);
					quadNode.m_testSizeVector = max.subtract(min);
					quadNode.m_halfSizeVector = new Vector3D(quadNode.m_testSizeVector.x*0.5, quadNode.m_testSizeVector.y*0.5, quadNode.m_testSizeVector.z*0.5);
					quadNode.m_max = max;
					quadNode.m_min = min;
					quadNode.m_looseMax = max.add(quadNode.m_halfSizeVector);
					quadNode.m_looseMin = min.subtract(quadNode.m_halfSizeVector);
					quadNode.m_testSizeVectorLength = quadNode.m_testSizeVector.length;
					
					
					
				}
				
				_insert(quadrant, quadNode, ++depth );
				node.m_sumChildren++;
			}
				
			else
			{
				node.children.push( quadrant );
				quadrant.m_parentNode = node;
				node.m_sumChildren++;
			}
		}
		
		
		public function updateTree(childrenDynamic:Vector.<SceneObjectRenderable> ):void
		{
			var len:int = childrenDynamic.length;
			var quadrant:Quadrant;
			for(var i:int = 0; i < len; i++)
			{
				var scn:SceneObjectRenderable = childrenDynamic.pop();
				scn.transformation.m_isAddedToSceneRefreshList = false;
				quadrant = sceneObjectToQuadrant[scn];
				
				if(quadrant && !quadrant.isInParent())
				{
					removeFromNode( scn );
					_insert(quadrant, m_root);
				}
			}
		}
		
		
		public function removeFromNode(sceneObject:SceneObjectRenderable):void
		{
			var quadrant:Quadrant = sceneObjectToQuadrant[sceneObject];
			if( quadrant )
			{
				var array:Vector.<Quadrant> = quadrant.m_parentNode.children;//dynamic
				array.splice(array.indexOf(quadrant),1);
				var parent:QuadNode = quadrant.m_parentNode;
				
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
		private function _visibilityProcess( frustum:Frustum, node:QuadNode, bTestChildren:Boolean) :void
		{		
			var i:int;
			
			var quadrantSceneObject:SceneObjectRenderable;
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
								quadrantSceneObject = node.children[i].sceneObject;
								quadrantSceneObject.m_isInFrustum = true;
								list[listlength] = quadrantSceneObject;
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

								quadrantSceneObject = node.children[i].sceneObject;
								axis = quadrantSceneObject.axisAlignedBoundingBox;
								
								//if(!frustum.boundingSphere.intersectTestSphereParam(axis.center, oct.sceneObject.boundingSphere.m_radius))
									//continue;
								if( frustum.containmentTestOctant(axis.halfSizeGlobal, axis.centerGlobal) == 0 /*Frustum.OUT */)
								{
									continue;
								}
								quadrantSceneObject.m_isInFrustum = true;
								list[listlength] = quadrantSceneObject;
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
						quadrantSceneObject = node.children[i].sceneObject;
						quadrantSceneObject.m_isInFrustum = true;
						
						list[listlength] = quadrantSceneObject;
						listlength++;
					}
				}
			}
			
			
			
			var childNode:QuadNode;
			var nodesOfNode:Vector.<QuadNode> = node.nodes;
			
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

			}
		}
		
		// recursive
		private function _visibilityProcessLight( frustum:Frustum, node:QuadNode, bTestChildren:Boolean, lightIndex:int, _scene:IScene) :void
		{		
			var i:int;
			
			var quadrantSceneObject:SceneObjectRenderable;
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
								quadrantSceneObject = node.children[i].sceneObject;
								if(quadrantSceneObject.m_isInFrustum)
									SceneTreeManager.s_renSetIlluminatorLightIndexes[_scene][quadrantSceneObject].push(lightIndex);
								
								list[listlength] = quadrantSceneObject;
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
								quadrantSceneObject = node.children[i].sceneObject;
								axis = quadrantSceneObject.axisAlignedBoundingBox;
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
								
								if(quadrantSceneObject.m_isInFrustum)
									SceneTreeManager.s_renSetIlluminatorLightIndexes[_scene][quadrantSceneObject].push(lightIndex);
								
								list[listlength] = quadrantSceneObject;
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
						quadrantSceneObject = node.children[i].sceneObject;
						if(quadrantSceneObject.m_isInFrustum)
							SceneTreeManager.s_renSetIlluminatorLightIndexes[_scene][quadrantSceneObject].push(lightIndex);
						
						list[listlength] = quadrantSceneObject;
						listlength++;
					}
				}
			}
			
			
			
			var childNode:QuadNode;
			var nodesOfNode:Vector.<QuadNode> = node.nodes;
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

					
			}
		}
		
	}
}