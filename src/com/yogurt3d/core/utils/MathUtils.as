package com.yogurt3d.core.utils
{
	public class MathUtils
	{
		public static function getClosestPowerOfTwo(value : uint) : uint
		{
			var tmp:uint = 1;
			while (tmp < value)
				tmp <<= 1;
			return tmp;
		}
	}
}