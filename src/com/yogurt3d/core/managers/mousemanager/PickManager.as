/*
 * PickManager.as
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
 
 
package com.yogurt3d.core.managers.mousemanager
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.events.MouseEvent3D;
	import com.yogurt3d.core.managers.tickmanager.TickManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.viewports.Viewport;
	import com.yogurt3d.presets.renderers.molehill.PickRenderer;
	
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	use namespace YOGURT3D_INTERNAL;
	/**
	 * This class is responsible for the mouse interactions. You will never have to create this class by your own. The Viewport creates it when you set the <i>pickEnable</i> to true. 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class PickManager
	{
		private var m_lastUpdateTime:uint = 0;
		
		public var updateTime:uint = 40;
		
		private static var m_pickRenderer:PickRenderer;
		
		YOGURT3D_INTERNAL var m_lastObject:SceneObjectRenderable;
		
		YOGURT3D_INTERNAL var m_currentObject:SceneObjectRenderable;
		
		YOGURT3D_INTERNAL var m_currentIntersection:Vector3D;
		
		YOGURT3D_INTERNAL var m_downObject:SceneObjectRenderable;
		
		private var m_viewport:Viewport;
		
		private var m_lastCamera:Camera;
		
		public function PickManager( _viewport:Viewport )
		{
			if( !_viewport ){
				throw new Error( "PickManager cannot be initialized without a valid Viewport" );
			}
			
			if( !m_pickRenderer )
			{
				m_pickRenderer = new PickRenderer();
			}
			
			m_viewport = _viewport;
			
			m_viewport.addEventListener( MouseEvent.MOUSE_DOWN, onDown );
			m_viewport.addEventListener( MouseEvent.MOUSE_UP, onUp );
			m_viewport.addEventListener( MouseEvent.MOUSE_MOVE, onMove );
			m_viewport.addEventListener( MouseEvent.DOUBLE_CLICK, onDoubleClick );
			m_viewport.doubleClickEnabled = true;
		}

		public function dispose():void{
			m_viewport.removeEventListener( MouseEvent.MOUSE_DOWN, onDown );
			m_viewport.removeEventListener( MouseEvent.MOUSE_UP, onUp );
			m_viewport.removeEventListener( MouseEvent.MOUSE_MOVE, onMove );
			m_viewport.removeEventListener( MouseEvent.DOUBLE_CLICK, onDoubleClick );
		}
		
		private function onDown( _e:MouseEvent ):void{
			if( m_currentObject != null )
			{
				if( m_currentObject.onMouseDown && m_currentObject.onMouseDown.numListeners > 0 )
				{
					var event:MouseEvent3D = new MouseEvent3D( MouseEvent3D.MOUSE_DOWN );
					event.target3d = m_currentObject; event.currentTarget3d = m_currentObject;
					event.intersection = m_currentIntersection;
					event.x = m_pickRenderer.mouseCoordX;
					event.y = m_pickRenderer.mouseCoordY;
					event.camera = m_lastCamera;
					event.viewport = m_viewport;
					m_currentObject.onMouseDown.dispatch( event );
				}
				m_downObject = m_currentObject;
			}
		}
		
		private function onUp( _e:MouseEvent ):void{
			if( m_currentObject != null )
			{
				if( m_currentObject.onMouseUp && m_currentObject.onMouseUp.numListeners > 0 )
				{
					var event:MouseEvent3D = new MouseEvent3D( MouseEvent3D.MOUSE_UP );
					event.intersection = m_currentIntersection;
					event.target3d = m_currentObject; event.currentTarget3d = m_currentObject;
					event.x = m_pickRenderer.mouseCoordX;
					event.y = m_pickRenderer.mouseCoordY;
					event.camera = m_lastCamera;
					event.viewport = m_viewport;
					m_currentObject.onMouseUp.dispatch( event );
				}
				if( m_currentObject == m_downObject )
				{
					if( m_currentObject.onMouseClick && m_currentObject.onMouseClick.numListeners > 0 )
					{
						event = new MouseEvent3D( MouseEvent3D.CLICK );
						event.target3d = m_currentObject; event.currentTarget3d = m_currentObject;
						event.intersection = m_currentIntersection;
						event.x = m_pickRenderer.mouseCoordX;
						event.y = m_pickRenderer.mouseCoordY;
						event.camera = m_lastCamera;
						event.viewport = m_viewport;
						m_currentObject.onMouseClick.dispatch( event );
					}
					
					m_downObject = null;
				}
			}
		}
		
		private function onMove( _e:MouseEvent ):void{
			if( m_currentObject != null  && m_currentObject.onMouseMove && m_currentObject.onMouseMove.numListeners > 0)
			{
				var event:MouseEvent3D = new MouseEvent3D( MouseEvent3D.MOUSE_MOVE );
				event.intersection = m_currentIntersection;
				event.target3d = m_currentObject; event.currentTarget3d = m_currentObject;
				event.x = m_pickRenderer.mouseCoordX;
				event.y = m_pickRenderer.mouseCoordY;
				event.camera = m_lastCamera;
				event.viewport = m_viewport;
				m_currentObject.onMouseMove.dispatch( event );
			}
		}
		
		private function onDoubleClick( _e:MouseEvent ):void{
			if( m_currentObject != null  && m_currentObject.onMouseDoubleClick && m_currentObject.onMouseDoubleClick.numListeners > 0 )
			{
				var event:MouseEvent3D = new MouseEvent3D( MouseEvent3D.DOUBLE_CLICK );
				event.target3d = m_currentObject; event.currentTarget3d = m_currentObject;
				event.intersection = m_currentIntersection;
				event.x = m_pickRenderer.mouseCoordX;
				event.y = m_pickRenderer.mouseCoordY;
				event.camera = m_lastCamera;
				event.viewport = m_viewport;
				m_currentObject.onMouseDoubleClick.dispatch( event );
			}
		}
		
		public function update( _scene:IScene, _camera:Camera ):void
		{
			if( TickManager.LATEST_SYSTEM_TIME - m_lastUpdateTime >= updateTime )
			{
				m_lastCamera = _camera;
				
				m_lastUpdateTime = TickManager.LATEST_SYSTEM_TIME;
				
				if( m_viewport.width >= m_viewport.mouseX && m_viewport.height >= m_viewport.mouseY )
				{
					m_pickRenderer.mouseCoordX = m_viewport.mouseX;
					m_pickRenderer.mouseCoordY = m_viewport.mouseY;
					m_pickRenderer.render( _scene, _camera, m_viewport );
					
					m_lastObject = m_currentObject;
					
					m_currentObject = m_pickRenderer.lastHit;
					
					m_currentIntersection = m_pickRenderer.localHitPosition;
					
					var event:MouseEvent3D;
					
					if( m_lastObject != m_currentObject )
					{
						if( m_lastObject )
						{
							if( m_lastObject.useHandCursor )
							{
								Mouse.cursor = MouseCursor.AUTO;
							}
							if( m_lastObject.onMouseOut &&  m_lastObject.onMouseOut.numListeners > 0 )
							{
								event = new MouseEvent3D( MouseEvent3D.MOUSE_OUT );
								event.target3d = m_lastObject; event.currentTarget3d = m_lastObject;
								event.intersection = m_currentIntersection;
								event.x = m_pickRenderer.mouseCoordX;
								event.y = m_pickRenderer.mouseCoordY;
								event.camera = m_lastCamera;
								event.viewport = m_viewport;
								m_lastObject.onMouseOut.dispatch( event );
							}
						}
						
						if( m_currentObject )
						{
							if( m_currentObject.useHandCursor )
							{
								Mouse.cursor = MouseCursor.AUTO;
								Mouse.cursor = MouseCursor.BUTTON;
							}
							if( m_currentObject.onMouseOver && m_currentObject.onMouseOver.numListeners > 0 )
							{
								event = new MouseEvent3D( MouseEvent3D.MOUSE_OVER );
								event.target3d = m_currentObject; event.currentTarget3d = m_currentObject;
								event.intersection = m_currentIntersection;
								event.x = m_pickRenderer.mouseCoordX;
								event.y = m_pickRenderer.mouseCoordY;
								event.camera = m_lastCamera;
								event.viewport = m_viewport;
								m_currentObject.onMouseOver.dispatch( event );
							}
						}
					}
					if( m_currentObject == null )
					{
						Mouse.cursor = MouseCursor.AUTO;
					}
				}
				
			}
		}
	}
}
