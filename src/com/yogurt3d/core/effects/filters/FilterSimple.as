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

	public class FilterSimple extends Filter
	{
		private var m_totStrength:Number;
		private var m_strength:Number;
		private var m_offset:Number;
		private var m_falloff:Number;
		private var m_radius:Number;
		
		private var m_noiseTex:Texture;
		private var m_noiseTexBitmap:BitmapData = null;
		
		private var m_nbSamples:uint = 3;
		private var m_invSamples:Number;
		
		public function FilterSimple(_noiseBitmap:BitmapData)
		{			
			super();
			
			m_totStrength = 1.38;
			m_strength = 0.07;
			m_offset = 18.0;
			m_falloff = 0.000002;
			m_radius = 0.006;
				
			m_invSamples =  -1.38/m_nbSamples;
			
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
		
		public override function clearTextures(_context3D:Context3D):void{
			_context3D.setTextureAt(1, null);
		}
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{
			var code:String = [
				// grab a normal for reflecting the sample rays later on
				//vec3 fres = normalize((texture2D(rnm,uv*offset).xyz*2.0) - vec3(1.0));
				"mul ft0.xy v0.xy fc6.w",//uv*offset // 1
				"tex ft0 ft0.xy fs1<2d,wrap,linear>",//(texture2D(rnm,uv*offset) // 2
				"mul ft0.xyz ft0.xyz fc0.w", //(texture2D(rnm,uv*offset).xyz*2.0) // 3
				"sub ft0.xyz ft0.x fc2.www",//(texture2D(rnm,uv*offset).xyz*2.0) - vec3(1.0)) // 4
				"nrm ft0.xyz ft0.xyz",// fres = ft0.xyz // 5
				
				// GET NORMALS & DEPTH		
				"tex ft3 v0 fs0<2d,wrap,linear>", // 6
				// get xy as normals
				"mul ft1.xy ft3.xy fc0.w", // 7
				"sub ft1.xy ft1.xy fc2.w", // 8
				// generate z 
				//n.z = sqrt(1-dot(n.xy, n.xy));
				"mul ft2.x ft1.x ft1.x", // 9
				"mul ft2.y ft1.y ft1.y",//10
				"sub ft1.z fc2.w ft2.x",//11
				"sub ft1.z ft1.z ft2.y",//12
				"nrm ft1.xyz ft1.xyz", //13
				// decode depth
				"mul ft1.w ft3.w fc3.w",//depth.y  * (1/255) //14
				"add ft1.w ft1.w ft3.z",//depth.x + (depth.y  * (1/255)) //15
				// currentPixelDepth = ft1.w
				// currentNormal = ft1.xyz
				
				"mov ft2.xy v0.xy",//16
				"mov ft2.z ft1.w",// vec3 ep = vec3(uv.xy,currentPixelDepth); //17
				
				"mov ft0.w fc1.w",//float bl = 0.0; //18
				"div ft2.w fc8.w ft1.w\n",//float radD = rad/currentPixelDepth; //19
				
				//"mov oc ft1"
			].join("\n");
			
			//20
			//public static function reflect(_target:String, _incidence:String, _normal:String):String{
			
			for(var i:uint = 0; i < m_nbSamples; i++){
			
				code += [
					ShaderUtils.reflect("ft3", "fc"+i+".xyz", "ft0.xyz"),//reflect(pSphere[i],fres)//20,21,22,23
					"mul ft4.xyz ft2.w ft3.xyz",// ft4.xyz = ray = radD*reflect(pSphere[i],fres); //24
					
					"dp3 ft4.w ft4.xyz ft1.xyz",//dot(ray,norm) //25
					ShaderUtils.signAGAL("ft5", "ft4.w","fc10.x", "fc2.w", "fc1.w", "fc10.z"),//ft5.x = result //[25, 29]
					"add ft5.xy ft0.xy ft5.x",//ep.xy + sign(dot(ray,norm) // 30
					
					"tex ft3 ft5.xy fs0<2d,wrap,linear>", //texture2D(normalMap,ep.xy + sign(dot(ray,norm) ) //31
					"mul ft3 ft3 ft4.xy",//texture2D(normalMap,ep.xy + sign(dot(ray,norm) )*ray.xy) //32
					
					// GET NORMALS & DEPTH		
					"tex ft3 ft3.xy fs0<2d,wrap,linear>", //33
					// get xy as normals
					"mul ft5.xy ft3.xy fc0.w", // 34
					"sub ft5.xy ft1.xy fc2.w", //35
					// generate z 
					//n.z = sqrt(1-dot(n.xy, n.xy));
					"mul ft4.x ft5.x ft5.x", //36
					"mul ft4.y ft5.y ft5.y", //37
					"sub ft5.z fc2.w ft4.x", //38
					"sub ft5.z ft5.z ft4.y", //39
					"nrm ft5.xyz ft5.xyz", //40
					// decode depth
					"mul ft5.w ft3.w fc3.w",//depth.y  * (1/255) //41
					"add ft5.w ft5.w ft3.z",//depth.x + (depth.y  * (1/255)) //42
					
					"sub ft3.x ft1.w ft5.w",//depthDifference = currentPixelDepth-occluderFragment.a; //43
					
					"slt ft3.y fc7.w ft3.x",//step(falloff,depthDifference) //44
					"dp3 ft3.z ft5.xyz ft1.xyz", //45
					"sub ft3.z fc2.w ft3.z",//(1.0-dot(occluderFragment.xyz,norm) //46
					
					"mul ft3.y ft3.y ft3.z",//step(falloff,depthDifference)*(1.0-dot(occluderFragment.xyz,norm)) //47
					"mov ft3.w fc7.w",	//48
					ShaderUtils.smoothstep("ft3.z","ft7","ft3.w","fc5.w","ft3.x",
						"fc1.w","fc2.w","fc0.w","fc10.y"),//[49, 57]
					
					"mul ft3.y ft3.y ft3.z",//step(falloff,depthDifference)*(1.0-dot(occluderFragment.xyz,norm))
					//					*(1.0-smoothstep(falloff,strength,depthDifference)); // 58
					
					"add ft0.w ft0.w ft3.y\n" //59
									
				].join("\n");
			
			}
			
			code += [
				"mul ft0.w ft0.w fc9.w",//bl*invSamples //60
				"add ft0.w ft0.w fc2.w",//1.0 + bl*invSamples //61
 				//"mov oc fc10.zzzz",
				"mov oc ft0.wwww" //62
			].join("\n");
			
			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT, code);
		}
		
		public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray
		{
//			
//			"mov op va0\n"+
//				"mov v0 va1"
			var code:String = [
				"",
				""
			
			
			].join("\n");
			return ShaderUtils.vertexAssambler.assemble( AGALMiniAssembler.VERTEX, code);
		}
		
		public override function setShaderConstants(_context3D:Context3D, view:Rectangle):void{
	
			if(m_noiseTex == null){
				
				createTextures(_context3D);
			}
			_context3D.setTextureAt(1, m_noiseTex);
			
		//	_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([2.0, 0.0, 1.0, (1.0/255.0 as Number)]));
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([-0.010735935,0.01647018, 0.0062425877, 2.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([-0.06533369,0.3647007, -0.13746321, 0.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([-0.6539235,-0.016726388, -0.53000957, 1.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,  Vector.<Number>([0.40958285,0.0052428036, -0.5591124, (1.0/255.0 as Number)]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4,  Vector.<Number>([-0.1465366,0.09899267, 0.15571679, m_totStrength]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5,  Vector.<Number>([-0.44122112,-0.5458797, 0.04912532, m_strength]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 6,  Vector.<Number>([0.03755566,-0.10961345, -0.33040273, m_offset]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 7,  Vector.<Number>([0.019100213,0.29652783, 0.066237666, m_falloff]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 8,  Vector.<Number>([0.8765323, 0.011236004, 0.28265962, m_radius]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 9,  Vector.<Number>([0.29264435, -0.40794238, 0.15964167, m_invSamples]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 10,  Vector.<Number>([-1.0, 3.0, 0.0000001, 0.0]));
			
			
		}
	}
}