/*
* SkinnedSubMesh.as
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
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.Dictionary;
	
	use namespace YOGURT3D_INTERNAL;
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class SkinnedSubMesh extends SubMesh
	{
		YOGURT3D_INTERNAL var m_boneDataBuffersByContext3D 	:Dictionary;
		
		private var partition:uint;	
		// maps the index of an un-partitioned vertex to that same vertex if it has been added to this particular partition. 
		// speeds up checking for duplicate vertices so we don't add the same vertex more than once.  
		private var indicesMap:Dictionary;
		public var vertexList:Vector.<uint>;
		public var originalBoneIndex:Vector.<uint>;
		
		public var bones						: Vector.<Bone>;
		public var boneIndies					: Vector.<Number>;
		public var boneWeights					: Vector.<Number>;
		
		public static const MAX_BONE_COUNT:uint = 38;
		
		public function SkinnedSubMesh()
		{
			clear();
			m_boneDataBuffersByContext3D = new Dictionary();
		}
		
		public override function dispose():void{
			indicesMap = null;
			vertexList = null;
			originalBoneIndex = null;
			bones = null;
			boneIndies = null;
			boneWeights = null;
			
			super.dispose();
		}
		
		public override function disposeGPU():void{
			super.disposeGPU();
			
			if( m_boneDataBuffersByContext3D )	
			{
				for each (var inBuf:VertexBuffer3D in m_boneDataBuffersByContext3D) {inBuf.dispose();}		
				m_boneDataBuffersByContext3D = new Dictionary();
			}
		}
		
		public override function get type():String{
			return "SkinnedMesh";
		}
		
		/**
		 * clears _Vertices, _Indices, and _IndicesMap, so we can start building another mesh subset with the same set of bones. 
		 * 
		 */
		public function clear():void{
			
			vertices = new Vector.<Number>();
			indices = new Vector.<uint>();
			indicesMap = new Dictionary();
			bones = new Vector.<Bone>();
			vertexList = new Vector.<uint>;
			originalBoneIndex = new Vector.<uint>;
			partition = 0;		
		}
		
		/**
		 * adds a vertex to this partition and returns the index of the added vertex, or returns the index of the  <br/>
		 * existing vertex if it has already been added.   <br/>
		 **/
		public function addVertex(_vertice:Vector.<Number>, _vertexIndex:uint):uint{
			
			var index:uint;
			
			if(indicesMap[_vertexIndex] != null){
				
				// return existing partitioned vertex  
				index = indicesMap[_vertexIndex];
				this.indices.push(index);
				
				
			}else{
				
				index = vertices.length/3;  
				indices.push( index ); 
				for(var k:uint = 0; k < _vertice.length; k++)
					this.vertices.push(_vertice[k]);  
				
				indicesMap[_vertexIndex] =  index;  
			}
			
			// holds original vertex index data
			if(vertexList.indexOf(_vertexIndex) == -1){
				vertexList.push(_vertexIndex);
			}
			m_triangleCount = this.indices.length / 3;
			return index;
		}
		/**
		 * adds a primitive to the bone partition builder.  <br/>
		 * returns true if primitive was successfully added.   <br/>
		 * returns false if primitive uses too many bones, more bones than we have room for. <br/>
		 **/
		public function addPrimitive(_verticesCount:uint, _vertices: Vector.<Number>, _indices:Vector.<uint>,_boneMap:Vector.<Vector.<uint>>):Boolean{
			
			// build a list of all the bones used by the vertex that aren't currently in this partition  
			
			var bonesToAdd:Vector.<uint> = new Vector.<uint>();
			var bonesToAddCount:uint = 0;
			var len:uint =  _indices.length;
			var indice:uint;
			
			for ( var iVertex:uint = 0; iVertex < len; iVertex++ )  
			{ 
				indice = _indices[iVertex];
				// get bone indices
				var bones:Vector.<uint> = _boneMap[indice];
				var bCount:uint = bones.length;
				for(var k:uint = 0; k < bCount; k++){
					
					var boneIndex:uint = bones[k];
					var needToAdd:Boolean = true;
					
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
						var boneRemapResult:int = getBoneRemap(boneIndex);
						
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
			
			// add vertices and indices  
			for ( iVertex = 0; iVertex < _verticesCount; iVertex++ )  
			{  
				var vert:Vector.<Number> = _vertices.slice(iVertex * 3, iVertex * 3 + 3);
				this.addVertex(vert, _indices[iVertex] );  
			}  
			
			return true;
		}
		
		/**
		 * given the index of an un-partitioned bone, returns the index of the same bone in this partition.   <br/>
		 * this is used to remap the bone indices in an un-partitioned vertex to make it into a partitioned vertex.   <br/>
		 **/
		public function getBoneRemap(_boneIndex:uint):int{
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
		
		public function printBones():void{
			
			Y3DCONFIG::TRACE
			{
				trace("*******************************************");
				
				trace("Orig Bone Index ", this.originalBoneIndex.length," = ",this.originalBoneIndex);
				trace("Bone Weights",this.boneWeights.length ," = ",this.boneWeights);
				trace("Bone Indices", this.boneIndies.length," = ",this.boneIndies);
				trace("Mesh Indices ",this.indices.length ," = ",this.indices);
				trace("Bones:", this.bones.length);
				
				trace("*******************************************");
			}
		
		}
		
		public function updateWeightTable():void{
			
			boneWeights = new Vector.<Number>();
			boneIndies = new Vector.<Number>();
			var vertexIndex:int;
			var boneList:Array;
			var weightList:Array;
			var index:uint;
			var boneIndex:int;
			if( vertexList.length != 0 )
			{
				for( vertexIndex = 0; vertexIndex < vertexList.length; vertexIndex++ ){
					boneList = [-1,-1,-1,-1, -1,-1,-1,-1];
					weightList = [0,0,0,0, 0,0,0,0];
					index = 0;
					for( boneIndex = 0; boneIndex < bones.length; boneIndex++ ){
						var temp:int = bones[boneIndex].indices.indexOf( vertexList[vertexIndex] );
						if( temp > -1 ){
							boneList[index] = boneIndex * 3 ;
							weightList[index] = bones[boneIndex].weights[ temp ];
							index++;
						}
						
					}
					boneWeights.push(weightList[0],weightList[1],weightList[2],weightList[3],
						weightList[4],weightList[5],weightList[6],weightList[7]);
					boneIndies.push(boneList[0],boneList[1],boneList[2],boneList[3],
						boneList[4],boneList[5],boneList[6],boneList[7]);
					
				}
			}else{
				boneIndies = new Vector.<Number>();
				for( vertexIndex = 0; vertexIndex < vertexCount; vertexIndex++ )
				{
					boneList = [-1,-1,-1,-1,-1,-1,-1,-1];
					weightList = [0,0,0,0,
						0,0,0,0];
					index = 0;
					for( boneIndex = 0; boneIndex < bones.length; boneIndex++ )
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
				}
			}
			
			
		}
		
		
		/**
		 * @inheritDoc
		 **/
		public function getBoneDataBufferByContext3D(_context3D:Context3D):VertexBuffer3D {
			if (m_boneDataBuffersByContext3D[_context3D]) {
				return m_boneDataBuffersByContext3D[_context3D];
			}			
			
			
			var _bufferData	:Vector.<Number>			= MeshUtils.createVertexBufferDataAsVector( m_vertexCount, boneIndies, boneWeights );
			
			m_boneDataBuffersByContext3D[_context3D] = _context3D.createVertexBuffer( m_vertexCount, 8 + 8);			
			m_boneDataBuffersByContext3D[_context3D].uploadFromVector( _bufferData, 0, m_vertexCount );
			
			return m_boneDataBuffersByContext3D[_context3D];
		}
		
	}
}
