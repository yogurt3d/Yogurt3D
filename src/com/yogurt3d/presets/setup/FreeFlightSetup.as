package com.yogurt3d.presets.setup
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.Scene;
	import com.yogurt3d.core.setup.SetupBase;
	import com.yogurt3d.core.viewports.Viewport;
	import com.yogurt3d.presets.cameras.FreeFlightCamera;
	import com.yogurt3d.presets.cameras.TargetCamera;
	import com.yogurt3d.presets.renderers.molehill.MolehillRenderer;
	
	import flash.display.DisplayObjectContainer;

	public class FreeFlightSetup extends SetupBase
	{
		public function FreeFlightSetup(_parent:DisplayObjectContainer)
		{
			super( _parent );
			
			viewport = new Viewport();
			if( _parent.stage )
			{
				viewport.setViewport(0,0,_parent.stage.stageWidth,_parent.stage.stageHeight);
			}else{
				viewport.setViewport(0,0,_parent.width,_parent.height);
			}
			
			YOGURT3D_INTERNAL::scene = new Scene();
			
			YOGURT3D_INTERNAL::camera = new FreeFlightCamera(viewport);
			
			ready();
		}
		
		public function get scene():Scene{
			return YOGURT3D_INTERNAL::scene as Scene;
		}
		public function set scene(value:Scene):void{
			YOGURT3D_INTERNAL::scene = value;
		}
		
		public function get camera():FreeFlightCamera{
			return YOGURT3D_INTERNAL::camera as FreeFlightCamera;
		}
		
		public function set camera(value:FreeFlightCamera):void{
			YOGURT3D_INTERNAL::camera = value;
		}
	}
}