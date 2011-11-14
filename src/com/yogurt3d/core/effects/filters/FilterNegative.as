package com.yogurt3d.core.effects.filters
{
	
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class FilterNegative extends Filter
	{
		private var m_xMin:Number;
		private var m_xMax:Number;
		private var m_yMin:Number;
		private var m_yMax:Number;
		
		
		public function FilterNegative(_xMin:Number=0.2, _xMax:Number = 0.8, _yMin:Number=0.2, _yMax:Number=0.8)
		{
			xMin = _xMin;
			xMax = _xMax;
			yMin = _yMin;
			yMax = _yMax;
			
			super();
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				[
					//			if (gl_TexCoord[0].x>xMin && gl_TexCoord[0].x<xMax && gl_TexCoord[0].y>yMin && gl_TexCoord[0].y<yMax)
					//				gl_FragColor.rgb = vec3(1.0) - texture2D(tex0, gl_TexCoord[0].xy).rgb;
					//			else
					//				gl_FragColor.rgb = texture2D(tex0, gl_TexCoord[0].xy).rgb;
					//			gl_FragColor.a = 1.0;
					
					"tex ft0 v0 fs0<2d,wrap,linear>", 
					
					"sge ft2 v0.x fc0.x",// if (gl_TexCoord[0].x>xMin && gl_TexCoord[0].x<xMax)
					"slt ft3 v0.x fc0.y",
					"mul ft2 ft2 ft3",
					
					"sge ft3 v0.y fc1.x",// if (gl_TexCoord[0].y>yMin && gl_TexCoord[0].y<yMax)
					"slt ft4 v0.y fc1.y",
					"mul ft3 ft3 ft4",
					
					"mul ft1 ft2 ft3",// if 
					"sub ft2 fc0.z ft1",//else
					
					"mul ft3 ft0 ft2",
					
					"sub ft4 fc0.z ft0",
					"mul ft4 ft4 ft1",
					
					"add ft0 ft3 ft4",
					"mov ft0.w fc0.z",
					
					"mov oc ft0"
					
				].join("\n")				
			);
		}
		
		public function get xMin():Number{
			return m_xMin;
		}
		public function get xMax():Number{
			return m_xMax;
		}
		public function get yMin():Number{
			return m_yMin;
		}
		public function get yMax():Number{
			return m_yMax;
		}
		
		public function set xMin(_value:Number):void{
			m_xMin = _value;
		}
		public function set xMax(_value:Number):void{
			m_xMax = _value;
		}
		public function set yMin(_value:Number):void{
			m_yMin = _value;
		}
		public function set yMax(_value:Number):void{
			m_yMax = _value;
		}
		
		public override function setShaderConstants(_context3D:Context3D, view:Rectangle):void{
			
//			trace(xMin, xMax, yMin, xMax);
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_xMin, m_xMax, 1.0, 0.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([m_yMin, m_yMax, 1.0, 1.0]));
		}
	}
}