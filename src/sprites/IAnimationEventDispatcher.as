package sprites 
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Gareth Williams
	 */
	public interface IAnimationEventDispatcher 
	{
		function addEventListener (type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		function dispatchEvent (event:AnimationEvent):Boolean
		function removeEventListener (type:String, listener:Function, useCapture:Boolean = false):void
		function hasEventListener (type:String) : Boolean;
	}
}