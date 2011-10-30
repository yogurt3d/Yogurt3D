/*
 * Vector3DUtils.as
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
 
 
package com.yogurt3d.core.utils
{
	import flash.geom.Vector3D;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class Vector3DUtils
	{
		/**
		 * Linear interpolation from vec1 to vec2 at time t 
		 * @param _t
		 * @param _vec1
		 * @param _vec2
		 * @return 
		 * 
		 */		
		public static function lerp( _t:Number, _vec1:Vector3D, _vec2:Vector3D ):Vector3D{
			_vec2 = _vec2.clone();
			_vec2.subtract( _vec1 );
			return new Vector3D(
				_vec1.x + _t * (_vec2.x - _vec1.x),
				_vec1.y + _t * (_vec2.y - _vec1.y),
				_vec1.z + _t * (_vec2.z - _vec1.z),
				_vec1.w + _t * (_vec2.w - _vec1.w)
				);
			
		}
	}
}
