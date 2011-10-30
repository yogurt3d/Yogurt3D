/*
 * BoxSceneObject.as
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
	import com.yogurt3d.presets.primitives.meshs.BoxMesh;
	
	public class BoxSceneObject extends SceneObjectRenderable
	{
		YOGURT3D_INTERNAL var m_width				:Number;
		YOGURT3D_INTERNAL var m_height				:Number;
		YOGURT3D_INTERNAL var m_length				:Number;
		YOGURT3D_INTERNAL var m_widthSegments		:Number;
		YOGURT3D_INTERNAL var m_heightSegments		:Number;
		YOGURT3D_INTERNAL var m_lengthSegments		:Number;
		
		use namespace YOGURT3D_INTERNAL;
		/**
		 * 
		 * 
	 	 * @author Yogurt3D Engine Core Team
	 	 * @company Yogurt3D Corp.
	 	 **/
		public function BoxSceneObject( _width:Number = 10.0, _height:Number = 10.0, _length:Number = 10.0, _widthSegments:int = 1, _heightSegments:int = 1, _lengthSegments:int = 1)
		{
			m_width				= _width;
			m_height			= _height;
			m_length			= _length;
			m_widthSegments		= _widthSegments;
			m_heightSegments	= _heightSegments;
			m_lengthSegments	= _lengthSegments;
			
			super();
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, BoxSceneObject);
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			
			geometry		= new BoxMesh( m_width, m_height, m_length, m_widthSegments, m_heightSegments, m_lengthSegments );
		}
	}
}
