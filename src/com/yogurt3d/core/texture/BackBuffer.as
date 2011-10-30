package com.yogurt3d.core.texture
{
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.texture.base.ETextureType;
	import com.yogurt3d.core.texture.base.TextureMapBase;
	
	import flash.display3D.Context3D;
	import flash.display3D.textures.TextureBase;
	
	public class BackBuffer extends RenderTextureTarget
	{
		public function BackBuffer()
		{
			super(0,0);
			YOGURT3D_INTERNAL::m_type = ETextureType.BACK_BUFFER;
		}
		public override function getTexture3D(_context3D:Context3D):TextureBase{
			return null;
		}
	}
}