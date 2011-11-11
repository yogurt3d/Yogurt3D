package com.yogurt3d.core.effects.filters
{
	
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	
	public class FilterBoxBlur extends Filter
	{
		private var m_step:Vector.<Number> = new Vector.<Number>;
		private var m_direction:Vector.<Number> = new Vector.<Number>;
		
		public function FilterBoxBlur()
		{
		}
		
		public function get direction():Vector.<Number>
		{
			return m_direction;
		}
		
		
		public function setdirection( _x:Number, _y:Number):void
		{
			
			m_direction[0] = _x;
			m_direction[1] = _y;
		}
		
		public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			/*blurVSOutput output = (blurVSOutput)0;
			output.Position = Position;
			float2 texelSize = 1.0f / float2(SHADOW_MAP_SIZE, SHADOW_MAP_SIZE);
			float2 step = direction * texelSize;
			outside calc
			float2 base = TexCoord - ((((float)taps - 1)*0.5f) * step);
			
			for (int i = 0; i < taps; i++)
			{
				output.TexCoord[i] = base;
				base += step;
			}
			
			return output;*/
			
			
			return ShaderUtils.vertexAssambler.assemble( AGALMiniAssembler.VERTEX,
				[
					
					"sub vt1.xy, va1.xy, vc0.xy",//TexCoord - ((((float)taps - 1)*0.5f) * step)---->base  vt1.xy
					
					"mov v0 vt1.xy",
					"add vt1.xy, vt1.xy, vc0.zw",//base += step;
					
					"mov v1 vt1.xy",
					"add vt1.xy, vt1.xy, vc0.zw",//""
					
					"mov v2 vt1.xy",
					"add vt1.xy, vt1.xy, vc0.zw",
					
					"mov v3 vt1.xy",
					"add vt1.xy, vt1.xy, vc0.zw",
					
					"mov v4 vt1.xy",
					//"add vt1.xy, vt1.xy, vc0.zw",
					
					"mov op va0"
					
				
				].join("\n")
			);
		}
		
		/*float log_conv ( float x0, float X, float y0, float Y )
		{
			return (X + log(x0 + (y0 * exp(Y - X))));
		}*/
		
		/*BlurPSOutput output;
		
		float  sample[5];
		for (int i = 0; i < 5; i++)
		{
			sample[i] = tex2D( tex, input.TexCoord[i] ).x;
		}
		
		const float c = (1.f/5.f);    
		
		float accum;
		accum = log_conv( c, sample[0], c, sample[1] );
		for (int i = 2; i < 5; i++)
		{
			accum = log_conv( 1.f, accum, c, sample[i] );
		}    
		
		output.depth = accum;
		return output;*/
		
		public override function getFragmentProgram(_lightType:ELightType=null ):ByteArray{
			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				[
					
					"sat ft3.xy, v0.xy",
					"tex ft1 ft3.xy fs0<2d,nearest,clamp>", // for each texturecoordinate do sample[i] = tex2D( tex, input.TexCoord[i] ).x;
					"dp4 ft2.x, ft1, fc0",//fc0 = encoder
					
					"sat ft3.xy, v1.xy",
					"tex ft1, ft3.xy, fs0<2d,nearest,clamp>",//ft2.xyzw ,ft1.x = sample[5]
					"dp4 ft2.y, ft1, fc0",
					
					"sat ft3.xy, v2.xy",
					"tex ft1, ft3.xy, fs0<2d,nearest,clamp>",
					"dp4 ft2.z, ft1, fc0",
					
					"sat ft3.xy, v3.xy",
					"tex ft1, ft3.xy, fs0<2d,nearest,clamp>",
					"dp4 ft2.w, ft1, fc0",
					
					"sat ft3.xy, v4.xy",
					"tex ft1, ft3.xy, fs0<2d,nearest,clamp>",
					"dp4 ft1.x, ft1, fc0",
					//
					/*"sub ft2.y, ft2.y, ft2.x",//Y - X
					"pow ft2.y, fc1.x, ft2.y", //fc1.x the e number exp(Y - X)
					"mul ft2.y, fc1.y, ft2.y", // fc1.y = 1.f/5.f = c    y0 * exp(Y - X)))
					"add ft2.y, fc1.y, ft2.y",//fc1.y  log(x0 + (y0 * exp(Y - X))
					"log ft2.y, ft2.y",*/
					
					"add ft2.x, ft2.x, ft2.y",//(X + log(x0 + (y0 * exp(Y - X))))  = accum
					
					/*accum = log_conv( c, sample[0], c, sample[1] );
					for (int i = 2; i < 5; i++)
					{
					accum = log_conv( 1.f, accum, c, sample[i] );
					}*/
					
					/*"sub ft2.y, ft2.z, ft2.x",//Y - X
					"pow ft2.y, fc1.x, ft2.y", //fc1.x the e number exp(Y - X)
					"mul ft2.y, fc1.y, ft2.y", // fc1.y = 1.f/5.f = c    y0 * exp(Y - X)))
					"add ft2.y, fc1.z, ft2.y",//fc1.z   = x0 log(x0 + (y0 * exp(Y - X))
					"log ft2.y, ft2.y",*/
					
					"add ft2.x, ft2.x, ft2.z",//(X + log(x0 + (y0 * exp(Y - X))))  = accum
					
					/*"sub ft2.y, ft2.w, ft2.x",//Y - X
					"pow ft2.y, fc1.x, ft2.y", //fc1.x the e number exp(Y - X)
					"mul ft2.y, fc1.y, ft2.y", // fc1.y = 1.f/5.f = c    y0 * exp(Y - X)))
					"add ft2.y, fc1.z, ft2.y",//fc1.z   = x0 log(x0 + (y0 * exp(Y - X))
					"log ft2.y, ft2.y",*/
					
					"add ft2.x, ft2.x, ft2.w",//(X + log(x0 + (y0 * exp(Y - X))))  = accum
					
					
					/*"sub ft2.y, ft1.x, ft2.x",//Y - X
					"pow ft2.y, fc1.x, ft2.y", //fc1.x the e number exp(Y - X)
					"mul ft2.y, fc1.y, ft2.y", // fc1.y = 1.f/5.f = c    y0 * exp(Y - X)))
					"add ft2.y, fc1.z, ft2.y",//fc1.z   = x0 log(x0 + (y0 * exp(Y - X))
					"log ft2.y, ft2.y",*/
					
					"add ft2.x, ft2.x, ft1.x",//(X + log(x0 + (y0 * exp(Y - X))))  = accum
					
					"div ft2.x, ft2.x, fc1.w",
					
					"mul ft0, fc2, ft2.x",//encoder code
					"frc ft0, ft0",
					"mul ft1, ft0.yzww, fc3",
					"sub ft0, ft0, ft1",
					"mov oc, ft0"
				
				].join("\n")
			);
		}
		
		
		
		
		public override function setShaderConstants(_context3D:Context3D, _viewport:Rectangle):void{
			
			m_step[0] = (1/_viewport.width) * m_direction[0];
			m_step[1] = (1/_viewport.height) * m_direction[1];
			 
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0,  
				Vector.<Number>([ 2*m_step[0], 2*m_step[1], m_step[0], m_step[1] ]), 1);//((float)taps - 1)*0.5f) (5 - 1)* 0.5 = 2
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, 
				Vector.<Number>([ 1, 1/(256), 1/(256*256), 1/(256*256*256) ,2.71828183 ,0.2, 1 ,5 ]), 2);
			
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, 
				Vector.<Number>([1, 255, 65025, 160581375, 0.003921569, 0.003921569, 0.003921569, 0 ]), 2);
			
			
			_context3D.setDepthTest( false, Context3DCompareMode.ALWAYS );
			_context3D.setBlendFactors( Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			// set culling
			_context3D.setCulling( Context3DTriangleFace.NONE );
			_context3D.setColorMask( true, true, true, true);
			
			
			/*params.culling = Context3DTriangleFace.FRONT;
			params.blendEnabled 	= false;
			params.blendSource 		= Context3DBlendFactor.ONE;// source:shadow
			params.blendDestination = Context3DBlendFactor.ZERO;
			
			params.writeDepth = false;
			params.depthFunction = Context3DCompareMode.ALWAYS;
			params.colorMaskEnabled = false;
			params.colorMaskA = false;*/
			
			
			
			//trace((1/PostEffect.width as Number), (1/PostEffect.height as Number));
	
			
			//_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([dx, dy, m_two, 0.0]));
			
		//	_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([m_sixteen, m_four, 1.0, 0.0]));
			
			//_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([-dx, -dy, 0.0, 0.0]));
		}
	}
}