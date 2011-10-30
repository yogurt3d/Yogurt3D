/*
 * INotifierObject.as
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
 
 
package com.yogurt3d.core.objects.interfaces
{
	/**
	 * <strong>INotifierObject</strong> Interface defines methods
	 * to add event based relationships between objects. 
 	 * 
  	 * @author Yogurt3D Engine Core Team
  	 * @company Yogurt3D Corp.
  	 **/
	public interface INotifierObject
	{
		/**
		 * Attaches an observer object that will recieve event updates.
		 * 
		 * @param _message Message (Event Name) that observer
		 * objects will be notified.
		 * 
		 * @param _observer Observer object that will be notified.
		 * 
		 * @param _observerCallBack Observers' listener function.
		 * 
		 * @see com.yogurt3d.core.managers.notificationmanager.NotificationManager
		 */
		function attachObserver(_message:String, _observer:Object, _observerCallBack:Function):void;
		
		/**
		 * Removes attached observer of given message's notifications
		 * 
		 * @see com.yogurt3d.core.managers.notificationmanager.NotificationManager
		 */
		function detachObserver(_message:String, _observer:Object, _observerCallBack:Function):void;
	}
}
