package  
{
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import org.flixel.FlxBasic;
	import org.flixel.FlxCamera;
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.plugin.photonstorm.FlxMath;
	
	/**
	 * ...
	 * @author LoneWolfWilliams
	 * 
	 * the camera always follows it's target with an amount of lag
	 * this allows for smooth transitions on changing camera follow
	 * 
	 */
	public class LazyCamera extends FlxCamera 
	{
		private var m_ghostPoint:FlxObject = new FlxObject();
		public function LazyCamera(X:int,Y:int,Width:int,Height:int,Zoom:Number=0)
		{
			super(X, Y, Width, Height, Zoom);
		}
		public override function follow(Target:FlxObject, Style:uint=STYLE_LOCKON):void
		{
			super.follow(m_ghostPoint);
			TweenMax.to(m_ghostPoint, 1, { 	x:Target.getMidpoint(_point).x,
											y:Target.getMidpoint(_point).y,
											onComplete:super.follow, onCompleteParams:[Target, Style]} );
		}
		public override function focusOn(Point:FlxPoint):void
		{
			super.focusOn(Point);
			
			m_ghostPoint.x = Point.x;
			m_ghostPoint.y = Point.y;
		}
	}
}