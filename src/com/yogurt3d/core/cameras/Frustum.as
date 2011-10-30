/*
* Frustum.as
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

package com.yogurt3d.core.cameras{

	import com.yogurt3d.core.helpers.boundingvolumes.*;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	//import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	//import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	//import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	
	use namespace YOGURT3D_INTERNAL;
	
	public class Frustum
	{
		public static const OUT:int = 0;
		public static const IN:int  = 1;
		public static const INTERSECT:int = 2;
		
		public var vPlanes:        Vector.<Plane>;
		public var m_vCornerPoints:  Vector.<Vector3D>;
		public var m_boundingAABox:  AxisAlignedBoundingBox;
		public var boundingSphere: BoundingSphere;
		public var m_bSCenterOrginal: Vector3D;
		
		public function Frustum()
		{
			vPlanes = new Vector.<Plane>(6, true);
			
			for(var i:int = 0; i < vPlanes.length; i++)
			{
				vPlanes[i] = new Plane();	
			}
			m_vCornerPoints = new Vector.<Vector3D>(8,true);
		}
		
		public function containmentTestSphere(sphere:BoundingSphere):int
		{
			var distance:Number;
			
			for(var i:int = 0; i < 6; i++) {
				
				// distance to plane
				distance = vPlanes[i].distanceToPoint( sphere.center);
				
				if(distance < -sphere.radius)
					return(OUT);
				
				if(Math.abs(distance) < sphere.radius)
					return(INTERSECT);
				
				
			}
			//full containment
			return(IN);
		}
		
		
		public function containmentTestOctant(halfSize:Vector3D, center:Vector3D):int
		{
			var all_inside:Boolean = true;
			
			for(var i:int = 0; i < 6; i++) 
			{
				switch( vPlanes[i].octantSideTest( center, halfSize ) )
				{
					case (Plane.BEHIND):
						return OUT;
					case (Plane.BOTH_SIDE):
						all_inside = false;
						break;
				}
				
			} 
			if ( all_inside )
				return IN;
			else
				return INTERSECT;
			
		}
		
		
		
		public function containmentTestAABR( aabr:Vector.<Vector3D> ) :int
		{
			var iTotalIn:int = 0;
			
			for(var p:int = 0; p < 6 ; p++) 
			{
				var iInCount:int  = 4;
				var iPtIn:int     = 1;
				
				for(var i:int = 0; i < 4; i++) 
				{
					if(vPlanes[p].pointSideTest(aabr[i]) == Plane.BEHIND) 
					{
						iPtIn = 0;
						--iInCount;
					}
				}
				
				// all out
				if(iInCount == 0)
					return(OUT);
				
				iTotalIn += iPtIn;
				
				if(p == 1)//skip top, bottom plane
					p = 3;
			}
			
			if(iTotalIn == 4)//4 = plane count, because of skipping
				return(IN);
			
			return(INTERSECT);
		} // end containmentTestAABR	
		
		public function containmentTestAABB( _box:AxisAlignedBoundingBox ) :int
		{
			var iTotalIn:int = 0;
			var _testPointCount:uint = 8;
			
			var _cornersOfBox:Vector.<Vector3D> = _box.corners;
			for(var p:int = 0; p < 6 ; p++) 
			{
				var iInCount:int  = _testPointCount;
				var iPtIn:int     = 1;
				
				for(var i:int = 0; i < _testPointCount; i++) 
				{
					if(vPlanes[p].pointSideTest(_cornersOfBox[i]) == Plane.BEHIND) 
					{
						iPtIn = 0;
						--iInCount;
					}
				}
				
				// all out
				if(iInCount == 0)
					return(OUT);
				
				iTotalIn += iPtIn;
			}
			
			if(iTotalIn == 6)
				return(IN);
			
			return(INTERSECT);
		} // end containmentTestAABR	
		
		
	}// end Frustum
}