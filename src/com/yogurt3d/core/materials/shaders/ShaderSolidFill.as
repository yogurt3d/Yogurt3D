/*
 * ShaderSolidFill.as
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
 /**
  * @revision
  *  - get color bug fix ( Gurel Erceis ) - 7/18/2011 
  */ 
package com.yogurt3d.core.materials.shaders
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.managers.contextmanager.Context;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class ShaderSolidFill extends Shader
	{
		public var colorConst:ShaderConstants;
		
		public function ShaderSolidFill(_color:uint, _opacity:Number = 1)
		{
			super();
			
			key = "Yogurt3DOriginalsShaderSolidFill";
			
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.BONE_DATA );
			
			params.writeDepth 		= true;
			
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling			= Context3DTriangleFace.NONE;
			
			// Shader Parameters
			params.vertexShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.MVP_TRANSPOSED));

			params.vertexShaderConstants.push(new ShaderConstants(4, EShaderConstantsType.MODEL_TRANSPOSED));

			params.vertexShaderConstants.push(new ShaderConstants(8, EShaderConstantsType.BONE_MATRICES));
			
			colorConst 	= new ShaderConstants(0, EShaderConstantsType.CUSTOM_VECTOR);
			
			var _r:uint = _color >> 16;
			var _g:uint = _color >> 8 & 0xFF;
			var _b:uint = _color & 0xFF;
			
			colorConst.vector = Vector.<Number>([_r/255,_g/255,_b/255, _opacity]);
			
			params.fragmentShaderConstants.push(colorConst);
			
		}
		
		public function get opacity():Number{
			return colorConst.vector[3];
		}
		
		public function set opacity( _val:Number):void{
			colorConst.vector[3] = _val;
		}
		
		public function get color():uint{
			return ((colorConst.vector[0]*255) << 16) | ((colorConst.vector[1]*255) << 8) | (colorConst.vector[2]*255); 
		}
		
		public function set color( _val:uint ):void{
			colorConst.vector[0] = ((_val >> 16) & 255) / 255;
			colorConst.vector[1] = ((_val >> 8) & 255) / 255;
			colorConst.vector[2] = (_val & 255) / 255;
		}
		
				public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			if( _meshKey == "SkinnedMesh")
			{
				var assembler:AGALMiniAssembler = ShaderUtils.vertexAssambler;
				
				var code:String = ShaderUtils.getSkeletalAnimationVertexShader( 
					0, 0, 0, 
					1, 3, 
					0, 4, 8, 
					0 );
				
				// Vertex Program
				return assembler.assemble(Context3DProgramType.VERTEX, 	code );
			}
			return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, 
				"m44 op, va0, vc0\n"
			);
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			return ShaderUtils.fragmentAssambler.assemble(AGALMiniAssembler.FRAGMENT, "mov ft0, fc0\nmov oc, ft0");
		}
	}
}
