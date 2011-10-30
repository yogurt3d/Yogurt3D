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
	import com.yogurt3d.core.viewports.ViewportLayer;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	/**
	 * <strong>ISceneObject</strong> interface abstract type.
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class SceneObject extends EngineObject implements ISceneObject
	{
		YOGURT3D_INTERNAL var m_transformation		: Transformation;
		//YOGURT3D_INTERNAL var m_viewportLayer 		: ViewportLayer;
		YOGURT3D_INTERNAL var m_dispacther 			: EventDispatcher;
		
		YOGURT3D_INTERNAL var m_renderLayer			: int = 0;
		
		YOGURT3D_INTERNAL var m_isStatic			: Boolean;
		
		YOGURT3D_INTERNAL var m_aabb:AxisAlignedBoundingBox;
		
		YOGURT3D_INTERNAL var m_boundingSphere:BoundingSphere;
		
		YOGURT3D_INTERNAL var m_visible:Boolean = true;
		
		use namespace YOGURT3D_INTERNAL;

		public function SceneObject(_initInternals:Boolean = true)
		{
			super(_initInternals);
		}
		
		public function get visible():Boolean {
			return m_visible;
		}
		
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
		
		override public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void {
			var _children:Vector.<ISceneObject> = SceneTreeManager.getChildren(this);
			if(_children != null){
				var _numChildren : int = _children.length;
				for ( var i:int=0; i < _numChildren; i++) {
					_children[i].addEventListener(type, internalListener, useCapture, priority, useWeakReference);
				}
			}
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void {
			var _children:Vector.<ISceneObject> = SceneTreeManager.getChildren(this);
			if(_children != null){
				var _numChildren : int = _children.length;
				for ( var i:int=0; i < _numChildren; i++) {
					_children[i].removeEventListener(type, internalListener, useCapture);
				}
			}
			super.removeEventListener(type, listener, useCapture);
		}
		
		private function internalListener(_event:MouseEvent3D):void {
			_event.target3d = _event.target as ISceneObjectRenderable;
			_event.currentTarget3d = this;
			var _parent:ISceneObject;
		
			dispatchEvent(_event);			
		}
		
		
		[Bindable(event="isStaticChange")]
		public function get isStatic():Boolean
		{
			return m_isStatic;
		}

		public function set isStatic(value:Boolean):void
		{
			if( m_isStatic !== value)
			{
				m_isStatic = value;
				dispatchEvent(new Event("isStaticChange"));
			}
		}

		[Bindable(event="renderLayerChange")]
		public function get renderLayer():int
		{
			return m_renderLayer;
		}

		public function set renderLayer(value:int):void
		{
			if( m_renderLayer !== value)
			{
				m_renderLayer = value;
				dispatchEvent(new Event("renderLayerChange"));
			}
		}
		
		public function get axisAlignedBoundingBox():AxisAlignedBoundingBox
		{
			//if(m_aabb == null)
			{
				updateBoundingVolumes();
			}
			return m_aabb;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get transformation():Transformation
		{
			/*if( m_isStatic )
			{
				return null;
			}*/
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
		
		
		public function addedToScene( _scene:IScene ):void{
			
		}
		
		public function removedFromScene( _scene:IScene ):void{
			
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
		 * @internal Yogurt3D Corp. Core Team editledi
		 * */
		public function addChild(_value:ISceneObject):void
		{
			if (_value == null) {
				throw new Error("Child can not be null");
				return;
			}
			SceneTreeManager.addChild(_value, this);
			
			m_aabb = null;
			m_boundingSphere = null;
			
			//_value.viewportLayer = m_viewportLayer;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeChild(_value:ISceneObject):void
		{
			SceneTreeManager.removeChild(_value, this);
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
		
		
		public function updateBoundingVolumes():void{
			var _min :Vector3D = new Vector3D(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
			var _max :Vector3D = new Vector3D(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
			var resolatedMax:Vector3D;
			var resolatedMin:Vector3D;
			var len:uint = children.length;
			
			if( this is ISceneObjectRenderable )
			{
				var obj:ISceneObjectRenderable = ISceneObjectRenderable(this);
				obj.geometry.axisAlignedBoundingBox.update( transformation.matrixGlobal );
				//_min = obj.geometry.axisAlignedBoundingBox.min;
				//_max = obj.geometry.axisAlignedBoundingBox.max;
			}
			
			if( len == 0 && !(this is ISceneObjectRenderable) )
			{
				_min = new Vector3D(0,0,0);
				_max = new Vector3D(0,0,0);
			}else if( len > 0 )
			{
				for(var i:int; i < len; i++)
				{
					var child:ISceneObject = children[i];
					if( child is ISceneObjectRenderable )
					{
						var aarr:AxisAlignedBoundingBox = ISceneObjectRenderable(child).geometry.axisAlignedBoundingBox.update(child.transformation.matrixGlobal);
						resolatedMax = aarr.max;
						resolatedMin = aarr.min;
						if(resolatedMax.x > _max.x) _max.x = resolatedMax.x;
						if(resolatedMin.x < _min.x) _min.x = resolatedMin.x;
						if(resolatedMax.y > _max.y) _max.y = resolatedMax.y;
						if(resolatedMin.y < _min.y) _min.y = resolatedMin.y;
						if(resolatedMax.z > _max.z) _max.z = resolatedMax.z;
						if(resolatedMin.z < _min.z) _min.z = resolatedMin.z;
					}
				}
				
			}
			if( !m_aabb )
			{
				m_aabb = new AxisAlignedBoundingBox(_min, _max);
			}else{
				m_aabb.recalculateFor( _min, _max );
			}
			
			var temp:Vector3D = _max.subtract(_min);
			var _radiusSqr :Number = temp.x*temp.x + temp.y*temp.y + temp.z*temp.z;
			var _center :Vector3D = _max.add( _min);
			_center.scaleBy( .5 );
			m_boundingSphere = new BoundingSphere( _radiusSqr, _center );
		}
		
			
		override protected function trackObject():void
		{
			IDManager.trackObject(this, SceneObject);
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			
			m_transformation		= new Transformation(this);
			m_dispacther			= new EventDispatcher(this);
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
			IDManager.removeObject(m_transformation);
			super.dispose();
		}
		
		
	}
}
