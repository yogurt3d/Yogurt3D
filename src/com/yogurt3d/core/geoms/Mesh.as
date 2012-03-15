/*
* Mesh.as
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

package com.yogurt3d.core.geoms {
	import com.yogurt3d.core.geoms.interfaces.IMesh;
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.helpers.boundingvolumes.BoundingSphere;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	
	import flash.geom.Vector3D;
	
	use namespace YOGURT3D_INTERNAL;
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class Mesh extends EngineObject implements IMesh
	{
		private var m_subMeshList		:Vector.<SubMesh>;	
		
		YOGURT3D_INTERNAL var m_aabb:AxisAlignedBoundingBox;
		YOGURT3D_INTERNAL var m_boundingSphere:BoundingSphere;
		
		
		public function get axisAlignedBoundingBox():AxisAlignedBoundingBox
		{
			if(m_aabb == null)
			{
				updateBoundingVolumes();
			}
			return m_aabb;
		}
		
		public function get boundingSphere():BoundingSphere
		{
			if(m_boundingSphere == null)
			{
				updateBoundingVolumes();
			}
			return m_boundingSphere;
		}
		
		public function get subMeshList():Vector.<SubMesh>
		{
			return m_subMeshList;
		}
		
		public function set subMeshList(_value:Vector.<SubMesh>):void
		{
			m_subMeshList = _value;
		}
		
		public function get type():String{
			return "Mesh";
		}
		
		public function Mesh(_initInternals:Boolean = true)
		{
			super(_initInternals);
		}
		
		public function get triangleCount():int{
			var total:uint = 0;
			for( var i:int = 0; i < m_subMeshList.length; i++)
			{
				total += m_subMeshList[i].triangleCount;
			}
			return total;
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, Mesh);
		}
		
		override protected function initInternals():void {
			m_subMeshList = new Vector.<SubMesh>;
			super.initInternals();
		}
		
		
		public function updateBoundingVolumes():void{
			var _min :Vector3D = new Vector3D(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
			var _max :Vector3D = new Vector3D(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
			var resolatedMax:Vector3D;
			var resolatedMin:Vector3D;
			var len:uint = m_subMeshList.length;
			if( len == 1 )
			{
				_min = m_subMeshList[0].axisAlignedBoundingBox.minGlobal;
				_max = m_subMeshList[0].axisAlignedBoundingBox.maxGlobal;
			}else{
				for(var i:int; i < len; i++)
				{
					resolatedMax = m_subMeshList[i].axisAlignedBoundingBox.maxGlobal;
					resolatedMin = m_subMeshList[i].axisAlignedBoundingBox.minGlobal;
					if(resolatedMax.x > _max.x) _max.x = resolatedMax.x;
					if(resolatedMin.x < _min.x) _min.x = resolatedMin.x;
					if(resolatedMax.y > _max.y) _max.y = resolatedMax.y;
					if(resolatedMin.y < _min.y) _min.y = resolatedMin.y;
					if(resolatedMax.z > _max.z) _max.z = resolatedMax.z;
					if(resolatedMin.z < _min.z) _min.z = resolatedMin.z;
				}
			}
			if( m_aabb )
			{
				m_aabb.disposeDeep();
			}
			m_aabb = new AxisAlignedBoundingBox(_min, _max);
			
			var temp:Vector3D = _max.subtract(_min);
			var _radiusSqr :Number = temp.x*temp.x + temp.y*temp.y + temp.z*temp.z;
			var _center :Vector3D = _max.add( _min);
			_center.scaleBy( .5 );
			if( m_boundingSphere )
			{
				m_boundingSphere.dispose();
			}
			m_boundingSphere = new BoundingSphere( _radiusSqr, _center );
		}
		
		public override function dispose():void{
			for( var i:int = 0; i < subMeshList.length; i++ )
			{
				subMeshList[i].dispose();
			}
			subMeshList.length = 0;
			
			if( m_aabb )
			{
				m_aabb.disposeDeep();
				m_aabb = null;
			}
			if( m_boundingSphere )
			{
				m_boundingSphere.dispose();
				m_boundingSphere = null;
			}
			
			super.dispose();
		}
		
		public override function disposeDeep():void{
			for( var i:int = 0; i < subMeshList.length; i++ )
			{
				subMeshList[i].disposeDeep();
			}
			dispose();
		}
		
		public override function disposeGPU():void{
			for( var i:int = 0; i < subMeshList.length; i++ )
			{
				subMeshList[i].disposeGPU();
			}
		}
		
		public override function instance():*{
			return this;
		}
	}
}
