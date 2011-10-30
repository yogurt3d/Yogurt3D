package com.yogurt3d.io.loaders
{
	import com.yogurt3d.io.parsers.TextureMap_Parser;
	import com.yogurt3d.io.parsers.Y3D_Parser;
	import com.yogurt3d.io.parsers.YOA_Parser;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.getTimer;
	
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipFile;

	
	public class CompressedFile extends ZipFile
	{
		public function CompressedFile(data:IDataInput)
		{
			super(data);
		}
		/**
		 * 
		 * @param name of file. Could include directory
		 * @param asyncFunction Not implemented
		 * @return 
		 * 
		 */		
		public function getContent(name:String, asyncFunction:Function = null):*{
			var entry:ZipEntry = getEntry( name );
			var dotIndex:int = entry.name.lastIndexOf(".");
			
			var byteArray:ByteArray = getInput(entry);
			
			
			if( dotIndex == -1 )
			{
				return byteArray;
			}
			var extension:String = name.substring(dotIndex+1, name.length ).toLowerCase();
			
			if( extension == "y3d")
			{
				return new Y3D_Parser().parse( byteArray );
			}else if( extension == "yoa")
			{
				return new YOA_Parser().parse( byteArray );
			}else if( extension == "atf")
			{
				return new TextureMap_Parser().parse( byteArray );
			}else if( extension == "jpg" || extension == "png" || extension == "bmp" || extension == "gif")
			{
				return new TextureMap_Parser().parse( byteArray );
			}
			return null;
		}
	}
}