package  
{
	import mx.core.FlexSprite;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.plugin.photonstorm.FlxBitmapFont;
	import org.flixel.plugin.photonstorm.FlxSpecialFX;
	import org.flixel.plugin.photonstorm.FX.StarfieldFX;
	/**
	 * ...
	 * @author LoneWolfWilliams
	 */
	public class Registry 
	{
		[Embed(source = "/audio/Coin [SFX].mp3")] public static const Coin:Class;
		
		[Embed(source = "/sprites/logo.png")] public static const Logo:Class;
		[Embed(source = "/sprites/worldwarriorfont.png")] public static const WWFont:Class;
		
		[Embed(source = "/sprites/udlr.png")] public static const UDLR:Class;
		[Embed(source = "/sprites/wasd.png")] public static const WASD:Class;
		
		[Embed(source = "/sprites/kenSheet.png")] public static const kenSheetImg:Class;
		
		[Embed(source = "/audio/206 [SFX].mp3")] public static const punch:Class;
		[Embed(source = "/audio/207 [SFX].mp3")] public static const kick:Class;
		[Embed(source = "/audio/208 [SFX].mp3")] public static const sweep:Class;
		[Embed(source = "/audio/215 [SFX].mp3")] public static const hit1:Class;
		[Embed(source = "/audio/214 [SFX].mp3")] public static const block:Class;
		[Embed(source = "/audio/216 [SFX].mp3")] public static const hit2:Class;
		[Embed(source = "/audio/ko [SFX].mp3")]  public static const ko:Class;
		
		[Embed(source = "/sprites/kenSheet2.png")] public static const ryuSheetImg:Class;
		
		[Embed(source="/sprites/sparks.png")] public static const sparkParticlesImg:Class;
		
		[Embed(source = "/sprites/kenPortrait.gif")] public static const LeftKen:Class;
		[Embed(source = "/sprites/kenPortrait2.gif")] public static const RightKen:Class;
		
		[Embed(source = "/sprites/pocketfighter-BG1.gif")] public static const Background:Class;
		
		[Embed(source = "/audio/stage end[SFX].mp3")]  public static const StageEnd:Class;
		
		private static var m_starfieldBackground:FlxGroup = null;
		public static function get starfieldBackground():FlxGroup
		{
			if (m_starfieldBackground == null)
			{
				m_starfieldBackground = createStarField();
			}
			return m_starfieldBackground;
		}
		private static function createStarField():FlxGroup
		{
			if (FlxG.getPlugin(FlxSpecialFX) == null)
			{
				FlxG.addPlugin(new FlxSpecialFX);
			}
			
			var background:FlxGroup = new FlxGroup();
			var starfieldInstance:StarfieldFX = FlxSpecialFX.starfield();
			starfieldInstance.setBackgroundColor(0xFFFFFF);
			starfieldInstance.setStarSpeed(-1, 0);
			background.add(starfieldInstance.create(0, 0, FlxG.width, FlxG.height, 200, StarfieldFX.STARFIELD_TYPE_2D));
			
			return background;
		}
		//private static var m_worldwarriorBitmapFont:FlxBitmapFont = null;
		public static function get WorldWarriorBitmapFont():FlxBitmapFont
		{
			/*
			if (m_worldwarriorBitmapFont == null)
			{
				m_worldwarriorBitmapFont = new FlxBitmapFont(WWFont, 12, 16, FlxBitmapFont.TEXT_SET3, 17, 8, 4, 4, 1);
			}
			
			m_worldwarriorBitmapFont.text = "";
			*/
			
			return new FlxBitmapFont(WWFont, 12, 16, FlxBitmapFont.TEXT_SET3, 17, 8, 4, 4, 1);
		}
		//use to turn off tutorial on subsequent play-throughs
		
		public static var isFirstRun:Boolean = CONFIG::debug == true ? false : true;
	}
}