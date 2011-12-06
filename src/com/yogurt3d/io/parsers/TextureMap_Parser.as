/*
 * TextureMap_Parser.as
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

package com.yogurt3d.io.parsers
{
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.io.parsers.interfaces.IParser;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class TextureMap_Parser implements IParser
	{
		private var m_mipmap:Boolean = false;
		public function TextureMap_Parser(_mipmap:Boolean=false)
		{
			m_mipmap = _mipmap;
		}
		
		public function get mipmap():Boolean
		{
			return m_mipmap;
		}

		public function set mipmap(value:Boolean):void
		{
			m_mipmap = value;
		}

		public function parse(_value:*, split:Boolean=true):*
		{
			var texture:TextureMap;
			
			if( _value is ByteArray )
			{
				var byte:ByteArray = _value as ByteArray;
				byte.endian = Endian.LITTLE_ENDIAN;
				byte.position = 0;
				var signature:String = byte.readUTFBytes( 3 );
				if( signature == "ATF" )
				{
					var temp:ByteArray = new ByteArray();
					byte.readBytes(temp, 1, 3 );
					temp.position = 0;
					var len:uint = temp.readUnsignedInt();
					var cubeMap:uint = byte.readUnsignedByte();
					var format:uint = cubeMap & 0x7F;
					cubeMap = 0x80 & cubeMap;
					var Log2Width:uint = byte.readUnsignedByte();
					var Log2Height:uint = byte.readUnsignedByte();
					var mipLevel:uint = byte.readUnsignedByte();
			
					if( cubeMap == 0 )
					{
						texture = new TextureMap();
						texture.YOGURT3D_INTERNAL::m_compressed = true;
						texture.YOGURT3D_INTERNAL::m_width = Math.pow(2, Log2Width);
						texture.YOGURT3D_INTERNAL::m_height = Math.pow(2, Log2Height);
						byte.position = 0;
						texture.byteArray = byte;
						texture.mipLevel = mipLevel;
						if(texture.mipLevel > 1){
							texture.mipmap = true;
							m_mipmap = true;
						}else{
							texture.mipmap = false;
							m_mipmap = false;
						}
							
						return texture;
					}else{
						// TODO
						var cubetexture:CubeTextureMap = new CubeTextureMap();
						cubetexture.YOGURT3D_INTERNAL::m_compressed = true;
						cubetexture.YOGURT3D_INTERNAL::m_width = Math.pow(2, Log2Width);
						cubetexture.YOGURT3D_INTERNAL::m_height = Math.pow(2, Log2Height);
						byte.position = 0;
						//texture.m_mipLevel = Count;
						cubetexture.setFromCompressedByteArray( byte );
						
//						if(texture.m_mipLevel > 1)
//							texture.mipmap = true;
						return cubetexture;
					}
				}else{
					return new TextureMap(null,null,byte)
				}
			}else if( _value is Bitmap ){
				texture = new TextureMap();
				texture.YOGURT3D_INTERNAL::m_compressed = false;
				texture.bitmapData = _value.bitmapData;
				texture.mipmap = m_mipmap;
				return texture;
			}else if( _value is BitmapData ){
				texture = new TextureMap();
				texture.YOGURT3D_INTERNAL::m_compressed = false;
				texture.bitmapData = _value as BitmapData;
				texture.mipmap = m_mipmap;
				return texture;
			}else if( _value is DisplayObject ){
				texture = new TextureMap();
				texture.YOGURT3D_INTERNAL::m_compressed = false;
				texture.displayObject = _value;
				texture.mipmap = m_mipmap;
				return texture;
			}
		}
	}
}