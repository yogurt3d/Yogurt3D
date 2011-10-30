/*
 * ILoader.as
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
 *  License along with this library. If not, see <http://www.yogurt3d.com/yogurt3d/downloads/yogurt3d-click-through-agreement.html>. 
 */
 
 
package com.yogurt3d.io.loaders.interfaces {
	import flash.events.IEventDispatcher;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public interface ILoader extends IEventDispatcher  
	{
		function get loadedContent():*;
		
		function get loadPath():String;
		
		function get bytesLoaded():int;
		function get bytesTotal():int;
		function get loadRatio():Number;
		
		function get isLoadComplete():Boolean;
		
		function load(_filePath:String):void;
		function close():void;
		function applyProps(_props:Object):void;
	}
}
