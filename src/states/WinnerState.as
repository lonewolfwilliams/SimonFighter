package states 
{
	import mx.core.FlexSprite;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.plugin.photonstorm.FlxBitmapFont;
	import org.flixel.plugin.photonstorm.FlxSpecialFX;
	import org.flixel.plugin.photonstorm.FX.StarfieldFX;
	import sprites.IPlayer;
	
	/**
	 * ...
	 * @author Gareth Williams
	 * display the familiar winners portrait and not so familiar bragging text :)
	 */
	public class WinnerState extends FlxState
	{
		private var m_background:FlxGroup;
		private var m_flagContinuePressed:Boolean = false;
		private var m_titleText:FlxBitmapFont;
		private var m_braggingText:FlxBitmapFont;
		private var m_portrait:FlxSprite;
		private var m_winnerIsLeftPlayer:Boolean;
		
		public function WinnerState(winnerIsLeftPlayer:Boolean = true) 
		{
			m_winnerIsLeftPlayer = winnerIsLeftPlayer;
		}
		
		public override function create():void 
		{
			m_background = Registry.starfieldBackground;
			add(m_background);
			
			initKenGraphic(m_winnerIsLeftPlayer);
			initTitle(m_winnerIsLeftPlayer);
			initBraggingText(m_winnerIsLeftPlayer);
			
			FlxG.music.stop();
			FlxG.play(Registry.StageEnd);
		}
		
		override public function destroy():void 
		{
			//remove otherwise they will be destroyed.
			remove(m_background);
			remove(m_braggingText);
			
			super.destroy();
		}
		
		private function initTitle(winnerIsLeftPlayer:Boolean):void 
		{
			m_titleText = Registry.WorldWarriorBitmapFont;
			
			if (winnerIsLeftPlayer)
			{
				m_titleText.text = "Left Player Wins!";
			}
			else
			{
				m_titleText.text = "Right Player Wins!";
			}
			
			m_titleText.y = FlxG.height * 0.1;
			m_titleText.x = (FlxG.width - m_titleText.width) * 0.5;
			
			add(m_titleText);
		}
		
		private function initBraggingText(winnerIsLeftPlayer:Boolean):void 
		{
			m_braggingText = Registry.WorldWarriorBitmapFont;
			
			m_braggingText.multiLine = true;
			m_braggingText.setFixedWidth(FlxG.width * 0.6, FlxBitmapFont.ALIGN_LEFT);
			
			m_braggingText.text = "Attack me\nif you dare,\nI will\ncrush you."
			
			m_braggingText.y = m_portrait.y + m_portrait.height - m_braggingText.height;
			m_braggingText.x = FlxG.width * 0.55;
			
			add(m_braggingText);
		}
		
		private function initKenGraphic(winnerIsLeftPlayer:Boolean):void 
		{
			if (winnerIsLeftPlayer)
			{
				m_portrait = new FlxSprite(0, 0, Registry.LeftKen);
			}
			else
			{
				m_portrait = new FlxSprite(0, 0, Registry.RightKen);
			}
			
			m_portrait.y = (FlxG.height - m_portrait.height) * 0.5;
			m_portrait.x = FlxG.width * 0.3 - m_portrait.width * 0.5;
			add(m_portrait);
		}
		
		override public function update():void
		{
			doPlayerInput();
		}
		
		private function doPlayerInput():void 
		{
			if (FlxG.keys.any() && false == m_flagContinuePressed)
			{
				m_flagContinuePressed = true;
				FlxG.switchState(new TitleState());
			}
		}
	}
}