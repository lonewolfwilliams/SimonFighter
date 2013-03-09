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
		private var m_instructionText:FlxBitmapFont;
		private var m_logo:FlxSprite;
		private var m_background:FlxGroup;
		private var m_flagStartPressed:Boolean = false;
		
		override public function create():void 
		{
			m_background = Registry.starfieldBackground;
			add(m_background);
			initLogo();
			initInstructionText();
			
			FlxG.playMusic(Registry.Theme, 1.0);
		}
		
		override public function destroy():void
		{
			 //otherwise they gets destroyed...
			remove(m_background);
			remove(m_instructionText);
			super.destroy();
		}
		
		override public function update():void
		{
			doPlayerInput();
		}
		
		private function doPlayerInput():void 
		{
			if (false == FlxG.keys.justReleased("T") &&
				false == FlxG.keys.justReleased("S"))
			{
				return;
			}
			
			if (m_flagStartPressed)
			{
				return;
			}
			
			if (FlxG.keys.justReleased("T"))
			{
				Registry.showTutorial = true;
			}
			
			if (FlxG.keys.justReleased("S"))
			{
				Registry.showTutorial = false;
			}
			
			m_flagStartPressed = true;
			
			FlxG.play(Registry.Coin);
			
			TweenMax.to(m_instructionText, 0.2, { delay:0.4, 
						startAt: { alpha:0 }, alpha:1, repeat:10, 
						yoyo:true, onComplete:OnTweenComplete, 
						onUpdate:OnTweenUpdate} );
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
		
		private function initInstructionText():void 
		{
			m_instructionText = Registry.WorldWarriorBitmapFont;
			m_instructionText.multiLine = true;
			m_instructionText.text = "A GAME FOR TWO PLAYERS:\nS TO START T FOR TUTORIAL";
			m_instructionText.y = FlxG.height * 0.8;
			m_instructionText.x = (FlxG.width - m_instructionText.width) * 0.5
			add(m_instructionText);
		}
		
		private function initLogo():void 
		{
			m_logo = new FlxSprite(0, 0, Registry.Logo);
			m_logo.x = (FlxG.width - m_logo.width) * 0.5;
			m_logo.y = (FlxG.height - m_logo.height) * 0.5;
			add(m_logo);
		}
	}
}