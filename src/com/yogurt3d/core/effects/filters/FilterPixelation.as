package com.yogurt3d.core.effects.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.utils.MathUtils;
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class FilterPixelation extends Filter
	{
		private var m_pixelWidth:Number;
		private var m_pixelHeight:Number;
		
		public function FilterPixelation(_pixelWidth:Number=15.0, _pixelHeight:Number=10.0)
		{
			m_pixelWidth = _pixelWidth;
			m_pixelHeight = _pixelHeight;		

			super();
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{			
			//			float dx = pixel_w*(1./rt_w);
			//			float dy = pixel_h*(1./rt_h);
			//			vec2 coord = vec2(dx*floor(uv.x/dx),
			//				dy*floor(uv.y/dy));
			//			tc = texture2D(sceneTex, coord).rgb;
			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				
				[
					
					"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
					
					"div ft1.x v0.x fc0.x",
					ShaderUtils.floorAGAL("ft2.x","ft1.x"),
					"mul ft1.x ft2.x fc0.x",
					
					"div ft1.y v0.y fc0.y",
					ShaderUtils.floorAGAL("ft2.x","ft1.y"),
					"mul ft1.y ft2.x fc0.y",
					
					"tex ft0 ft1.xy fs0<2d,wrap,linear>",
					
					"mov ft0.w fc0.z",
					
					"mov oc ft0"
					
				].join("\n")
				
			);
		}
		
		public function get pixelWidth():Number{
			return m_pixelWidth;
		}
		
		public function get pixelHeight():Number{
			return m_pixelHeight;
		}
		
		public function set pixelWidth(_value:Number):void{
			m_pixelWidth = _value;
		}
		
		public function set pixelHeight(_value:Number):void{
			m_pixelHeight = _value;
		}
		
		public override function setShaderConstants(_context3D:Context3D, view:Rectangle):void{
			
			var dx:Number = 1/m_width * m_pixelWidth;
			var dy:Number = 1/m_height * m_pixelHeight;
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([dx, dy, 1.0, 0.0]));

		}
	}
}