/*
* ShaderAmbient.as
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
	import com.yogurt3d.core.geoms.SkeletalAnimatedMesh;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.managers.contextmanager.Context;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	
	
	/**
	 * Ambient pass for multi-pass rendering pipeline.
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class ShaderDepth extends Shader
	{
		
		public function ShaderDepth()
		{
			super();
			
			key = "Yogurt3DOriginalsShaderDepth";
			
//			params.writeDepth 		= true;
//			params.blendEnabled 	= true;
//			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
//			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
//			params.culling			= Context3DTriangleFace.FRONT;
			
			params.writeDepth 		= true;
			params.depthFunction 	= Context3DCompareMode.LESS;
			params.blendSource 		= Context3DBlendFactor.ONE;
			params.blendDestination = Context3DBlendFactor.ZERO;
			params.culling			= Context3DTriangleFace.NONE;
				
			params.requiresLight				= false;
			
			attributes.push(EVertexAttribute.POSITION, EVertexAttribute.NORMAL);
			
			
			params.vertexShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.MVP_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(4, EShaderConstantsType.MODEL_VIEW));
			
			
			var _fragmentShaderConsts:ShaderConstants;
			_fragmentShaderConsts						= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.CUSTOM_VECTOR;
			_fragmentShaderConsts.firstRegister 		= 0;
			
			_fragmentShaderConsts.vector = Vector.<Number>([1.0, ((1.0/(255.0)) as Number),255.0, 0.5]);
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			

		}
		
		
		public override function getProgram(_context3D:Context3D, _lightType:ELightType=null, _meshType:String = null):Program3D{
//		/	disposeShaders();
			
			return super.getProgram( _context3D, _lightType, _meshType );
		}
		
		
		public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			// va0: vertex va1: normals
			var _vertexShader:String = [
				
				"m44 vt1 va0 vc0",// position
				//"m44 v0 va0 vc4",//posData
				"m33 vt2.xyz va1 vc4",//normal
				"nrm vt2.xyz vt2.xyz" ,
				
				"mov vt2.w vt1.w",//depth
				"mov v1 vt2",
				"mov v0 vt1",
				"mov op vt1"
			
			].join("\n");
			
			return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, _vertexShader);
	
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			var _fragmentShader:String = [   
				
				"mov ft0 v1",// normal

				"mul ft0.xyz ft0.xyz fc0.w",
				"add ft0.xyz ft0.xyz fc0.w",// view space normals
				"div ft0.w v0.z v0.w",// depth
								
				"mul ft2.z ft0.w fc2.z",// depth * 255
				ShaderUtils.floorAGAL("ft1.z", "ft2.z"),//floor (depth*255)
				"div ft1.z ft1.z fc2.z",// floor (depth*255)/255
				"frc ft1.w ft2.z",// frac(depth * 255) // encoded depth im wz channels
				"mov ft1.xy ft0.xy",// get normals (R: normal.x, G: normal.y, B:depth, A:depth
				
				"mov oc ft1"
				
			].join("\n");
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, _fragmentShader);
		}
	}
}
