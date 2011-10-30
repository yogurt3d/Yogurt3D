/*
 * SplineSequence.as
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
 
 
package com.yogurt3d.core.helpers.splines
{
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class SplineSequence
	{
		private var m_splines		:Vector.<QuadraticSpline>;
		private var m_lengthRatios	:Vector.<Number>;
		
		public function SplineSequence()
		{
			m_splines		= new Vector.<QuadraticSpline>();
			m_lengthRatios	= new Vector.<Number>();
		}
		
		public function addSpline(_value:QuadraticSpline):void
		{
			m_splines[m_splines.length]	= _value;
			m_lengthRatios.length		= m_splines.length;
			
			update();
		}
		
		public function removeSpline(_value:QuadraticSpline):void
		{
			var _splineIndex	:int = m_splines.indexOf(_value);
			
			if(_splineIndex != -1)
			{
				m_splines.splice(_splineIndex, 1);
				m_lengthRatios.length = m_splines.length;
				
				update();
			}
		}
		
		public function getDeltaPosition(_delta:Number, _resultPosition:Vector.<Number>):void
		{
			var _splineCount	:uint = m_splines.length;
			
			for(var i:uint = 0; i < _splineCount; i++)
			{
				if(i)
				{
					if(_delta > m_lengthRatios[i - 1] && _delta <= m_lengthRatios[i])
					{
						m_splines[i].getDeltaPosition((_delta - m_lengthRatios[i - 1]) / (m_lengthRatios[i] - m_lengthRatios[i - 1]), _resultPosition);
						return;
					}
				} else {
					if(_delta < m_lengthRatios[0])
					{
						m_splines[i].getDeltaPosition(_delta / m_lengthRatios[i], _resultPosition);
						return;
					}
				}
			}
		}
		
		private function update():void
		{
			var _length		:Number = getLength();
			
			for(var i:int = 0; i < m_splines.length; i++)
			{
				if(i)
				{
					m_lengthRatios[i] = m_lengthRatios[i - 1] + m_splines[i].length / _length;
				} else {
					m_lengthRatios[i] = m_splines[i].length / _length;
				}
			}
		}
		
		private function getLength():Number
		{
			var _length	:Number = 0;
			
			for(var i:int = 0; i < m_splines.length; i++)
			{
				_length += m_splines[i].length;
			}
			
			return _length;
		}
	}
}
