/*
 * ShaderConstants.as
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
	import com.yogurt3d.core.texture.base.ITexture;
	
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix3D;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class ShaderConstants
	{
		public var firstRegister:int	= 0;
		public var numRegisters:int;
		
		public var vector:Vector.<Number>;
		public var matrix:Matrix3D;
		public var type:EShaderConstantsType = EShaderConstantsType.MVP_TRANSPOSED;
		public var texture:ITexture;
		
		
		public function ShaderConstants( _firstRegister:uint = 0, _type:EShaderConstantsType = null ){
			type = _type;
			firstRegister = _firstRegister;
		}
	}
}
