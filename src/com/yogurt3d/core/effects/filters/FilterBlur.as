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
	
	public class FilterBlur extends Filter
	{
		
		private var m_two:Number;
		private var m_sixteen:Number;
		private var m_four:Number;
	
		public function FilterBlur()
		{	
			two = 2.0;
			sixteen = 16.0;
			four = 4.0;
		}
		
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			//			vec4 color = vec4(1.0, 0.0, 0.0, 1.0); 
			//			vec2 st = gl_TexCoord[0].st; 
			//			color	 = 4.0 * texture2D(tex, st); 
			//			float dx = 1.0 / rt_w; 
			//			float dy = 1.0 / rt_h; 
			//			color		+= 2.0 * texture2D(tex, st + vec2(+dx, 0.0)); 
			//			color		+= 2.0 * texture2D(tex, st + vec2(-dx, 0.0)); 
			//			color		+= 2.0 * texture2D(tex, st + vec2(0.0, +dy)); 
			//			color		+= 2.0 * texture2D(tex, st + vec2(0.0, -dy)); 
			//			color		+= texture2D(tex, st + vec2(+dx, +dy)); 
			//			color		+= texture2D(tex, st + vec2(-dx, +dy)); 
			//			color		+= texture2D(tex, st + vec2(-dx, -dy)); 
			//			color		+= texture2D(tex, st + vec2(+dx, -dy)); 
			//			color /= 16.0;
			//			gl_FragColor = color;
			
			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				[
					
					"tex ft0 v0 fs0<2d,wrap,linear>", 
					"mul ft1 ft0 fc1.y",// color = 4.0 * texture2D(tex, st);
					
					//color	+= 2.0 * texture2D(tex, st + vec2(+dx, 0.0)); 
					"mov ft2 fc0", // vec2(+dx, 0.0)
					"mov ft2.x fc0.x",
					"mov ft2.y fc1.w",
					"add ft2 ft2.xy v0", // st + vec2(+dx, 0.0)
					"tex ft2 ft2 fs0<2d,wrap,linear>", //texture2D(tex, st + vec2(+dx, 0.0)); 
					"mul ft2 ft2 fc0.z",//2.0 * texture2D(tex, st + vec2(+dx, 0.0)); 
					"add ft1 ft1 ft2",// color	+= 2.0 * texture2D(tex, st + vec2(+dx, 0.0)); 
					
					//color	+= 2.0 * texture2D(tex, st + vec2(-dx, 0.0)); 
					"mov ft2.x fc2.x",// vec2(-dx, 0.0)
					"mov ft2.y fc1.w",
					"add ft2 ft2.xy v0", // st + vec2(-dx, 0.0)
					"tex ft2 ft2 fs0<2d,wrap,linear>", //texture2D(tex, st + vec2(+dx, 0.0)); 
					"mul ft2 ft2 fc0.z",//2.0 * texture2D(tex, st + vec2(-dx, 0.0)); 
					"add ft1 ft1 ft2",// color	+= 2.0 * texture2D(tex, st + vec2(-dx, 0.0)); 
					
					//color	+= 2.0 * texture2D(tex, st + vec2(0.0, +dy)); 
					"mov ft2.x fc0.w",// vec2(0.0, +dy)
					"mov ft2.y fc0.y",
					"add ft2 ft2.xy v0", // st + vec2(0.0, +dy)
					"tex ft2 ft2 fs0<2d,wrap,linear>", //texture2D(tex, st + vec2(0.0, +dy)); 
					"mul ft2 ft2 fc0.z",//2.0 * texture2D(tex, st + vec2(0.0, +dy)); 
					"add ft1 ft1 ft2",// color	+= 2.0 * texture2D(tex, st + vec2(0.0, +dy)); 
					
					//color	+= 2.0 * texture2D(tex, st + vec2(0.0, -dy)); 
					"mov ft2.x fc0.w",// vec2(0.0, -dy)
					"mov ft2.y fc2.y",
					"add ft2 ft2.xy v0", // st + vec2(0.0, -dy)
					"tex ft2 ft2 fs0<2d,wrap,linear>", //texture2D(tex, st + vec2(0.0, -dy)); 
					"mul ft2 ft2 fc0.z",//2.0 * texture2D(tex, st + vec2(0.0, -dy)); 
					"add ft1 ft1 ft2",// color	+= 2.0 * texture2D(tex, st + vec2(0.0, -dy)); 
					
					//color	+= texture2D(tex, st + vec2(+dx, +dy)); 
					"mov ft2.x fc0.x",// vec2(+dx, +dy)
					"mov ft2.y fc0.y",
					"add ft2 ft2.xy v0",// st + vec2(+dx, +dy)
					"tex ft2 ft2 fs0<2d,wrap,linear>", //texture2D(tex, st + vec2(+dx, +dy)); 
					"add ft1 ft1 ft2",// color	+= texture2D(tex, st + vec2(+dx, +dy)); 
					
					//color	+= texture2D(tex, st + vec2(-dx, +dy)); 
					"mov ft2.x fc2.x",// vec2(-dx, +dy)
					"mov ft2.y fc0.y",
					"add ft2 ft2.xy v0",// st + vec2(-dx, +dy)
					"tex ft2 ft2 fs0<2d,wrap,linear>", //texture2D(tex, st + vec2(-dx, +dy)); 
					"add ft1 ft1 ft2",// color	+= texture2D(tex, st + vec2(-dx, +dy)); 
					
					//color	+= texture2D(tex, st + vec2(-dx, -dy)); 
					"mov ft2.x fc2.x",// vec2(-dx, -dy)
					"mov ft2.y fc2.y",
					"add ft2 ft2.xy v0",// st + vec2(-dx, -dy)
					"tex ft2 ft2 fs0<2d,wrap,linear>", //texture2D(tex, st + vec2(-dx, -dy)); 
					"add ft1 ft1 ft2",// color	+= texture2D(tex, st + vec2(-dx, -dy)); 
					
					//color	+= texture2D(tex, st + vec2(+dx, -dy)); 
					"mov ft2.x fc0.x",// vec2(+dx, -dy)
					"mov ft2.y fc2.y",
					"add ft2 ft2.xy v0",// st + vec2(+dx, -dy)
					"tex ft2 ft2 fs0<2d,wrap,linear>", //texture2D(tex, st + vec2(+dx, -dy)); 
					"add ft1 ft1 ft2",// color	+= texture2D(tex, st + vec2(+dx, -dy)); 
					
					"div ft1 ft1 fc1.x",
					"mov ft1.w fc1.z",
					
					"mov oc ft1"
					
				].join("\n")
			);
		}
		
		public function get two():Number{
			return m_two;
		}
		
		public function get sixteen():Number{
			return m_sixteen;
		}
		
		public function get four():Number{
			return m_four;
		}
		
		
		public function set two(_value:Number):void{
		
			m_two = _value;
		
		}
		
		public function set sixteen(_value:Number):void{
			
			m_sixteen = _value;
			
		}
		
		public function set four(_value:Number):void{
			
			m_four = _value;
			
		}
		
		public override function setShaderConstants(_context3D:Context3D, _viewport:Rectangle):void{
			
			//trace((1/PostEffect.width as Number), (1/PostEffect.height as Number));
			
			var dx:Number = 1/m_width;
			var dy:Number = 1/m_height;
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([dx, dy, m_two, 0.0]));
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([m_sixteen, m_four, 1.0, 0.0]));
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([-dx, -dy, 0.0, 0.0]));
		}
	}
}