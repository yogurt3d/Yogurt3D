/*
 * ISceneObjectRenderable.as
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
	import com.yogurt3d.core.geoms.Mesh;
	import com.yogurt3d.core.geoms.interfaces.IMesh;
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.viewports.ViewportLayer;
	
	import flash.utils.ByteArray;

	/**
	 * Defines properties to make object renderable by
	 * <strong>IRenderer</strong> objects.
 	 * 
  	 * @author Yogurt3D Engine Core Team
  	 * @company Yogurt3D Corp.
  	 **/
	public interface ISceneObjectRenderable extends ISceneObject
	{
		/**
		 * <strong>Mesh</strong> geometry of this
		 * <strong>ISceneObjectRenderable</strong>
		 * instance.
		 * */
		function get geometry():IMesh;
		
		/**
		 * @private
		 * */
		function set geometry(_value:IMesh):void;
		
		/**
		 * <strong>Material</strong> material
		 * object of this <strong>ISceneObjectRenderable</strong>
		 * instance.
		 * */
		function get material():Material;
		
		/**
		 * @private
		 * */
		function set material(_value:Material):void;

		function get castShadows():Boolean;
		function set castShadows(_castShadows:Boolean):void;

		function get receiveShadows():Boolean;
		function set receiveShadows(_receiveShadows:Boolean):void;
		
		function get interactive():Boolean;
		function set interactive(_value:Boolean):void;
		
		function get pickEnabled():Boolean;
		function set pickEnabled(_value:Boolean):void;
		
		function get useHandCursor():Boolean;
		function set useHandCursor(_value:Boolean):void;
		

		function get culling():String;
		function set culling(_value:String):void;
		
	}
}
