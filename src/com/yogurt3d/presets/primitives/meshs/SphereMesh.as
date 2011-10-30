/*
 * SphereMesh.as
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
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class SphereMesh extends Mesh
	{
		public function SphereMesh(_radius:Number = 1.0, _parallels:int = 16, _meridians:int = 16, _uvScale:Number = 1)
		{
			super();
			
			createSphere(_radius, _parallels, _meridians, _uvScale);
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, SphereMesh);
		}
		
		private function createSphere(_radius:Number, _segmentW:int, _segmentH:int, _uvScale:Number):void
		{
			
			if(_segmentW < 3) _segmentW	= 3;
			if(_segmentH < 3) _segmentH	= 3;
			
			var numVertices : uint = (_segmentW + 1) * (_segmentH + 1);
			var numUvs : uint = (_segmentH + 1) * (_segmentW + 1) * 2;
			
			var _vertices		:Vector.<Number>	= new Vector.<Number>(numVertices * 3, true);
			var _indices		:Vector.<uint>		= new Vector.<uint>((_segmentH - 1) * _segmentW * 6, true);
			var _normals		:Vector.<Number>	= new Vector.<Number>(numVertices * 3, true);
			var _tangents		:Vector.<Number>	= new Vector.<Number>(numVertices * 3, true);
			var _uvt			:Vector.<Number>	= new Vector.<Number>(numUvs, true);
			
			var i : uint, j : uint, indIndex : uint;
			numVertices = 0;
			
			for (j = 0; j <= _segmentW; ++j) {
				
				var horizontalAng:Number = Math.PI * j / _segmentH;
				var sinRadius:Number     = _radius * Math.sin(horizontalAng);
				var z:Number 		     = -_radius * Math.cos(horizontalAng);
				
				for (i = 0; i <= _segmentH; ++i) {
					
					var verticalAngle:Number = 2 * Math.PI * i / _segmentW;
					var x:Number 			 = sinRadius * Math.cos(verticalAngle);
					var y:Number             = sinRadius * Math.sin(verticalAngle);
					var normLen:Number	 	 = 1 / Math.sqrt(x * x + y * y + z * z);
					var tanLen:Number        = Math.sqrt(y * y + x * x);
					
					_normals[numVertices] 		= x * normLen;
					_tangents[numVertices] 		= tanLen > .007 ? -y / tanLen : 1;
					_vertices[numVertices++] 	= x;
					
					_normals[numVertices] 		= -z * normLen;
					_tangents[numVertices] 		= 0;
					_vertices[numVertices++] 	= -z;
					
					_normals[numVertices] 		= y * normLen;
					_tangents[numVertices] 		= tanLen > .007 ? x / tanLen : 0;
					_vertices[numVertices++] 	= y;
					
					if (i > 0 && j > 0) {
						var a : int = (_segmentW + 1) * j + i;
						var b : int = (_segmentW + 1) * j + i - 1;
						var c : int = (_segmentW + 1) * (j - 1) + i - 1;
						var d : int = (_segmentW + 1) * (j - 1) + i;
						
						if (j == _segmentH) {
							
							_indices[indIndex++] = a;
							_indices[indIndex++] = c;
							_indices[indIndex++] = d;
							
						}
						else if (j == 1) {
							_indices[indIndex++] = a;
							_indices[indIndex++] = b;
							_indices[indIndex++] = c;
							
						}
						else {
							
							_indices[indIndex++] = a;
							_indices[indIndex++] = b;
							_indices[indIndex++] = c;
							_indices[indIndex++] = a;
							_indices[indIndex++] = c;
							_indices[indIndex++] = d;	
						}
					}
				}
			}
			
			numUvs = 0;
			for (j = 0; j <= _segmentH; ++j) {
				for (i = 0; i <= _segmentW; ++i) {
					_uvt[numUvs++] = (i / _segmentW) * _uvScale;
					_uvt[numUvs++] = (j / _segmentH) * _uvScale;
				}
			}
			
			var subMesh:SubMesh = new SubMesh();
			
			subMesh.vertices	= _vertices;
			subMesh.indices		= _indices;
			subMesh.tangents	= _tangents;
			subMesh.normals		= _normals;
			subMesh.uvt			= _uvt;
			
			subMeshList.push( subMesh );
			
		}
	}
}
