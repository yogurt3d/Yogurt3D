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
	
	import mx.states.OverrideBase;

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

		
		public function ShaderDepthMap( )
		{
			super();
			
			key = "Yogurt3DOriginalsShaderDepthMap";
		
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.BONE_DATA );
			
			params.vertexShaderConstants.push( new ShaderConstants(0, EShaderConstantsType.LIGHT_VIEW_PROJECTION_TRANSPOSED) );
			
			params.vertexShaderConstants.push( new ShaderConstants(4, EShaderConstantsType.MODEL_TRANSPOSED) );
			
			params.vertexShaderConstants.push( new ShaderConstants(8, EShaderConstantsType.BONE_MATRICES) );
			
			
			var fragmentShaderConst:ShaderConstants = new ShaderConstants( 0, EShaderConstantsType.CUSTOM_VECTOR );
			fragmentShaderConst.vector = Vector.<Number>([1, 255, 65025, 160581375, 0.003921569, 0.003921569, 0.003921569, 0 ]);
			params.fragmentShaderConstants.push( fragmentShaderConst );
			
			
			params.writeDepth = true;
			params.depthFunction = Context3DCompareMode.LESS;
			params.blendSource = Context3DBlendFactor.ONE;
			params.blendDestination = Context3DBlendFactor.ZERO; 
			params.culling = Context3DTriangleFace.FRONT ;

		}
		
		
		public override function getProgram(_context3D:Context3D, _lightType:ELightType=null, _meshKey:String=""):Program3D{
			
			return super.getProgram( _context3D, _lightType, _meshKey );
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
				code = code.replace("m44 vt0, vt0, vc" + 4 + "\n","");
				// places projection space position to vt0
				code = code.replace( "m44 op, vt0, vc0", "m44 vt0, vt0, vc0");
				//code += "// Bone Transformations End " + i + "\n";
				//code += "m34 vt7.xyz, va" + vaPos + ", vt4\n";
				//code += "mov vt7.w, va" + vaPos + ".w\n";
				
				//non-skeletal code 
				//code +=
				//	"m44 vt0, vt7, vc0\n";//projection
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
			}
			
			return ShaderUtils.vertexAssambler.assemble( Context3DProgramType.VERTEX, code );
		}
		
		public override function getFragmentProgram( _lightType:ELightType=null ):ByteArray{
			
			var code:String =""; 
			
			code +=	"mul ft0, fc0, v0.z\n" +
				"frc ft0, ft0\n" +
				"mul ft1, ft0.yzww, fc1\n" +
				"sub ft0, ft0, ft1\n" +
				"mov oc, ft0\n";

				return ShaderUtils.fragmentAssambler.assemble( Context3DProgramType.FRAGMENT, code );
		}
	}
}
