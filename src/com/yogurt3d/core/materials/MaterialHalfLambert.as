package com.yogurt3d.core.materials
{
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.materials.shaders.ShaderHalfLambert;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.texture.TextureMap;
	
	public class MaterialHalfLambert extends Material
	{
		
		private var m_shader:ShaderHalfLambert;
		
		public function MaterialHalfLambert(_texture:TextureMap,
											_alpha:Number=0.5,
											_beta:Number=0.5,
											_gamma:Number=1.0,
											_opacity:Number=1.0,
											_initInternals:Boolean=true)
		{
			super(_initInternals);
			
			shaders = Vector.<com.yogurt3d.core.materials.shaders.base.Shader>([
				m_shader = new ShaderHalfLambert(_texture,_alpha, _beta, _gamma,_opacity),
				
			]);
			
			super.opacity = _opacity;
		}
		
		public function get alpha():Number{
			return m_shader.alpha;
		}
		public function set alpha(_value:Number):void{
			m_shader.alpha = _value;
		}
		
		public function get beta():Number{
			return m_shader.beta;
		}
		public function set beta(_value:Number):void{
			m_shader.beta = _value;
		}
		
		public function get gamma():Number{
			return m_shader.gamma;
		}
		public function set gamma(_value:Number):void{
			m_shader.gamma = _value;
		}
		
		public override function get opacity():Number{
			return m_shader.opacity;
		}
		public override function set opacity(_value:Number):void{
			m_shader.opacity = _value;
		}
		
		public function get texture():TextureMap{
			return m_shader.texture;
		}
		public function set texture(_value:TextureMap):void{
			m_shader.texture = _value;
		}
	}
}