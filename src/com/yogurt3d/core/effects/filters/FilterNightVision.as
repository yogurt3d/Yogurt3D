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
		
	public class FilterNightVision extends Filter
	{
		private var m_noiseTex:Texture;
		private var m_maskTex:Texture;
		private var m_noiseRandomize:Number;//seconds
		private var m_elapsedSin:Number;
		private var m_elapsedCos:Number;
		private var m_luminanceThreshold:Number;//0.2
		private var m_colorAmplifaction:Number;//4.0
		private var m_effectCoverage:Number;//0.5
		private var m_noiseTexBitmap:BitmapData = null;
		private var m_maskTexBitmap:BitmapData = null;
		
		public function FilterNightVision(_noiseBitmap:BitmapData, 
										_maskBitmap:BitmapData, 
										_noiseRandomize:Number, 
										_luminanceThreshold:Number=0.2,
										_colorAmplifaction:Number=4.0,
										_effectCoverage:Number=1 )
		{

			m_noiseTexBitmap = _noiseBitmap;
			m_maskTexBitmap = _maskBitmap;
			m_noiseRandomize = _noiseRandomize;
			m_elapsedSin = 0.4 * Math.sin(50* m_noiseRandomize);
			m_elapsedCos = 0.4 * Math.sin(50* m_noiseRandomize);
				
			m_luminanceThreshold = _luminanceThreshold;
			m_colorAmplifaction = _colorAmplifaction;
			m_effectCoverage = _effectCoverage;
			
			
			super();
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				[
					//			vec2 uv;
					//			uv.x = 0.4*sin(elapsedTime*50.0);
					//			uv.y = 0.4*cos(elapsedTime*50.0);
					//			float m = texture2D(maskTex, gl_TexCoord[0].st).r;
					//			vec3 n = texture2D(noiseTex,
					//				(gl_TexCoord[0].st*3.5) + uv).rgb;
					//			vec3 c = texture2D(sceneBuffer, gl_TexCoord[0].st
					//				+ (n.xy*0.005)).rgb;
					//			
					//			float lum = dot(vec3(0.30, 0.59, 0.11), c);
					//			if (lum < luminanceThreshold)
					//				c *= colorAmplification; 
					//			
					//			vec3 visionColor = vec3(0.1, 0.95, 0.2);
					//			finalColor.rgb = (c + (n*0.2)) * visionColor * m;
					
					"tex ft1 v0 fs2<2d,wrap,linear>",// get mask
					"mov ft2.x ft1.x",//float m = texture2D(maskTex, gl_TexCoord[0].st).r;
					
					"mul ft1.xy v0.xy fc1.y",//(gl_TexCoord[0].st*3.5)
					"add ft1.xy ft1.xy fc0.xy",//(gl_TexCoord[0].st*3.5) + uv
					"tex ft1 ft1.xy fs1<2d,wrap,linear>",//vec3 n = texture2D(noiseTex,(gl_TexCoord[0].st*3.5) + uv).rgb;
					
					"mul ft0.xy ft1.xy fc1.z",//(n.xy*0.005)
					"add ft0.xy v0.xy ft0.xy",//gl_TexCoord[0].st + (n.xy*0.005)
					"tex ft0 ft0.xy fs0<2d,wrap,linear>",//vec3 c = texture2D(sceneBuffer, gl_TexCoord[0].st+ (n.xy*0.005)).rgb;
					
					"dp3 ft2.y fc2.xyz ft0",//float lum = dot(vec3(0.30, 0.59, 0.11), c);
					
					"slt ft2.z ft2.y fc0.z",//if (lum < luminanceThreshold)
					"sub ft2.w fc1.w ft2.z",//1 - result
					
					"mul ft4 ft0 fc0.w",//c *= colorAmplification; 
					"mul ft4 ft4 ft2.z",
					"mul ft5 ft0 ft2.w",
					
					"add ft0 ft4 ft5",
					
					//	finalColor.rgb = (c + (n*0.2)) * visionColor * m;
					"mul ft1 ft1 fc2.w",// (n*0.2)
					"add ft0 ft0 ft1", //(c + (n*0.2))
					"mul ft0 ft0 fc3.xyz", //(c + (n*0.2)) * visionColor 
					"mul ft0 ft0 ft2.x",
					
					// effect coverage
					"slt ft2.x v0.x fc1.x",
					"sub ft2.y fc1.w ft2.x",
					
					"mul ft3 ft0 ft2.x",
					"tex ft4 v0 fs0<2d,wrap,linear>",
					"mul ft4 ft4 ft2.y",
					"add ft0 ft3 ft4",
					
					"mov ft0.w fc1.w",
					
					"mov oc ft0"
					
				].join("\n")
				
			);
		}
		
			
		public function get effectCoverage():Number
		{
			return m_effectCoverage;
		}

		public function set effectCoverage(value:Number):void
		{
			m_effectCoverage = value;
		}

		public function get colorAmplifaction():Number
		{
			return m_colorAmplifaction;
		}

		public function set colorAmplifaction(value:Number):void
		{
			m_colorAmplifaction = value;
		}

		public function get luminanceThreshold():Number
		{
			return m_luminanceThreshold;
		}

		public function set luminanceThreshold(value:Number):void
		{
			m_luminanceThreshold = value;
		}

		public function get noiseRandomize():Number
		{
			return m_noiseRandomize;
		}

		public function set noiseRandomize(value:Number):void
		{
			m_noiseRandomize = value;
			m_elapsedSin = 0.4 * Math.sin(50* m_noiseRandomize);
			m_elapsedCos = 0.4 * Math.sin(50* m_noiseRandomize);
		}

		public function get maskTex():Texture
		{
			return m_maskTex;
		}

		public function set maskTex(value:Texture):void
		{
			m_maskTex = value;
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
			_context3D.setTextureAt(2, null);
		}
		
		public function createTextures(_context3D:Context3D):void{
		
			var m:Matrix = new Matrix;
			m.scale(m_width / m_noiseTexBitmap.width, m_height /m_noiseTexBitmap.height);
			var scaledImg:BitmapData = new BitmapData(m_width, m_height, false);
			scaledImg.draw(m_noiseTexBitmap, m, null, null, null, true);
		
			m_noiseTex = _context3D.createTexture(m_width, m_height, Context3DTextureFormat.BGRA, true ); 
			m_noiseTex.uploadFromBitmapData(scaledImg);
				
			m = new Matrix;
			m.scale(m_width / m_maskTexBitmap.width, m_height /m_maskTexBitmap.height);
			scaledImg= new BitmapData(m_width, m_height, false);
			scaledImg.draw(m_maskTexBitmap, m, null, null, null, true);
			
			m_maskTex = _context3D.createTexture(m_width, m_height, Context3DTextureFormat.BGRA, true ); 
			m_maskTex.uploadFromBitmapData(scaledImg);
		
		}
		
		public override function setShaderConstants(_context3D:Context3D, _viewport:Rectangle):void{
						
			if(m_noiseTex == null && m_maskTex == null){
			
				createTextures(_context3D);
			}
			_context3D.setTextureAt(1, m_noiseTex);
			_context3D.setTextureAt(2, m_maskTex);
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([
				m_elapsedSin, 
				m_elapsedCos, 
				luminanceThreshold, colorAmplifaction]));
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([effectCoverage, 3.5, 0.005, 1.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([0.3, 0.59, 0.11, 0.2]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,  Vector.<Number>([0.1, 0.95, 0.2, 1.0]));
		
		}
	}
}