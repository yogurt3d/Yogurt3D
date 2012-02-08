// ActionScript file
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
	import com.yogurt3d.core.lights.ELightType;
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
	public class ShaderHemisphereTexture extends Shader
	{
		
		private var vaPos:uint = 0;
		private var vaUV:uint = 1;
		private var vaNormal:uint = 2;
		private var vaBoneIndices:uint = 3;
		private var vaBoneWeight:uint = 5;
		
		private var vcProjection:uint  = 0;
		private var vcModel:uint = 4;
		private var vcBoneMatrices:uint = 13;
		private var vcGroundColor:uint = 8
		private var vcSkyColor:uint = 9;
		private var vcZeroVec:uint 	= 10;
		private var vcDirFromSky:uint 	= 11;
		private var vcMaterialAmbient:uint = 12
		
		private var fcMaterialOpacity:uint			= 0;
		private var fcMaterialEmissive:uint			= 5;
		private var fcMaterialAmbient:uint			= 6;
		
		private var _alphaShaderConsts:ShaderConstants;	
		private var _textureConst:ShaderConstants;
		private var m_texture:TextureMap;
			
		public function ShaderHemisphereTexture( texture:TextureMap, _alpha:Number = 1)
		{
			super();
			
			key = "Yogurt3DOriginalsShaderHemisphereTexture"+ (texture.transparent?"withAlpha":"");
			
			m_texture = texture;
			
			params.blendEnabled			= true;
			params.blendSource			= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination		= Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.writeDepth			= true;
			params.depthFunction		= Context3DCompareMode.LESS;
			params.colorMaskEnabled		= false;
			params.colorMaskR			= true;
			params.colorMaskG			= true;
			params.colorMaskB			= true;
			params.colorMaskA			= true;
			params.culling				= Context3DTriangleFace.FRONT;
			params.loopCount			= 1;
			params.requiresLight				= false;
			
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.NORMAL, EVertexAttribute.BONE_DATA );
			
			var _vertexShaderConsts:ShaderConstants;
			
			_vertexShaderConsts = new ShaderConstants();
			_vertexShaderConsts.type				= EShaderConstantsType.MVP_TRANSPOSED;
			_vertexShaderConsts.firstRegister		= vcProjection;
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts = new ShaderConstants();
			_vertexShaderConsts.type				= EShaderConstantsType.MODEL_TRANSPOSED;
			_vertexShaderConsts.firstRegister		= vcModel;
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts = new ShaderConstants();
			_vertexShaderConsts.type				= EShaderConstantsType.BONE_MATRICES;
			_vertexShaderConsts.firstRegister		= vcBoneMatrices;
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_alphaShaderConsts = new ShaderConstants();
			_alphaShaderConsts.type					= EShaderConstantsType.CUSTOM_VECTOR;
			_alphaShaderConsts.firstRegister		= fcMaterialOpacity;
			_alphaShaderConsts.vector				= Vector.<Number>([_alpha,0.000001,1,0.2]);
			
			params.fragmentShaderConstants.push(_alphaShaderConsts);
		
			_vertexShaderConsts = new ShaderConstants();
			_vertexShaderConsts.type			    = EShaderConstantsType.CUSTOM_VECTOR;
			_vertexShaderConsts.firstRegister		= vcGroundColor;
			_vertexShaderConsts.vector				= Vector.<Number>([0.1, 0, 0, 1 ]);
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts = new ShaderConstants();
			_vertexShaderConsts.type			    = EShaderConstantsType.CUSTOM_VECTOR;
			_vertexShaderConsts.firstRegister		= vcZeroVec;
			_vertexShaderConsts.vector				= Vector.<Number>([0, 1, 2, 4 ]);
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts = new ShaderConstants();
			_vertexShaderConsts.type			    = EShaderConstantsType.CUSTOM_VECTOR;
			_vertexShaderConsts.firstRegister		= vcSkyColor;
			_vertexShaderConsts.vector				= Vector.<Number>([ 1, 1, 1, 1 ]);
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts = new ShaderConstants();
			_vertexShaderConsts.type			    = EShaderConstantsType.CUSTOM_VECTOR;
			_vertexShaderConsts.firstRegister		= vcDirFromSky;
			_vertexShaderConsts.vector				= Vector.<Number>([ 0, -1, 0, 1 ]);
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts = new ShaderConstants();
			_vertexShaderConsts.type				= EShaderConstantsType.MATERIAL_AMBIENT_COLOR;
			_vertexShaderConsts.firstRegister		= vcMaterialAmbient;
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_textureConst = new ShaderConstants();
			_textureConst.type = EShaderConstantsType.TEXTURE;
			_textureConst.texture = texture;
			
			params.fragmentShaderConstants.push( _textureConst );
		
		}
		
		public function get texture():TextureMap
		{
			return m_texture;
		}

		public function set texture(value:TextureMap):void
		{
			m_texture = value;
			key = "Yogurt3DOriginalsShaderHemisphereTexture"+ (value.transparent?"withAlpha":"");
		}
		
		public function get opacity():Number{
			
			return _alphaShaderConsts.vector[0];
		}
		
		public function set opacity(_alpha:Number):void{
			
			_alphaShaderConsts.vector[0] = _alpha;
		}

		
		public override function getVertexProgram( _meshKey:String, _lightType:ELightType = null ):ByteArray{
			if( _meshKey == "SkinnedMesh" )
			{
				var assembler:AGALMiniAssembler = new AGALMiniAssembler();
				
				var code:String = ShaderUtils.getSkeletalAnimationVertexShader( 
					vaPos, vaUV, vaNormal, 
					vaBoneIndices, vaBoneWeight, 
					vcProjection, vcModel, vcBoneMatrices, 
					0 );
				code += "mov v0, va" + vaUV + "\n"; // float4 temp1 = vertexNormal;
				// Vertex Program
				
				//ma * lerp(groundColor, skyColor, (dot(N, -DirFromSky ) + 1) / 2) * (1 - Occ); 
				code+= //Hemisphere string
				
				//x + s(y-x) "lerp" 
				"mov vt6, vc"+ vcSkyColor + "\n" +
				
				"sub vt6, vt6, vc" + vcGroundColor + "\n" + // (y-x) of x + s(y-x)
				
				"nrm vt4.xyz, vt1.xyz\n" + // float4 N = normalize( normal )
				"mov vt4.w, vc" + vcZeroVec + ".x\n"+ // V.w = 0;"
				
				"mov vt5, vc"+ vcDirFromSky + "\n" +
				"neg vt5, vt5 \n"+ // -DirFromSky of (dot(N, -DirFromSky) + 1)
				"dp3 vt4.x, vt4.xyz, vt5.xyz\n" + //dot(N, -DirFromSky)
				"add vt4.x, vt4.x, vc" + vcZeroVec +".y \n" + //(dot(N, -DirFromSky) + 1)
				"div vt4.x, vt4.x, vc" + vcZeroVec +".z \n" + //(dot(N, -DirFromSky) + 1) / 2  is "s" of  x + s(y-x)
				"mul vt4.xyz, vt6.xyz, vt4.xxx\n"+ // s(y-x) of x + s(y-x)
				
				"add vt4.xyz, vt4.xyz, vc" + vcGroundColor + ".xyz\n" + 
				//x + s(y-x) "lerp" end
				
				"mul vt4.xyz, vt4.xyz, vc" + vcMaterialAmbient +".xyz\n" + //ma * lerp(groundColor, skyColor, (dot(N, -DirFromSky ) + 1) / 2)
				//"mul vt4.xyz, vt4.xyz, vc" + vcMaterialAmbient + ".xyz\n" + //ma * lerp(groundColor, skyColor, (dot(N, -DirFromSky ) + 1) / 2)
				//TODO: (1 - Occ)
				//"mul vt2.xyz, vt2.xyz, vc" + vcMaterialAmbient + "\n"+
				//"sub vt5.x , vc" + vcZeroVec +".y, "*/
				"mov v3, vt4\n"
				return assembler.assemble(Context3DProgramType.VERTEX, 	code );
			}
			return new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, 
				"m44 op, va" + vaPos + ", vc" + vcProjection + "\n" + 
				// normals
				"m33 vt1.xyz, va" + vaNormal + ", vc" + vcModel +"\n" + // float4 temp1 = vertexNormal;
				"mov v0, va" + vaUV + "\n"+ // float4 temp1 = vertexNormal;
				
				//ma * lerp(groundColor, skyColor, (dot(N, -DirFromSky ) + 1) / 2) * (1 - Occ); 
				//Hemisphere string
				
				//x + s(y-x) "lerp" 
				"mov vt6, vc"+ vcSkyColor + "\n" +
				
				"sub vt6, vt6, vc" + vcGroundColor + "\n" + // (y-x) of x + s(y-x)
				
				"nrm vt4.xyz, vt1.xyz\n" + // float4 N = normalize( normal )
				"mov vt4.w, vc" + vcZeroVec + ".x\n"+ // V.w = 0;"
				
				"mov vt5, vc"+ vcDirFromSky + "\n" +
				"neg vt5, vt5 \n"+ // -DirFromSky of (dot(N, -DirFromSky) + 1)
				"dp3 vt4.x, vt4.xyz, vt5.xyz\n" + //dot(N, -DirFromSky)
				"add vt4.x, vt4.x, vc" + vcZeroVec +".y \n" + //(dot(N, -DirFromSky) + 1)
				"div vt4.x, vt4.x, vc" + vcZeroVec +".z \n" + //(dot(N, -DirFromSky) + 1) / 2  is "s" of  x + s(y-x)
				"mul vt4.xyz, vt6.xyz, vt4.xxx\n"+ // s(y-x) of x + s(y-x)
				
				"add vt4.xyz, vt4.xyz, vc" + vcGroundColor + ".xyz\n" + 
				//x + s(y-x) "lerp" end
				
				"mul vt4.xyz, vt4.xyz, vc" + vcMaterialAmbient +".xyz\n" + //ma * lerp(groundColor, skyColor, (dot(N, -DirFromSky ) + 1) / 2)
				//"mul vt4.xyz, vt4.xyz, vc" + vcMaterialAmbient + ".xyz\n" + //ma * lerp(groundColor, skyColor, (dot(N, -DirFromSky ) + 1) / 2)
				//TODO: (1 - Occ)
				//"mul vt2.xyz, vt2.xyz, vc" + vcMaterialAmbient + "\n"+
				//"sub vt5.x , vc" + vcZeroVec +".y, "*/
				"mov v3, vt4\n"
				//Hemisphere string end
				
			);
		}
		
		public override function getFragmentProgram( _lightType:ELightType=null ):ByteArray{
			return new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, 
				//"mov ft0, fc" + fcMaterialEmissive + "\n"+ // emissive = emissiveColor;
				//"mov ft1, fc" +fcMaterialAmbient+ "\n" + // // ambient = ambientColor;
				
				//"add ft0, ft0, ft1\n" + // float4 color = emissive + ambient;
				"mov ft0, v3 \n" +
				"mov ft0.w, fc" + fcMaterialOpacity + ".x\n" + // color.w = opacity;
				((!texture.mipmap)?"tex ft2, v0.xy, fs0<2d,wrap,linear>\n":"tex ft2, v0.xy, fs0<2d,wrap,linear,miplinear>\n")+ 
				((texture.transparent)?"sub ft1.w ft2.w fc"+fcMaterialOpacity+".w\nkil ft1.w\n":"" )+ 
				"mul ft0, ft0, ft2\n" + 
				"mov oc, ft0\n" // outputColor = color;
			);
		}
	}
}
