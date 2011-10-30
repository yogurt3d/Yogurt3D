package com.yogurt3d.core.materials.posteffects
{
	
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	
	public class FilterGaussianBlurHorizontal extends Filter
	{
		private var m_vxOff:Number;
		private var m_height:Number;
		private var m_width:Number;
		
		public function FilterGaussianBlurHorizontal(_vxOff:Number, _width:Number, _height:Number)
		{
			
			m_vxOff = _vxOff;
			m_width = _width;
			m_height = _height;
			
			super();
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				[
					
					"tex ft0 v0 fs0<2d,wrap,linear>",// tc2 = texture2D(sceneTex, gl_TexCoord[0].xy).rgb; 
					"mul ft1 ft0 fc1.x",// tc1 = texture2D(sceneTex, uv).rgb * weight[0];
					
					"mov ft3.x fc0.x",// ft2 = vec2(0.0, offset[1])
					"mov ft3.y fc0.y", //ft2 = vec2(0.0, offset[1])
					"div ft3.xy ft3.xy fc3.y", // ft2 = vec2(0.0, offset[i])/rt_h 
					"add ft2.xy ft3.xy v0", // uv + vec2(0.0, offset[i])/rt_h
					"tex ft2 ft2.xy fs0<2d,wrap,linear>", //texture2D(sceneTex, uv + vec2(0.0, offset[i])/rt_h).rgb
					"mul ft2 ft2 fc1.y",// texture2D(sceneTex, gl_TexCoord[0].xy + vec2(0.0, offset[i])/rt_h).rgb * weight[i];
					"add ft1 ft1 ft2",
					
					"sub ft3.xy v0 ft3.xy",//gl_TexCoord[0].xy - vec2(0.0, offset[i])/rt_h
					"tex ft3 ft3.xy fs0<2d,wrap,linear>", //texture2D(sceneTex, uv - vec2(0.0, offset[i])/rt_h).rgb
					"add ft1 ft1 ft3",
					
					"mov ft3.x fc0.x",// ft2 = vec2(0.0, offset[2])
					"mov ft3.y fc0.z", //ft2 = vec2(0.0, offset[2])
					"div ft3.xy ft3.xy fc3.y", // ft2 = vec2(0.0, offset[2])/rt_h 
					"add ft2.xy ft3.xy v0", // uv + vec2(0.0, offset[2])/rt_h
					"tex ft2 ft2.xy fs0<2d,wrap,linear>", //texture2D(sceneTex, uv + vec2(0.0, offset[i])/rt_h).rgb
					"mul ft2 ft2 fc1.z",// texture2D(sceneTex, gl_TexCoord[0].xy + vec2(0.0, offset[i])/rt_h).rgb * weight[i];
					"add ft1 ft1 ft2",
					
					"sub ft3.xy v0 ft3.xy",//gl_TexCoord[0].xy - vec2(0.0, offset[i])/rt_h
					"tex ft3 ft3.xy fs0<2d,wrap,linear>", //texture2D(sceneTex, uv - vec2(0.0, offset[i])/rt_h).rgb
					"add ft1 ft1 ft3",
					
					"mov ft2 fc2",// tc = vec3(1.0, 0.0, 0.0);
					
					"mov ft3 v0",
					"slt ft6 ft3.x fc3.w",//(gl_TexCoord[0].x < (vx_offset-0.01))
					"mul ft4 ft6 ft1", // tc1: first condition 
					
					"sge ft7 ft3.x fc2.w", // (gl_TexCoord[0].x>=(vx_offset+0.01))
					"mul ft5 ft7 ft0", // tc2: second condition
					
					"add ft6 ft6 ft7",
					"sub ft6 fc2.x ft6",
					"mul ft6 ft6 ft2",
					
					"add ft0 ft4 ft5",
					"add ft0 ft0 ft6",
					"mov ft0.w fc2.x",
					
					"mov oc ft0"
					
					
				].join("\n")
				
			);
		}
		
		public override function setShaderConstants(_context3D:Context3D, _viewport:Viewport):void{
			
			// offset
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([0.0, 1.3846153846, 3.2307692308, 0.0]));
			
			//weight
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([0.2270270270, 0.3162162162, 0.0702702703, 1.0]));
			
			// tc 
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([1.0, 0.0, 0.0, m_vxOff + 0.01]));
			
			//vx_offset
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,  Vector.<Number>([m_vxOff, m_width, m_height, m_vxOff - 0.01]));
			
		}
	}
}