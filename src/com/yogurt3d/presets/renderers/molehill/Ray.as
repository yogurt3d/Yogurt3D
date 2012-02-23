package com.yogurt3d.presets.renderers.molehill
{
	import com.yogurt3d.core.geoms.SubMesh;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class Ray
	{
		private var m_startPoint			:Vector3D ;
		
		private var m_endPoint				:Vector3D ;
		
		public function Ray(_startPoint:Vector3D = null,_endPoint:Vector3D = null)
		{
			if (_startPoint == null) m_startPoint = new Vector3D() ;
			if (_endPoint == null) m_endPoint = new Vector3D() ;
			
			m_startPoint = _startPoint ;
			m_endPoint = _endPoint ;
			
		}

		public function get endPoint():Vector3D
		{
			return m_endPoint;
		}

		public function set endPoint(value:Vector3D):void
		{
			m_endPoint = value;
		}

		public function get startPoint():Vector3D
		{
			return m_startPoint;
		}

		public function set startPoint(value:Vector3D):void
		{
			m_startPoint = value;
		}
		
		public function intersectSceneObject( _sceneObject:SceneObjectRenderable ):Vector3D{
			var i:uint, j:uint, k:uint ;
			
			// mesh check
			var _result:Vector3D = new Vector3D() ;
			var testDistance:Number = -1 ;
			
			
			var _sorgb:Matrix3D = new Matrix3D() ;
			_sorgb.copyFrom(_sceneObject.transformation.matrixGlobal) ;
			_sorgb.invert();
			endPoint = _sorgb.transformVector( endPoint );
			startPoint = _sorgb.transformVector( startPoint );
			
			var _rayResultVector:Vector3D ;
			
			var triangle:Vector.<Vector3D> = new Vector.<Vector3D>(3, true );
			triangle[0] = new Vector3D();
			triangle[1] = new Vector3D();
			triangle[2] = new Vector3D();
			
			for (i = 0; i < _sceneObject.geometry.subMeshList.length ; i++) {
				var _submesh:SubMesh = _sceneObject.geometry.subMeshList[i] ;
				
				for (j = 0 ; j < _submesh.triangleCount ; j++) {					
					for (k = 0 ; k < 3 ; k++) {
						
						var vec:Vector3D = triangle[k];
						vec.x = _submesh.vertices[_submesh.indices[j*3+k]*3  ] ;
						vec.y = _submesh.vertices[_submesh.indices[j*3+k]*3+1] ;
						vec.z = _submesh.vertices[_submesh.indices[j*3+k]*3+2] ;	
						
						//vec = _sorgb.transformVector(vec) ;
					}
					
					_rayResultVector = intersectTriangle(triangle) ;
					
					if (_rayResultVector != null ) {
						var tempDist:Number = Vector3D.distance(startPoint,_rayResultVector) ;
						if (testDistance == -1) {
							testDistance = tempDist ;
							_result = _rayResultVector ;
							
						} else if (testDistance > tempDist) {
							testDistance = tempDist ;
							_result = _rayResultVector ;
						}
					} // end if _rayResultVector
				} // _submesh.triangleCount
			} // subMeshList.length
			
			
			if (testDistance > -1) {
				return _result ; 
			} else return null ;
		}
		
		public function intersectTriangle(T:Vector.<Vector3D>, isLocal:Boolean = false):Vector3D
		{
			var _result:Vector3D = new Vector3D() ;
			
			var  u:Vector3D, v:Vector3D, n:Vector3D ;             // triangle vectors
			var  dir:Vector3D , w0:Vector3D , w:Vector3D;          // ray vectors
			var  r: Number, a: Number, b : Number;             // params to calc ray-plane intersect
			
			// get triangle edge vectors and plane normal
			u = T[1].subtract(T[0]);
			v = T[2].subtract(T[0]);
			
			n = new Vector3D() ;        // cross product
			n = u.crossProduct(v) ;
			if ((n.x == 0) && (n.y == 0) && (n.z == 0))            // triangle is degenerate
				return null;                 // do not deal with this case
			
			dir = endPoint.subtract(startPoint);             // ray direction vector
			w0 = startPoint.subtract(T[0]);
			
			a = -n.dotProduct(w0) ;
			b = n.dotProduct(dir) ;
			
			if (Math.abs(b) < 0.00000001) {     // ray is parallel to triangle plane
				if (a == 0)                // ray lies in triangle plane
					return null;
				else return null;             // ray disjoint from plane
			}
			
			// get intersect point of ray with triangle plane
			r = a / b;
			
			if (r < 0.0)                   // ray goes away from triangle
				return null;                  // => no intersect
			// for a segment, also test if (r > 1.0) => no intersect
			dir.scaleBy(r) ;
			_result = startPoint.clone().add(dir) ;           // intersect point of ray and plane
			
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
		
		public function clone():Ray {
			var _ray:Ray = new Ray(m_startPoint,m_endPoint) ;
			
			return _ray ;
		}

	}
}