/*
 * RenderableLight.as
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
 
 
package com.yogurt3d.core.lights
{
	import com.yogurt3d.core.materials.MaterialFill;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.utils.MathUtils;
	import com.yogurt3d.presets.primitives.sceneobjects.ConeSceneObject;
	import com.yogurt3d.presets.primitives.sceneobjects.SphereSceneObject;

	/**
	 * 
	 * 
 	 * @author Yogurt3D Engine Core Team
 	 * @company Yogurt3D Corp.
 	 **/
	public class RenderableLight extends Light
	{
		public var sceneObject:SceneObjectRenderable;
		
		public function RenderableLight(_type:ELightType = null, _color:uint = 0xFFFFFF, _radius:Number = 0.2, _initInternals:Boolean=true)
		{
			super( _type, _color, 1 );
			if( _type == null )
			{
				_type = ELightType.POINT;
			}
			if( _type == ELightType.POINT )
			{
				sceneObject = new SphereSceneObject( _radius );
			}else if( _type == ELightType.DIRECTIONAL ){
				sceneObject = new ConeSceneObject( 10 * 0.2 , 20 * 0.2 );
				sceneObject.transformation.rotationX = 90;
			}else if( _type == ELightType.SPOT )
			{
				sceneObject = new ConeSceneObject( Math.sin( innerConeAngle * MathUtils.DEG_TO_RAD) * 20 * 0.2 , 20 * 0.2 );
				sceneObject.transformation.rotationX = 90;
			}
			sceneObject.material = new MaterialFill( _color, .7);
			
			this.addChild( sceneObject );
		}
		
		public function setColor(_color:uint):void{
			MaterialFill(sceneObject.material).color = _color;
			color.setColorUint( 0xFF000000 | _color );
		}
		
		/**
		 * @inheritDoc 
		 * 
		 */		
		override protected function initInternals():void
		{
			super.initInternals();
			

		}
	}
}
