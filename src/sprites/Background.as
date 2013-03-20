package sprites 
{
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSave;
	import org.flixel.FlxSprite;
	import org.flixel.plugin.photonstorm.FlxGradient;
	/**
	 * ...
	 * @author LoneWolfWilliams
	 * 
	 * new animated background a combination of sprites and a static png
	 */
	public class Background extends FlxGroup
	{
		public function get width():int
		{
			return m_backgroundGraphic.width;
		}
		
		public function get height():int 
		{
			return m_backgroundGraphic.height;
		}
		
		private var m_backgroundGraphic:FlxSprite
		public function Background() 
		{
			m_backgroundGraphic = new FlxSprite(0, 0, Registry.Background);
			add(m_backgroundGraphic);
			
			AddCammy();
			AddDeejay();
			AddHonda();
			AddGuile();
			AddHawk();
			AddPonyTails();
			
			var gradiant:FlxSprite = new FlxSprite();
			FlxGradient.overlayGradientOnFlxSprite(gradiant, m_backgroundGraphic.width, m_backgroundGraphic.height * 0.5, 
													[0xAA000000, 0xAA000000, 0x00], 0, 
													m_backgroundGraphic.height - FlxG.camera.height);
			add(gradiant);
		}
		
		private function AddPonyTails():void 
		{
			var ponytails:FlxSprite = new FlxSprite();
			ponytails.loadGraphic(Registry.BGPonyTails, true, false, 45, 38);
			ponytails.addAnimation("idle", [4, 3, 5, 2, 0, 1], 5, true);//1 column
			
			add(ponytails);
			
			ponytails.x = 550;
			ponytails.y = 236;
			
			ponytails.play("idle");
		}
		
		private function AddHawk():void 
		{
			var hawk:FlxSprite = new FlxSprite();
			hawk.loadGraphic(Registry.BGHawk, true, false, 57, 39);
			hawk.addAnimation("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 5, true);//1 column
			
			add(hawk);
			
			hawk.x = 1;
			hawk.y = 221;
			
			hawk.play("idle");
		}
		
		private function AddGuile():void 
		{
			var guile:FlxSprite = new FlxSprite();
			guile.loadGraphic(Registry.BGGuile, true, false, 70, 45);
			guile.addAnimation("idle", [3, 4, 2, 1, 0], 5, true);//1 column
			
			add(guile);
			
			guile.x = 120;
			guile.y = 249;
			
			guile.play("idle");
		}
		
		private function AddHonda():void 
		{
			var honda:FlxSprite = new FlxSprite();
			honda.loadGraphic(Registry.BGHonda, true, false, 63, 67);
			honda.addAnimation("idle", [0, 1, 2], 5, true);//1 column
			
			add(honda);
			
			honda.x = 353;
			honda.y = 234;
			
			honda.play("idle");
		}
		
		private function AddDeejay():void 
		{
			var deejay:FlxSprite = new FlxSprite();
			deejay.loadGraphic(Registry.BGDeejay, true, false, 48, 34);
			deejay.addAnimation("idle", [6, 8, 7, 5, 4, 1, 3, 2, 0], 5, true);//1 row
			
			add(deejay);
			
			deejay.x = 304;
			deejay.y = 229;
			
			deejay.play("idle");
		}
		
		private function AddCammy():void 
		{
			var cammy:FlxSprite = new FlxSprite();
			cammy.loadGraphic(Registry.BGCammy, true, false, 51, 66);
			cammy.addAnimation("idle", [5, 4, 6, 3, 1, 0, 2], 5, true);//1 column
			
			add(cammy);
			
			cammy.x = 209;
			cammy.y = 227;
			
			cammy.play("idle");
		}
		
	}

}