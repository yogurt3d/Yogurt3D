/*
 * ICamera.as
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
package com.yogurt3d.core.cameras.interfaces {
	import com.yogurt3d.core.cameras.Frustum;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObject;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	/**
	  * 
	  * 
 	  * @author Yogurt3D Engine Core Team
 	  * @company Yogurt3D Corp.
 	  **/
	public interface ICamera extends ISceneObject
	{
		
		/**
		 * Projection Matrix of the camera
		 * @return 
		 * 
		 */
		function get projectionMatrix():Matrix3D;

		/**
		 * Sets the projection matrix to Orthographic Projection
		 * @param _width
		 * @param _height
		 * @param _near
		 * @param _far
		 * 
		 */
		function setProjectionOrtho( _width:Number, _height:Number, _near:Number, _far:Number ):void;
		/**
		 * Sets the projection matrix to Asymmetric Orthographic Projection
		 * @param _left
		 * @param _right
		 * @param _bottom
		 * @param _top
		 * @param _near
		 * @param _far
		 * 
		 */
		function setProjectionOrthoAsymmetric( _left:Number, _right:Number, _bottom:Number, _top:Number, _near:Number, _far:Number ):void;
		
		/**
		 * Sets the projection matrix to Perspective Projection
		 * @param _fovy Field of View
		 * @param _aspect Viewport Aspect Ratio 
		 * @param _near Near plane
		 * @param _far Far Plane
		 * 
		 */
		function setProjectionPerspective( _fovy:Number, _aspect:Number, _near:Number, _far:Number ):void;
		/**
		 * Sets the projection matrix to Asymmetric Perspective Projection
		 * @param _left
		 * @param _right
		 * @param _bottom
		 * @param _top
		 * @param _near
		 * @param _far
		 * 
		 */
		function setProjectionPerspectiveAsymmetric( _width:Number, _height:Number, _near:Number, _far:Number ):void;

	
		function get frustum():Frustum;
		function extractPlanes():void ;
	}
}
