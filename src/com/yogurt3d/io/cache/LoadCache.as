/*
 * LoadCache.as
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
	public class LoadCache
	{
		YOGURT3D_INTERNAL var m_resources		:Dictionary;
		YOGURT3D_INTERNAL var m_ids				:Array;
		
		use namespace YOGURT3D_INTERNAL;
		
		public function LoadCache()
		{
			init();
		}
		
		public function addResource(_id:*, _resource:*):void
		{
			var _idIndex	:int	= m_ids.indexOf(_id);
			
			if(_idIndex)
			{
				m_ids[m_ids.length] = _id;
			}
			
			m_resources[_id]		= _resource;
		}
		
		public function removeResource(_id:*):void
		{
			var _idIndex	:int	= m_ids.indexOf(_id);
			
			if(_idIndex != -1)
			{
				m_ids.splice(_idIndex, 1);
			}
			
			m_resources[_id]		= null;
		}
		
		public function getResource(_id:*):*
		{
			return m_resources[_id];
		}
		
		public function isResourceAdded(_id:*):Boolean
		{
			return m_resources[_id] != null;
		}
		
		public function dispose():void
		{
			m_resources	= new Dictionary();
		}
		
		private function init():void
		{
			m_resources	= new Dictionary();
			m_ids		= [];
		}
	}
}
