/*
 * IDManager.as
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
 
 
package com.yogurt3d.core.managers.idmanager
{
	import com.yogurt3d.core.objects.interfaces.IIdentifiableObject;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class IDManager
	{
		private static var init					:Boolean		= initialize();
		
		private static var s_objectBySystemID	:Dictionary;
		private static var s_systemIDByObject	:Dictionary;
		private static var s_userIDBySystemID	:Dictionary;
		private static var s_systemIDByUserID	:Dictionary;
		private static var s_indexesByType		:Dictionary;
		private static var s_classNamesByType	:Dictionary;
		
		/**
		 * Registers an <code>IIdentifiableObject</code> object to the <code>IDManager</code>.
		 * @param _object Object to be registered
		 * @param _indexType 
		 * 
		 */
		public static function trackObject(_object:IIdentifiableObject, _indexType:Class):void
		{
			var _systemID	:String 		= getUniqueSystemID(_indexType);
			
			s_objectBySystemID[_systemID]	= _object;
			s_systemIDByObject[_object]		= _systemID;
		}
		
		public static function listObjectsByType(_indexType:Class):Array{
			var list:Array = [];
			var id:String;
			if( _indexType != null )
				for each( id in s_objectBySystemID )
				{
					if( s_objectBySystemID[id] is _indexType )
					{
						list.push( s_objectBySystemID[id] );
					}
				}
			else
				for( id in s_objectBySystemID )
				{
					list.push( s_objectBySystemID[id] );
				}
			list.sortOn("systemID");
			return list;
		}
		
		/**
		 * 
		 * @param _userID
		 * @param _systemID
		 * 
		 */
		public static function setUserIDBySystemID(_userID:String, _systemID:String):void
		{
			delete s_systemIDByUserID[s_userIDBySystemID[_systemID]];
			
			s_userIDBySystemID[_systemID]	= _userID;
			s_systemIDByUserID[_userID]		= _systemID;
		}
		
		/**
		 * 
		 * @param _userID
		 * @param _object
		 * 
		 */
		public static function setUserIDByObject(_userID:String, _object:IIdentifiableObject):void
		{
			delete s_systemIDByUserID[s_userIDBySystemID[s_systemIDByObject[_object]]];
			
			s_userIDBySystemID[s_systemIDByObject[_object]]	= _userID;
			s_systemIDByUserID[_userID]						= s_systemIDByObject[_object];
		}
		
		/**
		 * 
		 * @param _value
		 * @return 
		 * 
		 */
		public static function getSystemIDByUserID(_value:String):String
		{
			return s_systemIDByUserID[_value];
		}
		
		/**
		 * 
		 * @param _value
		 * @return 
		 * 
		 */
		public static function getSystemIDByObject(_value:IIdentifiableObject):String
		{
			return s_systemIDByObject[_value];
		}
		
		/**
		 * 
		 * @param _value
		 * @return 
		 * 
		 */
		public static function getUserIDBySystemID(_value:String):String
		{
			return s_userIDBySystemID[_value];
		}
		
		/**
		 * 
		 * @param _value
		 * @return 
		 * 
		 */
		public static function getUserIDByObject(_value:IIdentifiableObject):String
		{
			return s_userIDBySystemID[s_systemIDByObject[_value]];
		}
		
		/**
		 * 
		 * @param _value
		 * @return 
		 * 
		 */
		public static function getObjectBySystemID(_value:String):IIdentifiableObject
		{
			return s_objectBySystemID[_value];
		}
		
		/**
		 * 
		 * @param _value
		 * @return 
		 * 
		 */
		public static function getObjectByUserID(_value:String):IIdentifiableObject
		{
			return s_objectBySystemID[s_systemIDByUserID[_value]];
		}
		
		/**
		 * 
		 * @param _value
		 * 
		 */
		public static function removeObject(_value:IIdentifiableObject):void
		{
			if( s_systemIDByObject[_value] == null ) return;
			
			var _systemID		:String		= s_systemIDByObject[_value];
			var _userID			:String		= s_userIDBySystemID[_systemID];
			
			s_objectBySystemID[_systemID]	= null;
			s_systemIDByObject[_value]		= null;
			s_userIDBySystemID[_systemID]	= null;
			s_systemIDByUserID[_userID]		= null;
			
			delete s_objectBySystemID[_systemID];
			delete s_systemIDByObject[_value];
			delete s_userIDBySystemID[_systemID];
			delete s_systemIDByUserID[_userID];
		}
		
		/**
		 * 
		 * @param _indexType
		 * @return 
		 * 
		 */
		private static function getUniqueSystemID(_indexType:Class):String
		{
			if(s_indexesByType[_indexType] == undefined)
			{
				s_indexesByType[_indexType] = 0;
			} else {
				s_indexesByType[_indexType]++;
			}
			
			if(!s_classNamesByType[_indexType])
			{
				s_classNamesByType[_indexType] = getQualifiedClassName(_indexType).split("::")[1].toLowerCase();
			}
			
			return s_classNamesByType[_indexType] + "_" + s_indexesByType[_indexType].toString();
		}
		
		/**
		 * @private 
		 * @return 
		 * 
		 */
		private static function initialize():Boolean
		{
			s_objectBySystemID	= new Dictionary();
			s_systemIDByObject	= new Dictionary();
			s_userIDBySystemID	= new Dictionary();
			s_systemIDByUserID	= new Dictionary();
			s_indexesByType		= new Dictionary();
			s_classNamesByType	= new Dictionary();
			
			return true;
		}
		
		public function IDManager()
		{
			throw new Error( "This class is a static object" );
		}
	}
}
