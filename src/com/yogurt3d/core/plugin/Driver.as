package com.yogurt3d.core.plugin
{
	public class Driver
	{
		public function get name():String{
			throw new Error("This function must be overriden by your driver.");
		}
		public function toString():String{
			return "[Driver] " + name;
		}
	}
}