/*
 * SceneObjectRenderable.as
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
 
 
package com.yogurt3d.core.sceneobjects {
	
	import com.yogurt3d.core.geoms.interfaces.IMesh;
	import com.yogurt3d.core.helpers.boundingvolumes.AxisAlignedBoundingBox;
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	import com.yogurt3d.core.transformations.Transformation;
	import com.yogurt3d.core.utils.MatrixUtils;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Matrix3D;
	import flash.geom.Utils3D;

	/**
	 * <strong>SceneObjectRenderable</strong> interface abstract type.
 	 * 
 	 * 
  	 * @author Yogurt3D Engine Core Team
  	 * @company Yogurt3D Corp.
  	 **/
	public class SceneObjectRenderable extends SceneObject
	{
		use namespace YOGURT3D_INTERNAL;
		
		public			  var castShadows			:Boolean 	= false;
		
		public			  var receiveShadows		:Boolean 	= false;

		YOGURT3D_INTERNAL var m_geometry			:IMesh;
		YOGURT3D_INTERNAL var m_material			:Material;
		YOGURT3D_INTERNAL var m_culling				:String 	= Context3DTriangleFace.BACK;
		
		YOGURT3D_INTERNAL var m_isInFrustum			:Boolean 	= false;
		
		private 		  var projectedVectices		:Vector.<Number>;
		
		private 		  var projectedUV			:Vector.<Number>;
		
		private 		  var m_drawWireFrame		:Boolean	= false;
		
		
		public function SceneObjectRenderable(_initInternals:Boolean = true)
		{
			super(_initInternals);
		}
		
		public function get wireframe():Boolean{
			return m_drawWireFrame;
		}
		
		public function set wireframe( _value:Boolean ):void{
			m_drawWireFrame = _value;
		}

		Y3DCONFIG::DEBUG
		{
			YOGURT3D_INTERNAL function drawWireFrame(_matrix:Matrix3D, _viewport:Viewport):void{
				
				if( m_drawWireFrame )
				{
					var matrix:Matrix3D = MatrixUtils.TEMP_MATRIX;
					matrix.copyFrom( _matrix );
					matrix.prepend( transformation.matrixGlobal );
					
					if( projectedVectices == null || projectedVectices.length != geometry.subMeshList[0].vertexCount * 2)
					{
						projectedVectices = new Vector.<Number>(geometry.subMeshList[0].vertexCount * 2);
					}
					
					if( projectedUV == null || projectedUV.length != geometry.subMeshList[0].vertexCount * 3)
					{
						projectedUV = new Vector.<Number>(geometry.subMeshList[0].vertexCount * 3);
					}
					
					Utils3D.projectVectors( matrix, geometry.subMeshList[0].vertices,projectedVectices,projectedUV);
					
					_viewport.graphics.lineStyle(1,0xff0000);
					
					for( var i:int = 0 ; i < geometry.subMeshList[0].triangleCount; i++ )
					{
						var i1:uint = geometry.subMeshList[0].indices[ i * 3 + 0 ];
						var i2:uint = geometry.subMeshList[0].indices[ i * 3 + 1 ];
						var i3:uint = geometry.subMeshList[0].indices[ i * 3 + 2 ];
						
						var x1:Number = projectedVectices[i1*2];
						var y1:Number = projectedVectices[i1*2+1];
						
						var x2:Number = projectedVectices[i2*2];
						var y2:Number = projectedVectices[i2*2+1];
						
						var x3:Number = projectedVectices[i3*2];
						var y3:Number = projectedVectices[i3*2+1];
						
						_viewport.graphics.moveTo( x1, y1 );
						_viewport.graphics.lineTo( x2, y2 );
						_viewport.graphics.lineTo( x3, y3 );
						_viewport.graphics.lineTo( x1, y1 );
					}
				}
								
					
				
			}
		}
		/**
		 * @inheritDoc
		 * */
		public function get geometry():IMesh
		{
			return m_geometry;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function set geometry(_value:IMesh):void
		{
			m_geometry = _value;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function get material():Material
		{
			return m_material;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function set material(_value:Material):void
		{
			if( m_material != _value )
			{
				//if( m_material )
				//{
					//m_material.onOpacityChanged.remove( opacityChanged );
					//if( "onAlphaTextureChanged" in m_material )
					//{
					//	Object(m_material).onAlphaTextureChanged.remove( opacityChanged );
					//}
				//}
				m_material = _value;
				//m_material.onOpacityChanged.add( opacityChanged );
				//if( "onAlphaTextureChanged" in m_material )
				//{
				//	Object(m_material).onAlphaTextureChanged.add( opacityChanged );
				//}
				//opacityChanged( );
			}
		}
		
		public function get culling() : String {
			return m_culling;
		}
		
		public function set culling(_value : String) : void {
			m_culling = _value;
		}		
	
		
		override protected function trackObject():void
		{
			IDManager.trackObject(this, SceneObjectRenderable);
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
		}

		
		override public function instance():*
		{
			var _sceneObjectCopy:SceneObjectRenderable 		= new SceneObjectRenderable();
			
			_sceneObjectCopy.geometry	 			= m_geometry;
			_sceneObjectCopy.m_material				= m_material;
			_sceneObjectCopy.visible 				= visible;
			_sceneObjectCopy.interactive 				= interactive;
			_sceneObjectCopy.pickEnabled 				= pickEnabled;
			
			_sceneObjectCopy.castShadows 				= castShadows;
			_sceneObjectCopy.receiveShadows 			= receiveShadows;
			
			_sceneObjectCopy.m_transformation = Transformation(m_transformation.clone());
			_sceneObjectCopy.m_transformation.m_ownerSceneObject = _sceneObjectCopy;
			
			return _sceneObjectCopy;
		}
		override public function clone():IEngineObject {			
			var _sceneObjectCopy:SceneObjectRenderable 		= new SceneObjectRenderable();
			_sceneObjectCopy.geometry	 			= geometry;
			_sceneObjectCopy.m_material				= m_material;
			_sceneObjectCopy.visible 				= visible;
			_sceneObjectCopy.interactive 				= interactive;
			_sceneObjectCopy.pickEnabled 				= pickEnabled;
			
			_sceneObjectCopy.castShadows 				= castShadows;
			_sceneObjectCopy.receiveShadows 			= receiveShadows;
			
			_sceneObjectCopy.m_transformation = Transformation(m_transformation.clone());
			_sceneObjectCopy.m_transformation.m_ownerSceneObject = _sceneObjectCopy;
			
			return _sceneObjectCopy;
		}
		
		public override function dispose():void{
			m_geometry = null;
			m_material = null;
			
			super.dispose();
		}
		
		public override function disposeDeep():void{
			if( m_geometry )
			{
				m_geometry.disposeDeep();
				m_geometry = null;
			}
			if( m_material )
			{
				m_material.disposeDeep();
				m_material = null;
			}
			super.disposeDeep();
		}
		
		public override function disposeGPU():void{
			
			m_geometry.disposeGPU();
			m_material.disposeGPU();
			
			super.disposeGPU();
		}
		
		public override function get axisAlignedBoundingBox():AxisAlignedBoundingBox
		{
			if(!m_aabb)
			{
				//AxisAlignedBoundingBox(geomBox.m_minInitial, geomBox.m_maxInitial, transformation); geometry.axisAlignedBoundingBox.clone() as AxisAlignedBoundingBox
				m_aabb = new AxisAlignedBoundingBox(geometry.axisAlignedBoundingBox.m_minInitial.clone(), geometry.axisAlignedBoundingBox.m_maxInitial.clone(), transformation);
			}
			return m_aabb;
		}
		public override function get cumulativeAxisAlignedBoundingBox():AxisAlignedBoundingBox
		{
			var len:uint = (children)?children.length:0;
			
			if( len )
			{
				if(m_reinitboundingVolumes)
				{
					var geomBox:AxisAlignedBoundingBox = geometry.axisAlignedBoundingBox;
					if(!m_aabbCumulative)
					{
						m_aabbCumulative = new AxisAlignedBoundingBox(geomBox.m_minInitial.clone(), geomBox.m_maxInitial.clone(), transformation);
						//m_aabbCumulative.update();
					}
					else	
						m_aabbCumulative.setInitialMinMax(geomBox.m_minInitial.clone(), geomBox.m_maxInitial.clone(),transformation);
					
					for(var i:int; i < len; i++)
					{
						var child:SceneObject = children[i];
						
						m_aabbCumulative.merge( child.cumulativeAxisAlignedBoundingBox );	
					}
					
					m_reinitboundingVolumes = false;
					
				}
				return m_aabbCumulative;
				
			}else
			{
				if( m_reinitboundingVolumes )
				{
					if( m_aabbCumulative )
					{
						m_aabbCumulative.dispose();
					}
					m_aabbCumulative = null;
					m_reinitboundingVolumes = false;
				}
				return axisAlignedBoundingBox;	
				
			}
			
		}
	}
}
