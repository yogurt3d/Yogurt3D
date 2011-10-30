/*
* DataLoader.as
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
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.io.loaders.interfaces.ILoader;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import nochump.util.zip.ZipFile;
	
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class ZipFileLoader extends EventDispatcher implements ILoader
	{
		YOGURT3D_INTERNAL var m_urlLoader		:URLLoader;
		YOGURT3D_INTERNAL var m_urlRequest		:URLRequest;
		
		YOGURT3D_INTERNAL var m_zipFile			:ZipFile;
		
		use namespace YOGURT3D_INTERNAL;
		
		public function ZipFileLoader()
		{
			init();
		}
		
		public function get loadedContent():*
		{
			return m_zipFile;
		}
		
		public function get bytesLoaded():int
		{
			return m_urlLoader.bytesLoaded;
		}
		
		public function get bytesTotal():int
		{
			return m_urlLoader.bytesTotal;
		}
		
		public function get loadRatio():Number
		{
			return m_urlLoader.bytesLoaded / m_urlLoader.bytesTotal;
		}
		
		public function get isLoadComplete():Boolean
		{
			return m_urlLoader.bytesLoaded == m_urlLoader.bytesTotal;
		}
		
		public function get dataFormat():String
		{
			return m_urlLoader.dataFormat;
		}
		
		public function set dataFormat(_value:String):void
		{
			m_urlLoader.dataFormat = _value;
		}
		
		public function load(_filePath:String):void
		{
			m_urlRequest.url = _filePath;
			
			m_urlLoader.load(m_urlRequest);
		}
		
		public function get loadPath():String{
			return m_urlRequest.url;
		}
		
		public function close():void
		{
			m_urlLoader.close();
		}
		
		public function applyProps(_props:Object):void
		{
			for (var prop:* in _props)
			{
				this[prop] = _props[prop];
			}
		}
		
		protected function handleURLLoaderLoadComplete(event:Event):void
		{
			m_zipFile = new CompressedFile(m_urlLoader.data);
			dispatchEvent(event);
		}
		
		protected function handleURLLoaderLoadProgress(event:ProgressEvent):void
		{
			dispatchEvent(event);
		}
		protected function handleURLLoaderIOErrorEvent(event:IOErrorEvent):void
		{
			dispatchEvent(event);
		}
		
		private function init():void
		{
			m_urlRequest		= new URLRequest();
			m_urlLoader			= new URLLoader();
			
			m_urlLoader.addEventListener(Event.COMPLETE, handleURLLoaderLoadComplete);
			m_urlLoader.addEventListener(ProgressEvent.PROGRESS, handleURLLoaderLoadProgress);
			m_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleURLLoaderIOErrorEvent);
		}
		
	}
}
