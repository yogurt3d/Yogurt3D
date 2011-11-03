/*
* Sprite3D.as
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
	public class Sprite3D extends Mesh
	{
		
		public function Sprite3D( _width:Number = 10.0, _height:Number = 10.0)
		{
			super();
			
			createSprite3D( _width, _height);
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, Sprite3D);
		}
		
		private function createSprite3D( _width:Number, _height:Number):void
		{
			
			var _vertices		:Vector.<Number> = new Vector.<Number>();
			var _normals		:Vector.<Number> = new Vector.<Number>();
			var _tangents		:Vector.<Number> = new Vector.<Number>();
			var _uvt			:Vector.<Number> = new Vector.<Number>();
			var _indices		:Vector.<uint>   = new Vector.<uint>();
						
			_vertices.push(	-1.0 * _width, 1.0  * _height, 0.0, 
							-1.0 * _width, -1.0 * _height, 0.0, 
							1.0  * _width, -1.0 * _height, 0.0, 
							1.0  * _width, 1.0  * _height, 0.0);
			
	
			_uvt.push(0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0);
			_indices.push(0, 1, 2, 0, 2, 3);
			_normals.push(.0, .0, -1.0, .0, .0, -1.0, .0, .0, -1.0, .0, .0, -1.0);
			_tangents.push(1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0);

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
