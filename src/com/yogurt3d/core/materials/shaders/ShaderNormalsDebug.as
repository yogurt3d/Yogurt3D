/*
 * ShaderNormalsDebug.as
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
 
 
package com.yogurt3d.core.materials.shaders
{	
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class ShaderNormalsDebug extends Shader
	{
		
		use namespace YOGURT3D_INTERNAL;
		
		public function ShaderNormalsDebug()
		{
			super();
			
			setProgramParameters();
		}
		
		private function setProgramParameters():void
		{

			
			params.depthFunction = Context3DCompareMode.LESS_EQUAL;
			
			// Shader Parameters
			var _vertexShaderConsts:ShaderConstants;
			
			_vertexShaderConsts							= new ShaderConstants();
			_vertexShaderConsts.type 					= EShaderConstantsType.MODEL_VIEW_TRANSPOSED;
			_vertexShaderConsts.firstRegister 			= 0;			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts							= new ShaderConstants();
			_vertexShaderConsts.type 					= EShaderConstantsType.MVP_TRANSPOSED;
			_vertexShaderConsts.firstRegister 			= 4;			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts							= new ShaderConstants();
			_vertexShaderConsts.type 					= EShaderConstantsType.CUSTOM_VECTOR;
			_vertexShaderConsts.vector					= Vector.<Number>([0,0,0,0]);
			_vertexShaderConsts.firstRegister 			= 8;			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts							= new ShaderConstants();
			_vertexShaderConsts.type 					= EShaderConstantsType.MODEL_TRANSPOSED;
			_vertexShaderConsts.firstRegister 			= 14;			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			
			var _fragmentShaderConsts:ShaderConstants;
			
			_fragmentShaderConsts						= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.CUSTOM_VECTOR;
			_fragmentShaderConsts.vector				= Vector.<Number>([1,2,0,1]);
			_fragmentShaderConsts.firstRegister 		= 0;
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
	
			
		}
		
				public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			return new AGALMiniAssembler().assemble(AGALMiniAssembler.VERTEX, 	
				"m44 op, va0, vc4\n"+
				"m34 vt1.xyz, va0, vc14\n"+
				"mov vt1.w, vc8.x\n"+
				"m34 vt2.xyz, va2, vc14\n"+
				"mov vt2.w, vc8.x\n"+
				"mov v0, va1.xyzw\n"+
				"mov v1, va1\n"+
				"mov v2, vt2\n"+
				"mov v3, vt1.xyzw\n"
			);
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			return new AGALMiniAssembler().assemble(AGALMiniAssembler.FRAGMENT, 
				"mov ft0, v2\n"+
				"add ft0.xyz, ft0.xyz, fc0.xxx\n"+
				"div ft0.xyz, ft0.xyz, fc0.yyy\n"+
				"mov oc, ft0.xyzw"
			);
		}
		
	}
}
