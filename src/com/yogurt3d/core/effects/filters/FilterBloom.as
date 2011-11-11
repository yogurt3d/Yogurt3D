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

	public class FilterBloom extends Filter
	{
		private var m_distance:Number = 0.0008;
		private var m_power:Number = 0.1;
		private var m_threshold:Number = 0.3;
		
		public function FilterBloom()
		{
			super();
		}
		
//		for( i= -4 ;i < 4; i++)
//		{
//			for (j = -3; j < 3; j++)
//			{
//				sum += texture2D(texture, texcoord + vec2(i, j)*glaresize) * power;
//			}
//		}
//		if (texture2D(bgl_RenderedTexture, texcoord).r < 2)
//		{
//			gl_FragColor = sum*sum*0.012 + texture2D(bgl_RenderedTexture, texcoord);
//		}

		public function get blurPower():Number
		{
			return m_distance;
		}
		
		public function set blurPower(value:Number):void
		{
			m_distance = value;
		}
		
		public function get power():Number
		{
			return m_power;
		}
		
		public function set power(value:Number):void
		{
			m_power = value;
		}
		public function get threshold():Number
		{
			return m_threshold;
		}
		
		public function set threshold(value:Number):void
		{
			m_threshold = value;
		}

		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			var j:int, i:int;
			
			var code:String = "";
			
			code += "mov ft0 v0\n";
			
			for( i= -2 ;i < 2; i++)//9
			{
				code += getParamX(-i, "ft6.x");
				code += getParamX(i, "ft7.y");
				for (j = -1; j < 2; j++){//7
					code += getParamY(j, "ft6.y");
					code += getParamY(i, "ft7.x");
					
					code += "mul ft1.xy ft6.xy fc0.xx\n"; // vec2(j, i)*blurDistance
					code += "add ft1.xy ft1.xy ft0.xy\n"; // texcoord + vec2(j, i)*blurDistance
					
				
					code += "tex ft1 ft1.xy fs0<2d,clamp,linear>\n"; // texture2D(bgl_RenderedTexture, texcoord + vec2(j, i)*blurDistance)
					code += "mul ft1 ft1 fc0.w\n";
					if( i == -2 && j == -1 )
					{
						code += "mov ft2, ft1\n";
					}else{
						code += "add ft2 ft1 ft2\n";
					}
					
					
					code += "mul ft1.xy ft7.xy fc0.xx\n"; // vec2(j, i)*blurDistance
					code += "add ft1.xy ft1.xy ft0.xy\n"; // texcoord + vec2(j, i)*blurDistance
					
					code += "tex ft1 ft1.xy fs0<2d,clamp,linear>\n"; // texture2D(bgl_RenderedTexture, texcoord + vec2(j, i)*blurDistance)
					code += "mul ft1 ft1 fc0.w\n";
					if( i == -2 && j == -1 )
					{
						code += "mov ft6, ft1\n";
					}else{
						code += "add ft6 ft1 ft6\n";
					}
				}
			}
			code += "tex ft3 v0.xy fs0<2d,clamp,linear>\n";
			code += "slt ft4.x ft3.x fc0.z\n" ;//if (texture2D(bgl_RenderedTexture, texcoord).r < 0.3)
			code += "mul ft5.x ft4.x fc3.x\n"; // coeff
			code += "add ft5.x ft5.x fc3.y\n"; // coeff (min coeff)
						
			code += "mul ft2.xyz ft2.xyz ft2.xyz\n"; // sum*sum
			code += "mul ft6.xyz ft6.xyz ft6.xyz\n"; // bum*bum
			code += "add ft2.xyz ft2.xyz ft6.xyz\n"; // sum*sum + bum*bum
			code += "mul ft2.xyz ft2.xyz ft5.x\n"; // sum*sum*coeff
			code += "add ft2.xyz ft3.xyz ft2.xyz\n"; // sum*sum*coeff + texture2D(bgl_RenderedTexture, texcoord)
			
			code += "mov ft2.w fc2.x\n";
			code += "mov oc ft2\n";
			code.split("\n");
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT, code );
		}
		public function getParamX( i:int, put:String =  "ft6.x" ):String{
			var posVec:Array = ["x", "y", "z", "w"];
			var code:String = "";
			if( i != 0 )
			{
				code += "mov "+put+" fc"+ ((i < 0)?1:2) + "." + posVec[Math.abs(i)-1] + "\n";
			}else{
				code += "mov "+put+" fc3.w\n";
			}
			return code;
		}
		public function getParamY( j:int, put:String =  "ft6.y" ):String{
			var posVec:Array = ["x", "y", "z", "w"];
			var code:String = "";
			if( j != 0 )
			{
				code += "mov "+put+" fc"+ ((j < 0)?1:2) + "."+posVec[Math.abs(j)-1]+ "\n";
			}else{
				code += "mov "+put+" fc3.w\n";
			}
			return code;
		}
		public override function setShaderConstants(_context3D:Context3D, _viewport:Rectangle):void{
			_context3D.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 0, Vector.<Number>([m_distance,0.0008,m_threshold,m_power]));
			_context3D.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 1, Vector.<Number>([-1,-2,-3,-4]));
			_context3D.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 2, Vector.<Number>([1,2,3,4]));
			_context3D.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 3, Vector.<Number>([0.012 - 0.0075,0.0075, 0.11,0]));
			
		}
	}
}