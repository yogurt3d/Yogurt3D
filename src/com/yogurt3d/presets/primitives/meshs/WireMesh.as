/*
* WireMesh.as
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
	import com.yogurt3d.core.geoms.interfaces.IMesh;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.utils.MatrixUtils;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	public class WireMesh extends Mesh
	{
		private var p1:Vector3D = new Vector3D();
		private var p2:Vector3D = new Vector3D();
		private var p3:Vector3D = new Vector3D();
		private var p4:Vector3D = new Vector3D();
		public function WireMesh(_initInternals:Boolean=true)
		{
			super(_initInternals);
		}
		public function addMesh( mesh:IMesh, radius:Number ):void{
			var dict:Dictionary = new Dictionary();
			var indices:Vector.<uint> = mesh.subMeshList[0].indices;
			var vertices:Vector.<Number> = mesh.subMeshList[0].vertices;
			
			var v1:Vector3D = new Vector3D();
			var v2:Vector3D = new Vector3D();
			var v3:Vector3D = new Vector3D();
			
			var len:uint = indices.length;
			
			for( var i:int = 0; i < len; )
			{
				var i13:uint = indices[i++] * 3;
				var i23:uint = indices[i++] * 3;
				var i33:uint = indices[i++] * 3;
				
				v1.setTo( vertices[ i13 ], vertices[ i13 + 1 ], vertices[ i13 + 2 ] );
				v2.setTo( vertices[ i23 ], vertices[ i23 + 1 ], vertices[ i23 + 2 ] );
				v3.setTo( vertices[ i33 ], vertices[ i33 + 1 ], vertices[ i33 + 2 ] );
				
				var str1:String = vertices[ i13 ] + "" +vertices[ i13 + 1 ]+ "" + vertices[ i13 + 2 ];
				var str2:String = vertices[ i23 ] + "" +vertices[ i23 + 1 ]+ "" + vertices[ i23 + 2 ];
				var str3:String = vertices[ i33 ] + "" +vertices[ i33 + 1 ]+ "" + vertices[ i33 + 2 ];
				
				if( dict[ str1 + str2 ] != true && dict[ str2 + str1 ] != true)
				{
					dict[ str1 + str2 ] = true;
					addLine( v1, v2, radius );
				}
				if( dict[ str2 + str3 ] != true && dict[ str3 + str2 ] != true )
				{
					dict[ str2 + str3 ] = true;
					addLine( v2, v3, radius );
				}
				if( dict[ str3 + str1 ] != true && dict[ str1 + str3 ] != true )
				{
					dict[ str3 + str1 ] = true;
					addLine( v3, v1, radius );
				}
			}
			dict = null;
		}
		private var out:Vector.<Number> = new Vector.<Number>(12);
		private var input:Vector.<Number> = new Vector.<Number>(12);
		private var NEG_Z:Vector3D = new Vector3D(0,0,-1);
		public function addLine( from:Vector3D, to:Vector3D, radius:Number ):void{
			var matrix:Matrix3D = MatrixUtils.TEMP_MATRIX;
			matrix.identity();
			matrix.pointAt(to.subtract(from),NEG_Z,Vector3D.Y_AXIS);
			
			input[0] = input[1] = input[7] = input[9] = radius/2;
			input[3] = input[4] = input[6] = input[10] = -radius/2;
			
			matrix.transformVectors( input, out );
			
			var submesh:SubMesh;
			if( this.subMeshList.length == 0 || subMeshList[subMeshList.length - 1].YOGURT3D_INTERNAL::m_vertexCount > 30000 )
			{
				submesh = new SubMesh();
				subMeshList.push( submesh );
			}else{
				submesh = subMeshList[subMeshList.length - 1];
			}
			
			if( submesh.vertices == null )
			{
				submesh.vertices = new Vector.<Number>();
				submesh.indices = new Vector.<uint>();
				submesh.uvt = new Vector.<Number>( );
			}
			var vertexCount:uint = submesh.YOGURT3D_INTERNAL::m_vertexCount;
			
			var fromX:Number = from.x;
			var fromY:Number = from.y;
			var fromZ:Number = from.z;
			
			var toX:Number = to.x;
			var toY:Number = to.y;
			var toZ:Number = to.z;
			
			var out0:Number = out[0];
			var out1:Number = out[1];
			var out2:Number = out[2];
			var out3:Number = out[3];
			var out4:Number = out[4];
			var out5:Number = out[5];
			var out6:Number = out[6];
			var out7:Number = out[7];
			var out8:Number = out[8];
			var out9:Number = out[9];
			var out10:Number = out[10];
			var out11:Number = out[11];
			
			submesh.vertices.push(
				out0 + fromX, out1 + fromY, out2 + fromZ, // 0
				out3 + fromX, out4 + fromY, out5 + fromZ, // 1
				out6 + fromX, out7 + fromY, out8 + fromZ, // 2
				out9 + fromX, out10 + fromY,out11 + fromZ, // 3
				
				out0 + toX, out1 + toY, out2 + toZ, // 4
				out3 + toX, out4 + toY, out5 + toZ, // 5
				out6 + toX, out7 + toY, out8 + toZ, // 6
				out9 + toX, out10 + toY, out11 + toZ  // 7
			);
			submesh.YOGURT3D_INTERNAL::m_vertexCount += 8;
			submesh.uvt.push( 0,0, 0,0, 0,0, 0,0,0,0, 0,0, 0,0, 0,0 );
			var v1:uint = vertexCount + 1;
			var v4:uint = vertexCount + 4;
			var v3:uint = vertexCount + 3;
			var v6:uint = vertexCount + 6;
			submesh.indices.push(
				vertexCount    ,v1,v4,
				vertexCount + 5,v1,v4,
				vertexCount + 2,v3,v6,
				vertexCount + 7,v3,v6
			);
			submesh.YOGURT3D_INTERNAL::m_triangleCount += 4;			
		}
	}
}