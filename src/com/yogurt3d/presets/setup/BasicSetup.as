package com.yogurt3d.presets.setup
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.Scene;
	import com.yogurt3d.core.setup.SetupBase;
	import com.yogurt3d.core.viewports.Viewport;
	import com.yogurt3d.presets.cameras.TargetCamera;
	import com.yogurt3d.presets.renderers.molehill.MolehillRenderer;
	
	import flash.display.DisplayObjectContainer;

	public class BasicSetup extends SetupBase
	{
		public function BasicSetup(_parent:DisplayObjectContainer)
		{
			super( _parent );
			
			viewport = new Viewport();
			viewport.setViewport(0,0,_parent.stage.stageWidth,_parent.stage.stageHeight);
			
			YOGURT3D_INTERNAL::scene = new Scene();
			
			YOGURT3D_INTERNAL::camera = new Camera();
			
			ready();
		}
		
		public function get scene():Scene{
			return YOGURT3D_INTERNAL::scene as Scene;
		}
		public function set scene(value:Scene):void{
			YOGURT3D_INTERNAL::scene = value;
		}
		
		public function get camera():Camera{
			return YOGURT3D_INTERNAL::camera as Camera;
		}
		
		public function set camera(value:Camera):void{
			YOGURT3D_INTERNAL::camera = value;
		}
	}
}