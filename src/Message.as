package  
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxText;
	import sprites.AnimationEvent;
	import sprites.IAnimationEventDispatcher;
	
	/**
	 * ...
	 * @author Gareth Williams
	 * flx text with a timer, dispatches an event when it times out and dissapears from the screen
	 */
	public class Message extends FlxText implements IAnimationEventDispatcher
	{
		
		private static var id:int = 0; 
		private var m_id:int = 0;
		
		private var eventDispatcher:EventDispatcher;
		private var secondsOnScreen:Number
		private var displayTimer:Timer;
		public function Message(text:String, duration:Number, colour:uint = 0xFFFFFF) 
		{
			m_id = id++;
			
			//trace("new message: " + m_id);
			
			eventDispatcher = new EventDispatcher();
			secondsOnScreen = duration;
			displayTimer = new Timer(1000 * secondsOnScreen, 1);
			displayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onTimeOut);
			super(0, FlxG.camera.height / 5, FlxG.camera.width, text);
			this.alignment = "center";
			this.color = colour;
			this.shadow = 2;
			this.scrollFactor = new FlxPoint(0, 0);
		}
		override public function destroy():void
		{
			displayTimer.stop();
			displayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.onTimeOut);
			super.destroy();
		}
		public function begin():void
		{
			displayTimer.start();
		}
		private function onTimeOut(event:TimerEvent):void
		{
			//trace("Message - animation complete " + m_id);
			eventDispatcher.dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_COMPLETE, this));
			
			this.kill();
		}
		//wrappers
		public function addEventListener (type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			this.eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public function dispatchEvent (event:AnimationEvent):Boolean
		{
			return this.eventDispatcher.dispatchEvent(event);
		}
		public function hasEventListener (type:String):Boolean
		{
			return this.eventDispatcher.hasEventListener(type);
		}
		public function removeEventListener (type:String, listener:Function, useCapture:Boolean = false):void
		{
			//trace("Message - removing listener " + m_id); 
			this.eventDispatcher.removeEventListener(type, listener, useCapture);
		}
	}
}