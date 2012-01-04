package com.yogurt3d.core.materials.shaders
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class ShaderEnvMapReflectivityMap extends Shader
	{
		private var m_mipmap						:Boolean;
		private var m_cubeMap						:CubeTextureMap;
		private var m_contextToTextureMap			:Dictionary;
		private var m_alpha							:Number;
		private var m_envMapTexture					:ShaderConstants;
		public  var m_alphaConsts					:ShaderConstants;
		private var m_normalMap						:TextureMap;
		private var m_reflectivityMap				:TextureMap;
		
		private var m_normalMapDirty				:Boolean = false;
		private var m_normalMapConst				:ShaderConstants;
		/**
		 * 
		 * 
		 * @author Yogurt3D Engine Core Team
		 * @company Yogurt3D Corp.
		 **/
		public function ShaderEnvMapReflectivityMap(_cubeMap:CubeTextureMap, 
												  _reflectivityMap:TextureMap,
												  _normalMap:TextureMap=null,_alpha:Number=1.0 )
		{
			key = "Yogurt3DOriginalsShaderEnvMapReflectionMap";
			
			m_cubeMap					= _cubeMap;
			m_contextToTextureMap   	= new Dictionary();
			m_alpha 					= _alpha;
			normalMap 					= _normalMap;
			m_reflectivityMap			= _reflectivityMap;
			
//			params.blendEnabled			= true;
//			params.blendSource			= Context3DBlendFactor.SOURCE_ALPHA;
//			params.blendDestination		= Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
//			params.writeDepth			= false;
//			params.depthFunction		= Context3DCompareMode.EQUAL;
//			params.colorMaskEnabled		= false;
//			params.colorMaskR			= true;
//			params.colorMaskG			= true;
//			params.colorMaskB			= true;
//			params.colorMaskA			= false;
//			params.culling				= Context3DTriangleFace.FRONT;
//			params.loopCount			= 1;
			
			params.writeDepth 		= true;
			params.depthFunction	= Context3DCompareMode.LESS_EQUAL;
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling			= Context3DTriangleFace.FRONT;
			
			params.requiresLight				= false;

			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.NORMAL, EVertexAttribute.TANGENT );

			
			var _vertexShaderConsts:ShaderConstants 	= new ShaderConstants();
			_vertexShaderConsts.type 					= EShaderConstantsType.MVP_TRANSPOSED;
			_vertexShaderConsts.firstRegister 			= 0;// vc0, matrix oldugu icin vc0.vc1.vc2.v
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts 						= new ShaderConstants();
			_vertexShaderConsts.type 					= EShaderConstantsType.MODEL_TRANSPOSED;
			_vertexShaderConsts.firstRegister 			= 4;// vc4
			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			// environmental map
			m_envMapTexture 							= new ShaderConstants();
			m_envMapTexture.type						= EShaderConstantsType.TEXTURE;
			m_envMapTexture.firstRegister				= 0; // FS0
			m_envMapTexture.texture 					= m_cubeMap;
			params.fragmentShaderConstants.push(m_envMapTexture);
			
			
			var _fragmentShaderConsts:ShaderConstants 	= new ShaderConstants();
			
			_fragmentShaderConsts						= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.TEXTURE;
			_fragmentShaderConsts.firstRegister			= 2;// fs2 reflection map
			_fragmentShaderConsts.texture				= m_reflectivityMap;
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
						
			// fc0: camera pos
			_fragmentShaderConsts						= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.CAMERA_POSITION;
			_fragmentShaderConsts.firstRegister			= 0;
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			// fc1 : alpha
			m_alphaConsts   							= new ShaderConstants();
			m_alphaConsts.type 							= EShaderConstantsType.CUSTOM_VECTOR;
			m_alphaConsts.vector						= Vector.<Number>([ m_alpha, 2.0, 0.5, -1.0 ]);
			m_alphaConsts.firstRegister					= 1;
			params.fragmentShaderConstants.push(m_alphaConsts);
			
			// fc1 : custom vector for normal map based vertex normal calculation
			_fragmentShaderConsts   					= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.CUSTOM_VECTOR;
			_fragmentShaderConsts.vector				= Vector.<Number>([ 1.0, 1.0, 1.0, 0.0 ]);
			_fragmentShaderConsts.firstRegister			= 2;
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
		}
		
		public function get reflectivityMap():TextureMap
		{
			return m_reflectivityMap;
		}
		
		public function set reflectivityMap(value:TextureMap):void
		{
			m_reflectivityMap = value;
		}
		
		public function get normalMap():TextureMap
		{
			return m_normalMap;
		}
		
		public function set normalMap(value:TextureMap):void
		{
			m_normalMap = value;
			m_normalMapDirty = true;
		}
		
		public function get alpha():Number{
			return alpha;
		}
		
		public function set alpha(_alpha:Number):void{
			m_alpha = _alpha;
			m_alphaConsts.vector = Vector.<Number>([_alpha, 2.0, 1.0, 1.0 ]);
			params.fragmentShaderConstants[params.fragmentShaderConstants.indexOf(m_alphaConsts)] = m_alphaConsts;
		}
		
				public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			//va0 : vertex position 
			//va1: uvt
			//va2: normals
			//va3: tangents
			
			var _environmentalMappingVS:String = [
				
				"m44 op va0 vc0" , 
				"m44 v0 va0 vc4" , 	
				"m33 vt0.xyz va2 vc4",
				"mov v1.w va2.w",
				"nrm vt0.xyz vt0.xyz" ,
				"mov v1.xyz vt0.xyz" ,// pass Normals
				"mov v2 va1",  // pass UV
				"mov v3 va3", // pass Tangent
				"mov vt1.w va0.w",// binormal calculation
				"crs vt1.xyz va1.xyz va3.xyz",
				"nrm vt1.xyz vt1.xyz",
				"mov v4 vt1"// pass binormals 
				
			].join("\n");
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, _environmentalMappingVS);
		}
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			// v0: Pixel Position in world space
			// v1: normal
			// v2: uvt  
			
			var _normalAGAL:String;
			
			if(m_normalMap != null){
				
				_normalAGAL = [   
					
					"tex ft1 v2 fs1<2d,wrap,linear>",
					// lookup normal from normal map, move from [0,1] to  [-1, 1] range, normalize
					// texNormal = texNormal * 2 - 1;
					"mul ft1 ft1 fc1.y",
					"sub ft1 ft1 fc2.x",
					"nrm ft1.xyz ft1",
					
					//	texNormal = (vecNormalWS * texNormal.z) + (texNormal.x * vecBinormalWS + texNormal.y * -vecTangentWS);
					"mul ft2 v1 ft1.z", // (vecNormalWS * texNormal.z)
					"mul ft5 ft1.x v4", // texNormal.x * vecBinormalWS
					"mul ft6 fc1.w v3", // -vecTangentWS
					"mul ft6 ft1.y ft6", //texNormal.y * -vecTangentWS
					"add ft5 ft5 ft6",//(texNormal.x * vecBinormalWS + texNormal.y * -vecTangentWS)
					"add ft1 ft5 ft2"		
					
				].join("\n");
				
			}else
				_normalAGAL =  "mov ft1 v1"; 
			
			// V: view vector
			// N: normal
			// T: tangent
			// B: binormal
			
			var _environmentalMappingFS:String = [   
				"mov ft3 v3",					      // ft3 = T 
				"mov ft4 v4",                         // ft4 = B
				_normalAGAL,					      // decide normal: texture or vertex normal?
				"sub ft7 fc0 v0" ,                    // ft7 = V
				"nrm ft7.xyz ft7",				      // norm(V)
				"dp3 ft0 ft7 ft1", 				      // V.N
				"add ft0 ft0 ft0",                    // 2(V.N)
				"mul ft0 ft0 ft1",   			      // 2(V.N)N
				"sub ft0 ft0 ft7",   				  // 2(V.N)N - V
				"tex ft0 ft0 fs0<3d,cube,linear> ",   // get envMap
				"tex ft2 v2 fs2<2d,wrap,linear>",     // get reflection map
				
				"mul ft0.w ft2.xyz fc1.x",  
				
				"mov oc ft0"
				
			].join("\n");
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, _environmentalMappingFS);
		}
		
		public override function getProgram(_context3D:Context3D, _lightType:ELightType=null, _meshType:String = null):Program3D{
			
			if(m_normalMapDirty )
			{
				if(m_normalMap != null ){
					key = "Yogurt3DOriginalsShaderEnvMapReflectionMapWithNormal";
					if( m_normalMapConst == null )
					{
						m_normalMapConst 						= new ShaderConstants();
						m_normalMapConst.type					= EShaderConstantsType.TEXTURE;
						m_normalMapConst.firstRegister			= 1;// FS1
						params.fragmentShaderConstants.push(m_normalMapConst);	
					}
					m_normalMapConst.texture = m_normalMap;
				}else{
					key = "Yogurt3DOriginalsShaderEnvMapReflectionMap";
					if(m_normalMapConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_normalMapConst ), 1 );
						m_normalMapConst = null;
					}
				}
				disposeShaders();
				m_normalMapDirty = false;
			}
			
			return super.getProgram( _context3D, _lightType, _meshType );
		}
	}
}