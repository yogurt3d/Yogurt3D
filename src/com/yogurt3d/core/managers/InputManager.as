package com.yogurt3d.core.managers
{
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.natives.NativeSignal;

	public class InputManager
	{
		private static var m_keyDown:NativeSignal;
		private static var m_keyUp:NativeSignal;
		
		private static var m_keyDict:Dictionary 			= new Dictionary();
		private static var m_keyJustDict:Dictionary 		= new Dictionary();
		
		YOGURT3D_INTERNAL static function setStage( stage:Stage ):void{
			if( m_keyDown != null )
			{
				m_keyDown.removeAll();
				m_keyDown = null;
			}
			if(  m_keyUp != null )
			{
				m_keyUp.removeAll();
				m_keyUp = null;
			}
			m_keyDown = new NativeSignal(stage, KeyboardEvent.KEY_DOWN, KeyboardEvent);
			m_keyUp = new NativeSignal(stage, KeyboardEvent.KEY_UP, KeyboardEvent);
			m_keyDown.add( onKeyDown );
			m_keyUp.add( onKeyUp);
			Yogurt3D.instance.onFrameEnd.addWithPriority(onFrameEnd, int.MAX_VALUE);
		}
		
		public static function isKeyDown( value:uint ):Boolean{
			return m_keyDict[value] != null;
		}
		public static function isKeyJustDown( value:uint ):Boolean{
			return m_keyJustDict[value] != null;
		}
		
		private static function onKeyDown( event:KeyboardEvent ):void{
			m_keyDict[ event.keyCode ] = true;
			m_keyJustDict[ event.keyCode ] = true;
			if( event.ctrlKey ){
				m_keyDict[ Keyboard.CONTROL] = true;
			}
			if( event.altKey ){
				m_keyDict[ Keyboard.ALTERNATE] = true;
			}
			if( event.shiftKey ){
				m_keyDict[ Keyboard.SHIFT] = true;
			}
		}
		private static function onFrameEnd( ):void{
			for( var key:Object in m_keyJustDict){
				delete m_keyJustDict[key];
			}
		}
		private static function onKeyUp( event:KeyboardEvent ):void{
			delete m_keyDict[ event.keyCode ];
			if( !event.ctrlKey ){
				delete m_keyDict[ Keyboard.CONTROL];
			}
			if( !event.shiftKey ){
				delete m_keyDict[ Keyboard.SHIFT];
			}
			if( !event.altKey ){
				m_keyDict[ Keyboard.ALTERNATE];
			}
		}
	}
}