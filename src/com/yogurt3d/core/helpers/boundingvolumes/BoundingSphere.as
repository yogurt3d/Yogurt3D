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
		
		public function intersectTest(other:BoundingSphere):Boolean
		{
			var centerdiffer:Vector3D = center.subtract(other.center);
			
			var sumOfRadiis:Number = radius + other.radius;
			
			if( centerdiffer.lengthSquared > (sumOfRadiis * sumOfRadiis) )
				return false;
			
			return true;
		}

	}
}
