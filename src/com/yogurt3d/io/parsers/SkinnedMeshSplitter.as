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
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	
	import com.yogurt3d.core.geoms.Bone;
	import com.yogurt3d.core.geoms.SkeletalAnimatedMeshBase;
	import com.yogurt3d.core.geoms.SkinnedSubMesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.geoms.SkinnedSubMesh;
	
	import flash.utils.Dictionary;
	import com.yogurt3d.core.geoms.Bone;
	import com.yogurt3d.core.geoms.SkinnedSubMesh;
	
	import flash.utils.Dictionary;
	
	
	use namespace YOGURT3D_INTERNAL;
	/**
	 * AIM: partitioning the mesh into smaller pieces that shares the same bone.
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class SkinnedMeshSplitter
	{
		public static const MAX_BONE_COUNT:uint = 38;
		
		public function SkinnedMeshSplitter(){}
		
		public function split( _skeletalAnimatedGPUMesh:SkeletalAnimatedMeshBase ): SkeletalAnimatedMeshBase {
			var bones:Vector.<Bone> = _skeletalAnimatedGPUMesh.bones;
			
			var _boneLen:int = bones.length;
			if(_boneLen < MAX_BONE_COUNT){			
				return null;
			}
			
			Y3DCONFIG::TRACE
			{
				trace("[SkinnedMeshSplitter]******************SPLITTING***************************");
				trace("[SkinnedMeshSplitter] Bone count:",_boneLen);
			}
			
			var gpuSubMesh:SubMesh = _skeletalAnimatedGPUMesh.subMeshList[0];
			var partitionList:Vector.<SkinnedSubMesh> = new Vector.<SkinnedSubMesh>();
			
			var _meshIndices:Vector.<uint> = gpuSubMesh.indices;
			var _triangleCount:uint = _meshIndices.length/3;
			var _vertexCount:uint = gpuSubMesh.vertexCount;
			var _indicesLength:uint = _meshIndices.length;
			
			var i:uint, mIndice:uint, len2:uint;
			var vertexList:Vector.<uint>;
			
			// first get every indices bone list
			var vertexBoneMap:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(_vertexCount);
			for(var index:uint = 0; index < _vertexCount; index++){
				vertexBoneMap[index] = new Vector.<uint>();
			}
			
			for( i = 0; i < _boneLen; i++){
				// get indices that is connected to bone i
				vertexList = bones[i].indices;
				
				len2 = vertexList.length;
				for(var k:int = 0; k < len2; k++){
					mIndice = vertexList[k];
					vertexBoneMap[mIndice].push(i);
				}
			}
			
			// phase 1  
			// build bone partitions  
			var x1:Number,x2:Number,x3:Number;
			var y1:Number,y2:Number,y3:Number;
			var z1:Number,z2:Number,z3:Number;
			var isAdded:Boolean = false;
			var vertices:Vector.<Number>, indices:Vector.<uint>;
			var partition:SkinnedSubMesh;
			
			var uvt:Vector.<Number> = gpuSubMesh.uvt;
			var normals:Vector.<Number> = gpuSubMesh.normals;
			var tangents:Vector.<Number> = gpuSubMesh.tangents;
			var gpuVertices:Vector.<Number> = gpuSubMesh.vertices;
			
			var hasUv:Boolean = (uvt)? true: false;
			var hasNormal:Boolean = (normals)? true: false;
			var hasTangent:Boolean = (tangents)? true: false;
			var _triangleIndice1:uint, _triangleIndice2:uint, _triangleIndice3:uint;
			var tIndex:uint, partitionLength:uint;
			var iBonePartition:uint = 0, _triangleIndex:uint = 0;
			
			
			for( ; _triangleIndex < _triangleCount; _triangleIndex++ ){
				
				vertices = new Vector.<Number>();
				indices = new Vector.<uint>();
				
				tIndex = _triangleIndex * 3;
				
				_triangleIndice1 = _meshIndices[ uint(tIndex) ];
				_triangleIndice2 = _meshIndices[ uint(tIndex + 1) ];
				_triangleIndice3 = _meshIndices[ uint(tIndex + 2) ];
				indices.push(_triangleIndice1, _triangleIndice2, _triangleIndice3);
				
				_triangleIndice1 = _triangleIndice1 * 3;
				_triangleIndice2 = _triangleIndice2 * 3;
				_triangleIndice3 = _triangleIndice3 * 3;
				
				x1 = gpuVertices[uint(_triangleIndice1)];
				y1 = gpuVertices[uint(_triangleIndice1 + 1)];
				z1 = gpuVertices[uint(_triangleIndice1 + 2)];
				
				x2 = gpuVertices[uint(_triangleIndice2)];
				y2 = gpuVertices[uint(_triangleIndice2 + 1)];
				z2 = gpuVertices[uint(_triangleIndice2 + 2)];
				
				x3 = gpuVertices[uint(_triangleIndice3)];
				y3 = gpuVertices[uint(_triangleIndice3 + 1)];
				z3 = gpuVertices[uint(_triangleIndice3 + 2)];
				
				vertices.push(x1,y1,z1,x2,y2,z2,x3,y3,z3);
				
				isAdded = false;
				
				partitionLength = partitionList.length;
				// attempt to add the primitive to an existing bone partition  
				for(iBonePartition = 0; iBonePartition < partitionLength; iBonePartition++ ){
					
					partition = (partitionList[iBonePartition] as SkinnedSubMesh);
					
					if (addPrimitive( partition, 3, vertices, indices , vertexBoneMap ) )  
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
					isAdded = addPrimitive( partition, 3, vertices, indices, vertexBoneMap );  
					if(isAdded){
						partitionList.push(partition);
					}else{
						partition.dispose();
					}
				}  
			} 
			
			var base:SkinnedSubMesh;
			var totalBones:uint = 0, totalMIndices:uint = 0, totalTri:uint = 0, totalVert:uint = 0;
			var nUvt:Vector.<Number>, nNormals:Vector.<Number>, nTangents:Vector.<Number>;
			var vIndex:uint, vlen:uint;
			var part:uint = 0, b:uint = 0, bLen:uint;
			var bIndex:Vector.<uint>, ind:uint;
			var boneClone:Bone, part1:SkinnedSubMesh;
			
			partitionLength = partitionList.length;
			
			for( ; part < partitionLength; part++)
			{
				part1 	= partitionList[part];
				base 	= part1 as SkinnedSubMesh;
				
				// set vertex count
				base.m_vertexCount = base.vertices.length / 3;
				
				// push related bones
				bIndex 	= base.originalBoneIndex;
				bLen 	= bIndex.length;
				
				for(b = 0; b < bLen; b++){
					ind = bIndex[b];
					boneClone = bones[ind];
					part1.bones.push(bones[ind]);
				}
				
				// push related uvt & related normals & related tangents
				
				if(hasUv)
					part1.uvt = new Vector.<Number>();
				if(hasNormal)
					part1.normals = new Vector.<Number>();
				if(hasTangent)
					part1.tangents = new Vector.<Number>();
				
				//trace(base.vertexList);
				vlen = base.vertexList.length;
				
				
				for(var t:uint = 0; t < vlen; t++)
				{
					vIndex = base.vertexList[t];
					
					if(hasUv){
						nUvt = 	part1.uvt;						
						nUvt.push(uvt[vIndex << 1], uvt[-~((vIndex << 1))]);
					}
					
					if(hasNormal){
						nNormals = 	part1.normals;	
						nNormals.push(normals[vIndex * 3], normals[vIndex * 3 + 1], normals[vIndex * 3 + 2]);
					}
					
					if(hasTangent){
						nTangents = part1.tangents;
						nTangents.push(tangents[vIndex * 3], tangents[vIndex * 3 + 1], tangents[vIndex * 3 + 2]);
					}	
				}
				
				updateWeightTable(base);
				
				totalBones += base.bones.length;
				totalMIndices += base.indices.length;
				totalTri += base.indices.length/3;
				totalVert += base.vertexCount;
				
				Y3DCONFIG::TRACE
				{
					trace("[SkinnedMeshSplitter]",part, "Bones:", base.bones.length,
						"MInd:",base.indices.length,
						"TriangleCount",base.indices.length/3,
						"Vertex Count:", base.vertexCount);
				}
			}
import com.yogurt3d.core.geoms.SkinnedSubMesh;
			
			
			var mesh:SkeletalAnimatedMeshBase = new SkeletalAnimatedMeshBase();
			var list:Vector.<SubMesh> = mesh.subMeshList;
			var plen:uint = partitionList.length;
			for( i= 0; i < plen; i++)
			{
				SkinnedSubMesh(partitionList[i]).indicesMap = null;
				SkinnedSubMesh(partitionList[i]).vertexList = null;
				list.push( partitionList[i]);
			}
			mesh.bones = bones;
			mesh.setBindPose();
			
			_skeletalAnimatedGPUMesh.bones = null;
			_skeletalAnimatedGPUMesh.disposeDeep();
			
			return mesh;
			
		}
		
		private final function updateWeightTable(_subMesh:SkinnedSubMesh):void{
			
			_subMesh.boneWeights = new Vector.<Number>();
			_subMesh.boneIndies = new Vector.<Number>();
			var boneWeights: Vector.<Number> = _subMesh.boneWeights;
			var boneIndies: Vector.<Number> = _subMesh.boneIndies;
			var vertexList:Vector.<uint> = _subMesh.vertexList;
			var bones: Vector.<Bone> = _subMesh.bones;
			var vertexCount:uint = _subMesh.vertexCount;
			
			var vertexIndex:int, index:uint, boneIndex:int;
			var boneList:Array, weightList:Array;
			var boneIndiceIndex:int, bone:Bone;
			var bLen:uint = bones.length;
			var vLen:uint = vertexList.length;
			
			if( vertexList.length != 0 )
			{
				for( vertexIndex = 0; vertexIndex < vLen; vertexIndex++ ){
					boneList = [-1,-1,-1,-1, -1,-1,-1,-1];
					weightList = [0,0,0,0, 0,0,0,0];
					index = 0;
					for( boneIndex = 0; boneIndex < bLen; boneIndex++ ){
						bone = bones[boneIndex];
						boneIndiceIndex = bone.indices.indexOf( vertexList[vertexIndex] );
						
						if( boneIndiceIndex > -1 ){
							boneList[index] = boneIndex * 3 ;
							weightList[index] = bone.weights[ boneIndiceIndex ];
							index++;
						}
						
					}
					boneWeights.push(weightList[0],weightList[1],weightList[2],weightList[3],
						weightList[4],weightList[5],weightList[6],weightList[7]);
					boneIndies.push(boneList[0],boneList[1],boneList[2],boneList[3],
						boneList[4],boneList[5],boneList[6],boneList[7]);
					
				}
			}else{
				
				for( vertexIndex = 0; vertexIndex < vertexCount; vertexIndex++ )
				{
					boneList = [-1,-1,-1,-1,-1,-1,-1,-1];
					weightList = [0,0,0,0,0,0,0,0];
					index = 0;
					for( boneIndex = 0; boneIndex < bLen; boneIndex++ )
					{
						bone = bones[boneIndex];
						boneIndiceIndex = bone.indices.indexOf( vertexIndex );
						if( boneIndiceIndex > -1 )
						{
							boneList[index] = boneIndex * 3 ;
							weightList[index] = bone.weights[ boneIndiceIndex ];
							index++;
						}
					}
					boneWeights.push(weightList[0],weightList[1],weightList[2],weightList[3],
						weightList[4],weightList[5],weightList[6],weightList[7]);
					boneIndies.push(boneList[0],boneList[1],boneList[2],boneList[3],
						boneList[4],boneList[5],boneList[6],boneList[7]);
				}
			}
			
			
		}
		
		/**
		 * adds a primitive to the bone partition builder.  <br/>
		 * returns true if primitive was successfully added.   <br/>
		 * returns false if primitive uses too many bones, more bones than we have room for. <br/>
		 **/
		private final function addPrimitive(_subMesh:SkinnedSubMesh, _verticesCount:uint, _vertices: Vector.<Number>, _indices:Vector.<uint>,_boneMap:Vector.<Vector.<uint>>):Boolean{
			
			// build a list of all the bones used by the vertex that aren't currently in this partition  
			
			var bonesToAdd:Vector.<uint> = new Vector.<uint>();
			var bonesToAddCount:uint = 0;
			var len:uint =  _indices.length;
			var indice:uint, bIndex:uint;
			var bone:Bone, bones:Vector.<uint>;
			var bCount:uint, needToAdd:Boolean;
			var boneIndex:uint, originalBoneIndex:Vector.<uint> = _subMesh.originalBoneIndex;
			
			for ( var iVertex:uint = 0; iVertex < len; iVertex++ )  
			{ 
				indice = _indices[iVertex];
				// get bone indices
				bones = _boneMap[indice];
				bCount = bones.length;
				
				for(var k:uint = 0; k < bCount; k++){
					
					boneIndex = bones[k];
					needToAdd = true;
					
					for ( var iBoneToAdd:uint = 0; iBoneToAdd < bonesToAddCount; iBoneToAdd++ )  
					{  
						if ( bonesToAdd[iBoneToAdd] == boneIndex )  
						{  
							needToAdd = false;  
							break;  
						}  
					}  
					
					if(needToAdd){
						bonesToAdd[bonesToAddCount] = boneIndex;
						var boneRemapResult:int = getBoneRemap(_subMesh, boneIndex);
						
						bonesToAddCount += (boneRemapResult == -1 ? 1 : 0);
					}
					
				}
			}
			
			// check that we can fit more bones in this partition. 
			if ( ( originalBoneIndex.length + bonesToAddCount ) > MAX_BONE_COUNT )  
			{  
				return false;  
			}  
			// add bones 
			
			for ( var iBone:uint = 0; iBone < bonesToAddCount; iBone++ )  
			{  
				originalBoneIndex.push( bonesToAdd[iBone] );  
			}
			
			var vInd:uint;
			// add vertices and indices  
			for ( iVertex = 0; iVertex < _verticesCount; iVertex++ )  
			{  
				vInd = iVertex * 3;
				var vert:Vector.<Number> = _vertices.slice(vInd, vInd + 3);
				addVertex(_subMesh, vert, _indices[iVertex] );  
			}  
			
			return true;
		}
		
		/**
		 * given the index of an un-partitioned bone, returns the index of the same bone in this partition.   <br/>
		 * this is used to remap the bone indices in an un-partitioned vertex to make it into a partitioned vertex.   <br/>
		 **/
		private final function getBoneRemap(_subMesh:SkinnedSubMesh, _boneIndex:uint):int{
			var originalBoneIndex:Vector.<uint> = _subMesh.originalBoneIndex;
			var bCount:uint = originalBoneIndex.length;
			for ( var iBone:uint = 0; iBone < bCount; iBone++ )  
			{  
				if ( originalBoneIndex[iBone] == _boneIndex )  
				{  
					if(iBone > MAX_BONE_COUNT)
						return -1;
					
					return iBone;  
				}  
			}  
			
			return -1;
		}	
		
		/**
		 * adds a vertex to this partition and returns the index of the added vertex, or returns the index of the  <br/>
		 * existing vertex if it has already been added.   <br/>
		 **/
		private final function addVertex(_subMesh:SkinnedSubMesh, _vertice:Vector.<Number>, _vertexIndex:uint):uint{
			var index:uint;
			var vlen:uint;
			var indicesMap:Dictionary = _subMesh.indicesMap;
			var indices:Vector.<uint> = _subMesh.indices;
			var vertices:Vector.<Number> = _subMesh.vertices;
			var vertexList:Vector.<uint> = _subMesh.vertexList;
			
			if(indicesMap[_vertexIndex] != null){
				
				// return existing partitioned vertex  
				index = indicesMap[_vertexIndex];
				var tt:uint = indices.length;
				indices[tt] = index;
				
				
			}else{
				
				index = vertices.length/3;  
				indices.push( index ); 
				vlen = _vertice.length;
				for(var k:uint = 0; k < vlen; k++)
					vertices.push(_vertice[k]);  
				
				indicesMap[_vertexIndex] =  index;  
			}
			
			var vIndex:int = vertexList.indexOf(_vertexIndex);
			// holds original vertex index data
			if(vIndex == -1){
				vertexList.push(_vertexIndex);
			}
			_subMesh.m_triangleCount = indices.length / 3;
			return index;
		}
	}
}
