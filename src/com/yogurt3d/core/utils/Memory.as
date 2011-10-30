/*
 * Memory.as
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
 
 
package com.yogurt3d.core.utils {

	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public final class Memory 
	{
		/**
		 * Selects a ByteArray object as the current memory.
		 * 
		 * @param byteArray The ByteArray object to work with.
		 */
		public static function select( byteArray: ByteArray ): void
		{
			ApplicationDomain.currentDomain.domainMemory = byteArray;
		}
		
		/**
		 * Writes a byte to the memory.
		 * 
		 * @param address The address in memory.
		 * @param value The value to write.
		 */
		[Inline(bytecode="0x3a")]
		public static function writeByte( value: int, address: int ): void
		{
			//__bytecode(
			//	0xd1,   //GetLocal1
			//	0xd2,   //GetLocal2
			//	0x3a,   //SetByte
			//	0x47    //ReturnVoid
			//);
			
			//
			// DCE will remove this parts since a ReturnVoid has happened
			// before.
			//
			// This applies for all the following methods.
			//
			
			ApplicationDomain.currentDomain.domainMemory.position = address;
			ApplicationDomain.currentDomain.domainMemory.writeByte( value );
		}
		
		/**
		 * Writes a short to the memory.
		 * 
		 * @param address The address in memory.
		 * @param value The value to write.
		 */
		[Inline(bytecode="0x3b")]
		public static function writeShort( value: int, address: int ): void
		{
			//__bytecode( 0xd1, 0xd2, 0x3b, 0x47 );
			
			ApplicationDomain.currentDomain.domainMemory.position = address;
			ApplicationDomain.currentDomain.domainMemory.writeShort( value );
		}
		
		/**
		 * Writes an integer to the memory.
		 * 
		 * @param address The address in memory.
		 * @param value The value to write.
		 */
		[Inline(bytecode="0x3c")]
		public static function writeInt(value: int, address: int): void
		{
			//__bytecode( 0xd1, 0xd2, 0x3c, 0x47 );
			
			ApplicationDomain.currentDomain.domainMemory.position = address;
			ApplicationDomain.currentDomain.domainMemory.writeInt( value );
		}
		
		/**
		 * Writes a float to the memory.
		 * 
		 * @param address The address in memory.
		 * @param value The value to write.
		 */
		[Inline(bytecode="0x3d")]
		public static function writeFloat(value: Number, address: int): void
		{
			//__bytecode( 0xd1, 0xd2, 0x3d, 0x47 );
			
			ApplicationDomain.currentDomain.domainMemory.position = address;
			ApplicationDomain.currentDomain.domainMemory.writeFloat( value );
		}
		
		/**
		 * Writes a double to the memory.
		 * 
		 * @param address The address in memory.
		 * @param value The value to write.
		 */
		[Inline(bytecode="0x3e")]
		public static function writeDouble(value: Number, address: int): void
		{
			//__bytecode( 0xd1, 0xd2, 0x3e, 0x47 );
			
			ApplicationDomain.currentDomain.domainMemory.position = address;
			ApplicationDomain.currentDomain.domainMemory.writeDouble( value );
		}
		
		/**
		 * Reads an unsigned byte from the memory.
		 * 
		 * @param address The address in memory.
		 * @return Unsigned byte at given address in memory.
		 */
		[Inline(bytecode="0x35")]
		public static function readUnsignedByte( address: int ): int
		{
			//__bytecode( 0xd1, 0x35, 0x48 );
			
			ApplicationDomain.currentDomain.domainMemory.position = address;
			return ApplicationDomain.currentDomain.domainMemory.readUnsignedByte();
		}
		
		/**
		 * Reads an unsigned short from the memory.
		 * 
		 * @param address The address in memory.
		 * @return Unsigned short at given address in memory.
		 */
		[Inline(bytecode="0x36")]
		public static function readUnsignedShort(address: int): int
		{
			//__bytecode(0xd1, 0x36, 0x48);
			
			ApplicationDomain.currentDomain.domainMemory.position = address;
			return ApplicationDomain.currentDomain.domainMemory.readUnsignedShort();
		}
		
		/**
		 * Reads a signed integer from the memory.
		 * 
		 * @param address The address in memory.
		 * @return Signed integer at given address in memory.
		 */
		[Inline(bytecode="0x37")]
		public static function readInt( address: int ): int
		{
			//__bytecode( 0xd1, 0x37, 0x48 );
			
			ApplicationDomain.currentDomain.domainMemory.position = address;
			return ApplicationDomain.currentDomain.domainMemory.readInt();
		}
		
		/**
		 * Reads a float from the memory.
		 * 
		 * @param address The address in memory.
		 * @return Float at given address in memory.
		 */
		[Inline(bytecode="0x38")]
		public static function readFloat( address: int ): Number
		{
			//__bytecode( 0xd1, 0x38, 0x48 );
			
			ApplicationDomain.currentDomain.domainMemory.position = address;
			return ApplicationDomain.currentDomain.domainMemory.readFloat();
		}
		
		/**
		 * Reads a double from the memory.
		 * 
		 * @param address The address in memory.
		 * @return Double at given address in memory.
		 */
		[Inline(bytecode="0x39")]
		public static function readDouble( address: int ): Number
		{
			//__bytecode( 0xd1, 0x39, 0x48 );
			
			ApplicationDomain.currentDomain.domainMemory.position = address;
			return ApplicationDomain.currentDomain.domainMemory.readDouble();
		}
		
		/**
		 * Sign-extension from 1 to 32 bits.
		 * 
		 * @param value The value to extend.
		 * @return The extended value.
		 */
		[Inline(bytecode="0x50")]
		public static function signExtend1( value: int ): int
		{
			//__bytecode( 0xd1, 0x50, 0x48 );
			
			if( 0 != ( value & 0x1 ) )
			{
				value &= 0x0;
				value -= 0x1;
			}
			
			return value;
		}
		
		/**
		 * Sign-extension from 8 to 32 bits.
		 * 
		 * @param value The value to extend.
		 * @return The extended value.
		 */
		[Inline(bytecode="0x51")]
		public static function signExtend8( value: int ): int
		{
			//__bytecode( 0xd1, 0x51, 0x48 );
			
			if( 0 != ( value & 0x80 ) )
			{
				value &= 0x7f;
				value -= 0x80;
			}
			
			return value;
		}
		
		/**
		 * Sign-extension from 16 to 32 bits.
		 * 
		 * @param value The value to extend.
		 * @return The extended value.
		 */
		[Inline(bytecode="0x52")]
		public static function signExtend16( value: int ): int
		{
			//__bytecode( 0xd1, 0x52, 0x48 );
			
			if( 0 != ( value & 0x8000 ) )
			{
				value &= 0x7fff;
				value -= 0x8000;
			}
			
			return value;
		}
		
		/**
		 * @private
		 */
		public function Memory()
		{
			throw new Error( 'Can not instantiate Memory object.' );
		}
	}
}
