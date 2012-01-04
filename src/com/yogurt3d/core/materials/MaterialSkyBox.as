/*
 * MaterialSkyBox.as
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
 
package com.yogurt3d.core.materials
{
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.texture.CubeTextureMap;
	
	import flash.display.BitmapData;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class MaterialSkyBox extends Material
	{
		public function MaterialSkyBox(_texture:CubeTextureMap, _initInternals:Boolean=true)
		{
			super(_initInternals);
			shaders.push(new ShaderSkyBox(_texture) );
		}
		public function get texture():CubeTextureMap{
			return ShaderSkyBox(shaders[0]).texture;
		}
		public function set texture(_value:CubeTextureMap):void{
			ShaderSkyBox(shaders[0]).texture = _value;
		}
	}
}
import com.adobe.utils.AGALMiniAssembler;
import com.yogurt3d.core.lights.ELightType;
import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
import com.yogurt3d.core.materials.shaders.base.Shader;
import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
import com.yogurt3d.core.texture.CubeTextureMap;

import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Program3D;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

internal class ShaderSkyBox extends Shader
{
	private var m_texture:CubeTextureMap;
	
	private var m_textureConstant:ShaderConstants;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public function ShaderSkyBox( _texture:CubeTextureMap ){
		key = "Yogurt3DOriginalsShaderSkyBox";
		m_texture = _texture;
		
		params.blendEnabled			= false;
		params.blendSource			= Context3DBlendFactor.ONE;
		params.blendDestination		= Context3DBlendFactor.ZERO;
		params.writeDepth			= false;
		params.depthFunction		= Context3DCompareMode.ALWAYS;
		params.colorMaskEnabled		= true;
		params.colorMaskR			= true;
		params.colorMaskG			= true;
		params.colorMaskB			= true;
		params.colorMaskA			= false;
		params.culling				= Context3DTriangleFace.NONE;
		params.loopCount			= 1;
		params.requiresLight				= false;

		attributes.push( EVertexAttribute.POSITION );

		var _vertexShaderConsts:ShaderConstants;
		
		_vertexShaderConsts = new ShaderConstants();
		_vertexShaderConsts.type				= EShaderConstantsType.SKYBOX_MATRIX_TRANSPOSED;
		_vertexShaderConsts.firstRegister		= 1;
		
		params.vertexShaderConstants.push(_vertexShaderConsts);
		
		_vertexShaderConsts = new ShaderConstants();
		_vertexShaderConsts.type				= EShaderConstantsType.CUSTOM_VECTOR;
		_vertexShaderConsts.firstRegister		= 0;
		_vertexShaderConsts.vector = Vector.<Number>([1,0,0,0]);
		
		params.vertexShaderConstants.push(_vertexShaderConsts);
		
		m_textureConstant = new ShaderConstants();
		m_textureConstant.type				= EShaderConstantsType.TEXTURE;
		m_textureConstant.firstRegister		= 0;
		m_textureConstant.texture			= _texture;
		
		params.fragmentShaderConstants.push(m_textureConstant);
	}
	
	
	public function get texture():CubeTextureMap
	{
		return m_texture;
	}

	public function set texture(value:CubeTextureMap):void
	{
		m_texture = value;
		m_textureConstant.texture = value;
	}

			public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
		if( _meshKey.indexOf( "SkeletalAnimatedGPUMesh" ) > -1 )
		{
			throw new Error("TODO: SkyBoxes does not support SkeletalAnimatedMesh!");
		}
		return new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, 
			"m44 op, va0, vc1\n" + 
			"nrm vt0.xyz, va0.xyz\n" + 
			"mov vt0.w, vc0.x\n" + 
			"mov v0, vt0"
		);
	}
	
	public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
		return new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, 
			"tex oc, v0, fs0 <cube,linear,clamp>\n"
		);
	}
}
