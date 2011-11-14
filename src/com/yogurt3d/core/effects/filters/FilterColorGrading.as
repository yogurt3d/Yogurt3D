package com.yogurt3d.core.effects.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.lights.Light;
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
	
	public class FilterColorGrading extends Filter
	{
		private var m_gradientTex:Texture;
		private var m_gradientBitmap:BitmapData = null;
		
		public function FilterColorGrading(_gradientBitmap:BitmapData)
		{
				
			super();
			
			m_gradientBitmap = _gradientBitmap;
		}

		public function get gradientBitmap():BitmapData
		{
			return m_gradientBitmap;
		}

		public function set gradientBitmap(value:BitmapData):void
		{
			m_gradientBitmap = value;
		}

		public override function clearTextures(_context3D:Context3D):void{
			_context3D.setTextureAt(1, null);
		}
		
		public function get gradientTex():Texture
		{
			return m_gradientTex;
		}
		
		public function set gradientTex(value:Texture):void
		{
			m_gradientTex = value;
		}
		
		public function createTextures(_context3D:Context3D):void{
			
			var m:Matrix = new Matrix;
			m.scale(m_width / m_gradientBitmap.width, m_height /m_gradientBitmap.height);
			var scaledImg:BitmapData = new BitmapData(m_width, m_height, false);
			scaledImg.draw(m_gradientBitmap, m, null, null, null, true);
			
			m_gradientTex = _context3D.createTexture(m_width, m_height, Context3DTextureFormat.BGRA, true ); 
			m_gradientTex.uploadFromBitmapData(scaledImg);
			
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
				
			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				
				[
					
					"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
				
					"mov ft1.y fc0.y",
					
					"mov ft1.x ft0.x",
					"tex ft2 ft1.xy fs1<2d,clamp,linear>", // get gradient
					"mov ft0.x ft2.x",
					
					"mov ft1.x ft0.y",
					"tex ft2 ft1.xy fs1<2d,clamp,linear>", // get gradient
					"mov ft0.y ft2.y",
					
					"mov ft1.x ft0.z",
					"tex ft2 ft1.xy fs1<2d,clamp,linear>", // get gradient
					"mov ft0.z ft2.z",
					
					"mov ft0.w fc0.x",
					
					"mov oc ft0"
					
				].join("\n")
				
			);
		}
		
		public override function setShaderConstants(_context3D:Context3D, view:Rectangle):void{
			
			if(m_gradientTex == null){
				
				createTextures(_context3D);
			}
			_context3D.setTextureAt(1, m_gradientTex);
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([1.0, 0.5, 0.0, 0.0]));
			
		}
	}
}