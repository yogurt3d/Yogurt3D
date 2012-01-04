/*
* ShaderToon.as
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
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.utils.ByteArray;

	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class ShaderToon extends Shader
	{
		public var colorConst:ShaderConstants;
		public var contColorConst:ShaderConstants;
		public var contThickness:ShaderConstants;
		
		
		public function ShaderToon(_color:uint, 
								   _contourColor:uint = 0x000000,
								   _contourThickness:Number=0.3,
								   _opacity:Number = 1.0)
		{
			super();
			
			key = "Yogurt3DOriginalsShaderToon";
			
			params.requiresLight				= true;

			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.NORMAL, EVertexAttribute.BONE_DATA );
			
			params.writeDepth 		= true;
			
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling			= Context3DTriangleFace.FRONT;
			
			// Shader Parameters
			params.vertexShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.MVP_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(4, EShaderConstantsType.MODEL_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(8, EShaderConstantsType.BONE_MATRICES));
			
			
			var _fragmentShaderConsts:ShaderConstants;
			
			params.fragmentShaderConstants.push(new ShaderConstants(0,EShaderConstantsType.CAMERA_POSITION));
			
			params.fragmentShaderConstants.push(new ShaderConstants(1,EShaderConstantsType.LIGHT_POSITION));
			
			_fragmentShaderConsts				 		= new ShaderConstants(2, EShaderConstantsType.CUSTOM_VECTOR);
			_fragmentShaderConsts.vector 				= Vector.<Number>([ 1.0, 2.0, 0.0, 0.000000000000000000001]);
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			
			_fragmentShaderConsts						= new ShaderConstants(3, EShaderConstantsType.CUSTOM_VECTOR);
			
			var _r:uint = _color >> 16;
			var _g:uint = _color >> 8 & 0xFF;
			var _b:uint = _color & 0xFF;
			
			_fragmentShaderConsts.vector = Vector.<Number>([_r/255,_g/255,_b/255, _opacity]);
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			colorConst = _fragmentShaderConsts;
			
			_fragmentShaderConsts				 		= new ShaderConstants(4,  EShaderConstantsType.CUSTOM_VECTOR);
			_fragmentShaderConsts.vector 				= Vector.<Number>([ 0.9, 0.5, 0.6, 0.4]);
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			contThickness				 				= new ShaderConstants(5, EShaderConstantsType.CUSTOM_VECTOR);
			contThickness.vector 						= Vector.<Number>([ 1.1, 0.7, _contourThickness, 0.2]);
			params.fragmentShaderConstants.push(contThickness);
					
			contColorConst				 				= new ShaderConstants(6, EShaderConstantsType.CUSTOM_VECTOR);
			_r = _contourColor >> 16;
			_g = _contourColor >> 8 & 0xFF;
			_b = _contourColor & 0xFF;
			contColorConst.vector 						= Vector.<Number>([ _r/255,_g/255,_b/255, _opacity]);
			params.fragmentShaderConstants.push(contColorConst);
			
			params.fragmentShaderConstants.push(new ShaderConstants(7, EShaderConstantsType.LIGHT_DIRECTION));
			
		}
		
		public function get contourThickness():Number{
			return contThickness.vector[2];
		}
		
		public function set contourThickness(_val:Number):void{
			contThickness.vector[2] = _val;
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
			return colorConst.vector[3];
		}
		
		public function set opacity( _val:Number):void{
			colorConst.vector[3] = _val;
			contColorConst.vector[3] = _val;
		}
		
		public function get color():uint{
			return colorConst.vector[0] << 16 & colorConst.vector[1] << 8 & colorConst.vector[2]; 
		}
		
		public function set color( _val:uint ):void{
			colorConst.vector[0] = ((_val >> 16) & 255) / 255;
			colorConst.vector[1] = ((_val >> 8) & 255) / 255;
			colorConst.vector[2] = (_val & 255) / 255;
		}
		
		public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			
			
			if( _meshKey == "SkinnedMesh")
			{
				var assembler:AGALMiniAssembler = new AGALMiniAssembler();
				
				var code:String = ShaderUtils.getSkeletalAnimationVertexShader( 
					0, 0, 1, 
					2, 4, 
					0, 4, 8, 
					0, false, false, false  );
				
				code += "mov v" + 0 +".xyzw, vt0.xyzw\n";
				code += "mov v" + 1 + ".xyzw, vt1.xyzw\n";
				
				
				return assembler.assemble(Context3DProgramType.VERTEX, 	code );
			}
		
			var _vertexShader:String = [
				
				"m44 op va0 vc0" , // MVP_TRANSPOSED * pos
				"m44 v0 va0 vc4" , 	  
				"m33 vt0.xyz va1 vc4",
				"mov v1.w va1.w",
				"nrm vt0.xyz vt0.xyz" ,
				"mov v1.xyz vt0.xyz"
			
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
				"sub ft7 v0.xyz fc0.xyz", 	 // ft7 = V
				
				(_lightType == ELightType.POINT || _lightType == ELightType.SPOT)?"sub ft0 fc1 ft7":"mov ft0 fc7",
				"neg ft1 ft0.xyz",// ft1 = -lightdir
				
				//reflect(-lightdir, N)
				"dp3 ft2 v1 ft1",			// dot(N,-lightdir)
				"mul ft2 ft2 v1",			// dot(N,-lightdir)*N
				"mul ft2 ft2 fc2.y",		// 2 * dot(N,-lightdir) * N
				"sub ft2 ft1 ft2", 			// R = -lightdir - 2 * dot(N,-lightdir) * N
				"nrm ft2.xyz ft2",			// reflectVec = ft2 = normalize(reflect( -lightdir, normal ));
				
				"neg ft7 ft7.xyz",			// viewVec  = ft7 = -view
				"nrm ft7.xyz ft7", 			// ft7 =  view vector
				"nrm ft0.xyz ft0",         // ft0 = light direction
				"mov ft1 v1",
				"nrm ft1.xyz v1",          // ft1 =  normal
				
				// for contour calculation
				"dp3 ft4 ft7 ft1", 			// dot(Normal, EyeVert)
				"max ft4 ft4 fc2.z", 		// sil =  max(dot(Normal, EyeVert), 0.0);
				
				"dp3 ft3 ft0 ft1", 			//dot(normalize(lightdir), normalize(normal)
				"max ft3 ft3 fc2.z", 		//ft3 = diff = max( dot(normalize(lightdir), normalize(normal)), 0.0);
				
				"sge ft0 ft3 fc2.w", 		// if diff > 0 ft0 = 1 else ft0 = 0
				"dp3 ft1 ft2 ft7", 			// dot(reflectVec, viewVec)
				"max ft1 ft1 fc2.z",		// max(dot(reflectVec, viewVec), 0.0)
				
				"mul ft0 ft0 ft1", 			// ft0 = spec
				"mul ft3 ft3 fc4.z",		// diff = diff * 0.6
				"mul ft0 ft0 fc4.w", 		//  spec =  spec * 0.4
				"add ft3 ft3 ft0", 			//diff =  diff * 0.6 + spec * 0.4
				
				// if (diff > 0.90) diff = 1.1;
				"sge ft0 ft3 fc4.x",
				"mov ft1 fc4.w",			// ft1 = 0.4
				"mul ft2 ft0 ft1",			// ft2 = 0.4 or 0
				
				// else if (diff > 0.5) diff = 0.7;
				"sge ft0 ft3 fc4.y",
				"mov ft1 fc5.w",			// ft1 = 0.2
				"mul ft1 ft0 ft1",
				"add ft2 ft2 ft1",
				
				// else diff = 0.5;
				"add ft3 ft2 fc4.y",
				"mul ft3 ft3 fc3", // color * diff;
				
				// contour
				// if (sil > 0.0 && sil < 0.1)
				// out_color = silhouette_color;
				"sge ft1 ft4 fc2.z",
				"slt ft2 ft4 fc5.z",
				"mul ft7 ft1 ft2",
				"mul ft4 ft7 fc6", 
				
				"sub ft5 fc2.x ft7",
				"mul ft3 ft5 ft3",
				
				"add ft3 ft3 ft4",
				"mov ft3.w fc3.w",
				"mov oc ft3",
			
			].join("\n");
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, _fragmentShader);
		}
	}
}
