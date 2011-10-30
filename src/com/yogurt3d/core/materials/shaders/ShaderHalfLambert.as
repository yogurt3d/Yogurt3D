package com.yogurt3d.core.materials.shaders
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.utils.ByteArray;
	
	public class ShaderHalfLambert extends Shader
	{
		private var m_lambertConst			:ShaderConstants;
		private var m_textureConst			:ShaderConstants;
		
		private var m_opacity				:Number;
		private var m_alpha					:Number;
		private var m_beta					:Number;
		private var m_gamma					:Number;
		private var m_texture				:TextureMap;
		
		public function ShaderHalfLambert(
			_texture:TextureMap,
			_alpha:Number=0.5,
			_beta:Number=0.5,
			_gamma:Number=1.0,
			_opacity:Number=1.0)
		{
			
			super();
			key = "Yogurt3DOriginalsShaderLambert";
			
			m_opacity = _opacity;
			m_alpha = _alpha;
			m_beta = _beta;
			m_gamma = _gamma;
			m_texture = _texture;
			
			params.writeDepth 		= true;
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling			= Context3DTriangleFace.FRONT;
			
			requiresLight				= true;
			
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.NORMAL, EVertexAttribute.BONE_DATA);
			
			params.vertexShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.MVP_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(4, EShaderConstantsType.MODEL_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(8, EShaderConstantsType.BONE_MATRICES));
			
//			var _vertexShaderConsts:ShaderConstants 	= new ShaderConstants();
//			_vertexShaderConsts.type 					= ShaderConstantsType.MVP_TRANSPOSED;
//			_vertexShaderConsts.firstRegister 			= 0;
//			params.vertexShaderConstants.push(_vertexShaderConsts);
//			
//			_vertexShaderConsts 						= new ShaderConstants();
//			_vertexShaderConsts.type 					= ShaderConstantsType.MODEL_TRANSPOSED;
//			_vertexShaderConsts.firstRegister 			= 4;
//			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			// FRAGMENT CONSTANTS
			params.fragmentShaderConstants.push( new ShaderConstants(0 , EShaderConstantsType.CAMERA_POSITION));
			params.fragmentShaderConstants.push( new ShaderConstants(1, EShaderConstantsType.LIGHT_POSITION));
			params.fragmentShaderConstants.push( new ShaderConstants(2, EShaderConstantsType.LIGHT_DIRECTION));
			
			m_lambertConst				 				= new ShaderConstants(3, EShaderConstantsType.CUSTOM_VECTOR);
			m_lambertConst.vector						= Vector.<Number>([ _alpha, _beta, _gamma, m_opacity ]);
			params.fragmentShaderConstants.push(m_lambertConst);
			
			m_textureConst 								= new ShaderConstants(0, EShaderConstantsType.TEXTURE);
			m_textureConst.texture 						= m_texture;
			params.fragmentShaderConstants.push(m_textureConst);
		}
		
		public function get alpha():Number{
			return m_alpha;
		}
		public function set alpha(_value:Number):void{
			m_alpha = _value;
			m_lambertConst.vector[0] = _value;
		}
		
		public function get beta():Number{
			return m_beta;
		}
		public function set beta(_value:Number):void{
			m_beta = _value;
			m_lambertConst.vector[1] = _value;
		}
		
		public function get gamma():Number{
			return m_gamma;
		}
		public function set gamma(_value:Number):void{
			m_gamma = _value;
			m_lambertConst.vector[2] = _value;
		}
		
		public function get opacity():Number{
			return m_opacity;
		}
		public function set opacity(_value:Number):void{
			m_opacity = _value;
			m_lambertConst.vector[3] = _value;
		}
	
		public function get texture():TextureMap{
			return m_texture;
		}
		public function set texture(_value:TextureMap):void{
			m_texture 				= _value;
			m_textureConst.texture 	= m_texture;
		}
	
				public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray{
			
			if( _meshKey == "SkinnedMesh")
			{
				var assembler:AGALMiniAssembler = new AGALMiniAssembler();
				
				var code:String = ShaderUtils.getSkeletalAnimationVertexShader( 
					0, 1, 2, 
					3, 5, 
					0, 4, 8, 
					0, false, false, false  );
				
				code += "mov v" + 0 +".xyzw, vt0.xyzw\n";
				code += "mov v" + 1 + ".xyzw, vt1.xyzw\n";
				code += "mov v" + 2 + ", va1\n";
				
				
				return assembler.assemble(Context3DProgramType.VERTEX, 	code );
			}
			
			//va0 : vertex position 
			//va1: uvt
			//va2: normals		
			var _vertexShader:String = [
				
				"m44 op va0 vc0" , 
				"m44 v0 va0 vc4" , 	
				"m33 vt0.xyz va2 vc4",
				"mov v1.w va2.w",
				"nrm vt0.xyz vt0.xyz" ,
				"mov v1.xyz vt0.xyz" ,// pass Normals
				"mov v2 va1",  // pass UV
				
			].join("\n");
			
			return new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, _vertexShader);
		}
	
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			var _fragmentShader:String = [
				
				"sub ft7 fc0 v0" , 		// ft0 = V =  CameraPos.xyz - WorldPos.xyz;	
				"nrm ft7.xyz ft7.xyz", 	// normalize(V);
				"mov ft1 v1",           // ft1 = N
				"nrm ft1.xyz ft1.xyz",	// normalize(N);
				"mov ft2 fc2",			// L = light direction
				//"neg ft2 ft2.xyz",
				"nrm ft2.xyz ft2.xyz",  // normalize(L)
				
				// View - Independent
				// Step 1 : Half Lambert Term
				"dp3 ft2.x ft1.xyz ft2.xyz", //dot(n.l)
				"mul ft2.x fc3.x ft2.x",// alpha * dot(n.l)
				"add ft2.x ft2.x fc3.y",// alpha * dot(n.l) + beta
				"pow ft2.x ft2.x fc3.z",// lambert = pow((alpha * dot(n.l) + beta) , gamma)
				
				"tex ft3 v2 fs0<2d,clamp,linear>",// get color texture
				"mul ft2 ft2.xxx ft3",
					
				"mov ft0 ft2",
				"div ft0.xyz, ft0.xyz, fc3.w",
				//"mov ft0.w fc3.w",//set opacity
				"mov oc ft0"
				
			].join("\n");
			
			return new AGALMiniAssembler().assemble(AGALMiniAssembler.FRAGMENT, _fragmentShader);
		}
	}
}