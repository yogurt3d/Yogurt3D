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
	import com.yogurt3d.core.lights.Light;
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
	import flash.utils.Dictionary;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class ShaderDiffuse extends Shader{
		
		private var m_normalMap:TextureMap;
		private var m_normalMapTexture:Dictionary;
		private var m_normalMapDirty:Boolean = false;
		private var m_normalMapConst:ShaderConstants;
		
		private var m_alphaMapConst:ShaderConstants;
		
		
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
		
		private var textureOpacityyMap:uint = 0;
		
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
		
		public function ShaderDiffuse(_alpha:Number = 1)
		{
			super();
			
			key = "Yogurt3DOriginalsShaderDiffuse";
			
			m_normalMapTexture = new Dictionary();
			
			params.blendEnabled			= true;
			params.blendSource			= Context3DBlendFactor.ONE;
			params.blendDestination		= Context3DBlendFactor.ONE;
			params.writeDepth			= false;
			params.depthFunction		= Context3DCompareMode.EQUAL;
			params.colorMaskEnabled		= true;
			params.colorMaskR			= true;
			params.colorMaskG			= true;
			params.colorMaskB			= true;
			params.colorMaskA			= false;
			params.culling				= Context3DTriangleFace.FRONT;
			params.loopCount			= 1;
			params.requiresLight				= true;
			
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.NORMAL, EVertexAttribute.BONE_DATA );
			
			params.vertexShaderConstants.push(new ShaderConstants(vcModelToWorld, EShaderConstantsType.MODEL_TRANSPOSED));
			
			params.vertexShaderConstants.push(new ShaderConstants(vcProjection, EShaderConstantsType.MVP_TRANSPOSED));
			
			params.vertexShaderConstants.push(new ShaderConstants(vcBoneMatrices, EShaderConstantsType.BONE_MATRICES));
			
			var _fragmentShaderConsts:ShaderConstants;
			
			_fragmentShaderConsts = new ShaderConstants(fcZeroVec, EShaderConstantsType.CUSTOM_VECTOR);
			_fragmentShaderConsts.vector			= Vector.<Number>([0,1,4,2]);			
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
						
			params.fragmentShaderConstants.push(new ShaderConstants(fcCameraPos, EShaderConstantsType.CAMERA_POSITION));
	
			params.fragmentShaderConstants.push(new ShaderConstants(fcLightDirection, EShaderConstantsType.LIGHT_DIRECTION));
					
			params.fragmentShaderConstants.push(new ShaderConstants(fcLightPosition, EShaderConstantsType.LIGHT_POSITION));
			
			_fragmentShaderConsts = new ShaderConstants(fcMaterial, EShaderConstantsType.CUSTOM_VECTOR);
			_fragmentShaderConsts.vector			= Vector.<Number>([0,30,0,0]);
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			params.fragmentShaderConstants.push(new ShaderConstants(fcLightColor, EShaderConstantsType.LIGHT_COLOR));
			
			params.fragmentShaderConstants.push(new ShaderConstants(fcMaterialDiffuse, EShaderConstantsType.MATERIAL_DIFFUSE_COLOR));
			
			params.fragmentShaderConstants.push(new ShaderConstants(fcMaterialSpecular, EShaderConstantsType.MATERIAL_SPECULAR_COLOR));
			
			params.fragmentShaderConstants.push(new ShaderConstants(fcAttenuation, EShaderConstantsType.LIGHT_ATTENUATION));
			
			m_alphaMapConst = new ShaderConstants(fcMaterialOpacity, EShaderConstantsType.CUSTOM_VECTOR);
			m_alphaMapConst.vector			= Vector.<Number>([_alpha,0,0,0]);
			params.fragmentShaderConstants.push(m_alphaMapConst);
					
			params.fragmentShaderConstants.push(new ShaderConstants(fcLightCone, EShaderConstantsType.LIGHT_CONE));
			
		}
		
		public function get opacity():Number{
			return m_alphaMapConst.vector[0];
		}
		
		public function set opacity(value:Number):void{
			m_alphaMapConst.vector[0] = value;
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
			
			if( m_normalMapDirty )
			{
				if( m_normalMap )
				{
					if( !m_normalMapConst )
					{
						m_normalMapConst = new ShaderConstants();
						m_normalMapConst.type				= EShaderConstantsType.TEXTURE;
						m_normalMapConst.firstRegister		= fsNormalMap;
						params.fragmentShaderConstants.push(m_normalMapConst);
					}
					m_normalMapConst.texture			= m_normalMap;
					
					if( attributes.indexOf( EVertexAttribute.TANGENT ) == -1 )
					{
						attributes.push( EVertexAttribute.TANGENT );
					}
					key = "Yogurt3DOriginalsShaderDiffuseWithNormalMap"+
						((m_normalMap.mipmap)?"withMipmap":"");
				}else{
					key = "Yogurt3DOriginalsShaderDiffuse";
					
					var popped:EVertexAttribute = attributes.pop();
					
					if( popped != EVertexAttribute.TANGENT ){
						attributes.push( popped );
					}
					
					if( m_normalMapConst )
					{
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_normalMapConst ), 1 );
						m_normalMapConst = null;
					}
				}
				m_normalMapDirty = false;
				
				disposeShaders();
			}
			
			return super.getProgram( _context3D, _lightType, _meshType );
		}
		
		public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			if( _meshKey == "SkinnedMesh")
			{
				var assembler:AGALMiniAssembler = new AGALMiniAssembler();
				
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
				return assembler.assemble(Context3DProgramType.VERTEX, 	code );
			}
			return new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, 
				"m44 v" + varyingWorldPos + ", va" + vaPos + ", vc" + vcModelToWorld + "\n" + // worldPosition = vertexPosition * modelToWorld
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
				
				"mov v" + varyingUV + ", va" + vaUV + "\n"// texcoord = vertexTexcoord
			);
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			// command count 6
			var SPOTCUTOFF:String = // spot cutoff
				"nrm ft4.xyz, ft0.xyz\n" + 
				"dp3 ft4.x, ft4.xyz, fc" + fcLightDirection + ".xyz\n" + //cos_cur_angle = dot(-L, D)
				
				"sub ft3.w, ft4.x, fc" + fcLightCone + ".y\n" + 
				"mul ft3.w, ft3.w, fc" + fcLightCone + ".z\n" + 
				"sat ft3.w, ft3.w\n" + 
				
				// att = att * spot
				"mul ft3.z, ft3.z, ft3.w\n";
			
			// command count 8
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
			
			// command count 1-5
			var TNB:String = 
				// ft7 - surface normal \'N\'
				"nrm ft7.xyz, v" + varyingNormal + ".xyz\n" + // float4 N = normalize( normal );
				
				(m_normalMap?
					//"// ft5 - surface tangent \'N\'\n" + 
					"nrm ft5.xyz, v" + varyingTangent + ".xyz\n" + // float4 N = normalize( normal );
					
					//"// ft6 - surface binormal \'N\'\n" + 
					"crs ft6.xyz, v" + varyingNormal + ".xyz,  v" + varyingTangent + ".xyz\n" + // float4 N = normalize( normal );
					"nrm ft6.xyz, ft6.xyz\n"
					:"")
			
			// command count 2-6
			var normL:String = // normalize light
				(m_normalMap?
					// tbn L
					"mov ft4, ft0.xyz\n"+
					"dp3 ft0.x, ft4.xyz, ft5.xyz\n" + 
					"dp3 ft0.y, ft4.xyz, ft6.xyz\n" + 
					"dp3 ft0.z, ft4.xyz, ft7.xyz\n"  
					:"")+
				"nrm ft0.xyz, ft0\n" + // L = normalize( L );
				"mov ft0.w, fc" + fcZeroVec + ".x\n"; // L.w = 0.0;
			
			// command count 3-8
			var view:String = // ft1 - view vector \'V\'
				"sub ft1, fc" + fcCameraPos + ", v" + varyingWorldPos + "\n" +  // float4 V = cameraPosition - position;
				
				(m_normalMap?
					// tbn V
					"mov ft4, ft1.xyz\n"+
					"dp3 ft1.x, ft4.xyz, ft5.xyz\n" + 
					"dp3 ft1.y, ft4.xyz, ft6.xyz\n" + 
					"dp3 ft1.z, ft4.xyz, ft7.xyz\n"  +
					"mov ft7.xyz, ft2\n"
					:"")+
				
				"nrm ft1.xyz, ft1\n" +  // V = normalize( V );
				"mov ft1.w, fc" + fcZeroVec + ".x\n"; // V.w = 0;
			
			// command count 2
			var light:String = // diffuse and specular light on ft3.xy
				
				"dp3 ft3.x, ft7.xyz, ft0.xyz\n" + // float diffuseAmount = dot( N, L );
				
				"sat ft3.x, ft3.x\n" // diffuseAmount = saturate( a );
			
			
			var agal:String =  
				(m_normalMap? 
					((!m_normalMap.mipmap)?"tex ft2, v"+varyingUV+".xy, fs"+fsNormalMap+"<2d,wrap,linear>\n":"tex ft2, v"+varyingUV+".xy, fs"+fsNormalMap+"<2d,wrap,linear,miplinear>\n")+ 
					"mul ft2.xyz, ft2.xyz, fc"+fcZeroVec+".www\n" + 
					"sub ft2.xyz, ft2.xyz, fc"+fcZeroVec+".yyy\n" 
					: "")+
				
				( _lightType == ELightType.DIRECTIONAL ?
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
					
					"mov ft2, fc" + fcLightColor + ".xyz\n" +
					
					// register ft0 = output
					"mul ft0, ft2, ft3.xxx\n" + // float4 diffuseLight = diffuseAmount * lightColor;
					
					
					"mul ft0, ft0, fc" + fcMaterialDiffuse + "\n" // diffuseLighting *= diffuseColor; 
					
					: "") +
				( _lightType == ELightType.POINT ?
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
					
					
					"mul ft2, fc" + fcLightColor + ".xyz, ft3.zzz\n" + // float4 light = lightColor * att;
					
					// register ft0 = output
					"mul ft0, ft2, ft3.xxx\n" + // float4 diffuseLight = diffuseAmount * lightColor;
					
					
					"mul ft0, ft0, fc" + fcMaterialDiffuse + "\n" // diffuseLighting *= diffuseColor; 
					
					: "") 
				+
				
				( _lightType == ELightType.SPOT ?
					
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
					
					
					"mul ft2, fc" + fcLightColor + ".xyz, ft3.zzz\n" + // float4 light = lightColor * att;
					
					// register ft0 = output
					"mul ft0, ft2, ft3.xxx\n" + // float4 diffuseLight = diffuseAmount * lightColor;
					
					"mul ft0, ft0.xyz, fc" + fcMaterialDiffuse + "\n"  // diffuseLighting *= diffuseColor; 
					
					
					: "") + 
				
				"mov ft0.w, fc" + fcMaterialOpacity + ".x\n" + // color.w = opacity;
				
				"mov oc, ft0"; // outputColor = color;\n
			return ShaderUtils.fragmentAssambler.assemble( Context3DProgramType.FRAGMENT, agal );
		}

	}
}
