package com.yogurt3d.core.particle.initializers
{
	
	import com.yogurt3d.core.materials.MaterialParticle;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.presets.primitives.meshs.Sprite3D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	
	import org.flintparticles.common.emitters.Emitter;
	import org.flintparticles.common.initializers.InitializerBase;
	import org.flintparticles.common.particles.Particle;
	import org.flintparticles.common.utils.construct;
	import org.flintparticles.threeD.particles.Particle3D;
	
	/**
	 * The ImageClass Initializer sets the DisplayObject to use to draw
	 * the particle. It is used with the DisplayObjectRenderer. When using the
	 * BitmapRenderer it is more efficient to use the SharedImage Initializer.
	 */
	
	public class Y3DImageClass extends InitializerBase
	{
		private var m_imageClass:Class;
		private var m_scaleX:Number;
		private var m_scaleY:Number;
		private var m_sprite:Sprite3D;
		private var m_texture:TextureMap;
		private var m_sceneObj:SceneObjectRenderable;
		
		/**
		 * The constructor creates an ImageClass initializer for use by 
		 * an emitter. To add an ImageClass to all particles created by an emitter, use the
		 * emitter's addInitializer method.
		 * 
		 * @param imageClass The class to use when creating
		 * the particles' DisplayObjects.
		 * @param parameters The parameters to pass to the constructor
		 * for the image class.
		 * 
		 * @see org.flintparticles.common.emitters.Emitter#addInitializer()
		 */
		
		// TODO : !!!
		public function Y3DImageClass( _imageClass:Class = null, _scaleX:Number=1.0, _scaleY:Number=1.0)
		{
			m_imageClass = _imageClass;
			m_scaleX = _scaleX;
			m_scaleY = _scaleY;
			m_sprite = new Sprite3D(m_scaleX, m_scaleY);
			m_sceneObj = new SceneObjectRenderable;
			m_sceneObj.geometry = m_sprite;
			
			var dObj:DisplayObject = construct(m_imageClass, new Array());			
			var width:uint = nearestPower(dObj.width); 
			var height:uint = nearestPower(dObj.height);
			//var height:uint = width;
			
			var matrix:Matrix = new Matrix();
		//	matrix.scale(width, height);
			matrix.tx = width/2;
			matrix.ty = height/2;
		//	trace(width, height);
			
			var bitmapData:BitmapData = new BitmapData( width, height ,true, 0x00FFFFFF);
			bitmapData.draw( dObj as IBitmapDrawable, matrix);
			
			m_texture = new TextureMap;
			m_texture.bitmapData = bitmapData;

		}
		
		private function nearestPower(i:uint):uint{
			
			var x:uint = ((i - 1) & i);
			return x ? nearestPower(x) : i << 1;
			
		}
		
		
		/**
		 * The class to use when creating
		 * the particles' DisplayObjects.
		 */
		public function get imageClass():Class
		{
			return m_imageClass;
		}
		public function set imageClass( _value:Class ):void
		{
			m_imageClass = _value;
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
			particle.image = m_sceneObj.clone();
			SceneObjectRenderable(particle.image).renderLayer = -1 * Particle3D(particle).sortID;
			
			var _r:uint = particle.color >> 16 & 0xFF;
			var _g:uint = particle.color >> 8 & 0xFF;
			var _b:uint = particle.color & 0xFF;
			var col:uint = (_r << 16 | _g << 8 | _b);
			
			SceneObjectRenderable(particle.image).material = new MaterialParticle(m_texture, col, particle.alpha);	
			
		}
	}
}