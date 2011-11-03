package com.yogurt3d.core.materials
{
	
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.materials.shaders.ShaderAmbient;
	import com.yogurt3d.core.materials.shaders.ShaderEnvMapFresnel;
	import com.yogurt3d.core.materials.shaders.ShaderSpecular;
	import com.yogurt3d.core.materials.shaders.ShaderTexture;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display3D.Context3DBlendFactor;
	
	/**
	 * 
	 * @author Yogurt3D Corp. Core Team
	 *  
	 */
	public class MaterialEnvMapFresnelSpecularTexture extends Material
	{
		
		private var m_envMap:CubeTextureMap;
		private var m_colorMap:TextureMap;
		private var m_normalMap:TextureMap;
		private var m_specularMap:TextureMap;
		private var m_reflectivityMap:TextureMap;;
		private var m_alpha:Number;
		
		private var m_fresnelReflectance:Number;
		private var m_fresnelPower:uint;
		
		private var lightShader:ShaderSpecular;
		private var m_envShader:ShaderEnvMapFresnel;
		private var m_ambShader:ShaderAmbient;

			
		public function MaterialEnvMapFresnelSpecularTexture( _envMap:CubeTextureMap=null, 
											   _colorMap:TextureMap=null,
											   _normalMap:TextureMap=null,
											   _specularMap:TextureMap=null,
											   _reflectivityMap:TextureMap=null,
											   _fresnelReflectance:Number=0.028,
											   _fresnelPower:uint=5,
											   _alpha:Number=1.0,
											   _opacity:Number=1.0,
											   _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			super.opacity = _opacity;
			
			m_envMap = _envMap;		
			m_colorMap = _colorMap;
			m_reflectivityMap = _reflectivityMap;
			
			m_fresnelReflectance = _fresnelReflectance;
			m_fresnelPower = _fresnelPower;
			m_alpha = _alpha;
			
			m_envShader = new ShaderEnvMapFresnel(_envMap,_colorMap ,  _normalMap, m_reflectivityMap, 
													m_alpha, m_fresnelReflectance, m_fresnelPower);
			
			m_envShader.params.blendEnabled = true;
			m_envShader.params.blendSource = Context3DBlendFactor.DESTINATION_COLOR;
			m_envShader.params.blendDestination = Context3DBlendFactor.ZERO;
			
			m_ambShader = new ShaderAmbient(_opacity);
			
			shaders = new Vector.<com.yogurt3d.core.materials.shaders.base.Shader>;
			
			shaders.push(m_ambShader);	
			shaders.push(lightShader = new ShaderSpecular());
			
			shaders.push(m_envShader);
			
			normalMap = _normalMap;
			specularMap = _specularMap;
		}
		
		public function get shininess():Number{
			return lightShader.shininess;
		}
		public function set shininess(_value:Number):void{
			lightShader.shininess = _value;
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
			m_envShader.texture = value;
		}
		
		public function get normalMap():TextureMap
		{
			return m_normalMap;
		}
		public function set normalMap(value:TextureMap):void
		{
			m_normalMap = value;
			m_envShader.normalMap = value;
			lightShader.normalMap = value;
		}
		
		public function get specularMap():TextureMap
		{
			return m_specularMap;
		}
		public function set specularMap(value:TextureMap):void
		{
			m_specularMap = value;
			lightShader.specularMap = value;
			
		}
		
		public function get alpha():Number{
			return m_alpha;
		}
		public function set alpha(_value:Number):void{
			m_alpha = _value;
			m_envShader.alpha = _value;
		}
		
		
		public function get fresnelReflectance():Number{
			return m_fresnelReflectance;
		}
		public function set fresnelReflectance(value:Number):void{
			m_fresnelReflectance = value;
			m_envShader.fresnelReflectance = value;
		}
		
		public function get fresnelPower():uint{
			return m_fresnelPower;
		}
		public function set fresnelPower(value:uint):void{
			m_fresnelPower = value;
			m_envShader.fresnelPower = value;
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
		
		public override function set opacity(value:Number):void{
			super.opacity = value;
			m_ambShader.opacity = value;
		}
		
	}
}