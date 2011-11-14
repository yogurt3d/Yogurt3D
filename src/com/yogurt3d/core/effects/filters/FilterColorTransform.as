/*
* FilterColorTransform.as
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
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	/**
	 * Applies color converting filter to adjust brightness and saturation
	 * 
	 * @author Ozgun Genc
	 * @company Yogurt3D Corp.
	 **/
	public class FilterColorTransform extends Filter
	{
		private var m_colorCube:Matrix3D;
		
		private var m_saturationFactor:Number = 1;
		private var m_brightnessFactor:Number = 1;
		private var m_red_brightnessFactor:Number = 1;
		private var m_green_brightnessFactor:Number = 1;
		private var m_blue_brightnessFactor:Number = 1;
		
		private var m_currentContext3D:Context3D;
		
		public function FilterColorTransform()
		{	
			
			m_colorCube = new Matrix3D();
			
			
		}
		
		public function get blue_brightnessFactor():Number
		{
			return m_blue_brightnessFactor;
		}
		
		public function set blue_brightnessFactor(value:Number):void
		{
			if (value>0){
				m_blue_brightnessFactor = value;
				
				updateColorCube();
			}
		}
		
		public function get green_brightnessFactor():Number
		{
			return m_green_brightnessFactor;
		}
		
		public function set green_brightnessFactor(value:Number):void
		{
			if (value>0){
				m_green_brightnessFactor = value;
				
				updateColorCube();
			}
		}
		
		public function get red_brightnessFactor():Number
		{
			return m_red_brightnessFactor;
			
		}
		
		public function set red_brightnessFactor(value:Number):void
		{
			if (value>0){
				m_red_brightnessFactor = value;
				
				updateColorCube();
			}
		}
		
		public function get brightnessFactor():Number
		{
			return m_brightnessFactor;
		}
		
		public function set brightnessFactor(value:Number):void
		{
			if (value>0){
				m_brightnessFactor = value;
				
				updateColorCube();
			}
		}
		
		public function get saturationFactor():Number
		{
			return m_saturationFactor;
		}
		
		public function set saturationFactor(value:Number):void
		{
			if (value>0){
				m_saturationFactor = value;
				
				updateColorCube();
			}
		}
		
		
		private function updateColorCube():void
		{
			m_colorCube.identity();
			
			// set brightness
			m_colorCube.appendScale(m_brightnessFactor*m_red_brightnessFactor, m_brightnessFactor*m_green_brightnessFactor, m_brightnessFactor*m_blue_brightnessFactor);
			
			// saturation 
			m_colorCube.appendRotation(45, new Vector3D(1,-1,0));
			m_colorCube.appendScale(m_saturationFactor, m_saturationFactor, 1);
			m_colorCube.appendRotation(-45, new Vector3D(1,-1,0));
			
			if (m_currentContext3D) setShaderConstants(m_currentContext3D, null);
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
				[			
					"tex ft0 v0 fs0<2d,wrap,linear>", 
					
					"mov ft2 ft0",
					"m34 ft2.xyz, ft2.xyz, fc0", // output: color converted pixel
					
					"mov oc ft2"
					
				].join("\n")
				);
		}
		
		
		public override function setShaderConstants(_context3D:Context3D, _viewport:Rectangle):void{
			m_currentContext3D = _context3D;
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.FRAGMENT, 0,  m_colorCube);
		}
		
		
		
	}
}