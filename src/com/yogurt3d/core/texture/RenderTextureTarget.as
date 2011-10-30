package com.yogurt3d.core.texture
{
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.texture.base.ETextureType;
	import com.yogurt3d.core.texture.base.TextureMapBase;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	
	public class RenderTextureTarget extends TextureMapBase
	{
		use namespace YOGURT3D_INTERNAL;
		public function RenderTextureTarget(width:uint, height:uint)
		{
			super(ETextureType.RTT);
			m_width = width;
			m_height = height;
		}
		
		public override function getTexture3D(_context3D:Context3D):TextureBase{
			if(!hasTextureForContext( _context3D ) )
			{
				var _texture:Texture = _context3D.createTexture(m_width,m_height, Context3DTextureFormat.BGRA, true );
				mapTextureForContext( _texture, _context3D );
				return _texture;
			}
			return getTextureForContext( _context3D );
		}

	}
}