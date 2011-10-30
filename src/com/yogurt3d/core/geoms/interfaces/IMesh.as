/*
 * IMesh.as
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
 
 
package com.yogurt3d.core.geoms.interfaces {
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.helpers.boundingvolumes.BoundingSphere;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	
	import flash.display3D.Context3D;
/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public interface IMesh extends IEngineObject
	{
		
		function get subMeshList():Vector.<SubMesh>;
		
		//function get normals():Vector.<Number>;
		//function set normals(_value:Vector.<Number>):void;		
		
		function get type():String;
		
		/**
		 * Tangents of the Mesh.
		 * <p>Tangents must be per-vertex.</p>
		 * @return 
		 * 
		 */
		//function get tangents():Vector.<Number>;
		/**
		 * @private  
		 * @param _value
		 * 
		 */
		//function set tangents(_value:Vector.<Number>):void;

		//function get indices():Vector.<uint>;				
		//function set indices(_value:Vector.<uint>):void;
		
		//function get uvt():Vector.<Number>;
		//function set uvt(_value:Vector.<Number>):void;
		
		//function get vertices():Vector.<Number>;
		//function set vertices(_value:Vector.<Number>):void;

		function get triangleCount():int;
		//function get vertexCount():int;
		
		function get axisAlignedBoundingBox():AxisAlignedBoundingBox;
		function get boundingSphere():BoundingSphere;
		
		//function getVertexBufferByContext3D(_context3d:Context3D):VertexBuffer3D;
		//function getIndexBufferByContext3D(_context3d:Context3D):IndexBuffer3D;
		
	}
}
