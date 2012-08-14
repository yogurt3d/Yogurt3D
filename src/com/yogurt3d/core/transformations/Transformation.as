/*
 * Transformation.as
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
 
 
package com.yogurt3d.core.transformations {
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	import com.yogurt3d.core.sceneobjects.SceneObject;
	import com.yogurt3d.core.utils.MathUtils;
	import com.yogurt3d.core.utils.MatrixUtils;
	
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;
	
	import org.osflash.signals.Signal;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class Transformation extends EngineObject 
	{
		use namespace YOGURT3D_INTERNAL;
		
		YOGURT3D_INTERNAL var m_ownerSceneObject					:SceneObject;
		YOGURT3D_INTERNAL var m_parentGlobalMatrix					:Matrix3D;
		
		YOGURT3D_INTERNAL var m_isLocalDirty						:Boolean;
		YOGURT3D_INTERNAL var m_isGlobalDirty						:Boolean;
		
		YOGURT3D_INTERNAL var m_matrixLocal							:Matrix3D;
		YOGURT3D_INTERNAL var m_matrixGlobal						:Matrix3D;

		private var m_x												:Number;
		private var m_y												:Number;
		private var m_z												:Number;

		private var m_rotation										:Vector3D;
		private var m_temprotation									:Vector3D;
		
		private var m_scale											:Vector3D;
		
		private var m_decomposedMatrix								:Vector.<Vector3D>;
		
		YOGURT3D_INTERNAL var m_onChange							: Signal;
		
		YOGURT3D_INTERNAL var m_isAddedToSceneRefreshList:Boolean 	= false;
		
		/**
		 * 
		 */
		public function Transformation(_owner:SceneObject)
		{
			super(true);
			
			m_ownerSceneObject = _owner;
		}
		
		
		
		public function get onChange():Signal
		{
			return YOGURT3D_INTERNAL::m_onChange;
		}

		/**
		 * Calculates local matrix from transformation properties
		 */
		private function calculateLocalMatrix() : void {
			m_decomposedMatrix[0].x = m_x;
			m_decomposedMatrix[0].y = m_y;
			m_decomposedMatrix[0].z = m_z;
			
			m_temprotation.copyFrom( m_rotation );
			m_temprotation.scaleBy( MathUtils.DEG_TO_RAD );
				
			m_decomposedMatrix[1] = m_temprotation;
			
			m_decomposedMatrix[2] = m_scale;
			
			m_matrixLocal.recompose( m_decomposedMatrix, Orientation3D.EULER_ANGLES );
			
			m_isLocalDirty = false;
		}		
		
		/**
		 * Returns clean global matrix
		 */
		public function get matrixGlobal():Matrix3D {
			if (m_isGlobalDirty) calculateGlobalMatrix();
			
			return m_matrixGlobal;
		}
		
		/**
		 * Calculates global transformation matrix
		 */
		protected function calculateGlobalMatrix():void {
			
			if (!m_ownerSceneObject.parent) {
				// if owner is not in a container, then global matrix equals to matrix local 
				m_matrixGlobal.copyFrom( matrixLocal );
			} else {
				// if owner is in a container, prepend container's transformation to local transformation matrix
				m_matrixGlobal.copyFrom( m_ownerSceneObject.parent.transformation.matrixGlobal );
				m_matrixGlobal.prepend( matrixLocal );
			}
			
			m_isGlobalDirty = false;		
		}
		
		/**
		 * Invalidates local and global transformation matrices
		 */
		public function invalidate():void {
			m_isLocalDirty 		= true;
			m_isGlobalDirty 	= true;	
			
			m_onChange.dispatch( this );
			
			invalidateChildren();	
		}		
		
		/**
		 * If owner is a container, invalidates the global matrix of children
		 */
		YOGURT3D_INTERNAL function invalidateChildren():void {
			if ( !m_ownerSceneObject ) return;
			
			var _children		:Vector.<SceneObject>	= m_ownerSceneObject.children;
			if ( !_children ) return;
			
			var _childrenCount	:int					= _children.length;
			
			for( var i:int; i < _childrenCount; i++ )
			{
				_children[i].transformation.m_isGlobalDirty = true;
				_children[i].transformation.m_onChange.dispatch( _children[i].transformation );
				
				_children[i].transformation.invalidateChildren();
			}				
		}		
		
		/**
		 * Sets transformation properties from local transformation matrix
		 * 
		 * Used when local matrix is changed directly
		 */
		YOGURT3D_INTERNAL function setPropertiesFromMatrix():void {
			m_decomposedMatrix = m_matrixLocal.decompose( Orientation3D.EULER_ANGLES ); 
			
			m_x = m_decomposedMatrix[0].x;
			m_y = m_decomposedMatrix[0].y;
			m_z = m_decomposedMatrix[0].z;
			
			m_rotation = m_decomposedMatrix[1];
			m_rotation.scaleBy( MathUtils.RAD_TO_DEG );
			
			m_scale = m_decomposedMatrix[2];
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function initInternals():void {
			
			m_decomposedMatrix		= Vector.<Vector3D>([new Vector3D(), new Vector3D(), new Vector3D()]);
			
			m_matrixLocal 			= new Matrix3D();
			
			m_matrixGlobal 			= new Matrix3D();
			
			m_isGlobalDirty			= true;
			m_isLocalDirty			= true;
			
			m_x = 0;
			m_y = 0;
			m_z = 0;

			m_rotation = new Vector3D();
			m_temprotation = new Vector3D();
			
			m_scale = new Vector3D(1,1,1);
			
			if( !m_onChange )
			{
				m_onChange 				= new Signal( Transformation );
			}
			m_onChange.dispatch(this);
		}

		/**
		 * Returns a new Vector3D object containing local position. <br/>
		 * If value in the Vector3D object is changed it does not effect the transformation.
		 * @return 
		 * 
		 */
		public function get position():Vector3D{
			return matrixLocal.position.clone();
		}
		
		public function set position(_value:Vector3D):void{
			m_x = _value.x;
			m_y = _value.y;
			m_z = _value.z;
			
			invalidate();
		}
		
		/**
		 * Returns a new Vector3D object containing global position. <br/>
		 * @return 
		 * 
		 */
		public function get globalPosition():Vector3D{
			return matrixGlobal.position.clone();
		}
		
		
		/**
		 * Position of object along x axis of parent
		 */
		public function get x():Number  {
			return m_x;
		}
		
		/**
		 * @private
		 */
		public function set x(_value:Number):void  {
			m_x = _value;
			
			invalidate();
		}
		
		/**
		 * Position of object along y axis of parent
		 */
		public function get y():Number  {
			return m_y;
		}
		
		
		/**
		 * @private
		 */
		public function set y(_value:Number):void  {
			m_y = _value;
			
			invalidate();
		}

		/**
		 * Position of object along z axis of parent
		 */
		public function get z():Number  {
			return m_z;
		}
		
		
		/**
		 * @private
		 */
		public function set z(_value:Number):void  {
			m_z = _value;
			
			invalidate();
		}
		
		/**
		 * Move the object along it's local axises (axises after rotation is applied) 
		 * @param x Translation along local x axis
		 * @param y Translation along local y axis
		 * @param z Translation along local z axis
		 * 
		 */
		public function moveAlongLocal( x:Number, y:Number, z:Number ):void{
			matrixLocal.prependTranslation( x,y,z );
			
			m_decomposedMatrix = m_matrixLocal.decompose( Orientation3D.EULER_ANGLES ); 
			
			m_x = m_decomposedMatrix[0].x;
			m_y = m_decomposedMatrix[0].y;
			m_z = m_decomposedMatrix[0].z;
			
			invalidate();
		}
		
		/**
		 * Rotation of object around X axis of parent
		 */
		public function get rotationX():Number {
			return m_rotation.x;
		}

		
		/**
		 * @private
		 */
		public function set rotationX(_value:Number):void {
			m_rotation.x = _value % 360;
			
			invalidate();
		}
		
		/**
		 * Rotation of object around Y axis of parent
		 */
		public function get rotationY():Number {
			return m_rotation.y;
		}

		
		/**
		 * @private
		 */
		public function set rotationY(_value:Number):void {
			m_rotation.y = _value % 360;
			
			invalidate();
		}
		
		/**
		 * Rotation of object around Z axis of parent
		 */
		public function get rotationZ():Number {
			return m_rotation.z;
		}

		
		
		/**
		 * @private
		 */
		public function set rotationZ(_value:Number):void {
			m_rotation.z = _value % 360;
			
			invalidate();
		}

		/**
		 * Sets the scale values of the transformation ( scaleX, scaleY, scaleZ )
		 * @param _scale new scale value
		 * 
		 */
		public function set scale(_scale:Number):void {
			m_scale.setTo( _scale, _scale, _scale );
			
			invalidate();
		}
		
		/**
		 * Set scale of object along X axis of parent
		 */
		public function get scaleX():Number {
			return m_scale.x;
		}		
		
		/**
		 * @private
		 */
		public function set scaleX(_value:Number):void {
			m_scale.x = _value;
			
			invalidate();
		}
		
		/**
		 * Set scale of object along Y axis of parent
		 */
		public function get scaleY():Number {
			return m_scale.y;
		}
		
		/**
		 * @private
		 */
		public function set scaleY(_value:Number):void {
			m_scale.y = _value;
			
			invalidate();
		}		
		
		/**
		 * Set scale of object along Z axis of parent
		 */
		public function get scaleZ():Number {
			return m_scale.z;
		}
		
		/**
		 * @private
		 */
		public function set scaleZ(_value:Number):void {
			m_scale.z = _value;
			
			invalidate();
		}
		
		/**
		 *  Returns clean local transformation matrix
		 */
		public function get matrixLocal():Matrix3D {
			if (m_isLocalDirty) {
				calculateLocalMatrix();
			} 
			return m_matrixLocal;
		}
		
		/**
		 *  Sets local transformation matrix
		 */
		public function set matrixLocal(_value:Matrix3D):void {
			m_matrixLocal.copyFrom( _value );
			setPropertiesFromMatrix();
			invalidate();
		}
		
		/**
		 * Returns if local or global matrix is invalid
		 */
		public function get isDirty():Boolean {
			return m_isGlobalDirty || m_isLocalDirty;
		}
		
		/**
		 * 
		 */
		public function lookAt(_target : Vector3D, _at : Vector3D = null, _up : Vector3D = null): void {
			if(  matrixGlobal.position.z == _target.z ) {
				_target.z += 0.00001;
			}
			if(  matrixGlobal.position.y == _target.y ) {
				_target.y += 0.00001;
			}
			if(  matrixGlobal.position.x == _target.x ) {
				_target.x += 0.00001;
			}
			
			var _tempMatrix:Matrix3D = MatrixUtils.TEMP_MATRIX;
			_tempMatrix.identity();
			_tempMatrix.position = matrixGlobal.position;
			_tempMatrix.pointAt( _target, _at || MathUtils.AT_VECTOR, _up || MathUtils.UP_VECTOR );
			var _rot : Vector3D = _tempMatrix.decompose(Orientation3D.QUATERNION)[1];
			
			var m_quaternion:Quaternion = new Quaternion();
			
			m_quaternion.setTo( _rot.w, _rot.x, _rot.y, _rot.z );
			
			m_quaternion.toEuler(m_rotation);
			
			invalidate();
		}
		
		/**
		 * 
		 */
		public function lookAtLocal(_target : Vector3D, _at : Vector3D = null, _up : Vector3D = null): void {
			if(  matrixLocal.position.z == _target.z ) {
				_target.z += 0.00001;
			}
			if(  matrixLocal.position.y == _target.y ) {
				_target.y += 0.00001;
			}
			if(  matrixLocal.position.x == _target.x ) {
				_target.x += 0.00001;
			}
			var _tempMatrix:Matrix3D = MatrixUtils.TEMP_MATRIX;
			_tempMatrix.identity();
			_tempMatrix.position = matrixLocal.position;
			_tempMatrix.pointAt( _target, _at || MathUtils.AT_VECTOR, _up || MathUtils.UP_VECTOR );
			var _rot : Vector3D = _tempMatrix.decompose(Orientation3D.QUATERNION)[1];
			
			var m_quaternion:Quaternion = new Quaternion();
			
			m_quaternion.setTo( _rot.w, _rot.x, _rot.y, _rot.z );
			
			m_quaternion.toEuler(m_rotation);
			
			invalidate();
		}
		
		/**
		 * Creates new transformaiton object with the same properties as current transformation
		 * 
		 */
		override public function clone():IEngineObject {
			var _transformation : Transformation = new Transformation(null);
			_transformation.m_matrixGlobal.copyFrom( matrixGlobal );
			_transformation.m_matrixLocal.copyFrom( matrixLocal );
			_transformation.setPropertiesFromMatrix();
			_transformation.m_isGlobalDirty = true;
			_transformation.m_isLocalDirty = true;
			return _transformation;
		}
		
		public function copyTo(trans:Transformation):Transformation {
			trans.m_matrixGlobal.copyFrom( matrixGlobal );
			trans.m_matrixLocal.copyFrom( matrixLocal );
			trans.setPropertiesFromMatrix();
			trans.m_isGlobalDirty = true;
			trans.m_isLocalDirty = true;
			return trans;
		}
		
		/**
		 * Resets transformation properties
		 */
		override public function renew():void {
			initInternals();
		}
		
		public function get xAxis():Vector3D {
			var vec:Vector3D = new Vector3D();
			matrixGlobal.copyColumnTo( 0, vec );
			return vec;
		}
		
		public function get yAxis():Vector3D {
			var vec:Vector3D = new Vector3D();
			matrixGlobal.copyColumnTo( 1, vec );
			return vec;
		}
		
		public function get zAxis():Vector3D {
			var vec:Vector3D = new Vector3D();
			matrixGlobal.copyColumnTo( 2, vec );
			return vec;
		}
		
		public function copyMatrixFrom(_matrixLocal:Matrix3D):void{
			m_matrixLocal.copyFrom(_matrixLocal);
			this.setPropertiesFromMatrix();
			this.invalidate();
		}
		
		protected override function trackObject():void
		{
			IDManager.trackObject(this, Transformation);
		}
		
		public override function dispose():void{
			m_onChange.removeAll();
			m_onChange = null;
		}
	}
}
