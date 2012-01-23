/*
 * BoundingSphere.as
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
 
 
package com.yogurt3d.core.helpers.boundingvolumes
{
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	
	import flash.geom.Vector3D;
	
	use namespace YOGURT3D_INTERNAL;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class BoundingSphere extends EngineObject
	{
		YOGURT3D_INTERNAL var m_radius		:Number;
		YOGURT3D_INTERNAL var m_radiusSqr	:Number;
		YOGURT3D_INTERNAL var m_center		:Vector3D;
		
/*		public function set center(value:Vector3D):void
		{
			YOGURT3D_INTERNAL::m_center = value;
		}*/

		override public function clone():IEngineObject{
			return new BoundingSphere(m_radiusSqr, m_center);
			
		}
		
		public function BoundingSphere(_radiusSqr:Number, _center:Vector3D)
		{
			m_radiusSqr	= _radiusSqr;
			m_center	= _center;
			
			m_radius	= Math.sqrt(_radiusSqr);
			
			super(true);
		}
		
		public function get radius():Number
		{
			return m_radius;
		}
		
		public function get radiusSqr():Number
		{
			return m_radiusSqr;
		}
		
		public function get center():Vector3D
		{
			return m_center;
		}
		
		public function set radius(_value:Number):void
		{
			m_radius = _value;
		}
		
		public function set radiusSqr(_value:Number):void
		{
			m_radiusSqr = _value;
		}
		
		public function set center(_value:Vector3D):void
		{
			m_center = _value;
		}
		
		public function intersectTestSphere(other:BoundingSphere):Boolean
		{
			return intersectTestSphereParam(other.m_center, other.m_radius);
		}
		
		public function intersectTestSphereParam(otherCenter:Vector3D, otherRadius:Number ):Boolean
		{
			var centerdiffer:Vector3D = center.subtract(otherCenter);
			
			var sumOfRadiis:Number = radius + otherRadius;
			
			if( centerdiffer.lengthSquared > (sumOfRadiis * sumOfRadiis) )
				return false;
			
			return true;
		}
		
		public function intersectTestAABB(_min:Vector3D, _max:Vector3D):int
		{
			//find closest point on AABB to center of sphere
			var point_X:Number = m_center.x;
			var point_Y:Number = m_center.y;
			var point_Z:Number = m_center.z;
			
			if( m_center.x < _min.x )
				point_X = _min.x;
			else if( m_center.x > _max.x )
				point_X = _max.x;
			
			if( m_center.y < _min.y )
				point_Y = _min.y;
			else if( m_center.y > _max.y )
				point_Y = _max.y;
			
			if( m_center.z < _min.z )
				point_Z = _min.z;
			else if( m_center.z > _max.z )
				point_Z = _max.z;
			//closest point calculation ends
			
			//find vector between closest point and sphere center
			point_X -= m_center.x;
			point_Y -= m_center.y;
			point_Z -= m_center.z;
			
			//squared distance
			var sqrtDistance:Number = (point_X*point_X)+(point_Y*point_Y)+(point_Z*point_Z);
			if(sqrtDistance > m_radius*m_radius)
				return 0;//outside
			else
				return 2;//intersect or in
		}
		
		protected override function trackObject():void
		{
			IDManager.trackObject(this, BoundingSphere);
		}


	}
}
