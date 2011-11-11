package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterPosterization;

	public class EffectPosterization extends Effect
	{
		private var m_filter:FilterPosterization;
		
		public function EffectPosterization(_gamma:Number=0.6, _numColors:Number=8.0)
		{
			super();
			addFilter( m_filter = new FilterPosterization(_gamma, _numColors) );
		}
		public function get gamma():Number{
			return m_filter.gamma;
		}
		public function set gamma(_value:Number):void{
			m_filter.gamma = _value;
		}
		
		public function get numColors():Number{
			return m_filter.numColors;
		}
		public function set numColors(_value:Number):void{
			m_filter.numColors = _value;
		}
	}
}