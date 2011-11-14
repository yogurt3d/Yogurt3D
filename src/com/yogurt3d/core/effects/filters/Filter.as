package com.yogurt3d.core.effects.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.managers.vbstream.VertexStreamManager;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.texture.RenderTextureTarget;
	import com.yogurt3d.core.utils.MathUtils;
	import com.yogurt3d.core.utils.ShaderUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class Filter extends Shader
	{	
		use namespace YOGURT3D_INTERNAL;
		
		private static var m_vertexBuffer:Dictionary;
		private static var m_indiceBuffer:Dictionary;
		
		private static var vsManager:VertexStreamManager = VertexStreamManager.instance;
		
		YOGURT3D_INTERNAL var m_renderTarget:RenderTextureTarget;
		
		protected static var m_width:Number;
		protected static var m_height:Number;
		
		public function Filter()
		{
			super();
			m_vertexBuffer = new Dictionary();
			m_indiceBuffer = new Dictionary();
		}


		public function dispose():void{
			if( m_renderTarget )
			{
				m_renderTarget.dispose();
				m_renderTarget = null;
			}
			if( m_vertexBuffer )	
			{
				for each (var verBuf:VertexBuffer3D in m_vertexBuffer) {verBuf.dispose();}				
			}
			if( m_indiceBuffer )	
			{
				for each (var inBuf:IndexBuffer3D in m_indiceBuffer) {inBuf.dispose();}				
			}
		}
		
		public function setShaderConstants(_context3D:Context3D, _viewport:Rectangle):void{}
		
		public function clearTextures(_context3D:Context3D):void{}
		

		
		public function getRenderTarget( _rect:Rectangle):RenderTextureTarget
		{
			if(m_renderTarget == null)
			{
				m_renderTarget = new RenderTextureTarget(
					m_width  = MathUtils.getClosestPowerOfTwo(_rect.width),
					m_height = MathUtils.getClosestPowerOfTwo(_rect.height)
				);
			}
			return m_renderTarget;
		}
		
		public function postProcess(_context3d:Context3D, _viewport:Rectangle, _sampler:RenderTextureTarget):void{
			
			_context3d.setProgram(getProgram(_context3d) );
			
			
			_context3d.setBlendFactors( Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO );
			_context3d.setColorMask(true,true,true,false);
			_context3d.setDepthTest( false, Context3DCompareMode.ALWAYS );
			_context3d.setCulling( Context3DTriangleFace.NONE );

			setShaderConstants(_context3d, _viewport);
			
			vsManager.setStream( _context3d, 0, getVertexBuffer(_context3d), 0, Context3DVertexBufferFormat.FLOAT_2 );  // x, y
			vsManager.setStream( _context3d, 1, getVertexBuffer(_context3d), 2, Context3DVertexBufferFormat.FLOAT_2 ); // u,v 
			
			
			//			
			//			context3D.setDepthTest(false, Context3DCompareMode.EQUAL );
			//			context3D.setCulling( Context3DTriangleFace.FRONT );
			
			_context3d.setTextureAt(0, _sampler.getTexture3D(_context3d) );
			_context3d.drawTriangles(getIndiceBuffer(_context3d), 0, 2 );
			
			_context3d.setTextureAt(0, null);
			clearTextures(_context3d);
			
		}
		
		public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray
		{
			return ShaderUtils.vertexAssambler.assemble( AGALMiniAssembler.VERTEX, 
				"mov op va0\n"+
				"mov v0 va1"
			);
		}
		
		private static function getVertexBuffer(_context3D:Context3D):VertexBuffer3D{
			if( m_vertexBuffer[_context3D] == null )
			{
				m_vertexBuffer[_context3D] = _context3D.createVertexBuffer( 4, 4 ); // 4 vertices, 7 floats per vertex
				m_vertexBuffer[_context3D].uploadFromVector(
					Vector.<Number>(
						[
							// x,y,u,v
							1,1,   1,0,    
							1,-1,  1,1, 
							-1,-1, 0,1, 
							-1,1,  0,0, 
						]
					),0, 4
				);
			}return m_vertexBuffer[_context3D];
		}
		private static function getIndiceBuffer(_context3D:Context3D):IndexBuffer3D{
			if( m_indiceBuffer[_context3D] == null )
			{
				m_indiceBuffer[_context3D] = _context3D.createIndexBuffer( 6 );
				m_indiceBuffer[_context3D].uploadFromVector( Vector.<uint>( [ 0, 1, 2, 0, 2, 3 ] ), 0, 6 );   
			}return m_indiceBuffer[_context3D];
		}
		
	}
}