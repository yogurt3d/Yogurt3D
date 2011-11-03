/*
 * ShaderUtils.as
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
 /**
 * 07/01/2011 - Gurel Erceis - Fixed bone count bug. 
 * 07/01/2011 - Gurel Erceis - Reduced opCode count by adding matrixes and multiplying vertices only once. 
 * 
 * 
 **/
 
package com.yogurt3d.core.utils
{
	import com.adobe.utils.AGALMiniAssembler;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class ShaderUtils
	{
		public static const vertexAssambler:AGALMiniAssembler = new AGALMiniAssembler();
		public static const fragmentAssambler:AGALMiniAssembler = new AGALMiniAssembler();
		/**
		 * Generates Vertex Shader<br/>
		 * Outputs<br/>
		 * oc - clip space vertex position<br/>
		 * vt0 - world space vertex position<br/>
		 * vt1 - world space normal<br/>
		 * vt2 - world space tangent <br/>
		 *  
		 * @param vaPos
		 * @param vaUV
		 * @param vaNormal
		 * @param vaBoneIndices
		 * @param vaBoneWeight
		 * @param vcModelViewProjection
		 * @param vcModel
		 * @param vcBoneMatrices
		 * @param boneCount
		 * @param vaTangent
		 * @param includeTangentCalculation
		 * @return 
		 * 
		 */
		public static function getSkeletalAnimationVertexShader(
			vaPos:uint,
			vaUV:uint,
			vaNormal:uint,
			vaBoneIndices:uint,
			vaBoneWeight:uint,
			vcModelViewProjection:uint,
			vcModel:uint,
			vcBoneMatrices:uint,
			vaTangent:uint = 0,
			includeNormalCalculation:Boolean = false,
			includeTangent:Boolean = false,
			includeTangentCalculation:Boolean = false
			
		):String{
			var posVec:Array = ["x", "y", "z", "w"];
			
			// Fail safe part
			var code:String = "mov vt0, va" + vaUV + "\n" + // float4 temp1 = vertexNormal;
				"mov vt0, va" + (vaBoneIndices+1) + "\n" + // float4 temp1 = vertexNormal;
				"mov vt0, va" + (vaBoneWeight+1)+ "\n" + // float4 temp1 = vertexNormal;
				
				"mov vt2, va" + vaNormal + "\n" +
				"mov vt2, va" + vaBoneIndices + "\n" +// float4 temp1 = vertexNormal;
				"mov vt3, va" + vaBoneWeight + "\n"; // float4 temp1 = vertexTangents;
			
			//code += "// Bone Transformations Start " + i + "\n";
			for( var i:int = 0; i < 8; i++ )
			{
				//code += "//bone "+i+"\n";
				//code += "//translationMatrix += weight * matrix\n";
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
						"mov vt2, va" + ( vaBoneIndices	+ int( ( i + 1 ) / 4 ) ) + "\n" + 
						"mov vt3, va" + ( vaBoneWeight	+ int( ( i + 1 ) / 4 ) ) + "\n";
				}
			}
			//code += "// Bone Transformations End " + i + "\n";
			
			code += "m34 vt0.xyz, va" + vaPos + ", vt4\n";
			code += "mov vt0.w, va" + vaPos + ".w\n";
			
			if( includeNormalCalculation )
			{
				code += "m33 vt1.xyz, va" + vaNormal + ", vt4\n";
				code += "mov vt1.w, va" + vaNormal + ".w\n";
				code += "m33 vt1.xyz, vt1.xyz, vc" + vcModel + "\n";
			}else{
				code += "m33 vt1.xyz, va" + vaNormal + ".xyz, vc" + vcModel + "\n";
			}
			if( includeTangentCalculation )
			{
				code += "m33 vt2.xyz, va" + vaTangent + ", vt4\n";
				code += "mov vt2.w, va" + vaTangent + ".w\n";
			}else{
				if( includeTangent )
				{
					code += "m33 vt2.xyz, va"+vaTangent+".xyz, vc" + vcModel + "\n";
				}
			}
			
			code += "m44 op, vt0, vc" + vcModelViewProjection + "\n";
			code += "m44 vt0, vt0, vc" + vcModel + "\n";
			
			return code;
		}
		
		public static function agal(_opCode:String, _target:String, _op1:String="", _op2:String=""):String{
			
			if(_op1.length > 0 && _op2.length >0)
				return _opCode+" "+_target+" "+_op1+" "+_op2;
			else if(_op1.length > 0)
				return _opCode+" "+_target+" "+_op1;
			
			return _opCode+" "+_target;
		}
		
		// sign function: returns 1.0 if x>0, 0.0 if x=0, -1.0 if x<0
		// target should be vec4
		// returns result in target.x
		// minusOne = -1.0, _one = 1.0, _zero = 0.0
		// _zeroApp = 0.00001 (for sge)
		public static function signAGAL(_target:String, _source:String,
										_minusOne:String, _one:String, _zero:String, 
										_zeroApp:String):String{
			var code:String = [
				agal("sge",_target+".y",_source, _zeroApp),
				agal("slt",_target+".z",_source, _zero),
				
				agal("mul",_target+".y",_target+".y", _one),
				agal("mul",_target+".z",_target+".z", _minusOne),
				
				agal("add",_target+".x",_target+".y", _target+".z"),
			
			].join("\n");
			
			return code;
		
		}
		
		// mod function: a - b*floor(a/b)
		public static function modAGAL(_target:String, _temp:String,_a:String, _b:String):String{
			
			var code:String = [
				agal("div",_temp,_a, _b),// a/b
				ShaderUtils.floorAGAL(_target, _temp),//floor(a/b)
				agal("mul",_target,_target, _b),//b*floor(a/b)
				agal("sub",_target,_a, _target)//a - floor(a/b)
				
//				agal("div",_target,_a, _b),
//				agal("frc",_target,_target),// (frc (a / b))(frc (a / b))
//				agal("mul",_target,_target,_b)//(frc (a / b)) * b]
			].join("\n");
			
			return code;
		}
		
		// floor function
		public static function floorAGAL(_target:String, _source:String):String{
		
			var code:String = [
				agal("frc",_target,_source),// z = source - floor(source)
				agal("sub",_target,_source,_target)//floor(source) = source + z
			].join("\n");
			
			return code;
		}
		//GLSL: clamp function min(max(x, minVal), maxVal)
		public static function clamp(_target:String, _x:String, _minVal:String, _maxVal:String):String{
		
			var code:String = [
				agal("max",_target,_x, _minVal),// max(x, minVal)
				agal("min",_target,_target,_maxVal)// min(max(x, minVal), maxVal)
			].join("\n");
			
			return code;
		}
		
		//GLSL: smoothstep function
		// t = clamp((x - edge0)/(edge1 - edge0), 0, 1)
		// return t * t * (3 - 2*t)
		public static function smoothstep(_target:String, _temp:String, _edge0:String, _edge1:String, _x:String, 
										  _zero:String, _one:String, _two:String, _three:String):String{
			var code:String = [
				agal("sub",_temp+".x", _x, _edge0),//(x - edge0)
				agal("sub",_temp+".y", _edge1, _edge0),//(edge1 - edge0)
				agal("div",_temp+"x", _temp+".x", _temp+".y"),//(x - edge0)/(edge1 - edge0)
				clamp(_target, _temp+"x", _zero, _one),//t = clamp((x - edge0)/(edge1 - edge0), 0, 1)
				
				agal("mul",_temp+".x", _two, _target),//2*t
				agal("sub",_temp+".x", _three, _temp+".x"),// 3 - 2*t
				agal("mul", _target, _target, _target),//t * t 
				agal("mul", _target, _temp+".x", _target)
				
			].join("\n");
			
			return code;
		}
		// GLSL: distance function
		public static function distance(_target:String, _temp:String, _vec1:String, _vec2:String):String{
			
			var code:String = [
				agal("sub",_temp,_vec1, _vec2),
				length(_target, _temp)
			].join("\n");
			
			return code;
		}
		
		// GLSL: length of the source vector 
		public static function length(_target:String, _source:String):String{
		
			var code:String = [
				agal("dp3",_target,_source, _source),
				agal("sqt",_target,_target)
			].join("\n");
			return code;
		}
		
		// GLSL: I – 2 * dot(N, I) * N
		public static function reflect(_target:String, _incidence:String, _normal:String):String{
			
			var code:String = [
				agal("dp3",_target,_normal, _incidence),// dot(N, I) 
				agal("add",_target,_target,_target),// 2 * dot(N, I) 
				agal("mul",_target, _target, _normal),// 2 * dot(N, I) * N
				agal("sub",_target,_incidence,_target)// I – 2 * dot(N, I) * N
				
			].join("\n");
			return code;
		}
		
		// GLSL: 2 * dot(N, L) * N - L
		public static function reflectionVector(_target:String, _light:String, _normal:String):String{
			
			var code:String = [
				agal("dp3",_target,_normal, _light),// dot(N, I) 
				agal("add",_target,_target,_target),// 2 * dot(N, I) 
				agal("mul",_target, _target, _normal),// 2 * dot(N, I) * N
				agal("sub",_target,_target, _light)// 2 * dot(N, I) * N - L
				
			].join("\n");
			return code;
		}
		
		//GLSL: x*(1 - a) + y*a
		public static function mix(_target:String,_temp:String, 
							_x:String, _y:String, _a:String,_oneMina:String):String{
			
			var code:String = [
				agal("mul",_target, _x, _oneMina),//x*(1 - a)
				agal("mul",_temp, _y, _a),//y*a
				agal("add",_target, _target, _temp)////x*(1 - a) + y*a
				
			].join("\n");
			return code;
		}
		
		/*******************************************************************************
		* Refract Function: incidence, normal, eta
		* parameters(vec3 i, vec3 n, float eta)
		* float cosi = dot(-i, n);
		* float cost2 = 1.0 - eta * eta * (1.0 - cosi*cosi);
		* vec3 t = eta*i + ((eta*cosi - sqrt(abs(cost2))) * n);
		* return t * vec3(cost2 > 0.0);
		*******************************************************************************/
		public static function refract(_target:String, _incidence:String, _normal:String, 
								_eta:String,_one:String, _zero:String,
								_temp:String, _temp2:String):String{
			
			var code:String = [
				agal("neg", _incidence, _incidence+".xyz"), // i = -i
				agal("dp3", _target, _incidence, _normal),//cosi = dot(-i, n)
				
				agal("mul", _temp, _target, _target),// cosi * cosi
				agal("sub", _temp, _one, _temp),// 1.0 - cosi*cosi
				agal("mul", _temp, _temp, _eta),//(1.0 - cosi*cosi)*eta
				agal("mul", _temp, _temp, _eta),//(1.0 - cosi*cosi)*eta*eta
				agal("sub", _temp, _one, _temp),//cost2 = 1.0 - eta * eta * (1.0 - cosi*cosi);
				
				agal("neg", _incidence, _incidence+".xyz"), // -i = i
				agal("mul", _target, _target, _eta),//eta*cosi
				
				agal("abs", _temp2, _temp),//abs(cost2)
				agal("sqt", _temp2, _temp2),//sqrt(abs(cost2)
				agal("sub", _temp2, _target, _temp2),//(eta*cosi - sqrt(abs(cost2))
				agal("mul", _temp2, _temp2, _normal), //((eta*cosi - sqrt(abs(cost2))) * n)
				
				agal("mul", _target, _eta, _incidence),//eta*i 
				agal("add", _target, _target, _temp2),// t = eta*i + ((eta*cosi - sqrt(abs(cost2))) * n); 
				
				agal("sge", _temp, _temp, _zero),// if cost2 > 0 temp = 0 else 1
				agal("mul", _target, _target, _temp)
				
			].join("\n");
			return code;
		}
		
		/****************************************************************************
		* Fresnel Approximation
		* F(a) = F(0) + (1- cos(a))^5 * (1- F(0))	
		*
		*		float fast_fresnel(vec3 I, vec3 N, vec3 fresnelValues)
		*		{
		*			float bias = fresnelValues.x;
		*			float power = fresnelValues.y;
		*			float scale = 1.0 - bias;
		*			
		*			return bias + pow(1.0 - dot(I, N), power) * scale;
		*		}
		******************************************************************************/
		public static function fastFresnel(_target:String, _normal:String, _incidence:String, _fresnelValues:String, 
									_one:String, _temp:String):String{
			
			var code:String = [
				agal("dp3",_temp, _incidence, _normal), //dot(I, N)
				agal("sub", _temp, _one, _temp),//1.0 - dot(I, N)
				agal("pow", _temp, _temp, _fresnelValues+".y"),//pow(1.0 - dot(I, N), fresnelValues.y)
				
				agal("mov",_target, _fresnelValues+".x"),
				agal("sub", _target, _one, _target),// scale = 1.0 - fresnelValues.x;
				agal("mul", _target, _target, _temp),//pow(1.0 - dot(I, N), power) * scale
				agal("add", _target, _target, _fresnelValues+".x")// fresnelValues.x + pow(1.0 - dot(I, N), fresnelValues.y) * scale
			].join("\n");
			return code;
		}
		
		// fresnel for yogurtistan
		public static function fresnel(_target:String, _normal:String, _incidence:String, _power:String, 
										   _one:String):String{
			
			var code:String = [
				agal("dp3",_target, _incidence, _normal), //dot(I, N)
				agal("sub",_target, _one, _target),//1.0 - dot(I, N)
				agal("pow",_target, _target, _power),//pow(1.0 - dot(I, N), power)
				
				
			].join("\n");
			return code;
			
		}
		
		
	}
}
