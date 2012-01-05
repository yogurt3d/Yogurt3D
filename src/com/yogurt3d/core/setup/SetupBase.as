package com.yogurt3d.core.setup
{
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.managers.contextmanager.Context;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.renderers.interfaces.IRenderer;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.viewports.Viewport;
	import com.yogurt3d.presets.renderers.molehill.MolehillRenderer;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	public class SetupBase
	{
		private var m_context:Context;
		
		private var m_parent:DisplayObjectContainer;
		
		public function SetupBase(_parent:DisplayObjectContainer)
		{
			Yogurt3D.instance;
			
			m_parent = _parent;
			
			m_context = new Context();
			
			renderer = new MolehillRenderer();
			
		}
		
		protected function ready():void{
			Yogurt3D.instance.contextManager.addContext( m_context );
			
			Yogurt3D.instance.startAutoUpdate();
		}
		
		public function get context():Context
		{
			return m_context;
		}

		public function set context(value:Context):void
		{
			m_context = value;
		}

		public function get renderer():IRenderer
		{
			return m_context.renderer;
		}
		
		public function set renderer(value:IRenderer):void
		{
			m_context.renderer = value;
		}
		
		YOGURT3D_INTERNAL function get scene():IScene
		{
			return m_context.scene;
		}
		
		YOGURT3D_INTERNAL function set scene(value:IScene):void
		{
			m_context.scene = value;
			if( m_context.scene && m_context.camera &&
				(!m_context.scene.cameraSet || 
					m_context.scene.cameraSet.indexOf( m_context.camera ) == -1)
			)
			{
				m_context.scene.addChild( m_context.camera );
			}
		}

		YOGURT3D_INTERNAL function get camera():Camera
		{
			return m_context.camera;
		}

		YOGURT3D_INTERNAL function set camera(value:Camera):void
		{
			m_context.camera = value;
			if( m_context.scene && 
				(!m_context.scene.cameraSet || 
				m_context.scene.cameraSet.indexOf( value ) == -1)
			)
			{
				m_context.scene.addChild( value );
			}
		}

		public function get viewport():Viewport
		{
			return m_context.viewport;
		}

		public function set viewport(value:Viewport):void
		{
			if( m_context.viewport )
			{
				m_parent.removeChild( m_context.viewport );
			}
			m_context.viewport = value;
			m_parent.addChildAt( m_context.viewport, 0 );
		}
		
		public function setArea( x:uint, y:uint, width:uint, height:uint):void{
			m_context.viewport.setViewport( x,y,width,height );
		}
	}
}