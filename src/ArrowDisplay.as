package  
{
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import sprites.Arrow;
	
	/**
	 * ...
	 * @author Gareth Williams
	 * draws the sequence of arrows input onscreen
	 */
	public class ArrowDisplay extends FlxObject
	{
		private const UNINITIALISED:int = -1;
		
		private var arrowLayer:FlxGroup = new FlxGroup();
		private var onscreenArrows:Array = new Array();
		private var sequenceLength:int = UNINITIALISED;
		
		public function ArrowDisplay(X:Number = 0, Y:Number = 0, Width:Number = 0, Height:Number = 0) 
		{
			super(X, Y, Width, Height);
		}
		override public function destroy():void
		{
			while(onscreenArrows.length)
			{
				var current:Arrow = onscreenArrows.pop();
				arrowLayer.remove(current);
				current.destroy();
			}
		}
		public function addArrow(pointing:int, state:String, sequenceLength:int = UNINITIALISED):void
		{
			this.sequenceLength = sequenceLength;
			
			var arrow:Arrow = new Arrow(this.x, this.y, pointing, state);
			onscreenArrows.push(arrow);
			arrowLayer.add(arrow);
			
			updateArrowPositions();
			updateArrowScale();
		}
		public function clearArrows():void
		{
			while(onscreenArrows.length)
			{
				var current:Arrow = onscreenArrows.pop();
				arrowLayer.remove(current);
				current.destroy();
			}
		}
		//overrides
		override public function update():void
		{
			for each (var a:Arrow in onscreenArrows)
			{
				a.update();
			}
		}
		override public function draw():void
		{
			for each (var a:Arrow in onscreenArrows)
			{
				a.draw();
			}
		}
		//helpers
		private function updateArrowPositions():void
		{
			var totalWidth:Number;
			if (sequenceLength == UNINITIALISED)
			{
				totalWidth = onscreenArrows.length * onscreenArrows[0].width;
			}
			else
			{
				totalWidth = sequenceLength * 32;
			}
			
			var offsetX:Number = this.x - totalWidth * 0.5;
			for (var a:int = 0; a < onscreenArrows.length; a++)
			{
				var current:Arrow = onscreenArrows[a];
				current.x = offsetX + a * current.width;
			}
		}
		private function updateArrowScale():void
		{
			var totalWidth:Number = sequenceLength * 32;
			if (totalWidth > FlxG.width)
			{
				var scaleTo:Number = FlxG.width / totalWidth;
				for (var a:int = 0; a < onscreenArrows.length; a++)
				{
					var current:Arrow = onscreenArrows[a];
					current.antialiasing = true;
					current.scale = new FlxPoint(scaleTo, scaleTo);
				}
				updateArrowPositions();
			}
		}
	}
}