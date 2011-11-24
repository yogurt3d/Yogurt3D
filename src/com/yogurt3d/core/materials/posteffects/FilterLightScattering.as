package com.yogurt3d.core.materials.posteffects
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.effects.filters.Filter;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.utils.MathUtils;
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class FilterLightScattering extends Filter
	{
		private var m_exposure:Number;
		private var m_decay:Number;
		private var m_density:Number;
		private var m_weight:Number;
		private var m_numSamples:uint;
		private var m_numLights:uint;
		
		public function FilterLightScattering(_numLights:uint,
											  _exposure:Number=1.0, _decay:Number=0.5, 
											  _density:Number=1.0, _weight:Number=1.0, 
											  _numSamples:uint=20)
		{
			exposure = _exposure;
			decay = _decay;
			density = _density;
			weight = _weight;
			m_numSamples = _numSamples;
			m_numLights = _numLights;
			
			super();
		}
		
		public function get numLights():uint
		{
			return m_numLights;
		}

		public function set numLights(value:uint):void
		{
			m_numLights = value;
		}

		public function get weight():Number
		{
			return m_weight;
		}

		public function set weight(value:Number):void
		{
			m_weight = value;
		}

		public function get density():Number
		{
			return m_density;
		}

		public function set density(value:Number):void
		{
			m_density = value;
		}

		public function get decay():Number
		{
			return m_decay;
		}

		public function set decay(value:Number):void
		{
			m_decay = value;
		}

		public function get exposure():Number
		{
			return m_exposure;
		}

		public function set exposure(value:Number):void
		{
			m_exposure = value;
		}

		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{			
			var code:String;
			
			code = [
				"sub ft1.xy v0.xy fc0.xy",//deltaTextCoord = vec2( gl_TexCoord[0].st - lightPositionOnScreen.xy );
				"mov ft2.x fc"+(m_numLights+1)+".z",//ft2.x = float(NUM_SAMPLES)
				"mul ft2.x ft2.x fc"+(m_numLights)+".z",//float(NUM_SAMPLES) * density
				"div ft2.x fc"+(m_numLights+1)+".x ft2.x",//1.0 / float(NUM_SAMPLES) * density;
				"mul ft1.xy ft1.xy ft2.x",//deltaTextCoord *= 1.0 / float(NUM_SAMPLES) * density;
				
				"mov ft3.xy v0.xy",// textCoo = gl_TexCoord[0].st;
				"mov ft3.z fc"+(m_numLights+1)+".x",//illuminationDecay = 1.0;
				"tex ft0 v0 fs0<2d,wrap,linear>"
			].join("\n");
			
			code += "\n";
			
			for(var i:uint =0; i< m_numSamples ; i++){
				
				code += "sub ft3.xy ft3.xy ft1.xy\n";//textCoo -= deltaTextCoord;
				code += "tex ft4 ft3.xy fs0<2d,wrap,linear>\n";//sample = texture2D(firstPass, textCoo );
				code += "mul ft3.w ft3.z fc"+(m_numLights)+".w\n";//illuminationDecay * weight;
				code += "mul ft4 ft4 ft3.w\n";//sample *= illuminationDecay * weight;
			
				code += "add ft0 ft0 ft4\n";//gl_FragColor += sample;
				code += "mul ft3.z ft3.z fc"+(m_numLights)+".y\n";
			}
			
			code += "mul ft0 ft0 fc"+(m_numLights)+".x\n";
			//code += "mov ft0.w fc0.z\n";
			code += "mov ft0.w fc"+ (m_numLights+1) +".x\n";
			code += "mov oc ft0";
			
			trace(code);
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT, code);
		}
		
		
		
		public override function setShaderConstants(_context3D:Context3D, view:Rectangle):void{
						
//			for(var i:uint = 0; i < _lights.length; i++){
//				_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, i, _lights[i].positionVector);
//			}
		
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, m_numLights,  Vector.<Number>([exposure, decay, density, weight]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, m_numLights+1,  Vector.<Number>([1.0, 0.0, m_numSamples, 0.0]));
			
		}
	}
}
