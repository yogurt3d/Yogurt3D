/*
 * LoaderEvent.as
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
 
 
package com.yogurt3d.io.managers.loadmanagers {
	import com.yogurt3d.io.loaders.interfaces.ILoader;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class LoaderEvent extends ProgressEvent 
	{
		public static const ALL_COMPLETE	:String 	= "allFilesComplete";
		public static const FILE_COMPLETE	:String 	= "fileComplete";
		public static const LOAD_PROGRESS	:String 	= "loadProgress";
		
		public var loader:ILoader;
		
		public function LoaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new LoaderEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("LoaderEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}
