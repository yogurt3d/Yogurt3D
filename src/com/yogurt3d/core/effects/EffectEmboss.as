package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterEmboss;
	
	public class EffectEmboss extends Effect
	{
		
		public function EffectEmboss(_numPass:uint=1)
		{
			super();
			addFilter( new FilterEmboss() );
			
			for(var i:uint = 0; i < _numPass-1; i++){
				addFilter( new FilterEmboss() );
			}
			
		}
		
	}
}