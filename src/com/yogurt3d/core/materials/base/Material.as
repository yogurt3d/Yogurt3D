/*
 * Material.as
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
 
 
package com.yogurt3d.core.materials.base {
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.TriangleCulling;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	use namespace YOGURT3D_INTERNAL;
	
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class Material extends EngineObject
	{
		YOGURT3D_INTERNAL var m_culling					:String;
		YOGURT3D_INTERNAL var m_doubleSided				:Boolean;		
		
		YOGURT3D_INTERNAL var m_shaders					:Vector.<Shader>;
		
		YOGURT3D_INTERNAL var m_emissiveColor			:Color;
		YOGURT3D_INTERNAL var m_ambientColor			:Color;
		YOGURT3D_INTERNAL var m_diffuseColor			:Color;
		YOGURT3D_INTERNAL var m_specularColor			:Color;

		YOGURT3D_INTERNAL var m_transparent				:Boolean = false;
		
		public function Material(_initInternals:Boolean = true)
		{
			super(_initInternals);
		}

		public function get transparent():Boolean
		{
			return m_transparent;
		}

		public function get specularColor():Color
		{
			return m_specularColor;
		}

		public function set specularColor(value:Color):void
		{
			m_specularColor = value;
		}

		public function get diffuseColor():Color
		{
			return m_diffuseColor;
		}

		public function set diffuseColor(value:Color):void
		{
			m_diffuseColor = value;
		}

		public function get ambientColor():Color
		{
			return m_ambientColor;
		}

		public function set ambientColor(value:Color):void
		{
			m_ambientColor = value;
		}

		public function get emissiveColor():Color
		{
			return m_emissiveColor;
		}

		public function set emissiveColor(value:Color):void
		{
			m_emissiveColor = value;
		}

		public function get culling():String
		{
			return m_culling;
		}
		
		public function set culling(_value:String):void
		{
			m_culling = _value;
		}
		
		public function get doubleSided():Boolean
		{
			return m_doubleSided;
		}
		
		public function set doubleSided(_value:Boolean):void
		{
			m_doubleSided = _value;
		}
		
		
		

		override protected function trackObject():void
		{
			IDManager.trackObject(this, Material);
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
			
			m_culling			= TriangleCulling.NEGATIVE;
			m_doubleSided		= false;
			m_shaders			= new Vector.<Shader>();
			
			m_emissiveColor = new Color( 0,0,0,1 );
			m_ambientColor  = new Color( 1,1,1,0 );
			m_diffuseColor  = new Color( 1,1,1,1 );
			m_specularColor = new Color( 1,1,1,1 );
			
		}
		
		public override function disposeGPU():void{
			for( var i:int = 0; i < m_shaders.length;i++)
			{
				m_shaders[i].disposeShaders();
			}
		}
		
		override public function dispose():void {
			for( var i:int = 0; i < m_shaders.length;i++)
			{
				m_shaders[i].disposeShaders();
			}
			m_shaders.length = 0;
			super.dispose();
		}
		
		public override function disposeDeep():void{
			for( var i:int = 0; i < m_shaders.length;i++)
			{
				m_shaders[i].disposeDeep();
			}
			m_shaders.length = 0;
		}

		public function get shaders():Vector.<Shader>
		{
			return m_shaders;
		}

		public function set shaders(value:Vector.<Shader>):void
		{
			m_shaders = value;
		}
		


	}
}
