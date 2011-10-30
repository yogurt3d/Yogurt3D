package com.yogurt3d.presets.primitives.test
{
	import com.yogurt3d.core.geoms.Mesh;
	import com.yogurt3d.core.geoms.SubMesh;
	
	public class TestTriangleMesh extends Mesh
	{
		public function TestTriangleMesh(_width:Number, _height:Number)
		{
			super();
			
			
			var subMesh:SubMesh = new SubMesh();
		
			subMesh.indices = new Vector.<Number>;
			subMesh.indices.push(0,1,2 );
			
			subMesh.vertices = new Vector.<Number>;
			subMesh.vertices.push(	0, 0, 0,
							_width,0,0,							
							0, _height,0						
			
			);
			subMesh.uvt = new Vector.<Number>;
			subMesh.uvt.push(1,0,1,1,0,1);
			
			
			subMeshList.push( subMesh );
		}
	}
}