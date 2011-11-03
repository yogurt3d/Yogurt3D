/*
 * BoxMesh.as
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
 
 
package com.yogurt3d.presets.primitives.meshs
{
	import com.yogurt3d.core.geoms.Mesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	
	import flash.display.*;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class BoxMesh extends Mesh
	{
		public function BoxMesh( _width:Number = 10.0, _height:Number = 10.0, _length:Number = 10.0, _widthSegments:int = 5, _heightSegments:int = 5, _lengthSegments:int = 5 )
		{
			super();
			createBox( _width, _height, _length, _widthSegments, _heightSegments, _lengthSegments);
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, BoxMesh);
		}
		
		private function createBox( _width:Number, _height:Number, _depth:Number, _widthSegments:int, _heightSegments:int, _depthSegments:int ):void
		{
		
			var numVertices : uint = 	((_widthSegments + 1) * (_heightSegments + 1)  +
										 (_widthSegments + 1) * (_depthSegments + 1)   +
				                         (_heightSegments + 1) * (_depthSegments + 1)) * 2;
			
			var _vertices		:Vector.<Number>		= new Vector.<Number>(numVertices * 3, true);
			var _indices		:Vector.<uint>			= new Vector.<uint>((_widthSegments*_heightSegments + _widthSegments*_depthSegments + _heightSegments*_depthSegments)*12, true);
			var _normals		:Vector.<Number>		= new Vector.<Number>(numVertices * 3, true);
			var _tangents		:Vector.<Number>		= new Vector.<Number>(numVertices * 3, true);
			
			var topLeft:uint, topRight:uint, bottomLeft:uint, bottomRight:uint;
			var vertexIndex:uint = 0, indiceIndex:uint = 0; 
			var outerPosition : Number;
			var i:uint, j:uint, increment:uint = 0;
			
			var deltaW:Number = _width/_widthSegments;
			var deltaH:Number = _height/_heightSegments;
			var deltaD:Number = _depth/_depthSegments;
			var halW:Number = _width/2 , halH:Number = _height/2 , halD:Number = _depth/2;
				
			// Front & Back faces
			for (i = 0; i <= _widthSegments; i++) {
				
				outerPosition = -halW + i*deltaW;
				
				for (j = 0; j <= _heightSegments; j++) {
				
					_normals[vertexIndex] 		= 0;
					_tangents[vertexIndex] 		= 1;
					_vertices[vertexIndex++] 	= outerPosition;
					_normals[vertexIndex] 		= 0;
					_tangents[vertexIndex] 		= 0;
					_vertices[vertexIndex++] 	= -halH + j*deltaH;
					_normals[vertexIndex] 		= -1;
					_tangents[vertexIndex] 		= 0;
					_vertices[vertexIndex++] 	= -halD;
					
					
					_normals[vertexIndex] 		= 0;
					_tangents[vertexIndex]		= -1;
					_vertices[vertexIndex++] 	= outerPosition;
					_normals[vertexIndex] 		= 0;
					_tangents[vertexIndex] 		= 0;
					_vertices[vertexIndex++] 	= -halH + j*deltaH;
					_normals[vertexIndex] 		= 1;
					_tangents[vertexIndex] 		= 0;
					_vertices[vertexIndex++] 	= halD;
					
					if (i && j) {
						topLeft 	= 2 * ((i-1) * (_heightSegments + 1) + (j-1));
						topRight 	= 2 * (i * (_heightSegments + 1) + (j-1));
						bottomLeft 	= topLeft + 2;
						bottomRight = topRight + 2;
						
						_indices[indiceIndex++] = topLeft;
						_indices[indiceIndex++] = bottomLeft;
						_indices[indiceIndex++] = bottomRight;
						_indices[indiceIndex++] = topLeft;
						_indices[indiceIndex++] = bottomRight;
						_indices[indiceIndex++] = topRight;
						_indices[indiceIndex++] = topRight + 1;
						_indices[indiceIndex++] = bottomRight + 1;
						_indices[indiceIndex++] = bottomLeft + 1;
						_indices[indiceIndex++] = topRight + 1;
						_indices[indiceIndex++] = bottomLeft + 1;
						_indices[indiceIndex++] = topLeft + 1;
					}
				}
			}
			
			increment += 2*(_widthSegments + 1)*(_heightSegments + 1);
			
			// Top & Bottom faces
			for (i = 0; i <= _widthSegments; i++) {
				outerPosition = -halW + i*deltaW;
				
				for (j = 0; j <= _depthSegments; j++) {
			
					_normals[vertexIndex] 		= 0;
					_tangents[vertexIndex] 		= 1;
					_vertices[vertexIndex++] 	= outerPosition;
					_normals[vertexIndex] 		= 1;
					_tangents[vertexIndex] 		= 0;
					_vertices[vertexIndex++] 	= halH;
					_normals[vertexIndex] 		= 0;
					_tangents[vertexIndex] 		= 0;
					_vertices[vertexIndex++] 	= -halD + j*deltaD;
					
					_normals[vertexIndex] 		= 0;
					_tangents[vertexIndex] 		= 1;
					_vertices[vertexIndex++] 	= outerPosition;
					_normals[vertexIndex] 		= -1;
					_tangents[vertexIndex] 		= 0;
					_vertices[vertexIndex++] 	= -halH;
					_normals[vertexIndex] 		= 0;
					_tangents[vertexIndex] 		= 0;
					_vertices[vertexIndex++] 	= -halD + j*deltaD;
					
					if (i && j) {
						topLeft = increment + 2 * ((i-1) * (_depthSegments + 1) + (j-1));
						topRight = increment + 2 * (i * (_depthSegments + 1) + (j-1));
						bottomLeft = topLeft + 2;
						bottomRight = topRight + 2;
						
						_indices[indiceIndex++] = topLeft;
						_indices[indiceIndex++] = bottomLeft;
						_indices[indiceIndex++] = bottomRight;
						_indices[indiceIndex++] = topLeft;
						_indices[indiceIndex++] = bottomRight;
						_indices[indiceIndex++] = topRight;
						_indices[indiceIndex++] = topRight + 1;
						_indices[indiceIndex++] = bottomRight + 1;
						_indices[indiceIndex++] = bottomLeft + 1;
						_indices[indiceIndex++] = topRight + 1;
						_indices[indiceIndex++] = bottomLeft + 1;
						_indices[indiceIndex++] = topLeft + 1;
					}
				}
			}
			
			increment += 2*(_widthSegments + 1)*(_depthSegments + 1);
			
			//Left & Right faces
			for (i = 0; i <= _heightSegments; i++) {
				outerPosition = -halH + i*deltaH;
				
				for (j = 0; j <= _depthSegments; j++) {
			
					_normals[vertexIndex] 		= -1;
					_tangents[vertexIndex] 		= 0;
					_vertices[vertexIndex++] 	= -halW;
					_normals[vertexIndex]		= 0;
					_tangents[vertexIndex] 		= 0;
					_vertices[vertexIndex++] 	= outerPosition;
					_normals[vertexIndex] 		= 0;
					_tangents[vertexIndex] 		= -1;
					_vertices[vertexIndex++] 	= -halD + j*deltaD;
					
					_normals[vertexIndex] 		= 1;
					_tangents[vertexIndex] 		= 0;
					_vertices[vertexIndex++] 	= halW;
					_normals[vertexIndex] 		= 0;
					_tangents[vertexIndex] 		= 0;
					_vertices[vertexIndex++] 	= outerPosition;
					_normals[vertexIndex] 		= 0;
					_tangents[vertexIndex] 		= 1;
					_vertices[vertexIndex++] 	= -halD + j*deltaD;
					
					if (i && j) {
						topLeft 		= increment + 2 * ((i-1) * (_depthSegments + 1) + (j-1));
						topRight 		= increment + 2 * (i * (_depthSegments + 1) + (j-1));
						bottomLeft 		= topLeft + 2;
						bottomRight 	= topRight + 2;
						
						_indices[indiceIndex++] = topLeft;
						_indices[indiceIndex++] = bottomLeft;
						_indices[indiceIndex++] = bottomRight;
						_indices[indiceIndex++] = topLeft;
						_indices[indiceIndex++] = bottomRight;
						_indices[indiceIndex++] = topRight;
						_indices[indiceIndex++] = topRight+1;
						_indices[indiceIndex++] = bottomRight + 1;
						_indices[indiceIndex++] = bottomLeft + 1;
						_indices[indiceIndex++] = topRight + 1;
						_indices[indiceIndex++] = bottomLeft + 1;
						_indices[indiceIndex++] = topLeft + 1;
					}
				}
			}
			
			//UVTs
			var numUvs : uint = ((_widthSegments + 1) * (_heightSegments + 1)  +
								 (_widthSegments + 1) * (_depthSegments + 1)   +
								 (_heightSegments + 1) * (_depthSegments + 1)) * 4;
			
			var _uvt:Vector.<Number>		= new Vector.<Number>(numUvs, true);
			var uvIndex:uint = 0;
	
			for (i = 0; i <= _widthSegments; i++) {
				outerPosition = (i/_widthSegments);
				
				for (j = 0; j <= _heightSegments; j++) {
					_uvt[uvIndex++] = outerPosition;
					_uvt[uvIndex++] = 1 - (j/_heightSegments);
					_uvt[uvIndex++] = 1 - outerPosition;
					_uvt[uvIndex++] = 1 - (j/_heightSegments);
				}
			}
			
			for (i = 0; i <= _widthSegments; i++) {
				outerPosition = (i/_widthSegments);
				
				for (j = 0; j <= _depthSegments; j++) {
					_uvt[uvIndex++] = outerPosition;
					_uvt[uvIndex++] = 1 - (j/_depthSegments);
					_uvt[uvIndex++] = outerPosition;
					_uvt[uvIndex++] = j/_depthSegments;
				}
			}
			
			for (i = 0; i <= _heightSegments; i++) {
				outerPosition =  (i/_heightSegments);
				
				for (j = 0; j <= _depthSegments; j++) {
					_uvt[uvIndex++] = 1 - (j/_depthSegments);
					_uvt[uvIndex++] = 1 - outerPosition;
					_uvt[uvIndex++] = j/_depthSegments;
					_uvt[uvIndex++] = 1 - outerPosition;
				}
			}

			var subMesh:SubMesh = new SubMesh();
			
			subMesh.vertices			= _vertices;
			subMesh.indices				= _indices;
			subMesh.normals 			= _normals;
			subMesh.tangents			= _tangents;
			subMesh.uvt					= _uvt;
			
			subMeshList.push( subMesh );
			
		}
	}
}
