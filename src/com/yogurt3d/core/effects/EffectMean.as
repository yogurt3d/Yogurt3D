package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterMean;

	public class EffectMean extends Effect
	{
	
		public function EffectMean(_numPass:uint=1)
		{
			super();
			addFilter( new FilterMean() );
			
			for(var i:uint = 0; i < _numPass-1; i++){
				addFilter( new FilterMean() );
			}
	
		}
		
	}
}