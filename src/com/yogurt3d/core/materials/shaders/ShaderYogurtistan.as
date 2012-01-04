/*
* ShaderEnvMapFresnel.as
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

package com.yogurt3d.core.materials.shaders
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.yogurt3d.core.lights.ELightType;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.materials.base.Color;
	import com.yogurt3d.core.materials.shaders.base.EVertexAttribute;
	import com.yogurt3d.core.materials.shaders.base.Shader;
	import com.yogurt3d.core.materials.shaders.renderstate.EShaderConstantsType;
	import com.yogurt3d.core.materials.shaders.renderstate.ShaderConstants;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.core.utils.ShaderUtils;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	public class ShaderYogurtistan extends Shader
	{
	
		private var m_diffuseGradient		:TextureMap;
		private var m_ambientGradient		:TextureMap;
		private var m_colorMap				:TextureMap;
		private var m_specularMap			:TextureMap;
		private var m_rimMask				:TextureMap;
		private var m_specularMask			:TextureMap;
		private var m_emmisiveMask			:TextureMap;
		
		private var m_diffuseGradientConst	:ShaderConstants;
		private var m_colorMapConst			:ShaderConstants;
		private var m_ambientGradientConst	:ShaderConstants;
		private var m_specularMapConst		:ShaderConstants;
		private var m_rimMaskConst			:ShaderConstants;
		private var m_specularMaskConst		:ShaderConstants;
		private var m_emmisiveMaskConst		:ShaderConstants;
		private var m_alphaConst			:ShaderConstants = null;
		
		private var m_constants				:ShaderConstants;
		private var m_fresnelConst			:ShaderConstants;
		private var m_lambertConst			:ShaderConstants;
		private var m_colorConst			:ShaderConstants;
		
		private var m_opacity				:Number;	
		private var m_blendConstant			:Number;
		private var m_fspecPower			:Number;
		private var m_fRimPower				:Number;
		private var m_kRim					:Number;
		private var m_kSpec					:Number;
		private var m_ksColor				:Number;
		private var m_krColor				:Number;
		private var m_color					:Color;
		
		private var m_KSDirty:Boolean = false;
		private var m_ColorDirty:Boolean = false;
		private var m_KRDirty:Boolean = false;
		private var m_KSpecDirty:Boolean = false;
		private var m_EmmisiveDirty:Boolean = false;
		
		/**
		 * 
		 * 
		 * @author Yogurt3D Engine Core Team
		 * @company Yogurt3D Corp.
		 **/
		public function ShaderYogurtistan( _diffuseGradient:TextureMap,
										   _ambientGradient:TextureMap,
										   _emmisiveMask:TextureMap=null,
										   _colorMap:TextureMap=null,
										   _specularMap:TextureMap=null,
										   _rimMask:TextureMap=null,
										   _specularMask:TextureMap=null,
										   _color:Color=null,
										   _ks:Number=1.0,//if texture is used for ks, default=-1
										   _kr:Number=1.0,
										   _blendConstant:Number=1.5,
										   _fspecPower:Number=1.0,
										   _fRimPower:Number=2.0,
										   _kRim:Number=1.0, 
										   _kSpec:Number=1.0,
										   _opacity:Number=1.0)
		{
			super();
			key = "Yogurt3DOriginalsShaderYogurtistan";
			
			m_fspecPower = _fspecPower;
			m_fRimPower = _fRimPower;
			m_kRim = _kRim;
			m_kSpec = _kSpec;
			m_ksColor = _ks;
			m_krColor = _kr;
			if(_color == null)
				_color = new Color(1,1,1);
			m_color = _color;
			
			m_opacity = _opacity;
			m_blendConstant = _blendConstant;

			params.writeDepth 		= true;
			params.blendEnabled 	= true;
			params.blendSource 		= Context3DBlendFactor.SOURCE_ALPHA;
			params.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			params.culling			= Context3DTriangleFace.FRONT;
		
			params.requiresLight				= true;
		
			attributes.push( EVertexAttribute.POSITION, EVertexAttribute.UV, EVertexAttribute.NORMAL, EVertexAttribute.BONE_DATA);
			
			params.vertexShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.MVP_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(4, EShaderConstantsType.MODEL_TRANSPOSED));
			params.vertexShaderConstants.push(new ShaderConstants(8, EShaderConstantsType.BONE_MATRICES));
			
			// FRAGMENT CONSTANTS
			params.fragmentShaderConstants.push(new ShaderConstants(0, EShaderConstantsType.CAMERA_POSITION));
			params.fragmentShaderConstants.push(new ShaderConstants(1, EShaderConstantsType.LIGHT_POSITION));
			params.fragmentShaderConstants.push(new ShaderConstants(2, EShaderConstantsType.LIGHT_DIRECTION));
			params.fragmentShaderConstants.push(new ShaderConstants(4, EShaderConstantsType.LIGHT_COLOR));
			
			// half lambert constants: alpha beta gamma
			m_lambertConst				 				= new ShaderConstants(3,  EShaderConstantsType.CUSTOM_VECTOR);
			m_lambertConst.vector						= Vector.<Number>([ 0.5, 0.5, 1.0, m_kSpec  ]);
			params.fragmentShaderConstants.push(m_lambertConst);
			
			// up vector
			var _fragmentShaderConsts:ShaderConstants	= new ShaderConstants(5,  EShaderConstantsType.CUSTOM_VECTOR);
			_fragmentShaderConsts.vector				= Vector.<Number>([ 0.0, 1.0, 0.0, 1.0 ]);
			params.fragmentShaderConstants.push(_fragmentShaderConsts);
			
			// constants 
			m_constants 								= new ShaderConstants(6,  EShaderConstantsType.CUSTOM_VECTOR);
			m_constants.vector							= Vector.<Number>([ m_blendConstant, 0.0, 0.00000001, m_opacity ]);
			params.fragmentShaderConstants.push(m_constants);
			
			m_fresnelConst 								= new ShaderConstants(7,  EShaderConstantsType.CUSTOM_VECTOR);
			m_fresnelConst.vector						= Vector.<Number>([m_fspecPower, m_fRimPower ,  m_kRim, m_ksColor ]);
			params.fragmentShaderConstants.push(m_fresnelConst);
			
			m_colorConst 								= new ShaderConstants(8,  EShaderConstantsType.CUSTOM_VECTOR);
			m_colorConst.vector							= Vector.<Number>([color.r, color.g ,color.b, m_krColor ]);
			params.fragmentShaderConstants.push(m_colorConst);
			
			// Textures	
			m_diffuseGradientConst 							= new ShaderConstants(0, EShaderConstantsType.TEXTURE);
			//m_diffuseGradientConst.texture 					= m_diffuseGradient;
			params.fragmentShaderConstants.push(m_diffuseGradientConst);
			
			m_ambientGradientConst 							= new ShaderConstants(1, EShaderConstantsType.TEXTURE);
			//m_ambientGradientConst.texture 					= m_ambientGradient;
			params.fragmentShaderConstants.push(m_ambientGradientConst);
			
			diffuseGradient = _diffuseGradient;
			ambientGradient = _ambientGradient;
			colorMap = _colorMap;
			specularMap = _specularMap;
			rimMask = _rimMask;
			specularMask = _specularMask;
			emmisiveMask = _emmisiveMask;
					
		}
		
		public override function getProgram(_context3D:Context3D, _lightType:ELightType=null, _meshType:String = null):Program3D{
			
			if(m_KSDirty )
			{
				
				if(m_specularMask != null ){
					
					if( m_specularMaskConst == null )
					{
						m_specularMaskConst 						= new ShaderConstants(5, EShaderConstantsType.TEXTURE);
						params.fragmentShaderConstants.push(m_specularMaskConst);	
					}
					m_specularMaskConst.texture = m_specularMask;
				}else{
					
					if(m_specularMaskConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_specularMaskConst ), 1 );
						m_specularMaskConst = null;
					}
				}
				disposeShaders();
				m_KSDirty = false;
				
			}
			
			if(m_KRDirty )
			{
				
				if(m_rimMask != null ){
					
					if( m_rimMaskConst == null )
					{
						m_rimMaskConst 						= new ShaderConstants(4, EShaderConstantsType.TEXTURE);
						params.fragmentShaderConstants.push(m_rimMaskConst);	
					}
					m_rimMaskConst.texture = m_rimMask;
				}else{
					
					if(m_rimMaskConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_rimMaskConst ), 1 );
						m_rimMaskConst = null;
					}
				}
				disposeShaders();
				m_KRDirty = false;
				
			}
			
			if(m_KSpecDirty )
			{
				
				if(m_specularMap != null ){
					
					if( m_specularMapConst == null )
					{
						m_specularMapConst 						= new ShaderConstants(3, EShaderConstantsType.TEXTURE);
						params.fragmentShaderConstants.push(m_specularMapConst);	
					}
					m_specularMapConst.texture = m_specularMap;
				}else{
					
					if(m_specularMapConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_specularMapConst ), 1 );
						m_specularMapConst = null;
					}
				}
				disposeShaders();
				m_KSpecDirty = false;
				
			}
			
			if(m_ColorDirty )
			{
				if(m_colorMap != null ){
					
					if(m_colorMap.transparent){
					
						if(m_alphaConst == null){
							m_alphaConst = new ShaderConstants(9, EShaderConstantsType.CUSTOM_VECTOR);
							m_alphaConst.vector = Vector.<Number>([0.2, 0, 0, 0 ]);
							params.fragmentShaderConstants.push(m_alphaConst);
						}
					}
					
					if( m_colorMapConst == null )
					{
						m_colorMapConst 	= new ShaderConstants(2, EShaderConstantsType.TEXTURE);
						params.fragmentShaderConstants.push(m_colorMapConst);	
					}
					m_colorMapConst.texture = m_colorMap;
				}else{
					
					if(m_colorMapConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_colorMapConst ), 1 );
						m_colorMapConst = null;
					}
					
					if(m_alphaConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_alphaConst ), 1 );
						m_alphaConst = null;
					}
				}
				disposeShaders();
				m_ColorDirty = false;
				
			}
			if(m_EmmisiveDirty )
			{
				
				if(m_emmisiveMask != null ){
					
					if( m_emmisiveMaskConst == null )
					{
						m_emmisiveMaskConst 	= new ShaderConstants(6, EShaderConstantsType.TEXTURE);
						params.fragmentShaderConstants.push(m_emmisiveMaskConst);	
					}
					m_emmisiveMaskConst.texture = m_emmisiveMask;
				}else{
					
					if(m_emmisiveMaskConst != null){
						params.fragmentShaderConstants.splice( params.fragmentShaderConstants.indexOf( m_emmisiveMaskConst ), 1 );
						m_emmisiveMaskConst = null;
					}
				}
				disposeShaders();
				m_EmmisiveDirty = false;
				
			}
			
			key = "Yogurt3DOriginalsShaderYogurtistan" + ((m_specularMask)?"WithSMask":"") 
				+ ((m_specularMask && m_specularMask.mipmap)?"SpecMaskMip":"")
				+ ((m_rimMask)?"WithRMask":"")
				+ ((m_rimMask && m_rimMask.mipmap)?"RimMip":"")
				+ ((m_specularMap)?"WithSMap":"")
				+ ((m_specularMap && m_specularMap.mipmap)?"SpecMip":"")
				+ ((m_colorMap)?"WithCMap":"")
				+ ((m_colorMap && m_colorMap.mipmap)?"ColorMip":"")
				+ ((m_colorMap && m_colorMap.transparent)?"AlphaTexture":"")
				+ ((m_emmisiveMask)?"WithEmmisive":"")
				+ ((m_emmisiveMask && m_emmisiveMask.mipmap)?"EmmMip":"");
			return super.getProgram( _context3D, _lightType, _meshType );
		}
		
		
		public function get emmisiveMask():TextureMap{
			return m_emmisiveMask;
		}
		public function set emmisiveMask(_value:TextureMap):void{
			m_EmmisiveDirty = true;
			m_emmisiveMask = _value;
			
		}
		
		public function get color():Color{
			return m_color;
		}
		public function set color(_value:Color):void{
			m_color = _value;
			m_colorConst.vector[0] = m_color.r;
			m_colorConst.vector[1] = m_color.g;
			m_colorConst.vector[2] = m_color.b;
		}
		
		public function get specularMap():TextureMap{
			return m_specularMap;
		}
		public function set specularMap(_value:TextureMap):void{
			m_KSpecDirty = true;
			m_specularMap = _value;
			
		}
	
		public function get specularMask():TextureMap{
			return m_specularMask;
		}
		public function set specularMask(_value:TextureMap):void{
		
			m_specularMask = _value;
			m_KSDirty = true;
		}
		
		public function get rimMask():TextureMap{
			return m_rimMask;
		}
		public function set rimMask(_value:TextureMap):void{
			m_rimMask = _value;
			m_KRDirty = true;
		}
		
		public function get krColor():Number{
			return m_krColor;
		}
		
		public function set krColor(_value:Number):void{
			m_krColor = _value;
			m_colorConst.vector[3] = m_krColor;
		}
		
		public function get ksColor():Number{
			return m_ksColor;
		}
		
		public function set ksColor(_value:Number):void{
			m_ksColor = _value;
			m_fresnelConst.vector[3] = m_ksColor;
		}
		
		public function get kSpec():Number{
			return m_kSpec;
		}
		public function set kSpec(_value:Number):void{
			m_kSpec = _value;
			m_lambertConst.vector[3] = m_kSpec;
		}
	
		public function get fRimPower():Number{
			return m_fRimPower;
		}
		public function set fRimPower(_value:Number):void{
			m_fRimPower = _value;
			m_fresnelConst.vector[1] = _value;
		}
		
		public function get kRim():Number{
			return m_kRim;
		}
		public function set kRim(_value:Number):void{
			m_kRim = _value;
			m_fresnelConst.vector[2] = _value;
		}
	
		public function get fspecPower():Number{
			return m_fspecPower;
		}
		public function set fspecPower(_value:Number):void{
			m_fspecPower = _value;
			m_fresnelConst.vector[0] = m_fspecPower;
		}
			
		public function get blendConstant():Number{
			return m_constants.vector[0];
		}
		public function set blendConstant(_value:Number):void{
			m_blendConstant = _value;
			m_constants.vector[0] = _value;
		}
		
		public function get colorMap():TextureMap{
			return m_colorMap;
		}
		
		public function set colorMap(_value:TextureMap):void{
			m_colorMap = _value;
			m_ColorDirty = true;
		}
		
		public function get ambientGradient():TextureMap{
			return m_ambientGradient;
		}
		public function set ambientGradient(_value:TextureMap):void{
			m_ambientGradient = _value;
			m_ambientGradientConst.texture = m_ambientGradient;
		}
		
		public function get diffuseGradient():TextureMap{
			return m_diffuseGradient;
		}
		public function set diffuseGradient(_value:TextureMap):void{
			m_diffuseGradient = _value;
			m_diffuseGradientConst.texture = m_diffuseGradient;
		}
		
		public function get opacity():Number{
			return m_opacity;
		}
		public function set opacity(_val:Number):void{
			m_opacity = _val;
			m_constants.vector[3]	= m_opacity;
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
				
				// Step 2: Warping (lambert)
				((!diffuseGradient.mipmap)?"tex ft0 ft2.xx fs0<2d,clamp,linear>":("tex ft0 ft2.xx fs0<2d,clamp,linear,miplinear>")),
				"mul ft0 ft0 fc6.x",
				
				// Step 3: color of light * Warping (lambert)
				"mul ft0 ft0 fc4",
				
				// Step 4: ambient term a(dot(n.u) )
				"dp3 ft2.y ft1.xyz fc5.xyz", //dot(n.u)
				((!ambientGradient.mipmap)?"tex ft5 ft2.yy fs1<2d,clamp,linear>":("tex ft5 ft2.yy fs1<2d,clamp,linear,miplinear>")),
				"add ft0 ft0 ft5",// a(n.u) + color of light * Warping (lambert)
				
				// Step 5: Get Color map
				(m_colorMap != null?
					((!colorMap.mipmap)?"tex ft4 v2 fs2<2d,wrap,linear>":("tex ft4 v2 fs2<2d,wrap,linear,miplinear>")):
					("mov ft4.w fc6.w\n" + "mov ft4 fc8")
				),
				((m_colorMap != null && m_colorMap.transparent)?"sub ft2.x ft4.w fc9.x\nkil ft2.x":""),
				"mul ft0.xyz ft0.xyz ft4.xyz",// ft0 = view independent
				
				// View Dependent
				// Step 6: Phong Specular Term
				ShaderUtils.reflectionVector("ft4", "fc2", "ft1"),// ft4= reflect vector
				"dp3 ft2.x ft7.xyz ft4.xyz",// dot(v.r)
				
				// TODO : SPECULARDAN AL
				
				(m_specularMap != null?
					((!m_specularMap.mipmap)?"tex ft4 v2 fs3<2d,wrap,linear>":("tex ft4 v2 fs3<2d,wrap,linear>,miplinear>")):
					"mov ft4.x fc3.w"
					),// get kspec from texture or number?
				"pow ft2.z ft2.x ft4.x",//pow(dot(v.r), kspec)
				
				// if L.n > 0 max (0, pow(dot(n.l), kspec))
				"max ft3.x fc6.y ft2.z", // max (0, pow(dot(v.r), kspec))
				"sge ft3.z ft2.x fc6.z",//dot(v.r)
				"mul ft3.x ft3.x ft3.z",// ft3.x = phong specular term
		
				ShaderUtils.fresnel("ft3.y","ft1","ft7","fc7.x","fc5.w"),//fs = DFT
				"add ft3.y ft3.y fc3.x",// fs = DFT + 0.5
				"mul ft3.y ft3.x ft3.y",// fs * pow(dot(v.r), kspec)
				
				"pow ft3.x ft2.x fc7.z",//(pow(dot(v.r), krim)
				"max ft3.x fc6.y ft3.x", // max (0, pow(dot(v.r), krim))
				"sge ft3.z ft2.x fc6.z",//dot(v.r)
				"mul ft3.x ft3.x ft3.z",// ft3.x = rim specular
				
				ShaderUtils.fresnel("ft3.w","ft1","ft7","fc7.y","fc5.w"),//fr = DFT
				
				(m_rimMask != null?
					((!m_rimMask.mipmap)?"tex ft6 v2 fs4<2d,clamp,linear>":("tex ft6 v2 fs4<2d,clamp,linear,miplinear>")):
					"mov ft6.x fc8.w"),
					
				"mul ft3.w ft3.w ft6.x",// fr * kr
				"mul ft3.z ft3.x ft3.w", //fr * kr * (pow(dot(v.r), krim)
							
				"max ft3.x ft3.y ft3.z", 
				"mul ft1 fc4 ft3.x",// * c 
				(m_specularMask != null?
					(((!m_specularMask.mipmap)?"tex ft6 v2 fs5<2d,clamp,linear>\n":("tex ft6 v2 fs5<2d,clamp,linear,miplinear>\n"))+
					"mul ft1 ft6.x ft1"):
					"mul ft1 fc7.w ft1"
					),// * ks: use color or texture // ft1: view dependent
			
				"mul ft6 ft3.w ft5",
				"mul ft6 ft6 ft2.y",// ft6 : ambien based view dependent
				
				"add ft1 ft6 ft1",// ft6: complete view dependent
				"add ft0 ft0 ft1",// result
				
				(this.emmisiveMask != null?
					((!emmisiveMask.mipmap)?"tex ft6 v2 fs6<2d,clamp,linear>\n":("tex ft6 v2 fs6<2d,clamp,linear,miplinear>\n"))+
					"add ft0 ft0 ft6":""),
				
				"mov ft0.w fc6.w",//set opacity
				"mov oc ft0"
				
			].join("\n");
				
			return new AGALMiniAssembler().assemble(AGALMiniAssembler.FRAGMENT, _fragmentShader);
		}

	}
}