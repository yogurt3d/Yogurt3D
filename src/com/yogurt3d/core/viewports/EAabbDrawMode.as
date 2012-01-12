/*
* EAabbDrawMode.as
* This file is part of Yogurt3D Flash Rendering Engine 
*
* Copyright (C) 2011 - Yogurt3D Corp.
*
* Yogurt3D Flash Rendering Engine is free software; you can redistribute it and/or
* modify it under the terms of the YOGURT3D CLICK-THROUGH AGREEMENT
* License.
* 
* Yogurt3D Flash Rendering Engine is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
* 
* You should have received a copy of the YOGURT3D CLICK-THROUGH AGREEMENT
* License along with this library. If not, see <http://www.yogurt3d.com/yogurt3d/downloads/yogurt3d-click-through-agreement.html>. 
*/

package com.yogurt3d.core.viewports
{
	import com.yogurt3d.core.utils.Enum;
	
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class EAabbDrawMode extends Enum
	{
		{initEnum(EAabbDrawMode);}	
		
		public static const NONE								:EAabbDrawMode = new EAabbDrawMode();
		
		public static const CUMULATIVE							:EAabbDrawMode = new EAabbDrawMode();
		
		public static const STRAIGHT						    :EAabbDrawMode = new EAabbDrawMode();
		
		public static const BOTH_CUM_AND_STR				    :EAabbDrawMode = new EAabbDrawMode();
		
		public static function GetConstants() :Array
		{ return Enum.GetConstants(EAabbDrawMode); }
		
		public static function ParseConstant(i_constantName :String, i_caseSensitive :Boolean = false) :EAabbDrawMode
		{ return EAabbDrawMode(Enum.ParseConstant(EAabbDrawMode, i_constantName, i_caseSensitive)); }
	}
}