/*
 * AnimationEvent.as
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
package com.yogurt3d.core.events {
	import flash.events.Event;

	
	/**
	  * 
	  * 
 	  * @author Yogurt3D Engine Core Team
 	  * @company Yogurt3D Corp.
 	  **/
	public class AnimationEvent extends Event {
		
		/**
		 * Type dispatched on an end of a loop
		 */
		public static const END_OF_LOOP:String 		= "endOfLoop";
		/**
		 * Type dispatched on an end of the animation swquence
		 */
		public static const END_OF_ANIMATION:String = "endOfAnimation";
		
		/**
		 * Type dispatched on a certain frame
		 */
		public static const FRAME:String = "frame";
		
		
		public var frame:uint;
		/**
		 *  
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * 
		 */
		public function AnimationEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}
