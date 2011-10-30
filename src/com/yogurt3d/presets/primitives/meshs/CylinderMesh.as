/*
 * CylinderMesh.as
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
	public class CylinderMesh extends Mesh
	{
		public function CylinderMesh( _radius:Number = 5.0, _height:Number = 10.0, _parallels:int = 1, _meridians:int = 16 )
		{
			super();
			
			createCylinder( _radius, _height, _parallels, _meridians);
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, CylinderMesh);
		}
		
		private function createCylinder( _radius:Number, _height:Number, _parallels:int, _meridians:int ):void
		{
	//		var _verticesLength : int										= _meridians * (_parallels + 1) + 2;
			
			var _vertices		:Vector.<Number>							= new Vector.<Number>();
			var _indices		:Vector.<uint>								= new Vector.<uint>();
			var _uvt			:Vector.<Number>							= new Vector.<Number>();
			
			_vertices[0] = 0;
			_vertices[1] = 0;
			_vertices[2] = 0;
			
			for(var j:int = 0; j <= _parallels; j++)
			{
				for(var i:int = 0; i < _meridians; i++)
				{
					_vertices.push(_radius * Math.cos( Math.PI * 2 / _meridians * i));
					_vertices.push(j * (_height / _parallels));
					_vertices.push(_radius * Math.sin( Math.PI * 2 / _meridians * i));
				}
			}
			
			_vertices.push(0);
			_vertices.push(_height);
			_vertices.push(0);
			
			
			for(i = 0; i < _vertices.length; i++)
			{
				_vertices[i] = int(_vertices[i]*100) / 100; 
			}
			
			////////
			for(i = 0; i < _meridians-1; i++)
			{
				_indices.push(0);
				_indices.push(i+1);
				_indices.push(i+2);
			}
			
			_indices.push(0);
			_indices.push(_meridians);
			_indices.push(1);
			
			////////
			
			for(j = 0; j < _parallels; j++)
			{
				for(i = 0; i < _meridians-1; i++)
				{
					_indices.push(i+1+(j * _meridians));
					_indices.push(i+_meridians+1+(j * _meridians));
					_indices.push(i+2+(j * _meridians));
				}
				
				_indices.push(_meridians+(j * _meridians));
				_indices.push(_meridians*2+(j * _meridians));
				_indices.push(1+(j * _meridians));
	
				
				for(i = 0; i < _meridians-1; i++)
				{
					_indices.push(i+_meridians+2+(j * _meridians));
					_indices.push(i+2+(j * _meridians));
					_indices.push(i+_meridians+1+(j * _meridians));
				}
				
				_indices.push(_meridians+1+(j * _meridians));
				_indices.push(1+(j * _meridians));
				_indices.push(_meridians*2+(j * _meridians));
			}
			
			//////////
			for(i = 0; i < _meridians-1; i++)
			{
				_indices.push((_meridians*(_parallels+1))+1);
				_indices.push((_meridians*_parallels)+i+2);
				_indices.push((_meridians*_parallels)+i+1);
			}
			
			_indices.push((_meridians*(_parallels+1))+1);
			_indices.push(_meridians*_parallels+1);
			_indices.push(_meridians*(_parallels+1));
			
			

		//	trace(_indices);
			//	trace(i);
			
			_uvt.push(0.5);
			_uvt.push(0.5);
			//_uvt.push(0);
			
			for(j = 0; j <= _parallels; j++)
			{
				for(i = 0; i < _meridians; i++)
				{
					_uvt.push(i / _meridians);
					_uvt.push(j / _parallels);
					//_uvt.push(0);
				}
			}
			
			_uvt.push(0.5);
			_uvt.push(0.5);
			//_uvt.push(0);
			
			/*for(i = 0; i < _vertices.length; i++)
			{
				_uvt.push(i/_vertices.length);
				_uvt.push(i/_vertices.length);
				_uvt.push(0);
			}*/
			
			var subMesh:SubMesh = new SubMesh();
			
			subMesh.vertices			= _vertices;
			subMesh.indices				= _indices;
			//indicesUint 		= _indicesUint;
			subMesh.uvt					= _uvt;
			
			subMeshList.push( subMesh );
			
		}
	}
}
