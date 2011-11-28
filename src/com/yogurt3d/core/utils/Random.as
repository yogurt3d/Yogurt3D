package com.yogurt3d.core.utils
{
	public class Random
	{
		public static function range( min:Number, max:Number ):Number{
			return (Math.random() * max - min) + min;
		}
	}
}