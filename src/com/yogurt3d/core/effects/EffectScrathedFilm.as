package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterScratchedFilm;
	
	import flash.display.BitmapData;

	public class EffectScrathedFilm extends Effect
	{
		private var m_filter:FilterScratchedFilm;
		
		public function EffectScrathedFilm(_noiseBitmap:BitmapData)
		{
			super();
			addFilter( m_filter = new FilterScratchedFilm(_noiseBitmap));
		}
		
		public function get IS():Number
		{
			return m_filter.IS;
		}
		
		public function set IS(value:Number):void
		{
			m_filter.IS = value;
		}
		
		public function get scratchIntensity():Number
		{
			return m_filter.scratchIntensity;
		}
		
		public function set scratchIntensity(value:Number):void
		{
			m_filter.scratchIntensity = value;
		}
		
		public function get speed2():Number
		{
			return m_filter.speed2;
		}
		
		public function set speed2(value:Number):void
		{
			m_filter.speed2 = value;
		}
		
		public function get speed1():Number
		{
			return m_filter.speed1;
		}
		
		public function set speed1(value:Number):void
		{
			m_filter.speed1 = value;
		}
		
		public function get timer():Number
		{
			return m_filter.timer;
		}
		
		public function set timer(value:Number):void
		{
			m_filter.timer = value;
		}
	}
}