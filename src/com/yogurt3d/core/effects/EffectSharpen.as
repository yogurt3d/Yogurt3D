package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterSharpen;
	
	public class EffectSharpen extends Effect
	{
		
		public function EffectSharpen(_numPass:uint=1)
		{
			super();
			addFilter( new FilterSharpen() );
			
			for(var i:uint = 0; i < _numPass-1; i++){
				addFilter( new FilterSharpen() );
			}
			
		}
		
	}
}