package com.yogurt3d.presets.renderers.molehill
{
	import com.yogurt3d.core.cameras.Camera;
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.helpers.boundingvolumes.BoundingSphere;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.viewports.Viewport;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class Ray
	{
		private var m_startPoint			:Vector3D ;
		
		private var m_endPoint				:Vector3D ;
		
		private var m_direction				:Vector3D = new Vector3D() ;
		
		
		public function Ray(_startPoint:Vector3D = null,_endPoint:Vector3D = null)
		{			
			m_startPoint = _startPoint || new Vector3D();
			m_endPoint =  _endPoint || new Vector3D();
			
			m_direction = m_endPoint.subtract(m_startPoint);
		}
		
		public function get endPoint():Vector3D
		{
			return m_endPoint;
		}
		
		public function set endPoint(value:Vector3D):void
		{
			m_endPoint = value;
			m_direction = m_endPoint.subtract(m_startPoint);
		}
		
		public function get startPoint():Vector3D
		{
			return m_startPoint;
		}
		
		public function set startPoint(value:Vector3D):void
		{
			m_startPoint = value;
			m_direction = m_endPoint.subtract(m_startPoint);
		}
		
		public function intersectBoundingSphere (_s:BoundingSphere):Boolean {		
			var MyRayToCenter:Vector3D = _s.center.subtract( m_startPoint);
			
			//	var a:Number = m_direction.dotProduct(m_direction) ;
			var b:Number = 2 * m_direction.dotProduct(MyRayToCenter) ;
			var c:Number = MyRayToCenter.dotProduct(MyRayToCenter) - _s.radiusSqr ;
			
			var discriminant:Number = b * b - 4 * m_direction.dotProduct(m_direction) * c ;
			
			if (discriminant < 0 ) return false ;
			return true ;
			
		}
		public function intersectTriangle(T:Vector.<Vector3D>, isLocal:Boolean = false):Vector3D
		{
			//var _MyRay:MyRay = this ;
			var _result:Vector3D // = new Vector3D() ;
			
			var  u:Vector3D, v:Vector3D, n:Vector3D ;             // triangle vectors
			var  w0:Vector3D , w:Vector3D;          // MyRay vectors
			var  r: Number, a: Number, b : Number;             // params to calc MyRay-plane intersect
			
			// get triangle edge vectors and plane normal
			u = T[1].subtract(T[0]);
			v = T[2].subtract(T[0]);
			
			n = u.crossProduct(v) ;        // cross product
			
			if ((n.x == 0) && (n.y == 0) && (n.z == 0))            // triangle is degenerate
				return null;                 // do not deal with this case
			
			w0 = startPoint.subtract(T[0]);
			
			a = -n.dotProduct(w0) ;
			b = n.dotProduct(m_direction) ;
			
			if (Math.abs(b) < 0.00000001) {     // MyRay is parallel to triangle plane
				if (a == 0)                // MyRay lies in triangle plane
					return null;
				else return null;             // MyRay disjoint from plane
			}
			
			// get intersect point of MyRay with triangle plane
			r = a / b;
			
			if (r < 0.0)                   // MyRay goes away from triangle
				return null;                  // => no intersect
			// for a segment, also test if (r > 1.0) => no intersect
			var  dir:Vector3D = m_direction.clone() ;
			dir.scaleBy(r) ;
			_result = startPoint.add(dir) ;           // intersect point of MyRay and plane
			
			// is I inside T?
			var uu: Number, uv: Number, vv: Number, wu: Number, wv: Number, D : Number ;
			uu = u.dotProduct(u) ;
			uv = u.dotProduct(v);
			vv = v.dotProduct(v);
			w = _result.subtract(T[0]);
			wu = w.dotProduct(u);
			wv = w.dotProduct(v);
			D = uv * uv - uu * vv;
			
			// get and test parametric coords
			var s: Number, t : Number;
			s = (uv * wv - vv * wu) / D;
			if (s < 0.0 || s > 1.0)        // I is outside T
				return null;
			t = (uv * wu - uu * wv) / D;
			if (t < 0.0 || (s + t) > 1.0)  // I is outside T
				return null;
			
			return _result ;               // I is in T
		}
		public function getIntersectPoint(_so:SceneObjectRenderable ):Vector3D {
			var i:uint, j:uint, k:uint ;
			
			// mesh check
			var _result:Vector3D = new Vector3D() ;
			var testDistance:Number = -1 ;
			
			var _sorgb:Matrix3D = new Matrix3D() ;
			_sorgb.copyFrom(_so.transformation.matrixGlobal.clone()) ;
			
			_sorgb.invert() ;
			
			var tempRay:Ray = clone() ;
			tempRay.startPoint = _sorgb.transformVector(this.startPoint) ; 
			tempRay.endPoint   = _sorgb.transformVector(this.endPoint) ; 
			
			//boundingSphere check
			if (tempRay.intersectBoundingSphere(_so.geometry.boundingSphere) == false) return null ; 
			
			var _rayResultVector:Vector3D ;
			var tempDist:Number ;
			
			var _trianglesCache:Vector.<Vector.<Vector3D>> = new Vector.<Vector.<Vector3D>>() ;
			for (i = 0; i < _so.geometry.subMeshList.length ; i++)
			{
				var _submesh:SubMesh = _so.geometry.subMeshList[i] ;
				for (j = 0 ; j < _submesh.triangleCount ; j++)
				{
					_trianglesCache[j] = new Vector.<Vector3D>() ;
					
					var j3:uint = j*3;
					
					_trianglesCache[j].push( new Vector3D(
						_submesh.vertices[uint(_submesh.indices[j3]*3) ], 
						_submesh.vertices[uint(_submesh.indices[j3]*3+1)], 
						_submesh.vertices[uint(_submesh.indices[j3]*3+2)] 
					) ) ;
					
					_trianglesCache[j].push(  new Vector3D(
						_submesh.vertices[uint(_submesh.indices[j3+1]*3) ], 
						_submesh.vertices[uint(_submesh.indices[j3+1]*3+1)], 
						_submesh.vertices[uint(_submesh.indices[j3+1]*3+2)] 
					) ) ;
					
					_trianglesCache[j].push(  new Vector3D(
						_submesh.vertices[uint(_submesh.indices[j3+2]*3) ], 
						_submesh.vertices[uint(_submesh.indices[j3+2]*3+1)], 
						_submesh.vertices[uint(_submesh.indices[j3+2]*3+2)] 
					) ) ;
					
					_rayResultVector = tempRay.intersectTriangle(_trianglesCache[j]) ;
					if (_rayResultVector != null ) {
						tempDist = Vector3D.distance(tempRay.startPoint,_rayResultVector) ;
						if (testDistance == -1) {
							testDistance = tempDist ;
							_result = _rayResultVector ;
							
						} else if (testDistance > tempDist) {
							testDistance = tempDist ;
							_result = _rayResultVector ;
						}
					}
				}
			}
			
			if (testDistance > -1) {
				_result = _so.transformation.matrixGlobal.transformVector(_result) ; 
				return _result ; 
			} else return null ;
			
		}		
		
		public static function getRayFromMousePosition(_camera:Camera, viewport:Viewport,_mouseX:Number, _mouseY:Number ):Ray {
			var _ray:Ray = new Ray() ;
			
			var _endPoint:Vector3D = new Vector3D() ;
			_endPoint.x = _camera.frustum.m_vCornerPoints[0].x - (_camera.frustum.m_vCornerPoints[0].x - _camera.frustum.m_vCornerPoints[1].x) * (viewport.width-_mouseX) / viewport.width ;
			_endPoint.y = _camera.frustum.m_vCornerPoints[0].y - (_camera.frustum.m_vCornerPoints[0].y - _camera.frustum.m_vCornerPoints[3].y) * _mouseY / viewport.height ;
			_endPoint.z = _camera.frustum.m_vCornerPoints[0].z ;
			
			_endPoint = _camera.transformation.matrixGlobal.transformVector(_endPoint) ;
			
			_ray.startPoint = _camera.transformation.globalPosition.clone() ;
			_ray.endPoint = _endPoint ;
			
			return _ray ;
		}	
		
		public function clone():Ray {
			var _MyRay:Ray = new Ray(m_startPoint,m_endPoint) ;
			
			return _MyRay ;
		}
		
	}
}