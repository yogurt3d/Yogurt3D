/*
 * AxisAlignedBoundingBox.as
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
 
 
package com.yogurt3d.core.helpers.boundingvolumes {
	import com.yogurt3d.core.managers.idmanager.IDManager;
	import com.yogurt3d.core.namespaces.YOGURT3D_INTERNAL;
	import com.yogurt3d.core.objects.EngineObject;
	import com.yogurt3d.core.objects.interfaces.IEngineObject;
	import com.yogurt3d.core.transformations.Transformation;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.osflash.signals.Signal;
	
	use namespace YOGURT3D_INTERNAL;
	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class AxisAlignedBoundingBox extends EngineObject
	{
		YOGURT3D_INTERNAL var m_minLocal				  :Vector3D = new Vector3D();
		YOGURT3D_INTERNAL var m_maxLocal				  :Vector3D = new Vector3D();
		YOGURT3D_INTERNAL var m_centerLocal			  :Vector3D;
		YOGURT3D_INTERNAL var m_halfSizeLocal	      :Vector3D  
		YOGURT3D_INTERNAL var m_sizeLocal	          :Vector3D;
		
		YOGURT3D_INTERNAL var m_minGlobal				  :Vector3D = new Vector3D();
		YOGURT3D_INTERNAL var m_maxGlobal				  :Vector3D = new Vector3D();
		YOGURT3D_INTERNAL var m_centerGlobal			  :Vector3D;
		YOGURT3D_INTERNAL var m_halfSizeGlobal	      :Vector3D  
		YOGURT3D_INTERNAL var m_sizeGlobal	          :Vector3D;
		
		
		YOGURT3D_INTERNAL var m_minInitial	    :Vector3D;
		YOGURT3D_INTERNAL var m_maxInitial	    :Vector3D;
		YOGURT3D_INTERNAL var m_centerInitial	:Vector3D;
		YOGURT3D_INTERNAL var m_halfSizeInitial :Vector3D;
		YOGURT3D_INTERNAL var m_sizeInitial	    :Vector3D;
		
		YOGURT3D_INTERNAL var m_minMaxDirtyLocal	      :Boolean = true;
		YOGURT3D_INTERNAL var m_centerHalfDirtyLocal	  :Boolean = true;
		YOGURT3D_INTERNAL var m_cornersDirtyLocal	      :Boolean = true;
		
		YOGURT3D_INTERNAL var m_minMaxDirtyGlobal	      :Boolean = true;
		YOGURT3D_INTERNAL var m_centerHalfDirtyGlobal	  :Boolean = true;
		YOGURT3D_INTERNAL var m_cornersDirtyGlobal	      :Boolean = true;
		
/*		YOGURT3D_INTERNAL static var FLAG_DIRTY_MINMAX           :int = 1;
		YOGURT3D_INTERNAL static var FLAG_DIRTY_CENTERHALFSIZE   :int = 2;
		YOGURT3D_INTERNAL static var FLAG_DIRTY_SIZE             :int = 4;
		YOGURT3D_INTERNAL static var FLAG_DIRTY_CORNERS          :int = 8;*/
		//YOGURT3D_INTERNAL static var FLAG_DIRTY_SIZE     :int = 8;
		
		//YOGURT3D_INTERNAL var m_dirty	          :int = int.MAX_VALUE;
		
		//YOGURT3D_INTERNAL var m_cornersDirty	  :Boolean = true;
		
		//private var m_transformationLocal		  :Matrix3D// = new Matrix3D();
		//private var m_transformationGlobal		  :Matrix3D// = new Matrix3D();
		private var m_sceneObjectTransformation	  :Transformation;

		//private var m_vectors					  :Vector.<Number>;
		//private var m_transformedVectors		  :Vector.<Number>;
		//private var m_zeroVector				  :Vector3D = new Vector3D();
		
	
		
		YOGURT3D_INTERNAL var m_cornersLocal			  :Vector.<Vector3D>;
		YOGURT3D_INTERNAL var m_cornersGlobal			  :Vector.<Vector3D>;
		
		public function AxisAlignedBoundingBox(_min:Vector3D, _max:Vector3D, _trans:Transformation = null)
		{
			m_minInitial = _min;
			m_maxInitial = _max;
			
			if(_trans)
			{
				m_sceneObjectTransformation = _trans;
				_trans.onChange.add(seekOwnerTransformationChange);
				
			}else
			{
				m_minLocal.copyFrom(_min);
				m_maxLocal.copyFrom(_max);
				
				m_minGlobal.copyFrom(_min);
				m_maxGlobal.copyFrom(_max);
				m_minMaxDirtyLocal = false;
				m_minMaxDirtyGlobal = false;
			}
			super(true);
		}
		
		private function seekOwnerTransformationChange( _trans:Transformation ):void
		{
			m_sceneObjectTransformation = _trans;
			if(_trans.m_isLocalDirty)
				updateLocal();
			if(_trans.m_isGlobalDirty)	
				updateGlobal();
		}
		
		public function get minLocal():Vector3D
		{
			if(m_minMaxDirtyLocal)
				updateMinMax(false);
				
			return m_minLocal;
		}
		
		public function get maxLocal():Vector3D
		{
			if(m_minMaxDirtyLocal)
				updateMinMax(false);
			
			return m_maxLocal;
		}
		
		public function get minGlobal():Vector3D
		{
			if(m_minMaxDirtyGlobal)
				updateMinMax();
			
			return m_minGlobal;
		}
		
		public function get maxGlobal():Vector3D
		{
			if(m_minMaxDirtyGlobal)
				updateMinMax();
			
			return m_maxGlobal;
		}
		
		public function get initialMin():Vector3D
		{
			
			return m_minInitial;
		}
		
		public function get initialMax():Vector3D
		{	
			return m_maxInitial;
		}
		
		
		
		public function get centerLocal():Vector3D
		{
			if(m_centerHalfDirtyLocal)
				updateCenterHalf(false);
				
			return m_centerLocal;
		}
		
		public function get halfSizeLocal():Vector3D
		{
			if(m_centerHalfDirtyLocal)
				updateCenterHalf(false);
				
			return m_halfSizeLocal;
		}
		
				
		public function get sizeLocal():Vector3D
		{
			if(m_centerHalfDirtyLocal)
				updateCenterHalf(false);
			
			return m_sizeLocal;
		}
		
		
		public function get centerGlobal():Vector3D
		{
			if(m_centerHalfDirtyGlobal)
				updateCenterHalf();
			
			return m_centerGlobal;
		}
		
		public function get halfSizeGlobal():Vector3D
		{
			if(m_centerHalfDirtyGlobal)
				updateCenterHalf();
			
			return m_halfSizeGlobal;
		}
		
		
		public function get sizeGlobal():Vector3D
		{
			if(m_centerHalfDirtyGlobal)
				updateCenterHalf();
			
			return m_sizeGlobal;
		}
		
		public function setInitialMinMax(_min:Vector3D, _max:Vector3D, _trans:Transformation):void
		{
			m_minInitial.setTo(_min.x, _min.y, _min.z);
			m_maxInitial.setTo(_max.x, _max.y, _max.z);
			m_sceneObjectTransformation = _trans;			
		}
		
		public function updateCenterHalf(_updateGlobally:Boolean = true):void
		{
			var tempCe:Vector3D;
			var tempHa:Vector3D;
			var tempSi:Vector3D;
			var raw:Vector.<Number>;
			
			if(!m_centerInitial)
			{
				m_centerInitial = m_maxInitial.add( m_minInitial );
			    m_centerInitial.scaleBy(.5);
				
				m_sizeInitial = m_maxInitial.subtract( m_minInitial );
				m_halfSizeInitial = new Vector3D(m_sizeInitial.x*0.5, m_sizeInitial.y*0.5, m_sizeInitial.z*0.5);
			}
			
			if(_updateGlobally)
			{
				if(!m_centerGlobal)
				{
					m_centerGlobal = new Vector3D();
				    m_sizeGlobal = new Vector3D();
					m_halfSizeGlobal = new Vector3D();
				}
				if(!m_minMaxDirtyGlobal)
				{
					m_centerGlobal.setTo( (m_maxGlobal.x+m_minGlobal.x)*0.5, (m_maxGlobal.y+m_minGlobal.y)*0.5, (m_maxGlobal.z+m_minGlobal.z)*0.5 );
					m_sizeGlobal.setTo(m_maxGlobal.x-m_minGlobal.x, m_maxGlobal.y-m_minGlobal.y, m_maxGlobal.z-m_minGlobal.z);
					m_halfSizeGlobal.setTo( m_sizeGlobal.x*0.5, m_sizeGlobal.y*0.5, m_sizeGlobal.z*0.5 );
					
					m_centerHalfDirtyGlobal = false;
					return;
				}
				tempCe = m_centerGlobal;
				tempHa = m_halfSizeGlobal;
				tempSi = m_sizeGlobal;
				raw = m_sceneObjectTransformation.matrixGlobal.rawData;
				m_centerHalfDirtyGlobal = false;
			}else
			{
				if(!m_centerLocal)
				{
					m_centerLocal = new Vector3D();
					m_sizeLocal = new Vector3D();
					m_halfSizeLocal = new Vector3D();
				}
				
				if(!m_minMaxDirtyLocal)
				{
					m_centerLocal.setTo( (m_maxLocal.x+m_minLocal.x)*0.5, (m_maxLocal.y+m_minLocal.y)*0.5, (m_maxLocal.z+m_minLocal.z)*0.5 );
					m_sizeLocal.setTo(m_maxLocal.x-m_minLocal.x, m_maxLocal.y-m_minLocal.y, m_maxLocal.z-m_minLocal.z);
					m_halfSizeLocal.setTo( m_sizeLocal.x*0.5, m_sizeLocal.y*0.5, m_sizeLocal.z*0.5 );
					
					m_centerHalfDirtyLocal = false;
					return;
				}
				
				
				tempCe = m_centerLocal;
				tempHa = m_halfSizeLocal;
				tempSi = m_sizeLocal;
				raw = m_sceneObjectTransformation.matrixLocal.rawData;
				m_centerHalfDirtyLocal = false;
			}
				
			
			
			tempCe.setTo( raw[12], raw[13], raw[14]);
			tempHa.setTo( 0, 0, 0);
			
			var centerX:Number = m_centerInitial.x;
			var centerY:Number = m_centerInitial.y;
			var centerZ:Number = m_centerInitial.z;
			
			var halfSizeX:Number = m_halfSizeInitial.x;
			var halfSizeY:Number = m_halfSizeInitial.y;
			var halfSizeZ:Number = m_halfSizeInitial.z;
			
			var xOfAxis:Number = raw[0];
			var yOfAxis:Number = raw[4];
			var zOfAxis:Number = raw[8];
			
			tempCe.x += xOfAxis * centerX + yOfAxis * centerY + zOfAxis * centerZ;
			tempHa.x += Math.abs(xOfAxis) * halfSizeX + Math.abs(yOfAxis) * halfSizeY + Math.abs(zOfAxis) * halfSizeZ ;

			xOfAxis  = raw[1];
			yOfAxis  = raw[5];
			zOfAxis  = raw[9];
			
			tempCe.y += xOfAxis * centerX + yOfAxis * centerY + zOfAxis * centerZ;
			tempHa.y += Math.abs(xOfAxis) * halfSizeX + Math.abs(yOfAxis) * halfSizeY + Math.abs(zOfAxis) * halfSizeZ;			
			
			xOfAxis  = raw[2];
			yOfAxis  = raw[6];
			zOfAxis  = raw[10];
			
			tempCe.z += xOfAxis * centerX + yOfAxis * centerY + zOfAxis * centerZ;
			tempHa.z += Math.abs(xOfAxis) * halfSizeX + Math.abs(yOfAxis) * halfSizeY + Math.abs(zOfAxis) * halfSizeZ;
			
			tempSi.setTo(tempHa.x*2, tempHa.y*2, tempHa.z*2);
		
		}
		
		public function updateMinMax(_updateGlobally:Boolean = true):void
		{
			// if center and half-size already updated (not dirty) use it 
			var tempMin:Vector3D;
			var tempMax:Vector3D;
			var raw:Vector.<Number>;
			if(_updateGlobally)
			{
				if(!m_centerHalfDirtyGlobal)
				{
					m_maxGlobal.setTo( m_centerGlobal.x+m_halfSizeGlobal.x, m_centerGlobal.y+m_halfSizeGlobal.y, m_centerGlobal.z+m_halfSizeGlobal.z );			
					m_minGlobal.setTo( m_centerGlobal.x-m_halfSizeGlobal.x, m_centerGlobal.y-m_halfSizeGlobal.y, m_centerGlobal.z-m_halfSizeGlobal.z );
					m_minMaxDirtyGlobal = false;
					return;
				}
				
				tempMin = m_minGlobal;
				tempMax = m_maxGlobal;
			    raw = m_sceneObjectTransformation.matrixGlobal.rawData;
				m_minMaxDirtyGlobal = false;
				
			}else
			{
				if(!m_centerHalfDirtyLocal)
				{
					m_maxLocal.setTo( m_centerLocal.x+m_halfSizeLocal.x, m_centerLocal.y+m_halfSizeLocal.y, m_centerLocal.z+m_halfSizeLocal.z );			
					m_minLocal.setTo( m_centerLocal.x-m_halfSizeLocal.x, m_centerLocal.y-m_halfSizeLocal.y, m_centerLocal.z-m_halfSizeLocal.z );
					m_minMaxDirtyLocal = false;
					return;
				}
				
				tempMin = m_minLocal;
				tempMax = m_maxLocal;
				raw = m_sceneObjectTransformation.matrixLocal.rawData;
				m_minMaxDirtyLocal = false;
			}
			
			
			
			var minX:Number = m_minInitial.x;
			var minY:Number = m_minInitial.y;
			var minZ:Number = m_minInitial.z;
			
			var maxX:Number = m_maxInitial.x;
			var maxY:Number = m_maxInitial.y;
			var maxZ:Number = m_maxInitial.z;
			
			var resMinX:Number = raw[12];
			var resMinY:Number = raw[13];
			var resMinZ:Number = raw[14];
			
			var resMaxX:Number = resMinX;
			var resMaxY:Number = resMinY;
			var resMaxZ:Number = resMinZ;
			
/*			m_max.setTo( raw[12], raw[13], raw[14]);
			m_min.setTo( raw[12], raw[13], raw[14]);*/
			
			var xOfAxis:Number = raw[0];
			var yOfAxis:Number = raw[4];
			var zOfAxis:Number = raw[8];
			
			var minProduct:Number = xOfAxis * minX;
			var maxProduct:Number = xOfAxis * maxX;
			
			if(minProduct < maxProduct){resMinX += minProduct;resMaxX += maxProduct;}else{resMaxX += minProduct;resMinX += maxProduct;}
			
			
			minProduct = yOfAxis * minY;
			maxProduct = yOfAxis * maxY;
			if(minProduct < maxProduct){resMinX += minProduct;resMaxX += maxProduct;}else{resMaxX += minProduct;resMinX += maxProduct;}
			
			minProduct = zOfAxis * minZ;
			maxProduct = zOfAxis * maxZ;
			if(minProduct < maxProduct){resMinX += minProduct;resMaxX += maxProduct;}else{resMaxX += minProduct;resMinX += maxProduct;}
			
			
			
			xOfAxis  = raw[1];
			yOfAxis  = raw[5];
			zOfAxis  = raw[9];
			
			minProduct = xOfAxis * minX;
			maxProduct = xOfAxis * maxX;
			if(minProduct < maxProduct){resMinY += minProduct;resMaxY += maxProduct;}else{resMaxY += minProduct;resMinY += maxProduct;}
			
			minProduct = yOfAxis * minY;
			maxProduct = yOfAxis * maxY;
			
			if(minProduct < maxProduct){resMinY += minProduct;resMaxY += maxProduct;}else{resMaxY += minProduct;resMinY += maxProduct;}
			
			minProduct = zOfAxis * minZ;
			maxProduct = zOfAxis * maxZ;
			if(minProduct < maxProduct){resMinY += minProduct;resMaxY += maxProduct;}else{resMaxY += minProduct;resMinY += maxProduct;}
			
			
			xOfAxis  = raw[2];
			yOfAxis  = raw[6];
			zOfAxis  = raw[10];
			
			minProduct = xOfAxis * minX;
			maxProduct = xOfAxis * maxX;
			if(minProduct < maxProduct){resMinZ += minProduct;resMaxZ += maxProduct;}else{resMaxZ += minProduct;resMinZ += maxProduct;}
			
			minProduct = yOfAxis * minY;
			maxProduct = yOfAxis * maxY;
			
			if(minProduct < maxProduct){resMinZ += minProduct;resMaxZ += maxProduct;}else{resMaxZ += minProduct;resMinZ += maxProduct;}
			
			minProduct = zOfAxis * minZ;
			maxProduct = zOfAxis * maxZ;
			if(minProduct < maxProduct){resMinZ += minProduct;resMaxZ += maxProduct;}else{resMaxZ += minProduct;resMinZ += maxProduct;}
			
			tempMax.setTo( resMaxX, resMaxY, resMaxZ);
			tempMin.setTo( resMinX, resMinY, resMinZ);
		
		}
	
		


		
		public function get cornersLocal():Vector.<Vector3D>
		{
			if(	!m_cornersLocal	)
			{
				m_cornersLocal 			 = new Vector.<Vector3D>( 8,true );
				
				m_cornersLocal[0] 		 = new Vector3D();
				m_cornersLocal[1] 		 = new Vector3D();
				m_cornersLocal[2] 		 = new Vector3D();
				m_cornersLocal[3] 		 = new Vector3D();
				m_cornersLocal[4] 		 = new Vector3D();
				m_cornersLocal[5] 		 = new Vector3D();
				m_cornersLocal[6] 		 = new Vector3D();
				m_cornersLocal[7] 		 = new Vector3D();
			}
			
			if( m_cornersDirtyLocal )
			{
				m_cornersLocal[0].setTo( minLocal.x, m_minLocal.y, m_minLocal.z);
				m_cornersLocal[1].setTo( m_minLocal.x, m_minLocal.y, m_maxLocal.z);
				m_cornersLocal[2].setTo( m_minLocal.x, m_maxLocal.y, m_minLocal.z);
				m_cornersLocal[3].setTo( m_maxLocal.x, m_minLocal.y, m_minLocal.z);
				m_cornersLocal[4].setTo( m_maxLocal.x, m_maxLocal.y, m_maxLocal.z);
				m_cornersLocal[5].setTo( m_maxLocal.x, m_maxLocal.y, m_minLocal.z);
				m_cornersLocal[6].setTo( m_maxLocal.x, m_minLocal.y, m_maxLocal.z);
				m_cornersLocal[7].setTo( m_minLocal.x, m_maxLocal.y, m_maxLocal.z);
				
				m_cornersDirtyLocal = false;
				//m_dirty ^= FLAG_DIRTY_CORNERS;
			}
			
			return  m_cornersLocal;
		}
		
		public function get cornersGlobal():Vector.<Vector3D>
		{
			if(!m_cornersGlobal)
			{
				m_cornersGlobal 		 = new Vector.<Vector3D>( 8,true );
				
				m_cornersGlobal[0] 		 = new Vector3D();
				m_cornersGlobal[1] 		 = new Vector3D();
				m_cornersGlobal[2] 		 = new Vector3D();
				m_cornersGlobal[3] 		 = new Vector3D();
				m_cornersGlobal[4] 		 = new Vector3D();
				m_cornersGlobal[5] 		 = new Vector3D();
				m_cornersGlobal[6] 		 = new Vector3D();
				m_cornersGlobal[7] 		 = new Vector3D();
			}
	
			
			if( m_cornersDirtyGlobal )
			{
				m_cornersGlobal[0].setTo( minGlobal.x, m_minGlobal.y, m_minGlobal.z);
				m_cornersGlobal[1].setTo( m_minGlobal.x, m_minGlobal.y, m_maxGlobal.z);
				m_cornersGlobal[2].setTo( m_minGlobal.x, m_maxGlobal.y, m_minGlobal.z);
				m_cornersGlobal[3].setTo( m_maxGlobal.x, m_minGlobal.y, m_minGlobal.z);
				m_cornersGlobal[4].setTo( m_maxGlobal.x, m_maxGlobal.y, m_maxGlobal.z);
				m_cornersGlobal[5].setTo( m_maxGlobal.x, m_maxGlobal.y, m_minGlobal.z);
				m_cornersGlobal[6].setTo( m_maxGlobal.x, m_minGlobal.y, m_maxGlobal.z);
				m_cornersGlobal[7].setTo( m_minGlobal.x, m_maxGlobal.y, m_maxGlobal.z);
				
				m_cornersDirtyGlobal = false;
				//m_dirty ^= FLAG_DIRTY_CORNERS;
			}
			
			return  m_cornersGlobal;
		}
		
		
		
		public function update():void 
		{
			updateLocal();
			
			updateGlobal();//esitle
			
		}
		
		public function updateLocal():void 
		{	
			//m_transformationLocal = _transformation;
			
			m_minMaxDirtyLocal = true;
			m_centerHalfDirtyLocal = true;
			m_cornersDirtyLocal = true;
		}
		
		public function updateGlobal():void 
		{	
			
			//m_transformationGlobal = _transformation;//esitle
			
			m_minMaxDirtyGlobal = true;
			m_centerHalfDirtyGlobal = true;
			m_cornersDirtyGlobal = true;
		}
		
/*		public function translate(_position:Vector3D):void
		{
			m_center = _position.add( m_center );
			
			m_max = m_center.add( m_halfSize );			
			m_min = m_center.subtract( m_halfSize );
			
			m_cornersDirty = true;
			
		}*/
		//TODO:other combinations
		public function intersectAABBLocal( _aabb:AxisAlignedBoundingBox ):Boolean
		{
			if( maxLocal.x < _aabb.minLocal.x || m_minLocal.x > _aabb.m_maxLocal.x )	return false;
			if( m_maxLocal.y < _aabb.m_minLocal.y || m_minLocal.y > _aabb.m_maxLocal.y )	return false;
			if( m_maxLocal.z < _aabb.m_minLocal.z || m_minLocal.z > _aabb.m_maxLocal.z )	return false;
			
			return true;
		}
		
		public function intersectAABBGlobal( _aabb:AxisAlignedBoundingBox ):Boolean
		{
			if( maxGlobal.x < _aabb.minGlobal.x || m_minGlobal.x > _aabb.m_maxGlobal.x )	return false;
			if( m_maxGlobal.y < _aabb.m_minGlobal.y || m_minGlobal.y > _aabb.m_maxGlobal.y )	return false;
			if( m_maxGlobal.z < _aabb.m_minGlobal.z || m_minGlobal.z > _aabb.m_maxGlobal.z )	return false;
			
			return true;
		}
		
		
/*		public function intersectRay( _rayStartPoint:Vector3D, _rayDirection:Vector3D ):Boolean
		{
			var maxS:Number = Number.MIN_VALUE;
			var minT:Number = Number.MAX_VALUE;
			var s:Number;
			var t:Number;
			var temp:Number;
			// do x coordinate test (yz planes)
			
			//ray is parallel to plane
			if( _rayDirection.x == 0 )
			{
				// ray passes by box
				if( _rayStartPoint.x < m_min.x || _rayStartPoint.x > m_max.x)
				{
					return false
				}
			}else{
				// compute intersection parameters and sort
				s = (m_min.x - _rayStartPoint.x) / _rayDirection.x;
				t = (m_max.x - _rayStartPoint.x) / _rayDirection.x;
				if( s > t )
				{
					temp = s;
					s = t;
					t = temp;
				}
				//adjust min and max values
				if( s > maxS )
					maxS = s;
				if( t < minT )
					minT = t;
				//check for intersection failure
				if( minT < 0 || maxS > minT )
					return false;
			}
			
			
			// do y coordinate test (xz planes)
			
			//ray is parallel to plane
			if( _rayDirection.y == 0 )
			{
				// ray passes by box
				if( _rayStartPoint.y < m_min.y || _rayStartPoint.y > m_max.y)
				{
					return false
				}
			}else{
				// compute intersection parameters and sort
				s = (m_min.y - _rayStartPoint.y) / _rayDirection.y;
				t = (m_max.y - _rayStartPoint.y) / _rayDirection.y;
				if( s > t )
				{
					temp = s;
					s = t;
					t = temp;
				}
				//adjust min and max values
				if( s > maxS )
					maxS = s;
				if( t < minT )
					minT = t;
				//check for intersection failure
				if( minT < 0 || maxS > minT )
					return false;
			}
			
			// do z coordinate test (xy planes)
			
			//ray is parallel to plane
			if( _rayDirection.z == 0 )
			{
				// ray passes by box
				if( _rayStartPoint.z < m_min.z || _rayStartPoint.z > m_max.z)
				{
					return false
				}
			}else{
				// compute intersection parameters and sort
				s = (m_min.z - _rayStartPoint.z) / _rayDirection.z;
				t = (m_max.z - _rayStartPoint.z) / _rayDirection.z;
				if( s > t )
				{
					temp = s;
					s = t;
					t = temp;
				}
				//adjust min and max values
				if( s > maxS )
					maxS = s;
				if( t < minT )
					minT = t;
				//check for intersection failure
				if( minT < 0 || maxS > minT )
					return false;
			}
			
			return true;
		}*/
		
		public function merge( _aabb:AxisAlignedBoundingBox ):void{
			
			var resolatedMax:Vector3D = _aabb.maxLocal;
			var resolatedMin:Vector3D = _aabb.minLocal;
			
			if(resolatedMax.x > m_maxInitial.x) m_maxInitial.x = resolatedMax.x;
			if(resolatedMin.x < m_minInitial.x) m_minInitial.x = resolatedMin.x;
			if(resolatedMax.y > m_maxInitial.y) m_maxInitial.y = resolatedMax.y;
			if(resolatedMin.y < m_minInitial.y) m_minInitial.y = resolatedMin.y;
			if(resolatedMax.z > m_maxInitial.z) m_maxInitial.z = resolatedMax.z;
			if(resolatedMin.z < m_minInitial.z) m_minInitial.z = resolatedMin.z;
			
			//m_minLocal.copyFrom(m_minInitial);
			//m_maxLocal.copyFrom(m_maxInitial);
			
			
			m_minMaxDirtyLocal = true;
			m_minMaxDirtyGlobal = true;
			
			m_centerHalfDirtyLocal = true;
			m_centerHalfDirtyGlobal = true;
			
			m_cornersDirtyLocal = true;
			m_cornersDirtyGlobal = true;
			//m_dirty	= int.MAX_VALUE;
			//m_dirty ^= FLAG_DIRTY_MINMAX;
			
			update();

		}
		
/*		public function recalculateFor( _min:Vector3D, _max:Vector3D ):AxisAlignedBoundingBox{
			m_max = _max;
			m_min = _min;
			
			m_size = m_max.subtract( m_min );
			m_halfSize.setTo(m_size.x*0.5, m_size.y*0.5, m_size.z*0.5);
			
			m_halfSize_original = m_halfSize.clone();
			m_size_Original = m_size.clone();
			
			m_center = m_max.add( m_min );
			m_center.scaleBy(.5);
			m_center_original = m_center.clone();
			
			
			m_vectors			= Vector.<Number>([ 
				-m_halfSize_original.x, m_halfSize_original.y, m_halfSize_original.z,
				m_halfSize_original.x,-m_halfSize_original.y, m_halfSize_original.z,
				m_halfSize_original.x, m_halfSize_original.y,-m_halfSize_original.z,
				m_halfSize_original.x, m_halfSize_original.y, m_halfSize_original.z 
			]);
			
			m_cornersDirty = true;
			
			return this;
		}*/
		
		override public function clone():IEngineObject{
			var _newAABB:AxisAlignedBoundingBox = new AxisAlignedBoundingBox( m_minInitial.clone(), m_maxInitial.clone(), m_sceneObjectTransformation);
			
			_newAABB.m_minLocal.copyFrom(m_minLocal);
			_newAABB.m_maxLocal.copyFrom(m_minLocal);
			_newAABB.m_minGlobal.copyFrom(m_minGlobal);
			_newAABB.m_minGlobal.copyFrom(m_minGlobal);
			
			_newAABB.m_minMaxDirtyLocal = m_minMaxDirtyLocal;
			_newAABB.m_centerHalfDirtyLocal = m_centerHalfDirtyLocal;
			_newAABB.m_minMaxDirtyGlobal = m_minMaxDirtyGlobal;
			_newAABB.m_centerHalfDirtyGlobal = m_centerHalfDirtyGlobal;
			_newAABB.m_cornersDirtyLocal = false;
			_newAABB.m_cornersDirtyGlobal = false;
			

			if(m_centerLocal)
			{
				_newAABB.m_centerLocal 					= m_centerLocal.clone();
				
				_newAABB.m_halfSizeLocal				= m_halfSizeLocal.clone();
				
				_newAABB.m_sizeLocal					= m_sizeLocal.clone();
			}
		    	if(m_centerGlobal)
			{
				_newAABB.m_centerGlobal 					= m_centerGlobal.clone();
				
				_newAABB.m_halfSizeGlobal				= m_halfSizeGlobal.clone();
				
				_newAABB.m_sizeGlobal					= m_sizeGlobal.clone();
			}
			if(m_halfSizeInitial)
				{
			_newAABB.m_halfSizeInitial		    = m_halfSizeInitial.clone();
			
			_newAABB.m_centerInitial			= m_centerInitial.clone();
			
			_newAABB.m_sizeInitial		    = m_sizeInitial.clone();
				}
				

			
			return _newAABB;
		}
		
		protected override function trackObject():void
		{
			IDManager.trackObject(this, AxisAlignedBoundingBox);
		}
		
		override protected function initInternals():void
		{
			super.initInternals();
		}
	}
}
