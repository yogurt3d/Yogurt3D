/*
 * EShaderConstantsType.as
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
 
 
package com.yogurt3d.core.materials.shaders.renderstate
{
	import com.yogurt3d.core.utils.Enum;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class EShaderConstantsType extends Enum
	{
		{initEnum(EShaderConstantsType);}	
		
		public static const TEXTURE								:EShaderConstantsType = new EShaderConstantsType();
		
		/**
		 * Cameras Projection Matrix 
		 */
		public static const PROJECTION							:EShaderConstantsType = new EShaderConstantsType();
		
		/**
		 * Cameras Projection Matrix Transposed
		 */
		public static const PROJECTION_TRANSPOSED				:EShaderConstantsType = new EShaderConstantsType();
		/**
		 * Objects Global Matrix 
		 */
		public static const MODEL								:EShaderConstantsType = new EShaderConstantsType();
		/**
		 * Objects Global Matrix Transposed
		 */
		public static const MODEL_TRANSPOSED					:EShaderConstantsType = new EShaderConstantsType();
		/**
		 * Camera's GlobalMatrix inv * Objects GlobalMatrix 
		 */		
		public static const MODEL_VIEW							:EShaderConstantsType = new EShaderConstantsType();
		/**
		 * Camera's GlobalMatrix inv * Objects GlobalMatrix  Transposed
		 */		
		public static const MODEL_VIEW_TRANSPOSED				:EShaderConstantsType = new EShaderConstantsType();
		
		public static const VIEW_PROJECTION						:EShaderConstantsType = new EShaderConstantsType();
		
		public static const VIEW_PROJECTION_TRANSPOSED			:EShaderConstantsType = new EShaderConstantsType();
		
		public static const BONE_MATRICES						:EShaderConstantsType = new EShaderConstantsType();
		public static const BONE_MATRICES_TRANSPOSED			:EShaderConstantsType = new EShaderConstantsType();
		/**
		 * Camera's Projection * Camera's GlobalMatrix inv * Objects GlobalMatrix 
		 */		
		public static const MVP									:EShaderConstantsType = new EShaderConstantsType();
		
		/**
		 * Camera's Projection * Camera's GlobalMatrix inv * Objects GlobalMatrix Transposed
		 */		
		public static const MVP_TRANSPOSED						:EShaderConstantsType = new EShaderConstantsType();
		
		/**
		 * Cameras Projection Matrix Transposed
		 */
		
		public static const SPRITE_MATRIX						:EShaderConstantsType = new EShaderConstantsType();
		
		
		public static const LIGHT_VIEW							:EShaderConstantsType = new EShaderConstantsType();
		public static const LIGHT_VIEW_TRANSPOSED				:EShaderConstantsType = new EShaderConstantsType();
		public static const LIGHT_PROJECTION					:EShaderConstantsType = new EShaderConstantsType();
		public static const LIGHT_PROJECTION_TRANSPOSED			:EShaderConstantsType = new EShaderConstantsType();
		public static const LIGHT_VIEW_PROJECTION_TRANSPOSED	:EShaderConstantsType = new EShaderConstantsType();
		
		
		public static const LIGHT_POSITION						:EShaderConstantsType = new EShaderConstantsType();
		public static const LIGHT_DIRECTION						:EShaderConstantsType = new EShaderConstantsType();
		// TODO: delete
		public static const LIGHT_COLOR							:EShaderConstantsType = new EShaderConstantsType();
		public static const LIGHT_SHADOW_COLOR					:EShaderConstantsType = new EShaderConstantsType();
		public static const LIGHT_ATTENUATION					:EShaderConstantsType = new EShaderConstantsType();
		
		public static const LIGHT_CONE							:EShaderConstantsType = new EShaderConstantsType();
		
		public static const MATERIAL_EMISSIVE_COLOR				:EShaderConstantsType = new EShaderConstantsType();
		public static const MATERIAL_AMBIENT_COLOR				:EShaderConstantsType = new EShaderConstantsType();
		public static const MATERIAL_DIFFUSE_COLOR				:EShaderConstantsType = new EShaderConstantsType();
		public static const MATERIAL_SPECULAR_COLOR				:EShaderConstantsType = new EShaderConstantsType();
		
		
		public static const LIGHT_SHADOWMAP_TEXTURE 			:EShaderConstantsType = new EShaderConstantsType();
		
		public static const CAMERA_POSITION						:EShaderConstantsType =new EShaderConstantsType();
		public static const CAMERA_VIEW							:EShaderConstantsType = new EShaderConstantsType();
		public static const CAMERA_VIEW_TRANSPOSED				:EShaderConstantsType = new EShaderConstantsType();
		public static const SKYBOX_MATRIX_TRANSPOSED			:EShaderConstantsType = new EShaderConstantsType();
		
		public static const CUSTOM_VECTOR						:EShaderConstantsType = new EShaderConstantsType();
		public static const CUSTOM_MATRIX						:EShaderConstantsType =new EShaderConstantsType();
		public static const CUSTOM_MATRIX_TRANSPOSED			:EShaderConstantsType = new EShaderConstantsType();
		
		}
}
