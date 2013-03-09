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
		private var arrowLayer:FlxGroup = new FlxGroup();
		private var onscreenArrows:Array = new Array();
		
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
		public function addArrow(pointing:int, state:String, sequenceLength:int):void
		{
			var arrow:Arrow = new Arrow(this.x, this.y, pointing, state);
			onscreenArrows.push(arrow);
			arrowLayer.add(arrow);
			
			updateArrowScale(sequenceLength);
			updateArrowPositions(sequenceLength);
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
		private function updateArrowPositions(sequenceLength:int):void
		{
			var arrowWidth:Number = (32 * onscreenArrows[0].scale.x);
			var totalWidth:Number = sequenceLength * arrowWidth;
			
			var offsetX:Number = this.x - totalWidth * 0.5;
			trace(sequenceLength);
			
			for (var a:int = 0; a < onscreenArrows.length; a++)
			{
				var current:Arrow = onscreenArrows[a];
				current.x = offsetX + a * (32 * current.scale.x);
			}
		}
		private function updateArrowScale(sequenceLength:int):void
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
				//updateArrowPositions();
			}
		}
	}
}