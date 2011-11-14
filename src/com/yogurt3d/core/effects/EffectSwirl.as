package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterSwirl;

	public class EffectSwirl extends Effect
	{
		private var m_filter:FilterSwirl;
		public function EffectSwirl(_radius:Number=200.0, _angle:Number=0.8, _centerX:Number=400, _centerY:Number=300, _effect:Number=8.0)
		{
			super();
			
			addFilter( m_filter = new FilterSwirl(_radius, _angle, _centerX, _centerY, _effect) );
		}
		
		public function get radius():Number{
			return m_filter.radius;
		}
		
		public function set radius(_value:Number):void{
			m_filter.radius = _value;
		}
		
		public function get angle():Number{
			return m_filter.angle;
		}
		
		public function set angle(_value:Number):void{
			m_filter.angle = _value;
		}
		
		public function get centerX():Number{
			return m_filter.centerX;
		}
		
		public function set centerX(_value:Number):void{
			m_filter.centerX = _value;
		}
		
		public function get centerY():Number{
			return m_filter.centerY;
		}
		
		public function set centerY(_value:Number):void{
			m_filter.centerY = _value;
		}
		
		public function get effect():Number{
			return m_filter.effect;
		}
		
		public function set effect(_value:Number):void{
			m_filter.effect = _value;
		}
	}
}