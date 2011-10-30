/*
 * CurveUtils.as
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
 
 
package com.yogurt3d.core.utils
{
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class CurveUtils
	{
		public static function getPositionOnQuadricSpline(	_startVertex	:Vector.<Number>,
															_controlVertex	:Vector.<Number>,
															_endVertex		:Vector.<Number>,
															_delta			:Number,
															_resultPosition	:Vector.<Number>):void
		{
			var _filteredDelta	:Number	= _delta;
			
			if(_delta < 0)
			{
				_filteredDelta	= 0;
			}
			
			if(_delta > 1)
			{
				_filteredDelta	= 1;
			}
			
			_resultPosition[0]	= _startVertex[0] + _filteredDelta * (2 * (1 - _filteredDelta) * (_controlVertex[0] - _startVertex[0]) + _filteredDelta * (_endVertex[0] - _startVertex[0]));
			_resultPosition[1]	= _startVertex[1] + _filteredDelta * (2 * (1 - _filteredDelta) * (_controlVertex[1] - _startVertex[1]) + _filteredDelta * (_endVertex[1] - _startVertex[1]));
			_resultPosition[2]	= _startVertex[2] + _filteredDelta * (2 * (1 - _filteredDelta) * (_controlVertex[2] - _startVertex[2]) + _filteredDelta * (_endVertex[2] - _startVertex[2]));
		}
	}
}
