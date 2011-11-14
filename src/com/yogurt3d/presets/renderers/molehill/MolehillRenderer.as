/*
* MolehillRenderer.as
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
	import com.yogurt3d.core.effects.Effect;
	import com.yogurt3d.core.effects.filters.Filter;
	import com.yogurt3d.core.effects.filters.FilterBoxBlur;
	import com.yogurt3d.core.geoms.SkeletalAnimatedMesh;
	import com.yogurt3d.core.geoms.SkinnedSubMesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.geoms.interfaces.IMesh;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.managers.rttmanager.RenderTargetManager;
	import com.yogurt3d.core.managers.vbstream.VertexStreamManager;
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.materials.shaders.ShaderDepthMap;
	import com.yogurt3d.core.materials.shaders.ShaderShadow;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderParameters;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.renderers.interfaces.IRenderer;
	import com.yogurt3d.core.sceneobjects.interfaces.IScene;
	import com.yogurt3d.core.sceneobjects.interfaces.ISceneObjectRenderable;
	import com.yogurt3d.core.sceneobjects.interfaces.ISelfRenderable;
	import com.yogurt3d.core.texture.BackBuffer;
	import com.yogurt3d.core.texture.RenderTextureTarget;
	import com.yogurt3d.core.texture.base.ETextureType;
	import com.yogurt3d.core.utils.Enum;
	import com.yogurt3d.core.utils.MatrixUtils;
	import com.yogurt3d.core.viewports.Viewport;
	import com.yogurt3d.presets.renderers.helper.IRendererHelper;
	import com.yogurt3d.presets.renderers.helper.Yogurt3DRendererHelper;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	use namespace YOGURT3D_INTERNAL;
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 * @change
	 * - added hidden object support (Gurel Erceis)
	 **/
	public class MolehillRenderer extends EngineObject implements IRenderer 
	{
		
		YOGURT3D_INTERNAL var rendererHelperClass		:Class					= Yogurt3DRendererHelper;
		YOGURT3D_INTERNAL var rendererHelper			:IRendererHelper;
		
		
		//shadow mapping shaders
		private var m_shadowDepthShader					:ShaderDepthMap;
		private var m_shadowRenderShader				:ShaderShadow;
		private var m_shadowFilter						:FilterBoxBlur;
		private var m_lastProgram						:Program3D;
		
		private var vsManager							:VertexStreamManager 	= VertexStreamManager.instance;
		
		private var rtManager							:RenderTargetManager 	= RenderTargetManager.instance;
		
		private var setStreamsFromShader				:Function 				= vsManager.setStreamsFromShader;
		
		private var setProgramConstants					:Function;

		private var _context3d							:Context3D;

		public static var RENDER_STATS					:String;
		
		public static const BACKBUFFER					:BackBuffer				= new BackBuffer();
		
		public var tempRect								:Rectangle 	= new Rectangle();
		
		public function MolehillRenderer(_initInternals:Boolean = true)
		{
			super(_initInternals);			
		}
		
		private function renderLayerSort( _a:ISceneObjectRenderable, _b:ISceneObjectRenderable ):Number{
			if(_a.renderLayer > _b.renderLayer ){return 1;}
			else if( _a.renderLayer < _b.renderLayer ){return -1;}
			else{return 0;}
		}
		
		public function render (_scene:IScene, _camera:ICamera, _viewport:Viewport):void 
		{
			Y3DCONFIG::DEBUG
			{
				var start:uint = getTimer();
			}
			_context3d = _viewport.context3d;
			
			var _postEffects:Vector.<Effect> = _scene.postEffects;
			
			var program:Program3D;
			
			
			var _renderableObject:ISceneObjectRenderable;
			var _mesh:IMesh;
			var _light:Light;
			
			
			
			var _renderableSet		:Vector.<ISceneObjectRenderable> 	= _scene.getRenderableSet(_camera);
			var _lights				:Vector.<Light>						= _scene.lightSet;

			_context3d.clear(_scene.sceneColor.r,_scene.sceneColor.g,_scene.sceneColor.b,_scene.sceneColor.a);
			
			rtManager.setRenderTo(_context3d, BACKBUFFER, false );
			
			if( !_renderableSet ) {_context3d.present();return;}
			
			var _numberOfRenderableObjects:uint = _renderableSet.length;	
			
			var _numberOfLights:uint			= (_lights) ? _lights.length : 0;
			
			rendererHelper.clearTextures( _context3d );
			
			_renderableSet = _renderableSet.sort( renderLayerSort );
			
			var len:uint; var subMeshIndex:int;
			
			// update shadow maps
			updateShadowMaps( _lights, _context3d, _scene );
			tempRect.setTo(0,0,_viewport.width,_viewport.height);
			// condition weather there are screen space post processing effects
			if(_postEffects.length > 0)
			{
				rtManager.setRenderTo( _context3d, _postEffects[0].filters[0].getRenderTarget(tempRect) , true, _scene.sceneColor );
			}
			else{
				// if shadow maps changed the render target from the backbuffer 
				// to simething else move back to backbuffer
				if( rtManager.getRenderTarget().type != ETextureType.BACK_BUFFER)
				{
					rtManager.setRenderTo(_context3d, BACKBUFFER, false );
				}
			}
				
			vsManager.cleanVertexBuffers( _context3d );
			
			renderSceneObjects(_renderableSet, _lights, _camera);
			renderShadowMaps(_lights, _context3d, _scene, _camera);
			
			vsManager.cleanVertexBuffers( _context3d );
			
			for(var i:uint = 0; i < _postEffects.length; i++){
				
				for( var j:int = 0; j < _postEffects[i].filters.length; j++ )
				{
					var sampler:RenderTextureTarget = rtManager.getRenderTarget();
					
					if((j+1) < _postEffects[i].filters.length)
					{
						// there is another filter in the effect
						rtManager.setRenderTo( _context3d, _postEffects[i].filters[j+1].getRenderTarget(tempRect), true );
					}else if((i+1) < _postEffects.length){
						// if there is no filter in this effect move onto next effect is there is
						rtManager.setRenderTo( _context3d, _postEffects[i+1].filters[0].getRenderTarget(tempRect), true );
					}else{
						rtManager.setRenderTo( _context3d, BACKBUFFER, false );
					}
					_postEffects[i].filters[j].postProcess(_context3d, tempRect, sampler);
					
				}
				
			}
			rendererHelper.endScene();
			rendererHelper.clearTextures( _context3d );
			
			_context3d.present();
			
			m_lastProgram = null;
			// clear vertex buffers
			Y3DCONFIG::DEBUG
			{
				Yogurt3D.DEBUG_TEXT = "Render Time:" + (getTimer() - start) ;
			}
			
		}

		override protected function initInternals():void
		{
		
			m_shadowDepthShader 			= new ShaderDepthMap();
			
			m_shadowRenderShader  			= new ShaderShadow();
			
			m_shadowFilter 					= new FilterBoxBlur();
			
			rendererHelper 					= new rendererHelperClass() as IRendererHelper;
			setProgramConstants 			= rendererHelper.setProgramConstants;
		}	
		
		private function renderShadowMaps(_lights:Vector.<Light>, _context3d:Context3D, _scene:IScene, _camera:ICamera):void
		{
			var k:int;
			var _renderableObject:ISceneObjectRenderable;
			var i:int;
			
			var m_tempMatrix:Matrix3D = new Matrix3D();
			if( _lights )
			{
				for ( k = 0; k < _lights.length; k++) {
					var _light:Light = _lights[k];	
					if( _light.castShadows )
					{
						var _lightRenderables:Vector.<ISceneObjectRenderable> = _scene.getRenderableSet( _camera );
						renderShadow(_lightRenderables, _light, _camera);
						
						if(_light.type == ELightType.POINT)
						{
							
							_context3d.setTextureAt(1, null);
						}
						
					}
				}
				m_lastProgram = null;
				
			}
		}
		
		private function updateShadowMaps(_lights:Vector.<Light>, _context3d:Context3D, _scene:IScene):void
		{
			var k:int;
			var _renderableObject:ISceneObjectRenderable;
			var i:int;
			
			var m_tempMatrix:Matrix3D = new Matrix3D();
			if( _lights )
			{				
				for ( k = 0; k < _lights.length; k++) {
					var _light:Light = _lights[k];	
					if( _light.castShadows )
					{
					    rtManager.setRenderTo( _context3d, _light.shadowMap, true );
						
						_context3d.setBlendFactors( Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
						
						_context3d.setColorMask( true, true, true, true);
						
						_context3d.setDepthTest( true, Context3DCompareMode.LESS );
						
						_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([1, 255, 65025, 160581375, 0.003921569, 0.003921569, 0.009, 0 ]), 2);

						_context3d.setCulling( Context3DTriangleFace.FRONT );
						
						var _lightRenderables:Vector.<ISceneObjectRenderable> = _scene.getRenderableSet(_light);
						
						if(_light.type == ELightType.POINT)
						{
							_context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([_light.range, 0, -1, 1]), 1);//w is near
							drawShadowMap( _context3d, _lightRenderables , _light );	

							rtManager.setRenderTo( _context3d, _light.shadowMap2, true );
							
							_context3d.setCulling( Context3DTriangleFace.BACK );
							_context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([_light.range, 0,  1, 1]), 1);//w is near
							
							drawShadowMap( _context3d, _lightRenderables, _light );
							
						}else{
							drawShadowMap( _context3d, _lightRenderables, _light );	
						}
						
						
						if(_light.isFilteringOn)
						{
							vsManager.cleanVertexBuffers( _context3d );
							
							var lightShadowMapRect:Rectangle = new Rectangle(0,0,_light.shadowMap.width,_light.shadowMap.height);
							rtManager.setRenderTo( _context3d, m_shadowFilter.getRenderTarget( lightShadowMapRect ) );
							
							//horizantal							
							m_shadowFilter.setdirection(1,0);
							m_shadowFilter.postProcess(_context3d, lightShadowMapRect, _light.shadowMap);
							
							
							// swap buffers
							m_shadowFilter.YOGURT3D_INTERNAL::m_renderTarget = _light.shadowMap;
							_light.shadowMap = rtManager.getRenderTarget();
							
							
							rtManager.setRenderTo( _context3d, m_shadowFilter.getRenderTarget( lightShadowMapRect ) );
							
							//vertical
							m_shadowFilter.setdirection(0,1);
							m_shadowFilter.postProcess(_context3d, lightShadowMapRect, _light.shadowMap);
							
							// swap buffers
							m_shadowFilter.YOGURT3D_INTERNAL::m_renderTarget = _light.shadowMap;
							_light.shadowMap = rtManager.getRenderTarget();
							
							if( _light.type == ELightType.POINT )
							{
								lightShadowMapRect.setTo(0,0,_light.shadowMap2.width,_light.shadowMap2.height);
								rtManager.setRenderTo( _context3d, m_shadowFilter.getRenderTarget( lightShadowMapRect ) );
								
								m_shadowFilter.setdirection(1,0);
								m_shadowFilter.postProcess(_context3d, lightShadowMapRect, _light.shadowMap2);
							
								
								m_shadowFilter.YOGURT3D_INTERNAL::m_renderTarget = _light.shadowMap2;
								_light.shadowMap2 = rtManager.getRenderTarget();
								
								rtManager.setRenderTo( _context3d, m_shadowFilter.getRenderTarget( lightShadowMapRect ) );

								m_shadowFilter.setdirection(0,1);
								m_shadowFilter.postProcess(_context3d, lightShadowMapRect, _light.shadowMap2);
								
								m_shadowFilter.YOGURT3D_INTERNAL::m_renderTarget = _light.shadowMap2;
								_light.shadowMap2 = rtManager.getRenderTarget();
							}
							

						}
					}
				}
				m_lastProgram = null;
			}
		}
		
		private function drawShadowMap( _context3d:Context3D, _renderableSet:Vector.<ISceneObjectRenderable>, _light:Light):void{
			
			var _renderableObject:ISceneObjectRenderable;

			var _params:ShaderParameters  = m_shadowDepthShader.params;
			

			_light.setProjection(); //can be bind to "rotational dirty" state  
		

			
			var _numberOfRenderableObjects:int  = _renderableSet.length;			
			
			for (var i:uint = 0; i < _numberOfRenderableObjects; i++ ) {
				// get renderable object and properties
				_renderableObject = _renderableSet[i];				
			
				// don't render if not cast or receive shadows
				if(!_renderableObject.visible || _renderableObject is ISelfRenderable || !(_renderableObject.castShadows || _renderableObject.receiveShadows)){
					continue;
				}
				
				var _mesh:IMesh = _renderableObject.geometry;
				if (!_mesh) { trace("Renderable object with no geometry.."); 	break;	}
				
				var len:int = _mesh.subMeshList.length;
				
				for(var subMeshIndex:int = 0; subMeshIndex < len; subMeshIndex++)
				{
					_context3d.setProgram( m_shadowDepthShader.getProgram( _context3d, _light.type, _renderableObject.geometry.subMeshList[subMeshIndex].type ) );
					
					// get vertex buffer
					vsManager.setStreamsFromShader( _context3d, _renderableObject.geometry.subMeshList[subMeshIndex], m_shadowDepthShader );
					
					if( !setProgramConstants(_context3d, _params, _light, null, _renderableObject, _mesh.subMeshList[subMeshIndex]) )
					{
						continue;
					}
					
					// draw triangles
					_context3d.drawTriangles(_mesh.subMeshList[subMeshIndex].getIndexBufferByContext3D(_context3d ), 0, _mesh.subMeshList[subMeshIndex].triangleCount);
				}
				
			}
		}
		
		private function renderShadow(_renderableSet:Vector.<ISceneObjectRenderable>,  _light:Light, _camera:ICamera):void
		{
			var _renderableObject:ISceneObjectRenderable;
			var _mesh:IMesh;
			var i:int,j:int,k:int,l:int;
			var len:uint; var subMeshIndex:int;
			var program:Program3D;
			
			var _numberOfRenderableObjects:uint = _renderableSet.length;
			
			var _params:ShaderParameters  = m_shadowRenderShader.params;
			
			// Set Blending
			_context3d.setBlendFactors( _params.blendSource, _params.blendDestination);
			
			_context3d.setColorMask( _params.colorMaskR, _params.colorMaskG, _params.colorMaskB, _params.colorMaskA);
			
			// set Depth
			_context3d.setDepthTest( _params.writeDepth, _params.depthFunction );
			
			// set Culling
			_context3d.setCulling( _params.culling );
			
			if(_light.type == ELightType.POINT)
			{
				_context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, Vector.<Number>([0.5, 0, _light.range, 1]), 1);//w is near
				_context3d.setTextureAt(1, _light.shadowMap2.getTexture3D(_context3d));
			}
			
			for (i = 0; i < _numberOfRenderableObjects; i++ ) {
				// get renderable object and properties
				_renderableObject = _renderableSet[i];
				
				if( !_renderableObject.receiveShadows || !_renderableObject.visible ) continue;
				
				_mesh = _renderableObject.geometry;
				if (!_mesh) { trace("Renderable object with no geometry.."); continue; }
				
				len = _mesh.subMeshList.length;
				for( subMeshIndex = 0; subMeshIndex < len; subMeshIndex++)
				{
					// set shader program
					program = m_shadowRenderShader.getProgram(_context3d, _light.type, _mesh.subMeshList[subMeshIndex].type);
					if( program != m_lastProgram )
					{
						_context3d.setProgram( program );
						m_lastProgram = program;
					}
					
					setStreamsFromShader( _context3d, _mesh.subMeshList[subMeshIndex], m_shadowRenderShader );
					
					// set program constants
					if( !setProgramConstants(_context3d, _params, _light, _camera, _renderableObject, _mesh.subMeshList[subMeshIndex]) )
					{
						continue;
					}
					_context3d.drawTriangles(_mesh.subMeshList[subMeshIndex].getIndexBufferByContext3D(_context3d), 0, _mesh.subMeshList[subMeshIndex].triangleCount);
				}
				
			}
			
		}

		private function renderSceneObjects(  _renderableSet :Vector.<ISceneObjectRenderable>,  _lights :Vector.<Light>, _camera:ICamera ):void{
			var _renderableObject:ISceneObjectRenderable;
			var _mesh:IMesh;
			var _light:Light;
			var i:int,j:int,k:int,l:int;
			var len:uint; var subMeshIndex:int;
			var program:Program3D;
			
			var streamTotal:uint = 0;
			
			var _numberOfRenderableObjects:uint = _renderableSet.length;
			
			rendererHelper.beginScene(_camera);
			
			for (i = 0; i < _numberOfRenderableObjects; i++ ) {
				
				// get renderable object and properties
				_renderableObject = _renderableSet[i];				
				if( !_renderableObject.visible ) continue;
				
				// Self Renderable Scene Object Handling
				if (_renderableObject is ISelfRenderable) {				
					vsManager.cleanVertexBuffers( _context3d );
					
					(_renderableObject as ISelfRenderable).render( _context3d, _camera );
					
					vsManager.cleanVertexBuffers( _context3d );
					
					m_lastProgram = null;
					continue;
				}
				_mesh = _renderableObject.geometry;
				if (!_mesh) { trace("Renderable object with no geometry.."); 	continue;	}
				
				var _material:Material = _renderableObject.material;
				if (!_material) { trace("Renderable object with no material");	continue;	}
				
				
				var _shaders:Vector.<Shader> = _material.shaders;
				if (!_shaders || _shaders.length < 1) {	trace("Material with no shader");	continue;	}
				
				
				// for each shader in material
				for (j=0; j < _shaders.length; j++) {
					
					var _shader:Shader = _shaders[j];
					// get shader parameters
					var _params:ShaderParameters = _shader.params;
					
					// Set Blending
					_context3d.setBlendFactors( _params.blendSource, _params.blendDestination);
					
					_context3d.setColorMask( _params.colorMaskR, _params.colorMaskG, _params.colorMaskB, _params.colorMaskA);
					
					// set depth
					_context3d.setDepthTest( _params.writeDepth, _params.depthFunction );
					
					// set culling
					_context3d.setCulling( _params.culling );
					
					if ( _shader.requiresLight && _lights != null)
					{
						for ( k = 0; k < _lights.length; k++) {
							_light = _lights[k];	
														
							// draw triangles
							len = _mesh.subMeshList.length;
							for( subMeshIndex = 0; subMeshIndex < len; subMeshIndex++)
							{
								// set shader program
								program = _shader.getProgram(_context3d, _light.type, _mesh.subMeshList[subMeshIndex].type);
								if( program != m_lastProgram )
								{
									_context3d.setProgram( program );
									m_lastProgram = program;
								}	
								
								setStreamsFromShader( _context3d, _mesh.subMeshList[subMeshIndex], _shader );
								
								// set program constants
								if( !setProgramConstants(_context3d, _params, _light, _camera, _renderableObject, _mesh.subMeshList[subMeshIndex] ) )
								{
									continue;
								}
								_context3d.drawTriangles(_mesh.subMeshList[subMeshIndex].getIndexBufferByContext3D(_context3d), 0, _mesh.subMeshList[subMeshIndex].triangleCount);
							}
						}
						
					}
					else if( !_shader.requiresLight )
					{			
						// draw triangles
						len = _mesh.subMeshList.length;
						for( subMeshIndex = 0; subMeshIndex < len; subMeshIndex++)
						{
							// set shader program
							program = _shader.getProgram(_context3d, null, _mesh.subMeshList[subMeshIndex].type);
							if( program != m_lastProgram )
							{
								_context3d.setProgram( program );
								m_lastProgram = program;
							}
							
							setStreamsFromShader( _context3d, _mesh.subMeshList[subMeshIndex], _shader );

							// set program constants
							if( !setProgramConstants(_context3d, _params, null, _camera, _renderableObject, _mesh.subMeshList[subMeshIndex]) )
							{
								continue;
							}
							_context3d.drawTriangles(_mesh.subMeshList[subMeshIndex].getIndexBufferByContext3D(_context3d), 0, _mesh.subMeshList[subMeshIndex].triangleCount);
						}
					}
					
				}// end for shader loop			
			}
		}		
	}
}
