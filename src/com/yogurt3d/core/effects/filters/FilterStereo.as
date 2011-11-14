/*
* FilterStereo.as
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



package com.yogurt3d.core.effects.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.cameras.interfaces.ICamera;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.utils.MathUtils;
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * Implements stereo vision for various anaglyph and 3DTV formats.
	 * 
	 * @author Ozgun Genc
	 * @company Yogurt3D Corp.
	 **/
	public class FilterStereo extends Filter
	{
		
		private var m_cameraBaselineDistance:Number;
		private var m_cameraConvergence:Number;
		
		private var m_camera:Camera;
		private var m_originalCameraLocalMatrix:Matrix3D;
		private var m_cameraLookAt:Vector3D;
		
		private var m_stereoMode:int = 0;
		
		private var m_switchViews:Boolean = false;
		
		public static const ANAGLYPH_RED_CYAN:int = 0;
		public static const ANAGLYPH_GREEN_MAGENTA:int = 1;
		public static const ANAGLYPH_BLUE_YELLOW:int = 2;
		public static const STEREO_INTERLEAVED_COLUMNS:int = 3;
		public static const STEREO_INTERLEAVED_ROWS:int = 4;
		public static const STEREO_INTERLEAVED_CHECKERBOARD:int = 5;
		public static const STEREO_SIDEBYSIDE:int = 6;
		public static const STEREO_TOP_BOTTOM:int = 7;
		public static const STEREO_LEFT_ONLY:int = 8;
		public static const STEREO_RIGHT_ONLY:int = 9;
		public static const STEREO_MODES_MAX:int = 10;
		
		
		//private var m_leftCameraTransformation:Matrix3D;
		//private var m_rightCameraTransformation:Matrix3D;
		
		protected var m_leftTextureDict:Dictionary;
		protected var m_rightTextureDict:Dictionary;
		
		public function FilterStereo(_camera:Camera, _stereoMode:int = ANAGLYPH_RED_CYAN, _cameraBaselineDistance:Number = .2, _cameraLookAt:Vector3D = null)
		{
			super();
			
			m_camera = _camera;
			
			m_stereoMode = _stereoMode;
			
			m_cameraBaselineDistance = _cameraBaselineDistance;
			
			m_originalCameraLocalMatrix = new Matrix3D();
			
			if (_cameraLookAt) m_cameraLookAt = _cameraLookAt; 
			else m_cameraLookAt = new Vector3D();
			
			m_leftTextureDict = new Dictionary();
			m_rightTextureDict = new Dictionary();
		}
		
		public function get cameraLookAt():Vector3D
		{
			return m_cameraLookAt;
		}

		public function set cameraLookAt(value:Vector3D):void
		{
			m_cameraLookAt = value;
		}

		public function get switchViews():Boolean
		{
			return m_switchViews;
		}

		public function set switchViews(value:Boolean):void
		{
			m_switchViews = value;
			
		}

		public function get stereoMode():int
		{
			return m_stereoMode;
		}
		
		public function set stereoMode(value:int):void
		{
			m_stereoMode = value;
			disposeShaders();
		}
		
		public function get cameraBaselineDistance():Number
		{
			return m_cameraBaselineDistance;
		}
		
		public function set cameraBaselineDistance(value:Number):void
		{
			m_cameraBaselineDistance = value;
		}
		
		public function get camera():Camera
		{
			return m_camera;
		}
		
		public function set camera(value:Camera):void
		{
			m_camera = value;
		}
		
		public function startRenderToLeftTexture(_context3d:Context3D, _viewport:Viewport):void
		{
			if(m_leftTextureDict[_context3d] == null){
				m_width  = MathUtils.getClosestPowerOfTwo(_viewport.width);
				m_height = MathUtils.getClosestPowerOfTwo(_viewport.height);
				//	trace(this.width , this.height);
				m_leftTextureDict[_context3d] = _context3d.createTexture(m_width, m_height, Context3DTextureFormat.BGRA, true );
			}
			_context3d.setRenderToTexture(m_leftTextureDict[_context3d], true, _viewport.antiAliasing);
			_context3d.clear();
		}
		
		public function startRenderToRightTexture(_context3d:Context3D, _viewport:Viewport):void
		{
			if(m_rightTextureDict[_context3d] == null){
				m_width  = MathUtils.getClosestPowerOfTwo(_viewport.width);
				m_height = MathUtils.getClosestPowerOfTwo(_viewport.height);
				//	trace(this.width , this.height);
				m_rightTextureDict[_context3d] = _context3d.createTexture(m_width, m_height, Context3DTextureFormat.BGRA, true );
			}
			_context3d.setRenderToTexture(m_rightTextureDict[_context3d], true, _viewport.antiAliasing);
			_context3d.clear();
		}
		

		
		public function moveCameraToLeftView():void
		{
			moveCameraToCentralView();
			if (!m_switchViews) m_camera.transformation.moveAlongLocal(-m_cameraBaselineDistance,0,0);
			else m_camera.transformation.moveAlongLocal(m_cameraBaselineDistance,0,0);
			
			m_camera.transformation.lookAt(m_cameraLookAt);
			//trace(m_camera.transformation.matrixGlobal.rawData);
		}
		
		public function moveCameraToRightView():void
		{
			moveCameraToCentralView();
			if (!m_switchViews) m_camera.transformation.moveAlongLocal(m_cameraBaselineDistance,0,0);
			else m_camera.transformation.moveAlongLocal(-m_cameraBaselineDistance,0,0);
			m_camera.transformation.lookAt(m_cameraLookAt);
		}
		
		public function moveCameraToCentralView():void
		{
			m_camera.transformation.matrixLocal.copyFrom(	m_originalCameraLocalMatrix );
		}
		
		public function saveCameraCentralPosition(_camera:ICamera):void
		{
			m_camera = Camera(_camera);
			m_originalCameraLocalMatrix.copyFrom( m_camera.transformation.matrixLocal );
		}
		
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray
		{
			
			switch (m_stereoMode){
				case ANAGLYPH_RED_CYAN:
					return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
						[
							"tex ft1, v0.xy, fs1 <2d,repeat,linear>", // get left render to texture
							"tex ft2, v0.xy, fs2 <2d,repeat,linear>", // get right render to texture
							
							"mov ft0.x ft1.x",
							"mov ft0.yz ft2.yz",
							"mov ft0.w fc0.w",
							
							
							"mov oc, ft0"
							
						].join("\n")
					);
					
				case ANAGLYPH_GREEN_MAGENTA:
					return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
						[
							"tex ft1, v0.xy, fs1 <2d,repeat,linear>", // get left render to texture
							"tex ft2, v0.xy, fs2 <2d,repeat,linear>", // get right render to texture
							
							
							"mov ft0.y ft1.y",
							"mov ft0.xz ft2.xz",
							"mov ft0.w fc0.w",
							
							
							"mov oc, ft0"
							
						].join("\n")
					);
				case ANAGLYPH_BLUE_YELLOW:
					return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
						[
							"tex ft1, v0.xy, fs1 <2d,repeat,linear>", // get left render to texture
							"tex ft2, v0.xy, fs2 <2d,repeat,linear>", // get right render to texture
					
						
							"mov ft0.z ft1.z",
							"mov ft0.xy ft2.xy",
							"mov ft0.w fc0.w",
							
							
							"mov oc, ft0"
							
						].join("\n")
					);
				case STEREO_INTERLEAVED_COLUMNS:
					return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
						[
							"tex ft1, v0.xy, fs1 <2d,repeat,linear>", // get left render to texture
							"tex ft2, v0.xy, fs2 <2d,repeat,linear>", // get right render to texture
							
							// test colors
//							"mov ft1, fc2",
//							"mov ft2, fc3",
							
							
							"mul ft3.x v.x fc1.x", // v.x*(width-1)
							"div ft3.x ft3.x fc1.w", // divide by 2
							"frc ft3.x ft3.x", //get the fraction
							"sge ft3.x ft3.x fc1.z", //set if greater equal than epsilon (odd numbered line)
							"slt ft3.y ft3.x fc1.z", //set if less than threshold (even numbered line)
							
							// mask
							"mul ft1 ft1 ft3.yyyy", // left
							"mul ft2 ft2 ft3.xxxx", // right
							
							// combine them together
							"add ft0 ft1 ft2",
							
							
							"mov oc, ft0"
							
						].join("\n")
					);
				case STEREO_INTERLEAVED_ROWS:
					return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
						[
							"tex ft1, v0.xy, fs1 <2d,repeat,linear>", // get left render to texture
							"tex ft2, v0.xy, fs2 <2d,repeat,linear>", // get right render to texture
							
							// test colors
//							"mov ft1, fc2",
//							"mov ft2, fc3",
							
							
							"mul ft3.x v.y fc1.y", // v.y*(height-1)
							"div ft3.x ft3.x fc1.w", // divide by 2
							"frc ft3.x ft3.x", //get the fraction
							"sge ft3.x ft3.x fc1.z", //set if greater equal than epsilon (odd numbered line)
							"slt ft3.y ft3.x fc1.z", //set if less than threshold (even numbered line)
							
							// mask
							"mul ft1 ft1 ft3.yyyy", // left
							"mul ft2 ft2 ft3.xxxx", // right
							
							// combine them together
							"add ft0 ft1 ft2",
							
							
							"mov oc, ft0"
							
						].join("\n")
					);
				case STEREO_INTERLEAVED_CHECKERBOARD:
					return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
						[
							"tex ft1, v0.xy, fs1 <2d,repeat,linear>", // get left render to texture
							"tex ft2, v0.xy, fs2 <2d,repeat,linear>", // get right render to texture
							
							// test colors
//							"mov ft1, fc2",
//							"mov ft2, fc3",
							
														
							// cloumns mask
							"mul ft3.x v.x fc1.x", // v.x*(width-1)
							"div ft3.x ft3.x fc1.w", // divide by 2
							"frc ft3.x ft3.x", //get the fraction
							"sge ft3.x ft3.x fc1.z", //set if greater equal than epsilon (odd numbered line)
							"slt ft3.y ft3.x fc1.z", //set if less than threshold (even numbered line)
							
														
							// rows mask
							"mul ft4.x v.y fc1.y", // v.y*(height-1)
							"div ft4.x ft4.x fc1.w", // divide by 2
							"frc ft4.x ft4.x", //get the fraction
							"sge ft4.x ft4.x fc1.z", //set if greater equal than epsilon (odd numbered line)
							"slt ft4.y ft4.x fc1.z", //set if less than threshold (even numbered line)
							
							// add masks together
							"add ft3.xy ft3.xy ft4.xy",
							"slt ft5.y ft3.y fc4.x",
							"mul ft3.y ft5.y ft3.y", //right
							"sub ft3.x fc0.w ft3.y",// 1 - right => left
							
							
							// mask
							"mul ft1 ft1 ft3.yyyy", // left
							"mul ft2 ft2 ft3.xxxx", // right
							
							// combine views
							"add ft0 ft1 ft2",
							
							
							"mov oc, ft0"
							
						].join("\n")
					);
				case STEREO_SIDEBYSIDE:
					return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
						[
							
							"mov ft5.xy v0.xy", // copy sampling location
							"sge ft4.x v0.x fc1.z", // set if greater equal than 0.5
							// ft4.x determines in which half the current pixel is
							"sub ft4.y fc0.w ft4.x", // ft4.y is its complement
							
							// subtract 0.5 only for the right half
							"mul ft6.x fc1.z ft4.x",
							"sub ft5.x ft5.x ft6.x",
							// multiply the x coordinate by 2
							"mul ft5.x ft5.x fc1.w",

							"tex ft1, ft5.xy, fs1 <2d,clamp,linear>", // get left render to texture
							"tex ft2, ft5.xy, fs2 <2d,clamp,linear>", // get right render to texture
							
							"mul ft1 ft1 ft4.yyyy", // left
							"mul ft2 ft2 ft4.xxxx", // right
							
							
							// combine them together
							"add ft0 ft1 ft2",
							
							
							"mov oc, ft0"
							
						].join("\n")
					);
				case STEREO_TOP_BOTTOM:
					return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
						[
							
							"mov ft5.xy v0.xy", // copy sampling location
							"sge ft4.x v0.y fc1.z", // set if greater equal than 0.5
							// ft4.x determines in which half the current pixel is
							"sub ft4.y fc0.w ft4.x", // ft4.y is its complement
							
							// subtract 0.5 only for the right half
							"mul ft6.y fc1.z ft4.x",
							"sub ft5.y ft5.y ft6.y",
							// multiply the y coordinate by 2
							"mul ft5.y ft5.y fc1.w",
							
							"tex ft1, ft5.xy, fs1 <2d,clamp,linear>", // get left render to texture
							"tex ft2, ft5.xy, fs2 <2d,clamp,linear>", // get right render to texture
							
							"mul ft1 ft1 ft4.yyyy", // left
							"mul ft2 ft2 ft4.xxxx", // right
							
							
							// combine them together
							"add ft0 ft1 ft2",
							
							
							"mov oc, ft0"
							
						].join("\n")
					);
				case STEREO_LEFT_ONLY:
					return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
						[
							"tex ft1, v0.xy, fs1 <2d,repeat,linear>", // get left render to texture
							"tex ft2, v0.xy, fs2 <2d,repeat,linear>", // get right render to texture
							

							
							"mov oc, ft1"
							
						].join("\n")
					);
				case STEREO_RIGHT_ONLY:
					return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
						[
							"tex ft1, v0.xy, fs1 <2d,repeat,linear>", // get left render to texture
							"tex ft2, v0.xy, fs2 <2d,repeat,linear>", // get right render to texture
							
							"mov oc, ft2"
							
						].join("\n")
					);

			default:
				// red-cyan
				return ShaderUtils.fragmentAssambler.assemble( AGALMiniAssembler.FRAGMENT,
					[
						"tex ft1, v0.xy, fs1 <2d,repeat,linear>", // get left render to texture
						"tex ft2, v0.xy, fs2 <2d,repeat,linear>", // get right render to texture
						
						
						//					"add ft0 ft1 ft2",
						//					"mul ft0 ft0 fc0.x", // divide b 2 to average
						
						"mov ft0.x ft1.x",
						"mov ft0.yz ft2.yz",
						"mov ft0.w fc0.w",
						
						
						"mov oc, ft0"
						
					].join("\n")
				);

			}
			
		}

		
		
		public function setTextures(_context3d:Context3D):void
		{
			_context3d.setTextureAt(1, m_leftTextureDict[_context3d]);
			_context3d.setTextureAt(2, m_rightTextureDict[_context3d]);
		}
		
		public override function clearTextures(_context3D:Context3D):void
		{
			_context3D.setTextureAt(1, null);
			_context3D.setTextureAt(2, null);
		}
		
		public override function setShaderConstants(_context3D:Context3D, _viewport:Rectangle):void{
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,  Vector.<Number>([0.5, 0.5, 0.0, 1.0]));
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,  Vector.<Number>([_viewport.width, _viewport.height, .50, 2.0])); //fc1
			//_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,  Vector.<Number>([1, 0, 0, 1])); //fc2 left test color red
			//_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,  Vector.<Number>([0, 0, 1, 1])); //fc3 right test color blue
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4,  Vector.<Number>([1.5, 1.5, 1, 1])); //fc3 right test color blue
			
			
		}
	}
}