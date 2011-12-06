/*
 * SkeletalAnimatedMeshBase.as
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
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.animation.SkeletalAnimationData;
	import com.yogurt3d.core.geoms.interfaces.IMesh;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.SceneObject;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	use namespace YOGURT3D_INTERNAL;	
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class SkeletalAnimatedMeshBase extends Mesh {
		
		
		public var rootHeight					: Number;
		public var bones						: Vector.<Bone>;
		
		
		public function SkeletalAnimatedMeshBase(_initInternals : Boolean = true) {
			super(_initInternals);
		}
		
		protected override function initInternals():void
		{
			super.initInternals();			
		}
		
		public function setBindPose():void{
			for( var i:int = 0; i < bones.length; i++)
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
			for( i = 0; i < bones.length; i++)
			{
				bones[i].setBindingPose();
			}
		}
		
		
	}
}
