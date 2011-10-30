/*
 * ViewportLayer.as
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
 
 
package com.yogurt3d.core.viewports {
	import flash.display.IGraphicsData;
	import flash.display.Sprite;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	[Deprecated("Used for creating layers inside a viewport. Unneeded due to Z-Buffer.")]
	public class ViewportLayer extends Sprite {

		private var m_graphicsData : Vector.<IGraphicsData>;		

		public function ViewportLayer() {
			m_graphicsData = new Vector.<IGraphicsData>();
		}

		public function get graphicsData() : Vector.<IGraphicsData> {
			return m_graphicsData;
		}

		public function set graphicsData(_graphicsData : Vector.<IGraphicsData>) : void {
			this.m_graphicsData = _graphicsData;
		}
	}
}
