/*
 * FrustrumPlaneAABB.as
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
package com.yogurt3d.core.culling
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	use namespace YOGURT3D_INTERNAL;
	/**
	  * NOTE: This class is not fully complete. Even may not work at all. Use this at your own risk.
	  * 
 	  * @author Yogurt3D Engine Core Team
 	  * @company Yogurt3D Corp.
 	  **/
	public class FrustrumPlaneAABB
	{
		public static var DEBUG_TEXT:String = "";
		
		public static function cullResult(_objects:Vector.<ISceneObjectRenderable>, _camera:Camera):Vector.<ISceneObjectRenderable> {
			var _timer				:Number = getTimer();
			var _result				:Vector.<ISceneObjectRenderable> = new Vector.<ISceneObjectRenderable>();			
			var _aabb				:AxisAlignedBoundingBox;
			var _object				:ISceneObjectRenderable;
			
			var _numberOfObjects	:int = _objects.length;	
			
			var _farPlane			:Vector3D// = _camera.frustumPlaneFar;
			var _nearPlane			:Vector3D// = _camera.frustumPlaneNear;
			var _leftPlane			:Vector3D// = _camera.frustumPlaneLeft;
			var _rightPlane			:Vector3D// = _camera.frustumPlaneRight;
			var _topPlane			:Vector3D// = _camera.frustumPlaneTop;
			var _bottomPlane		:Vector3D// = _camera.frustumPlaneBottom;
			
			var _cameraInverse		:Matrix3D = _camera.transformation.matrixGlobal.clone();
			_cameraInverse.invert();
			
			var _objectTransform	:Matrix3D = new Matrix3D();
			_objectTransform.identity();
			for (var i:int = 0; i < _numberOfObjects; i++) {
				_object 					= _objects[i];
				_objectTransform.copyFrom( _object.transformation.matrixGlobal );             // 9ms
				//_objectTransform.rawData =  _object.transformation.m_matrixGlobal.rawData;    // 10ms
				


				_aabb						= _object.geometry.axisAlignedBoundingBox;  
				_objectTransform.append(_cameraInverse);//1ms
				
				_aabb.update( _objectTransform ); // 15ms
				
				var _center				:Vector3D 	= _aabb.center;
				var _extent				:Vector3D 	= _aabb.halfSize;
				
				var _top				:Number 	= _center.y + _extent.y;
				var _bottom				:Number		= _center.y - _extent.y;
				
				var _left				:Number		= _center.x - _extent.x;
				var _right				:Number		= _center.x + _extent.x;
				
				var _far				:Number		= _center.z + _extent.z;
				var _near				:Number		= _center.z - _extent.z;
				
				
				if ( 	(_leftPlane.x 	* _right 	+ _leftPlane.y 		* _bottom 	+ _leftPlane.z 		* _far 		+ _leftPlane.w) 	< 0 || 	// left  plane vs right bottom far
						(_rightPlane.x 	* _left 	+ _rightPlane.y 	* _bottom 	+ _rightPlane.z 	* _far 		+ _rightPlane.w) 	< 0 || 	// right plane vs left  bottom far
						(_topPlane.x 	* _left 	+ _topPlane.y 		* _bottom 	+ _topPlane.z 		* _far 		+ _topPlane.w) 		< 0 ||	// top plane vs left bottom far
						(_bottomPlane.x * _left 	+ _bottomPlane.y 	* _top	 	+ _bottomPlane.z 	* _far 		+ _bottomPlane.w) 	< 0 || 	// bottom plane left top far
						(_nearPlane.x 	* _left 	+ _nearPlane.y 		* _bottom 	+ _nearPlane.z 		* _far	 	+ _nearPlane.w) 	< 0 ||
						(_farPlane.x 	* _left 	+ _farPlane.y 		* _bottom 	+ _farPlane.z 		* _near 	+ _farPlane.w) 		< 0 
				) {
					
				}else{
					//_result.push(_object);
				}
				
				/*if ((_leftPlane.x 	* _right 	+ _leftPlane.y 		* _bottom 	+ _leftPlane.z 		* _far 		+ _leftPlane.w) 	< 0) {
					
				} else if ((_rightPlane.x 	* _left 	+ _rightPlane.y 	* _bottom 	+ _rightPlane.z 	* _far 		+ _rightPlane.w) 	< 0) {
					
				} else if ((_topPlane.x 	* _left 	+ _topPlane.y 		* _bottom 	+ _topPlane.z 		* _far 		+ _topPlane.w) 		< 0) {
					
				} else if ((_bottomPlane.x * _left 	+ _bottomPlane.y 	* _top	 	+ _bottomPlane.z 	* _far 		+ _bottomPlane.w) 	< 0 ) {
					
				} else if ((_nearPlane.x 	* _left 	+ _nearPlane.y 		* _bottom 	+ _nearPlane.z 		* _far	 	+ _nearPlane.w) 	< 0 ) {
					
				} else if ((_farPlane.x 	* _left 	+ _farPlane.y 		* _bottom 	+ _farPlane.z 		* _near 	+ _farPlane.w) 		< 0) {
					
				} else {*/
					_result.push(_object);
				//}
			}
			DEBUG_TEXT = "Input count :"+_numberOfObjects+" \n output count:"+_result.length+" \n time: "+(getTimer() - _timer);
			return _result;
		}
	}
}
