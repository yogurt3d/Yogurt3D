/*
 * Yogurt3DRendererHelper.as
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
 
 
package com.yogurt3d.presets.renderers.helper
{
	import com.yogurt3d.core.cameras.interfaces.ICamera;
	import com.yogurt3d.core.geoms.SkeletalAnimatedMesh;
	import com.yogurt3d.core.geoms.SkinnedSubMesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderParameters;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	import com.yogurt3d.core.utils.MatrixUtils;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class Yogurt3DRendererHelper implements IRendererHelper
	{
		protected var registeredTextures:Vector.<uint> = new Vector.<uint>();
		
		private var m_modelMatrix					:Matrix3D				= new Matrix3D();
		private var m_viewMatrix					:Matrix3D				= new Matrix3D();
		private var m_projectionMatrix				:Matrix3D				= new Matrix3D();		
		private var m_modelViewMatrix				:Matrix3D				= new Matrix3D();
		private var m_viewProjectionMatrix			:Matrix3D				= new Matrix3D();
		private var m_modelViewProjectionMatrix		:Matrix3D				= new Matrix3D();
		
		private var m_tempMatrix		:Matrix3D				= new Matrix3D();
		private var m_spriteMatrix		:Matrix3D				= new Matrix3D();
		private var m_lastObject:ISceneObjectRenderable;
		
		
		private var setProgramConstantsFromMatrix:Function;
		private var setProgramConstantsFromVector:Function;

		private var constantFunctionLookup:Dictionary;
		/**
		 * @inheritDoc
		 * 
		 */		
		public function endScene():void{
			m_lastObject = null;
		}
		
		/**
		 * @inheritDoc
		 * @param _context3d
		 * 
		 */		
		public function clearTextures(_context3d:Context3D):void
		{
			for( var i:uint = 0; i < registeredTextures.length; i++) 
			{
				_context3d.setTextureAt(registeredTextures[i], null);
			}
			registeredTextures.splice(0,registeredTextures.length);
			return;
		}
		
		public function beginScene(_camera:ICamera=null):void
		{
			m_projectionMatrix.copyFrom( _camera.frustum.projectionMatrix );
			
			m_viewMatrix.copyFrom( _camera.transformation.matrixGlobal );
			m_viewMatrix.invert();
			
			m_viewProjectionMatrix.copyFrom( m_viewMatrix );
			m_viewProjectionMatrix.append( m_projectionMatrix );
		}
		
		public function Yogurt3DRendererHelper(){
			constantFunctionLookup = new Dictionary();
			
		}
		/**
		 * @inheritDoc
		 * @param _context3d
		 * @param _params
		 * @param _light
		 * @param _camera
		 * @param _object
		 * @param _subMesh
		 * 
		 */		
		public function setProgramConstants(_context3d:Context3D, _params:ShaderParameters, _light:Light=null, _camera:ICamera=null, _object:ISceneObjectRenderable=null, _subMesh:SubMesh = null):Boolean
		{
			clearTextures(_context3d);
			
			var material:Material = _object.material;
			
			if( m_lastObject != _object )
			{
				
				m_modelMatrix.copyFrom( _object.transformation.matrixGlobal );
				
				m_lastObject = _object;
			}
			setProgramConstantsFromMatrix = _context3d.setProgramConstantsFromMatrix;
			setProgramConstantsFromVector = _context3d.setProgramConstantsFromVector;
			
			// load vertex shader constants
			var i:int;
			var _shaderConstants:ShaderConstants;
			// for each shader constant
			var _len:uint = _params.vertexShaderConstants.length;
			for ( i = 0; i < _len; i++ ) {
				
				// get shader constants
				_shaderConstants = _params.vertexShaderConstants[i];
				// load constants according to type
				switch(_shaderConstants.type)
				{
					case EShaderConstantsType.MVP_TRANSPOSED:
						m_modelViewProjectionMatrix.copyFrom( m_modelMatrix );
						m_modelViewProjectionMatrix.append( m_viewProjectionMatrix );
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_modelViewProjectionMatrix, true	);
						break;
					case EShaderConstantsType.BONE_MATRICES:
						var _skinnedsubmesh:SkinnedSubMesh = _subMesh as SkinnedSubMesh
						if( _skinnedsubmesh != null )
						{
							for( var boneIndex:int = 0; boneIndex < _skinnedsubmesh.originalBoneIndex.length; boneIndex++)
							{	
								var originalBoneIndex:uint = _skinnedsubmesh.originalBoneIndex[boneIndex];
								m_tempMatrix.copyFrom( SkeletalAnimatedMesh(_object.geometry).bones[originalBoneIndex].transformationMatrix );
								setProgramConstantsFromVector( Context3DProgramType.VERTEX, _shaderConstants.firstRegister + (boneIndex*3), m_tempMatrix.rawData, 3 );
							}
						}
						break;
					case EShaderConstantsType.MODEL_TRANSPOSED:
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_modelMatrix, 			true	);
						break;
					case EShaderConstantsType.MODEL_VIEW_TRANSPOSED:
						m_modelViewMatrix.copyFrom( m_modelMatrix );	
						m_modelViewMatrix.append( m_viewMatrix );
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_modelViewMatrix, 		true	);
						break;
					
					case EShaderConstantsType.CUSTOM_VECTOR:
						setProgramConstantsFromVector( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, _shaderConstants.vector, Math.ceil(_shaderConstants.vector.length / 4)		);
						break;

					case EShaderConstantsType.VIEW_PROJECTION_TRANSPOSED:
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_viewProjectionMatrix, 	true	);
						break;

					case EShaderConstantsType.PROJECTION_TRANSPOSED:
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_projectionMatrix,		true	);
						break;
					
					case EShaderConstantsType.CUSTOM_MATRIX_TRANSPOSED:
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, _shaderConstants.matrix, 	true	);
						break;

					case EShaderConstantsType.MVP:
						m_modelViewProjectionMatrix.copyFrom( m_modelMatrix );
						m_modelViewProjectionMatrix.append( m_viewProjectionMatrix );
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_modelViewProjectionMatrix, false	);
						break;
					
					case EShaderConstantsType.PROJECTION:
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_projectionMatrix, 		false	);
						break;
					
					case EShaderConstantsType.MODEL:
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_modelMatrix, 			false	);
						break;
					case EShaderConstantsType.MODEL_VIEW:
						m_modelViewMatrix.copyFrom( m_modelMatrix );	
						m_modelViewMatrix.append( m_viewMatrix );
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_modelViewMatrix, 		false	);
						break;
					case EShaderConstantsType.VIEW_PROJECTION:
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_viewProjectionMatrix, 	false	);
						break;
					
					case EShaderConstantsType.CAMERA_POSITION:
						var pos:Vector3D = _camera.transformation.matrixGlobal.position;
						setProgramConstantsFromVector( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, Vector.<Number>([ pos.x,pos.y,pos.z,1] ), 	1);
						break;
					
					case EShaderConstantsType.CUSTOM_MATRIX:
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, _shaderConstants.matrix, 	false	);
						break;
					
					
					case EShaderConstantsType.MATERIAL_EMISSIVE_COLOR:
						setProgramConstantsFromVector( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, material.emissiveColor.getColorVector(),1	);
						break;	
					
					case EShaderConstantsType.MATERIAL_AMBIENT_COLOR:
						setProgramConstantsFromVector( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, material.ambientColor.getColorVector(),1);
						break;	
					
					case EShaderConstantsType.MATERIAL_DIFFUSE_COLOR:
						setProgramConstantsFromVector( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, material.diffuseColor.getColorVector(),	1 );
						break;	
					
					case EShaderConstantsType.MATERIAL_SPECULAR_COLOR:
						setProgramConstantsFromVector( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, material.specularColor.getColorVector(),	1	);
						break;
					
					case EShaderConstantsType.LIGHT_COLOR:
						setProgramConstantsFromVector( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, _light.color.getColorVector(), 1);
						break;	
					
					case EShaderConstantsType.LIGHT_POSITION:
						setProgramConstantsFromVector( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, _light.positionVector, 	1		);
						break;	
					
					case EShaderConstantsType.LIGHT_ATTENUATION:
						setProgramConstantsFromVector( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, _light.attenuation, 		1 		);
						break;	
					
					case EShaderConstantsType.LIGHT_DIRECTION:
						setProgramConstantsFromVector( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, _light.directionVector, 	1		);
						break;
					case EShaderConstantsType.LIGHT_CONE:
						setProgramConstantsFromVector( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister,  _light.coneAngles, 		1 		);
						break;
					
					case EShaderConstantsType.LIGHT_VIEW:
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, _light.transformation.matrixGlobal,	false	);
						break;
					case EShaderConstantsType.LIGHT_VIEW_TRANSPOSED:
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, _light.transformation.matrixGlobal,	true	);
						break;
					case EShaderConstantsType.LIGHT_PROJECTION:
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, _light.frustum.projectionMatrix,				false	);
						break;
					case EShaderConstantsType.LIGHT_VIEW_PROJECTION_TRANSPOSED:
						m_tempMatrix.copyFrom( _light.transformation.matrixGlobal );
						if(_light.type == ELightType.DIRECTIONAL)
							m_tempMatrix.position = new Vector3D(0,0,0);
						m_tempMatrix.invert();
						m_tempMatrix.prepend(_object.transformation.matrixGlobal);
						if(_light.type != ELightType.POINT)
							m_tempMatrix.append( _light.frustum.projectionMatrix );
						
						
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_tempMatrix,							true	);
						break;
					case EShaderConstantsType.LIGHT_PROJECTION_TRANSPOSED:
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, _light.frustum.projectionMatrix,				true	);
						break;
					case EShaderConstantsType.SKYBOX_MATRIX_TRANSPOSED:
						m_tempMatrix.copyFrom(_camera.transformation.matrixGlobal);
						m_tempMatrix.position = new Vector3D(0,0,0);
						m_tempMatrix.invert();
						m_tempMatrix.append( m_projectionMatrix );
						
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_tempMatrix,							true	);
						break;
					case EShaderConstantsType.SPRITE_MATRIX:
						// for 3d sprites that faces the camera
						m_spriteMatrix = new Matrix3D();
						
						m_spriteMatrix.copyFrom(m_modelMatrix);
						//				var pos:Vector3D = _object.transformation.position.clone();
						//				var scale:Vector3D = new Vector3D(_object.transformation.scaleX, 
						//					_object.transformation.scaleY,_object.transformation.scaleZ);
						
						// kill x and y rotations
						var decomposedMatrix:Vector.<Vector3D> = m_spriteMatrix.decompose();
						var objRotation:Vector3D = decomposedMatrix[1];
						objRotation.x = objRotation.y = 0;
						m_spriteMatrix.recompose(decomposedMatrix);
						
						var viewMatrix:Matrix3D = m_viewMatrix.clone();
						decomposedMatrix = viewMatrix.decompose();
						var camRotation:Vector3D = decomposedMatrix[1];
						camRotation.x = camRotation.y = camRotation.z = 0;
						viewMatrix.recompose(decomposedMatrix);
						
						//m_spriteMatrix.appendTranslation(pos.x, pos.y, pos.z);
						//m_spriteMatrix.appendScale(scale.x, scale.y, scale.z);
						
						m_spriteMatrix.append(viewMatrix);
						m_spriteMatrix.append(m_projectionMatrix);
						
						setProgramConstantsFromMatrix( 	Context3DProgramType.VERTEX, _shaderConstants.firstRegister, m_spriteMatrix, true);
						break;
					default:
						trace("ShaderConstant Not implemented" + _shaderConstants.type + "\n");
						return false;
						break;
					
				}
				
			}	
			
			// for each fragment shader constant
			for (i = 0; i < _params.fragmentShaderConstants.length; i++) {
				// get shader constants
				_shaderConstants = _params.fragmentShaderConstants[i];
				
				// load constants according to type
				switch(_shaderConstants.type)
				{
					case EShaderConstantsType.TEXTURE:
						var _texture:TextureBase = _shaderConstants.texture.getTexture3D(_context3d);
						if( _texture == null ) { return false; }
						_context3d.setTextureAt( _shaderConstants.firstRegister, _texture );
						registeredTextures.push( _shaderConstants.firstRegister );
						break;

					case EShaderConstantsType.CUSTOM_VECTOR:
						setProgramConstantsFromVector( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, _shaderConstants.vector, Math.ceil(_shaderConstants.vector.length / 4) );
						break;	

					case EShaderConstantsType.LIGHT_POSITION:
						setProgramConstantsFromVector( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, _light.positionVector, 1 );
						break;	
					
					case EShaderConstantsType.LIGHT_ATTENUATION:
						setProgramConstantsFromVector( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, _light.attenuation, 1 );
						break;	
					
					case EShaderConstantsType.LIGHT_DIRECTION:
						setProgramConstantsFromVector( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, 	_light.directionVector, 1);
						break;	
					case EShaderConstantsType.LIGHT_CONE:
						setProgramConstantsFromVector( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, _light.coneAngles, 1 );
						break;
					
					case EShaderConstantsType.LIGHT_COLOR:
						setProgramConstantsFromVector( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, _light.color.getColorVector(), 1);
						break;	
					
					case EShaderConstantsType.LIGHT_SHADOW_COLOR:
						setProgramConstantsFromVector( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, _light.shadowColor.getColorVectorRaw(), 1);
						break;	
					
					case EShaderConstantsType.MVP:
						setProgramConstantsFromMatrix( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, m_modelViewProjectionMatrix, false);
						break;
					
					case EShaderConstantsType.MVP_TRANSPOSED:
						setProgramConstantsFromMatrix( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, m_modelViewProjectionMatrix, true);
						break;	
					
					case EShaderConstantsType.MODEL:
						setProgramConstantsFromMatrix( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, m_modelMatrix, false);
						break;
					
					case EShaderConstantsType.MODEL_TRANSPOSED:
						setProgramConstantsFromMatrix( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, m_modelMatrix, true);
						break;
					
					case EShaderConstantsType.MODEL_VIEW:
						setProgramConstantsFromMatrix( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, m_modelViewMatrix, false);
						break;
					
					case EShaderConstantsType.MODEL_VIEW_TRANSPOSED:
						setProgramConstantsFromMatrix( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, m_modelViewMatrix, true);
						break;

					case EShaderConstantsType.CUSTOM_MATRIX:
						setProgramConstantsFromMatrix( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, _shaderConstants.matrix, false	);
						break;
					
					case EShaderConstantsType.CAMERA_POSITION:
						var pos1:Vector3D = _camera.transformation.globalPosition;
						setProgramConstantsFromVector( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, Vector.<Number>([ pos1.x,pos1.y,pos1.z,1] ), 	1);
						break;	
	
					case EShaderConstantsType.MATERIAL_EMISSIVE_COLOR:
						setProgramConstantsFromVector( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, material.emissiveColor.getColorVector(),1	);
						break;	
					
					case EShaderConstantsType.MATERIAL_AMBIENT_COLOR:
						setProgramConstantsFromVector( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, material.ambientColor.getColorVector(),1);
						break;	
					
					case EShaderConstantsType.MATERIAL_DIFFUSE_COLOR:
						setProgramConstantsFromVector( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, material.diffuseColor.getColorVector(),	1 );
						break;	
					
					case EShaderConstantsType.MATERIAL_SPECULAR_COLOR:
						setProgramConstantsFromVector( 	Context3DProgramType.FRAGMENT, _shaderConstants.firstRegister, material.specularColor.getColorVector(),	1	);
						break;	
					
					
					case EShaderConstantsType.LIGHT_SHADOWMAP_TEXTURE:
						_context3d.setTextureAt( _shaderConstants.firstRegister, 	_light.shadowMap.getTexture3D(_context3d)	);
						registeredTextures.push( _shaderConstants.firstRegister );
						break;
					
					
					default:
						trace("ShaderConstant Not implemented: " + _shaderConstants.type);
						return false;
						break;
				}
			}
			return true;
		}
	}
}
