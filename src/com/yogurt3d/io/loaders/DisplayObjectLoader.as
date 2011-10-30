/*
 * DisplayObjectLoader.as
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
package com.yogurt3d.io.loaders {
	import com.yogurt3d.io.loaders.interfaces.ILoader;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;

	public class DisplayObjectLoader extends EventDispatcher implements ILoader 
	{
		private var m_loader			:Loader;
		private var m_urlRequest		:URLRequest;
		
		public function DisplayObjectLoader()
		{
			init();
		}
		
		public function get loadedContent():*
		{
			return m_loader.content;
		}
		
		public function get bytesLoaded():int
		{
			return m_loader.contentLoaderInfo.bytesLoaded;
		}
		
		public function get bytesTotal():int
		{
			return m_loader.contentLoaderInfo.bytesTotal;
		}
		
		public function get loadRatio():Number
		{
			return m_loader.contentLoaderInfo.bytesLoaded / m_loader.contentLoaderInfo.bytesTotal;
		}
		
		public function get isLoadComplete():Boolean
		{
			return m_loader.contentLoaderInfo.bytesLoaded == m_loader.contentLoaderInfo.bytesTotal;
		}
		
		public function load(_filePath:String):void
		{
			m_urlRequest.url	= _filePath;
			
			m_loader.load(m_urlRequest);
		}
		
		public function get loadPath():String{
			return m_urlRequest.url;
		}
		
		public function close():void
		{
			m_loader.close();
		}
		
		public function applyProps(_props:Object):void
		{
			for (var prop:* in _props)
			{
				this[prop] = _props[prop];
			}
		}
		
		protected function handleLoaderLoadComplete(event:Event):void
		{
			dispatchEvent(event);
		}
		
		protected function handleLoaderLoadProgress(event:ProgressEvent):void
		{
			dispatchEvent(event);
		}
		
		private function init():void
		{
			m_loader			= new Loader();
			m_urlRequest		= new URLRequest();
			
			m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoaderLoadComplete);
			m_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, handleLoaderLoadProgress);
		}
	}
}