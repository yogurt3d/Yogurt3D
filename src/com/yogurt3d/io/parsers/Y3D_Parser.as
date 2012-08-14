/*
 * Y3D_Parser.as
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
 
 
package com.yogurt3d.io.parsers {
	import com.yogurt3d.core.geoms.Bone;
	import com.yogurt3d.core.geoms.Mesh;
	import com.yogurt3d.core.geoms.SkeletalAnimatedMesh;
	import com.yogurt3d.core.geoms.SkeletalAnimatedMeshBase;
	import com.yogurt3d.core.geoms.SkinnedSubMesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.transformations.Quaternion;
	import com.yogurt3d.io.parsers.interfaces.IParser;
	
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class Y3D_Parser implements IParser
	{
		private static const INANIMATE_MESH_DATA	:int	= 0;
		private static const ANIMATED_MESH_DATA		:int	= 1;
		
		private static const AABB_DATA_LENGTH		:int	= 6;
		
		public function Y3D_Parser()
		{
		}
		
		/**
		 * Public interface method to parse any Y3D binary. Return the according mesh data object (Mesh or SkeletalAnimatedGPUMesh).
		 * @param _value ByteArray containing the Y3D binary file.
		 * @param verbose File header info is printed when this is set to true.
		 *
		 */	
		public function parse(_data:*, split:Boolean = true):*
		{
			if(_data is ByteArray)
			{
				return parseByteArray(_data, split);
			}
		}
		/**
		 * Parses any Y3D binary and returns the according data object.
		 * @param _value ByteArray containing the Y3D binary file.
		 * @param verbose File header info is printed when this is set to true.
		 * 
		 */				
		private function parseByteArray(_value:ByteArray, split:Boolean = true):*
		{
			var _dataType				:int;
			var _exportType				:String;	
			
			try{
				ByteArray(_value).inflate();
			}catch(_e:*)
			{
				
			}
			
			_value.position				= 0;
			_value.endian				= Endian.LITTLE_ENDIAN;
			
			_dataType					= _value.readInt();
			_value.position = 0;
			//_value.inflate();
			var len:uint;
			_exportType					= _value.readMultiByte( _value.readShort() * 2,"utf-16");
			
			// new file
			if( _exportType == "Yogurt3D" )
			{
				var version:uint = _value.readShort();
				if( version == 2 )
				{
					return parseY3dFormat2( _value, split );
				}else if( version == 3){
					return parseY3dFormat3( _value, split );
				}
			}
			
			// old file
			_value.position = 4;
			
			for(var aabb:int = 0; aabb < AABB_DATA_LENGTH; aabb++)
			{
				_value.readFloat();
			}
			
			switch(_dataType)
			{
				case INANIMATE_MESH_DATA:					
					return parseByteArrayAsOldInanimate( _value );
				break;
				
				case ANIMATED_MESH_DATA:
					return parseByteArrayAsOldAnimated( _value );
				break;
			}
		}
		/**
		 * 
		 * @param _value
		 * @param verbose
		 * @return 
		 * 
		 */
		private function parseY3dFormat3( _value:ByteArray, split:Boolean =  true ):*{
			
			var _verticesData			:Vector.<Number>;
			var _indicesData			:Vector.<uint>;
			var _uvtData				:Vector.<Number>;
			var _uvtData2				:Vector.<Number>;
			var _uvtData3				:Vector.<Number>;
			var _normalData				:Vector.<Number>;
			var _tangentData			:Vector.<Number>;
			
			var type:uint = _value.readShort();
			var exporter:String = _value.readMultiByte( _value.readShort() * 2, "utf-16" );
			var upVector:uint = _value.readShort();
			var vertexCount:int = _value.readInt();
			var indexCount:int = _value.readInt();
			var tangentsIncluded:Boolean = _value.readBoolean();
			var uvCount:int = _value.readShort();
			var ocFactorIncluded:Boolean = _value.readBoolean();
			
			var uvC:uint;
			
			for(var aabb:int = 0; aabb < AABB_DATA_LENGTH; aabb++)
			{
				_value.readFloat();
			}
			
			if( type == INANIMATE_MESH_DATA )
			{
				
				Y3DCONFIG::TRACE
				{
					trace("[Y3D_Parser] Yogurt3D Mesh File V3");
					trace("[Y3D_Parser] Exporter:", exporter);
					trace("[Y3D_Parser] upVector:", upVector);
					trace("[Y3D_Parser] vertexCount:", vertexCount);
					trace("[Y3D_Parser] triangleCount:", indexCount / 3 );
					trace("[Y3D_Parser] normalsIncluded:", true);
					trace("[Y3D_Parser] tangentsIncluded:", tangentsIncluded);
					trace("[Y3D_Parser] uvCount:", uvCount);
					trace("[Y3D_Parser] ocFactorIncluded:", ocFactorIncluded);
				}
				
				var _verticesLoop			:int;
				var _indicesLoop			:int;
				var _uvtLoop				:int;
				var len						:int;
				
				// read vertices
				_verticesData						= new Vector.<Number>(vertexCount * 3, true);
				_uvtData							= new Vector.<Number>(vertexCount * 2);
				_uvtData2							= new Vector.<Number>(vertexCount * 2);
				_uvtData3							= new Vector.<Number>(vertexCount * 2);
				_normalData							= new Vector.<Number>(vertexCount * 3);
				// read vertex positions
				len = vertexCount * 3;
				for(_verticesLoop = 0; _verticesLoop < len; _verticesLoop++)
				{
					_verticesData[_verticesLoop]			= _value.readFloat();
				}
				// read uv data
				for( uvC = 0;uvC < uvCount; uvC++)
				{
						if( uvC == 0 )
						{
							
							for(_uvtLoop = 0; _uvtLoop < vertexCount; _uvtLoop++){
								_uvtData[int(_uvtLoop * 2)]		= _value.readFloat();
								_uvtData[int(_uvtLoop * 2 + 1)]	= 1 - _value.readFloat();
							}
						}else if ( uvC == 1 ){
							for(_uvtLoop = 0; _uvtLoop < vertexCount; _uvtLoop++){
								_uvtData2[int(_uvtLoop * 2)] 	  = _value.readFloat();
								_uvtData2[int(_uvtLoop * 2 + 1)] = 1 - _value.readFloat();
							}
						}
						else{
							for(_uvtLoop = 0; _uvtLoop < vertexCount; _uvtLoop++){
								_uvtData3[int(_uvtLoop * 2)] 	  = _value.readFloat();
								_uvtData3[int(_uvtLoop * 2 + 1)] = 1 - _value.readFloat();
							}
						}
				}
				// read normal data
				for(_verticesLoop = 0; _verticesLoop < len; _verticesLoop++){
					_normalData[_verticesLoop]			= _value.readFloat();
				}
				if( tangentsIncluded ){
					_tangentData							= new Vector.<Number>(vertexCount * 3);
					for(_verticesLoop = 0; _verticesLoop < len; _verticesLoop++)
					{
						_tangentData[_verticesLoop]			= _value.readFloat();
					}
				}
				_indicesData						= new Vector.<uint>(indexCount);
				for(_indicesLoop = 0; _indicesLoop < indexCount; _indicesLoop++)
				{
					_indicesData[_indicesLoop]					= _value.readInt();
				}
				var _inanimateMesh	:Mesh	= new Mesh();
				var subMesh:SubMesh			= new SubMesh();
				subMesh.vertices			= _verticesData;
				subMesh.indices				= _indicesData;
				subMesh.normals 			= _normalData;
				subMesh.uvt					= _uvtData;
				subMesh.uvt2				= _uvtData2;
				subMesh.uvt3				= _uvtData3;
				subMesh.tangents			= _tangentData;
				_inanimateMesh.subMeshList.push( subMesh );
				return _inanimateMesh;
			}else if( type == ANIMATED_MESH_DATA )
			{
				var boneCount:int = _value.readShort();
				
				Y3DCONFIG::TRACE
				{
					trace("[Y3D_Parser] Yogurt3D Animated Mesh File");
					trace("[Y3D_Parser] Exporter:", exporter);
					trace("[Y3D_Parser] upVector:", upVector);
					trace("[Y3D_Parser] vertexCount:", vertexCount);
					trace("[Y3D_Parser] triangleCount:", indexCount / 3 );
					trace("[Y3D_Parser] normalsIncluded:", true);
					trace("[Y3D_Parser] tangentsIncluded:", tangentsIncluded);
					trace("[Y3D_Parser] uvCount:", uvCount);
					trace("[Y3D_Parser] ocFactorIncluded:", ocFactorIncluded);
					trace("[Y3D_Parser] boneCount:", boneCount);
				}
				
				var _bone:Bone;
				var _boneIndicesCount:int;
				var i:int;
				var bones:Vector.<Bone> = new Vector.<Bone>( boneCount, true );
				for( i = 0; i < boneCount; i++ )
				{
					_bone					= new Bone();
					_boneIndicesCount		= _value.readInt();
					_bone.indices 			= new Vector.<uint>(_boneIndicesCount);
					_bone.weights			= new Vector.<Number>(_boneIndicesCount);
					_bone.translation 		= new Vector3D(_value.readFloat(),_value.readFloat(),_value.readFloat());
					_bone.rotation 			= new Quaternion(_value.readFloat(),_value.readFloat(),_value.readFloat(),_value.readFloat());
					_bone.scale 			= new Vector3D( _value.readFloat(),_value.readFloat(),_value.readFloat());
					_bone.name 				= _value.readMultiByte( _value.readShort() * 2, "utf-16" );
					_bone.parentName		= _value.readMultiByte( _value.readShort() * 2, "utf-16" );
					
					for(var _boneIndicesLoop:int = 0; _boneIndicesLoop < _boneIndicesCount; _boneIndicesLoop++)
					{
						_bone.indices[_boneIndicesLoop]		= _value.readInt();
					}
					for(_boneIndicesLoop = 0; _boneIndicesLoop < _boneIndicesCount; _boneIndicesLoop++)
					{
						_bone.weights[_boneIndicesLoop]		= _value.readFloat();
					}
					bones[i] = _bone;
				}
				
				_verticesData						= new Vector.<Number>(vertexCount * 3, true);
				_uvtData							= new Vector.<Number>(vertexCount * 2);
				_uvtData2							= new Vector.<Number>(vertexCount * 2);
				_normalData							= new Vector.<Number>(vertexCount * 3);
				// read vertex positions
				len = vertexCount * 3;
				for(_verticesLoop = 0; _verticesLoop < len; _verticesLoop++)
				{
					_verticesData[_verticesLoop]			= _value.readFloat();
				}
				// read uv data
				for( uvC = 0;uvC < uvCount; uvC++)
				{
					for(_uvtLoop = 0; _uvtLoop < vertexCount; _uvtLoop++){
						if( uvC == 0 )
						{
							_uvtData[(_uvtLoop * 2)]		= _value.readFloat();
							_uvtData[(_uvtLoop * 2) + 1]	= 1 - _value.readFloat();
						}else{
							_uvtData2[(_uvtLoop * 2)] 	  = _value.readFloat();
							_uvtData2[(_uvtLoop * 2) + 1] = 1 - _value.readFloat();
						}
						//_uvtData[(_uvtLoop * 3) + 2]	= 0;
					}
				}
				// read normal data
				for(_verticesLoop = 0; _verticesLoop < len; _verticesLoop++){
					_normalData[_verticesLoop]			= _value.readFloat();
				}
				if( tangentsIncluded ){
					_tangentData							= new Vector.<Number>(vertexCount * 3);
					for(_verticesLoop = 0; _verticesLoop < len; _verticesLoop++)
					{
						_tangentData[_verticesLoop]			= _value.readFloat();
					}
				}
				_indicesData						= new Vector.<uint>(indexCount);
				for(_indicesLoop = 0; _indicesLoop < indexCount; _indicesLoop++)
				{
					_indicesData[_indicesLoop]					= _value.readInt();
				}
				
				var _animateMesh	:SkeletalAnimatedMeshBase			= new SkeletalAnimatedMeshBase();
				var skinnedSubMesh:SkinnedSubMesh = new SkinnedSubMesh();
				skinnedSubMesh.vertices				= _verticesData;
				skinnedSubMesh.indices				= _indicesData;
				skinnedSubMesh.normals 				= _normalData;
				skinnedSubMesh.uvt					= _uvtData;
				skinnedSubMesh.uvt2					= _uvtData2;
				skinnedSubMesh.tangents				= _tangentData;
				skinnedSubMesh.bones 				= bones;
				skinnedSubMesh.originalBoneIndex 	= new Vector.<uint>(bones.length);
				for( i = 0; i < bones.length; i++ )
				{
					skinnedSubMesh.originalBoneIndex[i] = i;
				}
				skinnedSubMesh.updateWeightTable();
				_animateMesh.subMeshList.push( skinnedSubMesh );
				_animateMesh.bones 					= bones;
				_animateMesh.setBindPose();
				
				if( bones.length > SkinnedSubMesh.MAX_BONE_COUNT && split )
				{
					_animateMesh = new SkinnedMeshSplitter().split(	_animateMesh );
				}
				
				return new SkeletalAnimatedMesh( _animateMesh );
				
			}
			return null;
		}
		/**
		 * 
		 * @param _value
		 * @param verbose
		 * @return 
		 * 
		 */
		private function parseY3dFormat2( _value:ByteArray, split:Boolean =  true ):*{
			
			var _verticesData			:Vector.<Number>;
			var _indicesData			:Vector.<uint>;
			var _uvtData				:Vector.<Number>;
			var _normalData				:Vector.<Number>;
			var _tangentData			:Vector.<Number>;
			
			var type:uint = _value.readShort();
			var exporter:String = _value.readMultiByte( _value.readShort() * 2, "utf-16" );
			var upVector:uint = _value.readShort();
			var vertexCount:int = _value.readInt();
			var indexCount:int = _value.readInt();
			var tangentsIncluded:Boolean = _value.readBoolean();
			
			
			
			for(var aabb:int = 0; aabb < AABB_DATA_LENGTH; aabb++)
			{
				_value.readFloat();
			}
			
			if( type == INANIMATE_MESH_DATA )
			{
				
				Y3DCONFIG::TRACE
				{
					trace("[Y3D_Parser] Yogurt3D Mesh File V2");
					trace("[Y3D_Parser] Exporter:", exporter);
					trace("[Y3D_Parser] upVector:", upVector);
					trace("[Y3D_Parser] vertexCount:", vertexCount);
					trace("[Y3D_Parser] triangleCount:", indexCount / 3 );
					trace("[Y3D_Parser] normalsIncluded:", true);
					trace("[Y3D_Parser] tangentsIncluded:", tangentsIncluded);
				}
				
				var _verticesLoop			:int;
				var _indicesLoop			:int;
				var _uvtLoop				:int;
				
				// read vertices
				_verticesData						= new Vector.<Number>(vertexCount * 3, true);
				_uvtData							= new Vector.<Number>(vertexCount * 2);
				_normalData							= new Vector.<Number>(vertexCount * 3);
				// read vertex positions
				for(_verticesLoop = 0; _verticesLoop < vertexCount; _verticesLoop++)
				{
					_verticesData[(_verticesLoop * 3)]			= _value.readFloat();
					_verticesData[(_verticesLoop * 3) + 1]		= _value.readFloat();
					_verticesData[(_verticesLoop * 3) + 2]		= _value.readFloat();
				}
				// read uv data
				for(_uvtLoop = 0; _uvtLoop < vertexCount; _uvtLoop++){
					_uvtData[(_uvtLoop * 2)]		= _value.readFloat();
					_uvtData[(_uvtLoop * 2) + 1]	= 1 - _value.readFloat();
					//_uvtData[(_uvtLoop * 3) + 2]	= 0;
				}
				// read normal data
				for(_verticesLoop = 0; _verticesLoop < vertexCount; _verticesLoop++){
					_normalData[(_verticesLoop * 3)]			= _value.readFloat();
					_normalData[(_verticesLoop * 3) + 1]		= _value.readFloat();
					_normalData[(_verticesLoop * 3) + 2]		= _value.readFloat();
				}
				if( tangentsIncluded ){
					_tangentData							= new Vector.<Number>(vertexCount * 3);
					for(_verticesLoop = 0; _verticesLoop < vertexCount; _verticesLoop++)
					{
						_tangentData[(_verticesLoop * 3)]			= _value.readFloat();
						_tangentData[(_verticesLoop * 3) + 1]		= _value.readFloat();
						_tangentData[(_verticesLoop * 3) + 2]		= _value.readFloat();
					}
				}
				_indicesData						= new Vector.<uint>(indexCount);
				for(_indicesLoop = 0; _indicesLoop < indexCount; _indicesLoop++)
				{
					_indicesData[_indicesLoop]					= _value.readInt();
				}
				var _inanimateMesh	:Mesh			= new Mesh();
				var subMesh:SubMesh					= new SubMesh();
				subMesh.vertices				= _verticesData;
				subMesh.indices				= _indicesData;
				subMesh.normals 				= _normalData;
				subMesh.uvt					= _uvtData;
				subMesh.tangents				= _tangentData;
				_inanimateMesh.subMeshList.push( subMesh );
				return _inanimateMesh;
			}else if( type == ANIMATED_MESH_DATA )
			{
				var boneCount:int = _value.readShort();
				
				Y3DCONFIG::TRACE
				{
					trace("[Y3D_Parser] Yogurt3D Animated Mesh File");
					trace("[Y3D_Parser] Exporter:", exporter);
					trace("[Y3D_Parser] upVector:", upVector);
					trace("[Y3D_Parser] vertexCount:", vertexCount);
					trace("[Y3D_Parser] triangleCount:", indexCount / 3 );
					trace("[Y3D_Parser] normalsIncluded:", true);
					trace("[Y3D_Parser] tangentsIncluded:", tangentsIncluded);
					trace("[Y3D_Parser] boneCount:", boneCount);
				}
				
				var _bone:Bone;
				var _boneIndicesCount:int;
				var i:int;
				var bones:Vector.<Bone> = new Vector.<Bone>( boneCount, true );
				for( i = 0; i < boneCount; i++ )
				{
					_bone					= new Bone();
					_boneIndicesCount		= _value.readInt();
					_bone.indices 			= new Vector.<uint>(_boneIndicesCount);
					_bone.weights			= new Vector.<Number>(_boneIndicesCount);
					_bone.translation 		= new Vector3D(_value.readFloat(),_value.readFloat(),_value.readFloat());
					_bone.rotation 			= new Quaternion(_value.readFloat(),_value.readFloat(),_value.readFloat(),_value.readFloat());
					_bone.scale 			= new Vector3D( _value.readFloat(),_value.readFloat(),_value.readFloat());
					_bone.name 				= _value.readMultiByte( _value.readShort() * 2, "utf-16" );
					_bone.parentName		= _value.readMultiByte( _value.readShort() * 2, "utf-16" );
					
					for(var _boneIndicesLoop:int = 0; _boneIndicesLoop < _boneIndicesCount; _boneIndicesLoop++)
					{
						_bone.indices[_boneIndicesLoop]		= _value.readInt();
					}
					for(_boneIndicesLoop = 0; _boneIndicesLoop < _boneIndicesCount; _boneIndicesLoop++)
					{
						_bone.weights[_boneIndicesLoop]		= _value.readFloat();
					}
					bones[i] = _bone;
				}
				
				_verticesData						= new Vector.<Number>(vertexCount * 3, true);
				_uvtData							= new Vector.<Number>(vertexCount * 2);
				_normalData							= new Vector.<Number>(vertexCount * 3);
				// read vertex positions
				for(_verticesLoop = 0; _verticesLoop < vertexCount; _verticesLoop++)
				{
					_verticesData[(_verticesLoop * 3)]			= _value.readFloat();
					_verticesData[(_verticesLoop * 3) + 1]		= _value.readFloat();
					_verticesData[(_verticesLoop * 3) + 2]		= _value.readFloat();
				}
				// read uv data
				for(_uvtLoop = 0; _uvtLoop < vertexCount; _uvtLoop++){
					_uvtData[(_uvtLoop * 2)]		= _value.readFloat();
					_uvtData[(_uvtLoop * 2) + 1]	= 1 - _value.readFloat();
				}
				// read normal data
				for(_verticesLoop = 0; _verticesLoop < vertexCount; _verticesLoop++){
					_normalData[(_verticesLoop * 3)]			= _value.readFloat();
					_normalData[(_verticesLoop * 3) + 1]		= _value.readFloat();
					_normalData[(_verticesLoop * 3) + 2]		= _value.readFloat();
				}
				if( tangentsIncluded ){
					_tangentData							= new Vector.<Number>(vertexCount * 3);
					for(_verticesLoop = 0; _verticesLoop < vertexCount; _verticesLoop++)
					{
						_tangentData[(_verticesLoop * 3)]			= _value.readFloat();
						_tangentData[(_verticesLoop * 3) + 1]		= _value.readFloat();
						_tangentData[(_verticesLoop * 3) + 2]		= _value.readFloat();
					}
				}
				_indicesData						= new Vector.<uint>(indexCount);
				for(_indicesLoop = 0; _indicesLoop < indexCount; _indicesLoop++)
				{
					_indicesData[_indicesLoop]					= _value.readInt();
				}
				
				var _animateMesh	:SkeletalAnimatedMeshBase			= new SkeletalAnimatedMeshBase();
				var skinnedSubMesh:SkinnedSubMesh = new SkinnedSubMesh();
				skinnedSubMesh.vertices				= _verticesData;
				skinnedSubMesh.indices				= _indicesData;
				skinnedSubMesh.normals 				= _normalData;
				skinnedSubMesh.uvt					= _uvtData;
				skinnedSubMesh.tangents				= _tangentData;
				skinnedSubMesh.bones 				= bones;
				skinnedSubMesh.originalBoneIndex 	= new Vector.<uint>(bones.length);
				for( i = 0; i < bones.length; i++ )
				{
					skinnedSubMesh.originalBoneIndex[i] = i;
				}
				skinnedSubMesh.updateWeightTable();
				_animateMesh.subMeshList.push( skinnedSubMesh );
				_animateMesh.bones 					= bones;
				_animateMesh.setBindPose();
				
				if( bones.length > SkinnedSubMesh.MAX_BONE_COUNT && split )
				{
					_animateMesh = new SkinnedMeshSplitter().split(	_animateMesh );
				}
				
				return new SkeletalAnimatedMesh( _animateMesh );
				
			}
			return null;
		}
		/**
		 * Parses the Y3D v1 Animated Mesh binary and returns the SkeletalAnimatedGPUMesh object having the mesh data.
		 * Resolves backward compatibilty for the old (v1) file format.
		 * @param _value 	The byte array containing the Y3D v1 Animated Mesh Data.
		 * @param verbose 	Prints file header info when set to true.
		 * @return 	SkeletalAnimatedGPUMesh object containing the animated mesh data.
		 */		
		private function parseByteArrayAsOldAnimated( _value:ByteArray ) :*{
			
			
			var _verticesData			:Vector.<Number>;
			var _indicesData			:Vector.<uint>;
			var _uvtData				:Vector.<Number>;
			
			var _verticesLoop			:int;
			var _indicesLoop			:int;
			var _texturePathLoop		:int;
			var _uvtLoop				:int;

			var _bones					:Vector.<Bone>			= new Vector.<Bone>();
			var _bone					:Bone;
			var _boneRootHeight			:Number;
			var _boneCount				:int;
			var _boneIndicesCount		:int;
			var _boneVerticesCount		:int;
			var _boneWeightCount		:int;
			var _boneTranslationX		:Number;
			var _boneTranslationY		:Number;
			var _boneTranslationZ		:Number;
			var _boneNameLength			:int;
			var _boneName				:String;
			var _boneId					:int;
			var _boneParentNameLength	:int;
			var _boneParentName			:String;
			var _boneParentId			:int;
			var _boneIndices			:Vector.<uint>;
			var _boneVertices			:Vector.<Number>;
			var _boneWeights			:Vector.<Number>;
			
			var _vertexCount			:int;
			var _indicesCount			:int;
			var _boneLoop				:int;
			var _boneNameLoop			:int;
			var _boneParentNameLoop		:int;
			var _boneIndicesLoop		:int;
			var _boneVerticesLoop		:int;
			var _boneWeightLoop			:int;
			var _textureCoordCount		:int;
			
			_vertexCount				= _value.readInt();
			_indicesCount				= _value.readInt();
			_boneRootHeight				= _value.readFloat();
			_boneCount					= _value.readInt();
			_textureCoordCount			= _value.readInt();
			
			_indicesData				= new Vector.<uint>(_indicesCount);
			_uvtData					= new Vector.<Number>(_textureCoordCount * 2);
			
			
			Y3DCONFIG::TRACE
			{
				trace("[Y3D_Parser] Yogurt3D Animated Mesh File");
				trace("[Y3D_Parser] Version:", 1);
				trace("[Y3D_Parser] Exporter:", "unknown");
				trace("[Y3D_Parser] upVector:", "unknown");
				trace("[Y3D_Parser] vertexCount:", _vertexCount);
				trace("[Y3D_Parser] triangleCount:", _indicesCount / 3 );
				trace("[Y3D_Parser] normalsIncluded:", false);
				trace("[Y3D_Parser] tangentsIncluded:", false);
				trace("[Y3D_Parser] boneCount:", _boneCount);
			}
			var _boneVertexDict:Dictionary = new Dictionary();
			for(_boneLoop = 0; _boneLoop < _boneCount; _boneLoop++) // for each bone in the file
			{
				_boneIndicesCount		= _value.readInt();
				_boneVerticesCount		= _value.readInt();
				_boneWeightCount		= _value.readInt();
				
				_boneTranslationX		= _value.readFloat();
				_boneTranslationY		= _value.readFloat();
				_boneTranslationZ		= _value.readFloat();

				// read bone name
				_boneNameLength			= _value.readInt();
				_boneName				= "";
				for(_boneNameLoop = 0; _boneNameLoop < _boneNameLength; _boneNameLoop++)
				{
					_boneName			+= _value.readMultiByte(2, "utf-16");
				}
				
				_boneId					= _value.readInt(); // not used in v2
				
				// read parent bone name
				_boneParentNameLength	= _value.readInt();
				_boneParentName			= "";
				for(_boneParentNameLoop = 0; _boneParentNameLoop < _boneParentNameLength; _boneParentNameLoop++)
				{
					_boneParentName		+= _value.readMultiByte(2, "utf-16");
				}
				
				_boneParentId	= _value.readInt();
				
				_boneIndices	= new Vector.<uint>(_boneIndicesCount, true);
				_boneVertices	= new Vector.<Number>(_boneVerticesCount*3, true);
				_boneWeights	= new Vector.<Number>(_boneWeightCount, true);
				
				for(_boneIndicesLoop = 0; _boneIndicesLoop < _boneIndicesCount; _boneIndicesLoop++)
				{
					_boneIndices[_boneIndicesLoop]		= _value.readInt();
				}
				
				for(_boneVerticesLoop = 0; _boneVerticesLoop < _boneVerticesCount * 3; _boneVerticesLoop++)
				{
					_boneVertices[_boneVerticesLoop]	= _value.readFloat();
				}
				
				for(_boneWeightLoop = 0; _boneWeightLoop < _boneWeightCount; _boneWeightLoop++)
				{
					_boneWeights[_boneWeightLoop]		= _value.readFloat();
				}
				
				_bone					= new Bone();
				
				_bone.name				= _boneName;
				_bone.parentName		= _boneParentName;
				_bone.translation		= new Vector3D(_boneTranslationX, _boneTranslationY,_boneTranslationZ);
				_bone.rotation			= new Quaternion();
				_bone.scale				= new Vector3D(1,1,1);
				_bone.indices			= _boneIndices;
				_boneVertexDict[_bone]		= _boneVertices;
				_bone.weights			= _boneWeights;
				
				_bones[_boneLoop]		= _bone;
			}
			
			for(_indicesLoop = 0; _indicesLoop < _indicesCount; _indicesLoop++)
			{
				_indicesData[_indicesLoop]	= _value.readInt();
			}
			
			// TexturePath is not supported in v2.
			_value.readInt();
			/*for(_texturePathLoop = 0; _texturePathLoop < _texturePathLength; _texturePathLoop++)
			{
				_value.readMultiByte(2, "utf-16");
			}*/
			
			for(_uvtLoop = 0; _uvtLoop < _textureCoordCount; _uvtLoop++)
			{
				_uvtData[(_uvtLoop * 2)]		= _value.readFloat();
				_uvtData[(_uvtLoop * 2) + 1]	= 1.0-_value.readFloat();
				//_uvtData[(_uvtLoop * 3) + 2]	= 0;
			}
			
 			var _animateMesh	:SkeletalAnimatedMeshBase			= new SkeletalAnimatedMeshBase();
			
			// apply skeletal deformation to the mesh using bone translations
			// note that bind pose is not defined in this old file format. only bone translations are given.
			var submesh:SkinnedSubMesh = new SkinnedSubMesh();
			submesh.indices				= _indicesData;
			submesh.uvt					= _uvtData;
			submesh.bones 					= _bones;
			
			
			var _deformedVerticesData					:Vector.<Number>			= new Vector.<Number>(_vertexCount*3, true);
			for(var i:int = 0; i < _boneCount; i++) // for each bone
			{
				_bone				= _bones[i];
				_boneVertices		= _boneVertexDict[_bone];
				_boneIndices		= _bone.indices;
				_boneIndicesCount	= _boneIndices.length;
				
				for(var j:int = 0; j < _boneIndicesCount; j++) // for each vertex this bone affects	
				{
					var _weight			:Number				= _bone.weights[j]; // weight of the vertex for this bone
					
					var _temp0			:int				= 3 * _boneIndices[j];
					var _temp1			:int				= _temp0 + 1;
					var _temp2			:int				= _temp0 + 2;
					
					var _temp3			:int				= 3 * j;
					var _temp4			:int				= _temp3 + 1;
					var _temp5			:int				= _temp3 + 2;
				
					_deformedVerticesData[_temp0]							+=	_weight * (	_boneVertices[_temp3] +	_bone.getDerivedPosition().x);
					_deformedVerticesData[_temp1]							+=	_weight * (	_boneVertices[_temp4] +	_bone.getDerivedPosition().y);
					_deformedVerticesData[_temp2]							+=	_weight * (	_boneVertices[_temp5] + _bone.getDerivedPosition().z);
				}
			}
			
			submesh.vertices				= _deformedVerticesData; // vertices after translational bone deformations are added
			submesh.updateWeightTable();
			_animateMesh.subMeshList.push( submesh );
			_animateMesh.bones = submesh.bones;
			_animateMesh.setBindPose();
			
			
			return new SkeletalAnimatedMesh( _animateMesh );
		}
		
		/**
		 * Parses the Y3D v1 Inanimate Mesh binary and returns the Mesh object.
		 * @param _value 	The byte array containing the Y3D v1 Inanimate Mesh Data.
		 * @param verbose 	Prints file header info when set to true.
		 * @return 	Mesh object containing the animated mesh data.
		 * 
		 */ 
		private function parseByteArrayAsOldInanimate(_value:ByteArray, verbose:Boolean = false):*
		{
			var _vertexCount			:int;
			var _indicesCount			:int;
			var	_textureCoordCount		:int;
			var _texturePathLength		:int;
			
			var _verticesLoop			:int;
			var _indicesLoop			:int;
			var _texturePathLoop		:int;
			var _uvtLoop				:int;
			
			var _verticesData			:Vector.<Number>;
			var _indicesData			:Vector.<uint>;
			var _uvtData				:Vector.<Number>;
			var _normalData				:Vector.<Number>;
			var _tangentData			:Vector.<Number>;
			
			var _inanimateMesh	:Mesh			= new Mesh();
			
			_vertexCount						= _value.readInt();
			_indicesCount						= _value.readInt();
			_textureCoordCount					= _value.readInt();
			
			_verticesData						= new Vector.<Number>(_vertexCount * 3, true);
			_indicesData						= new Vector.<uint>(_indicesCount);
			_uvtData							= new Vector.<Number>(_textureCoordCount * 2);
			
			Y3DCONFIG::TRACE
			{
				trace("[Y3D_Parser] Yogurt3D Mesh File");
				trace("[Y3D_Parser] Version:", 1);
				trace("[Y3D_Parser] Exporter:", "unknown");
				trace("[Y3D_Parser] upVector:", "unknown");
				trace("[Y3D_Parser] vertexCount:", _vertexCount);
				trace("[Y3D_Parser] triangleCount:", _indicesCount / 3);
				trace("[Y3D_Parser] normalsIncluded:", false);
				trace("[Y3D_Parser] tangentsIncluded:", false);
			}
			
			for(_verticesLoop = 0; _verticesLoop < _vertexCount * 3; _verticesLoop+=3)
			{
				_verticesData[(_verticesLoop )]			= _value.readFloat();
				_verticesData[(_verticesLoop ) + 1]		= _value.readFloat();
				_verticesData[(_verticesLoop ) + 2]		= _value.readFloat();
			}
			
			for(_indicesLoop = 0; _indicesLoop < _indicesCount; _indicesLoop++)
			{
				_indicesData[_indicesLoop]					= _value.readInt();
			}
			
			// TexturePath is not supported.
			_texturePathLength					= _value.readInt();
			
			for(_texturePathLoop = 0; _texturePathLoop < _texturePathLength; _texturePathLoop++)
			{
				_value.readMultiByte(2, "utf-16");
			}
			
			for(_uvtLoop = 0; _uvtLoop < _textureCoordCount; _uvtLoop++)
			{
				_uvtData[(_uvtLoop * 2)]		= _value.readFloat();
				_uvtData[(_uvtLoop * 2) + 1]	= 1 - _value.readFloat();
				//_uvtData[(_uvtLoop * 3) + 2]	= 0;
			}
			var _subMesh:SubMesh = new SubMesh();
			_subMesh.vertices				= _verticesData;
			_subMesh.indices				= _indicesData;
			//_inanimateMesh.indicesUint 			= _indicesUintData;
			_subMesh.uvt					= _uvtData;
			_inanimateMesh.subMeshList.push( _subMesh );
			return _inanimateMesh;
		}
	}
}
