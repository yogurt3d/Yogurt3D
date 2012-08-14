package com.yogurt3d.presets.cameras
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.managers.tickmanager.TickManager;
	import com.yogurt3d.core.managers.tickmanager.TimeInfo;
	import com.yogurt3d.core.objects.interfaces.ITickedObject;
	import com.yogurt3d.core.sceneobjects.SceneObject;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class TargetCamera extends Camera implements ITickedObject
	{
		private var m_rotX:Number = 0;
		private var m_rotY:Number = 0;
		private var m_rotZ:Number = 0;
		private var m_dist:Number = 10;
		
		private var m_targetRotX:Number = 0;
		private var m_targetRotY:Number = 0;
		private var m_targetRotZ:Number = 0;
		private var m_targetDist:Number = 10;
		
		private var m_lastUpdateTime:uint = 0;
		
		private var m_limitRotXMin:Number = NaN;
		
		private var m_limitRotXMax:Number = NaN;
		
		private var m_limitRotYMin:Number = NaN;
		
		private var m_limitRotYMax:Number = NaN;
		
		private var m_limitdistMin:Number = NaN;
		private var m_limitdistMax:Number = NaN;
		
		private var m_matrix3d:Matrix3D;

		private static var m_mouseLastX:Number;
		private static var m_mouseLastY:Number;
		
		private var m_target:SceneObject;
		
		public var mouseControlEnabled:Boolean = true;
		
		public function TargetCamera(_viewport:DisplayObject, _initInternals:Boolean=true)
		{
			super(_initInternals);
			TickManager.registerObject( this );
			
			_viewport.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveEvent );
			_viewport.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelEvent );
			
			m_target = new SceneObject;
		}
		
		public override function dispose():void{
			TickManager.unRegisterObject( this );
		}
		
		public function get target():SceneObject{
			return m_target;
		}
		
		public function set target(value:SceneObject):void{
			m_target = value;
		}
		
		private function onMouseWheelEvent( event:MouseEvent ):void{
			dist -= event.delta;
		}
		
		
		public function get limitDistMax():Number
		{
			return m_limitdistMax;
		}
		
		public function set limitDistMax(value:Number):void
		{
			m_limitdistMax = value;
		}
		
		public function get limitDistMin():Number
		{
			return m_limitdistMin;
		}
		
		public function set limitDistMin(value:Number):void
		{
			m_limitdistMin = value;
		}
		
		private function onMouseMoveEvent( event:MouseEvent ):void{
			if(!mouseControlEnabled)
			{
				return;
			}
			
			var _offsetX:Number 	= m_mouseLastX - event.localX;
			var _offsetY:Number 	= m_mouseLastY - event.localY;
			
			if (event.buttonDown )
			{
				rotY += _offsetX ;
				rotX += _offsetY ;
			}
			
			m_mouseLastX 	= event.localX;
			m_mouseLastY 	= event.localY;
		}
		
		
		
		public function get limitRotXMax():Number
		{
			return m_limitRotXMax;
		}
		
		public function set limitRotXMax(value:Number):void
		{
			m_limitRotXMax = value;
		}
		
		public function get limitRotXMin():Number
		{
			return m_limitRotXMin;
		}
		
		public function set limitRotXMin(value:Number):void
		{
			m_limitRotXMin = value;
		}
		
		public function get limitRotYMax():Number
		{
			return m_limitRotYMax;
		}
		
		public function set limitRotYMax(value:Number):void
		{
			m_limitRotYMax = value;
		}
		
		public function get limitRotYMin():Number
		{
			return m_limitRotYMin;
		}
		
		public function set limitRotYMin(value:Number):void
		{
			m_limitRotYMin = value;
		}
		
		public function get dist():Number
		{
			return m_targetDist;
		}
		
		public function set dist(value:Number):void
		{
			m_targetDist = value;
			if( !isNaN(m_limitdistMax) && value > m_limitdistMax )
			{
				m_targetDist = m_limitdistMax;
			}
			if( !isNaN(m_limitdistMin) && value < m_limitdistMin )
			{
				m_targetDist = m_limitdistMin;
			}
		}
		
		public function get rotZ():Number
		{
			return m_targetRotZ;
		}
		
		public function set rotZ(value:Number):void
		{
			m_targetRotZ = value;
		}
		
		public function get rotY():Number
		{
			return m_targetRotY;
		}
		
		public function set rotY(value:Number):void
		{
			m_targetRotY = value;
			if( !isNaN(m_limitRotYMin) && value < m_limitRotYMin )
			{
				m_targetRotY = m_limitRotYMin;
			}
			if( !isNaN(m_limitRotYMax) && value > m_limitRotYMax )
			{
				m_targetRotY = m_limitRotYMax;
			}
		}
		
		public function get rotX():Number
		{
			return m_targetRotX;
		}
		
		public function set rotX(value:Number):void
		{
			m_targetRotX = value;
			if( !isNaN(m_limitRotXMin) && value < m_limitRotXMin )
			{
				m_targetRotX = m_limitRotXMin;
			}
			if( !isNaN(m_limitRotXMax) && value > m_limitRotXMax )
			{
				m_targetRotX = m_limitRotXMax;
			}
			
		}
		public function updateWithTimeInfo(_timeInfo:TimeInfo):void{
			m_matrix3d = new Matrix3D();
			
			
			var _ease:Number = 0.1;
			
			var _dx:Number = m_targetRotX - m_rotX;
			var _dy:Number = m_targetRotY - m_rotY;
			var _dz:Number = m_targetRotZ - m_rotZ;
			
			var _dist:Number = _dx*_dx + _dy*_dy + _dz*_dz;
			
			var _dDist:Number = m_targetDist - m_dist;
			
			var _distDist:Number = _dDist * _dDist;
			
			if( _distDist < 0.0001 )
			{
				m_dist = m_targetDist;
			}else{
				m_dist += _dDist * _ease;
			}
			
			if( _dist < 0.0001 )
			{
				m_rotX = m_targetRotX;
				m_rotY = m_targetRotY;
				m_rotZ = m_targetRotZ;
			}else{
				m_rotX += _dx * _ease;
				m_rotY += _dy * _ease;
				m_rotZ += _dz * _ease;
			}
			
			
			m_matrix3d.identity();
			m_matrix3d.appendTranslation( 0, 0, m_dist);
			m_matrix3d.appendRotation( m_rotX, Vector3D.X_AXIS );
			m_matrix3d.appendRotation( m_rotY, Vector3D.Y_AXIS );
			m_matrix3d.appendRotation( m_rotZ, Vector3D.Z_AXIS );
			m_matrix3d.appendTranslation( m_target.transformation.x, m_target.transformation.y, m_target.transformation.z );
			
			transformation.position = m_matrix3d.position;
			transformation.lookAt( m_target.transformation.position );
			
		}
		
	}
}