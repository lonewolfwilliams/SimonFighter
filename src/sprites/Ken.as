package sprites 
{
	import flash.display.BlendMode;
	import flash.display.ColorCorrection;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Gareth Williams
	 */
	public class Ken extends Player implements IPlayer
	{
		public function Ken(X:Number = 0, Y:Number = 0, SimpleGraphic:Class = null) 
		{
			super(0xD00000, X, Y, SimpleGraphic);
			
			loadGraphic(Registry.kenSheetImg, true, false, 117, 75);
			addAnimation("idle", [0, 1, 2, 3, 4, 5], 5 * fpsMultiplier, true);//row 1
			addAnimation("highPunch", [13, 14, 15, 16, 17, 18, 19], 7 * fpsMultiplier, false);//row2
			addAnimation("highKick", [26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38], 13 * super.fpsMultiplier, false); //row 3
			addAnimation("lowKick", [39, 40, 41, 42, 43, 44, 45, 46], 8 * fpsMultiplier, false); //row 4
			addAnimation("lowPunch", [52, 53, 54, 55, 56], 5 * fpsMultiplier, false);//row 5
			addAnimation("highBlock", [65, 66, 67, 68, 69, 70, 71], 7 * fpsMultiplier, false);//row 6
			addAnimation("lowBlock", [78, 79, 80, 81, 82, 83, 84], 7 * fpsMultiplier, false);//row 7
			addAnimation("highHit", [91], 1 * fpsMultiplier, false); //row 8
			addAnimation("fall", [92], 1 * fpsMultiplier, true); //row 8
			addAnimation("KO", [93], 1 * fpsMultiplier, true); //row 8
			addAnimation("taunt", [104, 105, 106, 107, 108, 109, 109, 109, 109, 109], 5 * fpsMultiplier, false); //row 9
			
			//modify bounding box
			width = 62;
			height = 62;
			offset.x = 0;
			offset.y = 0;
		}
		//overrides
		override protected function playHook(action:String):void
		{
			switch(action)
			{
				case "idle":
					
				break;
				case "highPunch":
					FlxG.play(Registry.punch);
				break;
				case "highKick":
					FlxG.play(Registry.kick);
				break;
				case "lowKick":
					FlxG.play(Registry.sweep);
				break;
				case "lowPunch":
					FlxG.play(Registry.punch);
				break;
				case "highBlock":
				case "lowBlock":
					FlxG.play(Registry.block);
				break;
				case "highHit":
					FlxG.play(Registry.hit1);
					doHitEffects();
				break;
			}
		}
		//interface
		public function highPunch():void
		{
			play("highPunch", true);
		}
		public function highKick():void
		{
			play("highKick", true);
		}
		public function lowPunch():void
		{
			play("lowKick", true);
		}
		public function lowKick():void
		{
			play("lowPunch", true);
		}
		public function highBlock():void
		{
			play("highBlock", true);
		}
		public function lowBlock():void
		{
			play("lowBlock", true);
		}
		public function highInjury():void
		{
			play("highHit", true);
		}
		public function lowInjury():void
		{
			play("highHit", true);
		}
		public function taunt():void 
		{
			play("taunt", true);
		}
		public function youGotKnockedTheFuckOut():void 
		{
			alive = false;
			play("fall", true);
			FlxG.play(Registry.ko);
			//if alive == false then idle animation swaps for ko animation...
		}
	}
}
