package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterNegative;
	import com.yogurt3d.core.effects.filters.FilterNightVision;
	
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;

	public class EffectNightVision extends Effect
	{
		private var m_filter:FilterNightVision;
		
		public function EffectNightVision(_noiseBitmap:BitmapData, 
										  _maskBitmap:BitmapData, 
										  _noiseRandomize:Number, 
										  _luminanceThreshold:Number=0.2,
										  _colorAmplifaction:Number=4.0,
										  _effectCoverage:Number=1 )
		{
			super();
			addFilter( m_filter = new FilterNightVision(_noiseBitmap, 
				_maskBitmap, 
				_noiseRandomize, 
				_luminanceThreshold,
				_colorAmplifaction,
				_effectCoverage ) );
		}
		
		public function get effectCoverage():Number
		{
			return m_filter.effectCoverage;
		}
		
		public function set effectCoverage(value:Number):void
		{
			m_filter.effectCoverage = value;
		}
		
		public function get colorAmplifaction():Number
		{
			return m_filter.colorAmplifaction;
		}
		
		public function set colorAmplifaction(value:Number):void
		{
			m_filter.colorAmplifaction = value;
		}
		
		public function get luminanceThreshold():Number
		{
			return m_filter.luminanceThreshold;
		}
		
		public function set luminanceThreshold(value:Number):void
		{
			m_filter.luminanceThreshold = value;
		}
		
		public function get noiseRandomize():Number
		{
			return m_filter.noiseRandomize;
		}
		
		public function set noiseRandomize(value:Number):void
		{
			m_filter.noiseRandomize = value;
		}
		
		public function get maskTex():Texture
		{
			return m_filter.maskTex;
		}
		
		public function set maskTex(value:Texture):void
		{
			m_filter.maskTex = value;
		}
		
		public function get noiseTex():Texture
		{
			return m_filter.noiseTex;
		}
		
		public function set noiseTex(value:Texture):void
		{
			m_filter.noiseTex = value;
		}
	}
}