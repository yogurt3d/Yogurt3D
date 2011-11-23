package com.yogurt3d.core.utils
{
	import flash.geom.Vector3D;

	public class MathUtils
	{
		public static const DEG_TO_RAD								:Number				= Math.PI / 180.0;
		public static const RAD_TO_DEG								:Number				= 180.0 / Math.PI;		
		
		public static const UP_VECTOR								:Vector3D			= new Vector3D(0,-1,0);
		public static const AT_VECTOR								:Vector3D			= new Vector3D(0,0,-1);
		
		public static const PI										:Number				= 4 * Math.atan( 1.0 );
		
		public static function getClosestPowerOfTwo(value : uint) : uint
		{
			var tmp:uint = 1;
			while (tmp < value)
				tmp <<= 1;
			return tmp;
		}
		
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