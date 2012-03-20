/*
 * Quaternion.as
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
 
 
package com.yogurt3d.core.transformations
{
	import com.yogurt3d.core.utils.MathUtils;
	import com.yogurt3d.core.utils.MatrixUtils;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class Quaternion
	{
		private var m_x:Number, m_y:Number, m_z:Number, m_w:Number;
		
		private static var EPSILON:Number = 1e-03;
		
		public function Quaternion(w:Number=1,x:Number=0,y:Number=0,z:Number=0)
		{
			m_x = x;
			m_y = y;
			m_z = z;
			m_w = w;
		}
		
		public function get w():Number
		{
			return m_w;
		}

		public function set w(value:Number):void
		{
			m_w = value;
		}

		public function get z():Number
		{
			return m_z;
		}

		public function set z(value:Number):void
		{
			m_z = value;
		}

		public function get y():Number
		{
			return m_y;
		}

		public function set y(value:Number):void
		{
			m_y = value;
		}

		public function get x():Number
		{
			return m_x;
		}

		public function set x(value:Number):void
		{
			m_x = value;
		}
		
		public function setTo( _w:Number, _x:Number, _y:Number, _z:Number ):void{
			m_w = _w; m_x = _x; m_y = _y; m_z = _z;
		}

		
		public function dot( rkQ:Quaternion):Number
		{
			return w*rkQ.w+x*rkQ.x+y*rkQ.y+z*rkQ.z;
		}

		public function multiply ( _quaternion:Quaternion, copyTo:Quaternion = null):Quaternion
		{
			// NOTE:  Multiplication is not generally commutative, so in most
			// cases p*q != q*p.
			
			var _X:Number = _quaternion.x;
			var _Y:Number = _quaternion.y;
			var _Z:Number = _quaternion.z;
			var _W:Number = _quaternion.w;
			
			if( copyTo != null )
			{
				copyTo.w = w * _W - x * _X - y * _Y - z * _Z;
				copyTo.x = w * _X + x * _W + y * _Z - z * _Y;
				copyTo.y = w * _Y + y * _W + z * _X - x * _Z;
				copyTo.z = w * _Z + z * _W + x * _Y - y * _X;
				return copyTo;
			}
			return new Quaternion
			(
				w * _W - x * _X - y * _Y - z * _Z,
				w * _X + x * _W + y * _Z - z * _Y,
				w * _Y + y * _W + z * _X - x * _Z,
				w * _Z + z * _W + x * _Y - y * _X
			);
		}
		
		public function multiplyVector( _vector:Vector3D ):Vector3D{
			// nVidia SDK implementation
			var uv:Vector3D, uuv:Vector3D;
			var qvec:Vector3D = new Vector3D(m_x, m_y, m_z);
			uv = qvec.crossProduct(_vector);
			uuv = qvec.crossProduct(uv);
			uv.scaleBy( 2.0 * w );
			uuv.scaleBy( 2.0 );
			
			return _vector.add(uv).add(uuv);
		}
		
		public function multiplyScalar( _scalar:Number, _qua:Quaternion = null ):Quaternion{
			// nVidia SDK implementation
			var qua:Quaternion = _qua || new Quaternion();
			qua.w = w * _scalar;
			qua.x = x * _scalar;
			qua.y = y * _scalar;
			qua.z = z * _scalar;
			
			return qua;
		}
		
		public function toVector3D(_vec:Vector3D = null):Vector3D{
			var vec:Vector3D = _vec || new Vector3D();
			vec.setTo( m_x, m_y, m_z );
			vec.w = m_w;
			return vec;
		}
		
		
		/**
		 * 
		 * @param _vec
		 * @see http://www.euclideanspace.com/maths/geometry/rotations/conversions/eulerToQuaternion/index.htm
		 */
		public function fromEuler( _vec:Vector3D ):void{
			var heading:Number = _vec.y* MathUtils.DEG_TO_RAD;
			var attitude:Number = _vec.z* MathUtils.DEG_TO_RAD;
			var bank:Number = _vec.x* MathUtils.DEG_TO_RAD;
			
			var c1:Number = Math.cos( heading / 2 );
			var s1:Number = Math.sin( heading / 2 );
			var c2:Number = Math.cos( attitude / 2 );
			var s2:Number = Math.sin( attitude / 2 );
			var c3:Number = Math.cos( bank / 2 );
			var s3:Number = Math.sin( bank / 2 );
			
			var c1c2:Number = c1*c2;
			var s1s2:Number = s1*s2;
			
			w = c1c2*c3 - s1s2*c3;
			x = c1c2*s3 + s1s2*c3;
			y = s1*c2*c3 + c1*s2*s3;
			z = c1*s2*c3 - s1*c2*s3;			
		}
		public function toEuler(target : Vector3D = null) : Vector3D
		{
			target ||= new Vector3D();
			
			var sqw:Number = m_w*m_w;
			var sqx:Number = m_x*m_x;
			var sqy:Number = m_y*m_y;
			var sqz:Number = m_z*m_z;
			var unit:Number = sqx + sqy + sqz + sqw; // if normalised is one, otherwise is correction factor
			var test:Number = m_x*m_y + m_z*m_w;
			if (test > 0.499*unit) { // singularity at north pole
				target.y = 2 * Math.atan2(m_x,m_w);
				target.z = Math.PI/2;
				target.x = 0;
				target.scaleBy( MathUtils.RAD_TO_DEG );
				return target;
			}
			if (test < -0.499*unit) { // singularity at south pole
				target.y = -2 * Math.atan2(m_x,m_w);
				target.z = -Math.PI/2;
				target.x = 0;
				target.scaleBy( MathUtils.RAD_TO_DEG );
				return target;
			}
			target.y = Math.atan2(2*m_y*m_w-2*m_x*m_z , sqx - sqy - sqz + sqw);
			target.z = Math.asin(2*test/unit);
			target.x = Math.atan2(2*m_x*m_w-2*m_y*m_z , -sqx + sqy - sqz + sqw);
			target.scaleBy( MathUtils.RAD_TO_DEG );
			return target;
		}
		
		public function add( _quaterion:Quaternion, _output:Quaternion = null ):Quaternion
		{
			var out:Quaternion = _output || new Quaternion();
			
			return new Quaternion(w+_quaterion.w,x+_quaterion.x,y+_quaterion.y,z+_quaterion.z);
		}
		
		public function sub (_quaterion:Quaternion) :Quaternion
		{
			return new Quaternion(w-_quaterion.w,x-_quaterion.x,y-_quaterion.y,z-_quaterion.z);
		}
		
		public function inverse():Quaternion{
			
			var fNorm:Number = m_w*m_w+m_x*m_x+m_y*m_y+m_z*m_z;
			if ( fNorm > 0.0 )
			{
				var fInvNorm:Number = 1.0 / fNorm;
				return new Quaternion(m_w*fInvNorm,-m_x*fInvNorm,-m_y*fInvNorm,-m_z*fInvNorm);
			}
			else
			{
				// return an invalid result to flag the error
				return null;
			}
			
		}
		public function negate(_value:Quaternion = null):Quaternion{
			
			var quo:Quaternion = _value || new Quaternion();
			quo.w = w;
			quo.x = -x;
			quo.y = -y;
			quo.z = -z;
			return quo;
		}
		
		public function toRotationMatrix():Matrix3D
		{
			var fTx:Number  = m_x+m_x;
			var fTy:Number  = m_y+m_y;
			var fTz:Number  = m_z+m_z;
			var fTwx:Number = fTx*m_w;
			var fTwy:Number = fTy*m_w;
			var fTwz:Number = fTz*m_w;
			var fTxx:Number = fTx*m_x;
			var fTxy:Number = fTy*m_x;
			var fTxz:Number = fTz*m_x;
			var fTyy:Number = fTy*m_y;
			var fTyz:Number = fTz*m_y;
			var fTzz:Number = fTz*m_z;
			
			var rawData:Vector.<Number> = MatrixUtils.RAW_DATA;
			
			rawData[0] = 1.0-(fTyy+fTzz);
			rawData[1] = fTxy-fTwz;
			rawData[2] = fTxz+fTwy;
			rawData[3] = 0;
			
			rawData[4] = fTxy+fTwz;
			rawData[5] = 1.0-(fTxx+fTzz);
			rawData[6] = fTyz-fTwx;
			rawData[7] = 0;
			
			rawData[8] = fTxz-fTwy;
			rawData[9] = fTyz+fTwx;
			rawData[10] = 1.0-(fTxx+fTyy);
			rawData[11] = 0;
			
			rawData[12] = 0;
			rawData[13] = 0;
			rawData[14] = 0;
			rawData[15] = 1;
			return new Matrix3D( rawData );
		}
		
		public function clone():Quaternion{
			return new Quaternion( m_w, m_x,m_y, m_z);
		}
		
		public function normalise(_qua:Quaternion = null):Quaternion
		{
					var len:Number = m_w * m_w + m_x * m_x + m_y * m_y + m_z * m_z;
					var factor:Number = 1.0 / Math.sqrt(len);
					
					var qua:Quaternion = _qua || new Quaternion();
					qua.setTo( m_w, m_x, m_y, m_z );
					qua.multiplyScalar( factor, qua );
					
					return qua;
		}
		
		public static function slerp ( t:Number, qa:Quaternion, qb:Quaternion):Quaternion
		{
			var w1 : Number = qa.w, x1 : Number = qa.x, y1 : Number = qa.y, z1 : Number = qa.z;
			var w2 : Number = qb.w, x2 : Number = qb.x, y2 : Number = qb.y, z2 : Number = qb.z;
			var dot : Number = w1*w2 + x1*x2 + y1*y2 + z1*z2;
			var _x:Number;
			var _y:Number;
			var _z:Number;
			var _w:Number;
			
			
			// shortest direction
			if (dot < 0) {
				dot = -dot;
				w2 = -w2;
				x2 = -x2;
				y2 = -y2;
				z2 = -z2;
			}
			
			if (dot < 0.95)
			{
				// interpolate angle linearly
				var angle : Number = Math.acos(dot);
				var s : Number = 1/Math.sin(angle);
				var s1 : Number = Math.sin(angle*(1-t))*s;
				var s2 : Number = Math.sin(angle*t)*s;
				_w = w1*s1 + w2*s2;
				_x = x1*s1 + x2*s2;
				_y = y1*s1 + y2*s2;
				_z = z1*s1 + z2*s2;
			}
			else {
				// nearly identical angle, interpolate linearly
				_w = w1 + t*(w2 - w1);
				_x = x1 + t*(x2 - x1);
				_y = y1 + t*(y2 - y1);
				_z = z1 + t*(z2 - z1);
				var len : Number = 1.0/Math.sqrt(_w*_w + _x*_x + _y*_y + _z*_z);
				_w *= len;
				_x *= len;
				_y *= len;
				_z *= len;
			}
			return new Quaternion(_w,_x,_y,_z);
		}
		
		public function toString():String{
			return "Quaternion x:" + m_x + " ,y:" + m_y + " ,z:" + m_z + ", w:" + m_w;
		}
		
	}
}
