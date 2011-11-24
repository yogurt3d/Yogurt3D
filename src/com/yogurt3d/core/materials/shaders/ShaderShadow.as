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

		private var vaBoneIndices:uint = 1;
		private var vaBoneWeight:uint = 3;

		private var vcBoneMatrices:uint = 13;
		
		private var m_colorAlphaConst:ShaderConstants;;
		private var m_biasOverDarkConst:ShaderConstants;;
		
		
		private var m_shadowColor:Color;
		private var m_shadowAlpha:Number;
		private var m_overDarkeningFactor:Number;
		private var m_bias:Number;

		
		public function ShaderShadow(_overDarkeningFactor:Number = 200,
									 _shadowAlpha:Number = 0.3,
									 _shadowColor:Color = null,
									 _bias:Number = -0.001 )
		{
			super();
			
			key = "Yogurt3DOriginalsShaderShadow";
			
			if(_shadowColor)
				m_shadowColor = _shadowColor;
			else
				m_shadowColor = new Color(0,0,0,0);
			
			m_shadowAlpha = _shadowAlpha;
			m_overDarkeningFactor = _overDarkeningFactor;
			m_bias = _bias;


			setProgramParameters();
			
		}
		

		
		public function set bias(_bias:Number):void
		{
			m_bias = _bias;

			params.fragmentShaderConstants[params.fragmentShaderConstants.indexOf(m_biasOverDarkConst)].vector[4] = _bias;
		}
		
		public function set overDarkeningFactor(_factor:Number):void
		{
			m_overDarkeningFactor = _factor;
			
			params.fragmentShaderConstants[params.fragmentShaderConstants.indexOf(m_biasOverDarkConst)].vector[5] = _factor;
		}		
		
		private function setProgramParameters():void
		{
			params.culling = Context3DTriangleFace.FRONT;
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;// source:shadow
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			
			params.writeDepth = false;
			params.depthFunction = Context3DCompareMode.EQUAL;
			params.colorMaskEnabled = false;
			//params.colorMaskA = true;
			
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.BONE_DATA );
			
			var _vertexShaderConsts:ShaderConstants;
			
			// vc0: MVP_TRANSPOSED
			_vertexShaderConsts							= new ShaderConstants( 0, EShaderConstantsType.MVP_TRANSPOSED);		
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
			
			m_biasOverDarkConst						= new ShaderConstants();
			m_biasOverDarkConst.type 				= EShaderConstantsType.CUSTOM_VECTOR;
			m_biasOverDarkConst.firstRegister 		= 0;
			
			m_biasOverDarkConst.vector = Vector.<Number>([1, 1/(256), 1/(256*256), 1/(256*256*256), m_bias, m_overDarkeningFactor , 2.71828183, -1]);
			params.fragmentShaderConstants.push(m_biasOverDarkConst);
			
			
			m_colorAlphaConst						= new ShaderConstants();
			m_colorAlphaConst.type 					= EShaderConstantsType.LIGHT_SHADOW_COLOR;
			m_colorAlphaConst.firstRegister 		= 2;
			//m_colorAlphaConst.vector = Vector.<Number>([1,0,0,1]);
			params.fragmentShaderConstants.push(m_colorAlphaConst);
			
			_fragmentShaderConsts							= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.CUSTOM_VECTOR;
			_fragmentShaderConsts.vector					= Vector.<Number>([0, 0, -0.1, 1]);
			_fragmentShaderConsts.firstRegister 			= 5;			
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
			
			_fragmentShaderConsts						= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.LIGHT_DIRECTION;
			_fragmentShaderConsts.firstRegister 		= 9;
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			// LIGHT_SHADOWMAP_TEXTURE
			_fragmentShaderConsts						= new ShaderConstants();
			_fragmentShaderConsts.type 					= EShaderConstantsType.LIGHT_SHADOWMAP_TEXTURE;
			_fragmentShaderConsts.firstRegister 		= 0;
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
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
					"m44 v7, va0, vc9\n";//MODEL_TRANSPOSED
				
			}else if(_lightType == ELightType.POINT)
			{
				code += "m44 v7, va0, vc9\n";//MODEL_TRANSPOSED
			}
			if (_lightType != ELightType.POINT)
				code += "mul vt1.xy, vt1.xy, vc8.xy\n" + // convert to uv
					"add vt1.xy, vt1.xy, vc8.xx\n";
			
			code += "mov v0.xyz, vt1.xyz\n" +
				"mov v0.w, va0.w\n";
			
			//trace(code);
			return ShaderUtils.vertexAssambler.assemble(AGALMiniAssembler.VERTEX, code);			
		}
		
		
		public override function getFragmentProgram(_lightType:ELightType=null):ByteArray{
			
			var code2:String = new String();

			if (_lightType == ELightType.DIRECTIONAL)
			{
				// center of the sampling area converted to uv ,z
				code2 += "mov ft7, v0\n"; 
				code2 += "kil ft7.x\n"; // kill with uv coordinates smaller than zero
				code2 += "kil ft7.y\n";
				code2 += "sub ft6, fc0.x, ft7\n";// kill with uv coordinates smaller than zero
				code2 += "kil ft6.x\n"; 			// "  "
				code2 += "kil ft6.y\n"; 			// "  "
			}
			
			if (_lightType == ELightType.SPOT){
				code2 += "sub ft1, fc8, v7\n" +//light direction 
					"nrm ft4.xyz, ft1.xyz\n" + 
					"dp3 ft4.x, ft4.xyz, fc9.xyz\n" + // cos_cur_angle = dot(-L, D)
					"sub ft3.w, ft4.x, fc3.y\n" + 
					"mul ft3.w, ft3.w, fc3.z\n" + //LIGHT_CONE
					//"sat ft3.w, ft3.w\n"+//SPOTCUTOFF end	
					"kil ft3.w\n";
				code2 += "mov ft7, v0\n"; 

				
			}
			
			
			if(_lightType != ELightType.POINT)
			{
				code2 += "tex ft6, ft7, fs0 <2d,linear,clamp>\n" + //ft6.x occluder
					     "dp4 ft6.z, ft6, fc0\n" ; //ft6.x occluder encoded
				    
			}else
			{
				code2 += 				
					"sub ft1, fc8, v7\n" +
					"dp3 ft3.z, ft1.xyz, ft1.xyz\n" + // vt4 = dot(vt1,vt1) -->Attenuation Distance
					"sqt ft3.z, ft3.z\n" + // vt4 = sqrt(dot(vt1,vt1)) -->Attenuation Distance
					
					"slt ft3.w, ft3.z, fc3.w\n" +
					"add ft3.w, fc5.z, ft3.w\n" +
					"kil ft3.w\n"+
					
					
					// vt5 = 1 / Kc + Kl * ft3 + Kq * ft3 * ft3
					"mul ft3.w, ft3.z, ft3.z\n" +
					"mul ft3.w, ft3.w, fc10.z\n" + // Kq * ft3 * ft3
					"mul ft3.z, ft3.z, fc10.y\n" + // Kl * ft3
					"add ft3.z, ft3.z, ft3.w\n" +
					"add ft3.z, ft3.z, fc10.x\n" +
					"div ft3.z, fc0.x, ft3.z\n"+
					
					"kil ft3.z\n"+
					
					
					"dp3 ft1.z, v0.xyz, v0.xyz\n" + 
					"sqt ft1.z, ft1.z\n" +//Length
					"div ft7, v0.xyz, ft1.zzz\n"+//vPosDP
					
					
					
					"slt ft2.x, ft7.z, fc5.x\n"+//kıyas sonucu 0 dan küçük
					"sub ft2.y, fc0.x, ft2.x\n"+//inverse condition
					
					//"pow ft2.y, fc1.w, ft2.x\n"+//***
					"mul ft5.x, ft7.z, fc1.w\n"+
					"mov ft5.y, ft7.z\n"+ //- or + vPosDP.z
					
					"mul ft5.x, ft5.x, ft2.x\n"+
					//"add ft5.x, ft5.x, fc2.x\n"+
					
					"mul ft5.y, ft5.y, ft2.y\n"+
					//"add ft5.y, ft5.y, fc2.y\n"+
					
					"add ft7.z, ft5.x, ft5.y\n"+//yutan toplam
					
					
					"add ft7.z, fc0.x, ft7.z\n"+//(1.0f + vPosDP.z) or -
					
					"div ft3.x, ft7.x, ft7.z\n"+//(vPosDP.x /  (1.0f - vPosDP.z))
					"mul ft3.x, ft3.x, fc4.x\n"+//10  (vPosDP.x /  (1.0f + vPosDP.z)) * 0.5f
					"add ft3.x, ft3.x, fc4.x\n"+//tex x
					//"sat ft3.x, ft3.x\n"+
					
					"div ft3.y, ft7.y, ft7.z\n"+
					"mul ft3.y, ft3.y, fc4.x\n"+
					"add ft3.y, ft3.y, fc4.x\n"+
					
					"sub ft3.y, fc0.x, ft3.y\n"+//tex y
					
					//"sat ft3.y, ft3.y\n"+
					
					"tex ft6, ft3.xy, fs0 <2d,linear,clamp>\n" +//front
					"mul ft6, ft6, ft2.xxxx\n" +
					
					"tex ft0, ft3.xy, fs1 <2d,linear,clamp>\n" +//back
					"mul ft0, ft0, ft2.yyyy\n" +
					
					"add ft6, ft0, ft6\n" +
					"dp4 ft6.z, ft6, fc0\n" + //ft6.z occluder encoded
					"sub ft1.x, ft1.z, fc4.y\n"+
					//"sub ft1.z, fc4.y, fc4.w\n"+
					"div ft7.z, ft1.x, fc4.z\n";//receiver
				
			}
			
			
			code2 += "add ft7.z, ft7.z, fc1.x\n";// add bias to the depth ,can scale ,receiver 
			
			code2 +=  "sub ft6.z, ft6.z, ft7.z\n" + //occluder - receiver
				
				"mul ft6.z, fc1.y, ft6.z\n" + // (over_darkening_factor *(occluder - receiver))
				
				"pow ft6.w, fc1.z ,ft6.z\n"+ //exp(over_darkening_factor * ( occluder - receiver ))
				
				"sat ft6.w, ft6.w\n" ;
			
			
			
			code2 += "mov ft6.xyz, fc2.xyz\n"+
			"sub ft6.w, fc0.x, ft6.w\n";
			
			if (_lightType == ELightType.SPOT){
				code2 +=
					//"sub ft3.w, fc0.x, ft3.w\n"+
					//"mul ft3.w, ft3.w, fc2.w\n"+// alpha * spot cutoff 
					"mul ft6.w, fc2.w, ft6.w\n"+
					
					//"mov ft6.w, fc0.x\n"+
					"mov oc, ft6\n";
				
			}else if(_lightType == ELightType.POINT)
			{
				code2 += //"mul ft6.xyz, ft3.zzz,ft6.www\n"+
					//"mov ft6.w, fc0.x\n"+
					"mul ft6.w, fc2.w, ft6.w\n"+
					"mov oc, ft6\n";
			}
			else
			{
				code2 += //"mov ft6.xyz, fc2.xxx\n"+
					//"mov ft6.w, fc0.x\n"+
					"mul ft6.w, fc2.w, ft6.w\n"+
					"mov oc, ft6\n"; 
			}
			
			
			
			
			
			return new AGALMiniAssembler().assemble(AGALMiniAssembler.FRAGMENT, code2);
			
			
		}
		
		
		
	}
}