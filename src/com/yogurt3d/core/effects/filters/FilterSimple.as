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
		
		public function FilterSimple(_color:uint)
		{	
			var _a:uint =  _color >>> 24;
			var _r:uint = _color >>> 16 & 0xFF ;
			var _g:uint = _color >>> 8 & 0xFF;
			var _b:uint = _color & 0xFF;
			
			//trace(_a, _r, _g, _b);
				
			m_color = new Vector.<Number>();
			m_color.push(Number(_r/255));
			m_color.push(Number(_g/255));
			m_color.push(Number(_b/255));
			m_color.push(Number(_a/255));

			
			super();
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				
				[
					
					"tex ft0 v0 fs0<2d,wrap,linear>", 
					"mul ft0 ft0 fc0",
					"mov oc ft0"
					
				].join("\n")
				
			);
		}
		
		public override function setShaderConstants(_context3D:Context3D, view:Rectangle):void{
	
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_color[0], m_color[1], m_color[2], m_color[3]]));
		}
	}
}