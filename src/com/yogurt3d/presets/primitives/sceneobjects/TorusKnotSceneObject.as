/*
 * TorusKnotSceneObject.as
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
	import com.yogurt3d.presets.primitives.meshs.TorusKnotMesh;
	
	public class TorusKnotSceneObject extends TorusSceneObject
	{
	
		YOGURT3D_INTERNAL var m_heightScale 	: Number;
		YOGURT3D_INTERNAL var m_p 				: uint;
		YOGURT3D_INTERNAL var m_q 				: uint;
		
		use namespace YOGURT3D_INTERNAL;
		
		/**
		 * 
		 * @param _radius
		 * @param _tubeRadius
		 * @param _segmentsR
		 * @param _segmentsT
		 * @param _yUp
		 * @param _p 
		 * @param _q
		 * @param _heightScale
		 * 
		 */
		public function TorusKnotSceneObject(_radius:Number  = 100.0, _tubeRadius:Number = 40.0, _segmentsR:uint = 8, 
											 _segmentsT:uint = 6, _yUp:Boolean = false, _p:uint = 2, _q:uint = 3, 
											_heightScale:Number = 1) 
		{
			m_p = _p;
			m_q = _q;
			m_heightScale = _heightScale;
			super(_radius, _tubeRadius, _segmentsR, _segmentsT, _yUp );
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, TorusKnotSceneObject);
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			
			geometry		= new TorusKnotMesh(m_radius, m_tubeRadius, m_segmentsR, 
								m_segmentsT, m_yUp, m_p, m_q, m_heightScale);
		}
	}
}