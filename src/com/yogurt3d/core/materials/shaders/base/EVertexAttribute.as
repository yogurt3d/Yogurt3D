package com.yogurt3d.core.materials.shaders.base
{
	import com.yogurt3d.core.utils.Enum;

	public class EVertexAttribute extends Enum
	{
		{initEnum(EVertexAttribute);}		
		
		public static const POSITION 	 :EVertexAttribute = new EVertexAttribute();
		public static const UV   		 :EVertexAttribute = new EVertexAttribute();
		public static const UV_2   		 :EVertexAttribute = new EVertexAttribute();
		public static const UV_3   		 :EVertexAttribute = new EVertexAttribute();
		public static const NORMAL       :EVertexAttribute = new EVertexAttribute();
		public static const TANGENT      :EVertexAttribute = new EVertexAttribute();
		public static const BONE_DATA    :EVertexAttribute = new EVertexAttribute();
		public static const NULL    	 :EVertexAttribute = new EVertexAttribute();
		
		public static function GetConstants() :Array
		{ return Enum.GetConstants(EVertexAttribute); }
		
		public static function ParseConstant(i_constantName :String, i_caseSensitive :Boolean = false) :EVertexAttribute
		{ return EVertexAttribute(Enum.ParseConstant(EVertexAttribute, i_constantName, i_caseSensitive)); }
		
	}
}