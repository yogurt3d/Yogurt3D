package com.yogurt3d.core.texture.base
{
	import com.yogurt3d.core.utils.Enum;
	
	public class ETextureType extends Enum
	{
		{initEnum(ETextureType);}	
		
		public static const TEXTURE 	 :ETextureType = new ETextureType();
		public static const TEXTURE_CUBE :ETextureType = new ETextureType();
		public static const RTT   		 :ETextureType = new ETextureType();
		public static const RTT_CUBE   	 :ETextureType = new ETextureType();
		public static const BACK_BUFFER  :ETextureType = new ETextureType();
	}
}