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
	
	public class FilterGaussianBlurVertical extends Filter
	{
		private var m_offset1:Number = 1.3846153846;
		private var m_offset2:Number = 3.2307692308;
		
		private var m_weight1:Number = 0.2270270270;
		private var m_weight2:Number = 0.3162162162;
		private var m_weight3:Number = 0.0702702703;
		
		public function FilterGaussianBlurVertical()
		{
			super();	
		}
		
		
		public function get weight3():Number
		{
			return m_weight3;
		}

		public function set weight3(value:Number):void
		{
			m_weight3 = value;
		}

		public function get weight2():Number
		{
			return m_weight2;
		}

		public function set weight2(value:Number):void
		{
			m_weight2 = value;
		}

		public function get weight1():Number
		{
			return m_weight1;
		}

		public function set weight1(value:Number):void
		{
			m_weight1 = value;
		}

		public function get offset2():Number
		{
			return m_offset2;
		}

		public function set offset2(value:Number):void
		{
			m_offset2 = value;
		}

		public function get offset1():Number
		{
			return m_offset1;
		}

		public function set offset1(value:Number):void
		{
			m_offset1 = value;
		}

		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{			
			// offset : fc0 [0.0, 1.3846153846, 3.2307692308, 0.0]
			// weight : fc1 [0.2270270270, 0.3162162162, 0.0702702703, 1.0]
			// fc2: [1.0, 0.0, 0.0, m_height]
		
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				[
					
					"mov ft1.xyz fc2.xyz",// vec3 tc = vec3(1.0, 0.0, 0.0);
					"tex ft0 v0 fs0<2d,wrap,linear>",// tc2 = texture2D(sceneTex, gl_TexCoord[0].xy).rgb; 
					"mul ft1.xyz ft0.xyz fc1.x",// tc1 = texture2D(sceneTex, uv).rgb * weight[0];
					
					//tc += texture2D(sceneTex, gl_TexCoord[0].xy + vec2(0.0, offset[1])/rt_h).rgb * weight[1];
					//tc += texture2D(sceneTex, gl_TexCoord[0].xy - vec2(0.0, offset[1])/rt_h).rgb * weight[1];
					
					"mov ft2.x fc0.x",
					"mov ft2.y fc0.y",//vec2(0.0, offset[1])
					"div ft2.xy ft2.xy fc2.w",//vec2(0.0, offset[1])/rt_h
					
					"add ft3.xy ft2.xy v0.xy",//gl_TexCoord[0].xy + vec2(0.0, offset[1])/rt_h
					"tex ft3 ft3.xy fs0<2d,wrap,linear>",
					"mul ft3.xyz ft3.xyz fc1.y",//texture2D(sceneTex, gl_TexCoord[0].xy + vec2(0.0, offset[1])/rt_h).rgb * weight[1]
					"add ft1.xyz ft1.xyz ft3.xyz",
					
					"sub ft3.xy v0.xy ft2.xy",//gl_TexCoord[0].xy - vec2(0.0, offset[1])/rt_h
					"tex ft3 ft3.xy fs0<2d,wrap,linear>",
					"mul ft3.xyz ft3.xyz fc1.y",//texture2D(sceneTex, gl_TexCoord[0].xy + vec2(0.0, offset[1])/rt_h).rgb * weight[1]
					"add ft1.xyz ft1.xyz ft3.xyz",
					
					
					//tc += texture2D(sceneTex, gl_TexCoord[0].xy + vec2(0.0, offset[2])/rt_h).rgb * weight[2];
					//tc += texture2D(sceneTex, gl_TexCoord[0].xy - vec2(0.0, offset[2])/rt_h).rgb * weight[2];
					
					"mov ft2.x fc0.x",
					"mov ft2.y fc0.z",//vec2(0.0, offset[1])
					"div ft2.xy ft2.xy fc2.w",//vec2(0.0, offset[1])/rt_h
					
					"add ft3.xy ft2.xy v0.xy",//gl_TexCoord[0].xy + vec2(0.0, offset[1])/rt_h
					"tex ft3 ft3.xy fs0<2d,wrap,linear>",
					"mul ft3.xyz ft3.xyz fc1.z",//texture2D(sceneTex, gl_TexCoord[0].xy + vec2(0.0, offset[1])/rt_h).rgb * weight[1]
					"add ft1.xyz ft1.xyz ft3.xyz",
					
					"sub ft3.xy v0.xy ft2.xy",//gl_TexCoord[0].xy - vec2(0.0, offset[1])/rt_h
					"tex ft3 ft3.xy fs0<2d,wrap,linear>",
					"mul ft3.xyz ft3.xyz fc1.z",//texture2D(sceneTex, gl_TexCoord[0].xy + vec2(0.0, offset[1])/rt_h).rgb * weight[1]
					"add ft1.xyz ft1.xyz ft3.xyz",
				
					"mov ft1.w fc1.w",
					"mov oc ft1"
					
					
				].join("\n")
				
			);
		}
		
		public override function setShaderConstants(_context3D:Context3D, _viewport:Rectangle):void{
			
			// offset
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([0.0, m_offset1, m_offset2, 0.0]));
			
			//weight
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([m_weight1, m_weight2, m_weight3, 1.0]));
			
			// tc 
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([1.0, 0.0, 0.0, m_height]));
		
		}
	}
}