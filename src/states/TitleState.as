package states
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.TweenNano;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.plugin.photonstorm.FlxBitmapFont;
	import org.flixel.plugin.photonstorm.FlxSpecialFX;
	import org.flixel.plugin.photonstorm.FX.StarfieldFX;
	/**
	 * ...
	 * @author LoneWolfWilliams
	 */
	public class TitleState extends FlxState
	{
		[Embed(source = "../sprites/logo.png")] private var Logo:Class;
		[Embed(source = "../sprites/worldwarriorfont.png")] private var WWFont:Class;
		
		private var m_instructionText:FlxBitmapFont;
		private var m_logo:FlxSprite;
		private var backgroundStarfield:StarfieldFX;
		private var background:FlxGroup = new FlxGroup();
		
		public function TitleState()
		{
			initStarfieldBackground();
			add(background);
			initLogo();
			initInstructionText();
		}
		
		override public function destroy():void
		{
			m_logo.destroy();
		}
		
		override public function update():void
		{
			doPlayerInput();
		}
		
		private function doPlayerInput():void 
		{
			if (FlxG.keys.any())
			{
				TweenMax.to(m_instructionText, 0.2, { delay:0.4, 
							startAt: { alpha:0 }, alpha:1, repeat:10, 
							yoyo:true, onComplete:OnTweenComplete, 
							onUpdate:OnTweenUpdate} );
			}
		}
		
		private function OnTweenComplete():void 
		{
			FlxG.switchState(new GameState());
		}
		
		private function OnTweenUpdate():void 
		{
			if (m_instructionText.alpha < 0.5)
			{
				m_instructionText.alpha = 0;
			}
			else
			{
				m_instructionText.alpha = 1;
			}
		}
		
		private function initStarfieldBackground():void 
		{
			if (FlxG.getPlugin(FlxSpecialFX) == null)
			{
				FlxG.addPlugin(new FlxSpecialFX);
			}
			
			backgroundStarfield = FlxSpecialFX.starfield();
			backgroundStarfield.setBackgroundColor(0xFFFFFF);
			backgroundStarfield.setStarSpeed(-1, 0);
			background.add(backgroundStarfield.create(0, 0, FlxG.width, FlxG.height, 200, StarfieldFX.STARFIELD_TYPE_2D));
		}
		
		private function initInstructionText():void 
		{
			m_instructionText = new FlxBitmapFont(WWFont, 12, 16, FlxBitmapFont.TEXT_SET3, 17, 8, 4, 4, 1);
			m_instructionText.multiLine = true;
			m_instructionText.text = "A GAME FOR TWO PLAYERS:\nPRESS ANY KEY TO START";
			m_instructionText.y = FlxG.height * 0.8;
			m_instructionText.x = (FlxG.width - m_instructionText.width) * 0.5
			add(m_instructionText);
		}
		
		private function initLogo():void 
		{
			m_logo = new FlxSprite(0, 0, Logo);
			m_logo.x = (FlxG.width - m_logo.width) * 0.5;
			m_logo.y = (FlxG.height - m_logo.height) * 0.5;
			add(m_logo);
		}
	}
}