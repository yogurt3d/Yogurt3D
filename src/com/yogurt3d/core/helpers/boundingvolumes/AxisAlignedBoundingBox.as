/*
 * AxisAlignedBoundingBox.as
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
 
 
package com.yogurt3d.core.helpers.boundingvolumes {
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	use namespace YOGURT3D_INTERNAL;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class AxisAlignedBoundingBox extends EngineObject
	{
		YOGURT3D_INTERNAL var m_min				  :Vector3D;
		YOGURT3D_INTERNAL var m_max				  :Vector3D;
		YOGURT3D_INTERNAL var m_center			  :Vector3D;
		YOGURT3D_INTERNAL var m_center_original	  :Vector3D;
		YOGURT3D_INTERNAL var m_halfSize	      :Vector3D  = new Vector3D();
		YOGURT3D_INTERNAL var m_halfSize_original :Vector3D;
		YOGURT3D_INTERNAL var m_size	          :Vector3D;
		YOGURT3D_INTERNAL var m_size_Original	  :Vector3D;
		
		YOGURT3D_INTERNAL var m_cornersDirty	  :Boolean = true;
		
		private var m_tempTransformation		  :Matrix3D = new Matrix3D();	

		private var m_vectors					  :Vector.<Number>;
		private var m_transformedVectors		  :Vector.<Number>;
		private var m_zeroVector				  :Vector3D = new Vector3D();
		
		YOGURT3D_INTERNAL var m_corners			  :Vector.<Vector3D>;
		
		
		public function AxisAlignedBoundingBox(_min:Vector3D, _max:Vector3D, _initInternals:Boolean = true)
		{
			m_min		= _min;
			m_max		= _max;
			
			super(true);
		}
		
		public function get min():Vector3D
		{
			return m_min;
		}
		
		public function get max():Vector3D
		{
			return m_max;
		}
		
		public function get center():Vector3D
		{
			return m_center;
		}
		
		public function get halfSize():Vector3D
		{
			return m_halfSize;
		}
		
		public function get size():Vector3D
		{
			return m_size;
		}
		
		public function get corners():Vector.<Vector3D>
		{
			if( m_cornersDirty )
			{
				m_corners[0].setTo( m_min.x, m_min.y, m_min.z);
				m_corners[1].setTo( m_min.x, m_min.y, m_max.z);
				m_corners[2].setTo( m_min.x, m_max.y, m_min.z);
				m_corners[3].setTo( m_max.x, m_min.y, m_min.z);
				m_corners[4].setTo( m_max.x, m_max.y, m_max.z);
				m_corners[5].setTo( m_max.x, m_max.y, m_min.z);
				m_corners[6].setTo( m_max.x, m_min.y, m_max.z);
				m_corners[7].setTo( m_min.x, m_max.y, m_max.z);
				
				m_cornersDirty = false;
			}
			
			return  m_corners;
		}
		
		
		public function update( _transformation:Matrix3D ):AxisAlignedBoundingBox {	

			m_tempTransformation.copyFrom( _transformation );
			m_tempTransformation.position = m_zeroVector;
			
			m_center = _transformation.transformVector( m_center_original );
			
			m_tempTransformation.transformVectors( m_vectors, m_transformedVectors );
			
			m_halfSize.x				= Math.max( 
												Math.abs(m_transformedVectors[0]), 
												Math.abs(m_transformedVectors[3]), 
												Math.abs(m_transformedVectors[6]), 
												Math.abs(m_transformedVectors[9]) 
											);  
			m_halfSize.y				= Math.max( 
												Math.abs(m_transformedVectors[1]), 
												Math.abs(m_transformedVectors[4]), 
												Math.abs(m_transformedVectors[7]), 
												Math.abs(m_transformedVectors[10]) 
											);
			m_halfSize.z				= Math.max( 
												Math.abs(m_transformedVectors[2]), 
												Math.abs(m_transformedVectors[5]), 
												Math.abs(m_transformedVectors[8]), 
												Math.abs(m_transformedVectors[11]) 
											);
		
			m_size.setTo(m_halfSize.x*2, m_halfSize.y*2, m_halfSize.z*2);
			
			m_max = m_center.add( m_halfSize );			
			m_min = m_center.subtract( m_halfSize );
			
			
			m_cornersDirty = true;
			return this;
		}
		
		public function translate(_position:Vector3D):void
		{
			m_center = _position.add( m_center );
			
			m_max = m_center.add( m_halfSize );			
			m_min = m_center.subtract( m_halfSize );
			
			m_cornersDirty = true;
			
		}
		
		public function intersectAABB( _aabb:AxisAlignedBoundingBox ):Boolean
		{
			if( m_max.x < _aabb.m_min.x || m_min.x > _aabb.m_max.x )	return false;
			if( m_max.y < _aabb.m_min.y || m_min.y > _aabb.m_max.y )	return false;
			if( m_max.z < _aabb.m_min.z || m_min.z > _aabb.m_max.z )	return false;
			
			return true;
		}
		
		public function intersectRay( _rayStartPoint:Vector3D, _rayDirection:Vector3D ):Boolean
		{
			var maxS:Number = Number.MIN_VALUE;
			var minT:Number = Number.MAX_VALUE;
			var s:Number;
			var t:Number;
			var temp:Number;
			// do x coordinate test (yz planes)
			
			//ray is parallel to plane
			if( _rayDirection.x == 0 )
			{
				// ray passes by box
				if( _rayStartPoint.x < m_min.x || _rayStartPoint.x > m_max.x)
				{
					return false
				}
			}else{
				// compute intersection parameters and sort
				s = (m_min.x - _rayStartPoint.x) / _rayDirection.x;
				t = (m_max.x - _rayStartPoint.x) / _rayDirection.x;
				if( s > t )
				{
					temp = s;
					s = t;
					t = temp;
				}
				//adjust min and max values
				if( s > maxS )
					maxS = s;
				if( t < minT )
					minT = t;
				//check for intersection failure
				if( minT < 0 || maxS > minT )
					return false;
			}
			
			
			// do y coordinate test (xz planes)
			
			//ray is parallel to plane
			if( _rayDirection.y == 0 )
			{
				// ray passes by box
				if( _rayStartPoint.y < m_min.y || _rayStartPoint.y > m_max.y)
				{
					return false
				}
			}else{
				// compute intersection parameters and sort
				s = (m_min.y - _rayStartPoint.y) / _rayDirection.y;
				t = (m_max.y - _rayStartPoint.y) / _rayDirection.y;
				if( s > t )
				{
					temp = s;
					s = t;
					t = temp;
				}
				//adjust min and max values
				if( s > maxS )
					maxS = s;
				if( t < minT )
					minT = t;
				//check for intersection failure
				if( minT < 0 || maxS > minT )
					return false;
			}
			
			// do z coordinate test (xy planes)
			
			//ray is parallel to plane
			if( _rayDirection.z == 0 )
			{
				// ray passes by box
				if( _rayStartPoint.z < m_min.z || _rayStartPoint.z > m_max.z)
				{
					return false
				}
			}else{
				// compute intersection parameters and sort
				s = (m_min.z - _rayStartPoint.z) / _rayDirection.z;
				t = (m_max.z - _rayStartPoint.z) / _rayDirection.z;
				if( s > t )
				{
					temp = s;
					s = t;
					t = temp;
				}
				//adjust min and max values
				if( s > maxS )
					maxS = s;
				if( t < minT )
					minT = t;
				//check for intersection failure
				if( minT < 0 || maxS > minT )
					return false;
			}
			
			return true;
		}
		
		public function merge( _aabb:AxisAlignedBoundingBox ):AxisAlignedBoundingBox{
			
			var resolatedMax:Vector3D = _aabb.max;
			var resolatedMin:Vector3D = _aabb.min;
			
			if(resolatedMax.x > m_max.x) m_max.x = resolatedMax.x;
			if(resolatedMin.x < m_min.x) m_min.x = resolatedMin.x;
			if(resolatedMax.y > m_max.y) m_max.y = resolatedMax.y;
			if(resolatedMin.y < m_min.y) m_min.y = resolatedMin.y;
			if(resolatedMax.z > m_max.z) m_max.z = resolatedMax.z;
			if(resolatedMin.z < m_min.z) m_min.z = resolatedMin.z;
			
			
			m_size = m_max.subtract( m_min );
			m_halfSize.setTo(m_size.x*0.5, m_size.y*0.5, m_size.z*0.5);
			
			m_halfSize_original = m_halfSize.clone();
			m_size_Original = m_size.clone();
			
			m_center = m_max.add( m_min );
			m_center.scaleBy(.5);
			m_center_original = m_center.clone();
			
			
			m_vectors			= Vector.<Number>([ 
				-m_halfSize_original.x, m_halfSize_original.y, m_halfSize_original.z,
				m_halfSize_original.x,-m_halfSize_original.y, m_halfSize_original.z,
				m_halfSize_original.x, m_halfSize_original.y,-m_halfSize_original.z,
				m_halfSize_original.x, m_halfSize_original.y, m_halfSize_original.z 
			]);
			
			m_cornersDirty = true;
			
			return this;
		}
		
		public function recalculateFor( _min:Vector3D, _max:Vector3D ):AxisAlignedBoundingBox{
			m_max = _max;
			m_min = _min;
			
			m_size = m_max.subtract( m_min );
			m_halfSize.setTo(m_size.x*0.5, m_size.y*0.5, m_size.z*0.5);
			
			m_halfSize_original = m_halfSize.clone();
			m_size_Original = m_size.clone();
			
			m_center = m_max.add( m_min );
			m_center.scaleBy(.5);
			m_center_original = m_center.clone();
			
			
			m_vectors			= Vector.<Number>([ 
				-m_halfSize_original.x, m_halfSize_original.y, m_halfSize_original.z,
				m_halfSize_original.x,-m_halfSize_original.y, m_halfSize_original.z,
				m_halfSize_original.x, m_halfSize_original.y,-m_halfSize_original.z,
				m_halfSize_original.x, m_halfSize_original.y, m_halfSize_original.z 
			]);
			
			m_cornersDirty = true;
			
			return this;
		}
		
		override public function clone():IEngineObject{
			var _newAABB:AxisAlignedBoundingBox = new AxisAlignedBoundingBox( m_min, m_max);
			_newAABB.m_center 					= m_center.clone();
			_newAABB.m_halfSize					= m_halfSize.clone();
			_newAABB.m_halfSize_original		= m_halfSize_original.clone();
			_newAABB.m_center_original			= m_center_original.clone();
			return _newAABB;
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			
			m_size = max.subtract( min );
			m_halfSize.setTo(m_size.x*0.5, m_size.y*0.5, m_size.z*0.5);

			m_halfSize_original = m_halfSize.clone();
			m_size_Original = m_size.clone();
			
			m_center = max.add( min );
			m_center.scaleBy(.5);
			m_center_original = m_center.clone();

			
			m_vectors			= Vector.<Number>([ 
				-m_halfSize_original.x, m_halfSize_original.y, m_halfSize_original.z,
				m_halfSize_original.x,-m_halfSize_original.y, m_halfSize_original.z,
				m_halfSize_original.x, m_halfSize_original.y,-m_halfSize_original.z,
				m_halfSize_original.x, m_halfSize_original.y, m_halfSize_original.z 
			]);
			
			m_transformedVectors = new Vector.<Number>( 15 );
			
			m_corners 			 = new Vector.<Vector3D>( 8,true );
			
			m_corners[0] 		 = new Vector3D();
			m_corners[1] 		 = new Vector3D();
			m_corners[2] 		 = new Vector3D();
			m_corners[3] 		 = new Vector3D();
			m_corners[4] 		 = new Vector3D();
			m_corners[5] 		 = new Vector3D();
			m_corners[6] 		 = new Vector3D();
			m_corners[7] 		 = new Vector3D();
			
			m_cornersDirty = true;
		}
		
		override public function toString():String {
			return "[Min x:"+m_min.x.toFixed(3)+"  y:"+m_min.y.toFixed(3)+"  z:"+m_min.z.toFixed(3)+"][Max x:"+m_max.x.toFixed(3)+"  y:"+m_max.y.toFixed(3)+"  z:"+m_max.z.toFixed(3)+"][Center x:"+m_center.x.toFixed(3)+"  y:"+m_center.y.toFixed(3)+"  z:"+m_center.z.toFixed(3)+"]"; 
		}
	}
}
