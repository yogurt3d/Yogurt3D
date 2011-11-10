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
	import com.yogurt3d.core.frustum.Frustum;
	
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
		
		private var m_frustum :Frustum;
		
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
		 * 
		 */		
		override protected function initInternals():void
		{
			super.initInternals();
			
			m_projectionMatrix			= new Matrix3D();
			
			m_frustum = new Frustum();
			
			m_frustum.setProjectionPerspective( 45.0, 4.0/3.0, 1.0, 500.0 );
		}
		

		
	}
}
