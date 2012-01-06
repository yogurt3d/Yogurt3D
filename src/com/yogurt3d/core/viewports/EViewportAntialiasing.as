package com.yogurt3d.core.viewports
{
	import com.yogurt3d.core.utils.Enum;

	public class EViewportAntialiasing extends Enum
	{
		private var m_value:uint;
		
		{initEnum(EViewportAntialiasing);}		
		
		public static const NO_ALIASING 	 :EViewportAntialiasing = new EViewportAntialiasing( 0 );
		public static const MINIMAL_ALIASING   		 :EViewportAntialiasing = new EViewportAntialiasing( 2 );
		public static const HIGH_ALIASING   		 :EViewportAntialiasing = new EViewportAntialiasing( 4 );
		public static const VERY_HIGH_ALIASING   		 :EViewportAntialiasing = new EViewportAntialiasing( 16 );
		
		public function EViewportAntialiasing(value:uint){
			m_value = value;
		}
		
		public function get value():uint
		{
			return m_value;
		}

		public static function GetConstants() :Array
		{ return Enum.GetConstants(EViewportAntialiasing); }
		
		public static function ParseConstant(i_constantName :String, i_caseSensitive :Boolean = false) :EViewportAntialiasing
		{ return EViewportAntialiasing(Enum.ParseConstant(EViewportAntialiasing, i_constantName, i_caseSensitive)); }
		
		
	}
}