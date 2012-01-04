/*
 * ShaderParameters.as
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
 
 
package com.yogurt3d.core.materials.shaders.renderstate
{
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.textures.Texture;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class ShaderParameters
	{
		public var vertexShaderConstants	:Vector.<ShaderConstants>;
		public var fragmentShaderConstants	:Vector.<ShaderConstants>;
		
		public var blendEnabled				:Boolean 		= false;		
		public var blendSource				:String 		= "one";		
		public var blendDestination			:String 		= "zero";		
		public var writeDepth				:Boolean 		= true;		
		public var depthFunction			:String  		= Context3DCompareMode.LESS_EQUAL;		
		public var colorMaskEnabled			:Boolean;		
		public var colorMaskR				:Boolean		= true;		
		public var colorMaskG				:Boolean		= true;		
		public var colorMaskB				:Boolean		= true;		
		public var colorMaskA				:Boolean		= true;
		public var culling					: String		= Context3DTriangleFace.NONE;
		public var requiresLight			: Boolean = false;
		
		public var loopCount				:int 			= 1;		

		public function ShaderParameters() 
		{
			vertexShaderConstants 		= new Vector.<ShaderConstants>();
			fragmentShaderConstants 	= new Vector.<ShaderConstants>();
		}
	}
}
