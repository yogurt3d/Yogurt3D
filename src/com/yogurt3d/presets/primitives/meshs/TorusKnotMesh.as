/*
 * TorusKnotMesh.as
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
	
	public class TorusKnotMesh extends Mesh
	{
		public function TorusKnotMesh(_radius:Number  = 100.0, _tubeRadius:Number = 40.0, _segmentsR:uint = 8, 
								  _segmentsT:uint = 6, _yUp:Boolean = false, _p:uint = 2, _q:uint = 3,_heightScale:Number = 1)
		{
			super();
			
			createKnotTorus(_radius, _tubeRadius, _segmentsR,_segmentsT, _yUp, _p, _q, _heightScale);
			
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, TorusKnotMesh);
		}
		
		private function createKnotTorus(_radius:Number, _tubeRadius:Number, _segmentsR:uint, _segmentsT:uint, _yUp:Boolean, 
										 _p:uint, _q:uint, _heightScale:Number):void{
			
			var _vertices		:Vector.<Number>			= new Vector.<Number>();
			var _indices		:Vector.<uint>				= new Vector.<uint>();
			var _verticesIndex	:int						= 0;
			var _indiceIndex	:int						= 0;
			var _grid			:Array 						= new Array(_segmentsR);		
			var _tang 			:Vector3D 					= new Vector3D();
			var _n 				:Vector3D 					= new Vector3D();
			var _bitan 			:Vector3D 					= new Vector3D();
			
			var i:int;
			var j:int;
					
			for (i = 0; i < _segmentsR; i++) {
				
				_grid[i] = new Array(_segmentsT);
				
				for (j = 0; j < _segmentsT; j++) {
					
					var u:Number = i / _segmentsR * 2 * _p * Math.PI;
					var v:Number = j / _segmentsT * 2 * Math.PI;
					var p  : Vector3D = getPos(_radius, _p, _q, _heightScale, u, v);
					var p2 : Vector3D = getPos(_radius, _p, _q, _heightScale, u + .01, v);
					var cx : Number, cy : Number;
					
					_tang.x = p2.x - p.x; _tang.y = p2.y - p.y; _tang.z = p2.z - p.z;
					_n.x = p2.x + p.x; _n.y = p2.y + p.y; _n.z = p2.z + p.z; 
					_bitan = _n.crossProduct(_tang);
					_n = _tang.crossProduct(_bitan);
					_bitan.normalize();
					_n.normalize();
					
					cx = _tubeRadius * Math.cos(v); cy = _tubeRadius * Math.sin(v);
					p.x += cx * _n.x + cy * _bitan.x;
					p.y += cx * _n.y + cy * _bitan.y;
					p.z += cx * _n.z + cy * _bitan.z;
	
					if (_yUp){
						_vertices[_verticesIndex] 		= p.x;
						_vertices[_verticesIndex + 1] 	= p.z;
						_vertices[_verticesIndex + 2] 	= p.y;
						
						_grid[i][j] = _indiceIndex;
						_indiceIndex++;
						_verticesIndex += 3;
					
					}
					else{
						_vertices[_verticesIndex] 		= p.x;
						_vertices[_verticesIndex + 1] 	= -p.y;
						_vertices[_verticesIndex + 2] 	= p.z;
						
						_grid[i][j] = _indiceIndex;
						_indiceIndex++;
						_verticesIndex += 3;
						
					}
					
				}
			}
			
			var _uvt:Vector.<Number> = new Vector.<Number>(_indiceIndex * 2);
			
			for (i = 0; i < _segmentsR; i++) {
				for (j = 0; j < _segmentsT; j++) {
					
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
		
		private function getPos(_radius : Number, _p : uint, _q : uint, _heightScale : Number, _u : Number, _v : Number) : Vector3D
		{
			var cu : Number = Math.cos(_u);
			var su : Number = Math.sin(_u);
			var quOverP : Number = _q/_p*_u;
			var cs : Number = Math.cos(quOverP);
			var pos : Vector3D = new Vector3D();
			
			pos.x = _radius*(2+cs)*.5 * cu;
			pos.y = _radius*(2+cs)*su*.5;
			pos.z = _heightScale*_radius*Math.sin(quOverP)*.5;
			
			return pos;
		}
		
	}
}