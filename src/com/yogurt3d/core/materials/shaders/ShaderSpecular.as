/*
 * ShaderSpecular.as
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
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class ShaderSpecular extends Shader{
		
		private var m_specularMap:TextureMap;
		private var m_specularDirty:Boolean = false;
		private var m_specularMapConst:ShaderConstants;
		
		private var m_normalMap:TextureMap;
		private var m_normalMapDirty:Boolean = false;
		private var m_normalMapConst:ShaderConstants;
		
		private var m_shininessConst:ShaderConstants;
		
		
		private var vaPos:uint = 0;
		private var vaUV:uint = 1;
		private var vaNormal:uint = 2;
		private var vaTangent:uint = 7;
		private var vaBoneIndices:uint = 3;
		private var vaBoneWeight:uint = 5;
		
		private var varyingWorldPos:uint = 0;
		private var varyingNormal:uint = 1;
		private var varyingUV:uint = 2;
		private var varyingTangent:uint = 3;
		
		private var vcModelToWorld:uint = 0;
		private var vcProjection:uint   = 4;
		private var vcBoneMatrices:uint = 8;
		
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
		private var fsNormalMap:uint 			= 1;
		
		public function ShaderSpecular(_opacity:Number=1.0)
		{
			super();
			
			key = "Yogurt3DOriginalsShaderSpecular";
			
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
			
			var _fragmentShaderConsts:ShaderConstants;
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.CUSTOM_VECTOR;
			_fragmentShaderConsts.firstRegister		= fcZeroVec;
			_fragmentShaderConsts.vector			= Vector.<Number>([0,1,4,2]);
			
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.CAMERA_POSITION;
			_fragmentShaderConsts.firstRegister		= fcCameraPos;
			
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.LIGHT_DIRECTION;
			_fragmentShaderConsts.firstRegister		= fcLightDirection;
			
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.LIGHT_POSITION;
			_fragmentShaderConsts.firstRegister		= fcLightPosition;
			
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			m_shininessConst = new ShaderConstants();
			m_shininessConst.type				= EShaderConstantsType.CUSTOM_VECTOR;
			m_shininessConst.firstRegister		= fcMaterial;
			m_shininessConst.vector			= Vector.<Number>([0,50,0,0]);
			
			params.fragmentShaderConstants.push(m_shininessConst);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.LIGHT_COLOR;
			_fragmentShaderConsts.firstRegister		= fcLightColor;
			
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.MATERIAL_DIFFUSE_COLOR;
			_fragmentShaderConsts.firstRegister		= fcMaterialDiffuse;
			
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.MATERIAL_SPECULAR_COLOR;
			_fragmentShaderConsts.firstRegister		= fcMaterialSpecular;
			
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.LIGHT_ATTENUATION;
			_fragmentShaderConsts.firstRegister		= fcAttenuation;
			
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.CUSTOM_VECTOR;
			_fragmentShaderConsts.firstRegister		= fcMaterialOpacity;
			_fragmentShaderConsts.vector			= Vector.<Number>([_opacity,0,0,0]);
			
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			_fragmentShaderConsts = new ShaderConstants();
			_fragmentShaderConsts.type				= EShaderConstantsType.LIGHT_CONE;
			_fragmentShaderConsts.firstRegister		= fcLightCone;
			
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			
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
			params.requiresLight				= true;
			
		}
		
		public function get shininess():Number
		{
			return m_shininessConst.vector[1];
		}
		
		public function set shininess(value:Number):void
		{
			m_shininessConst.vector[1] = value;
		}
		
		public function get specularMap():TextureMap
		{
			return m_specularMap;
		}
		
		public function set specularMap(value:TextureMap):void
		{
			m_specularMap = value;
			m_specularDirty = true;
		}
		
		public function get normalMap():TextureMap
		{
			return m_normalMap;
		}
		
		public function set normalMap(value:TextureMap):void
		{
			m_normalMap = value;
			m_normalMapDirty = true;
		}
		
		public override function getProgram(_context3D:Context3D, _lightType:ELightType=null, _meshType:String = null):Program3D{
			if( m_specularDirty )
			{
				if( m_specularMapConst )
				{
					params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_specularMapConst ), 1 );
					m_specularMapConst = null;
				}
				if( m_specularMap )
				{
					m_specularMapConst = new ShaderConstants();
					m_specularMapConst.type				= EShaderConstantsType.TEXTURE;
					m_specularMapConst.firstRegister	= fsSpecularMap;
					m_specularMapConst.texture 			= m_specularMap;
					
					params.fragmentShaderConstants.push(m_specularMapConst);
				}else{
					
				}
				m_specularDirty = false;
				
				disposeShaders();
				//key = "Yogurt3DOriginalsShaderSpecular" + (m_normalMap?"WithNormalMap":"") + (m_specularMap?"WithSpecularMap":"");
			}
			
			if( m_normalMapDirty )
			{
				if( m_normalMapConst )
				{
					params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_normalMapConst ), 1 );
					m_normalMapConst = null;
				}
				if( m_normalMap )
				{
					m_normalMapConst = new ShaderConstants();
					m_normalMapConst.type				= EShaderConstantsType.TEXTURE;
					m_normalMapConst.firstRegister		= fsNormalMap;
					m_normalMapConst.texture			= m_normalMap;
					
					params.fragmentShaderConstants.push(m_normalMapConst);
					
					attributes.push( EVertexAttribute.TANGENT );
				}else{
					var popped:EVertexAttribute = attributes.pop();
					
					if( popped != EVertexAttribute.TANGENT ){
						attributes.push( popped );
					}
				}
				m_normalMapDirty = false;
				
				disposeShaders();
			}
			
			key = "Yogurt3DOriginalsShaderSpecular" + 
				(m_normalMap?"WithNormalMap":"") + 
				((m_normalMap && m_normalMap.mipmap)?"WithNormalMapMip":"") + 
				(m_specularMap?"WithSpecularMap":"")+
				((m_specularMap && m_specularMap.mipmap)?"WithSpecularMapMip":"");
			
			return super.getProgram( _context3D, _lightType, _meshType );
		}
		
				public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			
			if( _meshKey ==  "SkinnedMesh" )
			{
				var code:String = ShaderUtils.getSkeletalAnimationVertexShader( 
					vaPos, vaUV, vaNormal, 
					vaBoneIndices, vaBoneWeight, 
					vcProjection, vcModelToWorld, vcBoneMatrices, 
					vaTangent, true, (m_normalMap!= null), (m_normalMap!= null)  );
				
				code += "mov v" + varyingWorldPos +".xyzw, vt0.xyzz\n";
				code += "mov v" + varyingNormal + ".xyzw, vt1.xyzz\n";
				code += "mov v" + varyingUV + ", va1\n";
				code += ( m_normalMap != null ? "mov v" + varyingTangent + ".xyzw, vt2.xyzz\n" : "" )
				// Vertex Program
				return ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, 	code );
			}
			
			var _vertexProgram:ByteArray	= ShaderUtils.vertexAssambler.assemble(Context3DProgramType.VERTEX, 
				"m44 vt0, va" + vaPos + ", vc" + vcModelToWorld + "\n" + // worldPosition = vertexPosition * modelToWorld
				"mov v" + varyingWorldPos + ", vt0\n" + // position = worldPosition
				"m44 op, va" + vaPos + ", vc" + vcProjection + "\n" + // outputPosition = worldPosition * worldToClipspace
				// normals
				//vec3 n = normalize (gl_NormalMatrix * gl_Normal);
				"mov vt1, va" + vaNormal + "\n" + // float4 temp1 = vertexNormal;
				"mov v" + varyingNormal + ".w, vt1.w\n"+
				"m33 v" + varyingNormal + ".xyz, vt1, vc" + vcModelToWorld + "\n" + // normal = worldNormal * modelToWorldIT;
				
				( m_normalMap != null ?
					//vec3 t = normalize (gl_NormalMatrix * tangent);
					"mov vt1, va" + vaTangent + "\n" + // float4 temp1 = vertexNormal;
					"mov v" + varyingTangent + ".w, vt1.w\n"+
					"m33 v" + varyingTangent + ".xyz, vt1, vc" + vcModelToWorld + "\n" // tangent = worldTangent * modelToWorldIT;
					: "" 
				) + 
				//vec3 b = cross (n, t); (in fragment shader)
				
				// TODO: normalMatrix
				
				"mov v" + varyingUV + ", va" + vaUV + "\n" // texcoord = vertexTexcoord
			);
			
			return _vertexProgram;
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			var SPOTCUTOFF:String = // spot cutoff
				"nrm ft4.xyz, ft0.xyz\n" + 
				"dp3 ft4.x, ft4.xyz, fc" + fcLightDirection + ".xyz\t\t\t\t//cos_cur_angle = dot(-L, D)\n" + 
				
				"sub ft3.w, ft4.x, fc" + fcLightCone + ".y\t\t\n" + 
				"mul ft3.w, ft3.w, fc" + fcLightCone + ".z\t\t\n" + 
				"sat ft3.w, ft3.w\n" + 
				
				// att = att * spot
				"mul ft3.z, ft3.z, ft3.w\n";
			
			var attenuation:String = // light distance attenuation
				"dp3 ft3.z, ft0.xyz, ft0.xyz\n" + // vt4 = dot(vt1,vt1) -->Attenuation Distance
				"sqt ft3.z, ft3.z\n" + // vt4 = sqrt(dot(vt1,vt1)) -->Attenuation Distance
				
				// vt5 = 1 / Kc + Kl * ft3 + Kq * ft3 * ft3
				"mul ft3.w, ft3.z, ft3.z\n" +
				"mul ft3.w, ft3.w, fc"+fcAttenuation+".z\n" + // Kq * ft3 * ft3
				"mul ft3.z, ft3.z, fc"+fcAttenuation+".y\n" + // Kl * ft3
				"add ft3.z, ft3.z, ft3.w\n" +
				"add ft3.z, ft3.z, fc"+fcAttenuation+".x\n" +
				"div ft3.z, fc"+fcZeroVec+".y, ft3.z\n";
			
			var TNB:String = 
				// ft7 - surface normal \'N\'
				"nrm ft7.xyz, v" + varyingNormal + ".xyz\n" + // float4 N = normalize( normal );
				"mov ft7.w, fc" + fcZeroVec + ".x\n" + 
				(m_normalMap?
					// ft5 - surface tangent \'T\' 
					"nrm ft5.xyz, v" + varyingTangent + ".xyz\n" + // float4 N = normalize( normal );
					"mov ft5.w, fc" + fcZeroVec + ".x\n" + 
					// ft6 - surface binormal \'B\' 
					"crs ft6.xyz, v" + varyingNormal + ".xyz,  v" + varyingTangent + ".xyz\n" + // float4 N = normalize( normal );
					"nrm ft6.xyz, ft6.xyz\n"+
					"mov ft6.w, fc" + fcZeroVec + ".x\n"
					:"")
			
			var normL:String = // normalize light
				(m_normalMap?
					// tbn L
					"mov ft4, ft0.xyz\n"+
					"m33 ft0.xyz, ft4.xyz, ft5\n"
					:"")+
				"nrm ft0.xyz, ft0\n" + // L = normalize( L );
				"mov ft0.w, fc" + fcZeroVec + ".x\n"; // L.w = 0.0;
			
			var view:String = // ft1 - view vector \'V\'
				"sub ft1, fc" + fcCameraPos + ", v" + varyingWorldPos + "\n" +  // float4 V = cameraPosition - position;
				
				(m_normalMap?
					// tbn V
					"mov ft4, ft1.xyz\n"+
					"m33 ft1.xyz, ft4.xyz, ft5\n" + 
					"mov ft7.xyz, ft2\n"
					:"")+
				
				"nrm ft1.xyz, ft1\n" +  // V = normalize( V );
				"mov ft1.w, fc" + fcZeroVec + ".x\n"; // V.w = 0;
			
			var light:String = // diffuse and specular light on ft3.xy
				"add ft1, ft0, ft1\n" + // float4 H = L + V;
				"nrm ft1.xyz, ft1\n" + // H = normalize( H );
				"mov ft1.w, fc" + fcZeroVec + ".x\n" + // H.w = 0.0;
				"dp3 ft3.x, ft7.xyz, ft0.xyz\n" + // float diffuseAmount = dot( N, L );
				
				"sat ft3.x, ft3.x\n" + // diffuseAmount = saturate( a );
				"dp3 ft3.y, ft7.xyz, ft1.xyz\n" + // float specularAmount = dot( N, H );
				"max ft3.y, ft3.y, fc" + fcZeroVec + ".x\n" + // specularAmount = max( a, 0.0 );
				"pow ft3.y, ft3.y, fc" + fcMaterial + ".y\n" // specularAmount = pow( a, specularExponent ); 
			
			var lambertCheck:String = // if ( diffuseAmount <= 0 ) specularAmount = 0; 
				"sub ft0.x, fc" + fcZeroVec + ".y, ft3.x\n" + // float temp = 1 - diffuseAmount;
				"slt ft0.x, ft0.x, fc" + fcZeroVec + ".y\n" + // temp = ( temp < 1 ) ? 1 : 0;
				"mul ft3.y, ft3.y, ft0.x\n" + // specularAmount *= temp;
				"mul ft0.x, ft3.x, fc"+fcZeroVec+".z\n" + // temp = diffuseAmount * 4
				"sat ft0.x, ft0.x\n" + // temp = saturate( temp )
				"mul ft3.y, ft3.y, ft0.x\n"  // specularAmount *= temp;
			
			var specularMapMip:String;
			if(m_specularMap){
				if(m_specularMap.mipmap){
					specularMapMip = "tex ft1.xyz, v" + varyingUV + ".xyyy, fs" + fsSpecularMap + "<2d, wrap,linear,miplinear>\n";
				}else{
					specularMapMip = "tex ft1.xyz, v" + varyingUV + ".xyyy, fs" + fsSpecularMap + "<2d, wrap,linear>\n";
				}
			}
			var specularMap:String = (m_specularMap ? 
				specularMapMip + 
				"mul ft5.xyz, ft5.xyz, ft1.xyz\n" // float4 specular = specularColor * specularAlpha;
				: "");	
			
			var normalMapMip:String;
			if(m_normalMap){
				if(m_normalMap.mipmap){
					normalMapMip = "tex ft2, v"+varyingUV+".xy, fs"+fsNormalMap+"<2d,wrap,linear,miplinear>\n"
				}else{
					normalMapMip = "tex ft2, v"+varyingUV+".xy, fs"+fsNormalMap+"<2d,wrap,linear>\n";
				}
			}
			
			var agal:String =  
				(m_normalMap? 
					normalMapMip + 
					"mul ft2.xyz, ft2.xyz, fc"+fcZeroVec+".www\n" + 
					"sub ft2.xyz, ft2.xyz, fc"+fcZeroVec+".yyy\n" 
					: "")+
				
				( _lightType == ELightType.DIRECTIONAL ?
					"// directional light \n"+
					TNB + 
					//**********
					// register ft0 = L
					"mov ft0, fc" + fcLightDirection + "\n" +//light direction
					//**********
					normL + 
					
					// register ft1 = V
					view + 
					
					// register ft1 = H
					light + 
					
					// register ft0 = conditional
					lambertCheck + 
					
					"mov ft2, fc" + fcLightColor + ".xyz\n" +
					
					// register ft0 = output
					"mul ft0, ft2, ft3.xxx\n" + // float4 diffuseLight = diffuseAmount * lightColor;
					"mul ft5, ft2, ft3.yyy\n"+ // float4 specularLight = specularAmount * lightColor;
					
					"mul ft0, ft0, fc" + fcMaterialDiffuse + "\n" + // diffuseLighting *= diffuseColor; 
					
					"mul ft5, ft5.xyz, fc" + fcMaterialSpecular + "\n" +// specularLighting *= specularColor;
					
					specularMap + 
					
					"add ft0, ft0, ft5\n" // color += specularLighting;
					
					: "") +
				( _lightType == ELightType.POINT ?
					"// point light \n"+
					
					TNB + 
					
					//**********
					// register ft0 = L
					"sub ft0, fc" + fcLightPosition + ", v"+varyingWorldPos+"\n" +//light direction
					//**********
					attenuation + 
					//**********
					normL + 
					
					// register ft1 = V
					view + 
					
					// register ft1 = H
					light + 
					
					// register ft0 = conditional
					lambertCheck + 
					
					"mul ft2, fc" + fcLightColor + ".xyz, ft3.zzz\n" + // float4 light = lightColor * att;
					
					// register ft0 = output
					"mul ft0, ft2, ft3.xxx\n" + // float4 diffuseLight = diffuseAmount * lightColor;
					"mul ft5, ft2, ft3.yyy\n"+ // float4 specularLight = specularAmount * lightColor;
					
					"mul ft0, ft0.xyz, fc" + fcMaterialDiffuse + ".xyz\n" + // diffuseLighting *= diffuseColor; 
					
					"mul ft5, ft5.xyz, fc" + fcMaterialSpecular + ".xyz\n" +// specularLighting *= specularColor;
					
					specularMap + 
					
					"add ft0, ft0, ft5\n" // color += specularLighting;
					
					: "") +
				
				( _lightType == ELightType.SPOT ?
					
					"// spot light \n"+
					
					TNB + 				
					
					//**********
					// register ft0 = L
					"sub ft0, fc" + fcLightPosition + ", v"+varyingWorldPos+"\n" +//light direction
					//**********
					attenuation +
					
					SPOTCUTOFF + 
					
					//**********
					normL + 
					
					// register ft1 = V
					view + 
					
					// register ft1 = H
					light + 
					
					// register ft0 = conditional
					lambertCheck + 
					
					"mul ft2, fc" + fcLightColor + ".xyz, ft3.zzz\n" + // float4 light = lightColor * att;
					
					// register ft0 = output
					"mul ft0, ft2, ft3.xxx\n" + // float4 diffuseLight = diffuseAmount * lightColor;
					"mul ft5, ft2, ft3.yyy\n"+ // float4 specularLight = specularAmount * lightColor;
					
					"mul ft0, ft0, fc" + fcMaterialDiffuse + "\n" + // diffuseLighting *= diffuseColor; 
					
					"mul ft5, ft5.xyz, fc" + fcMaterialSpecular + "\n" +// specularLighting *= specularColor;
					
					specularMap + 
					
					"add ft0, ft0, ft5\n" // color += specularLighting;		
					
					
					: "") + 
				
				"mov ft0.w, fc" + fcMaterialOpacity + ".x\n" +// color.w = opacity;
				
				"mov oc, ft0\n"; // outputColor = color;
			return ShaderUtils.fragmentAssambler.assemble( Context3DProgramType.FRAGMENT, agal );
		}
	}
}
