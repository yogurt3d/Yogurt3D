/*
 * PickRenderer.as
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
 
 
package com.yogurt3d.presets.renderers.molehill
{
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.cameras.interfaces.ICamera;
	import com.yogurt3d.core.geoms.SkeletalAnimatedMesh;
	import com.yogurt3d.core.geoms.SkinnedSubMesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.geoms.interfaces.IMesh;
	import com.yogurt3d.core.managers.vbstream.VertexStreamManager;
	import com.yogurt3d.core.materials.shaders.ShaderHitObject;
	import com.yogurt3d.core.materials.shaders.ShaderHitTriangle;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.renderers.interfaces.IRenderer;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	import com.yogurt3d.core.utils.MatrixUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DClearMask;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class PickRenderer extends EngineObject implements IRenderer
	{
		private var m_initialized:Boolean = false;
		
		private var shader:ShaderHitObject;
		private var shaderTriangle:ShaderHitTriangle;
		private var m_bitmapData:BitmapData;
		
		private var vsManager:VertexStreamManager = VertexStreamManager.instance;
		
		private var m_viewMatrix					:Matrix3D				= new Matrix3D();
		private var m_modelViewMatrix				:Matrix3D				= new Matrix3D();
		private var m_tempMatrix					:Matrix3D 				= MatrixUtils.TEMP_MATRIX;
		
		private var m_boneDataDirty					:Boolean = false;
		
		private var m_lastProgram					:Program3D = null;
		
		private var m_viewportData					:Vector.<Number> = new Vector.<Number>( 4, true );
		
		private var m_boundScale					:Vector.<Number> = new Vector.<Number>( 4, true );
		private var m_boundOffset					:Vector.<Number> = new Vector.<Number>( 4, true );
		
		private var m_mouseCoordX					:Number;
		
		private var m_mouseCoordY					:Number;
		
		private var m_lastHit						:ISceneObjectRenderable;
		
		private var m_localHitPosition:Vector3D;

		private var _context3d:Context3D = Yogurt3D.CONTEXT3D[3];
		
		private var m_lastVertexBufferLength:uint = 0;
		
		public function PickRenderer(_initInternals:Boolean=true)
		{
			super(_initInternals);
		}
		
		public function get localHitPosition():Vector3D
		{
			return m_localHitPosition;
		}

		public function set localHitPosition(value:Vector3D):void
		{
			m_localHitPosition = value;
		}

		public function get lastHit():ISceneObjectRenderable
		{
			return m_lastHit;
		}

		public function set lastHit(value:ISceneObjectRenderable):void
		{
			m_lastHit = value;
		}

		public function get mouseCoordY():Number
		{
			return m_mouseCoordY;
		}

		public function set mouseCoordY(value:Number):void
		{
			m_mouseCoordY = value;
		}

		public function get mouseCoordX():Number
		{
			return m_mouseCoordX;
		}

		public function set mouseCoordX(value:Number):void
		{
			m_mouseCoordX = value;
		}

		private function initHandler( _e:Event ):void{
			_context3d = Yogurt3D.CONTEXT3D[3] = _e.target.context3D;
		}
		
		public function render(_scene:IScene, _camera:ICamera, _viewport:Viewport):void
		{		
			m_lastHit = null;
			
			if( _context3d == null  )
			{
				if( Yogurt3D.CONTEXT3D[3] == null )
				{
					_viewport.stage.stage3Ds[3].addEventListener( Event.CONTEXT3D_CREATE, initHandler );
					_viewport.stage.stage3Ds[3].requestContext3D();	
					return;
				}else{
					_context3d = Yogurt3D.CONTEXT3D[3];
					_viewport.stage.stage3Ds[3].x = -50;
					_viewport.stage.stage3Ds[3].y = -50;
				}
			}
			
			
			if( !m_initialized)
			{
				_context3d.configureBackBuffer(50,50,0,true);
				m_initialized = true;
			}
			
			var _renderableObject:ISceneObjectRenderable;
			var _mesh:IMesh;
			var _vertexBuffer:VertexBuffer3D;
			var submeshlen:uint;
			var subMeshIndex:uint;
			var program:Program3D;
			var _submesh:SubMesh;
			
			var boneIndex:int;
			var originalBoneIndex:uint;
			
			// clean buffer
			_context3d.clear(0,0,0,0);
			_context3d.setScissorRectangle( new Rectangle( 0,0,1,1 ) );
			// disable blending
			_context3d.setBlendFactors( "one", "zero");
			_context3d.setColorMask( true, true, true, true);
			_context3d.setDepthTest( true, Context3DCompareMode.LESS );
			
			// viewport data that is used to shift the canvas under the mouse to 0,0 coordinates
			m_viewportData[2] = _viewport.width ;
			m_viewportData[3] = _viewport.height;
			m_viewportData[0] = 1 - ( m_mouseCoordX / _viewport.width ) * 2;
			m_viewportData[1] = ( m_mouseCoordY / _viewport.height ) * 2 - 1;
			
			// upload the viewport data
			_context3d.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 4, m_viewportData, 1 );
			
			// foe each renderable object loop
			var _renderableSet:Vector.<ISceneObjectRenderable> = _scene.getRenderableSet(_camera);
			
			var len:uint = (_renderableSet)?_renderableSet.length:0;
			
			m_viewMatrix.copyFrom( _camera.transformation.matrixGlobal );
			m_viewMatrix.invert();
			m_viewMatrix.append(_camera.frustum.projectionMatrix);
			
			for( var i:int = 0; i < len; i++ )
			{
				_renderableObject = _renderableSet[i];
				
				// if picking is disabled for object skip
				if( !_renderableObject.pickEnabled || !_renderableObject.visible ) continue;
				if( _renderableObject.geometry == null ) continue;
				// calculate model view prrojection matrix
				m_modelViewMatrix.copyFrom( _renderableObject.transformation.matrixGlobal );	
				m_modelViewMatrix.append( m_viewMatrix );
				
				// upload modelViewProjectionMatrix
				_context3d.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, m_modelViewMatrix, true );
				
				// set the selection index to objects' position on the renderable set plus one
				var selectionIndex:uint = i + 1;
				
				// split the selection index into 4 floating points
				_context3d.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 0, Vector.<Number>([
					(((selectionIndex) % 32) << 3) / 255.0, 
					(((selectionIndex>>5) % 32) << 3) / 255.0, 
					(((selectionIndex>>10) % 32) << 3) / 255.0, 1
					
				]), 1 );
				
				// for each submesh 
				submeshlen = _renderableObject.geometry.subMeshList.length;
				for( subMeshIndex = 0; subMeshIndex < submeshlen; subMeshIndex++ )
				{
					_submesh = _renderableObject.geometry.subMeshList[subMeshIndex];
					// get program
					program = shader.getProgram( _context3d, null, _submesh.type );
					
					if( program != m_lastProgram )
					{
						// set program
						_context3d.setProgram( program );
						m_lastProgram = program;
					}
					// set vertex streams
					vsManager.setStreamsFromShader( _context3d, _submesh, shader);
					
					// if skinned upload bone matrices
					if( _submesh is SkinnedSubMesh )
					{
						for( boneIndex = 0; boneIndex < SkinnedSubMesh(_submesh).originalBoneIndex.length; boneIndex++)
						{	
							originalBoneIndex = SkinnedSubMesh(_submesh).originalBoneIndex[boneIndex];
							m_tempMatrix.copyFrom( SkeletalAnimatedMesh(_renderableObject.geometry).bones[originalBoneIndex].transformationMatrix );
							_context3d.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 9 + (boneIndex*3), m_tempMatrix.rawData, 3 );
						}
					}
					// draw
					_context3d.drawTriangles( _submesh.getIndexBufferByContext3D( _context3d ), 0, _submesh.triangleCount );
				}
			}
			
			// draw single pixel to bitmap
			_context3d.drawToBitmapData( m_bitmapData );
			
			// get selection color code
			var selectedIndexColor:uint = m_bitmapData.getPixel( 0,0 );
			// find selected object index
			var red:uint 	= (selectedIndexColor>>16) & 0xFF;
			var green:uint 	= (selectedIndexColor>>8) & 0xFF;
			var blue:uint 	= (selectedIndexColor) & 0xFF;
			var selectedIndex:uint = (( red / 8.0 )) +  (( green / 8.0 ) << 5) +  (( blue / 8.0 ) << 10);

			if( selectedIndex != 0 && selectedIndex <= _renderableSet.length && _renderableSet[ selectedIndex - 1].interactive )
			{
				m_lastHit = _renderableSet[ selectedIndex - 1];	
			}else{
				m_lastHit = null;
			}
			
			m_lastProgram = null;
			
			// if an object is picked
			if( m_lastHit )
			{
				_context3d.clear( 0, 0, 0, 0, 1, 0, Context3DClearMask.DEPTH );
				
				_renderableObject = m_lastHit;
				
				var scX:Number;
				var scY:Number;
				var scZ:Number;
				var offsX:Number, offsY:Number, offsZ:Number;
			
				var max:Vector3D = new Vector3D();
				var min:Vector3D = new Vector3D();
				// for each submesh 
				submeshlen = _renderableObject.geometry.subMeshList.length;
				for( subMeshIndex = 0; subMeshIndex < submeshlen; subMeshIndex++ )
				{
					_submesh = _renderableObject.geometry.subMeshList[subMeshIndex];
					
					_submesh.axisAlignedBoundingBox.update( new Matrix3D() );
					
					if( subMeshIndex == 0 )
					{
						max.x = _submesh.axisAlignedBoundingBox.max.x;
						max.y = _submesh.axisAlignedBoundingBox.max.y;
						max.z = _submesh.axisAlignedBoundingBox.max.z;
						
						min.x = _submesh.axisAlignedBoundingBox.min.x;
						min.y = _submesh.axisAlignedBoundingBox.min.y;
						min.z = _submesh.axisAlignedBoundingBox.min.z;
					}else{
						if( _submesh.axisAlignedBoundingBox.max.x > max.x )
						{
							max.x = _submesh.axisAlignedBoundingBox.max.x
						}
						if( _submesh.axisAlignedBoundingBox.max.y > max.y )
						{
							max.y = _submesh.axisAlignedBoundingBox.max.y
						}
						if( _submesh.axisAlignedBoundingBox.max.z > max.z )
						{
							max.z = _submesh.axisAlignedBoundingBox.max.z
						}
						if( _submesh.axisAlignedBoundingBox.min.x < min.x )
						{
							min.x = _submesh.axisAlignedBoundingBox.min.x
						}
						if( _submesh.axisAlignedBoundingBox.min.y < min.y )
						{
							min.y = _submesh.axisAlignedBoundingBox.min.y
						}
						if( _submesh.axisAlignedBoundingBox.min.z < min.z )
						{
							min.z = _submesh.axisAlignedBoundingBox.min.z
						}
					}
				}
				m_boundScale[0] = scX = 1 / (max.x - min.x);
				m_boundScale[1] = scY = 1 / (max.y - min.y);
				m_boundScale[2] = scZ = 1 / (max.z - min.z);
				
				m_boundOffset[0] = offsX = -min.x;
				m_boundOffset[1] = offsY = -min.y;
				m_boundOffset[2] = offsZ = -min.z;
				
				m_modelViewMatrix.copyFrom( _renderableObject.transformation.matrixGlobal );
				
				m_modelViewMatrix.append( m_viewMatrix );
				
				//m_modelMatrix.append( m_projectionMatrix );
				
				_context3d.setDepthTest( false, Context3DCompareMode.ALWAYS );
				_context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m_modelViewMatrix, true);
				_context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, m_viewportData, 1 );
				_context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, m_boundOffset, 1);
				_context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 6, m_boundScale, 1);
				
				for( subMeshIndex = 0; subMeshIndex < submeshlen; subMeshIndex++ )
				{
					_submesh = _renderableObject.geometry.subMeshList[subMeshIndex];
					
					// get program
					program = shaderTriangle.getProgram( _context3d, null, _submesh.type );
					
					if( program != m_lastProgram )
					{
						// set program
						_context3d.setProgram( program );
						m_lastProgram = program;
					}
					// set vertex streams
					vsManager.setStreamsFromShader( _context3d, _submesh, shaderTriangle);
					
					// if skinned upload bone matrices
					if( _submesh is SkinnedSubMesh )
					{
						for( boneIndex = 0; boneIndex < SkinnedSubMesh(_submesh).originalBoneIndex.length; boneIndex++)
						{	
							originalBoneIndex = SkinnedSubMesh(_submesh).originalBoneIndex[boneIndex];
							m_tempMatrix.copyFrom( SkeletalAnimatedMesh(_renderableObject.geometry).bones[originalBoneIndex].transformationMatrix );
							_context3d.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 8 + (boneIndex*3), m_tempMatrix.rawData, 3 );
						}
					}
					// draw
					_context3d.drawTriangles( _submesh.getIndexBufferByContext3D( _context3d ), 0, _submesh.triangleCount );
				}
				
				_context3d.drawToBitmapData( m_bitmapData );
				
				var col:uint = m_bitmapData.getPixel(0, 0);
				
				localHitPosition = new Vector3D();
				
				localHitPosition.x = ((col >> 16) & 0xFF) / (scX*255) - offsX;
				localHitPosition.y = ((col >> 8)  & 0xFF) / (scY*255) - offsY;
				localHitPosition.z = (col 		  & 0xFF) / (scZ*255) - offsZ;
			}
			
			_context3d.present();			
		}
		
		protected override function initInternals():void{
			shader = new ShaderHitObject();
			shaderTriangle = new ShaderHitTriangle();
			
			m_bitmapData = new BitmapData( 1, 1, false, 0x00000000 );
		}
	}
}
