/*
 * GlobalCache.as
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
  
 
package com.yogurt3d.io.cache
{
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	
	import flash.utils.Dictionary;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class GlobalCache
	{
		private static var s_cache			:LoadCache;
		
		public static function get cache():LoadCache
		{
			if(!s_cache)
			{
				s_cache	= new LoadCache();	
			}
			
			return s_cache;
		}
		
		public static function mergeCacheWithGlobal(_cache:LoadCache):void
		{
			var _s_CacheResources	:Dictionary			= s_cache.YOGURT3D_INTERNAL::m_resources;
			var	_s_CacheIDs			:Array				= s_cache.YOGURT3D_INTERNAL::m_ids;
			
			var _cacheIDs			:Array				= _cache.YOGURT3D_INTERNAL::m_ids;
			var _cacheIDCount		:int				= _cacheIDs.length;
			
			for(var i:int = 0; i < _cacheIDCount; i++)
			{
				var _cacheID		:*					= _cacheIDs[i];
				var _resource		:*					= _cache.getResource(_cacheID);
				
				if(_resource)
				{
					_s_CacheResources[_cacheID]			= _resource;
					
					if(_s_CacheIDs.indexOf(_cacheID) == -1)
					{
						_s_CacheIDs[_s_CacheIDs.length]	= _cacheID;
					}
				}
			}
		}
	}
}
