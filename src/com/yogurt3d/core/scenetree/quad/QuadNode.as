package com.yogurt3d.core.scenetree.quad
{
	import com.yogurt3d.core.helpers.boundingvolumes.BoundingSphere;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	public class QuadNode
	{
		public static const TOP_LEFT:uint = 0;
		public static const TOP_RIGHT:uint = 1;
		public static const BOTTOM_LEFT:uint = 2;
		public static const BOTTOM_RIGHT:uint = 3;
		
		public var m_bound:Rectangle;
		public var children:Vector.<ISceneObjectRenderable> = new Vector.<ISceneObjectRenderable>();
		public var nodes:Vector.<QuadNode> = new Vector.<QuadNode>();
		public var _stuckChildren:Vector.<ISceneObjectRenderable> = new Vector.<ISceneObjectRenderable>();
		public var corners:Vector.<Vector3D>;
		
		public var bs:BoundingSphere;
		
		public var m_maxChildren:uint;
		private var m_maxDepth:uint;
		private var m_depth:uint;
		
		public function QuadNode(_bound:Rectangle,_depth:uint, _maxDepth:uint, _maxChildren:uint)
		{
			m_bound = _bound;
			m_maxDepth = _maxDepth;
			m_depth = _depth;
			m_maxChildren = _maxChildren;
			GenerateCorners();
			var temp:Vector3D = corners[3].subtract(corners[0]);
			temp.scaleBy(0.5);
			
			bs =  new BoundingSphere(temp.lengthSquared, corners[0].add(temp));
			m_depth = _depth;
		}
		public function GenerateCorners():void
		{
			corners = new Vector.<Vector3D>( 4 , true);
			
			corners[0] = new Vector3D(m_bound.x, 0, m_bound.y);// top left
			corners[1] = new Vector3D(m_bound.x + m_bound.width, 0, m_bound.y);// top right
			corners[2] = new Vector3D(m_bound.x, 0, m_bound.y + m_bound.height);// bottom left
			corners[3] = new Vector3D(m_bound.x + m_bound.width, 0, m_bound.y + m_bound.height);// bottom right aka world space top left
			
		}
		
		//public function VTretrieve():
		
		
		
		
		public function insert( item:ISceneObjectRenderable ):void{
			if(this.nodes.length)
			{
				var min:Vector3D = item.geometry.axisAlignedBoundingBox.min;
				var max:Vector3D = item.geometry.axisAlignedBoundingBox.max;
				var index:Array = this._findIndex( new Rectangle(min.x, min.z, max.x - min.x, max.z - min.z));
				//var node:QuadNode = this.nodes[index];
				
				//todo: make _bounds bounds
				if( index.length == 1)
				{
					this.nodes[index[0]].insert(item);
				}
				else
				{
					this._stuckChildren.push(item);
				}
				
				return;
			}
			
			this.children.push(item);
			
			var len:uint = this.children.length;
			
			if(!(this.m_depth >= m_maxDepth) && len > m_maxChildren)
			{
				this.subdivide();
				
				for(var i:uint = 0; i < len; i++)
				{
					this.insert(this.children[i]);
				}
				
				this.children.length = 0;
			}
		}
		public function retrieve( item:Rectangle):Vector.<ISceneObjectRenderable>{
			var out:Vector.<ISceneObjectRenderable> = new Vector.<ISceneObjectRenderable>();
			
			if(this.nodes.length)
			{
				var index:Array = this._findIndex(item);
				
				for( var i:int = 0; i<index.length;i++)
				{
					out = out.concat( this.nodes[index[i]].retrieve(item) );
				}
			}
			
			out = out.concat( this._stuckChildren);
			out = out.concat( this.children);
			
			return out;
		}
		
		
		
		private function _findIndex(  item:Rectangle ):Array{
			var b:Rectangle = this.m_bound;
			var align:Number = b.x + b.width / 2;
			var valign:Number = b.y + b.height / 2;
			
			var left:Boolean = (item.x < align )? true : false;
			var right:Boolean = (item.x > align || item.x + item.width > align )? true : false;
			var top:Boolean = (item.y < valign )? true : false;
			var bottom:Boolean = (item.y > valign || item.y + item.height > valign )? true : false;
			
			
			//top left
			var index:Array = [];
			if( top )
			{
				if( left )
					index.push( QuadNode.TOP_LEFT );
				if( right )
					index.push( QuadNode.TOP_RIGHT );
			}
			if( bottom )
			{
				if( left )
					index.push( QuadNode.BOTTOM_LEFT );
				if( right )
					index.push( QuadNode.BOTTOM_RIGHT );
			}
			
			
			return index;
		}
		
		public function subdivide():void{
			var depth:uint = m_depth + 1;
			
			var bx:Number = m_bound.x;
			var by:Number = m_bound.y;
			
			//floor the values
			var b_w_h:Number = (m_bound.width * 0.5)|0;
			var b_h_h:Number = (m_bound.height * 0.5)|0;
			var bx_b_w_h:Number = bx + b_w_h;
			var by_b_h_h:Number = by + b_h_h;
			
			//top left
			this.nodes[QuadNode.TOP_LEFT] = new QuadNode(new Rectangle(bx,by,b_w_h,b_h_h),depth, m_maxDepth, m_maxChildren);
			
			//top right
			this.nodes[QuadNode.TOP_RIGHT] = new QuadNode(new Rectangle(bx_b_w_h,by,b_w_h,b_h_h),depth, m_maxDepth, m_maxChildren);
			
			//bottom left
			this.nodes[QuadNode.BOTTOM_LEFT] = new QuadNode(new Rectangle(bx,by_b_h_h,b_w_h,b_h_h),depth, m_maxDepth, m_maxChildren);
			
			
			//bottom right
			this.nodes[QuadNode.BOTTOM_RIGHT] = new QuadNode(new Rectangle(bx_b_w_h,by_b_h_h,b_w_h,b_h_h),depth, m_maxDepth, m_maxChildren); 
		}
		

		public function clear():void{
			this._stuckChildren.length = 0;
			
			//array
			this.children.length = 0;
			
			var len:uint = this.nodes.length;
			
			if(!len)
			{
				return;
			}
			
			for(var i:uint = 0; i < len; i++)
			{
				this.nodes[i].clear();
			}
			
			//array
			this.nodes.length = 0;
			

		}
	}
}