package com.yogurt3d.core.lights
{
	import com.yogurt3d.core.utils.Enum;
	
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class ELightType extends Enum
	{
		{initEnum(ELightType);}	
		
		public static const POINT								:ELightType = new ELightType();
		
		public static const DIRECTIONAL							:ELightType = new ELightType();
		
		public static const SPOT								:ELightType = new ELightType();
		
		public static function GetConstants() :Array
		{ return Enum.GetConstants(ELightType); }
		
		public static function ParseConstant(i_constantName :String, i_caseSensitive :Boolean = false) :ELightType
		{ return ELightType(Enum.ParseConstant(ELightType, i_constantName, i_caseSensitive)); }
	}
}