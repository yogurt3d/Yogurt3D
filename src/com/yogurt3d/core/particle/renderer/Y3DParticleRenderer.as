package com.yogurt3d.core.particle.renderer
{
	import com.yogurt3d.core.geoms.Mesh;
	import com.yogurt3d.core.materials.MaterialParticle;
	import com.yogurt3d.core.sceneobjects.Scene;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.presets.primitives.meshs.Sprite3D;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import org.flintparticles.common.particles.Particle;
	import org.flintparticles.common.renderers.RendererBase;
	import org.flintparticles.common.utils.Maths;
	import org.flintparticles.threeD.particles.Particle3D;


	public class Y3DParticleRenderer extends RendererBase 
	{
		private var m_scene:Scene;
		
		public function Y3DParticleRenderer(_scene:Scene)
		{
			m_scene = _scene;
			
		}
				
		override protected function renderParticles( particles:Array ):void
		{
			for each( var p:Particle3D in particles )
			{
				renderParticle( p );
			}
		}
		
		protected function quaternion2euler(quarternion:Vector3D):Vector3D
		{
			var result:Vector3D = new Vector3D();
			
			var test :Number = quarternion.x*quarternion.y + quarternion.z*quarternion.w;
			if (test > 0.499) { // singularity at north pole
				result.x = 2 * Math.atan2(quarternion.x,quarternion.w);
				result.y = Math.PI/2;
				result.z = 0;
				return result;
			}
			if (test < -0.499) { // singularity at south pole
				result.x = -2 * Math.atan2(quarternion.x,quarternion.w);
				result.y = - Math.PI/2;
				result.z = 0;
				return result;
			}
			
			var sqx	:Number = quarternion.x*quarternion.x;
			var sqy	:Number = quarternion.y*quarternion.y;
			var sqz	:Number = quarternion.z*quarternion.z;
			
			result.x = Math.atan2(2*quarternion.y*quarternion.w - 2*quarternion.x*quarternion.z , 1 - 2*sqy - 2*sqz);
			result.y = Math.asin(2*test);
			result.z = Math.atan2(2*quarternion.x*quarternion.w-2*quarternion.y*quarternion.z , 1 - 2*sqx - 2*sqz);
			
			return result;
		}
		
		protected function renderParticle( particle:Particle3D ):void{
			
			var o:* = particle.image;
			
			SceneObjectRenderable(o).transformation.x = particle.position.x;
			SceneObjectRenderable(o).transformation.y = particle.position.y;
			SceneObjectRenderable(o).transformation.z = particle.position.z;
			
//			var rotation:Vector3D = quaternion2euler( new Vector3D(particle.rotation.x, particle.rotation.y, 
//				particle.rotation.z, particle.rotation.w));
//			
//			SceneObjectRenderable(o).transformation.rotationX  = Maths.asDegrees( rotation.x );
//			SceneObjectRenderable(o).transformation.rotationY  = Maths.asDegrees( rotation.y );
//			SceneObjectRenderable(o).transformation.rotationZ  = Maths.asDegrees( rotation.z );
			
			SceneObjectRenderable(o).transformation.scale = particle.scale;
						
			if(o is SceneObjectRenderable && SceneObjectRenderable(o).geometry is Sprite3D){
				
				var _r:uint = particle.color >> 16 & 0xFF;
				var _g:uint = particle.color >> 8 & 0xFF;
				var _b:uint = particle.color & 0xFF;
				
				var col:uint = (_r << 16 | _g << 8 | _b);
				
				(SceneObjectRenderable(o).material as MaterialParticle).color = col;
				(SceneObjectRenderable(o).material as MaterialParticle).opacity = particle.alpha;
																	
			}else if(o is SceneObjectRenderable && SceneObjectRenderable(o).geometry is Mesh){
			
				SceneObjectRenderable(o).material.opacity = particle.alpha;
			}
								
		}
		
		override protected function addParticle( particle:Particle ):void
		{
			// SceneObjectRenderable : particle.image + Sprite3D
			m_scene.addChild(particle.image );
			renderParticle( Particle3D( particle ) );	
				
		}
		
		override protected function removeParticle( particle:Particle ):void
		{

			SceneObjectRenderable(particle.image).material.dispose();
			m_scene.removeChild(particle.image );

		}

	}
}