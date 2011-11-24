package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterSephia;

	public class EffectSephia  extends Effect
	{
		public function EffectSephia()
		{
			super();
			addFilter( new FilterSephia() );
		}
	}
}