/*
 * SkyBox.as
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
 
 
package com.yogurt3d.core.sceneobjects
{
	import com.yogurt3d.core.geoms.Mesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.materials.MaterialSkyBox;
	import com.yogurt3d.core.texture.CubeTextureMap;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class SkyBox extends SceneObjectRenderable
	{
		private var m_texture:CubeTextureMap;
		
		public function SkyBox(_texture:CubeTextureMap, _size:Number=100.0)
		{
			pickEnabled = false;
			var size:Number = _size / 2;
			var subMesh:SubMesh = new SubMesh();
			
			this.geometry = new Mesh();
			this.geometry.subMeshList.push( subMesh );
			subMesh.vertices = Vector.<Number>([
				-size, -size, size,
				-size, size, size,
				size, -size, size,
				size, size, size,
				-size, size, -size, 
				size, size, -size,
				-size, -size, -size,
				size, -size, -size,
				-size, -size, size,
				size, -size, size,
				size, -size, -size,
				size, size, -size,
				-size, -size, -size,
				-size, size, -size
			]);
			
			var i:int = 0;
			
			subMesh.indices = Vector.<uint>([0, 1, 2, 2, 1, 3, 1, 4, 3, 3, 4, 5, 4, 6, 5, 5, 6, 7, 6, 8, 7, 7, 8, 9, 2, 3, 10, 10, 3, 11, 12, 13, 0, 0, 13, 1 ]);
			subMesh.uvt = new Vector.<Number>( subMesh.vertexCount * 2 );
			m_texture = _texture;
			
			material = new MaterialSkyBox( _texture );
			
			renderLayer = int.MIN_VALUE;
		}

		public function get texture():CubeTextureMap
		{
			return m_texture;
		}

		public function set texture(value:CubeTextureMap):void
		{
			m_texture = value;
			MaterialSkyBox(material).texture = m_texture;
		}

		
		public override function dispose():void{
			m_texture = null;
			super.dispose();
		}
		public override function disposeDeep():void{
			super.disposeDeep();
		}
		public override function disposeGPU():void{
			super.disposeGPU();
		}

	}
}
