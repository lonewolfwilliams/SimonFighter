package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import org.flixel.FlxG;
	import org.flixel.FlxGame;
	import states.GameState;
	/**
	 * ...
	 * @author LoneWolfWilliams
	 */
	public class Main extends FlxGame 
	{
		
		public function Main():void 
		{
			super(320,240,states.GameState,2);
			FlxG.bgColor = 0xff333333;
		}
		
	}
	
}