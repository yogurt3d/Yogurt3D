/*
 * ISceneObject.as
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
 
 
package com.yogurt3d.core.sceneobjects.interfaces {
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.helpers.boundingvolumes.BoundingSphere;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	import com.yogurt3d.core.transformations.Transformation;
	import com.yogurt3d.core.viewports.ViewportLayer;
	
	import flash.events.IEventDispatcher;
	
	import org.osflash.signals.Signal;

	/**
	 * Base interface for 3d objects that have transformation and
	 * can be nested into containers or added to scenes.
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public interface ISceneObject extends IEngineObject
	{
		// SIGNALS
		/**
		 * Signal for scene object added to scene. Sends the ISceneObject, IScene as parameter <br/>
		 * @return 
		 * 
		 * @example The following code adds a signal for a add to scene event:
		 
		 <listing version="3.0">
		 
		 sceneObject.onAddedToScene.add( onAdded );
		 
		 private function onAdded( _scn:IScene ):void{
		 ...
		 }			
		 </listing>
		 * 
		 * 
		 */
		function get onAddedToScene():Signal;
		/**
		 * Signal for scene object removed from scene. Sends the ISceneObject, IScene as parameter <br/>
		 * @return 
		 * 
		 * @example The following code adds a signal for a remove from scene event:
		 
		 <listing version="3.0">
		 
		 sceneObject.onRemovedFromScene.add( onRemoved );
		 
		 private function onRemoved( _scn:IScene ):void{
		 ...
		 }			
		 </listing>
		 * 
		 * 
		 */
		function get onRemovedFromScene():Signal;
		
		/**
		 * Signal for static state change. Sends the ISceneObject as parameter <br/>
		 * @return 
		 * 
		 * @example The following code adds a signal to static state change event:

			<listing version="3.0">
			
			sceneObject.onStaticChanged.add( onStaticChange );
			
			private function onStaticChange( _scn:ISceneObject ):void{
				...
			}			
			</listing>
		 * 
		 * 
		 */
		function get onStaticChanged():Signal;
		
		/**
		 * Signal for render layer state change. Sends the ISceneObject as parameter <br/>
		 * @return 
		 * 
		 * @example The following code adds a signal to render layer change event:
		 
		 <listing version="3.0">
		 
		 sceneObject.onRenderLayerChanged.add( onRenderLayerChange );
		 
		 private function onRenderLayerChange( _scn:ISceneObject ):void{
		 	...
		 }			
		 </listing>
		 * 
		 * 
		 */
		function get onRenderLayerChanged():Signal;
		
		
		/**
		 * Signal for mouse up event. Sends the MouseEvent3D as parameter <br/>
		 * @return 
		 * 
		 * @example The following code adds a signal to mouse up event:
		 
		 <listing version="3.0">
		 
		 sceneObject.onMouseUp.add( onMouseUpEvent );
		 
		 private function onMouseUpEvent( _event:MouseEvent3D ):void{
		 	...
		 }			
		 </listing>
		 * 
		 * 
		 */
		function get onMouseUp():Signal;
		/**
		 * Signal for mouse down event. Sends the MouseEvent3D as parameter <br/>
		 * @return 
		 * 
		 * @example The following code adds a signal to mouse down event:
		 
		 <listing version="3.0">
		 
		 sceneObject.onMouseDown.add( onMouseDownEvent );
		 
		 private function onMouseDownEvent( _event:MouseEvent3D ):void{
		 	...
		 }			
		 </listing>
		 * 
		 * 
		 */
		function get onMouseDown():Signal;
		/**
		 * Signal for mouse move event. Sends the MouseEvent3D as parameter <br/>
		 * @return 
		 * 
		 * @example The following code adds a signal to mouse move event:
		 
		 <listing version="3.0">
		 
		 sceneObject.onMouseMove.add( onMouseMoveEvent );
		 
		 private function onMouseMoveEvent( _event:MouseEvent3D ):void{
		 ...
		 }			
		 </listing>
		 * 
		 * 
		 */
		function get onMouseMove():Signal;
		/**
		 * Signal for mouse over event. Sends the MouseEvent3D as parameter <br/>
		 * @return 
		 * 
		 * @example The following code adds a signal to mouse over event:
		 
		 <listing version="3.0">
		 
		 sceneObject.onMouseOver.add( onMouseOverEvent );
		 
		 private function onMouseOverEvent( _event:MouseEvent3D ):void{
		 ...
		 }			
		 </listing>
		 * 
		 * 
		 */
		function get onMouseOver():Signal;
		/**
		 * Signal for mouse out event. Sends the MouseEvent3D as parameter <br/>
		 * @return 
		 * 
		 * @example The following code adds a signal to mouse out event:
		 
		 <listing version="3.0">
		 
		 sceneObject.onMouseOut.add( onMouseOutEvent );
		 
		 private function onMouseOutEvent( _event:MouseEvent3D ):void{
		 ...
		 }			
		 </listing>
		 * 
		 * 
		 */
		function get onMouseOut():Signal;
		/**
		 * Signal for mouse click event. Sends the MouseEvent3D as parameter <br/>
		 * @return 
		 * 
		 * @example The following code adds a signal to mouse click event:
		 
		 <listing version="3.0">
		 
		 sceneObject.onMouseClick.add( onMouseClickEvent );
		 
		 private function onMouseOutEvent( _event:MouseEvent3D ):void{
		 ...
		 }			
		 </listing>
		 * 
		 * 
		 */
		function get onMouseClick():Signal;
		/**
		 * Signal for mouse double click event. Sends the MouseEvent3D as parameter <br/>
		 * @return 
		 * 
		 * @example The following code adds a signal to mouse double click event:
		 
		 <listing version="3.0">
		 
		 sceneObject.onMouseDoubleClick.add( onMouseDoubleClickEvent );
		 
		 private function onMouseDoubleClickEvent( _event:MouseEvent3D ):void{
		 ...
		 }			
		 </listing>
		 * 
		 * 
		 */
		function get onMouseDoubleClick():Signal;
		
		/**
		 * Transformation of this object
		 * */
		function get transformation():Transformation;
		
		function get axisAlignedBoundingBox():AxisAlignedBoundingBox;
		
		function get boundingSphere():BoundingSphere;
		
		/**
		 * Indicates the container that contains this object.
		 * Property value is <strong>null</strong>
		 * if no container object found. 
		 * */
		function get parent():ISceneObject;
		
		/**
		 * Indicates the top-most relative container that
		 * contains this object. Property value is
		 * <strong>null</strong> if no container object
		 * found. 
		 * */
		function get root():ISceneObject;
		
		/**
		 * Indicates the scene that contains this object.
		 * Property value is <strong>null</strong>
		 * if no scene is found. 
		 * */
		function get scene():IScene;
		
		/**
		 * Render order of the scene object. Objects with the same renderlayer value are packed together.
		 * @return 
		 * 
		 */
		function get renderLayer():int
			
		/**
		 *  
		 * @return 
		 * 
		 */			
		function get isStatic():Boolean;
		
		
		/**
		 * Children objects this
		 * <strong>ISceneObjectContainer</strong>
		 * instance have.
		 * */
		function get children():Vector.<ISceneObject>;
		
		/**
		 * Adds specified child object into this
		 * <strong>ISceneObjectContainer</strong>
		 * instance.
		 * */
		function addChild(_value:ISceneObject):void;
		
		/**
		 * Removes specified child object from this
		 * <strong>ISceneObjectContainer</strong>
		 * instance.
		 * */
		function removeChild(_value:ISceneObject):void;
		
		/**
		 * Removes child object that has the given
		 * systemID from this <strong>ISceneObjectContainer</strong>
		 * instance.
		 * */
		function removeChildBySystemID(_value:String):void;
		
		/**
		 * Removes child object that has the given
		 * userID from this <strong>ISceneObjectContainer</strong>
		 * instance.
		 * */
		function removeChildByUserID(_value:String):void;
		
		/**
		 * Returns child object that has the
		 * given systemID.
		 * */
		function getChildBySystemID(_value:String):ISceneObject;
		
		/**
		 * Returns child object that has the
		 * given userID.
		 * */
		function getChildByUserID(_value:String):ISceneObject;
		
		/**
		 * Determines whether the specified <strong>ISceneObject</strong>
		 * instance is a child of the <strong>ISceneObjectContainer</strong>
		 * instance.
		 * 
		 * @param _child Child to check.
		 * 
		 * @param _recursive If this argument is <strong>false</strong>
		 * the check only works for the highest hierarchy. If argument is set
		 * <strong>true</strong> the check works for all
		 * children containers recursively.
		 * */
		function containsChild(_child:ISceneObject, _recursive:Boolean = false):Boolean;

		/**
		 * Sets the visiblity of self and children
		 * */
		function get visible():Boolean;
		
		/**
		 * @private
		 * */
		function set visible(_value:Boolean):void;
	}
}
