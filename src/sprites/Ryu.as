package sprites 
{
	import flash.display.BlendMode;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Gareth Williams
	 */
	public class Ryu extends Player implements IPlayer
	{
		public function Ryu(X:Number = 0, Y:Number = 0, SimpleGraphic:Class = null) 
		{
			super(0xC500E0, X, Y, SimpleGraphic);
			
			loadGraphic(Registry.kenSheetImg, true, true, 117, 75);
			addAnimation("idle", [0, 1, 2, 3, 4, 5], 5 * fpsMultiplier, true);//row 1
			addAnimation("highPunch", [13, 14, 15, 16, 17, 18, 19], 7 * fpsMultiplier, false);//row2
			addAnimation("highKick", [26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38], 13 * fpsMultiplier, false);
			addAnimation("lowKick", [39, 40, 41, 42, 43, 44, 45, 46], 8 * fpsMultiplier, false);
			addAnimation("lowPunch", [52, 53, 54, 55, 56], 5 * fpsMultiplier, false);
			addAnimation("highBlock", [65, 66, 67, 68, 69, 70, 71], 7 * fpsMultiplier, false);
			addAnimation("lowBlock", [78, 79, 80, 81, 82, 83, 84], 7 * fpsMultiplier, false);
			addAnimation("highHit", [91], 1 * fpsMultiplier, false);
			addAnimation("fall", [92], 1 * fpsMultiplier, false);
			addAnimation("KO", [93], 1 * fpsMultiplier, false);
			addAnimation("taunt", [104, 105, 106, 107, 108, 109, 109, 109, 109, 109], 5 * fpsMultiplier, false); //row 9
			
			//modify bounding box
			width = 62;
			height = 62;
			offset.x = 117-width;
			offset.y = 0;
			//face left
			this.facing = 1;
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
