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
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;

	/**
	 * Ambient pass for multi-pass rendering pipeline.
	 * 
  	 * @author Yogurt3D Engine Core Team
  	 * @company Yogurt3D Corp.
  	 **/
	public class ShaderDepthMap extends Shader
	{
		
		private var vaPos:uint = 0;
		private var vaBoneIndices:uint = 1;
		private var vaBoneWeight:uint = 3;
		
		private var vcProjection:uint   = 0;
		private var vcModel:uint = 4;
		private var vcBoneMatrices:uint = 8;

		private var m_pointLightConstant:ShaderConstants;
		
		public function ShaderDepthMap( )
		{
			super();
			
			key = "Yogurt3DOriginalsShaderDepthMap";
		
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.BONE_DATA );
			
			params.vertexShaderConstants.push( new ShaderConstants(0, EShaderConstantsType.LIGHT_VIEW_PROJECTION_TRANSPOSED) );
			
			//params.vertexShaderConstants.push( new ShaderConstants(4, EShaderConstantsType.MODEL_TRANSPOSED) );//not used, string removed before assembled
			
			params.vertexShaderConstants.push( new ShaderConstants(8, EShaderConstantsType.BONE_MATRICES) );

			var consts:ShaderConstants = new ShaderConstants(0, EShaderConstantsType.CUSTOM_VECTOR );
			consts.vector = Vector.<Number>([1, 255, 65025, 160581375, 0.003921569, 0.003921569, 0.009, 0 ]);
			
			params.fragmentShaderConstants.push( consts );
			
		}
		
		public override function getVertexProgram( _meshKey:String, _lightType:ELightType=null):ByteArray{

			var code:String = "";
			
			var vaPos:uint = 0;
			var vaBoneIndices:uint = 1;
			var vaBoneWeight:uint = 3;
			var posVec:Array = ["x", "y", "z", "w"];
			var vcBoneMatrices:uint = 8;
			var varyingWorldPos:uint = 0;
			
			

			if(_meshKey == "SkinnedMesh")
			{
				code += ShaderUtils.getSkeletalAnimationVertexShader( 0,0,0,vaBoneIndices,vaBoneWeight,0,4,8,0,false,false);
				// remove the model space projection
				code = code.replace("m44 vt0, vt0, vc4\n","");
				// places projection space position to vt0
				code = code.replace( "m44 op, vt0, vc0", "m44 vt0, vt0, vc0");
			}
			else  //"Mesh"
			{
				code +=	"m44 vt0, va0, vc0\n";//projection
			}
			
			
			if(_lightType == ELightType.SPOT)
			{
				code +=	"mov op, vt0\n" +
					"rcp vt1.x, vt0.w\n" +
					"mul v0, vt0, vt1.x\n"; 
				
			}else if(_lightType == ELightType.DIRECTIONAL)
			{
				code += "mov v0, vt0\n"+
					"mov op, vt0\n";
			}else
			{
				code +=	"rcp vt1.x, vt0.w\n" +
					"mul vt0, vt0, vt1.x\n"+// transform vertex to DP-space
					
					"mul vt0.z, vt0.z, vc4.z\n"+//*Dir
					
					"dp3 vt1.z, vt0.xyz, vt0.xyz\n" + 
					"sqt vt1.z, vt1.z\n" +//Distance ,Length
					
					"div vt0, vt0, vt1.z\n"+//divide by the distance  normalize 
					
					"mov v1, vt0.z\n"+//varying z for interpolate and kill
					
					"add vt0.z, vt0.z, vc4.w\n"+//reflected vector for normal calc
					
					"div vt0.xy, vt0.xy, vt0.zz\n"+//xy
					
					//"sub vt1.z, vt1.z, vc4.y\n" +//vt1.z = distance vc4.y = 0.1  Length - g_fNear
					//"sub vt1.x, vc0.y, vc0.w\n" +
					
					"div vt0.z, vt1.z, vc4.x\n"+//z vc0.x = g_fFar - g_fNear
					"mov vt0.w, vc4.w\n"+//w =1
					
					"mov op, vt0\n" +
					
					"mov v0, vt0.z\n";//depth to texture
				
			}
			
			return ShaderUtils.vertexAssambler.assemble( Context3DProgramType.VERTEX, code );

		}
		
		public override function getFragmentProgram( _lightType:ELightType=null ):ByteArray{
			
			var code:String =""; 
			
			if(_lightType == ELightType.POINT)
			{
				code += "add ft0.x, v1.z, fc1.z\n" +
					"kil ft0.x\n";
			}
			
			code +=	"mul ft0, fc0, v0.z\n" +
				"frc ft0, ft0\n" +
				"mul ft1, ft0.yzww, fc1.xxxw\n" +
				"sub ft0, ft0, ft1\n" +
				"mov oc, ft0\n";

				return ShaderUtils.fragmentAssambler.assemble( Context3DProgramType.FRAGMENT, code );
		}
	}
}
