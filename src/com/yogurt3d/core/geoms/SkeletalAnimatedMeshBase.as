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
		public var boneIndies					: Vector.<Number>;
		public var boneWeights					: Vector.<Number>;
		
		
		public function SkeletalAnimatedMeshBase(_initInternals : Boolean = true) {
			super(_initInternals);
		}
		
		protected override function initInternals():void
		{
			super.initInternals();			
		}
		
		/*public override function getVertexBufferByContext3D(_context3D:Context3D):VertexBuffer3D {

			if (m_vertexBuffersByContext3D[_context3D]) {
				return m_vertexBuffersByContext3D[_context3D];
			}
			
			if( m_normals == null )
			{
				m_normals = MeshUtils.calculateVerticeNormals( indices, m_vertices );
			}
			
			if( m_tangents == null )
			{ 
				m_tangents = MeshUtils.calculateVerticeTangents( m_normals );
			}
			var _bufferData		:Vector.<Number>			= MeshUtils.createVertexBufferDataAsVector( m_vertexCount, m_vertices, uvt, m_normals, m_tangents, boneIndies, boneWeights);
			
			m_vertexBuffersByContext3D[_context3D] = _context3D.createVertexBuffer( m_vertexCount, 11 + 8 + 8);			
			m_vertexBuffersByContext3D[_context3D].uploadFromVector(_bufferData, 0, m_vertexCount);
			
			return m_vertexBuffersByContext3D[_context3D];
		}*/
		
		public function setupWeightTable():void{
			/*boneWeights = new Vector.<Number>();
			boneIndies = new Vector.<Number>();
			for( var vertexIndex:int = 0; vertexIndex < vertexCount; vertexIndex++ )
			{
				var boneList:Array = [-1,-1,-1,-1,-1,-1,-1];
				var weightList:Array = [0,0,0,0,0,0,0,0];
				var index:uint = 0;
				for( var boneIndex:int = 0; boneIndex < bones.length; boneIndex++ )
				{
					if( bones[boneIndex].indices.indexOf( vertexIndex ) > -1 )
					{
						boneList[index] = boneIndex * 3 ;
						weightList[index] = bones[boneIndex].weights[ bones[boneIndex].indices.indexOf( vertexIndex ) ];
						index++;
					}
				}
				boneWeights.push(weightList[0],weightList[1],weightList[2],weightList[3],
									weightList[4],weightList[5],weightList[6],weightList[7]);
				boneIndies.push(boneList[0],boneList[1],boneList[2],boneList[3],
									boneList[4],boneList[5],boneList[6],boneList[7]);
			}*/
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
