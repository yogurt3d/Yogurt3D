package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterPixelation;

	public class EffectPixelation extends Effect
	{
		private var m_filter:FilterPixelation;
		public function EffectPixelation(_pixelWidth:Number=15.0, _pixelHeight:Number=10.0)
		{
			super();
			addFilter( m_filter = new FilterPixelation(_pixelWidth, _pixelHeight) );
		}
		public function get pixelWidth():Number{
			return m_filter.pixelWidth;
		}
		
		public function get pixelHeight():Number{
			return m_filter.pixelHeight;
		}
		
		public function set pixelWidth(_value:Number):void{
			m_filter.pixelWidth = _value;
		}
		
		public function set pixelHeight(_value:Number):void{
			m_filter.pixelHeight = _value;
		}
	}
	
}