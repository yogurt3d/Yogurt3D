package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterGammaCorrection;

	public class EffectGammaCorrection extends Effect
	{
		private var m_filter:FilterGammaCorrection;
		
		public function EffectGammaCorrection(gamma:Number = 2.2)
		{
			super();
			addFilter( m_filter = new FilterGammaCorrection(gamma) );
		}
		
		public function get gamma():Number{
			return m_filter.gamma;
		}
		public function set gamma(_value:Number):void{
			m_filter.gamma = _value;
		}
	}
}