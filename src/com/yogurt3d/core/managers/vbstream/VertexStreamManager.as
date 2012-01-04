package com.yogurt3d.core.managers.vbstream
{
	import com.yogurt3d.core.geoms.SkinnedSubMesh;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	public final class VertexStreamManager
	{
		private static var m_instance:VertexStreamManager;
		
		private var m_contextBufferAllocationCount:Dictionary ;
		
		public function VertexStreamManager(enforcer:SingletonEnforcer)
		{
			m_contextBufferAllocationCount = new Dictionary();
		}
		
		public static function get instance():VertexStreamManager{
			if( m_instance == null )
			{
				m_instance = new VertexStreamManager(new SingletonEnforcer());
			}
			return m_instance;
		}
		
		public function cleanVertexBuffers(_context3d:Context3D):void{
			if( m_contextBufferAllocationCount[_context3d] > -1 )
			{
				for( var i:uint = 0; i < m_contextBufferAllocationCount[_context3d] ; i++)
				{
						_context3d.setVertexBufferAt( i, null );
				}
				m_contextBufferAllocationCount[_context3d] = -1;
			}
		}
		
		public function setStream( _context3d:Context3D, index:uint, buffer:VertexBuffer3D, bufferOffset:uint = 0, format:String = "float4" ):void{
			if(m_contextBufferAllocationCount[_context3d] < index+1 )
			{
				m_contextBufferAllocationCount[_context3d] = index+1;
			}
			_context3d.setVertexBufferAt( index, buffer, bufferOffset, format );
		}
		
		/**
		 * Loads buffers the shader needs from the submesh to the specified context3d. <br/>
		 * This method clears all unneeded buffers afterwards.
		 * 
		 * @param _context3d
		 * @param _submesh
		 * @param _shader
		 * 
		 */
		public function setStreamsFromShader( _context3d:Context3D, _submesh:SubMesh, _shader:Shader ):void{
			
			if( _submesh == null || _shader == null )
			{
				return;
			}
			
			var vertexBufferIndex:uint = 0;

			var att:Vector.<EVertexAttribute> = _shader.attributes;
			
			if( att.length == 0 )
			{
				throw new Error("Vertex Attributes not defined for shader " + getQualifiedClassName(_shader));
			}
			
			var mesh:Object = _submesh;
			
			
			var _len:uint = att.length;
			for( var i:int = 0; i < _len; i++ )
			{
				var attr:EVertexAttribute = att[i];
				switch(attr)
				{
					case( EVertexAttribute.POSITION ):
						_context3d.setVertexBufferAt( vertexBufferIndex++, mesh.getPositonBufferByContext3D( _context3d ), 0, Context3DVertexBufferFormat.FLOAT_3 );
						break;
					case(EVertexAttribute.UV ):
						_context3d.setVertexBufferAt( vertexBufferIndex++, mesh.getUVBufferByContext3D( _context3d ), 0, Context3DVertexBufferFormat.FLOAT_2 );
						break;
					case( EVertexAttribute.UV_2 ):
						_context3d.setVertexBufferAt( vertexBufferIndex++, mesh.getUV2BufferByContext3D( _context3d ), 0, Context3DVertexBufferFormat.FLOAT_2 );
						break;
					case( EVertexAttribute.UV_3 ):
						_context3d.setVertexBufferAt( vertexBufferIndex++, mesh.getUV3BufferByContext3D( _context3d ), 0, Context3DVertexBufferFormat.FLOAT_2 );
						break;
					case( EVertexAttribute.NORMAL ):
						
						_context3d.setVertexBufferAt( vertexBufferIndex++, mesh.getNormalBufferByContext3D( _context3d ), 0, Context3DVertexBufferFormat.FLOAT_3 );
						break;
					case( EVertexAttribute.TANGENT ):
						
						_context3d.setVertexBufferAt( vertexBufferIndex++, mesh.getTangentBufferByContext3D( _context3d ), 0, Context3DVertexBufferFormat.FLOAT_3 );
						break;
					case( EVertexAttribute.BONE_DATA ):
						
						if( mesh is SkinnedSubMesh )
						{
							var _boneBuffer:VertexBuffer3D = mesh.getBoneDataBufferByContext3D( _context3d );
							
							_context3d.setVertexBufferAt( vertexBufferIndex++, _boneBuffer, 0, Context3DVertexBufferFormat.FLOAT_4 );
							_context3d.setVertexBufferAt( vertexBufferIndex++, _boneBuffer, 4, Context3DVertexBufferFormat.FLOAT_4 );
							_context3d.setVertexBufferAt( vertexBufferIndex++, _boneBuffer, 8, Context3DVertexBufferFormat.FLOAT_4 );
							_context3d.setVertexBufferAt( vertexBufferIndex++, _boneBuffer, 12,Context3DVertexBufferFormat.FLOAT_4 );
						}else{
							_context3d.setVertexBufferAt( vertexBufferIndex++, null );
							_context3d.setVertexBufferAt( vertexBufferIndex++, null );
							_context3d.setVertexBufferAt( vertexBufferIndex++, null );
							_context3d.setVertexBufferAt( vertexBufferIndex++, null );
						}
						break;
					case( EVertexAttribute.NULL ):
						_context3d.setVertexBufferAt( vertexBufferIndex++, null );
						break;
				}
			}
			
			if( m_contextBufferAllocationCount[_context3d] != null )
			{
				if( m_contextBufferAllocationCount[_context3d] > vertexBufferIndex )
				{
					for( i = vertexBufferIndex; i < m_contextBufferAllocationCount[_context3d]; i++)
					{
						_context3d.setVertexBufferAt( i, null );
					}
				}
			}
			m_contextBufferAllocationCount[_context3d] = vertexBufferIndex;
		}
		
	}
}
internal class SingletonEnforcer {}