package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import org.flixel.FlxG;
	import org.flixel.FlxGame;
	import states.*;
	/**
	 * ...
	 * @author LoneWolfWilliams
	 */
	public class Main extends FlxGame 
	{
		[SWF(width="640", height="480")]
		public function Main():void 
		{
			super(320,240, CONFIG::debug ? GameState : TitleState ,2);
			FlxG.bgColor = 0xff333333;
		}
		
	}
	
}