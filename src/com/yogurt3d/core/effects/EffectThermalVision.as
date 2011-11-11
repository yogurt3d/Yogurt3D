package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterThermalVision;
	import com.yogurt3d.core.materials.base.Color;

	public class EffectThermalVision extends Effect
	{
		private var m_filter:FilterThermalVision;
		
		public function EffectThermalVision(_color0:Color, _color1:Color, _color2:Color, _threshold:Number = 0.5)
		{
			super();
			addFilter( m_filter = new FilterThermalVision(_color0, _color1, _color2, _threshold) );
		}
		
		public function get color0():Color{
			return m_filter.color0;
		}
		public function set color0(_value:Color):void{
			m_filter.color0 = _value;
		}
		
		public function get threshold():Number{
			return m_filter.threshold;
		}
		public function set threshold(_value:Number):void{
			m_filter.threshold = _value;
		}
		
		public function get color1():Color{
			return m_filter.color1;
		}
		public function set color1(_value:Color):void{
			m_filter.color1 = _value;
		}
		public function get color2():Color{
			return m_filter.color2;
		}
		public function set color2(_value:Color):void{
			m_filter.color2 = _value;
		}
	}
}