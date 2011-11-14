package com.yogurt3d.core.materials.posteffects
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
		
		public function FilterSimple(_colorR:Number, _colorG:Number, _colorB:Number)
		{	
//			var _a:uint =  _color >>> 24;
//			var _r:uint = _color >>> 16 & 0xFF ;
//			var _g:uint = _color >>> 8 & 0xFF;
//			var _b:uint = _color & 0xFF;
			
			//trace(_a, _r, _g, _b);
				
			m_color = new Vector.<Number>();
			m_color.push(Number(_colorR/255));
			m_color.push(Number(_colorG/255));
			m_color.push(Number(_colorB/255));
			
			
			super();
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				
				[
					
					"tex ft0 v0 fs0<2d,wrap,linear>", 
					
					// get xy as normals
					
					"mov ft1.xy ft0.xy",
					// generate z 
					//n.z = sqrt(1-dot(n.xy, n.xy));
					"mul ft2.x ft1.x ft1.x",
					"mul ft2.y ft1.y ft1.y",
					"sub ft1.z fc0.z ft2.x",
					"sub ft1.z ft1.z ft2.y",
					//"dp3 ft1.z ft0.xy ft0.xy",//dot(n.xy, n.xy)
					//"sub ft1.z fc0.z ft1.z",//1-dot(n.xy, n.xy)
					//"sqt ft1.z ft1.z",//sqrt(1-dot(n.xy, n.xy))
					
					// decode depth
					"mul ft1.w ft0.w fc0.w",//depth.y  * (1/255)
					"add ft1.w ft1.w ft0.z",//depth.x + (depth.y  * (1/255))
					
					//"mul ft0.xyz ft0.xyz fc0.xyz",
					//"mov ft0.w fc0.w",
					//"mov ft1.w fc0.z",
					"mov oc ft1"
					
				].join("\n")
				
			);
		}
		
		public override function setShaderConstants(_context3D:Context3D, view:Rectangle):void{
	
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_color[0], m_color[1], 1.0, (1.0/256.0 as Number)]));
		}
	}
}