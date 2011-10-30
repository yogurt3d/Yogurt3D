package com.yogurt3d.core.materials
{
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.materials.shaders.ShaderHemisphereTexture;
	import com.yogurt3d.core.texture.TextureMap;
	
	public class MaterialHemisphereTexture extends Material
	{
		public function MaterialHemisphereTexture(texture:TextureMap, _initInternals:Boolean=true)
		{
			super(_initInternals);
			shaders.push( hemi = new ShaderHemisphereTexture(texture) );
			m_texture = texture;
			ambientColor.a = 1;
		}
		
		public function get alphaTexture():Boolean
		{
			return hemi.alphaTexture;
		}

		public function set alphaTexture(value:Boolean):void
		{
			hemi.alphaTexture = value;
		}

		public function get texture():TextureMap
		{
			return m_texture;
		}

		public function set texture(value:TextureMap):void
		{
			m_texture = value;
		}

		private var m_texture:TextureMap;
		public var hemi:ShaderHemisphereTexture;
		
		
		
	}
}