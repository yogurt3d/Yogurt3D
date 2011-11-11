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

	public class FilterRadialBlur extends Filter
	{
		
		private var m_samples:Vector.<String>;
		private var m_nbSamples:Number;
		
		private var m_sampleDist:Number = 1.0;
		private var m_sampleStrength:Number = 2.2; 
		
		public function FilterRadialBlur()
		{
			super();
			
			m_samples = Vector.<String>(["fc0.x", "fc0.y", "fc0.z", "fc0.w", "fc1.x", "fc1.y", "fc1.z","fc1.z", "fc2.x", "fc2.y"]);
			
			m_nbSamples = m_samples.length;
		}
		
		
		public function get sampleStrength():Number
		{
			return m_sampleStrength;
		}

		public function set sampleStrength(value:Number):void
		{
			m_sampleStrength = value;
		}

		public function get sampleDist():Number
		{
			return m_sampleDist;
		}

		public function set sampleDist(value:Number):void
		{
			m_sampleDist = value;
		}

		public function get nbSamples():Number
		{
			return m_nbSamples;
		}

		public function get samples():Vector.<String>
		{
			return m_samples;
		}

		public function set samples(value:Vector.<String>):void
		{
			m_samples = value;
			m_nbSamples = m_samples.length;
		}

		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			var code:String = [
				
				
				
				"sub ft1.xy fc2.w v0.xy",//vec2 dir = 0.5 - uv; 
				"mul ft1.z ft1.x ft1.x",//dir.x*dir.x 
				"mul ft1.w ft1.y ft1.y",// dir.y*dir.y
				"add ft1.z ft1.z ft1.w",//dir.x*dir.x + dir.y*dir.y
				"sqt ft1.z ft1.z",//float dist = sqrt(dir.x*dir.x + dir.y*dir.y); 
				
				"div ft1.xy ft1.xy ft1.z",//dir = dir/dist; 
				
				"tex ft0 v0 fs0<2d,wrap,linear>",//color = texture2D(tex,uv); 
				"mov ft2 ft0\n"
				
				
			].join("\n");
			
			for(var i:uint = 0; i < nbSamples; i++ ){
				
				code += "mul ft3.xy ft1.xy "+m_samples[i]+"\n";//dir * samples[i] 
				code += "mul ft3.xy ft3.xy fc3.x\n";//dir * samples[i] * sampleDist 
				code += "add ft3.xy ft3.xy v0.xy\n";//uv + dir * samples[i] * sampleDist
				
				code += "tex ft4 ft3.xy fs0<2d,wrap,linear>\n";//texture2D( tex, uv + dir * samples[i] * sampleDist );
				
				code += "add ft2 ft2 ft4\n";
			}
			
			
			
			code += [
				"mul ft2 ft2 fc3.z",// sum *= 1.0/11.0;
				"mul ft5.x ft1.z fc3.y",//dist * sampleStrength;
				ShaderUtils.clamp("ft5.y","ft5.x","fc3.w","fc2.z"),//t = clamp( t ,0.0,1.0);
				
				"sub ft5.z fc2.z ft5.y",
				ShaderUtils.mix("ft6","ft7","ft0","ft2","ft5.y","ft5.z"),
				
				"mov ft6.w fc2.z",
				"mov oc ft6"
			
			].join("\n");
			
			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT, code);
		}
		
		public override function setShaderConstants(_context3D:Context3D, _viewport:Rectangle):void{
			
			
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([-0.08,-0.05,-0.03,-0.02]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([-0.01,0.01,0.02,0.03]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([0.05, 0.08, 1.0, 0.5 ]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,  Vector.<Number>([m_sampleDist, m_sampleStrength, ((1.0/(nbSamples+1)) as Number), 0.0]));
		}
	}
}