package sprites 
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Gareth Williams
	 */
	public class PlayerShadow extends FlxSprite 
	{
		public function PlayerShadow(width:int, height:int) 
		{
			super();
			makeGraphic(width, height,0x00000000);
		}
		override public function makeGraphic(Width:uint,Height:uint,Color:uint=0xffffffff,Unique:Boolean=false,Key:String=null):FlxSprite
		{
			_bakedRotation = 0;
			_pixels = FlxG.createBitmap(Width,Height,Color,Unique,Key);
			width = frameWidth = _pixels.width;
			height = frameHeight = _pixels.height;
			var myShape:Shape = new Shape();
			var gfx:Graphics = myShape.graphics
			gfx.beginFill(0, 1);
				gfx.drawEllipse(0, 0, width, height);
			gfx.endFill();
			_pixels.draw(myShape);
			resetHelpers();
			return this;
		}
	}
}
