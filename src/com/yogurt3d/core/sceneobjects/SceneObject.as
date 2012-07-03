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
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.events.MouseEvent3D;
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.helpers.boundingvolumes.BoundingSphere;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.managers.scenetreemanager.SceneTreeManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.transformations.Transformation;
	import com.yogurt3d.core.utils.MatrixUtils;
	import com.yogurt3d.core.viewports.EAabbDrawMode;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	import org.osflash.signals.Signal;

	/**
	 * <strong>SceneObject</strong> interface abstract type.
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class SceneObject extends EngineObject
	{
		use namespace YOGURT3D_INTERNAL;

		YOGURT3D_INTERNAL var m_useHandCursor					: Boolean = false;
		
		YOGURT3D_INTERNAL var m_transformation					: Transformation;
		
		YOGURT3D_INTERNAL var m_renderLayer						: int = 0;
		
		YOGURT3D_INTERNAL var m_isStatic						: Boolean;
		
		YOGURT3D_INTERNAL var m_aabb							:AxisAlignedBoundingBox;
		
		YOGURT3D_INTERNAL var m_aabbCumulative					:AxisAlignedBoundingBox;
		
		YOGURT3D_INTERNAL var m_boundingSphere					:BoundingSphere;
		
		YOGURT3D_INTERNAL var m_boundingSphereCumulative		:BoundingSphere;
	
		
		/**
		 * This flag indicates that the bounding volumes have to be re initialized after a child transformation change 
		 */		
		YOGURT3D_INTERNAL var m_reinitboundingVolumes			:Boolean = true;
		
		YOGURT3D_INTERNAL var m_visible							:Boolean = true;
		
		YOGURT3D_INTERNAL var m_drawAABBWireFrame				:EAabbDrawMode = EAabbDrawMode.NONE;
		
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
		
		private			  var m_pickEnabled						:Boolean 	= true;
		
		private			  var m_interactive						:Boolean	= false;
		

		public function SceneObject(_initInternals:Boolean = true)
		{
			super(_initInternals);
		}

		public function get useHandCursor():Boolean
		{
			return m_useHandCursor;
		}

		public function set useHandCursor(value:Boolean):void
		{
			m_useHandCursor = value;
			if( children && children.length>0 )
			{
				for( var childIndex:uint = 0; childIndex < children.length; childIndex++ )
				{
					var scnObj:SceneObject = children[childIndex];
					scnObj.m_useHandCursor = value;
				}
			}
		}

		public function get interactive():Boolean
		{
			return m_interactive;
		}

		public function set interactive(value:Boolean):void
		{
			m_interactive = value;
			
			if( children && children.length>0 )
			{
				for( var childIndex:uint = 0; childIndex < children.length; childIndex++ )
				{
					var scnObj:SceneObject = children[childIndex];
					
					if( m_interactive )
					{
						scnObj.onMouseClick.add( $eventJump );
						scnObj.onMouseDoubleClick.add( $eventJump );
						scnObj.onMouseDown.add( $eventJump );
						scnObj.onMouseMove.add( $eventJump );
						scnObj.onMouseOut.add( $eventJump );
						scnObj.onMouseOver.add( $eventJump );
						scnObj.onMouseUp.add( $eventJump );
					}else{
						scnObj.onMouseClick.remove( $eventJump );
						scnObj.onMouseDoubleClick.remove( $eventJump );
						scnObj.onMouseDown.remove( $eventJump );
						scnObj.onMouseMove.remove( $eventJump );
						scnObj.onMouseOut.remove( $eventJump );
						scnObj.onMouseOver.remove( $eventJump );
						scnObj.onMouseUp.remove( $eventJump );
					}
				}
			}
		}
		public function set interactiveChildren(value:Boolean):void
		{
			if( children && children.length>0 )
			{
				for( var childIndex:uint = 0; childIndex < children.length; childIndex++ )
				{
					var scnObj:SceneObject = children[childIndex];
					scnObj.interactive = value;
					scnObj.interactiveChildren = value;
				}
			}
		}
		
		private function $eventJump( _e:MouseEvent3D ):void{
			var event:MouseEvent3D = _e.clone() as MouseEvent3D;
			event.currentTarget3d = this;
			switch( _e.type)
			{
				case( MouseEvent3D.CLICK ):
					onMouseClick.dispatch( event );
					break;
				case( MouseEvent3D.DOUBLE_CLICK ):
					onMouseDoubleClick.dispatch( event );
					break;
				case( MouseEvent3D.MOUSE_DOWN ):
					onMouseDown.dispatch( event );
					break;
				case( MouseEvent3D.MOUSE_MOVE ):
					onMouseMove.dispatch( event );
					break;
				case( MouseEvent3D.MOUSE_OUT ):
					onMouseOut.dispatch( event );
					break;
				case( MouseEvent3D.MOUSE_OVER ):
					onMouseOver.dispatch( event );
					break;
				case( MouseEvent3D.MOUSE_UP ):
					onMouseUp.dispatch( event );
					break;
			}
		}
		
		public function get pickEnabled():Boolean
		{
			return m_pickEnabled;
		}

		public function set pickEnabled(value:Boolean):void
		{
			m_pickEnabled = value;
		}
		
		public function set pickEnabledChildren(value:Boolean):void
		{
			if( children && children.length>0 )
			{
				for( var childIndex:uint = 0; childIndex < children.length; childIndex++ )
				{
					var scnObj:SceneObject = children[childIndex];
					scnObj.pickEnabled = value;
					scnObj.pickEnabledChildren = value;
				}
			}
		}

		public function get boundingSphere():BoundingSphere
		{
			if(!m_boundingSphere)
				m_boundingSphere = new BoundingSphere(axisAlignedBoundingBox.halfSizeGlobal.lengthSquared, axisAlignedBoundingBox.centerGlobal);
			else
			{
				m_boundingSphere.center = axisAlignedBoundingBox.centerGlobal;
				m_boundingSphere.radius = axisAlignedBoundingBox.halfSizeGlobal.length;
				m_boundingSphere.radiusSqr = axisAlignedBoundingBox.halfSizeGlobal.lengthSquared;
			}
			return m_boundingSphere;
		}
		
		public function get cumulativeBoundingSphere():BoundingSphere
		{
			if(!m_boundingSphereCumulative)
				m_boundingSphereCumulative = new BoundingSphere(cumulativeAxisAlignedBoundingBox.halfSizeGlobal.lengthSquared, cumulativeAxisAlignedBoundingBox.centerGlobal);
			else
			{
				m_boundingSphereCumulative.center = cumulativeAxisAlignedBoundingBox.centerGlobal;
				m_boundingSphereCumulative.radius = cumulativeAxisAlignedBoundingBox.halfSizeGlobal.length;
				m_boundingSphereCumulative.radiusSqr = cumulativeAxisAlignedBoundingBox.halfSizeGlobal.lengthSquared;
			}
			return m_boundingSphereCumulative;
		}

		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.SceneObject#onAddedToScene
		 */		
		public function get onAddedToScene():Signal{	return YOGURT3D_INTERNAL::m_onAddedToScene; }
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.SceneObject#onRemovedFromScene
		 */	
		public function get onRemovedFromScene():Signal{	return YOGURT3D_INTERNAL::m_onRemovedFromScene; }
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.SceneObject#onMouseUp
		 */	
		public function get onMouseUp():Signal{		return YOGURT3D_INTERNAL::m_onMouseUp;	}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.SceneObject#onMouseDown
		 */	
		public function get onMouseDown():Signal{	return YOGURT3D_INTERNAL::m_onMouseDown;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.SceneObject#onMouseMove
		 */	
		public function get onMouseMove():Signal{	return YOGURT3D_INTERNAL::m_onMouseMove;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.SceneObject#onMouseOver
		 */	
		public function get onMouseOver():Signal{	return YOGURT3D_INTERNAL::m_onMouseOver;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.SceneObject#onMouseOut
		 */	
		public function get onMouseOut():Signal{	return YOGURT3D_INTERNAL::m_onMouseOut;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.SceneObject#onMouseClick
		 */	
		public function get onMouseClick():Signal{	return YOGURT3D_INTERNAL::m_onMouseClick;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.SceneObject#onMouseDoubleClick
		 */	
		public function get onMouseDoubleClick():Signal{	return YOGURT3D_INTERNAL::m_onMouseDoubleClick;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.SceneObject#onStaticChanged
		 */	
		public function get onStaticChanged():Signal{	return m_onStaticChanged;}
		/**
		 * @inheritDoc 
		 * @return 
		 * @see com.yogurt3d.core.sceneobjects.interfaces.SceneObject#onRenderLayerChanged
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
			var _children:Vector.<SceneObject> = SceneTreeManager.getChildren(this);
			if(_children != null){
				var _numChildren : int = _children.length;
				for ( var i : int = 0; i < _numChildren; i++) {
					_children[i].visible = _value;
				}
			}
			m_visible = _value;
		}
		
		/*private function internalListener(_event:MouseEvent3D):void {
			_event.target3d = _event.target as SceneObjectRenderable;
			_event.currentTarget3d = this;
			var _parent:SceneObject;
		
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
		
		public function set renderLayerChildren(value:int):void
		{
			if( children )
			{
				for( var i:int = 0; i < children.length ; i++ )
				{
					children[i].renderLayer = value;
					children[i].renderLayerChildren = value;
				}
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
		public function get parent():SceneObject
		{
			return SceneTreeManager.getParent(this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get root():SceneObject
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
		public function get children():Vector.<SceneObject>
		{
			return SceneTreeManager.getChildren(this);
		}
		
		/**
		 * @inheritDoc
		 * @internal Yogurt3D Corp. Core Team
		 * */
		public function addChild(_value:SceneObject):void
		{
			if (_value == null) {
				throw new Error("Child can not be null");
				return;
			}
			SceneTreeManager.addChild(_value, this);
			
			_value.transformation.onChange.add( seekChildTransformationChange );
			
			m_aabb = null;
			m_boundingSphere = null;
			
			
			m_reinitboundingVolumes = true;
			
			var _curParent:SceneObject = parent;
			
			while(_curParent)
			{
				_curParent.m_reinitboundingVolumes = true;
				_curParent = _curParent.parent;
			}
			
			if( interactive )
			{
				_value.onMouseClick.add( $eventJump );
				_value.onMouseDoubleClick.add( $eventJump );
				_value.onMouseDown.add( $eventJump );
				_value.onMouseMove.add( $eventJump );
				_value.onMouseOut.add( $eventJump );
				_value.onMouseOver.add( $eventJump );
				_value.onMouseUp.add( $eventJump );
			}
			
			if( m_useHandCursor )
			{
				_value.useHandCursor = m_useHandCursor;
			}
		}
		/**
		 * Called when some childrens' tramsformation has changed 
		 * @param _trans
		 * 
		 */		
		private function seekChildTransformationChange( _trans:Transformation ):void{
			
			if(_trans.m_isLocalDirty)
			{
				m_reinitboundingVolumes = true;
				
				var _curParent:SceneObject = parent;
				
				while(_curParent)
				{
					_curParent.m_reinitboundingVolumes = true;
					_curParent = _curParent.parent;
				}
			}
			
		}
		
		/**
		 * @inheritDoc
		 * */
		public function removeChild(_value:SceneObject):void
		{
			if( _value.transformation )
				_value.transformation.onChange.remove( seekChildTransformationChange );

			SceneTreeManager.removeChild(_value, this);
			
			m_reinitboundingVolumes = true;
			
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
		public function getChildBySystemID(_value:String):SceneObject
		{
			return SceneTreeManager.getChildBySystemID(_value, this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function getChildByUserID(_value:String):SceneObject
		{
			return SceneTreeManager.getChildByUserID(_value, this);
		}
		
		/**
		 * @inheritDoc
		 * */
		public function containsChild(_child:SceneObject, _recursive:Boolean = false):Boolean
		{
			return SceneTreeManager.contains(_child, this, _recursive); 
		}
		
		public function get axisAlignedBoundingBox():AxisAlignedBoundingBox
		{
			if(!m_aabb)
			{
				m_aabb = new AxisAlignedBoundingBox(new Vector3D(), new Vector3D(), transformation);

			}
			return m_aabb;			
		}
		
		
		public function get cumulativeAxisAlignedBoundingBox():AxisAlignedBoundingBox
		{
			var len:uint = (children)?children.length:0;
			
			if( len  )
			{
				// if container needs re initialization of cumulative bounding volumes
				if(m_reinitboundingVolumes)
				{
					if(!m_aabbCumulative)
					{
						m_aabbCumulative = new AxisAlignedBoundingBox(new Vector3D(), new Vector3D(), transformation);
						//m_aabbCumulative.update();
					}
					else
						m_aabbCumulative.setInitialMinMax(new Vector3D(), new Vector3D(), transformation);
					
					for(var i:int = 0; i < len; i++)
					{
						var child:SceneObject = children[i];
						if( child is Camera || child is Light ) continue;
						if( i == 0 )
						{
							m_aabbCumulative.setInitialMinMax( child.cumulativeAxisAlignedBoundingBox.initialMin, child.cumulativeAxisAlignedBoundingBox.initialMax, transformation);
						}else{
							m_aabbCumulative.merge( child.cumulativeAxisAlignedBoundingBox );	
						}
						
					}
					
					m_reinitboundingVolumes = false;
					
				}
				
				return m_aabbCumulative;
				
			}else
			{
				if( m_reinitboundingVolumes )
				{
					if( m_aabbCumulative )
					{
						m_aabbCumulative.dispose();
					}
					m_aabbCumulative = null;
					m_reinitboundingVolumes = false;
				}
				
				return axisAlignedBoundingBox;
			}
		}

		
		

		
		
		public function get aabbWireframe():EAabbDrawMode{
			return m_drawAABBWireFrame;
		}
		public function set aabbWireframe( _value:EAabbDrawMode ):void{
			m_drawAABBWireFrame = _value;
		}
		
		Y3DCONFIG::DEBUG
		{
			YOGURT3D_INTERNAL function drawAABBWireFrame( _matrix:Matrix3D, _viewport:Viewport, _mode:EAabbDrawMode):void{
				
				var corners:Vector.<Vector3D>;
				if( _mode ==  EAabbDrawMode.CUMULATIVE)
				{	
					//var matrix:Matrix3D = MatrixUtils.TEMP_MATRIX;
					//matrix.copyFrom( _matrix );
					//matrix.prepend( transformation.matrixGlobal );
					//axisAlignedBoundingBox.update( transformation.matrixGlobal );
					corners = cumulativeAxisAlignedBoundingBox.cornersGlobal;
				}else if( _mode ==  EAabbDrawMode.STRAIGHT)
				{
					corners = axisAlignedBoundingBox.cornersGlobal;
				}
					var c0:Vector3D = Utils3D.projectVector( _matrix, corners[0] );
					var c1:Vector3D = Utils3D.projectVector( _matrix, corners[1] );
					var c2:Vector3D = Utils3D.projectVector( _matrix, corners[2] );
					var c3:Vector3D = Utils3D.projectVector( _matrix, corners[3] );
					var c4:Vector3D = Utils3D.projectVector( _matrix, corners[4] );
					var c5:Vector3D = Utils3D.projectVector( _matrix, corners[5] );
					var c6:Vector3D = Utils3D.projectVector( _matrix, corners[6] );
					var c7:Vector3D = Utils3D.projectVector( _matrix, corners[7] );
					
					if( _mode ==  EAabbDrawMode.CUMULATIVE)
					{	
						_viewport.graphics.lineStyle(1,0x0000FF);
					}else if( _mode ==  EAabbDrawMode.STRAIGHT)
					{
						_viewport.graphics.lineStyle(1,0x00FF00);
					}
					
					
					
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
			
		override protected function trackObject():void
		{
			IDManager.trackObject(this, SceneObject);
		}
		

		
		override protected function initInternals():void
		{
			super.initInternals();
			m_onStaticChanged 		= new Signal(SceneObject);
			m_onRenderLayerChanged  	= new Signal(SceneObject);
			m_transformation		= new Transformation(this);
			
			m_onMouseClick			= new Signal(MouseEvent3D);
			m_onMouseDoubleClick		= new Signal(MouseEvent3D);
			m_onMouseDown			= new Signal(MouseEvent3D);
			m_onMouseMove			= new Signal(MouseEvent3D);
			m_onMouseOut			= new Signal(MouseEvent3D);
			m_onMouseOver			= new Signal(MouseEvent3D);
			m_onMouseUp			= new Signal(MouseEvent3D);
			
			m_onRemovedFromScene		= new Signal( SceneObject, IScene );
			m_onAddedToScene		= new Signal( SceneObject, IScene );
		}
		
		override public function clone():IEngineObject {
			var _newContainer : SceneObject = new SceneObject();			
			_newContainer.m_transformation = Transformation(transformation.clone());
			_newContainer.m_transformation.m_ownerSceneObject = _newContainer;
			
			var _children:Vector.<SceneObject> = SceneTreeManager.getChildren(this);
			if(_children != null){
				var _numChildren : int = _children.length;
				for ( var i : int = 0; i < _numChildren; i++) {
					_newContainer.addChild( SceneObject( _children[i].clone() ) );
				}
			}
			
			return _newContainer;
			
		}
		
		override public function dispose():void {
			if( children )
			{
				for( var i:int = 0; i < children.length; i++ )
				{
					removeChild( children[0] );
				}
			}
			if( parent )
			{
				parent.removeChild( this );
			}
			
			if( m_aabb )
			{
				m_aabb.dispose();
				m_aabb = null;
			}
			
			if( m_boundingSphere )
			{
				m_boundingSphere.dispose();
				m_boundingSphere = null;
			}

			if( m_aabbCumulative )
			{
				m_aabbCumulative.dispose();
				m_aabbCumulative = null;
			}
			
			if( m_boundingSphereCumulative )
			{
				m_boundingSphereCumulative.dispose();
				m_boundingSphereCumulative = null;
			}
			
			if( m_onStaticChanged )
				m_onStaticChanged.removeAll();
			m_onStaticChanged = null;
			
			if( m_onRenderLayerChanged )
				m_onRenderLayerChanged.removeAll();
			m_onRenderLayerChanged = null;
			
			if( m_transformation )
				m_transformation.dispose();
			m_transformation = null;
			
			if( m_onMouseClick )
				m_onMouseClick.removeAll();
			m_onMouseClick = null;
			
			if( m_onMouseDoubleClick )
				m_onMouseDoubleClick.removeAll();
			m_onMouseDoubleClick = null;
			
			if( m_onMouseDown )
				m_onMouseDown.removeAll();
			m_onMouseDown = null;
			
			if( m_onMouseMove )
				m_onMouseMove.removeAll();
			m_onMouseMove = null;
			
			if( m_onMouseOut )
				m_onMouseOut.removeAll();
			m_onMouseOut = null;
			
			if( m_onMouseOver )
				m_onMouseOver.removeAll();
			m_onMouseOver = null;
			
			if( m_onMouseUp )
				m_onMouseUp.removeAll();
			m_onMouseUp = null;
			
			super.dispose();
		}
		
		public override function disposeDeep():void {
			if( children )
			{
				var _children:Vector.<SceneObject> = children.concat();
				for( var i:int = 0; i < _children.length; i++ )
				{
					removeChild( _children[i] );
					
					_children[i].disposeDeep();
				}
			}
			dispose();
		}
		
		public override function disposeGPU():void {
			if( children )
			{
				var _children:Vector.<SceneObject> = children;
				for( var i:int = 0; i < _children.length; i++ )
				{
					_children[i].disposeGPU();
				}
			}
		}
		
		
	}
}
