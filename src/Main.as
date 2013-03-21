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
	
	[SWF(width = "640", height = "480")]
	[Frame(factoryClass="Preloader")] //Tells Flixel to use the default preloader 
		
	public class Main extends FlxGame 
	{
		public function Main():void 
		{
			super(320,240, CONFIG::debug ? GameState : TitleState ,2);
			FlxG.bgColor = 0xff333333;
		}
		
	}
	
}