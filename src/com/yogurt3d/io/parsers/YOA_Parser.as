/*
 * YOA_Parser.as
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
	import com.yogurt3d.core.animation.SkeletalAnimationData;
	import com.yogurt3d.core.transformations.Quaternion;
	import com.yogurt3d.io.parsers.interfaces.IParser;
	
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class YOA_Parser implements IParser
	{
		public function YOA_Parser()
		{
		}

		/**
		 * Public interface method to parse any YOA binary. Return the according animation data object.
		 * @param _value ByteArray containing the YOA binary file.
		 * @param verbose File header info is printed when this is set to true.
		 * @return SkeletalAnimationGPUData object having the animation data.
		 */	
		public function parse(_data:*, balabala:Boolean = true):*
		{
			if(_data is ByteArray)
			{
				ByteArray(_data).endian		= Endian.LITTLE_ENDIAN;
				ByteArray(_data).position = 0;
				try{
					ByteArray(_data).inflate();
				}catch(_e:*)
				{
					
				}
				var short:int = ByteArray(_data).readShort();
				ByteArray(_data).position = 0;
				if( short != 8 )
				{
					return parseByteArrayOld(_data );
				}else{
					return parseByteArray( _data );
				}
				
			}
		}
		
		/**
		 * Parses any YOA binary and returns the according animation data object.
		 * @param _value ByteArray containing the YOA binary file.
		 * @param verbose File header info is printed when this is set to true.
		 * 
		 */	
		private function parseByteArray(_value:ByteArray):*
		{
			var _exportType:String = _value.readMultiByte( _value.readShort() * 2,"utf-16");
			var _version:int        = _value.readShort();
			var _type:int        	= _value.readShort();
			
			var _exporter:String	   = _value.readMultiByte( _value.readShort() * 2,"utf-16");
			
			var _boneCount:int	   = _value.readShort();
			var _frameCount:int	   = _value.readShort();
			var _frameRate:int	   = _value.readShort();
			
			Y3DCONFIG::TRACE
			{
				trace("[YOA_Parser] Yogurt3D Animation File");
				trace("[YOA_Parser] Version:", _version);
				trace("[YOA_Parser] Exporter:", _exporter);
				trace("[YOA_Parser] boneCount:", _boneCount);
				trace("[YOA_Parser] frameCount:", _frameCount);
			}
			
			var _animData:SkeletalAnimationData = new SkeletalAnimationData();
			
			var _boneList:Array = [];
			
			for( var i:int = 0; i < _boneCount; i++)
			{
				var nameLength:int = _value.readShort() ;
				_boneList.push( _value.readMultiByte( nameLength * 2, "utf-16" ) );
			}
			
			for( i = 0; i < _frameCount; i++ )
			{
				for( var j:int = 0; j < _boneCount; j++ )
				{
					_animData.addBoneData( i, _boneList[j], 
						new Vector3D(_value.readFloat(),_value.readFloat(),_value.readFloat()),
						new Quaternion(_value.readFloat(),_value.readFloat(),_value.readFloat(),_value.readFloat()),
						new Vector3D(_value.readFloat(),_value.readFloat(),_value.readFloat()) 
					);
					
				}
			}
			_animData.frameRate = _frameRate;
			return _animData;
		}

		/**
		 * Parses any Y3D v1 binary and returns the animation data object.
		 * @param _value ByteArray containing the Y3D binary file.
		 * @param verbose File header info is printed when this is set to true.
		 * 
		 */	
		private function parseByteArrayOld(_value:ByteArray):*
		{
			_value.position		= 0;
			_value.endian		= Endian.LITTLE_ENDIAN;
			
			var _animData:SkeletalAnimationData 					= new SkeletalAnimationData(); // v2 gpu data object
			
			var _boneCount				:int	= _value.readInt();
			var _frameCount				:int	= _value.readInt();
			
			var _boneList:Array = [];
			
			Y3DCONFIG::TRACE
			{
				trace("[YOA_Parser] Yogurt3D Animation File");
				trace("[YOA_Parser] Version:", 1);
				trace("[YOA_Parser] Exporter:", null);
				trace("[YOA_Parser] boneCount:", _boneCount);
				trace("[YOA_Parser] frameCount:", _frameCount);
			}
			
			for(var _boneLoop:int = 0; _boneLoop < _boneCount; _boneLoop++)
			{
				var _boneNameLength	:int		= _value.readInt();
				var _boneName		:String		= "";
				
				for(var _boneNameLoop:int = 0; _boneNameLoop < _boneNameLength; _boneNameLoop++)
				{
					_boneName += _value.readMultiByte(2, "utf-16");
				}
				_boneList[_boneLoop] = _boneName;
				
				// Unused value in YOA file.
				var _boneId			:int	= _value.readInt();
				
			}
			
			var _frames		:Vector.<Vector.<Vector.<Number>>>	= new Vector.<Vector.<Vector.<Number>>>(_frameCount, true);
			
			for(var _frameIndex:int = 0; _frameIndex < _frameCount; _frameIndex++) // for each frame
			{
				_frames[_frameIndex] = new Vector.<Vector.<Number>>(_boneCount, true);
				
				for(var _boneIndex:int = 0; _boneIndex < _boneCount - 1; _boneIndex++) // foe each bone
				{
					// read bone transformation matrix from file
					var _matrix:Vector.<Number> = new Vector.<Number>(16, true);
					_matrix[0]		= _value.readFloat();
					_matrix[1]		= _value.readFloat();
					_matrix[2]		= _value.readFloat();
					_matrix[4]		= _value.readFloat();
					_matrix[5]		= _value.readFloat();
					_matrix[6]		= _value.readFloat();
					_matrix[8]		= _value.readFloat();
					_matrix[9]		= _value.readFloat();
					_matrix[10]		= _value.readFloat();
					if(_boneIndex % _boneCount == 0)
					{
						_matrix[12]	= _value.readFloat();
						_matrix[13]	= _value.readFloat();
						_matrix[14]	= _value.readFloat();
					} else {
						_matrix[12]	= 0;
						_matrix[13]	= 0;
						_matrix[14]	= 0;
					}
					_matrix[15]		= 1;
					
					// convert v1 yoa transformation matrix to v2 yoa transformation data format
					var _trmatrix:Matrix3D = new Matrix3D();
					var _decomposed:Vector.<Vector3D>;
					_trmatrix.copyRawDataFrom( _matrix );
					_decomposed = _trmatrix.decompose( Orientation3D.QUATERNION );
					
					_animData.addBoneData(_frameIndex, _boneList[_boneIndex], _decomposed[0], new Quaternion(_decomposed[1].w, _decomposed[1].x, _decomposed[1].y, _decomposed[1].z), _decomposed[2]);  
					
				}
			}
			
			
			
			return _animData;
		}
	}
}
