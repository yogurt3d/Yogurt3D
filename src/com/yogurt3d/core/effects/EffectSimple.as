package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterColorGrading;
	import com.yogurt3d.core.effects.filters.FilterSimple;
	
	import flash.display.BitmapData;
	
	public class EffectSimple extends Effect
	{
		private var m_filter:FilterSimple;
		
		public function EffectSimple(_bitmapData:BitmapData)
		{
			super();
			addFilter( m_filter = new FilterSimple(_bitmapData) );
		}
	
	}
}