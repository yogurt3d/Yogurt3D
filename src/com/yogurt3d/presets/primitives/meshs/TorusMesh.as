/*
 * TorusMesh.as
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

	import flash.geom.*;
	
	public class TorusMesh extends Mesh
	{
	
		public function TorusMesh(_radius:Number  = 100.0, _tubeRadius:Number = 40.0, _segmentsR:uint = 8, 
										 _segmentsT:uint = 6, _yUp:Boolean = false)
		{
			super();
			
			createTorus(_radius, _tubeRadius, _segmentsR,_segmentsT, _yUp);
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, TorusMesh);
		}
		
		private function createTorus(_radius:Number, _tubeRadius:Number, _segmentsR:uint, _segmentsT:uint, _yUp:Boolean):void{
			
			var _vertices		:Vector.<Number>			= new Vector.<Number>();
			var _indices		:Vector.<uint>				= new Vector.<uint>();
			var _verticesIndex	:int						= 0;
			var _indiceIndex	:int						= 0;
			var _grid			:Array 						= new Array(_segmentsR);		
			
			
			for (var i:uint = 0; i < _segmentsR; i++) {
				_grid[i] = new Array(_segmentsT);
				for (var j:uint = 0; j < _segmentsT; j++) {
					
					var u:Number = i / _segmentsR * 2 * Math.PI;
					var v:Number = j / _segmentsT * 2 * Math.PI;
					
					if (_yUp){
					
						_vertices[_verticesIndex] 		= (_radius + _tubeRadius * Math.cos(v)) * Math.cos(u);
						_vertices[_verticesIndex + 1]	= _tubeRadius * Math.sin(v);
						_vertices[_verticesIndex + 2]	= (_radius + _tubeRadius * Math.cos(v)) * Math.sin(u);
					
						_grid[i][j] = _indiceIndex;
						_indiceIndex++;
						_verticesIndex += 3;
					}
					else{
						_vertices[_verticesIndex] 		= (_radius + _tubeRadius * Math.cos(v)) * Math.cos(u);
						_vertices[_verticesIndex + 1]	= -(_radius + _tubeRadius * Math.cos(v)) * Math.sin(u);
						_vertices[_verticesIndex + 2]	=  _tubeRadius * Math.sin(v);
						
						_grid[i][j] = _indiceIndex;
						_indiceIndex++;
						_verticesIndex += 3;
					}
				}
			}
		
			var _uvt:Vector.<Number> = new Vector.<Number>(_indiceIndex * 2);
			
			for (i = 0; i < _segmentsR; ++i) {
				for (j = 0; j < _segmentsT; ++j) {
					
					var ip:int = (i+1) % _segmentsR;
					var jp:int = (j+1) % _segmentsT;
					var a:uint = _grid[i][j]; 
					var b:uint = _grid[ip][j];
					var c:uint = _grid[i][jp]; 
					var d:uint = _grid[ip][jp];
					
					// uvt
					_uvt[a * 2] 	= i/_segmentsR;
					_uvt[a * 2 + 1] = j/_segmentsT;
					
					_uvt[b * 2] 	= (i+1)/_segmentsR;
					_uvt[b * 2 + 1] = j/_segmentsT;
					
					_uvt[c * 2] 	= i/_segmentsR;
					_uvt[c * 2 + 1] = (j+1)/_segmentsT;
					
					_uvt[d * 2] 	= (i+1)/_segmentsR;
					_uvt[d * 2 + 1] = (j+1)/_segmentsT;
					
					//indices
					_indices.push(a,c,b);
					_indices.push(d,b,c);
			
				}
			}
			
			var subMesh:SubMesh = new SubMesh();
			
			subMesh.vertices			= _vertices;
			subMesh.indices				= _indices;
			subMesh.uvt					= _uvt;
			
			subMeshList.push( subMesh );	
		}
	}
}