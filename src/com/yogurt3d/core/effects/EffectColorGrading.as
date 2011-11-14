package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterColorGrading;
	
	import flash.display.BitmapData;

	public class EffectColorGrading extends Effect
	{
		private var m_filter:FilterColorGrading;
		
		public function EffectColorGrading(_gradientBitmap:BitmapData)
		{
			super();
			addFilter( m_filter = new FilterColorGrading( _gradientBitmap ) );
		}

		public function get gradientBitmap():BitmapData
		{
			return m_filter.gradientBitmap;
		}

		public function set gradientBitmapData(value:BitmapData):void
		{
			m_filter.gradientBitmap = value;
		}

	}
}