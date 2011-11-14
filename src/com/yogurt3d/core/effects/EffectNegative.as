package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterNegative;

	public class EffectNegative extends Effect
	{
		private var m_filter:FilterNegative;
		
		public function EffectNegative(_xMin:Number=0.2, _xMax:Number = 0.8, _yMin:Number=0.2, _yMax:Number=0.8)
		{
			super();
			addFilter( new FilterNegative(_xMin, _xMax, _yMin, _yMax) );
		}
		
		public function get xMin():Number{
			return m_filter.xMin;
		}
		public function get xMax():Number{
			return m_filter.xMax;
		}
		public function get yMin():Number{
			return m_filter.yMin;
		}
		public function get yMax():Number{
			return m_filter.yMax;
		}
		
		public function set xMin(_value:Number):void{
			m_filter.xMin = _value;
		}
		public function set xMax(_value:Number):void{
			m_filter.xMax = _value;
		}
		public function set yMin(_value:Number):void{
			m_filter.yMin = _value;
		}
		public function set yMax(_value:Number):void{
			m_filter.yMax = _value;
		}
	}
}