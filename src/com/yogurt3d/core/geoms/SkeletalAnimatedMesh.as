/*
 * SkeletalAnimatedMesh.as
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
 
 
 
package com.yogurt3d.core.geoms
{
	import com.yogurt3d.core.animation.IControllable;
	import com.yogurt3d.core.animation.controllers.IController;
	import com.yogurt3d.core.animation.controllers.SkinController;
	import com.yogurt3d.core.geoms.interfaces.IMesh;
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.helpers.boundingvolumes.BoundingSphere;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	use namespace YOGURT3D_INTERNAL;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class SkeletalAnimatedMesh extends EngineObject implements IMesh, IControllable
	{
		private var m_bones						: Vector.<Bone>;
		private var m_base:SkeletalAnimatedMeshBase;
		
		private var m_subMeshList:Vector.<SubMesh>;
		
		YOGURT3D_INTERNAL var m_aabb:AxisAlignedBoundingBox;
		YOGURT3D_INTERNAL var m_boundingSphere:BoundingSphere;
		
		YOGURT3D_INTERNAL var m_controller:IController;
		
		public function SkeletalAnimatedMesh(base:SkeletalAnimatedMeshBase)
		{
			m_base = base;
			m_subMeshList = m_base.subMeshList;
			super( true );
		}
		
		
		public function get controller():IController{
			if( m_controller == null )
			{
				m_controller = new SkinController( this ); 
			}
			return m_controller;
		}
		
		public function set controller( _value:IController ):void{
			m_controller = _value;
		}
		
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

		
		public function updateBoundingVolumes():void{
			var _min :Vector3D = new Vector3D(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
			var _max :Vector3D = new Vector3D(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
			var resolatedMax:Vector3D;
			var resolatedMin:Vector3D;
			var len:uint = m_subMeshList.length;
			if( len == 1 )
			{
				m_subMeshList[0].axisAlignedBoundingBox.update(new Matrix3D());
				m_aabb =m_subMeshList[0].axisAlignedBoundingBox.clone() as AxisAlignedBoundingBox;
				_min = m_subMeshList[0].axisAlignedBoundingBox.min;
				_max = m_subMeshList[0].axisAlignedBoundingBox.max;
			}else{
				for(var i:int; i < len; i++)
				{
					m_subMeshList[i].axisAlignedBoundingBox.update(new Matrix3D());
					
					resolatedMax = m_subMeshList[i].axisAlignedBoundingBox.max;
					resolatedMin = m_subMeshList[i].axisAlignedBoundingBox.min;
					if(resolatedMax.x > _max.x) _max.x = resolatedMax.x;
					if(resolatedMin.x < _min.x) _min.x = resolatedMin.x;
					if(resolatedMax.y > _max.y) _max.y = resolatedMax.y;
					if(resolatedMin.y < _min.y) _min.y = resolatedMin.y;
					if(resolatedMax.z > _max.z) _max.z = resolatedMax.z;
					if(resolatedMin.z < _min.z) _min.z = resolatedMin.z;
				}
				m_aabb = new AxisAlignedBoundingBox(_min, _max);
			}
			
			
			var temp:Vector3D = _max.subtract(_min);
			var _radiusSqr :Number = temp.x*temp.x + temp.y*temp.y + temp.z*temp.z;
			var _center :Vector3D = _max.add( _min);
			_center.scaleBy( .5 );
			m_boundingSphere = new BoundingSphere( _radiusSqr, _center );
		}
		
		public function get base():SkeletalAnimatedMeshBase
		{
			return m_base;
		}
		public function get subMeshList():Vector.<SubMesh>
		{
			return m_subMeshList;
		}

		public function get type():String{
			return "SkeletalAnimatedGPUMesh_" + m_bones.length;
		}
		
		public function get bones():Vector.<Bone>
		{
			return m_bones;
		}

		public function set bones(value:Vector.<Bone>):void
		{
			m_bones = value;
		}

		
		
		public function get triangleCount():int
		{
			return m_base.triangleCount;
		}
		
		public override function instance():*
		{			
			return new SkeletalAnimatedMesh(m_base);
		}
		
		public override function clone():IEngineObject
		{
			return null;
		}
		
		public override function dispose():void
		{
			super.dispose();
			m_base = null;
			controller.dispose();
			controller = null;
		}
		
		protected override function initInternals():void
		{
			super.initInternals();
			
			reinitBones();
		}
		
		public function reinitBones():void{
			m_bones = new Vector.<Bone>();
			
			var len:int = m_base.bones.length;
			
			// clone bones from mesh
			for( var i:int = 0; i < len; i++)
			{
				m_bones.push( m_base.bones[i].clone() );
			}
			// reinit the hierarchy for the bones
			for( i = 0; i < bones.length; i++)
			{
				for( var j:int = 0; j < bones.length; j++)
				{
					if( bones[i].parentName == bones[j].name )
					{
						bones[i].parentBone = bones[j];
						bones[j].children.push( bones[i] );
					}
				}
			}
		}
	}
}
