package com.yogurt3d.core.materials
{
	
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.materials.shaders.ShaderAmbient;
	import com.yogurt3d.core.materials.shaders.ShaderEnvMapping;
	import com.yogurt3d.core.materials.shaders.ShaderSpecular;
	import com.yogurt3d.core.materials.shaders.ShaderTexture;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	
	/**
	 * 
	 * @author Yogurt3D Corp. Core Team
	 *  
	 */
	public class MaterialEnvMappingSpecular extends Material
	{
		private var m_envMap:CubeTextureMap;
		private var m_colorMap:TextureMap;
		private var m_normalMap:TextureMap;
		private var m_specularMap:TextureMap;
		private var m_reflectivityMap:TextureMap;
		private var m_alpha:Number;

		private var m_lightShader:ShaderSpecular;
		private var m_envShader:ShaderEnvMapping;
		private var m_ambShader:ShaderAmbient;
		public  var m_decalShader:ShaderTexture;
		
		
		public function MaterialEnvMappingSpecular( _envMap:CubeTextureMap, 
															  _colorMap:TextureMap=null,
															  _normalMap:TextureMap=null,
															  _specularMap:TextureMap=null,
															  _reflectivityMap:TextureMap=null,
															  _alpha:Number=1.0,
															  _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			m_envMap = _envMap;		
			m_colorMap = _colorMap;
			m_alpha = _alpha;
			
			m_reflectivityMap = _reflectivityMap;
			
			m_envShader = new ShaderEnvMapping(_envMap, _normalMap, null, m_alpha);
			m_ambShader = new ShaderAmbient();
			
			shaders = new Vector.<com.yogurt3d.core.materials.shaders.base.Shader>;
			
			shaders.push(m_ambShader);	
			shaders.push(m_lightShader = new ShaderSpecular());
			
			
			if(m_colorMap != null){
				m_decalShader = new ShaderTexture(m_colorMap);
				m_decalShader.params.blendEnabled = true;
				m_decalShader.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
				m_decalShader.params.blendDestination = Context3DBlendFactor.ZERO;
				m_decalShader.params.depthFunction = Context3DCompareMode.EQUAL;
				shaders.push(m_decalShader);
			}
			
			shaders.push(m_envShader);
			
			normalMap = _normalMap;
			specularMap = _specularMap;
		}
		
		public function get envMap():CubeTextureMap
		{
			return m_envMap;
		}
		public function set envMap(value:CubeTextureMap):void
		{
			m_envMap = value;
			m_envShader.envMap = value;
		}
		
		public function get texture():TextureMap
		{
			return m_colorMap;
		}
		public function set texture(value:TextureMap):void
		{
			
			m_colorMap = value;
			if( value )
			{
				if( m_decalShader )
				{
					m_decalShader.texture = m_colorMap;
				}else{
					if(m_colorMap != null){
						m_decalShader = new ShaderTexture(m_colorMap);
						m_decalShader.params.blendEnabled = true;
						m_decalShader.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
						m_decalShader.params.blendDestination = Context3DBlendFactor.ZERO;
						m_decalShader.params.depthFunction = Context3DCompareMode.EQUAL;
						shaders.splice(2,0,m_decalShader);
					}
				}
			}else{
				if( m_decalShader )
				{
					shaders.splice(2,1);
					m_decalShader.dispose();
					m_decalShader = null;
				}
			}
		}
		
		public function get normalMap():TextureMap
		{
			return m_normalMap;
		}
		public function set normalMap(value:TextureMap):void
		{
			m_normalMap = value;
			m_envShader.normalMap = value;
			m_lightShader.normalMap = value;
		}
		
		public function get specularMap():TextureMap
		{
			return m_normalMap;
		}
		public function set specularMap(value:TextureMap):void
		{
			m_specularMap = value;
			m_lightShader.specularMap = value;
		}
		
		public function get reflectivityMap():TextureMap
		{
			return m_reflectivityMap;
		}
		public function set reflectivityMap(value:TextureMap):void
		{
			m_reflectivityMap = value;
			m_envShader.reflectivityMap = value;
		}
		
		public function get alpha():Number
		{
			return m_alpha;
		}
		public function set alpha(_alpha:Number):void{
			m_envShader.alpha = _alpha;	
			m_alpha = _alpha;
		}
		
		public function get shininess():Number{
			return m_lightShader.shininess;
		}
		public function set shininess(_value:Number):void{
			m_lightShader.shininess = _value;
		}
		
		public override function set opacity(value:Number):void{
			super.opacity = value;
			m_ambShader.opacity = value;
		}
	
	}
}