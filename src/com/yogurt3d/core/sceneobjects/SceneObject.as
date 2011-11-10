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
	
	import org.osflash.signals.Signal;

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
		
		use namespace YOGURT3D_INTERNAL;

		public function SceneObject(_initInternals:Boolean = true)
		{
			super(_initInternals);
		}
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */		
		public function get onAddedToScene():Signal{	return YOGURT3D_INTERNAL::m_onAddedToScene; }
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */	
		public function get onRemovedFromScene():Signal{	return YOGURT3D_INTERNAL::m_onRemovedFromScene; }
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */	
		public function get onMouseUp():Signal{		return YOGURT3D_INTERNAL::m_onMouseUp;	}
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */	
		public function get onMouseDown():Signal{	return YOGURT3D_INTERNAL::m_onMouseDown;}
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */	
		public function get onMouseMove():Signal{	return YOGURT3D_INTERNAL::m_onMouseMove;}
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */	
		public function get onMouseOver():Signal{	return YOGURT3D_INTERNAL::m_onMouseOver;}
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */	
		public function get onMouseOut():Signal{	return YOGURT3D_INTERNAL::m_onMouseOut;}
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */	
		public function get onMouseClick():Signal{	return YOGURT3D_INTERNAL::m_onMouseClick;}
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */	
		public function get onMouseDoubleClick():Signal{	return YOGURT3D_INTERNAL::m_onMouseDoubleClick;}
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */	
		public function get onStaticChanged():Signal{	return m_onStaticChanged;}
		/**
		 * @inheritDoc 
		 * @return 
		 * 
		 */	
		public function get onRenderLayerChanged():Signal{	return m_onRenderLayerChanged;}

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
		
		/*private function internalListener(_event:MouseEvent3D):void {
			_event.target3d = _event.target as ISceneObjectRenderable;
			_event.currentTarget3d = this;
			var _parent:ISceneObject;
		
			dispatchEvent(_event);			
		}*/
		
		public function get isStatic():Boolean
		{
			return m_isStatic;
		}

		public function set isStatic(value:Boolean):void
		{
			if( m_isStatic !== value)
			{
				m_isStatic = value;
				m_onStaticChanged.dispatch(this);
			}
		}

		public function get renderLayer():int
		{
			return m_renderLayer;
		}

		public function set renderLayer(value:int):void
		{
			if( m_renderLayer !== value)
			{
				m_renderLayer = value;
				m_onRenderLayerChanged.dispatch( this );
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
			m_onStaticChanged 		= new Signal(ISceneObject);
			m_onRenderLayerChanged  = new Signal(ISceneObject);
			m_transformation		= new Transformation(this);
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
