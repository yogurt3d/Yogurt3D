package com.yogurt3d.presets.primitives.test
{
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	
	public class TestTriangleObject extends SceneObjectRenderable
	{
		YOGURT3D_INTERNAL var m_width:Number;
		YOGURT3D_INTERNAL var m_height:Number;
		
		use namespace YOGURT3D_INTERNAL;
		
		
		
		public function TestTriangleObject( _width:Number = 10, _height:Number = 10)
		{
			m_width = _width;
			m_height = _height;
			
			super();
			
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			
			m_geometry = new TestTriangleMesh( m_width, m_height);
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, TestTriangleObject);
		}
	}
}