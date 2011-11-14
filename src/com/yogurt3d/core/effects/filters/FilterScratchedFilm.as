// FROM : http://developer.download.nvidia.com/shaderlibrary/webpages/shader_library.html

package com.yogurt3d.core.effects.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.core.utils.MathUtils;
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class FilterScratchedFilm extends Filter
	{
		private var m_noiseTex:Texture;
		private var m_noiseTexBitmap:BitmapData = null;
		private var m_timer:Number = 5.0;
		private var m_speed1:Number = 0.03;// 0 - 0.2
		private var m_speed2:Number = 0.01;// 0 - 0.01
		private var m_scratchIntensity:Number = 0.65;// 0 - 0.65
		private var m_is:Number = 0.01;// 0 - 0.1
		
		
		public function FilterScratchedFilm(_noiseBitmap:BitmapData )
		{
			
			m_noiseTexBitmap = _noiseBitmap;
			
			super();
		}
		
		public function get IS():Number
		{
			return m_is;
		}

		public function set IS(value:Number):void
		{
			m_is = value;
		}

		public function get scratchIntensity():Number
		{
			return m_scratchIntensity;
		}

		public function set scratchIntensity(value:Number):void
		{
			m_scratchIntensity = value;
		}

		public function get speed2():Number
		{
			return m_speed2;
		}

		public function set speed2(value:Number):void
		{
			m_speed2 = value;
		}

		public function get speed1():Number
		{
			return m_speed1;
		}

		public function set speed1(value:Number):void
		{
			m_speed1 = value;
		}

		public function get timer():Number
		{
			return m_timer;
		}

		public function set timer(value:Number):void
		{
			m_timer = value;
		}

		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				[
					"mov ft1.x fc0.x",//ScanLine = (Timer*Speed1);
					"mov ft1.y fc0.y",//Side = (Timer*Speed2);

					"tex ft0 v0 fs0<2d,wrap,linear>",//img = tex2D(SceneSampler,uv);
					"dp3 ft4.x ft0 fc2",
					"mul ft0 ft4.x fc3",
					
					"add ft1.z v0.x ft1.y",//IN.UV.x+Side
					"mov ft1.w ft1.x",//s = float2(IN.UV.x+Side,ScanLine);
					
					"tex ft2 ft1.zw fs1<2d,wrap,linear>",//scratch = tex2D(Noise2DSamp,s).x;
					"sub ft2.x ft2.x fc0.z",//(scratch - ScratchIntensity)
					"mul ft2.x ft2.x fc1.z",
					"div ft2.x ft2.x fc0.w",//scratch = 2.0f*(scratch - ScratchIntensity)/IS;
					
					"sub ft2.y fc1.x ft2.x",
					"abs ft2.y ft2.y",//abs(1.0f-scratch)
					"sub ft2.x fc1.x ft2.y",//1.0-abs(1.0f-scratch);
					"max ft2.x fc1.y ft2.x",// scratch = max(0,scratch);
					
					"mov ft3.xyz ft2.xxx",
					"mov ft3.w fc1.y",
					
					"add ft0 ft3 ft0",//img + float4(scratch.xxx,0);
					
					"mov ft0.w fc1.x",
					
					"mov oc ft0"
					
				].join("\n")
				
			);
		}
		
		public function get noiseTex():Texture
		{
			return m_noiseTex;
		}
		
		public function set noiseTex(value:Texture):void
		{
			m_noiseTex = value;
		}
		
		public override function clearTextures(_context3D:Context3D):void{
			_context3D.setTextureAt(1, null);
		}
		
		public function createTextures(_context3D:Context3D, _rect:Rectangle):void{
			
			var m:Matrix = new Matrix;
			m.scale(m_width / m_noiseTexBitmap.width, m_height /m_noiseTexBitmap.height);
			var scaledImg:BitmapData = new BitmapData(m_width, m_height, false);
			scaledImg.draw(m_noiseTexBitmap, m, null, null, null, true);
			
			m_noiseTex = _context3D.createTexture(m_width, m_height, Context3DTextureFormat.BGRA, true ); 
			m_noiseTex.uploadFromBitmapData(scaledImg);
			
		}
		
		public override function setShaderConstants(_context3D:Context3D, _rect:Rectangle):void{
			
			if(m_noiseTex == null){
				
				createTextures(_context3D, _rect);
			}
			_context3D.setTextureAt(1, m_noiseTex);
			
		
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_timer * m_speed1, m_timer * m_speed2, m_scratchIntensity, m_is]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([1.0, 0.0, 2.0, 100.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([0.3,0.59,0.11,0.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,  Vector.<Number>([1.0,0.8,0.6,1.0]));
			
			
		}
	}
}