package com.yogurt3d.core.particle.initializers
{	
	import com.yogurt3d.core.materials.MaterialParticle;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.presets.primitives.meshs.Sprite3D;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import org.flintparticles.common.displayObjects.Dot;
	import org.flintparticles.common.displayObjects.Ellipse;
	import org.flintparticles.common.displayObjects.Line;
	import org.flintparticles.common.displayObjects.RadialDot;
	import org.flintparticles.common.displayObjects.Rect;
	import org.flintparticles.common.displayObjects.Ring;
	import org.flintparticles.common.displayObjects.Star;
	import org.flintparticles.common.emitters.Emitter;
	import org.flintparticles.common.initializers.InitializerBase;
	import org.flintparticles.common.particles.Particle;
	import org.flintparticles.threeD.particles.Particle3D;
	
	
	/**
	 * The ImageClass Initializer sets the DisplayObject to use to draw
	 * the particle. It is used with the DisplayObjectRenderer. When using the
	 * BitmapRenderer it is more efficient to use the SharedImage Initializer.
	 */
	
	public class Y3DShapeObject extends InitializerBase
	{
		private var m_shape:Shape;
		private var m_scaleX:Number;
		private var m_scaleY:Number;
		private var width:Number, height:Number;
		private var tx:Number, ty:Number;
		private var m_texture:TextureMap;
		private var m_sprite:Sprite3D;
		private var m_sceneObj:SceneObjectRenderable;
		
		public function Y3DShapeObject( _shape:Shape, _scaleX:Number=1.0, _scaleY:Number=1.0, _filters:Vector.<BitmapFilter> = null)
		{
			var maxVal:Number;
			
			m_shape = _shape;
			m_scaleX = _scaleX;
			m_scaleY = _scaleY;
			m_sprite = new Sprite3D(m_scaleX, m_scaleY);
			
			m_sceneObj = new SceneObjectRenderable;
			m_sceneObj.geometry = m_sprite;
			
			width = 128;
			if(m_shape is RadialDot && RadialDot(m_shape).radius*2 > width){
				width = nearestPower(uint(RadialDot(m_shape).radius) * 2);
			}else if(m_shape is Line && Line(m_shape).length > width * 2){
				width = nearestPower(uint(Line(m_shape).length) * 2);
			}else if(m_shape is Dot && Dot(m_shape).radius * 2 > width){
				width = nearestPower(uint(Dot(m_shape).radius) * 2);
			}else if(m_shape is Ellipse && (Ellipse(m_shape).width * 2 > width ||
				Ellipse(m_shape).height * 2 > height)){
				maxVal = Math.max(Ellipse(m_shape).width, Ellipse(m_shape).height);
				width = nearestPower(uint(maxVal) * 2);
			}else if(m_shape is Star && Star(m_shape).radius*2 > width){
				width = nearestPower(uint(Star(m_shape).radius) * 2);
			}else if(m_shape is Ring && Ring(m_shape).outerRadius * 2 > width){
				width = nearestPower(uint(Ring(m_shape).outerRadius) * 2);
			}else if(m_shape is Rect && (Rect(m_shape).width * 2 > width ||
				Rect(m_shape).height * 2 > height)){
				maxVal = Math.max(Rect(m_shape).width, Rect(m_shape).height);
				width = nearestPower(uint(maxVal) * 2);
			}
			
			height = width;
			tx = width/2;
			ty = height/2;
			
			var bitmap:BitmapData = new BitmapData(width, height, true, 0x00FFFFFF);
			var matrix:Matrix = new Matrix();
			matrix.tx = tx;
			matrix.ty = ty;
			
			bitmap.draw(m_shape, matrix);
			
			if(_filters != null){
				for(var i:uint = 0; i < _filters.length; i++){
					bitmap.applyFilter(bitmap, bitmap.rect, new Point(), _filters[i]);
				}
			}
			m_texture = new TextureMap;
			m_texture.bitmapData = bitmap;

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
		private function powerOfTwo(_width:Number, _height:Number):Boolean{
		
			var wTest:Boolean =  (_width & -_width) == _width;
			var hTest:Boolean =  (_height & -_height) == _height;
			
			return wTest && hTest;
		}
		private function nearestPower(i:uint):uint{
						
			var x:uint = ((i - 1) & i);
			return x ? nearestPower(x) : i << 1;
		
		}
		
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
