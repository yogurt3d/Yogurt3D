
package com.yogurt3d.core.effects.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class FilterSSAO extends Filter
	{
		private var m_totStrength:Number;
		private var m_strength:Number;
		private var m_offset:Number;
		private var m_falloff:Number;
		private var m_radius:Number;
		
		private var m_noiseTex:Texture;
		private var m_noiseTexBitmap:BitmapData = null;
		
		private var m_nbSamples:uint = 5;
		private var m_invSamples:Number;
		
		//#define SAMPLES 16 // 10 is good
		
		public function FilterSSAO( _noiseBitmap:BitmapData, 
									_totStrength:Number=1.38,
									_strength:Number=0.07,
									_offset:Number=18.0, _falloff:Number=0.000002,
									_rad:Number=0.006)
		{
			super();
			m_totStrength = _totStrength;
			m_strength = _strength;
			m_offset = _offset;
			m_falloff = _falloff;
			m_radius = _rad;
			
			m_invSamples =  -1.38/10.0;
			
			m_noiseTexBitmap = _noiseBitmap;
		}
		
		public function get noiseTexBitmap():BitmapData
		{
			return m_noiseTexBitmap;
		}

		public function set noiseTexBitmap(value:BitmapData):void
		{
			m_noiseTexBitmap = value;
		}

		public function get noiseTex():Texture
		{
			return m_noiseTex;
		}

		public function set noiseTex(value:Texture):void
		{
			m_noiseTex = value;
		}

		public function createTextures(_context3D:Context3D):void{
			
			var m:Matrix = new Matrix;
			m.scale(m_width / m_noiseTexBitmap.width, m_height /m_noiseTexBitmap.height);
			var scaledImg:BitmapData = new BitmapData(m_width, m_height, false);
			scaledImg.draw(m_noiseTexBitmap, m, null, null, null, true);
			
			m_noiseTex = _context3D.createTexture(m_width, m_height, Context3DTextureFormat.BGRA, true ); 
			m_noiseTex.uploadFromBitmapData(scaledImg);
			
		}
		
		public function get radius():Number
		{
			return m_radius;
		}

		public function set radius(value:Number):void
		{
			m_radius = value;
		}

		public function get falloff():Number
		{
			return m_falloff;
		}

		public function set falloff(value:Number):void
		{
			m_falloff = value;
		}

		public function get offset():Number
		{
			return m_offset;
		}

		public function set offset(value:Number):void
		{
			m_offset = value;
		}

		public function get strength():Number
		{
			return m_strength;
		}

		public function set strength(value:Number):void
		{
			m_strength = value;
		}

		public function get totStrength():Number
		{
			return m_totStrength;
		}

		public function set totStrength(value:Number):void
		{
			m_totStrength = value;
		}
		
		public override function clearTextures(_context3D:Context3D):void{
			_context3D.setTextureAt(1, null);
		}

		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			var code:String = 
				[
					
					"tex ft0 v0 fs0<2d,wrap,linear>",// get depth + normal map
					
					// grab a normal for reflecting the sample rays later on
					//  vec3 fres = normalize((texture2D(rnm,uv*offset).xyz*2.0) - vec3(1.0));
					"mul ft1 v0 fc8.z",// uv*offset
					"tex ft1 ft1 fs1<2d,wrap,linear>", 
					"mul ft1 ft1 fc6.w",
					"nrm ft1.xyz ft1.xyz",
					"sub ft1.xyz ft1.xyz fc9.zzz",// ft1.xyz = fres
					
					// ft0.xyz = norm 
					// ft0.w = currentPixelDepth 
					
					"mov ft2.xy v0.xy",
					"mov ft2.z ft0.w",//ft2.xyz = ep = vec3(uv.xy,currentPixelDepth);
					
					"div ft2.w fc9.x ft0.w", // ft2.w = radD = rad/currentPixelDepth;
					
					"mov ft1.w fc9.w",// ft1.w =  bl = 0.0;
					
					"mov ft3.x fc9.z",
					"add ft3.z ft3.x fc6.w",
					"sub ft3.x ft3.x fc6.w\n"

				].join("\n");
			
				// fres = ft1.xyz
				// norm = ft0.xyz
				// currentDepthPixel = ft0.w
				// ep = ft2.xyz
				// radD = ft2.w
				// bl = ft1.w
				// ft3.x = minusOne
				// ft3.z = three
			
				for(var i:uint = 0; i < m_nbSamples; i++){
					code += getSphere(i, "ft5.xyz");//pSphere[i]
					code += ShaderUtils.reflect("ft4.xyz","ft5.xyz","ft1.xyz") + "\n";//reflect(pSphere[i],fres);
					code += "mul ft4.xyz ft4.xyz ft2.w\n";//ray = radD*reflect(pSphere[i],fres);
					
					//  occluderFragment = texture2D(normalMap,ep.xy + sign(dot(ray,norm) )*ray.xy);
					code += "dp3 ft5.x ft4.xyz ft0.xyz\n";// dot(ray,norm)
					code += ShaderUtils.signAGAL("ft6","ft5.x", "ft3.x","fc9.z", "fc9.w","fc7.w") + "\n";
					code += "add ft6.xy ft6.x ft2.xy\n";//ep.xy + sign(dot(ray,norm)
					code += "tex ft6 ft6.xy fs0<2d,wrap,linear>\n";// get depth + normal map
					code += "mul ft6 ft6 ft4.xy\n";// occFrag
					code += "sub ft3.y ft0.w ft6.w\n";//depthDifference = currentPixelDepth-occluderFragment.a;
					
					//bl += step(falloff,depthDifference)*
					code += "slt ft5.x fc8.w ft3.y\n";
					
					//(1.0-dot(occluderFragment.xyz,norm))
					code += "dp3 ft5.y ft6.xyz ft0.xyz\n";
					code += "sub ft5.y fc9.z ft5.y\n";
					code += "mov ft3.w fc8.w\n";
					
					//*(1.0-smoothstep(falloff,strength,depthDifference));
					code += ShaderUtils.smoothstep("ft5.z","ft7","ft3.w","fc8.y","ft3.y",
												"fc9.w","fc9.z","fc6.w","ft3.z") + "\n";
					code += "sub ft5.z fc9.z ft5.z\n";
					
					code += "sub ft5.x ft5.x ft5.y\n";
					code += "sub ft5.x ft5.x ft5.z\n";
					
					code += "add ft1.w ft5.x ft1.w\n";
				
				}
				
				code += [
					"mul ft1.w ft1.w fc9.y",//bl*invSamples
					"add ft1.w ft1.w fc9.z",// 1 + bl*invSamples
//					"mov oc fc9.z",
					"mov oc ft1.wwww"
					
				].join("\n");
		
				
				return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT, code);
		}
		
		private function getSphere(_index:uint, _target:String):String{
		
			var code:String = "";
			
			if(_index < 8){
				return "mov "+_target +" fc"+_index+".xyz\n";
			
			}else if(_index == 8){
				code = [
					"mov "+_target+".x fc0.w",
					"mov "+_target+".y fc1.w",
					"mov "+_target+".z fc2.w\n"
					
				].join("\n");
			
			}else if(_index == 9){
				code =  [
					"mov "+_target+".x fc3.w",
					"mov "+_target+".y fc4.w",
					"mov "+_target+".z fc5.w\n"
					
				].join("\n");
			}
		
			return code;
		
		}
		
		public override function setShaderConstants(_context3D:Context3D, _viewport:Rectangle):void{
			
			if(m_noiseTex == null){
				
				createTextures(_context3D);
			}
			_context3D.setTextureAt(1, m_noiseTex);
			
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0,  Vector.<Number>([-1.0, 1.0, 0.0, 0.000001]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 1,  Vector.<Number>([0.5, 0.0, 0.0, 0.0]));
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 8,  Vector.<Number>([totStrength, strength, offset, falloff]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 9,  Vector.<Number>([radius,m_invSamples, 1.0, 0.0]));
			
			// these are the random vectors inside a unit sphere
			// [0] = fc0.xyz - [1] = fc1.xyz - [2] = fc2.xyz - [3] = fc3.xyz
			// [4] = fc4.xyz - [5] = fc5.xyz - [6] = fc6.xyz - [7] = fc7.xyz
			// [8] = fc0.w, fc1.w, fc2.w - [9] = fc3.w, fc4.w, fc5.w (Special Case)
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([-0.010735935,0.01647018, 0.0062425877, 0.8765323]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([-0.06533369,0.3647007, -0.13746321, 0.011236004]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([-0.6539235,-0.016726388, -0.53000957, 0.28265962]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,  Vector.<Number>([0.40958285,0.0052428036, -0.5591124, 0.29264435]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4,  Vector.<Number>([-0.1465366,0.09899267, 0.15571679, -0.40794238]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5,  Vector.<Number>([-0.44122112,-0.5458797, 0.04912532, 0.15964167]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 6,  Vector.<Number>([0.03755566,-0.10961345, -0.33040273, 2.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 7,  Vector.<Number>([0.019100213,0.29652783, 0.066237666, 0.000001]));
			
			
			
		}
	}
}