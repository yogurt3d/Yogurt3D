/*
 * TextureMap.as
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
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.texture.base.ITexture;
	import com.yogurt3d.core.utils.MathUtils;
	import com.yogurt3d.core.utils.MipmapGenerator;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.natives.NativeSignal;

	use namespace YOGURT3D_INTERNAL;
	/**
	 * 
	 * 
	 * @author Yogurt3D Engine Core Team
	 * @company Yogurt3D Corp.
	 **/
	public class TextureMap extends EngineObject implements ITexture
	{
		public static const ATF_COMP:String			= "ATF_COMPRESSED";
		public static const ATF:String				= "ATF";
		public static const BITMAP:String			= "BITMAP";
		public static const DISPLAY:String			= "DISPLAY";
		public static const UNKNOWN:String 			= "UNKNOWN";
		
		
		YOGURT3D_INTERNAL var m_bitmapData		:BitmapData;
		YOGURT3D_INTERNAL var m_displayObject	:DisplayObject;
		YOGURT3D_INTERNAL var m_byteArray		:ByteArray;
		
		private var m_context3DMap				:Dictionary;
		
		YOGURT3D_INTERNAL var m_compressed		:Boolean          = false;
		YOGURT3D_INTERNAL var m_width			:uint;
		YOGURT3D_INTERNAL var m_height			:uint;
		
		YOGURT3D_INTERNAL var m_dirty			:Boolean          = true;
		YOGURT3D_INTERNAL var m_sizedirty		:Boolean          = true;

		private var m_tempBitmap				:BitmapData;
		
		private var m_animated					:Boolean 		  = false;
		
		private var m_readyToUpload				:Boolean 		  = false;
		
	    private var m_mipmap					:Boolean          = false;
		private var m_mipLevel					:uint             =	1;
		private var m_type						:String;
		private var m_transparent				:Boolean		  = false;
		
		/**
		 *  
		 * @param _bitmapData
		 * @param _displayObject
		 * @param _byte
		 * 
		 */
		public function TextureMap( _bitmapData:BitmapData = null, _displayObject:DisplayObject = null, _byte:ByteArray = null, _mipmap:Boolean = false)
		{
			m_context3DMap = new Dictionary();
			
			byteArray = _byte;
			bitmapData = _bitmapData;
			displayObject = _displayObject;
			m_mipmap = _mipmap;
			
			if(bitmapData){
				m_type = BITMAP;
				m_transparent = bitmapData.transparent;
			}else if(m_byteArray && m_compressed){
				m_type = ATF_COMP;
			}else if(m_byteArray && !m_compressed){
				m_type = ATF;
			}else if(m_displayObject){
				m_type = DISPLAY;
			}else{
				m_type = UNKNOWN
			}
		}
		
		public function get transparent():Boolean
		{
			return m_transparent;
		}

		public function set transparent(value:Boolean):void
		{
			m_transparent = value;
		}

		public function get type():String
		{
			return m_type;
		}

		public function set type(value:String):void
		{
			m_type = value;
		}

		public function get mipLevel():uint
		{
			return m_mipLevel;
		}

		public function set mipLevel(value:uint):void
		{
			m_mipLevel = value;
		}

		public function get mipmap():Boolean
		{
			return m_mipmap;
		}

		public function set mipmap(value:Boolean):void
		{
			m_mipmap = value;
			m_dirty = true;
		}

		/**
		 * This flag is used to make the texture be updated on every frame if is it a displayobject texture. 
		 * @return 
		 * 
		 */
		public function get animated():Boolean
		{
			return m_animated;
		}

		/**
		 * @private 
		 * @param value
		 * 
		 */
		public function set animated(value:Boolean):void
		{
			m_animated = value;
			
			if(m_displayObject && m_animated){
				m_type = DISPLAY;
			}
		}

		/**
		 * The bytearray texture 
		 * @return the bytearray texture if set
		 * 
		 */
		public function get byteArray():ByteArray
		{
			return m_byteArray;
		}
		/**
		 * @private 
		 * @param byte
		 * 
		 */
		public function set byteArray(byte:ByteArray):void
		{
			if( byte )
			{
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
					var count:uint = byte.readUnsignedByte();
					//trace("TextureMap: "+count);
					m_mipLevel = count;
					m_byteArray = temp;
					if(m_mipLevel > 1)
						m_mipmap = true;
					if( cubeMap == 0x80 )
					{
						throw new Error("File is a CubeMap.");
					}else{
						if( m_width != Math.pow(2, Log2Width) )
						{
							m_sizedirty = true;
						}
						if( m_height != Math.pow(2, Log2Height) )
						{
							m_sizedirty = true;
						}
						m_width = Math.pow(2, Log2Width);
						m_height = Math.pow(2, Log2Height);
						
					}
					m_readyToUpload = true;
				}else{
					var loader:Loader = new Loader();
					new NativeSignal( loader.contentLoaderInfo, Event.INIT, Event).addOnce( onDisplayObjectLoaded );
					loader.loadBytes( byte );
				}
				
				m_byteArray = byte;
				m_bitmapData = null;
				m_displayObject = null;
				m_dirty = true;
				m_transparent = false;
				type = ATF;
			}
		}
		private final function onDisplayObjectLoaded( _e:Event ):void{
			displayObject = LoaderInfo(_e.target).content;
		}

		/**
		 * The displayobject texture 
		 * @return the displayobject texture if set
		 * 
		 */
		public function get displayObject():DisplayObject
		{
			return m_displayObject;
		}

		/**
		 * @private 
		 * @param value
		 * 
		 */
		public function set displayObject(value:DisplayObject):void
		{
			if( value )
			{
				m_displayObject = value;
				if( m_width != value.width )
				{
					m_sizedirty = true;
				}else if( m_height != value.height )
				{
					m_sizedirty = true;
				}
				m_width = value.width;
				m_height = value.height;
				m_bitmapData = null;
				m_byteArray = null;
				m_dirty = true;
				m_readyToUpload = true;
				m_transparent = false;
				type = DISPLAY;
			}
		}

		/**
		 * The bitmapdata texture 
		 * @return the bitmapdata texture if set
		 * 
		 *//**
		 * The bitmapdata texture 
		 * @return the bitmapdata texture if set
		 * 
		 */
		public function get bitmapData():BitmapData
		{
			return m_bitmapData;
		}

		/**
		 * @private 
		 * @param value
		 * 
		 */
		public function set bitmapData(value:BitmapData):void
		{
			if( value )
			{
				m_bitmapData = value;
				if( m_width != value.width )
				{
					m_sizedirty = true;
				}
				if( m_height != value.height )
				{
					m_sizedirty = true;
				}
				m_width = value.width;
				m_height = value.height;
				m_byteArray = null;
				m_displayObject = null;
				m_readyToUpload = true;
				m_dirty = true;
				m_transparent = value.transparent;
				type = BITMAP;
			}
		}
		

		/**
		 * @private
		 * Uploads a displayobject as the current texture 
		 * @param _texture
		 * 
		 */
		private function uploadFromDisplayObject( _texture:Texture ):void{
			// check weather the tempBitmap is in the same size as the display object
			if( m_tempBitmap == null || m_width != m_tempBitmap.width || m_height != m_tempBitmap.height)
			{
				if( m_tempBitmap!= null )
					m_tempBitmap.dispose();
				m_tempBitmap = new BitmapData( m_width, m_height, true, 0x00FFFFFF );
			}
			// draw the displayObject onto a bitmapData
			//if( transparent )
			{
				m_tempBitmap.fillRect( m_tempBitmap.rect, 0x00FFFFFF );
			}
			m_tempBitmap.draw( m_displayObject, m_displayObject.transform.matrix, null,null,m_tempBitmap.rect, false );	
			
			if( !m_mipmap )
			{
				_texture.uploadFromBitmapData( m_tempBitmap, 0 );
				
			}else{
				MipmapGenerator.generateMipMaps( m_tempBitmap, _texture, null, true );
			}
			
		}
		
		
		/**
		 * @inheritDoc 
		 * @param _context3D
		 * @return 
		 * 
		 */
		public function getTexture3D(_context3D:Context3D):TextureBase{
			if( m_readyToUpload == false )
			{
				return null;
			}
			// check weather texture is uploaded to the GPU of texture has changes
			if( m_context3DMap[ _context3D ] == null || m_dirty )
			{
				m_width = MathUtils.getClosestPowerOfTwo( m_width );
				m_height = MathUtils.getClosestPowerOfTwo( m_height );
				var _texture:Texture;
				if( m_context3DMap[ _context3D ] == null || m_sizedirty )
				{
					// If texture has changed dispose old.
					if( m_context3DMap[ _context3D ] != null )
					{
						TextureBase(m_context3DMap[ _context3D ]).dispose();
						m_context3DMap[ _context3D ] = null;
					}
					// create a new texture
					_texture = _context3D.createTexture(m_width, m_height, ( m_byteArray && m_compressed)?Context3DTextureFormat.COMPRESSED: Context3DTextureFormat.BGRA, false );
					m_sizedirty = false;
				}else{
					_texture = m_context3DMap[ _context3D ];
				}
				// According to the texture type upload if to the GPU
				if( m_byteArray && m_compressed )
				{
					//trace("byte + compressed load");
				
					_texture.uploadCompressedTextureFromByteArray(m_byteArray,0);
			
					
				}else if( m_byteArray && !m_compressed )
				{
					//trace("byte + NON compressed load");
				
					_texture.uploadFromByteArray( m_byteArray, 0, m_mipLevel );
					
				}else if( m_bitmapData )
				{
				
					if( !m_mipmap )
					{
						_texture.uploadFromBitmapData( m_bitmapData, 0 );
					
					}else{
						MipmapGenerator.generateMipMaps( m_bitmapData, _texture, null, true );
					}
					
				}else if( m_displayObject ){
					uploadFromDisplayObject( _texture );
				}
				// cache the texture object
				m_context3DMap[ _context3D ] = _texture;
				// set dirty to false
				m_dirty = false;
			}else{
				// if texture is a display object and it is animated
				if( m_displayObject && m_animated )
				{
					// upload the current frame
					uploadFromDisplayObject( m_context3DMap[ _context3D ] as Texture );
				}
			}
			return m_context3DMap[ _context3D ] as Texture;
		}
		
		override public function disposeDeep():void{
			dispose();
		}
		
		override public function dispose():void{
			disposeGPU();
			
			if( m_displayObject )
			{
				m_displayObject = null;
			}
			if( m_byteArray )
			{
				m_byteArray = null;
			}
			if( m_bitmapData )
			{
				m_bitmapData.dispose();
				m_bitmapData = null;
			}
			
			super.dispose();
		}
		
		public override function disposeGPU():void{
			for each( var _texture:TextureBase in m_context3DMap )
			{
				_texture.dispose();
			}
			m_context3DMap = new Dictionary();;
		}
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, TextureMap);
		}
		
	}
}