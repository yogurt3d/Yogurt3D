/*
* Camera.as
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

package com.yogurt3d.core.cameras {
	import com.yogurt3d.core.cameras.interfaces.ICamera;
	import com.yogurt3d.core.helpers.ProjectionUtils;
	import com.yogurt3d.core.helpers.boundingvolumes.BoundingSphere;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.SceneObject;
	import com.yogurt3d.core.sceneobjects.SceneObjectContainer;
	import com.yogurt3d.core.transformations.Transformation;
	import com.yogurt3d.core.utils.MatrixUtils;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/	
	public class Camera extends SceneObject implements ICamera
	{
		YOGURT3D_INTERNAL var m_projectionMatrix		:Matrix3D;
		
		//YOGURT3D_INTERNAL var m_frustrumPlanes			:Vector.<Vector3D>;
		
		public var m_frustum :Frustum;
		
		use namespace YOGURT3D_INTERNAL;
		
		public function Camera(_initInternals:Boolean = true)
		{
			super(_initInternals);
		}
		
		public function get frustum():Frustum
		{
			return m_frustum;
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
			m_projectionMatrix = ProjectionUtils.setProjectionOrtho( _width, _height, _near, _far );
			
			extractPlanes();
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
			m_projectionMatrix = ProjectionUtils.setProjectionOrthoAsymmetric(_left, _right, _bottom, _top, _near, _far);
			
			extractPlanes();
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
			m_projectionMatrix = ProjectionUtils.setProjectionPerspective(_fovy, _aspect, _near, _far);
			
			CalcFrustumBSPers(_fovy, _aspect, _near, _far);
			CalcFrustumPointsPers(_fovy, _aspect, _near, _far);
			//extractPlanes();
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
			
			m_projectionMatrix = ProjectionUtils.setProjectionPerspectiveAsymmetric(_width,_height, _near, _far);
			
			extractPlanes();
		}
		
		/**
		 * Based on paper:
		 * Fast Extraction of Viewing Frustum Planes from the World-View-Projection Matrix
		 * Gill Gribb / Klaus Hartmann
		 */
		public function extractPlanes():void {
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
			m_frustum.vPlanes[0].a = raw3  + raw0;
			m_frustum.vPlanes[0].b = raw7  + raw4;
			m_frustum.vPlanes[0].c = raw11 + raw8;
			m_frustum.vPlanes[0].d = raw15 + raw12;
			
			// Right clipping plane
			m_frustum.vPlanes[1].a = raw3  - raw0;
			m_frustum.vPlanes[1].b = raw7  - raw4;
			m_frustum.vPlanes[1].c = raw11 - raw8;
			m_frustum.vPlanes[1].d = raw15 - raw12;
			
			// Top clipping plane
			m_frustum.vPlanes[2].a = raw3  - raw1;
			m_frustum.vPlanes[2].b = raw7  - raw5;
			m_frustum.vPlanes[2].c = raw11 - raw9;
			m_frustum.vPlanes[2].d = raw15 - raw13;
			
			// Bottom clipping plane
			m_frustum.vPlanes[3].a = raw3  + raw1;
			m_frustum.vPlanes[3].b = raw7  + raw5;
			m_frustum.vPlanes[3].c = raw11 + raw9;
			m_frustum.vPlanes[3].d = raw15 + raw13;
			
			// Near clipping plane
			m_frustum.vPlanes[4].a = raw3  + raw2;
			m_frustum.vPlanes[4].b = raw7  + raw6;
			m_frustum.vPlanes[4].c = raw11 + raw10;
			m_frustum.vPlanes[4].d = raw15 + raw14;
			
			// Far clipping plane
			m_frustum.vPlanes[5].a = raw3  - raw2;
			m_frustum.vPlanes[5].b = raw7  - raw6;
			m_frustum.vPlanes[5].c = raw11 - raw10;
			m_frustum.vPlanes[5].d = raw15 - raw14;
			
			//Normalizes the frustum plane equations
			for (var i:int = 0; i < 6; i++) {
				var a:Number = m_frustum.vPlanes[i].a;
				var b:Number = m_frustum.vPlanes[i].b;
				var c:Number = m_frustum.vPlanes[i].c;
				var _mag : Number = 1 / Math.sqrt( a * a + b * b + c * c);
				m_frustum.vPlanes[i].a = a * _mag;
				m_frustum.vPlanes[i].b = b * _mag;
				m_frustum.vPlanes[i].c = c * _mag;
				m_frustum.vPlanes[i].d *= _mag;
			}
		}
		
		
		/**
		 * @inheritDoc
		 * 
		 */		
		override protected function initInternals():void
		{
			super.initInternals();
			
			m_projectionMatrix			= new Matrix3D();
			
			m_frustum = new Frustum();
			
			setProjectionPerspective( 45.0, 4.0/3.0, 1.0, 500.0 );
		}
		
		
		public function CalcFrustumBSPers(_fovy:Number, _aspect:Number, _near:Number, _far:Number):void
		{
			var viewDistance :Number =_near - _far;
			m_frustum.m_bSCenterOrginal = new Vector3D(0, 0, -_near + viewDistance*0.5);
			
			var farHalfHeight:Number = Math.tan( (_fovy / 2) * Math.PI/180 ) * -_far;
			var farHalfWidth :Number = farHalfHeight * _aspect;
			
			var farthestPoint :Vector3D =  new Vector3D(farHalfWidth, farHalfHeight, -_far);
			var differVector :Vector3D =  farthestPoint.subtract(m_frustum.m_bSCenterOrginal);
			
			m_frustum.boundingSphere = new BoundingSphere(differVector.lengthSquared, m_frustum.m_bSCenterOrginal);
		}
		
		public function  CalcFrustumPointsPers(_fovy:Number, _aspect:Number, _near:Number, _far:Number):void
		{
			var Hnear:Number;
			var Wnear:Number;
			var Hfar:Number;
			var Wfar:Number;
			
			
			Hnear = 2 * Math.tan(_fovy*Transformation.DEG_TO_RAD / 2) * -_near;
			Wnear = Hnear * _aspect;
			Hfar = 2 * Math.tan(_fovy*Transformation.DEG_TO_RAD / 2) * -_far;
			Wfar = Hfar * _aspect;
			
			var points:Vector.<Vector3D> = m_frustum.m_vCornerPoints;
			
			points[0] = new Vector3D(-Wfar/2,-Hfar/2,-_far);//far bottom left
			points[1] = new Vector3D(Wfar/2,-Hfar/2,-_far);//far bottom right
			points[2] = new Vector3D(Wfar/2,Hfar/2,-_far);//far top right
			points[3] = new Vector3D(-Wfar/2,Hfar/2,-_far);//far top left
			
			points[4] = new Vector3D(-Wnear/2,-Hnear/2,  -_near);//near bottom left
			points[5] = new Vector3D(Wnear/2, -Hnear/2,  -_near);//near bottom right
			points[6] = new Vector3D(Wnear/2,  Hnear/2, -_near);//near top right
			points[7] = new Vector3D(-Wnear/2,  Hnear/2, -_near);//near top left
		}
		
		public function TransformedFrustumCorners():Vector.<Vector3D>
		{
			var points:Vector.<Vector3D> = m_frustum.m_vCornerPoints;
			var pointsNew:Vector.<Vector3D> = new Vector.<Vector3D>(8);
			var matrix:Matrix3D = transformation.matrixGlobal;
			
			for(var i:int; i < 8; i++)
			{
				pointsNew[i] = matrix.transformVector(points[i]);
			}
			
			return pointsNew;
		}
		
		
		
	}
}
