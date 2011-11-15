/*
 * Color.as
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
 
package com.yogurt3d.core.materials.base
{
	import flash.geom.Vector3D;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class Color
	{
		private var m_colorVector:Vector.<Number>;
		private var m_colorVectorRaw:Vector.<Number>;
		private var m_color:Vector.<Number>;
		
		
		public function Color(_r:Number, _g:Number, _b:Number, _a:Number = 1)
		{
			m_color = new Vector.<Number>(4,true);
			setColorf( _r, _g, _b, _a );
		}
		
		public function get a():Number
		{
			return m_color[3];
		}
		
		public function set a(value:Number):void
		{
			m_color[3] = value;
			
			generateVector();
		}
		
		public function get r():Number
		{
			return m_color[0];
		}
		
		public function set r(value:Number):void
		{
			m_color[0] = value;
			
			generateVector();
		}
		
		public function get g():Number
		{
			return m_color[1];
		}
		
		public function set g(value:Number):void
		{
			m_color[1] = value;
			
			generateVector();
		}
		
		public function get b():Number
		{
			return m_color[2];
		}
		
		public function set b(value:Number):void
		{
			m_color[2] = value;
			
			generateVector();
		}

		/**
		 *  
		 * @param _r 0-255
		 * @param _g 0-255
		 * @param _b 0-255
		 * @param a 0-100
		 * 
		 */
		public function setColorub( _r:uint, _g:uint, _b:uint, _a:uint = 1 ):void{
			m_color[0] = (_r & 0xFF) / 255;
			m_color[1] = (_g & 0xFF) / 255;
			m_color[2] = (_b & 0xFF) / 255;
			m_color[3] = _a / 100;
			
			generateVector();
		}
		
		/**
		 * Sets the color and intensity component.
		 * WARNING: format is 0xFFFFFFFF first byte for intensity the rest is for color
		 * 
		 * @param _color 0x00000000-0xFFFFFFFF
		 * @example 0xFF000000 | 0xEFFFD7
		 */
		public function setColorUint( _color:uint ):void{			
			m_color[3] = (_color >> 24 & 255) / 255;
			m_color[0] = (_color >> 16 & 255 ) / 255;
			m_color[1] = (_color >> 8 & 255) / 255;
			m_color[2] = (_color & 255) / 255;
			
			generateVector();
		}
		
		/**
		 * 
		 * @param _r 0-1
		 * @param _g 0-1
		 * @param _b 0-1
		 * 
		 */
		public function setColorf( _r:Number, _g:Number, _b:Number, _a:Number = 1 ):void{
			m_color[0] = _r;
			m_color[1] = _g;
			m_color[2] = _b;
			m_color[3] = _a;
			
			generateVector();
		}
		
		public function toUint():uint
		{
			return (m_color[3] * 255) << 24 | (m_color[0] * 255) << 16 | (m_color[1] * 255) << 8 | (m_color[2] * 255);
		}
		
		private function generateVector():void{
			m_colorVector = Vector.<Number>([m_color[0] * m_color[3], m_color[1] * m_color[3], m_color[2] * m_color[3], m_color[3]]);
			m_colorVectorRaw = Vector.<Number>([m_color[0] , m_color[1] , m_color[2] , m_color[3]]);
		}
		
		
		public function getColorVector():Vector.<Number>{
			return m_colorVector;
		}
		
		public function getColorVectorRaw():Vector.<Number>{
			return m_colorVectorRaw;
		}
	}
}
