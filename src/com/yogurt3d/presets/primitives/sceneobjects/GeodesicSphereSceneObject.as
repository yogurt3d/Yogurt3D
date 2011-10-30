/*
 * GeodesicSphereSceneObject.as
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
	import com.yogurt3d.presets.primitives.meshs.GeodesicSphereMesh;
	
	public class GeodesicSphereSceneObject  extends SceneObjectRenderable
	{
		YOGURT3D_INTERNAL var m_radius		:Number;//radius of the torus
		YOGURT3D_INTERNAL var m_fractures	:uint;//tube radius of the torus
		
		use namespace YOGURT3D_INTERNAL;
		
		public function GeodesicSphereSceneObject(_radius:Number  = 100.0, _fractures:uint = 2)
		{
			m_radius = _radius;
			m_fractures = _fractures;
			
			super();
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, GeodesicSphereSceneObject);
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			
			geometry		= new GeodesicSphereMesh(m_radius, m_fractures);
		}
	}
}