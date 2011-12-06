/*
 * LoadManager.as
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
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.io.cache.GlobalCache;
	import com.yogurt3d.io.cache.LoadCache;
	import com.yogurt3d.io.loaders.DataLoader;
	import com.yogurt3d.io.loaders.interfaces.ILoader;
	import com.yogurt3d.io.parsers.TextureMap_Parser;
	import com.yogurt3d.io.parsers.interfaces.IParser;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.Dictionary;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	[Event(name="allFilesComplete", type="com.yogurt3d.io.managers.loadmanagers.LoaderEvent")]
	[Event(name="fileComplete", type="com.yogurt3d.io.managers.loadmanagers.LoaderEvent")]
	[Event(name="loadProgress", type="com.yogurt3d.io.managers.loadmanagers.LoaderEvent")]
	public class LoadManager extends EventDispatcher 
	{
		YOGURT3D_INTERNAL var m_files					:Vector.<String>;
		YOGURT3D_INTERNAL var m_loaderTypes				:Vector.<Class>;
		YOGURT3D_INTERNAL var m_currentLoader			:ILoader;
		YOGURT3D_INTERNAL var m_loadedFileCount			:int;
		YOGURT3D_INTERNAL var m_localLoadCache			:LoadCache;
		YOGURT3D_INTERNAL var m_currentCache			:LoadCache;
		YOGURT3D_INTERNAL var m_useGlobalCache			:Boolean;
		YOGURT3D_INTERNAL var m_loaderInstanceByType	:Dictionary;
		YOGURT3D_INTERNAL var m_parserInstanceByType	:Dictionary;
		YOGURT3D_INTERNAL var m_parserTypeByFilePath	:Dictionary;
		YOGURT3D_INTERNAL var m_mipmapType				:Dictionary;
		YOGURT3D_INTERNAL var m_propsByFilePath			:Dictionary;
		
		use namespace YOGURT3D_INTERNAL;
		
		public function LoadManager()
		{
			init();
		}
		
		public function get loadsCompleted():int
		{
			return m_loadedFileCount;
		}
		
		public function get loadsTotal():int
		{
			return m_files.length;
		}
		
		public function get loadRatio():Number
		{
			return m_loadedFileCount / m_files.length;
		}
		
		public function get currentFileRatio():Number
		{
			return m_currentLoader.loadRatio;
		}
		
		/**
		 * If false this LoadManager will use an internal cache, otherwise use a global shared cache
		 * @default false
		 * @return 
		 * 
		 */
		public function get useGlobalCache():Boolean
		{
			return m_useGlobalCache;
		}
		
		/**
		 * @private 
		 * @param _value
		 * 
		 */
		public function set useGlobalCache(_value:Boolean):void
		{
			m_useGlobalCache	= _value;
			
			if(_value)
			{
				m_currentCache	= GlobalCache.cache;	
			} else {
				m_currentCache	= m_localLoadCache; 
			}
		}
		
		
		
		/**
		 * Adds a file to the load list. 
		 * @param _filePath Address of the file
		 * @param _loaderType LoaderClass (eg: DisplayObjectLoader, DataLoader)
		 * @param _parserType Parser to parse the input data (eg: Y3D_Parser, YOA_Parser)
		 * @param _props 
		 * 
		 * @see com.yogurt3d.io.loaders.DataLoader
		 * @see com.yogurt3d.io.loaders.DisplayObjectLoader
		 * @see com.yogurt3d.io.parsers.Y3D_Parser
		 * @see com.yogurt3d.io.parsers.YOA_Parser
		 */
		public function add(_filePath:String, _loaderType:Class, _parserType:Class = null, _props:Object = null, _mipmap:Boolean=false):void
		{
			if(!m_loaderInstanceByType[_loaderType])
			{
				var _loader:ILoader					= new _loaderType();
				m_loaderInstanceByType[_loaderType] = _loader;
				
				_loader.addEventListener(Event.COMPLETE, handleFileLoadComplete );
				_loader.addEventListener(ProgressEvent.PROGRESS, handleFileLoadProgress);
				_loader.addEventListener(IOErrorEvent.IO_ERROR, handleFileIOError);
			}
			
			if(_parserType)
			{
				if(!m_parserInstanceByType[_parserType])
				{
					var _parser:IParser					= new _parserType();
					if(_parser is TextureMap_Parser){
						(_parser as TextureMap_Parser).mipmap = _mipmap;
					}
					m_parserInstanceByType[_parserType] = _parser;
				}
				
				m_parserTypeByFilePath[_filePath]		= _parserType;
			}
			
			m_mipmapType[_filePath]  				= _mipmap;
			
			m_files[m_files.length]					= _filePath;
			m_loaderTypes[m_loaderTypes.length]		= _loaderType;
			m_propsByFilePath[_filePath]			= _props;
		}
		
		public function fileIsLoaded(_filePath:String):Boolean
		{
			return m_currentCache.isResourceAdded(_filePath);
		}
		
		public function getLoadedContent(_filePath:String):*
		{
			return m_currentCache.getResource(_filePath);
		}
		
		public function clearInternalCache():void
		{
			m_localLoadCache.dispose();
		}
		
		public function mergeInternalCacheWithGlobal():void
		{
			GlobalCache.mergeCacheWithGlobal(m_localLoadCache);
		}
		
		public function start():void
		{
			loadFileAtIndex(0);
		}
		
		public function close():void
		{
			m_currentLoader.close();
		}
		
		protected function handleFileLoadComplete(event:Event):void
		{
			var _loadedFilePath	:String	= m_files[m_loadedFileCount];
			var _parserType		:Class	= m_parserTypeByFilePath[_loadedFilePath];
			var _mipmap:Boolean = m_mipmapType[_loadedFilePath];
			
			if(_parserType)
			{
				var _parser	:IParser	= m_parserInstanceByType[_parserType];
				if(_parser is TextureMap_Parser){
					//(_parser as TextureMap_Parser).mipmap = _mipmap;
				//	trace(_loadedFilePath);
					TextureMap_Parser(_parser).mipmap = _mipmap;
					//trace("LOAD MANAGER ", _filePath, " - ", (_parser as TextureMap_Parser).mipmap);
				}
				m_currentCache.addResource(_loadedFilePath, _parser.parse(m_currentLoader.loadedContent));
			} else {
				m_currentCache.addResource(_loadedFilePath, m_currentLoader.loadedContent);
			}
			
			m_loadedFileCount++;
			var _event:LoaderEvent;
			
			if(m_loadedFileCount != m_files.length)
			{
				loadFileAtIndex(m_loadedFileCount);
				
				_event = new LoaderEvent(LoaderEvent.FILE_COMPLETE);
				dispatchEvent(_event);
			} else {
				
				_event = new LoaderEvent(LoaderEvent.FILE_COMPLETE);
				dispatchEvent(_event);
				
				_event = new LoaderEvent(LoaderEvent.ALL_COMPLETE);
				dispatchEvent(_event);
			}
		}
		protected function handleFileIOError( event:IOErrorEvent):void
		{
			throw new Error(event.toString());
		}
		protected function handleFileLoadProgress( event:ProgressEvent):void
		{
			var _event : LoaderEvent;
			_event = new LoaderEvent(LoaderEvent.LOAD_PROGRESS);
			_event.bytesLoaded 	= event.bytesLoaded;
			_event.bytesTotal 	= event.bytesTotal;
			_event.loader		= m_currentLoader;
			dispatchEvent(_event);
		}
		
		private function loadFileAtIndex(_index:int):void
		{
			m_currentLoader			= m_loaderInstanceByType[m_loaderTypes[_index]];
			
			var _file		:String	= m_files[_index];
			var _props		:Object	= m_propsByFilePath[_file];
			
			if(_props)
			{
				m_currentLoader.applyProps(_props);
			}
			
			m_currentLoader.load(m_files[_index]);
		}
		
		private function init():void
		{
			m_files					= new Vector.<String>();
			m_loaderTypes			= new Vector.<Class>();
			m_currentLoader			= new DataLoader();
			m_loadedFileCount		= 0;
			m_localLoadCache		= new LoadCache();
			m_loaderInstanceByType	= new Dictionary();
			m_parserInstanceByType	= new Dictionary();
			m_parserTypeByFilePath	= new Dictionary();
			m_propsByFilePath		= new Dictionary();
			m_mipmapType			= new Dictionary();
			
			m_currentCache			= m_localLoadCache;
		}
	}
}
