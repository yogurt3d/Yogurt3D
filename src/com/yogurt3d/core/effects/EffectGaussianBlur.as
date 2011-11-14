package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterGaussianBlurHorizontal;
	import com.yogurt3d.core.effects.filters.FilterGaussianBlurVertical;

	public class EffectGaussianBlur extends Effect
	{
		public function EffectGaussianBlur()
		{
			super();
			addFilter( new FilterGaussianBlurHorizontal() );
			addFilter( new FilterGaussianBlurVertical() );
		}
	}
}