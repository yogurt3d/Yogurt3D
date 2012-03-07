/*
* SubMesh.as
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

package com.yogurt3d.core.geoms
{
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.helpers.boundingvolumes.BoundingSphere;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	use namespace YOGURT3D_INTERNAL;
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class SubMesh extends EngineObject
	{
		public function SubMesh(_initInternals:Boolean = true)
		{
			super(_initInternals);
		}
		
		YOGURT3D_INTERNAL var m_vertices		:Vector.<Number>;
		YOGURT3D_INTERNAL var m_indices			:Vector.<uint>;
		YOGURT3D_INTERNAL var m_normals			:Vector.<Number>;
		YOGURT3D_INTERNAL var m_uvt				:Vector.<Number>;
		YOGURT3D_INTERNAL var m_uvt_2			:Vector.<Number>;
		YOGURT3D_INTERNAL var m_uvt_3			:Vector.<Number>;
		YOGURT3D_INTERNAL var m_tangents		:Vector.<Number>;
		YOGURT3D_INTERNAL var m_triangleCount	:int;
		YOGURT3D_INTERNAL var m_vertexCount		:int;
		
		YOGURT3D_INTERNAL var m_aabb			:AxisAlignedBoundingBox;
		YOGURT3D_INTERNAL var m_boundingSphere	:BoundingSphere;
		
		YOGURT3D_INTERNAL var m_indexBuffersByContext3D		:Dictionary;
		YOGURT3D_INTERNAL var m_vertexBuffersByContext3D 	:Dictionary;
		YOGURT3D_INTERNAL var m_uvBuffersByContext3D		:Dictionary;
		YOGURT3D_INTERNAL var m_uv2BuffersByContext3D		:Dictionary;
		YOGURT3D_INTERNAL var m_uv3BuffersByContext3D		:Dictionary;
		YOGURT3D_INTERNAL var m_normalBuffersByContext3D 	:Dictionary;
		YOGURT3D_INTERNAL var m_tangentBuffersByContext3D 	:Dictionary;
		
		/**
		 * Returns the type of the Submesh. Overriding classes should change this value. 
		 * @return type of the Submesh
		 * 
		 */		
		public function get type():String{
			return "Mesh";
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get tangents():Vector.<Number>
		{
			return m_tangents;
		}
		/**
		 * @private 
		 * @param value
		 * 
		 */		
		public function set tangents(value:Vector.<Number>):void
		{
			m_tangents = value;
			disposeTangentBuffer();
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get uvt():Vector.<Number>
		{
			return m_uvt;
		}
		/**
		 * @private 
		 * @param value
		 * 
		 */		
		public function set uvt(value:Vector.<Number>):void
		{
			m_uvt = value;
			disposeUVBuffer();
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get uvt2():Vector.<Number>
		{
			return m_uvt_2;
		}
		/**
		 * @private 
		 * @param value
		 * 
		 */		
		public function set uvt2(value:Vector.<Number>):void
		{
			m_uvt_2 = value;
			disposeUV2Buffer();
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get uvt3():Vector.<Number>
		{
			return m_uvt_3;
		}
		/**
		 * @private 
		 * @param value
		 * 
		 */		
		public function set uvt3(value:Vector.<Number>):void
		{
			m_uvt_3 = value;
			disposeUV2Buffer();
		}
		
		/**
		 *  
		 * @return 
		 * 
		 */		
		public function get vertices():Vector.<Number>
		{
			return m_vertices;
		}
		/**
		 * @private 
		 * @param _value
		 * 
		 */		
		public function set vertices(_value:Vector.<Number>):void
		{
			m_vertices 		= _value;
			m_vertexCount 	= m_vertices.length / 3;
			
			disposePositionBuffer();
			
			m_aabb = null;
			m_boundingSphere = null;
		}
		
		public function get indices():Vector.<uint>
		{
			return m_indices;
		}
		/**
		 * @private 
		 * @param _value
		 * 
		 */
		public function set indices(_value:Vector.<uint>):void
		{
			m_indices 		= _value;
			m_triangleCount = m_indices.length / 3;
			
			disposeIndiceBuffer();
		}
		
		public function get normals():Vector.<Number>
		{
			return m_normals;
		}
		
		/**
		 * @private 
		 * @param _value
		 * 
		 */
		public function set normals(_value:Vector.<Number>):void
		{
			m_normals = _value;
			disposeNormalBuffer();
		}
		
		
		
		public function get triangleCount():int
		{
			return m_triangleCount;
		}
		
		public function get vertexCount():int
		{
			return m_vertexCount;
		}
		
		public function get axisAlignedBoundingBox():AxisAlignedBoundingBox
		{
			if( m_aabb == null )
			{
				initializeBoundingVolumes();
			}
			return m_aabb;
		}
		
		public function get boundingSphere():BoundingSphere
		{
			if(m_boundingSphere == null)
			{
				initializeBoundingVolumes();
			}
			return m_boundingSphere;
		}
		
		
		
		/**
		 *	Calculates AABB and BoundingSphere fot this mesh
		 * 
		 */		
		YOGURT3D_INTERNAL function initializeBoundingVolumes():void
		{
			var _min	:Vector3D		= new Vector3D(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
			var _max	:Vector3D		= new Vector3D(-Number.MAX_VALUE, -Number.MAX_VALUE, -Number.MAX_VALUE);
			
			var _3i		:int;
			
			for( var i:int = 0; i < m_vertexCount; i++ )
			{
				_3i 	= 3*i;
				
				if( m_vertices[_3i] > _max.x ) _max.x	= m_vertices[_3i];
				if( m_vertices[_3i] < _min.x ) _min.x	= m_vertices[_3i];
				
				_3i++;
				
				if( m_vertices[_3i] > _max.y ) _max.y	= m_vertices[_3i];
				if( m_vertices[_3i] < _min.y ) _min.y	= m_vertices[_3i];
				
				_3i++;
				
				if( m_vertices[_3i] > _max.z ) _max.z	= m_vertices[_3i];
				if( m_vertices[_3i] < _min.z ) _min.z	= m_vertices[_3i];
			}
			var temp:Vector3D = _max.subtract(_min);
			var _radiusSqr	:Number		= temp.x*temp.x + temp.y*temp.y + temp.z*temp.z;
			var _center		:Vector3D	= _max.add( _min);
			_center.scaleBy( .5 );
			
			m_aabb						= new AxisAlignedBoundingBox(_min, _max);
			m_boundingSphere			= new BoundingSphere( _radiusSqr, _center );
		}
		
		
		
		/**
		 * Clones this mesh 
		 * @return clone og this mesh
		 * 
		 */		
		override public function clone():IEngineObject{
			var m_newMesh 		: SubMesh 	= new SubMesh();
			m_newMesh.m_vertices 		= this.m_vertices.concat();
			m_newMesh.m_indices 		= this.m_indices.concat();
			if(m_normals){
				m_newMesh.m_normals		= this.m_normals.concat();
			}
			if(m_tangents){
				m_newMesh.m_tangents	= this.m_tangents.concat();
			}
			m_newMesh.m_uvt				= this.m_uvt.concat();
			m_newMesh.m_triangleCount  	= this.m_triangleCount;
			m_newMesh.m_vertexCount 	= this.m_vertexCount;
			m_newMesh.m_aabb			= this.axisAlignedBoundingBox.clone() as AxisAlignedBoundingBox;
			m_newMesh.m_boundingSphere	= this.boundingSphere.clone() as BoundingSphere;
			
			return m_newMesh;
		}
		
		
		/**
		 * Returns the index buffer of the mesh for given Context3D
		 * If there is currently no buffer for that Context3D, a buffer is created on that Context3D 
		 * 
		 * @param _context3D Context3D
		 * @return Index buffer of the mesh for given Context3D
		 */		
		public function getIndexBufferByContext3D(_context3D:Context3D):IndexBuffer3D {
			
			if (m_indexBuffersByContext3D[_context3D]) {
				return m_indexBuffersByContext3D[_context3D];
			}
			
			m_indexBuffersByContext3D[_context3D] =_context3D.createIndexBuffer(m_indices.length );
			m_indexBuffersByContext3D[_context3D].uploadFromVector(m_indices, 0, m_indices.length);
			
			return m_indexBuffersByContext3D[_context3D];
		}
		
		
		/**
		 * Returns the vertex positon buffer of the mesh for given Context3D
		 * If there is currently no buffer for that Context3D, a buffer is created on that Context3D 
		 * 
		 * @param _context3D Context3D
		 * @return Vertex buffer of the mesh for given Context3D
		 * 
		 */		
		public function getPositonBufferByContext3D(_context3D:Context3D):VertexBuffer3D {
			
			
			if (m_vertexBuffersByContext3D[_context3D]) {
				return m_vertexBuffersByContext3D[_context3D];
			}
			
			m_vertexBuffersByContext3D[_context3D] = _context3D.createVertexBuffer( m_vertexCount, 3);			
			m_vertexBuffersByContext3D[_context3D].uploadFromVector( m_vertices, 0, m_vertexCount );
			
			return m_vertexBuffersByContext3D[_context3D];
		}
		/**
		 * Returns the vertex uv buffer of the mesh for given Context3D
		 * If there is currently no buffer for that Context3D, a buffer is created on that Context3D 
		 * 
		 * @param _context3D Context3D
		 * @return Vertex buffer of the mesh for given Context3D
		 * 
		 */		
		public function getUVBufferByContext3D(_context3D:Context3D):VertexBuffer3D {
			if (m_uvBuffersByContext3D[_context3D]) {
				return m_uvBuffersByContext3D[_context3D];
			}
			
			m_uvBuffersByContext3D[_context3D] = _context3D.createVertexBuffer( m_vertexCount, 2);			
			m_uvBuffersByContext3D[_context3D].uploadFromVector( m_uvt, 0, m_vertexCount );
			
			return m_uvBuffersByContext3D[_context3D];
		}
		/**
		 * Returns the vertex uv (channel 2) buffer of the mesh for given Context3D
		 * If there is currently no buffer for that Context3D, a buffer is created on that Context3D 
		 * 
		 * @param _context3D Context3D
		 * @return Vertex buffer of the mesh for given Context3D
		 * 
		 */		
		public function getUV2BufferByContext3D(_context3D:Context3D):VertexBuffer3D {
			if (m_uv2BuffersByContext3D[_context3D]) {
				return m_uv2BuffersByContext3D[_context3D];
			}
			
			m_uv2BuffersByContext3D[_context3D] = _context3D.createVertexBuffer( m_vertexCount, 2);			
			m_uv2BuffersByContext3D[_context3D].uploadFromVector( m_uvt_2, 0, m_vertexCount );
			
			return m_uv2BuffersByContext3D[_context3D];
		}
		
		/**
		 * Returns the vertex uv (channel 2) buffer of the mesh for given Context3D
		 * If there is currently no buffer for that Context3D, a buffer is created on that Context3D 
		 * 
		 * @param _context3D Context3D
		 * @return Vertex buffer of the mesh for given Context3D
		 * 
		 */		
		public function getUV3BufferByContext3D(_context3D:Context3D):VertexBuffer3D {
			if (m_uv3BuffersByContext3D[_context3D]) {
				return m_uv3BuffersByContext3D[_context3D];
			}
			
			m_uv3BuffersByContext3D[_context3D] = _context3D.createVertexBuffer( m_vertexCount, 2);			
			m_uv3BuffersByContext3D[_context3D].uploadFromVector( m_uvt_2, 0, m_vertexCount );
			
			return m_uv3BuffersByContext3D[_context3D];
		}
		/**
		 * Returns the vertex normal buffer of the mesh for given Context3D
		 * If there is currently no buffer for that Context3D, a buffer is created on that Context3D 
		 * 
		 * @param _context3D Context3D
		 * @return Vertex buffer of the mesh for given Context3D
		 * 
		 */		
		public function getNormalBufferByContext3D(_context3D:Context3D):VertexBuffer3D {
			if (m_normalBuffersByContext3D[_context3D]) {
				return m_normalBuffersByContext3D[_context3D];
			}
			
			if( m_normals == null )
			{
				m_normals = MeshUtils.calculateVerticeNormals( indices, m_vertices );
			}
			
			m_normalBuffersByContext3D[_context3D] = _context3D.createVertexBuffer( m_vertexCount, 3);			
			m_normalBuffersByContext3D[_context3D].uploadFromVector( m_normals, 0, m_vertexCount );
			
			return m_normalBuffersByContext3D[_context3D];
		}
		/**
		 * Returns the vertex tangent buffer of the mesh for given Context3D
		 * If there is currently no buffer for that Context3D, a buffer is created on that Context3D 
		 * 
		 * @param _context3D Context3D
		 * @return Vertex buffer of the mesh for given Context3D
		 * 
		 */		
		public function getTangentBufferByContext3D(_context3D:Context3D):VertexBuffer3D {
			if (m_tangentBuffersByContext3D[_context3D]) {
				return m_tangentBuffersByContext3D[_context3D];
			}
			
			if( m_tangents == null )
			{
				m_tangents = MeshUtils.calculateVerticeTangents( m_normals );
			}
			
			m_tangentBuffersByContext3D[_context3D] = _context3D.createVertexBuffer( m_vertexCount, 3);			
			m_tangentBuffersByContext3D[_context3D].uploadFromVector( m_tangents, 0, m_vertexCount );
			
			return m_tangentBuffersByContext3D[_context3D];
		}
		
		override public function dispose():void{
			super.dispose();
			
			if( m_aabb ) 
			{
				m_aabb.dispose();
				m_aabb = null;
			}
			if( m_boundingSphere )
			{ 
				m_boundingSphere.dispose();
				m_boundingSphere = null;
			}
			
			disposeGPU();
			
			m_vertices			= null;
			m_indices			= null;
			m_normals			= null;
			m_uvt				= null;
			m_uvt_2				= null;
			m_tangents			= null;
		}
		public override function disposeDeep():void{
			dispose();
		}
		
		public override function disposeGPU():void{
			disposeIndiceBuffer();
			disposePositionBuffer();
			disposeUVBuffer();
			disposeUV2Buffer();
			disposeNormalBuffer();
			disposeTangentBuffer();
		}
		
		public function disposeIndiceBuffer():void{
			if( m_indexBuffersByContext3D )	
			{
				for each (var inBuf:IndexBuffer3D in m_indexBuffersByContext3D) {inBuf.dispose();}		
				m_indexBuffersByContext3D = new Dictionary();
			}
		}
		
		public function disposePositionBuffer():void{
			if( m_vertexBuffersByContext3D )	
			{
				for each (var verBuf:VertexBuffer3D in m_vertexBuffersByContext3D) {verBuf.dispose();}
				m_vertexBuffersByContext3D = new Dictionary();
			}
		}
		public function disposeUVBuffer():void{
			if( m_uvBuffersByContext3D )	
			{
				for each (var verBuf:VertexBuffer3D in m_uvBuffersByContext3D) {verBuf.dispose();}
				m_uvBuffersByContext3D = new Dictionary();
			}
		}
		public function disposeUV2Buffer():void{
			if( m_uv2BuffersByContext3D )	
			{
				for each (var verBuf:VertexBuffer3D in m_uv2BuffersByContext3D) {verBuf.dispose();}		
				m_uv2BuffersByContext3D = new Dictionary();
			}
		}
		public function disposeNormalBuffer():void{
			if( m_normalBuffersByContext3D )	
			{
				for each (var verBuf:VertexBuffer3D in m_normalBuffersByContext3D) {verBuf.dispose();}	
				m_normalBuffersByContext3D = new Dictionary();
			}
		}
		public function disposeTangentBuffer():void{
			if( m_tangentBuffersByContext3D )	
			{
				for each (var verBuf:VertexBuffer3D in m_tangentBuffersByContext3D) {verBuf.dispose();}	
				m_tangentBuffersByContext3D = new Dictionary();
			}
		}
		
		protected override function trackObject():void
		{
			IDManager.trackObject(this, SubMesh);
		}
		
		override protected function initInternals():void {
			m_indexBuffersByContext3D 		= new Dictionary();
			m_vertexBuffersByContext3D		= new Dictionary();
			m_uvBuffersByContext3D 			= new Dictionary();
			m_normalBuffersByContext3D		= new Dictionary();
			m_tangentBuffersByContext3D		= new Dictionary();
			m_uv2BuffersByContext3D			= new Dictionary();
			m_uv3BuffersByContext3D			= new Dictionary();
			super.initInternals();
		}
	}
}
