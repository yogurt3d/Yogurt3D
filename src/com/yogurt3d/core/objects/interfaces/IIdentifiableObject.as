/*
 * IIdentifiableObject.as
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
	 * <strong>IIdentifiableObject</strong> Interface
	 * provides properties to identify objects.
 	 * 
  	 * @author Yogurt3D Engine Core Team
  	 * @company Yogurt3D Corp.
  	 **/
	public interface IIdentifiableObject
	{
		/**
		 * Automatically assigned id. Every object that implements this interface
		 * will have this value assigned to it.
		 * 
		 * @see com.yogurt3d.core.sceneobjects.SceneObjectContainer#removeChildBySystemID()  
		 * @see com.yogurt3d.core.sceneobjects.SceneObjectContainer#getChildBySystemID()  
		 * @see com.yogurt3d.core.managers.contextmanager.ContextManager#removeContextBySystemID()  
		 */
		function get systemID():String;
		
		/**
		 * Identification string can be assigned by developer to identify objects.
		 * 
		 * @see com.yogurt3d.core.sceneobjects.SceneObjectContainer#removeChildByUserID()
		 * @see com.yogurt3d.core.sceneobjects.SceneObjectContainer#getChildByUserID()
		 * @see com.yogurt3d.core.managers.contextmanager.ContextManager#removeContextByUserID()
		 */
		function get userID():String;
		
		/**
		 * @private
		 */
		function set userID(_value:String):void;
	}
}
