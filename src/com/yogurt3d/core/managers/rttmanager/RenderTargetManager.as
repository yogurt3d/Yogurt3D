package com.yogurt3d.core.managers.rttmanager
{
	import com.yogurt3d.core.materials.base.Color;
	import com.yogurt3d.core.texture.RenderTextureTarget;
	import com.yogurt3d.core.texture.base.ETextureType;
	
	import flash.display3D.Context3D;
	

	public final class RenderTargetManager
	{
		private static var m_instance:RenderTargetManager;
		
		private var m_renderTo:RenderTextureTarget;
		
		public function RenderTargetManager(enforcer:SingletonEnforcer)
		{
		
		}
		
		public static function get instance():RenderTargetManager{
			if( m_instance == null )
			{
				m_instance = new RenderTargetManager(new SingletonEnforcer());
			}
			return m_instance;
		}
		
		public function setRenderTo( _context3d:Context3D, target:RenderTextureTarget, _clean:Boolean = true, _cleanColor:Color = null,  _surface:uint = 0 ):void{
			if( target.type == ETextureType.RTT )
			{
				_context3d.setRenderToTexture( target.getTexture3D(_context3d), true);
			}else if( target.type == ETextureType.RTT_CUBE )
			{
				_context3d.setRenderToTexture( target.getTexture3D(_context3d), true, 0, _surface);
			}else if( target.type == ETextureType.BACK_BUFFER )
			{
				if( m_renderTo != null )
				{
					_context3d.setRenderToBackBuffer();
				}
			}
			if( _clean )
			{
				if( _cleanColor )
				{
					_context3d.clear(_cleanColor.r,_cleanColor.g,_cleanColor.b,_cleanColor.a);
				}else{
					_context3d.clear(1,1,1,1);
				}
			}
			m_renderTo = target;
		}
		
		public function getRenderTarget():RenderTextureTarget{
			return m_renderTo;
		}
	}
}

internal class SingletonEnforcer {}