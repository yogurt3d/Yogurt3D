/*
 * TorusSceneObject.as
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
	import com.yogurt3d.presets.primitives.meshs.TorusMesh;
	
	public class TorusSceneObject  extends SceneObjectRenderable
	{
		YOGURT3D_INTERNAL var m_radius		:Number;//radius of the torus
		YOGURT3D_INTERNAL var m_tubeRadius	:Number;//tube radius of the torus
		YOGURT3D_INTERNAL var m_segmentsR	:uint;//radial segments
		YOGURT3D_INTERNAL var m_segmentsT	:uint;//tubular segments
		YOGURT3D_INTERNAL var m_yUp			:Boolean;//whether the coordinates of the torus points use a yUp orientation (true) 
													//or a zUp orientation (false)

		use namespace YOGURT3D_INTERNAL;
		
		public function TorusSceneObject(_radius:Number  = 100.0, _tubeRadius:Number = 40.0, _segmentsR:uint = 8, 
										 _segmentsT:uint = 6, _yUp:Boolean = false)
		{
			m_radius = _radius;
			m_tubeRadius = _tubeRadius;
			m_segmentsR = _segmentsR;
			m_segmentsT = _segmentsT;
			m_yUp = _yUp;
			
			super();
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, TorusSceneObject);
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			
			geometry		= new TorusMesh(m_radius, m_tubeRadius, m_segmentsR, 
											m_segmentsT, m_yUp);
		}
	}
}