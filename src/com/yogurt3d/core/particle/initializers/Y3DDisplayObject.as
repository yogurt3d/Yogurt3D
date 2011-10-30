/*
* FLINT PARTICLE SYSTEM
* .....................
* 
* Author: Richard Lord & Michael Ivanov
* Copyright (c) Richard Lord 2008-2011
* http://flintparticles.org
* 
* 
* Licence Agreement
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

package com.yogurt3d.core.particle.initializers
{	
	import com.yogurt3d.core.geoms.Mesh;
	import com.yogurt3d.core.materials.MaterialParticle;
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.presets.primitives.meshs.Sprite3D;
	
	import org.flintparticles.common.emitters.Emitter;
	import org.flintparticles.common.initializers.InitializerBase;
	import org.flintparticles.common.particles.Particle;
	import org.flintparticles.common.utils.WeightedArray;
	import org.flintparticles.threeD.particles.Particle3D;
	
	/**
	 * The ImageClass Initializer sets the DisplayObject to use to draw
	 * the particle. It is used with the DisplayObjectRenderer. When using the
	 * BitmapRenderer it is more efficient to use the SharedImage Initializer.
	 */
	
	public class Y3DDisplayObject extends InitializerBase
	{
		private var m_images:WeightedArray;
		private var m_scaleX:Number;
		private var m_scaleY:Number;
		private var m_sprite:Sprite3D;
		private var m_sceneObj:SceneObjectRenderable;
	
		public function Y3DDisplayObject( images:Array, _scaleX:Number=1.0, _scaleY:Number=1.0, weights:Array = null )
		{
			m_images = new WeightedArray;
			m_scaleX = _scaleX;
			m_scaleY = _scaleY;
			m_sprite = new Sprite3D(m_scaleX, m_scaleY);
			m_sceneObj = new SceneObjectRenderable;
			m_sceneObj.geometry = m_sprite;
						
			var len:int = images.length;
			var i:int;
			
			if( weights != null && weights.length == len ){
				for( i = 0; i < len; ++i )
					addImage( images[i], weights[i] );
			}
			else{
				for( i = 0; i < len; ++i )
					addImage( images[i], 1 );
			}
		}
		
		public function addImage( image:*, weight:Number = 1 ):void
		{
			if( image is Array )
			{
				var parameters:Array = ( image as Array ).concat();
				var img:TextureMap = parameters.shift();
				m_images.add( new Pair( img, parameters ), weight );
			}
			else
			{
				m_images.add( new Pair( image, [] ), weight );
			}
		}
		
		public function removeImage( image:* ):void
		{
			m_images.remove( image );
		}
		
		public function get scaleX():Number
		{
			return m_scaleX;
		}
		public function set scaleX( _value:Number ):void
		{
			m_scaleX = _value;
		}
		public function get scaleY():Number
		{
			return m_scaleY;
		}
		public function set scaleY( _value:Number ):void
		{
			m_scaleY = _value;
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override public function initialize( emitter:Emitter, particle:Particle ):void
		{
			var img:Pair = m_images.getRandomValue();
			particle.image = m_sceneObj.clone();
			
			var obj:SceneObjectRenderable = particle.image;
			obj.renderLayer = -1 * Particle3D(particle).sortID;
			
			var _r:uint = particle.color >> 16 & 0xFF;
			var _g:uint = particle.color >> 8 & 0xFF;
			var _b:uint = particle.color & 0xFF;
			var col:uint = (_r << 16 | _g << 8 | _b);

			obj.material = new MaterialParticle(img.image, col ,particle.alpha);	
//				m_material.clone() as MaterialParticle;
//			m_material.texture = img.image;
//			m_material.color = col;
//			m_material.opacity = particle.alpha;
			
				
				//new MaterialParticle(img.image, col ,particle.alpha);	

		}
	}
}
import com.yogurt3d.core.texture.TextureMap;

class Pair
{
	internal var image:TextureMap;
	internal var parameters:Array;
	
	public function Pair( image:TextureMap, parameters:Array )
	{
		this.image = image;
		this.parameters = parameters;
	}
}