package com.yogurt3d.core.scenetree
{
	import com.yogurt3d.core.plugin.Kernel;
	import com.yogurt3d.core.plugin.Plugin;
	import com.yogurt3d.core.plugin.Server;
	import com.yogurt3d.core.scenetree.octree.OcTreeSceneTreeManagerDriver;
	import com.yogurt3d.core.scenetree.quad.QuadSceneTreeManagerDriver;
	import com.yogurt3d.core.scenetree.simple.SimpleSceneTreeManagerDriver;
	

	[Plugin]
	public class SceneTreePlugins extends Plugin
	{
		public static const SERVERNAME:String = "sceneTreeManagerServer";
		public static const SERVERVERSION:uint = 1;
		
		public override function registerPlugin(_kernel:Kernel):Boolean{
			var server:Server = _kernel.getServer( SERVERNAME );
			if( server )
			{
				var drivers:Array = [SimpleSceneTreeManagerDriver, QuadSceneTreeManagerDriver, OcTreeSceneTreeManagerDriver];
				
				var success:uint = drivers.length;
				
				for( var i:int = 0; i < drivers.length; i++)
				{
					if( server.addDriver( new drivers[i](), SERVERVERSION ) )
					{
						success--;
					}
				}
				
				
				return (success == 0);
			}
			return false;
		}
	}
}