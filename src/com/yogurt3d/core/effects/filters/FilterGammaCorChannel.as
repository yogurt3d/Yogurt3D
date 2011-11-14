package com.yogurt3d.core.effects.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	public class FilterGammaCorChannel extends Filter
	{
		private var m_gammaRGB:Vector3D;
		private var m_gammaR:Number;
		private var m_gammaG:Number;
		private var m_gammaB:Number;
		
		public function FilterGammaCorChannel(_gammaR:Number, _gammaG:Number, _gammaB:Number)
		{
			super();
			
			m_gammaR = _gammaR;
			m_gammaG = _gammaG;
			m_gammaB = _gammaB;
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{
			//if (color[0].r < 0.50)
			//	outColor.rgb = pow(color, 1.0 / gammaRGB);
			//else
			//	outColor.rgb = color;
			//outColor.a = 1.0;
			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				[
					
					"tex ft0 v0 fs0<2d,wrap,linear>", // get render to texture
					"mov ft4 fc1",
					"mov ft4.x fc1.x",
					"mov ft4.y fc1.y",
					"mov ft4.z fc1.z",
					"div ft4 fc1.w ft4",
					
					"pow ft1 ft0 ft4", //pow(color, 1.0 / gammaRGB)
					"slt ft2 ft0.x fc1.x",//if (color[0].r < 0.50)
					"mul ft1 ft2 ft1", // outColor.rgb = pow(color, 1.0 / gammaRGB);
					
					"sub ft3 fc0.w ft1", // else outColor.rgb = color;
					"mul ft0 ft0 ft3",
					
					"add ft0 ft0 ft1",
					"mov ft0.w fc0.w",
					
					"mov oc ft0"
					
				].join("\n")
			);
		}
		
		public function get gammaR():Number{
			return m_gammaR;
		}
		
		public function get gammaG():Number{
			return m_gammaG;
		}
		
		public function get gammaB():Number{
			return m_gammaB;
		}
		
		public function set gammaR(_value:Number):void{
			m_gammaR = _value;
		}
		
		public function set gammaG(_value:Number):void{
			m_gammaG = _value;
		}
		
		public function set gammaB(_value:Number):void{
			m_gammaB = _value;
		}
		
		public override function setShaderConstants(_context3D:Context3D, _viewport:Rectangle):void{
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([0.5, 0.5, 0.0, 1.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([m_gammaR, m_gammaG, m_gammaB, 1.0]));
		}
	}
}