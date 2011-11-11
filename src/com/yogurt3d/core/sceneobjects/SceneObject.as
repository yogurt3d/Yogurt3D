/*
 * SceneObject.as
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
 
 
package com.yogurt3d.core.sceneobjects {
	import com.yogurt3d.core.events.MouseEvent3D;
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.helpers.boundingvolumes.BoundingSphere;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.managers.scenetreemanager.SceneTreeManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObject;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	import com.yogurt3d.core.transformations.Transformation;
	import com.yogurt3d.core.utils.MatrixUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	import org.osflash.signals.Signal;

	/**
	 * <strong>ISceneObject</strong> interface abstract type.
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class SceneObject extends EngineObject implements ISceneObject
	{
		YOGURT3D_INTERNAL var m_transformation					: Transformation;
		
		YOGURT3D_INTERNAL var m_dispacther 						: EventDispatcher;
		
		YOGURT3D_INTERNAL var m_renderLayer						: int = 0;
		
		YOGURT3D_INTERNAL var m_isStatic						: Boolean;
		
		YOGURT3D_INTERNAL var m_aabb							:AxisAlignedBoundingBox;
		
		YOGURT3D_INTERNAL var m_boundingSphere					:BoundingSphere;
		
		YOGURT3D_INTERNAL var m_boundingVolumesDirty			:Boolean;
		YOGURT3D_INTERNAL var m_reinitboundingVolumes			:Boolean;
		
		YOGURT3D_INTERNAL var m_visible							:Boolean = true;
		
		YOGURT3D_INTERNAL var m_drawAABBWireFrame				:Boolean = false;
		
		// SIGNALS BEGIN
		YOGURT3D_INTERNAL var m_onStaticChanged					: Signal;
		
		YOGURT3D_INTERNAL var m_onRenderLayerChanged			: Signal;
		
		YOGURT3D_INTERNAL var m_onMouseUp						: Signal;
		
		YOGURT3D_INTERNAL var m_onMouseDown						: Signal;
		
		YOGURT3D_INTERNAL var m_onMouseMove						: Signal;
		
		YOGURT3D_INTERNAL var m_onMouseOver						: Signal;
		
		YOGURT3D_INTERNAL var m_onMouseOut						: Signal;
		
		YOGURT3D_INTERNAL var m_onMouseClick					: Signal;
		
		YOGURT3D_INTERNAL var m_onMouseDoubleClick				: Signal;
		
		YOGURT3D_INTERNAL var m_onAddedToScene   				: Signal;
		
		YOGURT3D_INTERNAL var m_onRemovedFromScene   			: Signal;
		//SIGNALS END
		
		
		use namespace YOGURT3D_INTERNAL;

		public function SceneObject(_initInternals:Boolean = true)
		{
			super(_initInternals);
		}

		public function get boundingSphere():BoundingSphere
		{
			return YOGURT3D_INTERNAL::m_boundingSphere;
		}

		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.ISceneObject#onAddedToScene
		 */		
		public function get onAddedToScene():Signal{	return YOGURT3D_INTERNAL::m_onAddedToScene; }
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.ISceneObject#onRemovedFromScene
		 */	
		public function get onRemovedFromScene():Signal{	return YOGURT3D_INTERNAL::m_onRemovedFromScene; }
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.ISceneObject#onMouseUp
		 */	
		public function get onMouseUp():Signal{		return YOGURT3D_INTERNAL::m_onMouseUp;	}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.ISceneObject#onMouseDown
		 */	
		public function get onMouseDown():Signal{	return YOGURT3D_INTERNAL::m_onMouseDown;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.ISceneObject#onMouseMove
		 */	
		public function get onMouseMove():Signal{	return YOGURT3D_INTERNAL::m_onMouseMove;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.ISceneObject#onMouseOver
		 */	
		public function get onMouseOver():Signal{	return YOGURT3D_INTERNAL::m_onMouseOver;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.ISceneObject#onMouseOut
		 */	
		public function get onMouseOut():Signal{	return YOGURT3D_INTERNAL::m_onMouseOut;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.ISceneObject#onMouseClick
		 */	
		public function get onMouseClick():Signal{	return YOGURT3D_INTERNAL::m_onMouseClick;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.ISceneObject#onMouseDoubleClick
		 */	
		public function get onMouseDoubleClick():Signal{	return YOGURT3D_INTERNAL::m_onMouseDoubleClick;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.ISceneObject#onStaticChanged
		 */	
		public function get onStaticChanged():Signal{	return m_onStaticChanged;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.ISceneObject#onRenderLayerChanged
		 */	
		public function get onRenderLayerChanged():Signal{	return m_onRenderLayerChanged;}

		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */		
		public function get visible():Boolean {
			return m_visible;
		}
		/**
		 * @private 
		 * @param _value
		 * 
		 */		
		public function set visible(_value:Boolean):void {
			var _children:Vector.<ISceneObject> = SceneTreeManager.getChildren(this);
			if(_children != null){
				var _numChildren : int = _children.length;
				for ( var i : int = 0; i < _numChildren; i++) {
					if ( _children[i] is SceneObjectRenderable ) {
						SceneObjectRenderable( _children[i] ).visible = _value;
					} else if (  _children[i] is SceneObjectContainer ) {
						SceneObjectContainer( _children[i] ).visible = _value;
					}
				}
			}
			m_visible = _value;
		}
		
		/*private function internalListener(_event:MouseEvent3D):void {
			_event.target3d = _event.target as ISceneObjectRenderable;
			_event.currentTarget3d = this;
			var _parent:ISceneObject;
		
			dispatchEvent(_event);			
		}*/
		/**
		 * @inheritDoc
		 * @return 
		 * 
		 */
		public function get isStatic():Boolean
		{
			return m_isStatic;
		}
		/**
		 * @private 
		 * @param value
		 * 
		 */
		public function set isStatic(value:Boolean):void
		{
			if( m_isStatic !== value)
			{
				m_isStatic = value;
				m_onStaticChanged.dispatch(this);
			}
		}
		/**
		 * @inheritDoc
		 * @return 
		 * 
		 */
		public function get renderLayer():int
		{
			return m_renderLayer;
		}
		/**
		 * @private 
		 * @param value
		 * 
		 */
		public function set renderLayer(value:int):void
		{
			if( m_renderLayer !== value)
			{
				m_renderLayer = value;
				m_onRenderLayerChanged.dispatch( this );
			}
		}
		
		
		/**
		 * @inheritDoc
		 * */
		public function get transformation():Transformation
		{
			return m_transformation;
		}
		
		
		/**
		 * @inheritDoc
		 * */
		public function get parent():ISceneObject
		{
			return SceneTreeManager.getParent(this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get root():ISceneObject
		{
			return SceneTreeManager.getRoot(this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get scene():IScene
		{
			return SceneTreeManager.getScene(this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get children():Vector.<ISceneObject>
		{
			return SceneTreeManager.getChildren(this);
		}
		
		/**
		 * @inheritDoc
		 * @internal Yogurt3D Corp. Core Team
		 * */
		public function addChild(_value:ISceneObject):void
		{
			if (_value == null) {
				throw new Error("Child can not be null");
				return;
			}
			SceneTreeManager.addChild(_value, this);
			
			_value.transformation.onChange.add( seekChildTransformationChange );
			
			m_aabb = null;
			m_boundingSphere = null;
			
			//_value.viewportLayer = m_viewportLayer;
		}
		
		private function seekChildTransformationChange( _trans:Transformation ):void{
			m_reinitboundingVolumes = true;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeChild(_value:ISceneObject):void
		{
			SceneTreeManager.removeChild(_value, this);
			
			_value.transformation.onChange.remove( seekChildTransformationChange );
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeChildBySystemID(_value:String):void
		{
			SceneTreeManager.removeChildBySystemID(_value, this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeChildByUserID(_value:String):void
		{
			SceneTreeManager.removeChildByUserID(_value, this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function getChildBySystemID(_value:String):ISceneObject
		{
			return SceneTreeManager.getChildBySystemID(_value, this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function getChildByUserID(_value:String):ISceneObject
		{
			return SceneTreeManager.getChildByUserID(_value, this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function containsChild(_child:ISceneObject, _recursive:Boolean = false):Boolean
		{
			return SceneTreeManager.contains(_child, this, _recursive); 
		}
		
		public function get axisAlignedBoundingBox():AxisAlignedBoundingBox
		{
			if(m_aabb == null || m_reinitboundingVolumes)
			{
				calculateBoundingVolumes();
				m_reinitboundingVolumes = false;
			}
			if( m_boundingVolumesDirty )
			{
				m_aabb.update( transformation.matrixGlobal );
				m_boundingSphere.center = transformation.globalPosition;
				
				m_boundingVolumesDirty = false;
			}
			return m_aabb;
		}
		
		public function calculateBoundingVolumes():void{
			var _min :Vector3D = new Vector3D(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
			var _max :Vector3D = new Vector3D(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);

			var len:uint = (children)?children.length:0;
			
			MatrixUtils.TEMP_MATRIX.identity();
			
			
			if( this is ISceneObjectRenderable )
			{
				var obj:ISceneObjectRenderable = ISceneObjectRenderable(this);
				// setup aabb on identity
				obj.geometry.axisAlignedBoundingBox.update( MatrixUtils.TEMP_MATRIX );
				// get geometry aabb min max values
				_min = obj.geometry.axisAlignedBoundingBox.min;
				_max = obj.geometry.axisAlignedBoundingBox.max;
			}else if( len == 0 )
			{
				_min = new Vector3D(0,0,0);
				_max = new Vector3D(0,0,0);
			}
			
			if( !m_aabb )
			{
				m_aabb = new AxisAlignedBoundingBox(_min, _max);
			}else{
				m_aabb.recalculateFor( _min, _max );
			}
			
			if( len > 0 )
			{
				// add each child
				for(var i:int; i < len; i++)
				{
					var child:ISceneObject = children[i];
					if( child is ISceneObjectRenderable )
					{
						var aarr:AxisAlignedBoundingBox = ISceneObjectRenderable(child).axisAlignedBoundingBox.update( ISceneObjectRenderable(child).transformation.matrixLocal );
						m_aabb.merge( aarr );
						
					}
				}
				
			}
			
			
			var temp:Vector3D = m_aabb.max.subtract(m_aabb.min);
			var _radiusSqr :Number = temp.x*temp.x + temp.y*temp.y + temp.z*temp.z;
			var _center :Vector3D = m_aabb.max.add(m_aabb.min);
			_center.scaleBy( .5 );
			m_boundingSphere = new BoundingSphere( _radiusSqr, _center );
			
			m_boundingVolumesDirty = true;
		}
		
		public function get aabbWireframe():Boolean{
			return m_drawAABBWireFrame;
		}
		public function set aabbWireframe( _value:Boolean ):void{
			m_drawAABBWireFrame = _value;
		}
		
		Y3DCONFIG::DEBUG
		{
			YOGURT3D_INTERNAL function drawAABBWireFrame( _matrix:Matrix3D, _viewport:Viewport ):void{
				if( m_drawAABBWireFrame )
				{	
					var matrix:Matrix3D = MatrixUtils.TEMP_MATRIX;
					matrix.copyFrom( _matrix );
					matrix.prepend( transformation.matrixGlobal );
					axisAlignedBoundingBox.update( transformation.matrixGlobal );
					var corners:Vector.<Vector3D> = axisAlignedBoundingBox.corners;
					var c0:Vector3D = Utils3D.projectVector( _matrix, corners[0] );
					var c1:Vector3D = Utils3D.projectVector( _matrix, corners[1] );
					var c2:Vector3D = Utils3D.projectVector( _matrix, corners[2] );
					var c3:Vector3D = Utils3D.projectVector( _matrix, corners[3] );
					var c4:Vector3D = Utils3D.projectVector( _matrix, corners[4] );
					var c5:Vector3D = Utils3D.projectVector( _matrix, corners[5] );
					var c6:Vector3D = Utils3D.projectVector( _matrix, corners[6] );
					var c7:Vector3D = Utils3D.projectVector( _matrix, corners[7] );
					
					_viewport.graphics.lineStyle(1,0x00FF00);
					
					
					_viewport.graphics.moveTo( c0.x, c0.y ); // sol alt
					_viewport.graphics.lineTo( c1.x, c1.y  );// sol alt
					_viewport.graphics.lineTo( c7.x, c7.y  ); // sol ust ileri
					_viewport.graphics.lineTo( c2.x, c2.y  );// sol ust geri
					_viewport.graphics.lineTo( c0.x, c0.y ); // sol alt
					
					
					_viewport.graphics.moveTo( c3.x, c3.y  ); // sag alt geri
					_viewport.graphics.lineTo( c5.x, c5.y  ); // sag geri ust
					_viewport.graphics.lineTo( c4.x, c4.y  ); // sag ileri ust
					_viewport.graphics.lineTo( c6.x, c6.y  ); //sag alt ileri
					_viewport.graphics.lineTo( c3.x, c3.y  ); // sag alt geri
					
					_viewport.graphics.moveTo( c3.x, c3.y  ); // sag alt geri
					_viewport.graphics.lineTo( c0.x, c0.y  ); // sag geri ust
					
					_viewport.graphics.moveTo( c6.x, c6.y  ); // sag alt geri
					_viewport.graphics.lineTo( c1.x, c1.y  ); // sag geri ust
					
					_viewport.graphics.moveTo( c4.x, c4.y  ); // sag alt geri
					_viewport.graphics.lineTo( c7.x, c7.y  ); // sag geri ust
					
					_viewport.graphics.moveTo( c5.x, c5.y  ); // sag alt geri
					_viewport.graphics.lineTo( c2.x, c2.y  ); // sag geri ust
				}
			}
		}
			
		override protected function trackObject():void
		{
			IDManager.trackObject(this, SceneObject);
		}
		
		protected function onTransformationChange( _trans:Transformation ):void{
			m_boundingVolumesDirty = true;
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			m_onStaticChanged 		= new Signal(ISceneObject);
			m_onRenderLayerChanged  = new Signal(ISceneObject);
			m_transformation		= new Transformation(this);
			
			m_transformation.onChange.add( onTransformationChange );
			
			m_onMouseClick			= new Signal(MouseEvent3D);
			m_onMouseDoubleClick	= new Signal(MouseEvent3D);
			m_onMouseDown			= new Signal(MouseEvent3D);
			m_onMouseMove			= new Signal(MouseEvent3D);
			m_onMouseOut			= new Signal(MouseEvent3D);
			m_onMouseOver			= new Signal(MouseEvent3D);
			m_onMouseUp				= new Signal(MouseEvent3D);
			
			m_onRemovedFromScene	= new Signal( ISceneObject, IScene );
			m_onAddedToScene		= new Signal( ISceneObject, IScene );
		}
		
		override public function clone():IEngineObject {
			var _newContainer : SceneObject = new SceneObject();			
			_newContainer.m_transformation = Transformation(transformation.clone());
			_newContainer.m_transformation.m_ownerSceneObject = _newContainer;
			
			var _children:Vector.<ISceneObject> = SceneTreeManager.getChildren(this);
			if(_children != null){
				var _numChildren : int = _children.length;
				for ( var i : int = 0; i < _numChildren; i++) {
					_newContainer.addChild( SceneObject( _children[i].clone() ) );
				}
			}
			
			return _newContainer;
			
		}
		
		override public function dispose():void {
			
			m_onStaticChanged.removeAll();
			m_onStaticChanged = null;
			
			m_onRenderLayerChanged.removeAll();
			m_onRenderLayerChanged = null;
			
			m_transformation.dispose();
			m_transformation = null;
			
			m_onMouseClick.removeAll();
			m_onMouseClick = null;
			
			m_onMouseDoubleClick.removeAll();
			m_onMouseDoubleClick = null;
			
			m_onMouseDown.removeAll();
			m_onMouseDown = null;
			
			m_onMouseMove.removeAll();
			m_onMouseMove = null;
			
			m_onMouseOut.removeAll();
			m_onMouseOut = null;
			
			m_onMouseOver.removeAll();
			m_onMouseOver = null;
			
			m_onMouseUp.removeAll();
			m_onMouseUp = null;
			
			super.dispose();
		}
		
		
	}
}
