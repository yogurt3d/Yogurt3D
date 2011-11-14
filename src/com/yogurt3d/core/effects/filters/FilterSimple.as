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

	public class FilterSimple extends Filter
	{
		private var m_color:Vector.<Number>;
		
		public function FilterSimple()
		{			
			super();
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				
				[	"tex ft0 v0 fs0<2d,wrap,linear>", 
					// get xy as normals
					"mov ft1.xy ft0.xy",
					// generate z 
					//n.z = sqrt(1-dot(n.xy, n.xy));
					"mul ft2.x ft1.x ft1.x",
					"mul ft2.y ft1.y ft1.y",
					"sub ft1.z fc0.z ft2.x",
					"sub ft1.z ft1.z ft2.y",
					// decode depth
					"mul ft1.w ft0.w fc0.w",//depth.y  * (1/255)
					"add ft1.w ft1.w ft0.z",//depth.x + (depth.y  * (1/255))
					// so ft1.xyz : normals ft1.w: depth
					
					
					
					
					
					
					
					
					
					
					//"mul ft0.xyz ft0.xyz fc0.xyz",
					//"mov ft0.w fc0.w",
					//"mov ft1.w fc0.z",
					"mov oc ft1"
					
				].join("\n")
				
			);
		}
		
		public override function setShaderConstants(_context3D:Context3D, view:Rectangle):void{
	
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([0, 0, 1.0, (1.0/255.0 as Number)]));
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([-0.010735935,0.01647018, 0.0062425877, 0.8765323]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([-0.06533369,0.3647007, -0.13746321, 0.011236004]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,  Vector.<Number>([-0.6539235,-0.016726388, -0.53000957, 0.28265962]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4,  Vector.<Number>([0.40958285,0.0052428036, -0.5591124, 0.29264435]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5,  Vector.<Number>([-0.1465366,0.09899267, 0.15571679, -0.40794238]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 6,  Vector.<Number>([-0.44122112,-0.5458797, 0.04912532, 0.15964167]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 7,  Vector.<Number>([0.03755566,-0.10961345, -0.33040273, 2.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 8,  Vector.<Number>([0.019100213,0.29652783, 0.066237666, 0.000001]));
		}
	}
}