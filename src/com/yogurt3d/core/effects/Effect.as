package com.yogurt3d.core.effects
{
	import com.yogurt3d.core.effects.filters.Filter;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;

	public class Effect
	{
		use namespace YOGURT3D_INTERNAL;
		
		YOGURT3D_INTERNAL var m_filters:Vector.<Filter>;
		
		public function Effect()
		{
			m_filters = new Vector.<Filter>();
		}
		
		YOGURT3D_INTERNAL function get filters():Vector.<Filter>
		{
			return YOGURT3D_INTERNAL::m_filters;
		}

		public function addFilter( filter:Filter ):void{
			m_filters.push( filter );
		}
		
		public function removeFilter( filter:Filter ):void{
			m_filters.splice( m_filters.indexOf( filter ), 1 );
		}
	}
}