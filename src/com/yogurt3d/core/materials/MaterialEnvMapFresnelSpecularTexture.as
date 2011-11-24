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
						
			m_envShader = new ShaderEnvMapFresnel(_envMap,_colorMap ,  _normalMap, _reflectivityMap, 
													_alpha, _fresnelReflectance, _fresnelPower);
			
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
			return m_envShader.envMap;
		}
		public function set envMap(value:CubeTextureMap):void
		{
			m_envShader.envMap = value;
		}
		
		public function get texture():TextureMap
		{
			return m_envShader.texture;
		}
		public function set texture(value:TextureMap):void
		{
			m_envShader.texture = value;
		}
		
		public function get normalMap():TextureMap
		{
			return m_envShader.normalMap;
		}
		public function set normalMap(value:TextureMap):void
		{
			m_envShader.normalMap = value;
			lightShader.normalMap = value;
		}
		
		public function get specularMap():TextureMap
		{
			return lightShader.specularMap;
		}
		public function set specularMap(value:TextureMap):void
		{
			
			lightShader.specularMap = value;
		}
		
		public function get alpha():Number{
			return m_envShader.alpha;
		}
		public function set alpha(_value:Number):void{
			m_envShader.alpha = _value;
		}
		
		
		public function get fresnelReflectance():Number{
			return m_envShader.fresnelReflectance;
		}
		public function set fresnelReflectance(value:Number):void{
			m_envShader.fresnelReflectance = value;
		}
		
		public function get fresnelPower():uint{
			return m_envShader.fresnelPower;
		}
		public function set fresnelPower(value:uint):void{
			m_envShader.fresnelPower = value;
		}
		
		public function get reflectivityMap():TextureMap
		{
			return m_envShader.reflectivityMap;
		}
		public function set reflectivityMap(value:TextureMap):void
		{
			m_envShader.reflectivityMap = value;
		}
		
		public override function set opacity(value:Number):void{
			super.opacity = value;
			m_ambShader.opacity = value;
			m_envShader.alpha = value;
		}
		
	}
}