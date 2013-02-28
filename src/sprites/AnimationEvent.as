package sprites 
{
	import flash.events.Event;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Gareth Williams
	 */
	public class AnimationEvent extends Event 
	{
		public static var ANIMATION_COMPLETE:String = "animation has completed for this sprite";
		public static var PLAYER_HIT_ANIMATION:String = "player hit animation trigered";
		public var sprite:IAnimationEventDispatcher;
		public function AnimationEvent(type:String, sprite:IAnimationEventDispatcher, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			this.sprite = sprite;
			super(type, bubbles, cancelable);
		} 
		public override function clone():Event 
		{ 
			return new AnimationEvent(type, sprite, bubbles, cancelable);
		} 
		public override function toString():String 
		{ 
			return formatToString("AnimationEvent", "sprite", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}
