/*
 * SceneObjectRenderable.as
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
	
	import com.yogurt3d.core.geoms.interfaces.IMesh;
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.materials.MaterialFill;
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	import com.yogurt3d.core.transformations.Transformation;
	import com.yogurt3d.presets.primitives.meshs.WireMesh;
	
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;

	/**
	 * <strong>ISceneObjectRenderable</strong> interface abstract type.
 	 * 
 	 * 
  	 * @author Yogurt3D Engine Core Team
  	 * @company Yogurt3D Corp.
  	 **/
	public class SceneObjectRenderable extends SceneObject implements ISceneObjectRenderable
	{
		YOGURT3D_INTERNAL var m_geometry			:IMesh;
		YOGURT3D_INTERNAL var m_material			:Material;
		YOGURT3D_INTERNAL var m_visible				:Boolean 	= true;
		YOGURT3D_INTERNAL var m_castShadows			:Boolean 	= false;
		YOGURT3D_INTERNAL var m_receiveShadows		:Boolean 	= false;
		YOGURT3D_INTERNAL var m_interactive			:Boolean;
		YOGURT3D_INTERNAL var m_pickEnabled			:Boolean 	= true;
		YOGURT3D_INTERNAL var m_useHandCursor		:Boolean 	= false;
		YOGURT3D_INTERNAL var m_culling				:String 	= Context3DTriangleFace.BACK;
		
		YOGURT3D_INTERNAL var m_wireframe			:SceneObjectRenderable;
		YOGURT3D_INTERNAL var m_wireframeToBeAdded	:Boolean = false;
		
		use namespace YOGURT3D_INTERNAL;
		
		public function SceneObjectRenderable(_initInternals:Boolean = true)
		{
			super(_initInternals);
		}
		
		public function deactivateWireFrame():void{
			if( m_wireframe )
			{
				if( scene )
				{
					scene.removeChild(m_wireframe );
				}
				m_wireframe.geometry.dispose();
				m_wireframe.material.dispose();
				m_wireframe.dispose();
				m_wireframe = null;
			}
		}
		
		public function activateWireFrame( _color:uint = 0xFFFFFF, _tickness:Number = 0.01 ):void{
			if( m_wireframe == null )
			{
				m_wireframe = new SceneObjectRenderable();
				var wire:WireMesh;
				m_wireframe.geometry = wire = new WireMesh();
				wire.addMesh( this.geometry, _tickness );
				m_wireframe.material = new MaterialFill( _color );
				if( scene != null )
				{
					scene.addChild( m_wireframe );
				}else{
					m_wireframeToBeAdded = true;
				}
			}else{
				deactivateWireFrame();
				activateWireFrame( _color, _tickness );
			}
		}
		
		public function hideWireFrame():Boolean{
			if( m_wireframe )
			{
				m_wireframe.visible = false;
				return true;
			}
			return false;
		}
		public function showWireFrame():Boolean{
			if( m_wireframe )
			{
				m_wireframe.visible = true;
				return true;
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 * */
		public override function addedToScene( _scene:IScene ):void{
			super.addedToScene( _scene );
			if(m_wireframeToBeAdded && m_wireframe )
			{
				_scene.addChild( m_wireframe );
			}
			m_wireframeToBeAdded = false;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get geometry():IMesh
		{
			return m_geometry;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function set geometry(_value:IMesh):void
		{
			m_geometry = _value;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get material():Material
		{
			return m_material;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function set material(_value:Material):void
		{
			if( m_material != _value )
			{
				if( m_material )
				{
					m_material.removeEventListener("opacityChange", opacityChanged );
					if( "alphaTexture" in m_material )
					{
						m_material.removeEventListener("alphaTextureChange", opacityChanged );
					}
				}
				m_material = _value;
				m_material.addEventListener("opacityChange", opacityChanged );
				if( "alphaTexture" in m_material )
				{
					m_material.addEventListener("alphaTextureChange", opacityChanged );
				}
				opacityChanged( null );
			}
		}
		/**
		 * renderLayers:
		 * default: 0
		 * opacity default: 100
		 * alpha texture default: 50
		 * @param _e
		 * 
		 */		
		private function opacityChanged( _e:Event ):void{
			if( (renderLayer == 100 || renderLayer == 50 || renderLayer == 0) )
			{
				if( m_material.opacity < 1 )
				{
					renderLayer = 100;
				}else if( "alphaTexture" in  m_material && m_material["alphaTexture"] == true)
				{
					renderLayer = 50;
				}
				else
				{
					renderLayer = 0;
				}
			}
		}
		
	
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, SceneObjectRenderable);
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
		}

		public function get castShadows():Boolean {
			return m_castShadows;	
		}
		
		public function set castShadows(_castShadows:Boolean):void {
			m_castShadows = _castShadows;
		}

		public function get receiveShadows():Boolean {
			return m_receiveShadows;	
		}
		
		public function set receiveShadows(_receiveShadows:Boolean):void {
			m_receiveShadows = _receiveShadows;
		}
		
		public function get interactive():Boolean
		{
			return m_interactive;
		}
		
		public function set interactive(_value:Boolean):void
		{
			m_interactive = _value;
		}
		
		public function get pickEnabled():Boolean
		{
			return m_pickEnabled;
		}
		
		public function set pickEnabled(_value:Boolean):void
		{
			m_pickEnabled = _value;
		}
		override public function instance():*
		{
			var _sceneObjectCopy:SceneObjectRenderable 	= new SceneObjectRenderable();
			
			_sceneObjectCopy.geometry	 				= m_geometry;
			_sceneObjectCopy.m_material					= m_material;
			_sceneObjectCopy.m_visible 					= m_visible;
			
			_sceneObjectCopy.m_castShadows 				= m_castShadows;
			_sceneObjectCopy.m_receiveShadows 			= m_receiveShadows;
			
			_sceneObjectCopy.m_transformation = Transformation(m_transformation.clone());
			_sceneObjectCopy.m_transformation.m_ownerSceneObject = _sceneObjectCopy;
			
			return _sceneObjectCopy;
		}
		override public function clone():IEngineObject {			
			var _sceneObjectCopy:SceneObjectRenderable 	= new SceneObjectRenderable();
			_sceneObjectCopy.geometry	 				= geometry;
			_sceneObjectCopy.m_material					= m_material;
			_sceneObjectCopy.m_visible 					= m_visible;
			_sceneObjectCopy.m_interactive 				= m_interactive;
			
			_sceneObjectCopy.m_castShadows 				= m_castShadows;
			_sceneObjectCopy.m_receiveShadows 			= m_receiveShadows;
			
			_sceneObjectCopy.m_transformation = Transformation(m_transformation.clone());
			_sceneObjectCopy.m_transformation.m_ownerSceneObject = _sceneObjectCopy;
			
			return _sceneObjectCopy;
		}
		
		public function updateAABB():AxisAlignedBoundingBox {
			var _aabb:AxisAlignedBoundingBox = geometry.axisAlignedBoundingBox;
			_aabb.update(transformation.matrixGlobal);
			return _aabb;
		}
		
		public function get useHandCursor() : Boolean {			
			return m_useHandCursor;
		}
		
		public function set useHandCursor(_value : Boolean) : void {
			m_useHandCursor = _value;
		}
		
		public function get culling() : String {
			return m_culling;
		}
		
		public function set culling(_value : String) : void {
			m_culling = _value;
		}
		
		public override function dispose():void{
			super.dispose();
			m_geometry = null;
			m_material = null;
		}
	}
}