package com.yogurt3d.core.helpers
{
	import com.yogurt3d.core.transformations.Transformation;
	import com.yogurt3d.core.utils.MathUtils;
	import com.yogurt3d.core.utils.MatrixUtils;
	
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Transform;

/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class ProjectionUtils
	{
		public static function setProjectionOrtho(_matrix:Matrix3D,_width:Number, _height:Number, _near:Number, _far:Number):Matrix3D
		{
			var _xScale:Number = 2.0 / _width;
			var _yScale:Number = 2.0 / _height;
			var _deltaZ:Number = _near - _far;//right handed
			
			_matrix.copyRawDataFrom(Vector.<Number>([
				_xScale, 0.0, 0.0, 0.0,
				0.0, _yScale, 0.0, 0.0,
				0.0, 0.0, 1.0/_deltaZ, 0.0,
				0.0, 0.0, _near/_deltaZ, 1.0
			]));
			
			return _matrix;
		}
		
		public static function setProjectionOrthoAsymmetric(_matrix:Matrix3D, _left:Number, _right:Number, _bottom:Number, _top:Number, _near:Number, _far:Number):Matrix3D
		{
			var _deltaX:Number = _right-_left;
			var _deltaY:Number = _top -_bottom;
			var _deltaZ:Number = _near - _far;//right handed
			
			_matrix.copyRawDataFrom(Vector.<Number>([
				2.0 / _deltaX, 0.0, 0.0, 0.0,
				0.0, 2.0 / _deltaY, 0.0, 0.0,
				0.0, 0.0, 1.0/_deltaZ, 0.0,
				(_left+_right)/-_deltaX, (_top +_bottom)/-_deltaY, _near/_deltaZ, 1.0
			]));
			
			return _matrix;
		}
		
		public static function setProjectionPerspective(_matrix:Matrix3D,_fovy:Number, _aspect:Number, _near:Number, _far:Number):Matrix3D
		{	
			var _yScale:Number = 1.0/Math.tan(_fovy/2.0*MathUtils.DEG_TO_RAD);
			var _xScale:Number = _yScale / _aspect; 
			var _deltaZ:Number = _near-_far;//right handed
			
			_matrix.copyRawDataFrom(Vector.<Number>([
				_xScale, 0.0, 0.0, 0.0,
				0.0, _yScale, 0.0, 0.0,
				0.0, 0.0, _far/_deltaZ, -1.0,
				0.0, 0.0, (_near*_far)/_deltaZ, 0.0
			]));
			
			return _matrix;
		}
		public static function setProjectionPerspectiveAsymmetric(_matrix:Matrix3D,width:Number, _height:Number, _near:Number, _far:Number):Matrix3D
		{
			var _deltaZ			:Number				= _near - _far;
			
			if( _deltaZ == 0  )	throw new Error("Invalid parameters.");
			
			var _m				:Vector.<Number> 	= MatrixUtils.RAW_DATA;
			
			_m[0]	= 2.0 * _near / width;
			_m[5]	= 2.0 * _near / _height;
			_m[8]	= 0;
			_m[9]	= 0;
			_m[10]	= _far / _deltaZ;
			_m[11]	= -1.0;
			_m[14]	= _far * _near / _deltaZ;
			_m[15]	= 0.0;
			
			_m[1] = 0;
			_m[2] = 0;
			_m[3] = 0;
			_m[4] = 0;
			_m[6] = 0;
			_m[7] = 0;
			_m[12] = 0;
			_m[13] = 0;
			
			_matrix.copyRawDataFrom( _m );
			
			return _matrix;
			
		}
	}
}
