/*
 * ConeMesh.as
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
	public class ConeMesh extends Mesh
	{
		public function ConeMesh( _radius:Number = 5.0, _height:Number = 10.0, _meridians:int = 16 )
		{
			super();
			
			createCone( _radius, _height, _meridians);
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, ConeMesh);
		}
		
		private function createCone( _radius:Number, _height:Number, _meridians:int ):void
		{
			var _vertex_no : int										= 0;
			
			var _verticesLength : int									= _meridians + 2;
			var _indicesLength : int									= _meridians * 2;
			
			var _vertices	:Vector.<Number>							= new Vector.<Number>();
			var _indices	:Vector.<uint>								= new Vector.<uint>();
			var _uvt		:Vector.<Number>							= new Vector.<Number>();
			
			_vertices[0] = 0;
			_vertices[1] = 0;
			_vertices[2] = 0;
			
			for(var i:int = 0; i < _meridians; i++)
			{
				_vertices.push(_radius * Math.cos( Math.PI * 2 / _meridians * _vertex_no));
				_vertices.push(0);
				_vertices.push(_radius * Math.sin( Math.PI * 2 / _meridians * _vertex_no));
				_vertex_no++;
			}
			
			_vertices.push(0);
			_vertices.push(_height);
			_vertices.push(0);
			
			_vertex_no = 0;

			for(i = 0; i < _meridians-1; i++)
			{
				_indices.push(0);
				_indices.push(_vertex_no+1);
				_indices.push(_vertex_no+2);
				_vertex_no++;
			}
			
			_indices.push(0);
			_indices.push(_vertex_no+1);
			_indices.push(1);
			
			_vertex_no = 1;
			
			for(i = 0; i < _meridians-1; i++)
			{
				_indices.push(_vertex_no);
				_indices.push(_meridians+1);
				_indices.push(_vertex_no+1);
				_vertex_no++;
			}
			
			_indices.push(_vertex_no);
			_indices.push(_meridians+1);
			_indices.push(1);
			
			_uvt.push(0.5);
			_uvt.push(0.5);
			//_uvt.push(0);
			
			for(i = 0; i < _verticesLength/2; i++)
			{
				_uvt.push(1);
				_uvt.push(0);
				//_uvt.push(0);
			}
			
			for(i = 0; i < _verticesLength/2; i++)
			{
				_uvt.push(i / _meridians);
				_uvt.push(0);
				//_uvt.push(0);
			}
			
			_uvt.push(0.5);
			_uvt.push(1);
			//_uvt.push(0);
			
			var subMesh:SubMesh = new SubMesh();
			
			subMesh.vertices			= _vertices;
			subMesh.indices				= _indices;
			//indicesUint 		= _indicesUint;
			subMesh.uvt					= _uvt;
			
			subMeshList.push( subMesh );
			
		}
	}
}
