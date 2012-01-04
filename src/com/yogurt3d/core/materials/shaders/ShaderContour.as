/*
* ShaderContour.as
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
	public class ShaderContour extends Shader
	{
		public var contColorConst:ShaderConstants;
		public var contThickness:ShaderConstants;
		
			
		public function ShaderContour(_contourColor:uint = 0x000000,
								   	  _contourThickness:Number=0.3,
									  _litThickness:Number=0.00,
									  _unlitThickness:Number=0.00001,
								      _opacity:Number = 1)
		{
			super();
			
			key = "Yogurt3DOriginalsShaderContour";
			
			params.requiresLight				= true;
			
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.NORMAL, EVertexAttribute.BONE_DATA);
			
			params.writeDepth 		= false;
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling			= Context3DTriangleFace.FRONT;
			
			// Shader Parameters
			params.vertexShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.MVP_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(4, EShaderConstantsType.MODEL_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(8, EShaderConstantsType.BONE_MATRICES));
			
			params.fragmentShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.CAMERA_POSITION));
			params.fragmentShaderConstants.push(new ShaderConstants(1, EShaderConstantsType.LIGHT_POSITION));
			params.fragmentShaderConstants.push(new ShaderConstants(7, EShaderConstantsType.LIGHT_DIRECTION));
			
									
			var _fragmentShaderConsts:ShaderConstants;
			_fragmentShaderConsts				 		= new ShaderConstants(2, EShaderConstantsType.CUSTOM_VECTOR);
			_fragmentShaderConsts.vector 				= Vector.<Number>([ _contourThickness, 0.0, _litThickness, _unlitThickness]);
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			contThickness = _fragmentShaderConsts;
			
			_fragmentShaderConsts				 		= new ShaderConstants(3, EShaderConstantsType.CUSTOM_VECTOR);
			
			var _r:uint = _contourColor >> 16;
			var _g:uint = _contourColor >> 8 & 0xFF;
			var _b:uint = _contourColor & 0xFF;
			_fragmentShaderConsts.vector 				= Vector.<Number>([ _r/255,_g/255,_b/255, _opacity]);
			
			contColorConst = _fragmentShaderConsts;
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
		}
		
		public function set litThickness(_value:Number):void{
			contThickness.vector[2] = _value;
		}
		
		public function set unlitThickness(_value:Number):void{
			contThickness.vector[3] = _value;
		}
		
		public function get contourThickness():Number{
			return contThickness.vector[0];
		}
		
		public function set contourThickness(_val:Number):void{
			contThickness.vector[0] = _val;
		}
		
		public function get contourColor():uint{
			
			return contColorConst.vector[0] << 16 & contColorConst.vector[1] << 8 & contColorConst.vector[2]; 
		}
		
		public function set contourColor(_val:uint):void{
			
			contColorConst.vector[0] = ((_val >> 16) & 255) / 255;
			contColorConst.vector[1] = ((_val >> 8) & 255) / 255;
			contColorConst.vector[2] = (_val & 255) / 255;
		}
		
		public function get opacity():Number{
			return contColorConst.vector[3];
		}
		
		public function set opacity( _val:Number):void{
			contColorConst.vector[3] = _val;
		}
		
		public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			
			if( _meshKey == "SkinnedMesh")
			{
				var assembler:AGALMiniAssembler = new AGALMiniAssembler();
				
				var code:String = ShaderUtils.getSkeletalAnimationVertexShader( 
					0, 1, 2, 
					3, 5, 
					0, 4, 8, 
					0, false, false, false  );
				
				code += "mov v" + 0 +".xyzw, vt0.xyzw\n";
				code += "mov v" + 1 + ".xyzw, vt1.xyzw\n";
				code += "mov v" + 2 + ", va1\n";
				
				
				return assembler.assemble(Context3DProgramType.VERTEX, 	code );
			}
			
			var _vertexShader:String = [
				
				"m44 op va0 vc0" , // MVP_TRANSPOSED * pos
				"m44 v0 va0 vc4" , 	  
				"m33 vt0.xyz va2 vc4",
				"mov v1.w va2.w",
				"nrm vt0.xyz vt0.xyz" ,
				"mov v1.xyz vt0.xyz" ,// pass Normals
				"mov v2 va1",  // pass UV
				
			].join("\n");
			
			return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, _vertexShader);
			
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			// v0: ec_pos
			// v1: normal
			// fc0: camera pos
			// fc1: light pos
			// fc2: Vector.<Number>([ 1.0, 2.0, 0.0, 0.0]);
			// fc3: color
			var _fragmentShader:String = [   
				"mov ft7 v2",
				"sub ft7 v0.xyz fc0.xyz", 	 // ft7 = V
			
				"neg ft7 ft7.xyz",			// viewVec  = ft7 = -view
				"nrm ft7.xyz ft7", 			// ft7 =  view vector
				"mov ft1 v1",
				"nrm ft1.xyz v1",          // ft1 =  normal
				
				(_lightType == ELightType.POINT || _lightType == ELightType.SPOT)?"sub ft0 fc1 ft7":"mov ft0 fc7",
				
				"dp3 ft4 ft7 ft1", 			// dot(Normal, EyeVert)
				"dp3 ft5 ft1 ft0",//dot(normalDirection, lightDirection)
				"max ft5 ft5 fc2.y",//max(0.0, dot(normalDirection, lightDirection))
				"sub ft2 fc3.w ft5",
				ShaderUtils.mix("ft6","ft3","fc2.z", "fc2.w","ft5","ft2"),
				
				"slt ft2 ft4 ft6",
				
				// for contour calculation
				"dp3 ft4 ft7 ft1", 			// dot(Normal, EyeVert)
				"max ft4 ft4 fc2.y", 		// sil =  max(dot(Normal, EyeVert), 0.0);
//				
//				// contour
//				// if (sil > 0.0 && sil < 0.1)
//				// out_color = silhouette_color;
				"sge ft1 ft4 fc2.y",
				"slt ft2 ft4 fc2.x",
				"mul ft7 ft1 ft2",
				"mul ft7 fc3.w ft7",
				
				"mov ft3 fc3",
				"mul ft2 ft2 fc3.w",
				"mov ft3.w ft2",
				"mov oc ft3"
				
			].join("\n");
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, _fragmentShader);
		}
	}
}
