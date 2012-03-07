/*
 * EngineObject.as
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
 
 
package com.yogurt3d.core.objects {
	import avmplus.getQualifiedClassName;
	
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	
	import flash.events.EventDispatcher;

	/**
	 * <strong>IEngineObject</strong> interface abstract type.
  	 * @author Yogurt3D Engine Core Team
  	 * @company Yogurt3D Corp.
  	 **/
	public class EngineObject implements IEngineObject
	{
		/**
		 * 
		 * @param _initInternals
		 * 
		 */
		public function EngineObject(_initInternals:Boolean = true)
		{
			trackObject();
			
			if(_initInternals)
			{
				initInternals();
			}
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get systemID():String
		{
			return IDManager.getSystemIDByObject(this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get userID():String
		{
			return IDManager.getUserIDByObject(this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function set userID(_value:String):void
		{
			IDManager.setUserIDByObject(_value, this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function toString():String
		{
			return "{systemId:"+IDManager.getSystemIDByObject(this)+", userId:"+IDManager.getUserIDByObject(this)+"}";
		}
		
		/**
		 * @inheritDoc
		 * */
		public function renew():void
		{
		}
		
		/**
		 * @inheritDoc
		 * */
		public function clone():IEngineObject
		{
			return null;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function instance():*
		{
			return this;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function dispose():void
		{
			IDManager.removeObject(this);
		}
		
		public function disposeDeep():void
		{
			dispose();
			
			Y3DCONFIG::DEBUG
			{
				Y3DCONFIG::TRACE
				{
					trace("This class has not implemented a disposeDeep function", getQualifiedClassName(this) );
				}
			}
			
		}
		
		public function disposeGPU():void
		{
			Y3DCONFIG::DEBUG
			{
				Y3DCONFIG::TRACE
				{
					trace("This class has not implemented a disposeGPU function", getQualifiedClassName(this) );
				}
			}
			
		}
		/**
		 * Starts the tracking of the object 
		 * @see com.yogurt3d.core.managers.idmanager.IDManager
		 */		
		protected function trackObject():void
		{
			IDManager.trackObject(this, EngineObject);
		}
		
		protected function initInternals():void
		{
			
		}
		
	}
}
