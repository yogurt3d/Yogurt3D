package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterLensCircle;

	public class EffectLensCircle extends Effect
	{
		private var m_filter:FilterLensCircle;
		
		public function EffectLensCircle(_lensX:Number=0.45, _lensY:Number=0.38, _centerX:Number=0.5, _centerY:Number=0.5)
		{
			super();
			addFilter( m_filter = new FilterLensCircle(_lensX, _lensY, _centerX, _centerY) );
		}
		
		public function get lensX():Number{
			return m_filter.lensX;
		}
		
		public function get lensY():Number{
			return m_filter.lensY;
		}
		
		public function get centerX():Number{
			return m_filter.centerX;
		}
		
		public function set centerY(_value:Number):void{
			m_filter.centerY = _value;
		}
		
		public function set lensX(_value:Number):void{
			m_filter.lensX = _value;
		}
		
		public function set lensY(_value:Number):void{
			m_filter.lensY = _value;
		}
	}
}