package com.yogurt3d.core.materials.shaders
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.materials.base.Color;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.*;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	
	
	public class ShaderShadow extends Shader
	{
		use namespace YOGURT3D_INTERNAL;
		
		private var vaPos:uint = 0;
		private var vaUV:uint = 0;
		private var vaNormal:uint = 0;
		private var vaTangent:uint = 3;
		private var vaBoneIndices:uint = 1;
		private var vaBoneWeight:uint = 3;
		
		private var vcModelToWorld:uint = 15;
		private var vcBoneMatrices:uint = 13;
		
		private var fcLightCone:uint = 6;
		private var fcLightDirection:uint = 7;
		private var fcLightPosition:uint 	= 8;
		
		private var _kernelSize:Number;
		private var _kernelRadius:Number;
		private var _shadowColor:Color;
		private var stepSize:Number;
		private var shadowingAmount:Number;
		private var bias:Number;
		
		private const max_kernelRadius:Number = 2;
		private const max_kernelSize:Number = 5;
		//private const max_filterSize:Number = 50;
		
		private var m_kernelDirty:Boolean = false;
		
		public function ShaderShadow()
		{
			
			
			
			super();
			bias = -0.003;
			
			
			
			
			key = "Yogurt3DOriginalsShaderShadow";
			
			
			setProgramParameters();
		}
		
		
		
		private function setProgramParameters():void
		{
			params.culling = Context3DTriangleFace.FRONT;
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;// source:shadow
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			
			params.writeDepth = false;
			params.depthFunction = Context3DCompareMode.EQUAL;
			params.colorMaskEnabled = true;
			params.colorMaskA = false;
			
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.BONE_DATA );
			
			var _vertexShaderConsts:ShaderConstants;
			
			// vc0: MVP_TRANSPOSED
			_vertexShaderConsts							= new ShaderConstants();
			_vertexShaderConsts.type 					= EShaderConstantsType.MVP_TRANSPOSED;
			_vertexShaderConsts.firstRegister 			= 0;			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			
			// LIGHT_VIEW_PROJECTION_TRANSPOSED
			_vertexShaderConsts							= new ShaderConstants();
			_vertexShaderConsts.type 					= EShaderConstantsType.LIGHT_VIEW_PROJECTION_TRANSPOSED;
			_vertexShaderConsts.firstRegister 			= 4;			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			//for uv coordinate convert
			_vertexShaderConsts							= new ShaderConstants();
			_vertexShaderConsts.type 					= EShaderConstantsType.CUSTOM_VECTOR;
			_vertexShaderConsts.vector					= Vector.<Number>([.50, -.50, 1, 1]);
			_vertexShaderConsts.firstRegister 			= 8;			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			
			_vertexShaderConsts							= new ShaderConstants();
			_vertexShaderConsts.type 					= EShaderConstantsType.MODEL_TRANSPOSED;
			_vertexShaderConsts.firstRegister 			= 9;			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			_vertexShaderConsts							= new ShaderConstants();
			_vertexShaderConsts.type 					= EShaderConstantsType.BONE_MATRICES;
			_vertexShaderConsts.firstRegister 			= 13;			
			params.vertexShaderConstants.push(_vertexShaderConsts);
			
			
			
			var _fragmentShaderConsts:ShaderConstants;
			_fragmentShaderConsts						= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.CUSTOM_VECTOR;
			_fragmentShaderConsts.firstRegister 		= 0;
			
			_fragmentShaderConsts.vector = Vector.<Number>([1, 1/(256), 1/(256*256), 1/(256*256*256), bias, 10 , 2.71828, 0]);
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			
			_fragmentShaderConsts						= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.CUSTOM_VECTOR;
			_fragmentShaderConsts.firstRegister 		= 2;
			_fragmentShaderConsts.vector = Vector.<Number>([0, 0, 0, 1]);
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			// fc6 light cone
			_fragmentShaderConsts						= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.LIGHT_CONE;
			_fragmentShaderConsts.firstRegister 		= 3;
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			
			_fragmentShaderConsts						= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.LIGHT_POSITION;
			_fragmentShaderConsts.firstRegister 		= 8;
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			// LIGHT_SHADOWMAP_TEXTURE
			_fragmentShaderConsts						= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.LIGHT_SHADOWMAP_TEXTURE;
			_fragmentShaderConsts.firstRegister 		= 0;
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
		}
		
		public override function getProgram(_context3D:Context3D, _lightType:ELightType=null, _meshKey:String=""):Program3D{
			return super.getProgram( _context3D, _lightType, _meshKey );
		}
		
		public override function getVertexProgram(_meshKey:String, _lightType:ELightType = null):ByteArray
		{
			
			var code:String = new String();
			
			var posVec:Array = ["x", "y", "z", "w"];
			
			
			if(_meshKey == "SkinnedMesh")
			{
				code +=
					
					"mov vt0, va" + (vaBoneIndices+1) + "\n" + // float4 temp1 = vertexNormal;
					"mov vt0, va" + (vaBoneWeight+1)+ "\n" + // float4 temp1 = vertexNormal;
					// "mov vt2, va" + vaNormal + "\n" +
					"mov vt2, va" + vaBoneIndices + "\n" +// float4 temp1 = vertexNormal;
					"mov vt3, va" + vaBoneWeight + "\n"; // float4 temp1 = vertexTangents;
				
				for( var i:int = 0; i < 8; i++ )
				{
					
					code += "mul vt1, vt3." + posVec[ i % 4 ] + ", vc[vt2." + posVec[ i % 4 ] + "+"+vcBoneMatrices+"]\n";
					if( i == 0 )
					{
						code += "mov vt4, vt1\n";
					}else{
						code += "add vt4, vt1, vt4\n";
					}
					code += "mul vt1, vt3." + posVec[ i % 4 ] + ", vc[vt2." + posVec[ i % 4 ] + "+"+(vcBoneMatrices+1)+"]\n";
					if( i == 0 )
					{
						code += "mov vt5, vt1\n";
					}else{
						code += "add vt5, vt1, vt5\n";
					}
					code += "mul vt1, vt3." + posVec[ i % 4 ] + ", vc[vt2." + posVec[ i % 4 ] + "+"+(vcBoneMatrices+2)+"]\n";
					if( i == 0 )
					{
						code += "mov vt6, vt1\n";
					}else{
						code += "add vt6, vt1, vt6\n";
					}
					if( i == 3 )
					{
						code +=
							"mov vt2, va" + ( vaBoneIndices + int( ( i + 1 ) / 4 ) ) + "\n" + 
							"mov vt3, va" + ( vaBoneWeight + int( ( i + 1 ) / 4 ) ) + "\n";
					}
				}
				//code += "// Bone Transformations End " + i + "\n";
				code += "m34 vt7.xyz, va" + vaPos + ", vt4\n";
				code += "mov vt7.w, va" + vaPos + ".w\n";
				
				//non-skeletal code 
				code +=
					"m44 op, vt7, vc0\n"+
					"m44 vt1, vt7, vc4\n"; // transform by LIGHTVIEW-PROJECTION
			}
			else //"Mesh"
			{
				code +=	"m44 op, va0, vc0\n"+
					"m44 vt1, va0, vc4\n";
			}	
			
			
			if(_lightType == ELightType.SPOT)
			{
				code +=	"rcp vt1.w, vt1.w\n" +
					"mul vt1, vt1, vt1.w\n" + 
					"m44 v7, va0, vc12\n";//MODEL_TRANSPOSED
				
			}//else if(_lightType == "point")
			//{
			//}
			if(_lightType != ELightType.POINT)
				code += "mul vt1.xy, vt1.xy, vc8.xy\n" + // convert to uv
					"add vt1.xy, vt1.xy, vc8.xx\n";
			
			code += "mov v0.xyz, vt1.xyz\n" +
				"mov v0.w, va0.w\n";//gerekmeyebilir
			
			//trace(code);
			return ShaderUtils.vertexAssambler.assemble(AGALMiniAssembler.VERTEX, code);			
		}
		
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			var code2:String = new String();
			
			code2 += "mov ft7, v0\n"; // center of the sampling area converted to uv ,z
			
			code2 += "kil ft7.x\n"; // kill with uv coordinates smaller than zero
			code2 += "kil ft7.y\n";
			code2 += "sub ft6, fc0.x, ft7\n";// kill with uv coordinates smaller than zero
			code2 += "kil ft6.x\n"; 			// "  "
			code2 += "kil ft6.y\n"; 			// "  "
			
			
			
			
			
			
			code2 += "add ft7.z, v0.z, fc1.x\n";// add bias to the depth ,can scale ,receiver 
			
			
			code2 += "tex ft6, ft7, fs0 <2d,linear,clamp>\n" + //ft6.x occluder
				"dp4 ft6.z, ft6, fc0\n" + //ft6.x occluder encoded
				"sub ft6.z, ft6.z, ft7.z\n" + //occluder - receiver
				
				"mul ft6.z, fc1.y, ft6.z\n" + // (over_darkening_factor *(occluder - receiver))
				
				//"pow ft6.w, fc1.z ,ft6.z\n"+ //exp(over_darkening_factor * ( occluder - receiver ))
				
				"sat ft6, ft6\n" ;
			
			
			
			code2 += "mov ft6.xyz, fc2.xyz\n"+ 
				"sub ft6.w, fc0.x, ft6.w\n";
			
			if (_lightType == ELightType.SPOT){
				code2 += "sub ft1, fc8, v7\n" +//light direction 
					"nrm ft4.xyz, ft1.xyz\n" + 
					"dp3 ft4.x, ft4.xyz, fc8.xyz\n" + //fcLightDirection  cos_cur_angle = dot(-L, D)
					"sub ft3.w, ft4.x, fc3.y\n" + 
					"mul ft3.w, ft3.w, fc3.z\n" + //LIGHT_CONE
					"sat ft3.w, ft3.w\n"+//SPOTCUTOFF end	
					
					"mul ft3.w, ft3.w, fc2.w\n"+// alpha * spot cutoff elenebilir
					"mul ft6.w, ft3.w, ft6.w\n"+ 
					"mov oc, ft6\n";}
				
			else if (_lightType == ELightType.DIRECTIONAL)
			{
				code2 += "mul ft6.w, ft6.w, fc2.w\n"+
					"mov oc, ft6\n"; 
			}

			return ShaderUtils.fragmentAssambler.assemble(AGALMiniAssembler.FRAGMENT, code2);
			
			
		}
		
		
		
	}
}