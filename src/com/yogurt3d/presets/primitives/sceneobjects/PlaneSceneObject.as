/*
 * PlaneSceneObject.as
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
 
 
package com.yogurt3d.presets.primitives.sceneobjects
{
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.presets.primitives.meshs.PlaneMesh;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class PlaneSceneObject extends SceneObjectRenderable
	{
		YOGURT3D_INTERNAL var m_width				:Number;
		YOGURT3D_INTERNAL var m_height				:Number;
		YOGURT3D_INTERNAL var m_hSegments			:Number;
		YOGURT3D_INTERNAL var m_vSegments			:Number;
		YOGURT3D_INTERNAL var m_normalX				:Number;
		YOGURT3D_INTERNAL var m_normalY				:Number;
		YOGURT3D_INTERNAL var m_normalZ				:Number;
		
		use namespace YOGURT3D_INTERNAL;
		
		public function PlaneSceneObject( _width:Number = 1.0, _height:Number = 1.0, _hSegments:int = 1, _vSegments:int = 1, _normalX:Number = 0.0, _normalY:Number = 1.0, _normalZ:Number = 0.0 )
		{
			m_width				= _width;
			m_height			= _height;
			m_hSegments			= _hSegments;
			m_vSegments			= _vSegments; 
			
			m_normalX			= _normalX;
			m_normalY			= _normalY;
			m_normalZ			= _normalZ;
			
			super();
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, PlaneSceneObject);
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			
			geometry		= new PlaneMesh( m_width, m_height, m_hSegments, m_vSegments, m_normalX, m_normalY, m_normalZ );
			
			this.userID = "PlaneSceneObject";
		}
	}
}
