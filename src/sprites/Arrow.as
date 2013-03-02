package sprites 
{
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Gareth Williams
	 */
	public class Arrow extends FlxSprite 
	{
		[Embed(source = "uparrows.png")] private var arrowImg:Class;
		//[Embed(source = "uparrowrotationscolour.png")] private var arrowImg:Class;
		public static var UP:int = 0;
		public static var DOWN:int = 1;
		public static var LEFT:int = 2;
		public static var RIGHT:int = 3;
		
		public static var CORRECT:String = "correct";
		public static var INCORRECT:String = "incorrect";
		public static var REGULAR:String = "regular";
		public static var BLANK:String = "blank";
		
		public function Arrow(X:Number, Y:Number, direction:int, state:String) 
		{
			//super(X, Y, arrowImg);
			super(X, Y);
			loadGraphic(arrowImg, true, false, 32);
			
			switch(direction)
			{
				case UP:
					this.showUpArrow(state);
					break;
				case DOWN:
					this.showDownArrow(state);
					break;
				case LEFT:
					this.showLeftArrow(state);
					break;
				case RIGHT:
					this.showRightArrow(state);
					break;
			}
		}
		public function showUpArrow(state:String):void
		{
			//this.angle = 0;
			this.frame = 0 + getFrameAdjustment(state);
			this.draw();
		}
		public function showDownArrow(state:String):void
		{
			//this.angle = 180;
			this.frame = 2 + getFrameAdjustment(state);
			this.draw();
		}
		public function showLeftArrow(state:String):void
		{
			//this.angle = 270;
			this.frame = 3 + getFrameAdjustment(state);
			this.draw();
		}
		public function showRightArrow(state:String):void
		{
			//this.angle = 90;
			this.frame = 1 + getFrameAdjustment(state);
			this.draw();
		}
		private function getFrameAdjustment(fromState:String):int
		{
			var modifier:int = 0;
			if (fromState == CORRECT)
			{
				modifier = 4;
			}
			else if (fromState == INCORRECT)
			{
				modifier = 8;
			}
			else if (fromState == BLANK)
			{
				modifier = 12;
			}
			
			return modifier
		}
	}
}