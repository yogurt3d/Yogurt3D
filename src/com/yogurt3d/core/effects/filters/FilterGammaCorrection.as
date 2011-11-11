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
	
	public class FilterGammaCorrection extends Filter
	{		
		private var m_gamma:Number;
		
		public function FilterGammaCorrection(_gamma:Number=2.2)
		{
			
			m_gamma = _gamma;
			

			super();
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
					
					/*"pow ft1 ft0 fc0.x", //pow(color, 1.0 / gammaRGB)
					"slt ft2 ft0.x fc0.y",//if (color[0].r < 0.50)
					"mul ft1 ft2 ft1", // outColor.rgb = pow(color, 1.0 / gamma) * ft2;
					
					"sub ft3 fc0.w ft1", // else outColor.rgb = color;
					"mul ft0 ft0 ft3",
					
					"add ft0 ft0 ft1",
					"mov ft0.w fc0.w",*/
					
					"mov oc ft0"
					
				].join("\n")
				
			);
		}
		
		
		public function get gamma():Number{
			return m_gamma;
		}
		public function set gamma(_value:Number):void{
			m_gamma = _value;
		}
		
		public override function setShaderConstants(_context3D:Context3D,_veiwport:Rectangle):void{
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([1/m_gamma, 0.5, 0.0, 1.0]));
			
		}
	}
}