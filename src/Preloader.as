package  
{
	import org.flixel.system.*;
	
	/**
	 * ...
	 * @author LoneWolfWilliams
	 * http://flashgamedojo.com/wiki/index.php?title=Preloader_%28Flixel%29
	 * 
	 */
	
	public class Preloader extends FlxPreloader
	{
		public function Preloader():void
		{
			className = "Main";
			super();
			
			minDisplayTime = 5;
		}
	}
}