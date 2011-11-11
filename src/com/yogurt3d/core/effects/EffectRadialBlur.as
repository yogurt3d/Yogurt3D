package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.Filter;
	import com.yogurt3d.core.effects.filters.FilterRadialBlur;

	public class EffectRadialBlur extends Effect
	{
		private var m_filter:FilterRadialBlur;
		
		public function EffectRadialBlur()
		{
			super();
			addFilter( m_filter = new FilterRadialBlur() );
		}
	}
}