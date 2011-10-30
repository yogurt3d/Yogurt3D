/*
 * QuadraticSpline.as
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
	public class QuadraticSpline
	{
		public var startVertex			:Vector.<Number>;
		public var controlVertex		:Vector.<Number>;
		public var endVertex			:Vector.<Number>;
		public var length				:Number;
		
		public function QuadraticSpline()
		{
		}
		
		public function initWithVectors(	_startVertex:Vector.<Number>,
											_controlVertex:Vector.<Number>,
											_endVertex:Vector.<Number>):void
		{
			startVertex		= _startVertex;
			controlVertex	= _controlVertex;
			endVertex		= _endVertex;
			
			updateLength();
		}
		
		public function initWithPositions(	_startVertexX:Number,
											_startVertexY:Number,
											_startVertexZ:Number,
											_controlX:Number,
											_controlY:Number,
											_controlZ:Number,
											_endX:Number,
											_endY:Number,
											_endZ:Number):void
		{
			startVertex		= Vector.<Number>([_startVertexX, _startVertexY, _startVertexZ]);
			controlVertex	= Vector.<Number>([_controlX, _controlY, _controlZ]);;
			endVertex		= Vector.<Number>([_endX, _endY, _endZ]);
			
			updateLength();
		}
		
		public function getDeltaPosition(_delta:Number, _resultPosition:Vector.<Number>):void
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
			
			_resultPosition[0]	= startVertex[0] + _filteredDelta * (2 * (1 - _filteredDelta) * (controlVertex[0] - startVertex[0]) + _filteredDelta * (endVertex[0] - startVertex[0]));
			_resultPosition[1]	= startVertex[1] + _filteredDelta * (2 * (1 - _filteredDelta) * (controlVertex[1] - startVertex[1]) + _filteredDelta * (endVertex[1] - startVertex[1]));
			_resultPosition[2]	= startVertex[2] + _filteredDelta * (2 * (1 - _filteredDelta) * (controlVertex[2] - startVertex[2]) + _filteredDelta * (endVertex[2] - startVertex[2]));
		}
		
		public function updateLength():void
		{
			length	= 0;
			
			var _tPositionCurrent	:Vector.<Number> = new Vector.<Number>(3, true);
			var _tPositionOld		:Vector.<Number> = new Vector.<Number>(3, true);
			
			getDeltaPosition(0, _tPositionOld);
			
			for(var i:int = 0; i <= 20; i++)
			{
				if(i)
				{
					var t	:Number	= i / 20;
					
					getDeltaPosition(t, _tPositionCurrent);
					
					length			+= distanceBetweenVertices(_tPositionCurrent, _tPositionOld);
					
					_tPositionOld[0] = _tPositionCurrent[0];
					_tPositionOld[1] = _tPositionCurrent[1];
					_tPositionOld[2] = _tPositionCurrent[2];
				}
			}
		}
		
		private function distanceBetweenVertices(_vertex1:Vector.<Number>, _vertex2:Vector.<Number>):Number
		{
			var dx		:Number	= _vertex1[0] - _vertex2[0];
			var dy		:Number	= _vertex1[1] - _vertex2[1];
			var dz		:Number	= _vertex1[2] - _vertex2[2];
			
			return Math.sqrt(dx * dx + dy * dy + dz * dz);
		}
	}
}
