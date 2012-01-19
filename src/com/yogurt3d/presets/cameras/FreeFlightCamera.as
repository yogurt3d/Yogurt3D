package com.yogurt3d.presets.cameras
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.managers.tickmanager.TickManager;
	import com.yogurt3d.core.managers.tickmanager.TimeInfo;
	import com.yogurt3d.core.objects.interfaces.ITickedObject;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	public class FreeFlightCamera extends Camera implements ITickedObject
	{
		
		private var m_isCtrlDown:Boolean;
		private var m_isShiftDown:Boolean;
		
		private var m_leftKey		:Boolean = false;
		private var m_rightKey		:Boolean = false;
		private var m_upKey			:Boolean = false;
		private var m_downKey		:Boolean = false;
		
		private var m_mouseLastX:Number;
		private var m_mouseLastY:Number;
		
		private var m_viewport:DisplayObject;
		
		public function FreeFlightCamera(_viewport:DisplayObject, _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			if( _viewport.stage )
			{
				_viewport.stage.addEventListener(KeyboardEvent.KEY_DOWN, 	onKeyDown);
				_viewport.stage.addEventListener(KeyboardEvent.KEY_UP, 		onKeyUp );
			}else{
				_viewport.addEventListener(Event.ADDED_TO_STAGE, function( _e:Event ):void{
					_e.target.removeEventListener( 	 Event.ADDED_TO_STAGE, 		arguments.callee );
					_e.target.stage.addEventListener(KeyboardEvent.KEY_DOWN, 	onKeyDown);
					_e.target.stage.addEventListener(KeyboardEvent.KEY_UP, 		onKeyUp );
				});
			}
			_viewport.addEventListener(MouseEvent.MOUSE_MOVE, 	onMouseMoveEvent );
			
			m_viewport = _viewport;
			
			TickManager.registerObject( this );
		}
		
		public function updateWithTimeInfo(_timeInfo:TimeInfo):void{
			if( m_leftKey  )
			{
				moveLocalX( -1  );
			}
			if( m_rightKey )
			{
				moveLocalX( 1  );
			}
			if( m_downKey )
			{
				moveLocalZ( 1  );
			}
			if( m_upKey  )
			{
				moveLocalZ( -1  );
			}
		}
		
		
		public function moveLocalX( _value:Number ):void{
			transformation.moveAlongLocal( _value,0,0 );
		}
		public function moveLocalZ( _value:Number ):void{
			transformation.moveAlongLocal( 0,0,_value );
		}
		
		protected function onMouseMoveEvent(event:MouseEvent):void
		{
			var _offsetX:Number 	= m_mouseLastX - event.localX;
			var _offsetY:Number 	= m_mouseLastY - event.localY;
			
			if (event.buttonDown )
			{
				transformation.rotationY += _offsetX ;
				transformation.rotationX += _offsetY ;
			}
			
			m_mouseLastX 	= event.localX;
			m_mouseLastY 	= event.localY;
			
			
		}
		
		
		protected function onKeyDown(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case 65: // A key
					m_leftKey = true;
					break;
				case 68: // D Key
					m_rightKey = true;
					break;
				case 83: // S Key
					m_downKey = true;
					break;
				case 87: // W Key
					m_upKey = true;
					break;
				case 76: // L Key
					break;
				
				case 16: // SHIFT key
					if (!m_isShiftDown) {
						m_isShiftDown = true;
					}
					
					break;
				
				case 17: // CTRL key
					if (!m_isCtrlDown) {
						m_isCtrlDown = true;
					}
					break;	
				
			}
			
			
			
		}
		
		protected  function onKeyUp(event:KeyboardEvent):void
		{
			m_mouseLastX = m_viewport.mouseX;
			m_mouseLastY = m_viewport.mouseY;
			
			switch(event.keyCode)
			{
				case 65: // A key
					m_leftKey = false;
					break;
				case 68: // D Key
					m_rightKey = false;
					break;
				case 83: // S Key
					m_downKey = false;
					break;
				case 87: // W Key
					m_upKey = false;
					break;
				
				case 16: // SHIFT key
					m_isShiftDown = false;
					break;
				
				case 17: // CTRL Key
					m_isCtrlDown = false;
					break;	
				
			}
		}
	}
}