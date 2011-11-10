/*
* Plane.as
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
package com.yogurt3d.core.frustum
{
	
	import flash.geom.Vector3D;
	
	public class Plane
	{   
		public static const BEHIND    :int = 0;
		public static const FRONT     :int = 1;
		public static const ON        :int = 2;
		public static const BOTH_SIDE :int = 3;
		public var  a:Number;
		public var  b:Number;
		public var  c:Number;
		public var	d:Number;
		
		public function Plane()
		{
		}
		
		public function distanceToPoint(point:Vector3D):Number
		{
			return ( (point.x * a) + (point.y * b) + (point.z * c) + d );
		}
		
		public function maxAbsulateDistance(vector:Vector3D):Number
		{
			return Math.abs( vector.x * a) + Math.abs(vector.y * b) + Math.abs(vector.z * c);
		}
		
		public function pointSideTest(point:Vector3D) :int
		{
			var distance:Number = ( (point.x * a) + (point.y * b) + (point.z * c) + d );
			
			if(distance == 0)
				return (ON);
			if(distance > 0)
				return (FRONT);
			
			return (BEHIND);
		}
		
		public function octantSideTest(center:Vector3D, halfSize:Vector3D) :int
		{
			var distance:Number = distanceToPoint( center );
			var maxAbsDistance:Number = maxAbsulateDistance( halfSize );
			
			if(distance < -maxAbsDistance)
				return(BEHIND);
			
			if(distance > +maxAbsDistance)
				return(FRONT);
			
			return(BOTH_SIDE);
		}
		
		
		public function toString():String{
			return "a:" + a + " b:" + b + " c:" + c + " d:" + d; 
		}
	}
}

