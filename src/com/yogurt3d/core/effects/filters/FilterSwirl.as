/*
* FilterSwirl.as
* This file is part of Yogurt3D Flash Rendering Engine 
*
* Copyright (C) 2011 - Yogurt3D Corp.
*
* Yogurt3D Flash Rendering Engine is free software; you can redistribute it and/or
* modify it under the terms of the YOGURT3D CLICK-THROUGH AGREEMENT
* License.
* 
* Yogurt3D Flash Rendering Engine is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
* 
* You should have received a copy of the YOGURT3D CLICK-THROUGH AGREEMENT
* License along with this library. If not, see <http://www.yogurt3d.com/yogurt3d/downloads/yogurt3d-click-through-agreement.html>. 
*/
package com.yogurt3d.core.effects.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.utils.MathUtils;
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class FilterSwirl extends Filter
	{
		private var m_radius:Number;
		private var m_angle:Number;
		private var m_centerX:Number;
		private var m_centerY:Number;
		private var m_effect:Number;
		
		public function FilterSwirl(_radius:Number=200.0, _angle:Number=0.8, _centerX:Number=400, _centerY:Number=300, _effect:Number=8.0)
		{
			m_radius = _radius;
			m_angle = _angle;
			m_centerX = _centerX;
			m_centerY = _centerY;
			m_effect = _effect;
			
			super();
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{		
			//			vec2 texSize = vec2(rt_w, rt_h);
			//			vec2 tc = uv * texSize;
			//			tc -= center;
			//			float dist = length(tc);
			//			if (dist < radius)
			//			{
			//				float percent = (radius - dist) / radius;
			//				float theta = percent * percent * angle * 8.0;
			//				float s = sin(theta);
			//				float c = cos(theta);
			//				tc = vec2(dot(tc, vec2(c, -s)), dot(tc, vec2(s, c)));
			//			}
			//			tc += center;
			//			vec3 color = texture2D(tex0, tc / texSize).rgb;
			//			return vec4(color, 1.0);
			
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				
				[					
					"mul ft1.xy v0.xy fc0.xy", //tc = uv * texSize;
					"sub ft1.xy ft1.xy fc1.xy",//tc -= center;
					
					ShaderUtils.length("ft2.x","ft1.xy"),//float dist = length(tc);
					
					"sub ft3.x fc0.z ft2.x",//(radius - dist)
					"div ft3.x ft3.x fc0.z",// percent = (radius - dist) / radius;
					"mul ft3.y ft3.x fc0.w",//percent * angle
					"mul ft3.x ft3.y ft3.x",//percent * percent * angle
					"mul ft3.x ft3.x fc1.z",//theta = percent * percent * angle * 8.0;
					
					"sin ft3.y ft3.x", //float s = sin(theta);
					"cos ft3.z ft3.x", //float c = cos(theta);
					
					"mov ft4.x ft3.z",//vec2(c, -s)
					"mul ft4.w ft3.y fc2.x",//  
					"mov ft4.y ft4.w",
					"mov ft4.z ft3.y",//vec2(s, c)
					"mov ft4.w ft3.z",//vec2(s, c)
					// ft4: c, -s, s, c
					
					"dp3 ft5.x ft1.xy ft4.xy",//dot(tc, vec2(c, -s)
					"dp3 ft5.y ft1.xy ft4.zw",//dot(tc, vec2(s, c))
					
					"slt ft3 ft2.x fc0.z", //if (dist < radius)
					"mul ft4 ft5.xy ft3",
					
					"sub ft3 fc1.w ft3",
					"mul ft3 ft3 ft1.xy",
					
					"add ft1 ft4 ft3",
					"add ft1 ft1 fc1.xy",
					
					//color = texture2D(tex0, tc / texSize).rgb;
					
					"div ft2 ft1 fc0.xy",
					"tex ft1 ft2 fs0<2d,wrap,linear>", // get render to texture
					"mov ft1.w fc1.w",
					
					"mov oc ft1"
					
				].join("\n")
				
			);
		}
		
		public function get radius():Number{
			return m_radius;
		}
		
		public function set radius(_value:Number):void{
			m_radius = _value;
		}
		
		public function get angle():Number{
			return m_angle;
		}
		
		public function set angle(_value:Number):void{
			m_angle = _value;
		}
		
		public function get centerX():Number{
			return m_centerX;
		}
		
		public function set centerX(_value:Number):void{
			m_centerX = _value;
		}
		
		public function get centerY():Number{
			return m_centerY;
		}
		
		public function set centerY(_value:Number):void{
			m_centerY = _value;
		}
		
		public function get effect():Number{
			return m_effect;
		}
		
		public function set effect(_value:Number):void{
			m_effect = _value;
		}
		
		public override function setShaderConstants(_context3D:Context3D, view:Rectangle):void{
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([m_width, m_height, m_radius, m_angle]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([m_centerX, m_centerY, m_effect, 1.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([-1.0, 0.0, 0.0, 0.0]));
		}
	}
}