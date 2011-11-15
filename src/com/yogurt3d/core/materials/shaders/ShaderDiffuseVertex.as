//

/*
* ShaderDiffuse.as
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
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
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
	public class ShaderDiffuseVertex extends Shader{
		
		/*private var m_normalMap:TextureMap;
		private var m_normalMapTexture:Dictionary;
		private var m_normalMapDirty:Boolean = false;
		private var m_normalMapConst:ShaderConstants;*/
		
		
		private var vaPos:uint = 0;
		private var vaUV:uint = 1;
		private var vaNormal:uint = 2;
		private var vaTangent:uint = 3;
		private var vaBoneIndices:uint = 4;
		private var vaBoneWeight:uint = 6;
		//private var vaColor:uint = 7;
		
		private var varyingWorldPos:uint = 0;
		//private var varyingNormal:uint = 1;
		private var varyingColor:uint = 1;
		//private var varyingUV:uint = 2;
		//private var varyingTangent:uint = 3;
		
		private var vcModelToWorld:uint = 11;
		private var vcProjection:uint   = 15;
		private var vcBoneMatrices:uint = 19;
		
		private var textureOpaticyMap:uint = 0;
		
		private var fcZeroVec:uint 			= 0; // 0,1, 4
		private var fcCameraPos:uint    	= 1;
		
		private var fcLightDirection:uint 	= 2;
		private var fcLightPosition:uint 	= 3;
		
		private var fcMaterial:uint			= 4; // fc6.y = specular exponent
		
		private var fcLightColor:uint		= 5;
		
		private var fcMaterialDiffuse:uint			= 6;
		private var fcMaterialSpecular:uint			= 7;
		
		private var fcMaterialOpacity:uint			= 8; // x: opaticy	
		
		private var fcLightCone:uint			= 9;
		
		private var fcAttenuation:uint 			= 10;
		
		private var fsSpecularMap:uint 			= 0;
		//private var fsNormalMap:uint 			= 1;
		
		public function ShaderDiffuseVertex()
		{
			super();
			
			key = "Yogurt3DOriginalsShaderDiffuseVertex";
			
			//m_normalMapTexture = new Dictionary();
			
			params.blendEnabled			= true;
			params.blendSource			= Context3DBlendFactor.ONE;
			params.blendDestination		= Context3DBlendFactor.ONE;
			params.writeDepth			= false;
			params.depthFunction		= Context3DCompareMode.EQUAL;
			params.colorMaskEnabled		= false;
			params.colorMaskR			= true;
			params.colorMaskG			= true;
			params.colorMaskB			= true;
			params.colorMaskA			= false;
			params.culling				= Context3DTriangleFace.FRONT;
			params.loopCount			= 1;
			requiresLight				= true;
			
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.NORMAL, EVertexAttribute.BONE_DATA );
			
			var _vertexShaderConsts:ShaderConstants;
			
			_vertexShaderConsts = new ShaderConstants();
			_vertexShaderConsts.type				= EShaderConstantsType.MODEL_TRANSPOSED;
			_vertexShaderConsts.firstRegister		= vcModelToWorld;
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts = new ShaderConstants();
			_vertexShaderConsts.type				= EShaderConstantsType.MVP_TRANSPOSED;
			_vertexShaderConsts.firstRegister		= vcProjection;
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts = new ShaderConstants();
			_vertexShaderConsts.type				= EShaderConstantsType.BONE_MATRICES;
			_vertexShaderConsts.firstRegister		= vcBoneMatrices;
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			
			//fragment
			
			var _fragmentShaderConsts:ShaderConstants;
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.CUSTOM_VECTOR;
			_fragmentShaderConsts.firstRegister		= fcZeroVec;
			_fragmentShaderConsts.vector			= Vector.<Number>([0,1,4,2]);
			
			params.vertexShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.CAMERA_POSITION;
			_fragmentShaderConsts.firstRegister		= fcCameraPos;
			
			params.vertexShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.LIGHT_DIRECTION;
			_fragmentShaderConsts.firstRegister		= fcLightDirection;
			
			params.vertexShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.LIGHT_POSITION;
			_fragmentShaderConsts.firstRegister		= fcLightPosition;
			
			params.vertexShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.CUSTOM_VECTOR;
			_fragmentShaderConsts.firstRegister		= fcMaterial;
			_fragmentShaderConsts.vector			= Vector.<Number>([0,30,0,0]);
			
			params.vertexShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.LIGHT_COLOR;
			_fragmentShaderConsts.firstRegister		= fcLightColor;
			
			params.vertexShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.MATERIAL_DIFFUSE_COLOR;
			_fragmentShaderConsts.firstRegister		= fcMaterialDiffuse;
			
			params.vertexShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.MATERIAL_SPECULAR_COLOR;
			_fragmentShaderConsts.firstRegister		= fcMaterialSpecular;
			
			params.vertexShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.LIGHT_ATTENUATION;
			_fragmentShaderConsts.firstRegister		= fcAttenuation;
			
			params.vertexShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.CUSTOM_VECTOR;
			_fragmentShaderConsts.firstRegister		= fcMaterialOpacity;
			_fragmentShaderConsts.vector			= Vector.<Number>([1,0,0,0]);
			
			params.vertexShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.LIGHT_CONE;
			_fragmentShaderConsts.firstRegister		= fcLightCone;
			
			params.vertexShaderConstants.push(_fragmentShaderConsts);
			
		}
		

		
		public override function getVertexProgram(_meshKey:String, _lightType:ELightType=null):ByteArray{
			
			var SPOTCUTOFF:String = // spot cutoff
				"nrm vt4.xyz, vt0.xyz\n" + 
				"dp3 vt4.x, vt4.xyz,vc" + fcLightDirection + ".xyz\n" + //cos_cur_angle = dot(-L, D)
				
				"sub vt3.w, vt4.x, vc" + fcLightCone + ".y\n" + 
				"mul vt3.w, vt3.w, vc" + fcLightCone + ".z\n" + 
				"sat vt3.w, vt3.w\n" + 
				
				// att = att * spot
				"mul vt3.z, vt3.z, vt3.w\n"
			
			
			var attenuation:String = // light distance attenuation
				"dp3 vt3.z, vt0.xyz, vt0.xyz\n" + // vt4 = dot(vt1,vt1) -->Attenuation Distance
				"sqt vt3.z, vt3.z\n" + // vt4 = sqrt(dot(vt1,vt1)) -->Attenuation Distance
				
				// vt5 = 1 / Kc + Kl * ft3 + Kq * ft3 * ft3
				"mul vt3.w, vt3.z, vt3.z\n" +
				"mul vt3.w, vt3.w, vc"+fcAttenuation+".z\n" + // Kq * ft3 * ft3
				"mul vt3.z, vt3.z, vc"+fcAttenuation+".y\n" + // Kl * ft3
				"add vt3.z, vt3.z, vt3.w\n" +
				"add vt3.z, vt3.z, vc"+fcAttenuation+".x\n" +
				"div vt3.z, vc"+fcZeroVec+".y, vt3.z\n";
			
			
			var light:String = // diffuse and specular light on ft3.xy
				
				"dp3 vt3.x, vt7.xyz, vt0.xyz\n" + // float diffuseAmount = dot( N, L );
				
				"sat vt3.x, vt3.x\n" // diffuseAmount = saturate( a );
			
			var view:String = // ft1 - view vector \'V\'
				"sub vt1, vc" + fcCameraPos + ", vt2.xyzz \n" +  // float4 V = cameraPosition - position;
				"nrm vt1.xyz, vt1\n" +  // V = normalize( V );
				"mov vt1.w, vc" + fcZeroVec + ".x\n" // V.w = 0;
			
			var assembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			if( _meshKey.indexOf( "SkinnedMesh" ) > -1 )
			{
				
				var code:String = ShaderUtils.getSkeletalAnimationVertexShader( 
					vaPos, vaUV, vaNormal, 
					vaBoneIndices, vaBoneWeight, 
					vcProjection, vcModelToWorld, vcBoneMatrices, 
					0, true, false, false  );
				
				code += "mov v" + varyingWorldPos +".xyzw, vt0.xyzz\n";//colorrrrrrrr
				//code += "mov v" + varyingNormal + ".xyzw, vt1.xyzz\n";
				//code += "mov v" + varyingUV + ", va1\n";
				//code += "mov v" + varyingColor + ", va7\n";
				//code += ( m_normalMap != null ? "mov v" + varyingTangent + ".xyzw, vt2.xyzz\n" : "" )
				
				// Vertex Program
				
				code+= ( _lightType == ELightType.DIRECTIONAL ?
					// register ft0 = L
					"mov vt0, vc" + fcLightDirection + "\n" +//light direction
					
					"nrm vt0.xyz, vt0.xyz\n"+//normalized ise gerek yok
					"mov vt0.w, vc" + fcZeroVec + ".x\n" + // L.w = 0;
					
					"nrm vt7.xyz, vt1.xyz\n" + // float4 N = normalize( normal );
					"mov vt7.w, vc" + fcZeroVec + ".x\n" + // V.w = 0;
					
					// register ft1 = V
					view + 
					
					// register ft1 = H
					light + 
					
					"mov vt2, vc" + fcLightColor + ".xyz\n" +
					
					// register ft0 = output
					"mul vt0, vt2, vt3.xxx\n" + // float4 diffuseLight = diffuseAmount * lightColor;
					
					
					"mul vt0, vt0, vc" + fcMaterialDiffuse + "\n" // diffuseLighting *= diffuseColor; 
					
					: "") + ( _lightType == ELightType.POINT ?

						// register ft0 = L
						
						"sub vt0, vc" + fcLightPosition + ", vt2.xyzz\n" +//light direction
						"nrm vt0.xyz, vt0.xyz\n"+
						"mov vt0.w, vc" + fcZeroVec + ".x\n" + // L.w = 0;
						
						"nrm vt7.xyz, vt1.xyz\n" + // float4 N = normalize( normal );
						"mov vt7.w, vc" + fcZeroVec + ".x\n" + // V.w = 0;
						
						attenuation + 
						
						// register ft1 = V
						view + 
						
						// register ft1 = H
						light + 
						
						
						"mul vt2, vc" + fcLightColor + ".xyz, vt3.zzz\t\t// float4 light = lightColor * att;\n" +
						
						// register ft0 = output
						"mul vt0, vt2, vt3.xxx\n" + // float4 diffuseLight = diffuseAmount * lightColor;
						
						
						"mul vt0, vt0, vc" + fcMaterialDiffuse + "\n" // diffuseLighting *= diffuseColor; 
						
						: "") +
					
					( _lightType == ELightType.SPOT ?

						// register ft0 = L
						"sub vt0, vc" + fcLightPosition + ", vt2.xyzz\n" +//light direction
						"nrm vt0.xyz, vt0.xyz\n"+
						"mov vt0.w, vc" + fcZeroVec + ".x\n" + // L.w = 0;
						
						"nrm vt7.xyz, vt1.xyz\n" + // float4 N = normalize( normal );
						"mov vt7.w, vc" + fcZeroVec + ".x\n" + // V.w = 0;
						
						//**********
						attenuation +
						
						SPOTCUTOFF + 
	
						view + 

						light + 
						
						
						"mul vt2, vc" + fcLightColor + ".xyz, vt3.zzz\t\t// float4 light = lightColor * att;\n" +
						
			
						"mul vt0, vt2, vt3.xxx\n" + // float4 diffuseLight = diffuseAmount * lightColor;
						
						"mul vt0, vt0.xyz, vc" + fcMaterialDiffuse + "\n"  // diffuseLighting *= diffuseColor; 
						
						
						: "") + 
					
					"mov vt0.w, vc" + fcMaterialOpacity + ".x\t\t\t\t\t\t// color.w = opacity;\n"+
				    "mov v" + varyingColor + ", vt0\t\t\t\t\t\t\t\t// outputColor = color;\n";
					
				
				return assembler.assemble(Context3DProgramType.VERTEX, 	code );
			}
			return assembler.assemble(Context3DProgramType.VERTEX, 
				
				"m44 vt2, va" + vaPos + ", vc" + vcModelToWorld + "\n" + // worldPosition = vertexPosition * modelToWorld
				
				"m44 op, va" + vaPos + ", vc" + vcProjection + "\n" + // outputPosition = worldPosition * worldToClipspace
				//"mov v" + varyingUV + ", va" + vaUV + "\n" +// texcoord = vertexTexcoord
				"mov vt1, va" + vaNormal + "\n" + // float4 temp1 = vertexNormal;
				
				( _lightType == ELightType.DIRECTIONAL ?
					// register ft0 = L
					"mov vt0, vc" + fcLightDirection + "\n" +//light direction
					
					"nrm vt0.xyz, vt0.xyz\n"+//normalized ise gerek yok
					"mov vt0.w, vc" + fcZeroVec + ".x\n" + // L.w = 0;
					
					"nrm vt7.xyz, vt1.xyz\n" + // float4 N = normalize( normal );
					"mov vt7.w, vc" + fcZeroVec + ".x\n" + // V.w = 0;
					
					// register ft1 = V
					view + 
					
					// register ft1 = H
					light + 
					
					"mov vt2, vc" + fcLightColor + ".xyz\n" +
					
					// register ft0 = output
					"mul vt0, vt2, vt3.xxx\n" + // float4 diffuseLight = diffuseAmount * lightColor;
					
					
					"mul vt0, vt0, vc" + fcMaterialDiffuse + "\n" // diffuseLighting *= diffuseColor; 
					
					: "") + ( _lightType == ELightType.POINT ?
						
						// register ft0 = L
						"sub vt0, vc" + fcLightPosition + ", vt2.xyzz\n" +//light direction
						
						"nrm vt0.xyz, vt0.xyz\n"+
						"mov vt0.w, vc" + fcZeroVec + ".x\n" + // L.w = 0;
						
						"nrm vt7.xyz, vt1.xyz\n" + // float4 N = normalize( normal );
						"mov vt7.w, vc" + fcZeroVec + ".x\n" + // V.w = 0;
						
						attenuation + 
						
						// register ft1 = V
						view + 
						
						// register ft1 = H
						light + 
						
						
						"mul vt2, vc" + fcLightColor + ".xyz, vt3.zzz\t\t// float4 light = lightColor * att;\n" +
						
						// register ft0 = output
						"mul vt0, vt2, vt3.xxx\n" + // float4 diffuseLight = diffuseAmount * lightColor;
						
						
						"mul vt0, vt0, vc" + fcMaterialDiffuse + "\n" // diffuseLighting *= diffuseColor; 
						
						: "") +
				
				( _lightType == ELightType.SPOT ?
					
					// register ft0 = L
					"sub vt0, vc" + fcLightPosition + ", vt2.xyzz\n" +//light direction
					
					"nrm vt0.xyz, vt0.xyz\n"+
					"mov vt0.w, vc" + fcZeroVec + ".x\n" + // L.w = 0;
					
					"nrm vt7.xyz, vt1.xyz\n" + // float4 N = normalize( normal );
					"mov vt7.w, vc" + fcZeroVec + ".x\n" + // V.w = 0;
					
					//**********
					attenuation +
					
					SPOTCUTOFF + 
					
					view + 
					
					light + 
					
					
					"mul vt2, vc" + fcLightColor + ".xyz, vt3.zzz\t\t// float4 light = lightColor * att;\n" +
					
					
					"mul vt0, vt2, vt3.xxx\n" + // float4 diffuseLight = diffuseAmount * lightColor;
					
					"mul vt0, vt0.xyz, vc" + fcMaterialDiffuse + "\n"  // diffuseLighting *= diffuseColor; 
					
					
					: "") + 
				
				"mov vt0.w, vc" + fcMaterialOpacity + ".x\t\t\t\t\t\t// color.w = opacity;\n" +
				"mov v" + varyingColor + ", vt0\t\t\t\t\t\t\t\t// outputColor = color;\n"
				
			);
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			return ShaderUtils.fragmentAssambler.assemble( Context3DProgramType.FRAGMENT, "mov oc, v" + varyingColor +"\t\t\t\t\t\t\t\t// outputColor = color;\n" );
		}
		
	}
}
