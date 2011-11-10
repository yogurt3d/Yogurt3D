/*
 * TickManager.as
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
 
package com.yogurt3d.core.managers.tickmanager {
	import com.yogurt3d.core.objects.interfaces.ITickedObject;
	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.osflash.signals.PrioritySignal;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class TickManager
	{
		private static var s_init				:Boolean						= staticInitializer();
		private static var s_timeScale			:Number;
		public  static var LATEST_SYSTEM_TIME	:uint;
		private static var s_tickedObjectsCount	:uint;
		private static var s_tickedObjects		:Vector.<ITickedObject>;
		private static var s_timeInfosByObject	:Dictionary;
		private static var s_startTimesByObject	:Dictionary;
		
		private static var m_signal				: PrioritySignal;
		
		public static function get timeScale():Number
		{
			return s_timeScale;
		}
		
		public static function set timeScale(value:Number):void
		{
			s_timeScale = value;
		}
		
		public static function registerObject(_value:ITickedObject, _priority:int = 0):void
		{
			
			if(s_tickedObjects.indexOf(_value) == -1)
			{
				s_tickedObjects[s_tickedObjectsCount]	= _value;
				s_timeInfosByObject[_value]				= new TimeInfo();
				
				/*s_tickedObjects = s_tickedObjects.sort( function( _a:*, _b:* ):Number{
					if(_a.priority < _b.priority )
					{return 1;}
					else if( _a.priority > _b.priority )
					{return -1;}
					else{return 0;}
				});*/
				
				s_tickedObjectsCount++;
			}
		}
		
		public static function unRegisterObject(_value:ITickedObject):void
		{
			var _objectIndex	:int		= s_tickedObjects.indexOf(_value);
			
			if(_objectIndex != -1)
			{
				s_timeInfosByObject[_value]	= null;
				s_startTimesByObject[_value] = null;
				s_tickedObjects.splice(_objectIndex, 1);
				s_tickedObjectsCount--;
			}
		}
		
		public static function update():void
		{
			var _systemTime				:int				= getTimer();
			var _currentDelta			:Number				= _systemTime - LATEST_SYSTEM_TIME;
			
			LATEST_SYSTEM_TIME								= _systemTime;
			
			for(var i:int = 0; i < s_tickedObjectsCount; i++)
			{
				var _object				:ITickedObject		= s_tickedObjects[i];
				var _timeInfo			:TimeInfo			= s_timeInfosByObject[_object];
				var _objectStartTime	:Number				= s_startTimesByObject[_object];
				
				if(!_objectStartTime)
				{
					_objectStartTime						= _systemTime;
					s_startTimesByObject[_object]			= _objectStartTime;
				} 
				
				_timeInfo.deltaTime							= _currentDelta;
				_timeInfo.systemTime						= _systemTime;
				_timeInfo.objectTime						= (_systemTime - _objectStartTime) * s_timeScale;
				
				_object.updateWithTimeInfo(_timeInfo);
			}
		}
		
		private static function staticInitializer():Boolean
		{
			s_timeScale				= 1;
			LATEST_SYSTEM_TIME		= getTimer();
			s_tickedObjectsCount	= 0;
			s_timeInfosByObject		= new Dictionary();
			s_startTimesByObject	= new Dictionary();
			s_tickedObjects			= new Vector.<ITickedObject>();
			
			return true;
		}
	}
}
