package com.yogurt3d.core.materials
{
	import com.yogurt3d.core.materials.base.Color;
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.materials.shaders.ShaderYogurtistan;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.textures.Texture;
	
	public class MaterialYogurtistan extends Material
	{
		private var m_yogurtistanShader:ShaderYogurtistan;
		
		public function MaterialYogurtistan(
											_diffuseGradient:TextureMap=null,
											_ambientGradient:TextureMap=null,
											_emmisiveMap:TextureMap=null,
											_colorMap:TextureMap=null,
											_specularMap:TextureMap=null,
											_rimMask:TextureMap=null,
											_specularMask:TextureMap=null,
											_color:Color=null,
											_ks:Number=1.0,//if texture is used for ks
											_kr:Number=1.0,//if texture is used for kr
											_blendConstant:Number=1.5,
											_fspecPower:Number=1.0,
											_fRimPower:Number=2.0,
											_kRim:Number=1.0,
											_kSpec:Number=1.0,
											_opacity:Number=1.0,
											_initInternals:Boolean=true
		){
			
			super(_initInternals);
			
			shaders = Vector.<com.yogurt3d.core.materials.shaders.base.Shader>([
				m_yogurtistanShader = new ShaderYogurtistan(_diffuseGradient,_ambientGradient,
															_emmisiveMap,
															_colorMap,_specularMap,
															_rimMask, _specularMask,
															_color,
															_ks,_kr,
															_blendConstant, _fspecPower,
															_fRimPower,
															_kRim,_kSpec,
															_opacity),
				 
			]);
			 
			super.opacity = _opacity;
		}
		
		public function get emmisiveMask():TextureMap{
			return m_yogurtistanShader.emmisiveMask;
		}
		
		public function set emmisiveMask(_value:TextureMap):void{
			m_yogurtistanShader.emmisiveMask = _value;
		}
		
		public function get color():Color{
			return m_yogurtistanShader.color;
		}
		public function set color(_value:Color):void{
			m_yogurtistanShader.color = _value;
		}
	
		public function get specularMask():TextureMap{
			return m_yogurtistanShader.specularMask;
		}
		public function set specularMask(_value:TextureMap):void{
			m_yogurtistanShader.specularMask = _value;
		}
		
		public function get krColor():Number{
			return m_yogurtistanShader.krColor;
		}
		
		public function set krColor(_value:Number):void{
			m_yogurtistanShader.krColor = _value;
		}
		
		public function get ksColor():Number{
			return m_yogurtistanShader.ksColor;
		}
		
		public function set ksColor(_value:Number):void{
			m_yogurtistanShader.ksColor = _value;
		}
		
		public function get kSpec():Number{
			return m_yogurtistanShader.kSpec;
		}
		public function set kSpec(_value:Number):void{
			m_yogurtistanShader.kSpec = _value;
		}
		
		public function get rimMask():TextureMap{
			return m_yogurtistanShader.rimMask;
		}
		public function set rimMask(_value:TextureMap):void{
			m_yogurtistanShader.rimMask = _value;
		}
		
		public function get fRimPower():Number{
			return m_yogurtistanShader.fRimPower;
		}
		public function set fRimPower(_value:Number):void{
			m_yogurtistanShader.fRimPower = _value;
		}
		
		public function get kRim():Number{
			return m_yogurtistanShader.kRim;
		}
		public function set kRim(_value:Number):void{
			m_yogurtistanShader.kRim = _value;
		}
		
		public function get fspecPower():Number{
			return  m_yogurtistanShader.fspecPower;
		}
		
		public function set fspecPower(_value:Number):void{
			m_yogurtistanShader.fspecPower = _value;
		}
		
		public function get specularMap():TextureMap{
			return m_yogurtistanShader.specularMap;
		}
		public function set specularMap(_value:TextureMap):void{
			m_yogurtistanShader.specularMap = _value;
		}
		
		public function get blendConstant():Number{
			return m_yogurtistanShader.blendConstant;
		}
		public function set blendConstant(_value:Number):void{
			m_yogurtistanShader.blendConstant = _value;
		}
		
		public function get colorMap():TextureMap{
			return m_yogurtistanShader.colorMap;
		}
		
		public function set colorMap(_value:TextureMap):void{
			m_yogurtistanShader.colorMap = _value;
		}
		
		public function get ambientGradient():TextureMap{
			return m_yogurtistanShader.ambientGradient;
		}
		public function set ambientGradient(_value:TextureMap):void{
			m_yogurtistanShader.ambientGradient = _value;
		}

		public function get diffuseGradient():TextureMap{
			return m_yogurtistanShader.diffuseGradient;
		}
		
		public function set diffuseGradient(_value:TextureMap):void{
			m_yogurtistanShader.diffuseGradient = _value;
		}
	}
}