package com.yogurt3d.core.particle.initializers
{
	import com.yogurt3d.core.geoms.Mesh;
	import com.yogurt3d.core.materials.base.Material;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	
	import org.flintparticles.common.emitters.Emitter;
	import org.flintparticles.common.initializers.InitializerBase;
	import org.flintparticles.common.particles.Particle;
	import org.flintparticles.threeD.particles.Particle3D;

	public class Y3DMeshObject extends InitializerBase
	{
		private var m_mesh:Mesh;
		private var m_material:Material;
		private var m_scaleX:Number;
		private var m_scaleY:Number;
		private var m_scaleZ:Number;
		private var m_sceneObj:SceneObjectRenderable;
	
		public function Y3DMeshObject(_mesh:Mesh,_material:Material, _scaleX:Number=1.0,  _scaleY:Number=1.0, _scaleZ:Number=1.0)
		{
			m_scaleX = _scaleX;
			m_scaleY = _scaleY;
			m_scaleZ = _scaleZ;
			
			m_material = _material;
			m_mesh = _mesh;
			
			m_sceneObj = new SceneObjectRenderable;
			m_sceneObj.geometry = _mesh;
		}
		override public function initialize( emitter:Emitter, particle:Particle ):void
		{
			particle.image = m_sceneObj.clone();
			var obj:SceneObjectRenderable = particle.image;
			obj.renderLayer = -1 * Particle3D(particle).sortID;
			obj.transformation.scaleX = m_scaleX;
			obj.transformation.scaleY = m_scaleY;
			obj.transformation.scaleZ = m_scaleZ;
			
			obj.material = m_material;
			obj.material.opacity = particle.alpha;
			
		}
	}
}