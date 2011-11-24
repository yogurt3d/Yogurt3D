package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterDilate;
	
	public class EffectDilate extends Effect
	{
		
		public function EffectDilate()
		{
			super();
			addFilter( new FilterDilate() );
		}
		
	}
}