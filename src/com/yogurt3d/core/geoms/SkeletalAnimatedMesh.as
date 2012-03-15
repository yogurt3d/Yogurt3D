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
	import com.yogurt3d.core.managers.idmanager.IDManager;
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
			return m_base.axisAlignedBoundingBox;
		}
		
		public function get boundingSphere():BoundingSphere
		{
			return m_base.boundingSphere;
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
		override protected function trackObject():void
		{
			IDManager.trackObject(this, SkeletalAnimatedMesh);
		}
		public override function dispose():void
		{
			m_base = null;
			controller.dispose();
			controller = null;
			super.dispose();
		}
		public override function disposeGPU():void{
			m_base.disposeGPU();
		}
		public override function disposeDeep():void
		{
			m_base.disposeDeep();
			m_base = null;
			controller.dispose();
			controller = null;
			dispose();
		}
		
		protected override function initInternals():void
		{
			super.initInternals();
			
			reinitBones();
		}
		
		public function reinitBones():void{
			m_bones = new Vector.<Bone>(m_base.bones.length,true);
			
			var len:int = m_base.bones.length;
			var bone1:Bone;
			var bone2:Bone;
			// clone bones from mesh
			for( var i:int = 0; i < len; i++)
			{
				m_bones[i] =  m_base.bones[i].clone();
			}
			// reinit the hierarchy for the bones
			for( i = 0; i < len; i++)
			{
				bone1 = bones[i];
				for( var j:int = 0; j < len; j++)
				{
					bone2 = bones[j];
					if( bone1.parentName == bone2.name )
					{
						bone1.parentBone = bone2;
						bone2.children.push( bone1 );
					}
				}
			}
		}
		
	}
}
