package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterLaplacian;
	
	public class EffectLaplacian extends Effect
	{
		
		public function EffectLaplacian()
		{
			super();
			addFilter( new FilterLaplacian() );
		}
		
	}
}