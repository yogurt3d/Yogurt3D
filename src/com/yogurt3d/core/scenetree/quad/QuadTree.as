package com.yogurt3d.core.scenetree.quad
{
	import com.yogurt3d.core.cameras.interfaces.ICamera;
	import com.yogurt3d.core.frustum.Frustum;
	import com.yogurt3d.core.helpers.boundingvolumes.BoundingSphere;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	public class QuadTree
	{
		public var root:QuadNode;
		public var list:Vector.<ISceneObjectRenderable> = new Vector.<ISceneObjectRenderable>();
		
		public function QuadTree( _bound:Rectangle, _maxDepth:uint = 3, _maxChildren:uint = 4)
		{
			root = new QuadNode(_bound,0,_maxDepth,_maxChildren );	
		}
		
		public function insert( _sceneObject:ISceneObjectRenderable ):void{
			var min:Vector3D = _sceneObject.geometry.axisAlignedBoundingBox.min;
			var max:Vector3D = _sceneObject.geometry.axisAlignedBoundingBox.max;
			Y3DCONFIG::TRACE
			{
				trace("[QuadNode](insert)",min,max);
			}
			root.insert( _sceneObject );
		}
		public function retrieve( _bound:Rectangle ):Vector.<ISceneObjectRenderable>{
			return root.retrieve( _bound );
		}
		
		public function visibilityProcess( camera:ICamera ) :void
		{
			list.length = 0;
			return _visibilityProcess( camera, root, true );
		}
		
		
		// recursive
		private function _visibilityProcess( camera:ICamera, node:QuadNode, bTestChildren:Boolean) :void
		{		
			if(bTestChildren) 
			{
				var pos:Vector3D = camera.transformation.matrixGlobal.position;
				var frustum:Frustum = camera.frustum;
				var boundingSphere:BoundingSphere = node.bs;
				
				if(!node.m_bound.contains( pos.x, pos.z) ) 
				{
					
					if(!frustum.boundingSphere.intersectTest(boundingSphere))
						return;
				
					switch( frustum.containmentTestSphere(boundingSphere) ) 
					{
						case (Frustum.OUT):
							return;
						case (Frustum.IN):
							bTestChildren = false;
							break;
						case (Frustum.INTERSECT):
							
							var res:int;
							
							res = frustum.containmentTestAABR(node.corners);
	
							switch(res)
							{
								case (Frustum.IN):
									bTestChildren = false;
									break;
								case (Frustum.OUT):
									return;
							}
							break;
						
					}
				}
			}	
			// we can now check the children or render this node
			if(node._stuckChildren.length > 0)
				list = list.concat(node._stuckChildren);
			
			if(node.nodes.length == 0)
			{
				list = list.concat( node.children);
				
			}else
			{
				for(var i :int = 0 ; i < node.nodes.length; i++)
				{
					_visibilityProcess( camera, node.nodes[i], bTestChildren);
				}
			}

		}
		
		
		
		public function removeItem( x:Number, z:Number, node:QuadNode, bTestChildren:Boolean) : Boolean
		{
			var min:Vector3D;
			var max:Vector3D;
			var _bounds:Rectangle;
			
			if(bTestChildren) 
			{
				if(!node.m_bound.contains( x, z) ) 
				{
					bTestChildren = false;
					return false ;
				}
			}	
			
			var len:int = node._stuckChildren.length;
			    
			
			if(len > 0)
			{
				for(var i :int = 0 ; i < len; i++)
				{
					min = node._stuckChildren[i].geometry.axisAlignedBoundingBox.min;
					max = node._stuckChildren[i].geometry.axisAlignedBoundingBox.max;
					_bounds = new Rectangle(min.x, min.z, max.x - min.x, max.z - min.z)
					if( ( (min.x <= x)&&(x <= max.x ) )&&
						( (min.z <= z)&&(z <= max.z) ) )
					{    
						node._stuckChildren.splice(i , 1 );
						removeRegulate(node);
						return true;//stuck
					}
				}
				
			}	
			
			len = node.nodes.length;
			
			if(len == 0)
			{
				var lenc:int = node.children.length;
				
				if(lenc != 0)
				{
					for(var j :int = 0 ; j < lenc; j++)
					{
						min = node.children[i].geometry.axisAlignedBoundingBox.min;
						max = node.children[i].geometry.axisAlignedBoundingBox.max;
						_bounds = new Rectangle(min.x, min.z, max.x - min.x, max.z - min.z)
							
						if( ( (min.x <= x)&&(x <= max.x) ) &&
							( (min.z <= z)&&(z <= max.z) ) )
						{    
							node.children.splice(j , 1 );
							
							return true;
						}
					}
					
				}
				
			}
		
			for(var k :int = 0 ; k < len; k++)
			{
				var removed:Boolean = removeItem( x, z, node.nodes[k], bTestChildren);
					
				if(removed)
				{
					removeRegulate(node);
						
					return true;
				}
			}
				
			return true;
			
		}
		
		public function removeRegulate(node:QuadNode) :void
		{
			var sumnn:int;
			var sumnc:int;
			
			var len:int = node.nodes.length;
			
			var nodesArr:Vector.<QuadNode> = node.nodes;
			
			for(var n :int = 0 ; n < len; n++)
			{
					
					sumnc += nodesArr[n].children.length;
					
					sumnn += nodesArr[n].nodes.length;
			}
			
			sumnc += node._stuckChildren.length;
			
			if(sumnc <= node.m_maxChildren && sumnn == 0) 
			{
				if(node._stuckChildren.length)
				{
					node.children = node.children.concat(node._stuckChildren);
					node._stuckChildren.length = 0;
				}
				
				for(var j :int = 0 ; j < len; j++ )
				{
					node.children = node.children.concat(node.nodes[j].children);
				}
				
				
				node.nodes.length = 0;
			}
		}
			
		
		
		
	}
}