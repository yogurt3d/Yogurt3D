/*
 * Bone.as
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
 
 
package com.yogurt3d.core.geoms {
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	import com.yogurt3d.core.transformations.Quaternion;
	import com.yogurt3d.core.transformations.Transformation;
	import com.yogurt3d.core.utils.MatrixUtils;
	
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;
	
	use namespace YOGURT3D_INTERNAL;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class Bone
	{
		/**
		 *  
		 */
		[Deprecated("Not used since v2.0")]
		public var id			:int;
		/**
		 * 
		 */		
		public var name			:String;
		/**
		 * 
		 */
		[Deprecated("Not used since v2.0")]
		public var parentId		:int;
		/**
		 * 
		 */
		public var parentName	:String;
		/**
		 * 
		 */		
		[Deprecated("Not used since v2.0")]
		public var rootHeight	:Number;
		
		private var m_translation	:Vector3D;
		private var m_rotation		:Quaternion;
		private var m_scale		:Vector3D;
		
		/**
		 * Inverse of the bind pose translation
		 */
		public var invTranslation	:Vector3D;
		/**
		 * Inverse of the bind pose rotation
		 */
		public var invRotation		:Quaternion;
		/**
		 * Inverse of the bind pose scale
		 */
		public var invScale			:Vector3D;
		
		private var m_invMatrix		:Matrix3D;
		
		/**
		 * Indices of the bone 
		 */
		public var indices		:Vector.<uint>;
		/**
		 * Vertices of the bone
		 */
		[Deprecated("Not used since v2.0")]
		public var vertices		:Vector.<Number>;
		/**
		 * Weight values of the indices 
		 */
		public var weights		:Vector.<Number>;
		
		/**
		 * Child bone list 
		 */
		public var children:Vector.<Bone>;
		
		private var m_dirty:Boolean				= true;
		
		/**
		 * Current transformation matrix of the bone
		 */
		public var transformationMatrix:Matrix3D;
		
		public var parentBone:Bone;
		
		private var m_derivedScale:Vector3D;
		private var m_derivedRotation:Quaternion;
		private var m_derivedTranslation:Vector3D;
		
		private var m_observers:Vector.<Transformation>;
		YOGURT3D_INTERNAL var m_offsets:Vector.<Vector3D>;
		YOGURT3D_INTERNAL var m_translationoffsets:Vector.<Vector3D>;
		private var m_boneParentTransformation:Transformation;
		
		/**
		 *  
		 * @param _initInternals
		 * 
		 */
		public function Bone(_initInternals:Boolean=true)
		{
			transformationMatrix = new Matrix3D();
			children = new Vector.<Bone>();
		}
		
		/**
		 *  
		 * @return 
		 * 
		 */
		public function get scale():Vector3D
		{
			return m_scale;
		}

		/**
		 * @private 
		 * @param value
		 * 
		 */
		public function set scale(value:Vector3D):void
		{
			m_scale = value;
			invalidate();
		}

		/**
		 * 
		 * @return 
		 * 
		 */
		public function get rotation():Quaternion
		{
			return m_rotation;
		}

		/**
		 * @private 
		 * @param value
		 * 
		 */
		public function set rotation(value:Quaternion):void
		{
			m_rotation = value;
			invalidate();
		}

		/**
		 *  
		 * @return 
		 * 
		 */
		public function get translation():Vector3D
		{
			return m_translation;
		}

		/**
		 * @private 
		 * @param value
		 * 
		 */
		public function set translation(value:Vector3D):void
		{
			m_translation = value;
			invalidate();
		}

		/**
		 * Sets the current rotation, scale and translation values as bind pose. 
		 * 
		 */
		public function setBindingPose():void{
			
			invTranslation = getDerivedPosition().clone();
			invTranslation.negate();
			var _derivedScale:Vector3D = getDerivedScale();
			invScale = new Vector3D(1/_derivedScale.x,1/_derivedScale.y,1/_derivedScale.z );
			var qua:Quaternion = getDerivedOrientation();
			invRotation = getDerivedOrientation().inverse();
			//m_invMatrix = new Matrix3D();
			//m_invMatrix.recompose( Vector.<Vector3D>([invTranslation, invRotation.toVector3D(), invScale]), Orientation3D.QUATERNION );
		}
		
		/**
		 * @private 
		 * invalidates all the children bones
		 */
		private function invalidateChildren():void{
			for( var i:int = 0; i < children.length; i++)
			{
				children[i].invalidate();
			}
		}
		
		/**
		 * Invalides this bones rotation, translation and scale data, thus also marking all the children bones as dirty too.
		 * 
		 */
		public function invalidate():void{
			m_dirty = true;
			invalidateChildren();
		}
		
		/**
		 * Returns the derived rotation of the bone
		 * @return 
		 * 
		 */
		public function getDerivedOrientation():Quaternion{
			if( parentBone == null )
			{
				return rotation;
			}
			if( m_dirty )
			{
				return m_derivedRotation = parentBone.getDerivedOrientation().multiply( rotation );
			}
			return m_derivedRotation;
		}
		
		/**
		 * Returns the derived scale of the bone
		 * @return 
		 * 
		 */
		public function getDerivedScale():Vector3D{
			if( parentBone == null )
			{
				return scale;
			}
			if( m_dirty )
			{
				var _parentScale:Vector3D =  parentBone.getDerivedScale();
				return m_derivedScale = new Vector3D( _parentScale.x * scale.x, _parentScale.y * scale.y, _parentScale.z * scale.z );
			}
			return m_derivedScale;
		}
		
		/**
		 * Returns the derived position of the bone
		 * @return 
		 * 
		 */
		public function getDerivedPosition():Vector3D{
			if( parentBone == null )
			{
				return translation;
			}
			if( m_dirty )
			{
				var _parentScale:Vector3D = parentBone.getDerivedScale();
				var _derivedTranslation:Vector3D = parentBone.getDerivedOrientation().multiplyVector( 
					new Vector3D(   
						_parentScale.x * translation.x,
						_parentScale.y * translation.y,
						_parentScale.z * translation.z
					)
				);
				
				return m_derivedTranslation = _derivedTranslation.add( parentBone.getDerivedPosition() );
			}
			return m_derivedTranslation;
		}
		
		public function addObserver( _transformation:Transformation, _boneParentTransformation:Transformation, 
									 _rotationOffset:Vector3D = null, _translationOffset:Vector3D = null ):void{
			if( m_observers == null )
			{
				m_observers = new Vector.<Transformation>();
				m_offsets = new Vector.<Vector3D>();
				m_translationoffsets = new Vector.<Vector3D>();
				m_boneParentTransformation = _boneParentTransformation;
			}
			m_observers.push( _transformation );
			m_offsets.push( _rotationOffset );
			m_translationoffsets.push( _translationOffset );
			
			update();
		}
		
		public function removeObserver( _transformation:Transformation ):void{
			if( m_observers != null )
			{
				m_observers.splice( m_observers.indexOf(_transformation), 1 );
				if( m_observers.length == 0 )
				{
					m_observers = null;
				}
			}
		}
		
		/**
		 * Updates the bone using it's parent bone or uploads a specified matrix as the current transformation 
		 * @param _boneMatrix 
		 * @return 
		 * 
		 */
		public function update(_boneMatrix:Matrix3D = null):Matrix3D{
			if( _boneMatrix == null )
			{
				if( m_dirty )
				{
					// get the derived scale of the bone
					var _derivedScale:Vector3D = getDerivedScale();
					
					// find the current scale change by removing the bind pose scale from the currrent scale
					var locScale:Vector3D = new Vector3D( 
						_derivedScale.x * invScale.x, 
						_derivedScale.y * invScale.y, 
						_derivedScale.z * invScale.z 
					);
					
					// find the current rotation change by removing the bind pose rotation from the currrent rotation
					var _locRotate:Quaternion = getDerivedOrientation().multiply( invRotation );
					
					// Combine position with binding pose inverse position,
					// Note that translation is relative to scale & rotation,
					// so first reverse transform original derived position to
					// binding pose bone space, and then transform to current
					// derived bone space.
					var _locTranslate:Vector3D = getDerivedPosition().add(
						_locRotate.multiplyVector( 
							new Vector3D(   
								locScale.x * invTranslation.x,
								locScale.y * invTranslation.y,
								locScale.z * invTranslation.z
							)
						) 
					);
					transformationMatrix.recompose( Vector.<Vector3D>([_locTranslate, _locRotate.toVector3D(), locScale]), Orientation3D.QUATERNION);
					transformationMatrix.transpose();
					
					
					m_dirty = false;
				}
			}else{
				transformationMatrix.copyFrom( _boneMatrix );
			}
			if( m_observers )
			{
				for( var i:int = 0; i < m_observers.length; i++)
				{
					var mat:Matrix3D = MatrixUtils.TEMP_MATRIX;
					mat.copyFrom( m_boneParentTransformation.matrixGlobal );
					transformationMatrix.transpose();
					
					mat.prepend( transformationMatrix );
					if( m_translationoffsets[i] != null)
					{
						mat.prependTranslation( -invTranslation.x + m_translationoffsets[i].x, 
							-invTranslation.y + m_translationoffsets[i].y, 
							-invTranslation.z + m_translationoffsets[i].z);
					}else{
						mat.prependTranslation( -invTranslation.x, -invTranslation.y, -invTranslation.z );
					}
					
					var rot:Vector3D = invRotation.toEuler();
					if( m_offsets[i] != null)
					{
						mat.prependRotation( -rot.x +  m_offsets[i].x , Vector3D.X_AXIS);
						mat.prependRotation( -rot.y +  m_offsets[i].y, Vector3D.Y_AXIS);
						mat.prependRotation( -rot.z +  m_offsets[i].z, Vector3D.Z_AXIS);
					}else{
						mat.prependRotation( -rot.x , Vector3D.X_AXIS);
						mat.prependRotation( -rot.y , Vector3D.Y_AXIS);
						mat.prependRotation( -rot.z , Vector3D.Z_AXIS);
					}
					
					
					transformationMatrix.transpose();
					m_observers[i].matrixLocal = mat;
				}
			}
			return transformationMatrix;
		}
		
		/**
		 * Clones the bone. <br/>
		 * WARNING: parentBone and children are left empty 
		 * @return Returns a copy of this bone without it's parent and children
		 * 
		 */
		public function clone():Bone{
			var _newBone:Bone = new Bone();
			_newBone.indices = indices;
			_newBone.name = name;
			_newBone.parentName = parentName;
			_newBone.translation = translation.clone();
			_newBone.rotation = rotation.clone();
			_newBone.scale = scale.clone();
			_newBone.weights = weights;
			_newBone.transformationMatrix = transformationMatrix.clone();
			_newBone.invRotation = invRotation.clone();
			_newBone.invScale = invScale.clone();
			_newBone.invTranslation = invTranslation.clone();
			return _newBone;
		}
	}
}
