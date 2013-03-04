package sprites 
{
	import adobe.utils.CustomActions;
	import com.greensock.easing.Bounce;
	import com.greensock.TweenMax;
	import flash.display.ActionScriptVersion;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.plugin.photonstorm.FlxExtendedSprite;
	/**
	 * ...
	 * @author Gareth Williams
	 */
	public class Player extends FlxExtendedSprite implements IAnimationEventDispatcher
	{
		
		//we may add other types of points later eg experience points
		public var colour:uint = 0;
		protected var eventDispatcher:EventDispatcher = new EventDispatcher();
		protected var isPerformingAction:Boolean = false;
		protected var actionQueue:Array = new Array();
		protected var fpsMultiplier:int = 2;
		private var starParticles:FlxEmitter;
		private var particles:FlxGroup = new FlxGroup();
		public function Player(colour:uint, X:Number = 0, Y:Number = 0, SimpleGraphic:Class = null) 
		{
			this.colour = colour;
			super(X, Y, SimpleGraphic);
			initParticles();
			this.health = 100;
		}
		private function initParticles():void 
		{
			starParticles = new FlxEmitter();
			starParticles.frequency = 3;
			starParticles.setXSpeed(-150,150);
			starParticles.setYSpeed(-200,0);
			starParticles.setRotation( -720, -720);
			starParticles.makeParticles(Registry.sparkParticlesImg, 100, 16, true);
			particles.add(starParticles);
		}
		//override
		override public function update():void
		{
			if (isPerformingAction && finished)
			{
				this.onAnimationComplete();
			}
			
			if (false == isPerformingAction && alive)
			{
				super.play("idle");
			}
			
			if (false == isPerformingAction && false == alive)
			{
				super.play("ko");
			}
			
			starParticles.update();
			super.update();
		}
		override public function draw():void
		{
			starParticles.draw();
			super.draw();
		}
		override public function play(AnimName:String, Force:Boolean = false):void 
		{
			if (this.isPerformingActionSequence == false)
			{
				//trace("performing action", AnimName, this);
				playHook(AnimName);
				super.play(AnimName, Force);
				isPerformingAction = true;
			}
			else
			{
				//trace("queuing action", AnimName, this);
				queueAction(new ActionData(AnimName, Force));
			}
		}
		//interface
		public function get isPerformingActionSequence():Boolean
		{
			return isPerformingAction || Boolean(actionQueue.length > 0);
		}
		//callback
		private function onAnimationComplete():void
		{
			var areQueuedActionsRemaining:Boolean = Boolean(actionQueue.length > 0);
			if (areQueuedActionsRemaining)
			{
				var next:ActionData = actionQueue.shift();
				//trace("dequeing action", this);
				playHook(next.action);
				super.play(next.action, next.force);
			}
			else
			{
				//trace("player - animation queue empty calling back", this);
				isPerformingAction = false;
				dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_COMPLETE, this));				
			}
		}
		private function queueAction(action:ActionData):void
		{
			actionQueue.push(action);
		}
		protected function playHook(action:String):void
		{
			//stub...
		}
		//helpers
		protected function doHitEffects():void
		{
			FlxG.shake(0.01,0.2);
			starParticles.at(this);
			starParticles.start(true, 3);
			dispatchEvent(new AnimationEvent(AnimationEvent.PLAYER_HIT_ANIMATION, this));
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
			this.eventDispatcher.removeEventListener(type, listener, useCapture);
		}
	}
}
internal class ActionData
{
	public var action:String;
	public var force:Boolean;
	public function ActionData(action:String, force:Boolean)
	{
		this.action = action;
		this.force = force;
	}
}