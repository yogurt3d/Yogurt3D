package com.yogurt3d.core.effects.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class FilterSharpen extends Filter
	{		
		
		private var m_offset:Dictionary;
		
		public function FilterSharpen()
		{
			m_offset = new Dictionary();
			m_offset["0x"] = "fc0.z"; m_offset["0y"] = "fc0.w"; 
			m_offset["1x"] = "fc1.y"; m_offset["1y"] = "fc0.w"; 
			m_offset["2x"] = "fc0.x"; m_offset["2y"] = "fc0.w"; 
			m_offset["3x"] = "fc0.z"; m_offset["3y"] = "fc1.y";
			m_offset["4x"] = "fc1.y"; m_offset["4y"] = "fc1.y";
			m_offset["5x"] = "fc0.x"; m_offset["5y"] = "fc1.y";
			m_offset["6x"] = "fc0.z"; m_offset["6y"] = "fc0.y";
			m_offset["7x"] = "fc1.y"; m_offset["7y"] = "fc0.y";
			m_offset["8x"] = "fc0.x"; m_offset["8y"] = "fc0.y";
			
			super();
		}
		
		private function getOffset(_index:uint):String{
			
			var code:String = [	
				"mov ft1.x "+ m_offset[_index+"x"],
				"mov ft1.y "+ m_offset[_index+"y"]+"\n"
			].join("\n");
			
			return code;
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{				
			var code:String = "mov ft0 fc1.yyyy\n"
			
			
			for( var i:uint = 0; i < 9; i++){
				
				code += [
					getOffset(i),
					"add ft1.xy ft1.xy v0.xy",
					"tex ft1 ft1.xy fs0<2d,wrap,linear>",
					((i != 4)?"mul ft1 ft1 fc1.x":"mul ft1 ft1 fc1.w"),
					"add ft0 ft0 ft1\n"
					
				].join("\n");
			}
			
			code += [
				"mov ft0.w fc1.z",
				"mov oc ft0"
			].join("\n");
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT, code);
		}
		
		public override function setShaderConstants(_context3D:Context3D,_veiwport:Rectangle):void{
			
			var stepW:Number = 1/m_width;
			var stepH:Number = 1/m_height;
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([stepW, stepH, -stepW, -stepH]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([-1.0, 0.0, 1.0, 9.0]));
			
		}
	}
}