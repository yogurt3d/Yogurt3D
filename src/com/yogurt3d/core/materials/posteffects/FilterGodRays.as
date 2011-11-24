package com.yogurt3d.core.materials.posteffects
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.effects.filters.Filter;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class FilterGodRays extends Filter
	{
		private var m_blurStart:Number = 1.0;
		private var m_blurWidth:Number = -0.3;
		private var m_cx:Number = 0.5;
		private var m_cy:Number = 0.5;
		private var m_intensity:Number = 6.0;
		private var m_glowGamma:Number = 1.6;
		private var m_nbSamples:uint = 10;
		
		public function FilterGodRays()
		{
			super();
		}
		// SetVertexShader( CompileShader( vs_4_0, VS_GodRays(QuadTexelOffsets,gCX,gCY) ) );
//		uniform float2 TexelOffset,
//		uniform float CX,
//		uniform float CY
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			var code:String = [
				"mov ft0.x fc0.z",// float2 ctrPt = float2(CX,CY);
				"mov ft0.y fc0.w",
				"mov ft0.z fc0.w",//i
				"mov ft1 fc1.wwww\n",// ft1 = blur
			].join("\n");
			
			for(var i:uint = 0; i < m_nbSamples; i++){
			
				code += "div ft0.w ft0.z fc2.x\n";//(i/(float) (nsamples-1));
				code += "mul ft0.w ft0.w fc0.y\n";//BlurWidth*(i/(float) (nsamples-1));
				code += "add ft0.w ft0.w fc0.x\n";//scale = BlurStart + BlurWidth*(i/(float) (nsamples-1));
				
				code += "mul ft2.xy v0.xy ft0.w\n";//IN.UV.xy*scale
				//code += "add ft2.xy ft2.xy ft0.xy\n";//IN.UV.xy*scale + ctrPt 
				code += "tex ft2 ft2.xy fs0<2d,wrap,linear>\n";//
				code += "add ft1 ft1 ft2\n";//blurred += tex2D(tex, IN.UV.xy*scale + ctrPt );
				
				code += "mov ft0.z fc1.z\n";//i = i +1
			}
			
			
			code += [
				"div ft1 ft1 fc2.y",//blurred /= nsamples;
				"pow ft1.xyz ft1.xyz fc1.y",//blurred.rgb = pow(blurred.rgb,GlowGamma);
				"mul ft1.xyz ft1.xyz fc1.x",//blurred.rgb *= Intensity;
				ShaderUtils.clamp("ft5.x","ft1.xyz","fc1.z","fc1.w"),
				"mov ft1.xyz ft5.x",
				//"add ft3.xy v0.xy ft0.xy",//IN.UV.xy + ctrPt 
				"tex ft3 v0 fs0<2d,wrap,linear>",// half4 origTex = tex2D(tex, IN.UV.xy + ctrPt );
				"sub ft4.x fc1.z ft3.w",//(1.0-origTex.a)
				"mul ft4.xyz ft4.x ft1.xyz",//(1.0-origTex.a)* blurred.rgb
				"add ft4.xyz ft3.xyz ft4.xyz",//origTex.rgb + (1.0-origTex.a)* blurred.rgb;
				"max ft4.w ft3.w ft1.w",//half newA = max(origTex.a,blurred.a);
				
				"mov oc ft4"
				
			].join("\n");
			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT, code);
		}
		
		public override function setShaderConstants(_context3D:Context3D, _viewport:Rectangle):void{
			
		
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_blurStart, m_blurWidth, m_cx, m_cy]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([m_intensity, m_glowGamma, 1.0, 0.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([(m_nbSamples-1 as Number),m_nbSamples, 0.0, 0.0]));
		}
	}
}