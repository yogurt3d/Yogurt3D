/*
 * SkinnedMeshSplitter.as
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
 
 
package com.yogurt3d.io.parsers
{
	import com.yogurt3d.core.geoms.Bone;
	import com.yogurt3d.core.geoms.SkeletalAnimatedMeshBase;
	import com.yogurt3d.core.geoms.SkinnedSubMesh;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	
	import flash.utils.Dictionary;

	/**
	 * AIM: partitioning the mesh into smaller pieces that shares the same bone.
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class SkinnedMeshSplitter
	{
		private var _subMeshDictionary:Dictionary;
		
		public function SkinnedMeshSplitter(){
			
			_subMeshDictionary = new Dictionary();
		}
		
		// if the splitter is used more than once
		public function reset():void{
			
			_subMeshDictionary = new Dictionary();
		}
		
		public function split( _skeletalAnimatedGPUMesh:SkeletalAnimatedMeshBase ): SkeletalAnimatedMeshBase {
			
			var partitionList:Vector.<SkinnedSubMesh> = new Vector.<SkinnedSubMesh>();
			
			_subMeshDictionary = new Dictionary();
			
			//resultMeshes.push(_skeletalAnimatedGPUMesh); 
			Y3DCONFIG::TRACE
			{
				trace("******************SPLITTING***************************");
			}
			var _boneLen:int = _skeletalAnimatedGPUMesh.bones.length;
			Y3DCONFIG::TRACE
			{
				trace("Bone count:",_boneLen);
			}
			if(_boneLen < SkinnedSubMesh.MAX_BONE_COUNT){			
				return null;
			}
			var _meshIndices:Vector.<uint> 		= _skeletalAnimatedGPUMesh.subMeshList[0].indices;
			var _triangleCount:uint 			= _meshIndices.length/3;
			var _vertexCount:uint				= _skeletalAnimatedGPUMesh.subMeshList[0].vertexCount;
			var _indicesLength:uint 			= _meshIndices.length;
			
			var i:uint;
				
			// first get every indices bone list
			var vertexBoneMap:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(_vertexCount);
			for(var index:uint = 0; index < _vertexCount; index++){
				vertexBoneMap[index] = new Vector.<uint>();
			}
			
			var len:int = _skeletalAnimatedGPUMesh.bones.length;
			for( i = 0; i < len; i++){
				// get indices that is connected to bone i
				var vertexList:Vector.<uint> = _skeletalAnimatedGPUMesh.bones[i].indices;
				var len2:uint = vertexList.length;
				//trace(i,vertexList );
				for(var k:int = 0; k < len2; k++){
					var mIndice:uint = vertexList[k];
					vertexBoneMap[mIndice].push(i);
				}
			}
				
			// phase 1  
			// build bone partitions  
			var x1:Number,x2:Number,x3:Number;
			var y1:Number,y2:Number,y3:Number;
			var z1:Number,z2:Number,z3:Number;
			var isAdded:Boolean = false;
			var vertices:Vector.<Number>;
			var indices:Vector.<uint>;
			var partition:SkinnedSubMesh;

			for( var _triangleIndex:uint = 0; _triangleIndex < _triangleCount; _triangleIndex++ ){
				
				var _triangleIndice1:uint = _meshIndices[ _triangleIndex * 3 + 0 ];
				var _triangleIndice2:uint = _meshIndices[ _triangleIndex * 3 + 1 ];
				var _triangleIndice3:uint = _meshIndices[ _triangleIndex * 3 + 2 ];
				
				var t1:uint = _triangleIndice1 * 3;
				var t2:uint = _triangleIndice2 * 3;
				var t3:uint = _triangleIndice3 * 3;
				
				
				x1 = _skeletalAnimatedGPUMesh.subMeshList[0].vertices[t1 + 0];
				y1 = _skeletalAnimatedGPUMesh.subMeshList[0].vertices[t1 + 1];
				z1 = _skeletalAnimatedGPUMesh.subMeshList[0].vertices[t1 + 2];
				
				x2 = _skeletalAnimatedGPUMesh.subMeshList[0].vertices[t2 + 0];
				y2 = _skeletalAnimatedGPUMesh.subMeshList[0].vertices[t2 + 1];
				z2 = _skeletalAnimatedGPUMesh.subMeshList[0].vertices[t2 + 2];
				
				x3 = _skeletalAnimatedGPUMesh.subMeshList[0].vertices[t3 + 0];
				y3 = _skeletalAnimatedGPUMesh.subMeshList[0].vertices[t3 + 1];
				z3 = _skeletalAnimatedGPUMesh.subMeshList[0].vertices[t3 + 2];
				
				vertices = new Vector.<Number>();
				indices = new Vector.<uint>();
				
				vertices.push(x1,y1,z1,x2,y2,z2,x3,y3,z3);
				indices.push(_triangleIndice1, _triangleIndice2, _triangleIndice3);
			
				isAdded = false;
				
				// attempt to add the primitive to an existing bone partition  
				for(var iBonePartition:uint = 0; iBonePartition < partitionList.length; iBonePartition++ ){
					
					partition = SkinnedSubMesh(partitionList[iBonePartition]);
					
					if (partition.addPrimitive( 3, vertices, indices , vertexBoneMap ) )  
					{  
						isAdded = true;
						break;
					}  
				}
				// if the primitive was not added to an existing bone partition, 
				// we need to make a new bone partition and add the primitive to it  
				
				if ( !isAdded )  
				{  
					partition = new SkinnedSubMesh();
					isAdded = partition.addPrimitive( 3, vertices, indices, vertexBoneMap );  
					if(isAdded){
						partitionList.push(partition);
					}
				}  
			} 
			
			var base:SkinnedSubMesh;
			var totalBones:uint = 0, totalMIndices:uint = 0, totalTri:uint = 0, totalVert:uint = 0;
			for(var part:uint = 0; part < partitionList.length; part++){
				base = SkinnedSubMesh(partitionList[part]);
				
				// set vertex count
				base.YOGURT3D_INTERNAL::m_vertexCount = base.vertices.length / 3;
				
				// push related bones
				for(var b:uint = 0; b < base.originalBoneIndex.length; b++){
					var boneClone:Bone = _skeletalAnimatedGPUMesh.bones[base.originalBoneIndex[b]];
					
					partitionList[part].bones.push(_skeletalAnimatedGPUMesh.bones[base.originalBoneIndex[b]]);
				}
				
				// push related uvt & related normals & related tangents
			
				if(_skeletalAnimatedGPUMesh.subMeshList[0].uvt != null){
					partitionList[part].uvt = new Vector.<Number>();
				}
				if(_skeletalAnimatedGPUMesh.subMeshList[0].normals != null){
					partitionList[part].normals = new Vector.<Number>();
				}
				if(_skeletalAnimatedGPUMesh.subMeshList[0].tangents != null){
					partitionList[part].tangents = new Vector.<Number>();
				}
					
				//trace(base.vertexList);
				var vlen:uint = base.vertexList.length;
				for(var t:uint = 0; t < vlen; t++){
					var vIndex:uint = base.vertexList[t];
					
					if(_skeletalAnimatedGPUMesh.subMeshList[0].uvt != null){
											
						partitionList[part].uvt.push(_skeletalAnimatedGPUMesh.subMeshList[0].uvt[vIndex * 2]);
						partitionList[part].uvt.push(_skeletalAnimatedGPUMesh.subMeshList[0].uvt[vIndex * 2 + 1]);
					}
					 
					if(_skeletalAnimatedGPUMesh.subMeshList[0].normals != null){
									
						partitionList[part].normals.push(_skeletalAnimatedGPUMesh.subMeshList[0].normals[vIndex * 3]);
						partitionList[part].normals.push(_skeletalAnimatedGPUMesh.subMeshList[0].normals[vIndex * 3 + 1]);
						partitionList[part].normals.push(_skeletalAnimatedGPUMesh.subMeshList[0].normals[vIndex * 3 + 2]);
					}
					
					if(_skeletalAnimatedGPUMesh.subMeshList[0].tangents != null){
						
						partitionList[part].tangents.push(_skeletalAnimatedGPUMesh.subMeshList[0].tangents[vIndex * 3]);
						partitionList[part].tangents.push(_skeletalAnimatedGPUMesh.subMeshList[0].tangents[vIndex * 3 + 1]);
						partitionList[part].tangents.push(_skeletalAnimatedGPUMesh.subMeshList[0].tangents[vIndex * 3 + 2]);
					}	
				}
				
				base.updateWeightTable();
				//base.setBindPose();
				
				totalBones 		+= base.bones.length;
				totalMIndices		+= base.indices.length;
				totalTri 		+= base.indices.length/3;
				totalVert 		+= base.vertexCount;
				
				Y3DCONFIG::TRACE
				{
					trace(part, "Bones:", base.bones.length,
								"MInd:",base.indices.length,
								"TriangleCount",base.indices.length/3,
								"Vertex Count:", base.vertexCount);
				}
			}
			Y3DCONFIG::TRACE
			{
				trace("totalBones", totalBones, "totalMIndices", totalMIndices, "totalTri", totalTri, "totalVert", totalVert);
			}
			var mesh:SkeletalAnimatedMeshBase = new SkeletalAnimatedMeshBase();
			for( i= 0; i < partitionList.length; i++)
			{
				mesh.subMeshList.push( partitionList[i]);
			}
			mesh.bones = _skeletalAnimatedGPUMesh.bones;
			mesh.setBindPose();
			return mesh;
		
		}
	}
}
