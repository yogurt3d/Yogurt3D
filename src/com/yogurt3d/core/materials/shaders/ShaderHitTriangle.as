/*
 * ShaderHitTriangle.as
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
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.utils.ByteArray;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class ShaderHitTriangle extends Shader
	{
		
		private var vaPos:uint = 0;
		private var vaUV:uint = 0;
		private var vaNormal:uint = 0;
		private var vaTangent:uint = 0;
		private var vaBoneIndices:uint = 1;
		private var vaBoneWeight:uint = 3;
		
		private var vcModelToWorld:uint = 4;
		private var vcProjection:uint   = 0;
		private var vcBoneMatrices:uint = 8;
		
		public function ShaderHitTriangle()
		{
			super();
			
			key = "Yogurt3DOriginalsShaderHitTriangle";
			
			params.blendEnabled			= false;
			params.writeDepth			= true;
			params.depthFunction		= Context3DCompareMode.LESS;
			params.colorMaskEnabled		= false;
			params.culling				= Context3DTriangleFace.NONE;
			params.loopCount			= 1;

			
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.BONE_DATA );
		}
				public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			if( _meshKey == "SkinnedMesh" )
			{
				var code:String = ShaderUtils.getSkeletalAnimationVertexShader( 
					vaPos, 0, 0, 
					vaBoneIndices, vaBoneWeight, 
					vcProjection, vcModelToWorld, vcBoneMatrices, 
					0  );
				code += "add vt0, va0, vc5\n" +
						"mul vt0, vt0, vc6\n" +
						"mov v0, vt0\n";
				
				// Vertex Program
				return new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, 	code );
			}
			return new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, 
				"add vt0, va0, vc5\n" +
				"mul vt0, vt0, vc6\n" +
				"mov v0, vt0\n" +
				"m44 vt0, va0, vc0\n" +
				"mul vt1.xy, vt0.w, vc4.xy\n" +
				"add vt0.xy, vt0.xy, vt1.xy\n" +
				"mul vt0.xy, vt0.xy, vc4.zw\n" +
				"mov op, vt0\n"
			);
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			return new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, 
				"mov oc, v0\n"
			);
		}
	}
}
