yObject's transform properties, so do not use
		 * it in conjunction with regular x/y/scaleX/scaleY/rotation tweens concurrently.<br /><br />
		 * 
		 * <b>USAGE:</b><br /><br />
		 * <code>
		 * 		import com.greensock.TweenMax; <br />
		 * 		import com.greensock.data.TweenMaxVars; <br />
		 * 		import com.greensock.plugins.TweenPlugin; <br />
		 * 		import com.greensock.plugins.TransformMatrixPlugin; <br />
		 * 		TweenPlugin.activate([TransformMatrixPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.<br /><br />
		 * 
		 * 		TweenMax.to(mc, 1, new TweenMaxVars().transformMatrix({x:50, y:300, scaleX:2, scaleY:2})); <br /><br />
		 * 		
		 * 		//-OR-<br /><br />
		 * 
		 * 		TweenMax.to(mc, 1, new TweenMaxVars().transformMatrix({tx:50, ty:300, a:2, d:2})); <br /><br />
		 * 
		 * </code>
		 **/
		public function transformMatrix(properties:Object):TweenMaxVars {
			return _set("transformMatrix", properties, true);
		}
		
		/** Sets a DisplayObject's "visible" property at the end of the tween. **/
		public function visible(value:Boolean):TweenMaxVars {
			return _set("visible", value, true);
		}
		
		/** Changes the volume of any object that has a soundTransform property (MovieClip, SoundChannel, NetStream, etc.) **/
		public function volume(volume:Number):TweenMaxVars {
			return _set("volume", volume, true);
		}
		
		
//---- GETTERS / SETTERS -------------------------------------------------------------------------------------------------------------
		
		/** The generic object populated by all of the method calls in the TweenMaxVars instance. This is the raw data that gets passed to the tween. **/
		public function get vars():Object {
			return _vars;
		}
		
		/** @private **/
		public function get isGSVars():Boolean {
			return true;
		}
		
	}
}