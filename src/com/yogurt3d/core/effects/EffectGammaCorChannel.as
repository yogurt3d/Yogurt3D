package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.FilterGammaCorChannel;

	public class EffectGammaCorChannel extends Effect
	{
		private var m_filter:FilterGammaCorChannel;
		
		public function EffectGammaCorChannel(_gammaR:Number, _gammaG:Number, _gammaB:Number)
		{
			super();
			addFilter( m_filter = new FilterGammaCorChannel(_gammaR, _gammaG, _gammaB) );
		}
		
		public function get gammaR():Number{
			return m_filter.gammaR;
		}
		
		public function get gammaG():Number{
			return m_filter.gammaG;
		}
		
		public function get gammaB():Number{
			return m_filter.gammaB;
		}
		
		public function set gammaR(_value:Number):void{
			m_filter.gammaR = _value;
		}
		
		public function set gammaG(_value:Number):void{
			m_filter.gammaG = _value;
		}
		
		public function set gammaB(_value:Number):void{
			m_filter.gammaB = _value;
		}
	}
}