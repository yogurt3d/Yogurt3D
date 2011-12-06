package com.yogurt3d.core.effects.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class FilterSephia extends Filter
	{		
		
		public function FilterSephia()
		{
			
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
					
					"dp3 ft1.x ft0.xyz fc0.xyz",
					"mul ft1.xyz fc1.xyz ft1.x",
					"mov ft1.w fc0.w",
					"mov oc ft1"
					
				].join("\n")
				
			);
		}
		
		public override function setShaderConstants(_context3D:Context3D,_veiwport:Rectangle):void{
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([0.299, 0.587, 0.114, 1.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([1.2, 1.0, 0.8, 0.0]));
			
		}
	}
}