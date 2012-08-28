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

package com.yogurt3d.core.frustum{

	import com.yogurt3d.core.helpers.ProjectionUtils;
	import com.yogurt3d.core.helpers.boundingvolumes.*;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.transformations.Transformation;
	import com.yogurt3d.core.utils.MathUtils;
	import com.yogurt3d.core.utils.MatrixUtils;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	//import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	//
	//
	
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
		
		private var m_sphereCheck:Boolean = false;
		
		private var m_projectionMatrix:Matrix3D;
		
		public function Frustum()
		{
			vPlanes = new Vector.<Plane>(6, true);
			
			for(var i:int = 0; i < vPlanes.length; i++)
			{
				vPlanes[i] = new Plane();	
			}
			
			m_vCornerPoints = new Vector.<Vector3D>(8,true);
			
			for(var j:int = 0; j < m_vCornerPoints.length; j++)
			{
				m_vCornerPoints[j] = new Vector3D();	
			}
			
			m_projectionMatrix = new Matrix3D();
		}
		
		/**
		 * @inheritDoc   
		 * @return 
		 * @default perspective projection with 45 fovy, 4/3 aspect ratio, near plane at 1 and far plane at 500
		 */
		public function get projectionMatrix():Matrix3D
		{
			return m_projectionMatrix;
		}
		
		
		YOGURT3D_INTERNAL function get sphereCheck():Boolean
		{
			return m_sphereCheck;
		}
		
		YOGURT3D_INTERNAL function set sphereCheck(value:Boolean):void
		{
			m_sphereCheck = value;
		}
		
		/**
		 * @inheritDoc  
		 * @param _width
		 * @param _height
		 * @param _near
		 * @param _far
		 * 
		 */		
		public function setProjectionOrtho(_width:Number, _height:Number, _near:Number, _far:Number):void
		{		
			ProjectionUtils.setProjectionOrtho( m_projectionMatrix, _width, _height, _near, _far );
			
			CalcFrustumBSOrtho(_width, _height, _near, _far);
		}
		/**
		 * @inheritDoc   
		 * @param _left
		 * @param _right
		 * @param _bottom
		 * @param _top
		 * @param _near
		 * @param _far
		 * 
		 */		
		public function setProjectionOrthoAsymmetric(_left:Number, _right:Number, _bottom:Number, _top:Number, _near:Number, _far:Number):void
		{
			ProjectionUtils.setProjectionOrthoAsymmetric(m_projectionMatrix, _left, _right, _bottom, _top, _near, _far);
			
			CalcFrustumBSOrthoAsym(_left, _right, _bottom, _top, _near, _far);
		}
		/**
		 * @inheritDoc   
		 * @param _fovy
		 * @param _aspect
		 * @param _near
		 * @param _far
		 * 
		 */		
		public function setProjectionPerspective(_fovy:Number, _aspect:Number, _near:Number, _far:Number):void
		{	
			ProjectionUtils.setProjectionPerspective(m_projectionMatrix, _fovy, _aspect, _near, _far);
			
			CalcFrustumBSPers(_fovy, _aspect, _near, _far);
			CalcFrustumPointsPers(_fovy, _aspect, _near, _far);
		}
		/**
		 * @inheritDoc   
		 * @param _left
		 * @param _right
		 * @param _bottom
		 * @param _top
		 * @param _near
		 * @param _far
		 * 
		 */		
		public function setProjectionPerspectiveAsymmetric(_width:Number, _height:Number, _near:Number, _far:Number):void
		{
			ProjectionUtils.setProjectionPerspectiveAsymmetric(m_projectionMatrix, _width,_height, _near, _far);
			
			//CalcFrustumBSPers(_fovy, _aspect, _near, _far);
			//CalcFrustumPointsPers(_fovy, _aspect, _near, _far);
		}
		
		public function CalcFrustumBSPers(_fovy:Number, _aspect:Number, _near:Number, _far:Number):void
		{
			var viewDistance :Number =_near - _far;
			m_bSCenterOrginal = new Vector3D(0, 0, -_near + viewDistance*0.5);
			
			var farHalfHeight:Number = Math.tan( (_fovy / 2) * Math.PI/180 ) * -_far;
			var farHalfWidth :Number = farHalfHeight * _aspect;
			
			var farthestPoint :Vector3D =  new Vector3D(farHalfWidth, farHalfHeight, -_far);
			var differVector :Vector3D =  farthestPoint.subtract(m_bSCenterOrginal);
			
			if( boundingSphere )
			{
				boundingSphere.disposeDeep();
			}
			boundingSphere = new BoundingSphere(differVector.lengthSquared, m_bSCenterOrginal);
		}
		
		
		public function CalcFrustumBSOrthoAsym(_left:Number, _right:Number, _bottom:Number, _top:Number, _near:Number, _far:Number):void
		{
			m_bSCenterOrginal = new Vector3D(_left + ((_right-_left)*0.5), _bottom + ((_top-_bottom)*0.5), -_far + ((_far-_near)*0.5));
			
			var cornerPoint:Vector3D = new Vector3D(_right, _top, -_far);
			if( boundingSphere )
			{
				boundingSphere.disposeDeep();
			}
			boundingSphere = new BoundingSphere(cornerPoint.subtract(m_bSCenterOrginal).lengthSquared, m_bSCenterOrginal);
		}
		
		
		public function CalcFrustumBSOrtho(_width:Number, _height:Number, _near:Number, _far:Number):void
		{
			var viewDistance:Number = _far - _near;
			
			m_bSCenterOrginal = new Vector3D(0, 0, -_far + viewDistance*0.5);
			
			var cornerPoint:Vector3D = new Vector3D(_width*0.5, _height*0.5, -_far);
			if( boundingSphere )
			{
				boundingSphere.disposeDeep();
			}
			boundingSphere = new BoundingSphere(cornerPoint.subtract(m_bSCenterOrginal).lengthSquared, m_bSCenterOrginal);
		}
		
		private function  CalcFrustumPointsPers(_fovy:Number, _aspect:Number, _near:Number, _far:Number):void
		{
			var Hnear:Number;
			var Wnear:Number;
			var Hfar:Number;
			var Wfar:Number;
			
			
			Hnear = 2 * Math.tan(_fovy*MathUtils.DEG_TO_RAD / 2) * -_near;
			Wnear = Hnear * _aspect;
			Hfar = 2 * Math.tan(_fovy*MathUtils.DEG_TO_RAD / 2) * -_far;
			Wfar = Hfar * _aspect;
			
			var points:Vector.<Vector3D> = m_vCornerPoints;
			
			points[0].setTo(-Wfar/2,-Hfar/2,-_far);//far bottom left
			points[1].setTo(Wfar/2,-Hfar/2,-_far);//far bottom right
			points[2].setTo(Wfar/2,Hfar/2,-_far);//far top right
			points[3].setTo(-Wfar/2,Hfar/2,-_far);//far top left
			
			points[4].setTo(-Wnear/2,-Hnear/2,  -_near);//near bottom left
			points[5].setTo(Wnear/2, -Hnear/2,  -_near);//near bottom right
			points[6].setTo(Wnear/2,  Hnear/2, -_near);//near top right
			points[7].setTo(-Wnear/2,  Hnear/2, -_near);//near top left
		}
		
		
		public function CalcFrustumPointsOrtho(_width:Number, _height:Number, _near:Number, _far:Number):void
		{
			var _halfWidth:Number = _width*0.5;
			var _halfheight:Number = _height*0.5;
			
			var points:Vector.<Vector3D> = m_vCornerPoints;
			
			points[0].setTo(-_halfWidth,-_halfheight,-_far);//far bottom left
			points[1].setTo(_halfWidth,-_halfheight,-_far);//far bottom right
			points[2].setTo(_halfWidth,_halfheight, -_far);//far top right
			points[3].setTo(-_halfWidth, _halfheight,-_far);//far top left
			
			points[4].setTo(-_halfWidth,-_halfheight,  -_near);//near bottom left
			points[5].setTo(_halfWidth, -_halfheight,  -_near);//near bottom right
			points[6].setTo(_halfWidth,  _halfheight, -_near);//near top right
			points[7].setTo(-_halfWidth, _halfheight, -_near);//near top left
		
		}
		
		public function CalcFrustumPointsOrthoAsym(_left:Number, _right:Number, _bottom:Number, _top:Number, _near:Number, _far:Number):void
		{
			var points:Vector.<Vector3D> = m_vCornerPoints;
			
			points[0].setTo(_left,_bottom,-_far);//far bottom left
			points[1].setTo(_right,_bottom,-_far);//far bottom right
			points[2].setTo(_right,_top, -_far);//far top right
			points[3].setTo(_left, _top,-_far);//far top left
			
			points[4].setTo(_left,_bottom,  -_near);//near bottom left
			points[5].setTo(_right, _bottom,  -_near);//near bottom right
			points[6].setTo(_right,  _top, -_near);//near top right
			points[7].setTo(_left, _top, -_near);//near top left
			
		}
		
		
		/*public function TransformedFrustumCorners():Vector.<Vector3D>
		{
			var points:Vector.<Vector3D> = m_vCornerPoints;
			var pointsNew:Vector.<Vector3D> = new Vector.<Vector3D>(8);
			var matrix:Matrix3D = transformation.matrixGlobal;
			
			for(var i:int; i < 8; i++)
			{
				pointsNew[i] = matrix.transformVector(points[i]);
			}
			
			return pointsNew;
		}*/
		
		/**
		 * Based on paper:
		 * Fast Extraction of Viewing Frustum Planes from the World-View-Projection Matrix
		 * Gill Gribb / Klaus Hartmann
		 */
		public function extractPlanes(transformation:Transformation):void {
			var temp:Matrix3D = MatrixUtils.TEMP_MATRIX;
			temp.copyFrom( transformation.matrixGlobal );
			temp.invert();
			temp.append( m_projectionMatrix );
			var _rawData			:Vector.<Number>	= temp.rawData;
			
			var raw0:Number = _rawData[0];
			var raw1:Number = _rawData[1];
			var raw2:Number = _rawData[2];
			var raw3:Number = _rawData[3];
			var raw4:Number = _rawData[4];
			var raw5:Number = _rawData[5];
			var raw6:Number = _rawData[6];
			var raw7:Number = _rawData[7];
			var raw8:Number = _rawData[8];
			var raw9:Number = _rawData[9];
			var raw10:Number = _rawData[10];
			var raw11:Number = _rawData[11];
			var raw12:Number = _rawData[12];
			var raw13:Number = _rawData[13];
			var raw14:Number = _rawData[14];
			var raw15:Number = _rawData[15];
			
			
			// Left clipping plane
			vPlanes[0].a = raw3  + raw0;
			vPlanes[0].b = raw7  + raw4;
			vPlanes[0].c = raw11 + raw8;
			vPlanes[0].d = raw15 + raw12;
			
			// Right clipping plane
			vPlanes[1].a = raw3  - raw0;
			vPlanes[1].b = raw7  - raw4;
			vPlanes[1].c = raw11 - raw8;
			vPlanes[1].d = raw15 - raw12;
			
			// Top clipping plane
			vPlanes[2].a = raw3  - raw1;
			vPlanes[2].b = raw7  - raw5;
			vPlanes[2].c = raw11 - raw9;
			vPlanes[2].d = raw15 - raw13;
			
			// Bottom clipping plane
			vPlanes[3].a = raw3  + raw1;
			vPlanes[3].b = raw7  + raw5;
			vPlanes[3].c = raw11 + raw9;
			vPlanes[3].d = raw15 + raw13;
			
			// Near clipping plane
			vPlanes[4].a = raw3  + raw2;
			vPlanes[4].b = raw7  + raw6;
			vPlanes[4].c = raw11 + raw10;
			vPlanes[4].d = raw15 + raw14;
			
			// Far clipping plane
			vPlanes[5].a = raw3  - raw2;
			vPlanes[5].b = raw7  - raw6;
			vPlanes[5].c = raw11 - raw10;
			vPlanes[5].d = raw15 - raw14;
			
			//Normalizes the frustum plane equations
			for (var i:int = 0; i < 6; i++) {
				var a:Number = vPlanes[i].a;
				var b:Number = vPlanes[i].b;
				var c:Number = vPlanes[i].c;
				var _mag : Number = 1 / Math.sqrt( a * a + b * b + c * c);
				vPlanes[i].a = a * _mag;
				vPlanes[i].b = b * _mag;
				vPlanes[i].c = c * _mag;
				vPlanes[i].d *= _mag;
			}
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
				var test:uint = vPlanes[i].octantSideTest( center, halfSize );
				if( test == 0 /*Plane.BEHIND*/ )
				{
					return OUT;
				}
				else if( test == 3 /*Plane.BOTH_SIDE*/ ){
					all_inside = false;
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
			
			var _cornersOfBox:Vector.<Vector3D> = _box.cornersGlobal;
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