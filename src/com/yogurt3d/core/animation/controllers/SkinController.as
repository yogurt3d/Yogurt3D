/*
* SkinController.as
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

package com.yogurt3d.core.animation.controllers
{
	import com.yogurt3d.core.animation.SkeletalAnimationData;
	import com.yogurt3d.core.events.AnimationEvent;
	import com.yogurt3d.core.geoms.Bone;
	import com.yogurt3d.core.geoms.SkeletalAnimatedMesh;
	import com.yogurt3d.core.managers.tickmanager.TickManager;
	import com.yogurt3d.core.managers.tickmanager.TimeInfo;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.interfaces.ITickedObject;
	import com.yogurt3d.core.transformations.Quaternion;
	import com.yogurt3d.core.utils.MathUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	use namespace YOGURT3D_INTERNAL;
	
	/**
	 * This Event is dispatched when a loop ends. This event is not triggered on infinite loops. 
	 */	
	[Event(name="endOfLoop", type="com.yogurt3d.core.events.AnimationEvent")]
	/**
	 * This Event is dispatched when an animation ends.
	 */
	[Event(name="endOfAnimation", type="com.yogurt3d.core.events.AnimationEvent")]
	/**
	 * This event is triggered if the player reaches a marked frame. 
	 * @example 
	 * <listing version="3.0"> 
	 * controller.addFrameEventListener( AnimationEvent.FRAME, function( _e:AnimationEvent):void{ trace( _e.frame )}, 40 );
	 * </listing> 
	 */	
	[Event(name="frame", type="com.yogurt3d.core.events.AnimationEvent")]
	
	/**
	 * Default controllor for SkeletalAnimatedMesh files<br/>
	 * This controller serves as an animation player where 
	 * you can upload animations belonging to the same bone structure as the mesh.
	 *
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 * @change 
	 * 07/11/2011 - Gurel Erceis - Added getters and setters
	 * 07/11/2011 - Gurel Erceis - Added hasAnimation function
	 * 09/21/2011 - Trevor Lanz - Bug Fix
	 **/
	public class SkinController implements IEventDispatcher, ITickedObject, IController
	{
		public static const STATE_PLAYING						:uint = 0;
		
		public static const STATE_PAUSED						:uint = 1;
		
		public static const STATE_STOPPED						:uint = 2;
		
		public static const STATE_STARTING						:uint = 3;
		
		public static const BLEND_SWITCH						:uint = 0;
		
		public static const BLEND_THEN_ANIMATE					:uint = 1;
		
		public static const BLEND_ANIMATED						:uint = 2;
		
		YOGURT3D_INTERNAL var m_startTime						:uint = 0;
		
		YOGURT3D_INTERNAL var m_startTimeOld					:uint = 0;
		
		private var i											:int = 0;
		
		private var m_internalEventDispatcher:EventDispatcher;
		
		private var m_frameRateOverride							:int = 0;
		
		YOGURT3D_INTERNAL var m_animations						:Dictionary;
		
		YOGURT3D_INTERNAL var m_currentAnimation				:String;
		
		// also refered as last played animation
		YOGURT3D_INTERNAL var m_blendingAnimation				:String; 
		
		YOGURT3D_INTERNAL var m_currentState					:uint = STATE_STOPPED;
		
		YOGURT3D_INTERNAL var m_startFrame						:uint = 0;
		
		YOGURT3D_INTERNAL var m_startFrameOld					:uint = 0;
		
		YOGURT3D_INTERNAL var m_lastFrame						:int;
		
		YOGURT3D_INTERNAL var m_mesh							:SkeletalAnimatedMesh;
		
		YOGURT3D_INTERNAL var m_loopCount						:int = 0;
		
		YOGURT3D_INTERNAL var m_blendMode						:uint;
		
		YOGURT3D_INTERNAL var m_blendDuration					:Number;
		
		YOGURT3D_INTERNAL var m_frameEventListeners				:Dictionary;
		
		public function SkinController(_mesh:SkeletalAnimatedMesh)
		{
			if( _mesh == null )
			{
				throw new Error("Mesh not bound.");
			}
			m_internalEventDispatcher = new EventDispatcher(this);
			m_animations = new Dictionary();
			m_frameEventListeners = new Dictionary();
			m_mesh = _mesh;
		}
		
		public function set frameRateOverride( _frameRate:int ):void
		{
			m_frameRateOverride = _frameRate;
		}
		
		public function shareBonesWith( _skeletalAnimatedMesh:SkeletalAnimatedMesh ):void
		{
			_skeletalAnimatedMesh.bones = m_mesh.bones;
		}
		
		public function get lastPlayedFrame():uint
		{
			return m_lastFrame;
		}
		
		public function get mesh():SkeletalAnimatedMesh
		{
			return m_mesh;
		}
		/**
		 * Returns the current animation 
		 * @return 
		 * 
		 */
		public function get currentAnimation():String
		{
			return m_currentAnimation;
		}
		
		public function dispose():void{
			TickManager.unRegisterObject(this);
			m_mesh = null;
			m_animations = null;
		}
		/**
		 * Return a boolean value indicating weather this skinController has the specified animation 
		 * @param _id ID of the animation
		 * @return boolean value indicating this skin controller has the animation with the specified id
		 * 
		 */
		public function hasAnimation( _id:String ):Boolean{
			return m_animations[ _id ] != null;
		}
		/**
		 * Adds a new animation to this skin controller. 
		 * @param _id ID of the animation
		 * @param _data SkeletalAnimationData object.
		 * @see com.yogurt3d.core.animation.SkeletalAnimationData
		 */		
		public function addAnimation( _id:String, _data:SkeletalAnimationData ):void{
			if( _data != null )
			{
				m_animations[ _id ] = _data;
			}
		}
		/**
		 * Plays a certain animation on the attached mesh file.
		 * @param _id ID of the animation loaded
		 * @param _startFrame Starting frame of the animation
		 * @param _loopCount Loop count to play. 
		 * @param blend Weather or not blending should be applied on the previously played animation SkinController.BLEND_SWITCH or SkinController.BLEND_ANIMATED
		 * @param blendDuration
		 * 
		 */
		public function playAnimation( _id:String, _startFrame:uint = 0, _loopCount:uint = 0, blendMode:uint = 0, blendDuration:Number = 0 ):void{
			m_blendingAnimation = m_currentAnimation;
			m_currentAnimation = _id;
			m_startFrameOld = m_startFrame;
			m_startFrame = _startFrame;
			m_loopCount = _loopCount;
			m_blendMode = blendMode;
			m_lastFrame = -1;
			if( m_blendingAnimation == null )
			{
				m_blendMode = BLEND_SWITCH;
			}
			m_blendDuration = blendDuration;
			m_currentState = STATE_STARTING;
			
			TickManager.registerObject(this, -1);
		}
		public function stop():void{
			m_currentState = STATE_STOPPED;
			
			TickManager.unRegisterObject(this);
		}
		public function pause():void{
			m_currentState = STATE_PAUSED;
			
			TickManager.unRegisterObject(this);
		}
		public function play():void{
			if( m_currentAnimation != "" && m_currentState != STATE_PLAYING)
			{
				if( m_currentState == STATE_PAUSED )
				{
					m_startFrame = m_lastFrame;
					m_currentState = STATE_STARTING;
				}else{
					m_startFrame = 0;
					m_currentState = STATE_STARTING;
				}
				TickManager.registerObject(this, -1);
			}
		}
		
		public function get isPlaying():Boolean{
			return m_currentState == STATE_PLAYING;
		}
		
		public function gotoAndPlay(frame:uint):void{
			if( m_currentAnimation != "" && m_currentState != STATE_PLAYING)
			{
				m_startFrame = frame;
				m_currentState = STATE_STARTING;
				
				TickManager.registerObject(this, -1);
			}
		}
		/**
		 * If you are moving your sceneObject while it is not being animated, the observers are <br/>
		 * not update. You can use this function to update them manually. 
		 * 
		 */		
		public function updateObservers():void{
			for( i = 0; i < m_mesh.bones.length;i++ )
			{	
				var bone:Bone = m_mesh.bones[i];
				
				bone.update();
			}	
		}
		/**
		 * This function is triggered before rendering. It uploads the correct bone matrices<br/>
		 * using time and currently playing animations. 
		 * @param _timeInfo
		 * 
		 */		
		public function updateWithTimeInfo(_timeInfo:TimeInfo):void{
			if( m_currentState == STATE_STARTING )
			{
				m_startTimeOld = m_startTime;
				m_startTime = _timeInfo.objectTime;
				m_currentState = STATE_PLAYING;
			}
			
			if( m_currentState == STATE_PLAYING )
			{
				var i:int;
				
				var obj:Object;
				
				// retrieve the animation data of the currently playin animation
				var animation:SkeletalAnimationData = m_animations[ m_currentAnimation ] as SkeletalAnimationData;
				if( animation == null )
				{
					m_currentState = STATE_STOPPED;
					this.dispatchEvent( new AnimationEvent( AnimationEvent.END_OF_ANIMATION ) );
					return;
				}
				// animation time
				var _time:uint = _timeInfo.objectTime - m_startTime;
				
				var animationFrameRate:int = (m_frameRateOverride != 0)? m_frameRateOverride : animation.frameRate;
				
				// current frame to display
				var currentFrame:uint  = ( Math.floor(_time * ( animationFrameRate/1000 ) ) + m_startFrame ) % animation.frameData.length;
				
				// return if pose is same with the last one, not to recalculate bone matrices
				if( currentFrame == m_lastFrame && m_blendMode != BLEND_ANIMATED ) return;				
				
				// tsl: if there is a callback registered for a given frame, call it via a dispatchEvent, but if we skipped it, backtrack to ensure every callback is hit. 
				//      missedFrameCnt should be 0/inconsequential if no frames were skipped
				for(var missedFrameCnt:int = 0; missedFrameCnt < (currentFrame - m_lastFrame); missedFrameCnt++)
				{
					Y3DCONFIG::TRACE
					{
						// tsl: replaced instances of currentFrame with (currentFrame - missedFrameCnt) throughout this loop
						if( m_frameEventListeners[ currentFrame - missedFrameCnt ] != null && (currentFrame - missedFrameCnt) != currentFrame)
						{
								trace("SkinController::updateWithTimeInfo: caught skipped frame " + (currentFrame - missedFrameCnt));
						}
					}
					
					if( m_frameEventListeners[ currentFrame - missedFrameCnt ] != null && m_frameEventListeners[currentFrame - missedFrameCnt].hasEventListener(AnimationEvent.FRAME) )
					{
						var event:AnimationEvent = new AnimationEvent( AnimationEvent.FRAME );
						event.frame = currentFrame - missedFrameCnt;
						m_frameEventListeners[ currentFrame - missedFrameCnt ].dispatchEvent( event ); 
					}
				}
				
				// tsl: moved the following code above all the actual animation code; if we're not looping and we're at the last frame (or we've looped) test the end of 
				// animation/loop scenarios. 
				// Check if animation moved to first frame
				if( currentFrame < m_lastFrame )
				{
					// decrement the loop count
					m_loopCount--;
					this.dispatchEvent( new AnimationEvent( AnimationEvent.END_OF_LOOP ) ); // tsl: this was END_OF_ANIMATION, which should only get dispatched when loopCount == 0
					
					if( m_loopCount == 0 ) 
					{
						// stop only if loopCount = 0 else loop infinite
						m_currentState = STATE_STOPPED;
						if( this.hasEventListener( AnimationEvent.END_OF_ANIMATION  ) )
						{
							this.dispatchEvent( new AnimationEvent( AnimationEvent.END_OF_ANIMATION ) ); // tsl: this was END_OF_LOOP, which should fire, but continue if loopCount != 0
						}
						return;
					}
				}
				
				// tsl: don't jump back to frame 0 if we're not dealing with a looping animation. If we're at loopCount 0, AND our last frame is the last frame of the animation, then bail.. Don't snap to the 0 frame 
				if(m_loopCount == 0 && (m_lastFrame >= (animation.frameData.length - 1)) && m_blendMode != BLEND_ANIMATED)
					return;
				
				// Data of the current frame
				var _currentFrameData:Dictionary = animation.frameData[ currentFrame ];
				var boneName:String;
				var meshBoneLength:uint = m_mesh.bones.length;
				var bone:Bone;
				if( m_blendMode == BLEND_ANIMATED )
				{
					var blendWeight:Number = _time / (m_blendDuration * 1000);
					
					if( blendWeight < 1 )
					{
						var _time2:uint = _timeInfo.objectTime - m_startTimeOld;
						
						var animation2:SkeletalAnimationData = m_animations[ m_blendingAnimation ] as SkeletalAnimationData;
						var currentFrame2:uint = ( Math.floor(_time2 * ( animation2.frameRate/1000 ) ) + m_startFrameOld ) % animation2.frameData.length;
							
						// set the bone transformations
						for( i = 0; i < meshBoneLength;i++ )
						{
							bone = m_mesh.bones[i];
							boneName = bone.name;
							
							obj = _currentFrameData[ boneName ];
							
							var obj2:Object = animation2.frameData[ currentFrame2 ][ boneName ];
							
							bone.translation 	= MathUtils.lerp( 	blendWeight,  	obj2.translation,  	obj.translation );
							bone.rotation 		= Quaternion.slerp( 	blendWeight, 	obj2.rotation, 		obj.rotation );
							bone.scale 			= MathUtils.lerp( 	blendWeight, 	obj2.scale, 		obj.scale );
						}
					}else{
						m_blendMode = BLEND_SWITCH;
					}
				}
				if( m_blendMode == BLEND_SWITCH )
				{
					// set the bone transformations
					for( i = 0; i < meshBoneLength;i++ )
					{
						bone = m_mesh.bones[i];
						boneName = bone.name;
						
						obj = _currentFrameData[ boneName ];
						
						if( !obj.matrix )
						{
							var rot:Quaternion = obj.rotation;
							bone.rotation.setTo( rot.w, rot.x, rot.y, rot.z );
							bone.scale.setTo( obj.scale.x, obj.scale.y, obj.scale.z );
							bone.translation.setTo(obj.translation.x,obj.translation.y,obj.translation.z );
							bone.invalidate();
						}
					}
					
				}
				
				// update the transformation matrices
				for( i = 0; i < meshBoneLength;i++ )
				{	
					bone = m_mesh.bones[i];
					boneName = bone.name;
					
					// if matrix is arhived
					if( _currentFrameData[ boneName ].matrix  && m_blendMode != BLEND_ANIMATED)
					{
						// restore the matrix
						bone.update( _currentFrameData[ boneName ].matrix );
					}else
					{
						// calculate the transformation matrix and archive
						if( m_blendMode != BLEND_ANIMATED )
						{
							_currentFrameData[ boneName ].matrix = bone.update().clone();
						}else{
							bone.update();
						}
					}
				}				
			}
			m_lastFrame = currentFrame;
		}
		public function addFrameEventListener(type:String, listener:Function, frame: uint):void{
			if( m_frameEventListeners[ frame ] == null )
				m_frameEventListeners[ frame ] = new EventDispatcher(this);
			
			var event:AnimationEvent;
			
			m_frameEventListeners[frame].addEventListener( type , listener );
		}
		public function removeFrameEventListener(type:String, listener:Function, frame: uint):void{
			if( m_frameEventListeners[ frame ] != null)
			{
				m_frameEventListeners[ frame ].removeEventListener( type, listener );
				if( !m_frameEventListeners[frame].hasEventListener(type) )
				{
					delete m_frameEventListeners[frame];
				}
			}
		}
		public function addEventListener( type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			m_internalEventDispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}
		public function removeEventListener( type:String, listener:Function, useCapture:Boolean=false):void
		{
			m_internalEventDispatcher.removeEventListener( type, listener, useCapture );
		}
		public function dispatchEvent( event:Event):Boolean
		{
			return m_internalEventDispatcher.dispatchEvent( event );
		}
		public function hasEventListener( type:String ):Boolean
		{
			return m_internalEventDispatcher.hasEventListener( type );
		}
		public function willTrigger( type:String ):Boolean
		{
			return m_internalEventDispatcher.willTrigger( type );
		}
	}
}
