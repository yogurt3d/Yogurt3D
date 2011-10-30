/*
 * MeshUtils.as
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

	
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class MeshUtils
	{
		public static function calculateVerticeTangents(_normals:Vector.<Number>):Vector.<Number> {
			var _tangents		:Vector.<Number> 	= new Vector.<Number>(_normals.length);
			var tangent:Vector3D;
			
			for( var i:int = 0; i < _normals.length; i+=3)
			{
				var normal:Vector3D = new Vector3D(_normals[i],_normals[i+1],_normals[i+2]);
				var c1:Vector3D = normal.crossProduct( Vector3D.Z_AXIS ); 
				var c2:Vector3D = normal.crossProduct( Vector3D.Y_AXIS ); 
				
				if(c1.length > c2.length)
				{
					tangent = c1;	
				}
				else
				{
					tangent = c2;	
				}
				tangent.normalize();
				_tangents[i] 	= tangent.x;
				_tangents[i+1] 	= tangent.y;
				_tangents[i+2] 	= tangent.z;
			}
			return _tangents;			
		}
		/**
		 * Calculates the vertex normals using triangle normals.
		 * <p>This method uses triangle centers to calculate vertex normals. It omits triangle areas, uses an averaging  method.</p>
		 * @param _indices Mesh indices
		 * @param _vertices Mesh vertices
		 * @return Normal list
		 * 
		 */
		public static function calculateVerticeNormals(_indices:Vector.<uint>, _vertices:Vector.<Number>):Vector.<Number> {
			
			
			var _triangleCount	:int				= _indices.length/3;
			var _v0				:Vector3D 			= new Vector3D();
			var _v1				:Vector3D 			= new Vector3D();
			var _v2				:Vector3D 			= new Vector3D();
			var _normal			:Vector3D 			= new Vector3D();
			var _3i				:int;
			
			var _normals		:Vector.<Number> 	= new Vector.<Number>(_vertices.length);
			
			for ( var i:int = 0; i < _triangleCount; i++) {
				
				_3i = 3 * i;
				
				_v1.x = _vertices[3 * _indices[_3i + 1]] 		- _vertices[3 * _indices[_3i]];
				_v1.y = _vertices[3 * _indices[_3i + 1] + 1] 	- _vertices[3 * _indices[_3i] + 1];
				_v1.z = _vertices[3 * _indices[_3i + 1] + 2] 	- _vertices[3 * _indices[_3i] + 2];
				
				_v2.x = _vertices[3 * _indices[_3i + 2]] 		- _vertices[3 * _indices[_3i]];
				_v2.y = _vertices[3 * _indices[_3i + 2] + 1] 	- _vertices[3 * _indices[_3i] + 1];
				_v2.z = _vertices[3 * _indices[_3i + 2] + 2] 	- _vertices[3 * _indices[_3i] + 2];
				
				_normal = _v1.crossProduct(_v2);
				
				_normals[3 * _indices[_3i]] 			+= _normal.x;
				_normals[3 * _indices[_3i] + 1] 		+= _normal.y;
				_normals[3 * _indices[_3i] + 2] 		+= _normal.z;
				
				_normals[3 * _indices[_3i + 1]] 		+= _normal.x;
				_normals[3 * _indices[_3i + 1] + 1] 	+= _normal.y;
				_normals[3 * _indices[_3i + 1] + 2] 	+= _normal.z;
				
				_normals[3 * _indices[_3i + 1]] 		+= _normal.x;
				_normals[3 * _indices[_3i + 1] + 1] 	+= _normal.y;
				_normals[3 * _indices[_3i + 1] + 2] 	+= _normal.z;
				
			} 
			
			var _vertexCount:int = _vertices.length;
			
			for (i = 0; i < _normals.length; i+=3) {
				
				_normal.x = _normals[i];
				_normal.y = _normals[i+1];
				_normal.z = _normals[i+2];
				
				_normal.normalize();
				
				_normals[i] 	= _normal.x;
				_normals[i+1] 	= _normal.y;
				_normals[i+2] 	= _normal.z;
				
			}
			
			return _normals;
		}
		
		public static function createVertexBufferDataAsVector(_vertexCount:uint, ... args ):Vector.<Number>//_vertices:Vector.<Number>, _normals:Vector.<Number>, _uvt:Vector.<Number>, _tangents:Vector.<Number>):Vector.<Number> {
		{
			var _bufferData:Vector.<Number> = new Vector.<Number>();
			
			for( var _vertexIndex:int = 0; _vertexIndex < _vertexCount; _vertexIndex++){
				var _len:uint = args.length;
				for( var i:int = 0; i < _len; i++ )
				{
					var listItemSpan:int = args[i].length / _vertexCount;
					for( var j:int = 0; j < listItemSpan; j++)
					{
						var x:int = _vertexIndex * listItemSpan;
						_bufferData.push( args[i][ x + j] );
					}
				}
			}
			
			return _bufferData;
		}
		
		public static function createVertexBufferDataAsByteArray(_vertices:Vector.<Number>, _normals:Vector.<Number>, _uvt:Vector.<Number>):ByteArray {
			var _bufferData		:ByteArray 	= new ByteArray();
			var _vertexCount	:int 		= _vertices.length;
			
			for( var _vertexIndex:int = 0; _vertexIndex < _vertexCount; _vertexIndex+=3){
				// xyzw
				//_bufferData.push( _vertices[_vertexIndex], _vertices[_vertexIndex+1], _vertices[_vertexIndex+2],1);
				_bufferData.writeDouble( _vertices[_vertexIndex]   );
				_bufferData.writeDouble( _vertices[_vertexIndex+1] );
				_bufferData.writeDouble( _vertices[_vertexIndex+2] );
				_bufferData.writeDouble( 1 );
				
				// uv
				//_bufferData.push( _uvt[_vertexIndex], _uvt[_vertexIndex+1] );
				_bufferData.writeDouble( _uvt[_vertexIndex]   );
				_bufferData.writeDouble( _uvt[_vertexIndex+1] );
				
				// normals xyz
				//_bufferData.push( _normals[_vertexIndex], _normals[_vertexIndex+1], _normals[_vertexIndex+2]);
				_bufferData.writeDouble( _normals[_vertexIndex]   );
				_bufferData.writeDouble( _normals[_vertexIndex+1] );
				_bufferData.writeDouble( _normals[_vertexIndex+2] );
			}
			
			return _bufferData;
		}
	}
}
