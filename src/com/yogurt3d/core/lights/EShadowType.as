package com.yogurt3d.core.lights
{
	import com.yogurt3d.core.utils.Enum;
	
	public class EShadowType extends Enum
	{
		{initEnum(EShadowType);}	
		
		public static const NONE								:EShadowType = new EShadowType();
		
		public static const HARD								:EShadowType = new EShadowType();
		
		public static const SOFT								:EShadowType = new EShadowType();
		
		public static function GetConstants() :Array
		{ return Enum.GetConstants(EShadowType); }
		
		public static function ParseConstant(i_constantName :String, i_caseSensitive :Boolean = false) :EShadowType
		{ return EShadowType(Enum.ParseConstant(EShadowType, i_constantName, i_caseSensitive)); }
	}
}