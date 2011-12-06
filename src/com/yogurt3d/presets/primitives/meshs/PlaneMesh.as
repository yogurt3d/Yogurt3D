/*
 * PlaneMesh.as
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
	public class PlaneMesh extends Mesh
	{
		public function PlaneMesh( _width:Number = 1.0, _height:Number = 1.0, _hSegments:int = 1, _vSegments:int = 1, _normalX:Number = 0.0, _normalY:Number = 1.0, _normalZ:Number = 0.0 )
		{
			super();
			
			createPlane( _width, _height, _hSegments, _vSegments, _normalX, _normalY, _normalZ );
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, PlaneMesh);
		}
		
		private function createPlane( _width:Number, _height:Number, _hSegments:int, _vSegments:int, _normalX:Number, _normalY:Number, _normalZ:Number ):void
		{
		
			var x:Number, y:Number;
			var vIndex:uint, iIndex:uint;
		
			var indiceConstant:uint = _vSegments + 1;
			var nbVertices:uint = (_hSegments + 1) * indiceConstant;
			var numUV : uint = (_hSegments + 1) * (_vSegments + 1) * 2;
			
			var _vertices			:Vector.<Number> = new Vector.<Number>(nbVertices * 3, true);
			var _normals			:Vector.<Number> = new Vector.<Number>(nbVertices * 3, true);
			var _tangents			:Vector.<Number> = new Vector.<Number>(nbVertices * 3, true);
			var _indices			:Vector.<uint>	 = new Vector.<uint>  (_hSegments * _vSegments * 6, true);
			var _uvt				:Vector.<Number> = new Vector.<Number>(numUV, true);

			nbVertices = 0;
			numUV = 0;
			
			for (var yi : uint = 0; yi <= _hSegments; ++yi) {
				for (var xi : uint = 0; xi <= _vSegments; ++xi) {
					
					x = (xi/_vSegments-.5)*_width;
					y = (yi/_hSegments-.5)*_height;
					
					_vertices[nbVertices] 	= x;
					_normals[nbVertices] 	= 0;
					_tangents[nbVertices++] = 1;
				
					_vertices[nbVertices] 	= 0;
					_normals[nbVertices] 	= 1;
					_tangents[nbVertices++] = 0;
						
					_vertices[nbVertices] 	= y;
					_normals[nbVertices] 	= 0;
					_tangents[nbVertices++] = 0;
					
					if (xi != _vSegments && yi != _hSegments) {
						iIndex = xi + yi*indiceConstant;
						_indices[vIndex++] = iIndex;
						_indices[vIndex++] = iIndex + indiceConstant;
						_indices[vIndex++] = iIndex + indiceConstant + 1;
						_indices[vIndex++] = iIndex;
						_indices[vIndex++] = iIndex + indiceConstant + 1;
						_indices[vIndex++] = iIndex + 1;
					}
				}
			}

			for (yi = 0; yi <= _hSegments; ++yi) {
				for (xi = 0; xi <= _vSegments; ++xi) {
					_uvt[numUV++] = clamp( xi/_vSegments, 0.05, 0.95 );
					_uvt[numUV++] = clamp( yi/_hSegments, 0.05, 0.95 );
				}
			}
			var subMesh:SubMesh = new SubMesh();
			
			subMesh.vertices			= _vertices;
			subMesh.indices				= _indices;
			subMesh.normals				= _normals;
			subMesh.tangents			= _tangents;
			subMesh.uvt					= _uvt;
			
			subMeshList.push( subMesh );
			
		}
		
		private function clamp(val:Number, min:Number = 0, max:Number = 1):Number{
			return Math.max(min, Math.min(max, val))
		}

	}
}
