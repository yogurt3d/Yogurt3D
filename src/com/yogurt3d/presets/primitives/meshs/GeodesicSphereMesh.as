/*
 * Copyright 2007 (c) Gabriel Putnam
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

package com.yogurt3d.presets.primitives.meshs
{
	import com.yogurt3d.core.geoms.Mesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	
	import flash.geom.*;
	
	public class GeodesicSphereMesh extends Mesh
	{
		
		public function GeodesicSphereMesh(_radius:Number  = 100.0, _fractures:Number = 2.0)
		{
			super();
			
			createGeodesicSphere(_radius, _fractures);
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, GeodesicSphereMesh);
		}
		
		private function createGeodesicSphere(_radius:Number, _fractures:uint):void{
			
			var _vertices		:Vector.<Number>			= new Vector.<Number>();
			var _indices		:Vector.<uint>				= new Vector.<uint>();
			var _uvt			:Vector.<Number> 			= new Vector.<Number>();
			
			var _verticesIndex	:int						= 0;
			var _indiceIndex	:int						= 0;
			
			// Set up variables for keeping track of the number of iterations and the angles
			var iVerts:uint = _fractures + 1, jVerts:uint;
			var j:uint, theta:Number = 0, phi:Number = 0, thetaDel:Number, phiDel:Number;
			var cosTheta:Number, sinTheta:Number, rcosPhi:Number, rsinPhi:Number;
			
			// Set up variables for figuring out the texture coordinates using a diamond ~equal area map projection
			// This is done so that there is the minimal amount of distortion of textures around poles.
			// Visually, this map projection looks like this.
			/*	Phi   /\0,0
				|    /  \
				\/  /    \
				   /      \
				  /        \
				 / 1,0      \0,1
				 \ Theta->  /
				  \        /
				   \      /
				    \    /
				     \  /
				      \/1,1
			*/
			
			var pd4:Number = Math.PI / 4, cosPd4:Number = Math.cos(pd4), sinPd4:Number = Math.sin(pd4), piInv:Number = 1/Math.PI;
			var r_00:Number = cosPd4, r_01:Number = -sinPd4, r_10:Number = sinPd4, r_11:Number = cosPd4;
			var scale:Number = Math.SQRT2, uOff:Number = 0.5, vOff:Number = 0.5;
			var uu:Number, vv:Number, u:Number, v:Number;
			phiDel = Math.PI / ( 2 * iVerts);
			
			// Build the top vertex
			_vertices[_verticesIndex] 		= 0;
			_vertices[_verticesIndex + 1] 	= 0;
			_vertices[_verticesIndex + 2] 	= _radius;
	
			_uvt.push(0,0);
			_verticesIndex += 3;
			_indiceIndex++;
			
			phi += phiDel;
			
			// Build the tops worth of vertices for the sphere progressing in rings around the sphere
			var i:int;
			
			for( i = 1 ; i <= iVerts; i++){
				j = 0;
				jVerts = i*4;
				theta = 0;
				thetaDel = 2* Math.PI / jVerts;
				rcosPhi = Math.cos( phi ) * _radius;
				rsinPhi = Math.sin( phi ) * _radius;
				
				for( j; j < jVerts; ++j ){
					
					uu = theta * piInv/2 - 0.5;
					vv = ( phi * piInv - 1 ) * ( 0.5 - Math.abs( uu ) );
					
					u = ( uu * r_00 + vv * r_01 ) * scale + uOff;
					v = ( uu * r_10 + vv * r_11 ) * scale + vOff;
					
					cosTheta = Math.cos( theta );
					sinTheta = Math.sin( theta );
					
					_vertices[_verticesIndex] 		= cosTheta * rsinPhi;
					_vertices[_verticesIndex + 1] 	= sinTheta * rsinPhi;
					_vertices[_verticesIndex + 2] 	= rcosPhi;
					
					_uvt.push(u,v);
					
					_verticesIndex += 3;
					_indiceIndex++;
					
					theta += thetaDel;
				}
				phi += phiDel;
			}
			
			// Build the bottom worth of vertices for the sphere.
			
			for( i = iVerts-1; i >0; i-- ){
				j = 0;
				jVerts = i*4;
				theta = 0;
				thetaDel = 2* Math.PI / jVerts;
				rcosPhi = Math.cos( phi ) * _radius;
				rsinPhi = Math.sin( phi ) * _radius;
				for( j; j < jVerts; ++j ){
					
					uu = theta * piInv/2 - 0.5;
					vv = ( phi * piInv - 1 ) * ( 0.5 + Math.abs( uu ) );
					
					u = ( uu * r_00 + vv * r_01 ) * scale + uOff;
					v = ( uu * r_10 + vv * r_11 ) * scale + vOff;
					
					cosTheta = Math.cos( theta );
					sinTheta = Math.sin( theta );
					
					_vertices[_verticesIndex] 		= cosTheta * rsinPhi;
					_vertices[_verticesIndex + 1] 	= sinTheta * rsinPhi;
					_vertices[_verticesIndex + 2] 	= rcosPhi;
					
					_uvt.push(u,v);
					
					_verticesIndex += 3;
					_indiceIndex++;
					
					theta += thetaDel;
				}
				phi += phiDel;
			}
			
			// Build the last vertice
			
			_vertices[_verticesIndex] 		= 0;
			_vertices[_verticesIndex + 1] 	= 0;
			_vertices[_verticesIndex + 2] 	= -_radius;
			
			_uvt.push(1,1);
			_verticesIndex += 3;
			_indiceIndex++;
			
			// Build the faces for the sphere
			// Build the upper four sections
			var k:uint, l_Ind_s:uint, u_Ind_s:uint, u_Ind_e:uint, l_Ind_e:uint, l_Ind:uint, u_Ind:uint;
			var isUpTri:Boolean, pt0:uint, pt1:uint, pt2:uint, triInd:uint, tris:uint;
			tris = 1;
			
			l_Ind_s = 0; l_Ind_e = 0;
			for( i = 0; i < iVerts; ++i ){
				u_Ind_s = l_Ind_s;
				u_Ind_e = l_Ind_e;
				if( i == 0 ) l_Ind_s++;
				l_Ind_s += 4*i;
				l_Ind_e += 4*(i+1);
				u_Ind = u_Ind_s;
				l_Ind = l_Ind_s;
				for( k = 0; k < 4; ++k ){
					isUpTri = true;
					for( triInd = 0; triInd < tris; triInd++ ){
						if( isUpTri ){
							pt0 = u_Ind;
							pt1 = l_Ind;
							l_Ind++;
							if( l_Ind > l_Ind_e ) l_Ind = l_Ind_s;
							pt2 = l_Ind;
							isUpTri = false;
						} else {
							pt0 = l_Ind;
							pt2 = u_Ind;
							u_Ind++;
							if( u_Ind > u_Ind_e ) u_Ind = u_Ind_s;
							pt1 = u_Ind;
							isUpTri = true;
						}
						_indices.push(pt0,pt1,pt2);
						
					}
				}
				tris += 2;
			}
			u_Ind_s = l_Ind_s; u_Ind_e = l_Ind_e;
			
			for( i = iVerts-1; i >= 0; i-- ){
				l_Ind_s = u_Ind_s; l_Ind_e = u_Ind_e; u_Ind_s = l_Ind_s + 4*(i+1); u_Ind_e = l_Ind_e + 4*i;
				if( i == 0 ) u_Ind_e++;
				tris -= 2;
				u_Ind = u_Ind_s;
				l_Ind = l_Ind_s;
				for( k = 0; k < 4; ++k ){
					isUpTri = true;
					for( triInd = 0; triInd < tris; triInd++ ){
						if( isUpTri ){
							pt0 = u_Ind;
							pt1 = l_Ind;
							l_Ind++;
							if( l_Ind > l_Ind_e ) l_Ind = l_Ind_s;
							pt2 = l_Ind;
							isUpTri = false;
						} else {
							pt0 = l_Ind;
							pt2 = u_Ind;
							u_Ind++;
							if( u_Ind > u_Ind_e ) u_Ind = u_Ind_s;
							pt1 = u_Ind;
							isUpTri = true;
						}
						_indices.push(pt0,pt2,pt1);
						
					}
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