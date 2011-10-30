/*
 * TransformationUtils.as
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
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class TransformationUtils
	{
		public static const PI:Number 			= 3.141592653589793238462643;
		public static const DTOR:Number      	= 0.0174532925;
		public static const RTOD:Number      	= 57.2957795;
		
		public static function matrix2euler( m :Matrix3D, euler:Vector3D=null, scale:Vector3D=null ) : Vector3D
		{
			euler = euler || new Vector3D();
			var rawData:Vector.<Number> = m.rawData;
			var r11:Number = rawData[0];
			var r21:Number = rawData[1];
			var r31:Number = rawData[2];
			var r12:Number = rawData[4];
			var r22:Number = rawData[5];
			var r32:Number = rawData[6];
			var r13:Number = rawData[8];
			var r23:Number = rawData[9];
			var r33:Number = rawData[10];
			
			
			// need to get rid of scale
			// TODO: whene scale is uniform, we can save some cycles. s = 3x3 determinant i beleive
			var sx		:Number = (scale && scale.x == 1) ? 1 : Math.sqrt(r11 * r11 + r21 * r21 + r31 * r31);
			var sy		:Number = (scale && scale.y == 1) ? 1 : Math.sqrt(r12 * r12 + r22 * r22 + r32 * r32);
			var sz		:Number = (scale && scale.z == 1) ? 1 : Math.sqrt(r13 * r13 + r23 * r23 + r33 * r33);
			
			var n11		:Number = r11 / sx;
			var n21		:Number = r21 / sy;
			var n31		:Number = r31 / sz;
			var n32		:Number = r32 / sz;
			var n33		:Number = r33 / sz;
			
			n31 = n31 > 1 ? 1 : n31;
			n31 = n31 < -1 ? -1 : n31;
			
			// zyx
			euler.y = Math.asin(-n31);
			euler.z = Math.atan2(n21, n11);
			euler.x = Math.atan2(n32, n33);
			
			// TODO: fix singularities
			
			// yzx
			//euler.z = Math.asin(-r21);
			//euler.y = Math.atan2(r31, r11);
			//euler.x = Math.atan2(-r23, r22);
			
			// zxy
			//euler.x = Math.asin(-r32);
			//euler.z = Math.atan2(-r12, r22);
			//euler.y = Math.atan2(-r31, r33);
			
			euler.x *= RTOD;
			euler.y *= RTOD;
			euler.z *= RTOD;
			
			//  Clamp values
			// euler.x = euler.x < 0 ? euler.x + 360 : euler.x;
			// euler.y = euler.y < 0 ? euler.y + 360 : euler.y;
			// euler.z = euler.z < 0 ? euler.z + 360 : euler.z;
			
			return euler;
		}
	}
}
