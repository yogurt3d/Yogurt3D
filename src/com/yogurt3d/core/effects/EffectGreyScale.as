package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterGreyScale;

	public class EffectGreyScale extends Effect
	{
		public function EffectGreyScale()
		{
			super();
			addFilter( new FilterGreyScale() );
		}
	}
}