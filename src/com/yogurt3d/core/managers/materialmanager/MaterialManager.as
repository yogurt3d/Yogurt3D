/*
 * MaterialManager.as
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
 
 
package com.yogurt3d.core.managers.materialmanager
{
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class MaterialManager
	{
		public static var shaderSourceDict:Dictionary = new Dictionary();
		public static var programDict:Dictionary = new Dictionary();
		public static var shaderCount:Dictionary = new Dictionary();
		
		public static function isRegistered( _key:String ):Boolean{
			return shaderSourceDict[ _key ] != null;
		}
		
		public static function registerShader( _vertexShader:ByteArray, _fragmentShader:ByteArray, _key:String ):void{
			
			if( shaderSourceDict[ _key ] == null )
				shaderSourceDict[ _key ] = {vert:_vertexShader, frag:_fragmentShader};
			
			if( shaderCount[_key] != null && !isNaN(shaderCount[_key]) )
			{
				shaderCount[_key] ++;
			}else{
				shaderCount[_key] = 1;
			}
			Y3DCONFIG::TRACE
			{
				trace("[REGISTER]", _key, "count:", shaderCount[_key] );
			}
		}
		
		public static function unregisterShader( _key:String ):void{
			
			if( shaderCount[_key] == 1 )
			{
				Y3DCONFIG::TRACE
				{
					trace("[DELETE]", _key);
				}
				delete shaderSourceDict[ _key ];
				if( programDict[_key] )
				{
					for each( var program3D:Program3D in programDict[_key] )
					{
						program3D.dispose();
					}
				}
				delete programDict[_key];
				delete shaderCount[_key];
			}else{
				shaderCount[_key] -= 1;
				Y3DCONFIG::TRACE
				{
					trace("[UNREGISTER]", _key, "count:", shaderCount[_key] );
				}
			}
			
		}
		
		public static function getProgram( _key:String, _context:Context3D ):Program3D{
			if( programDict[_key ] == null || programDict[_key][_context] == null )
			{
				if( shaderSourceDict[_key] == null ) return null;
				Y3DCONFIG::TRACE
				{
					trace("[CREATE]", _key);
				}
				var program:Program3D = _context.createProgram();
				program.upload( shaderSourceDict[ _key ].vert, shaderSourceDict[ _key ].frag);
				if( programDict[_key ] == null )
				{
					programDict[_key ] = new Dictionary();
				}
				programDict[_key ][_context] = program;
			}
			return programDict[_key][_context];
		}
		
	}
}
