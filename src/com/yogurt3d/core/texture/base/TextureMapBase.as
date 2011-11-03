package com.yogurt3d.core.texture.base
{
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.utils.Dictionary;

	public class TextureMapBase implements ITexture
	{
		use namespace YOGURT3D_INTERNAL;
		
		YOGURT3D_INTERNAL var m_type:ETextureType;
		
		YOGURT3D_INTERNAL var m_context3DMap				:Dictionary;
		
		YOGURT3D_INTERNAL var m_width			:uint;
		YOGURT3D_INTERNAL var m_height			:uint;
		
		public function TextureMapBase(type:ETextureType)
		{
			m_context3DMap = new Dictionary();
			
			m_type = type;
		}
		
		public function get height():uint
		{
			return YOGURT3D_INTERNAL::m_height;
		}

		public function get width():uint
		{
			return YOGURT3D_INTERNAL::m_width;
		}

		public function get type():ETextureType
		{
			return YOGURT3D_INTERNAL::m_type;
		}

		public function getTexture3D(_context3D:Context3D):TextureBase{
			return null;
		}
		
		protected function mapTextureForContext( texture:TextureBase, context:Context3D ):void
		{
			if( m_context3DMap[ context ] && m_context3DMap[ context ] != texture)
			{
				m_context3DMap[ context ].dispose();
			}
			m_context3DMap[ context ] = texture;
		}
		protected function hasTextureForContext( context:Context3D ):Boolean{
			return m_context3DMap[ context ]!=null;
		}
		protected function getTextureForContext( context:Context3D ):TextureBase
		{
			return m_context3DMap[ context ];
		}
		
		public function dispose():void{
			for each( var _texture:TextureBase in m_context3DMap )
			{
				_texture.dispose();
			}
			m_context3DMap = null;
		}
	}
}