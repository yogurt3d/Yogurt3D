/*
 * CubeTextureMap.as
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

package com.yogurt3d.core.texture
{
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.texture.base.ETextureType;
	import com.yogurt3d.core.texture.base.ITexture;
	import com.yogurt3d.core.texture.base.TextureMapBase;
	import com.yogurt3d.core.utils.MipmapGenerator;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.TextureBase;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class CubeTextureMap extends TextureMapBase
	{
		use namespace YOGURT3D_INTERNAL;
		
		public static const POSITIVE_X:uint = 0;
		public static const NEGATIVE_X:uint = 1;
		public static const POSITIVE_Y:uint = 2;
		public static const NEGATIVE_Y:uint = 3;
		public static const POSITIVE_Z:uint = 4;
		public static const NEGATIVE_Z:uint = 5;
		

		YOGURT3D_INTERNAL var m_faces:Vector.<Object>;
		YOGURT3D_INTERNAL var m_byteArray:ByteArray;
		
		YOGURT3D_INTERNAL var m_compressed:Boolean = false;
		
		YOGURT3D_INTERNAL var m_dirty:Boolean = true;
		
		YOGURT3D_INTERNAL var m_mipEnabled:Boolean;
		
		private var tempBitmap:BitmapData;
		
		public function CubeTextureMap(_mipEnabled:Boolean = true)
		{
			super( ETextureType.TEXTURE_CUBE );
			
			m_faces = new Vector.<Object>(6);
			m_mipEnabled = _mipEnabled;
		}
		
		public function setFromCompressedByteArray( byte:ByteArray ):void
		{
			m_byteArray = byte;
			m_faces = new Vector.<Object>(6);
			m_compressed = true;
			
			//check weather file if really is a compressed texture
			var signature:String = byte.readUTFBytes( 3 );
			if( signature == "ATF" )
			{
				var temp:ByteArray = new ByteArray();
				byte.readBytes(temp, 1, 3 );
				temp.position = 0;
				temp.readUnsignedInt(); // skip length
				var cubeMap:uint = byte.readUnsignedByte();
				cubeMap =  cubeMap & 0x80;
				var Log2Width:uint = byte.readUnsignedByte();
				var Log2Height:uint = byte.readUnsignedByte();
				if( cubeMap == 0 )
				{
					throw new Error("File is not a CubeMap.");
				}else{
					m_width = Math.pow(2, Log2Width);
					m_height = Math.pow(2, Log2Height);
				}
			}
			
			m_dirty = true;
		}
		
		public function setFace( _faceId:uint, _texture:* ):void
		{
			m_faces[ _faceId ] = _texture;
			m_compressed = false;
			m_dirty = true;
			if( _texture is BitmapData ){
				m_width = BitmapData(_texture).width;
			}else if( _texture is Bitmap ){
				m_width = Bitmap(_texture).bitmapData.width;
			}else if( _texture is DisplayObject )
			{
				m_width = DisplayObject(_texture).width;
			}
		}
		public function getFace( _faceId:uint ):*
		{
			return m_faces[ _faceId ];			
		}

		private function uploadFromDisplayObject( texture:CubeTexture, side:uint, displayObject:DisplayObject ):void{
			if( tempBitmap == null || m_width != tempBitmap.width || m_height != tempBitmap.height)
			{
				if( tempBitmap!= null )
					tempBitmap.dispose();
				tempBitmap = new BitmapData( m_width, m_height, true, 0x00FFFFFF );
			}
			tempBitmap.draw( displayObject );
			if( !m_mipEnabled )
			{
				texture.uploadFromBitmapData( tempBitmap, side, 0 );
			}else{
				MipmapGenerator.generateMipMapsCube( tempBitmap, texture, side);
			}
			
		}
		
		/**
		 * @inheritDoc
		 * @param _context3D
		 * @return 
		 * 
		 */
		public override function getTexture3D(_context3D:Context3D):TextureBase{
			
			if( !hasTextureForContext(_context3D) || m_dirty )
			{
				var i:int;
				var texture:*;
				
				var cubetexture:CubeTexture = _context3D.createCubeTexture(m_width, Context3DTextureFormat.BGRA, false );
				
				if( m_byteArray && m_compressed )
				{
					cubetexture.uploadCompressedTextureFromByteArray(m_byteArray,0);
				}else 
				{
					for( i = 0; i < 6; i++ )
					{
						texture = m_faces[i];
						if( texture is BitmapData )
						{
							if( !m_mipEnabled )
							{
								cubetexture.uploadFromBitmapData( texture as BitmapData, i, 0 );
							}else{
								MipmapGenerator.generateMipMapsCube( texture, cubetexture, i);
							}
						}else if( texture is Bitmap )
						{
							if( !m_mipEnabled )
							{
								cubetexture.uploadFromBitmapData( texture.bitmapData as BitmapData, i, 0 );
							}else{
								MipmapGenerator.generateMipMapsCube( texture.bitmapData, cubetexture, i);
							}
						}else if( texture is DisplayObject )
						{
							uploadFromDisplayObject( cubetexture, i, texture );
						}
					}
				}
				mapTextureForContext( cubetexture, _context3D );
				m_dirty = false;
				return cubetexture;
			}else{
				for( i = 0; i < 6; i++ )
				{
					texture = m_faces[i];
					if( texture is DisplayObject && !(texture is Bitmap) )
					{
						uploadFromDisplayObject( cubetexture, i, texture );
					}
				}
			}
			return getTextureForContext( _context3D );
		}
		
		
	}
}