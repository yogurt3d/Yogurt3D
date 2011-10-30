package com.yogurt3d.core.plugin
{
	public class Plugin
	{
		public function Plugin()
		{
		}
		
		public function registerPlugin( _kernel:Kernel ):Boolean{
			throw new Error("This function must be overriden by your plugin.");
		}
	}
}