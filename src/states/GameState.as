package states
{
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Linear;
	import com.greensock.TweenMax;
	import flash.utils.Dictionary;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxRect;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.plugin.photonstorm.*;
	import simon.Simon;
	import simon.SimonEvent;
	import sprites.AnimationEvent;
	import sprites.Arrow;
	import sprites.Background;
	import sprites.IAnimationEventDispatcher;
	import sprites.IPlayer;
	import sprites.Ken;
	import sprites.Player;
	import sprites.Ryu;
	import util.DelayedCallback;
	
	
	/**
	 * ...
	 * @author Gareth Williams
	 */
	public class GameState extends FlxState
	{
		private var m_whosTurn:String;
		
		public static const LEFTS_TURN:String = "Left Players Turn";
		public static const RIGHTS_TURN:String = "Right Players Turn";
		public static const SEQUENCE_EXTENSION:String = "{player} Direction Added GET READY!";
		
		private static var ATTACK_TEXT:String = "Go!";
		private static var INTRODUCTION:String = "Welcome To Simon Fighter!\nIn this game players must repeat an ever growing sequence of directions";
		private static var SEQUENCE_TUTORIAL:String = "Player keys:";
		private static var ATTACK_TUTORIAL:String = "Now the {player} must remember the direction from the first round and the new direction added";
		private static var POST_ATTACK_TUTORIAL_SUCCESS:String = "{player} entry was correct, so they scored a hit on the other player";
		private static var POST_ATTACK_TUTORIAL_FAILURE:String = "{player} entry was incorrect, so the other player blocked their attack";
		private static var END_OF_TUTORIAL:String = "Next round their will be two directions in the sequence";
		
		public static const TEXT_COLOUR:uint = 0xFFFFFFFF;
		public static const HIGH_KICK:uint = 87;//these are the corresponding flash keycodes, but that is really arbitrary.
		public static const LOW_KICK:uint = 68;
		public static const HIGH_PUNCH:uint = 65;
		public static const LOW_PUNCH:uint = 69;//dudes :P
		
		private var m_sequenceExtensionTextDuration:int = 3;
		private var m_playerAttackTextDuration:int = 3;
		private var m_instructionTextDurationShort:int = 4;
		private var m_instructionTextDurationLong:int = 8;
		private var m_healthDecrement:int;
		
		private var m_simonEngine:Simon = new Simon();
		private var m_previousTurn:String;
		
		private var m_blankDisplay:ArrowDisplay;
		private var m_arrowDisplay:ArrowDisplay;
		
		//later on it would be nice if you could choose a player so we keep these reference names generic
		private var m_leftPlayer:Player;
		private var m_rightPlayer:Player;
		private var m_leftPlayerHealthBar:FlxBar;
		private var m_rightPlayerHealthBar:FlxBar;
		
		private var m_playerReferences:Dictionary = new Dictionary(true);
		private var m_playerMovementInPixels:int;
		
		private var m_leftPlayerKeyGraphic:FlxSprite;
		private var m_rightPlayerKeyGraphic:FlxSprite;
		private var m_onscreenMessage:Message;
		private var m_background:Background = new Background();
		private var m_midField:FlxGroup = new FlxGroup();
		private var m_foreGround:FlxGroup = new FlxGroup();
		
		internal var m_flagKeyBlock:Keyblock = new Keyblock();
		internal var m_sandbox:Dictionary = new Dictionary(false);
		
		override public function create():void 
		{
			FlxG.resetCameras(new LazyCamera(0, 0, FlxG.width, FlxG.height, 0));
			
			m_healthDecrement = CONFIG::debug == true ? 50 : 5; //max sequeunce length 20 ?
			m_playerMovementInPixels = 32;// / TOTAL_POINTS;
			m_whosTurn = Math.random() > 0.5 ? LEFTS_TURN : RIGHTS_TURN;
			m_previousTurn = m_whosTurn == LEFTS_TURN ? RIGHTS_TURN : LEFTS_TURN;
			//init game objects into groups
			initControlDisplay();
			initArrowDisplay();
			initPlayers();
			
			//game logic is driven by simon abstract.
			addSimonListeners();
			
			add(m_background);
			add(m_midField);
			add(m_foreGround);
			
			FlxG.camera.bounds = new FlxRect(0, 0, m_background.width, m_background.height);
			FlxG.camera.focusOn(m_leftPlayer.getMidpoint());
			
			//initialise game
			if (Registry.showTutorial)
			{
				doIntroductionTutorialScene();
			}
			else
			{
				doSequenceExtensionScene();
			}
		}
		
		override public function destroy():void //called on swap out of FlxGame::switchstate();
		{
			//sprite memory management is taken care of internally by flxgroup
			m_leftPlayer.removeEventListener(AnimationEvent.PLAYER_HIT_ANIMATION, this.onPlayerHitAnimationTriggered);
			m_rightPlayer.removeEventListener(AnimationEvent.PLAYER_HIT_ANIMATION, this.onPlayerHitAnimationTriggered);
			removeAnimationListeners();
			removeSimonListeners();
			m_simonEngine.destructor();
			super.destroy();
		}
		
//initialisers-------------------------------------------------------------------------------------

		
		private function initControlDisplay():void 
		{
			m_rightPlayerKeyGraphic = new FlxSprite(0, 0, Registry.WASD);
			m_rightPlayerKeyGraphic.scrollFactor = new FlxPoint(0, 0);
			m_rightPlayerKeyGraphic.y = FlxG.camera.height * 0.32;
			m_rightPlayerKeyGraphic.x = 25;
			m_midField.add(m_rightPlayerKeyGraphic);
			
			m_leftPlayerKeyGraphic = new FlxSprite(0, 0, Registry.UDLR);
			m_leftPlayerKeyGraphic.scrollFactor = new FlxPoint(0, 0);
			m_leftPlayerKeyGraphic.y = FlxG.camera.height * 0.32;
			m_leftPlayerKeyGraphic.x = FlxG.camera.width - m_leftPlayerKeyGraphic.width - 25;
			m_midField.add(m_leftPlayerKeyGraphic);
			
			hidePlayerControls();
		}
		private function initArrowDisplay():void 
		{
			m_blankDisplay = new ArrowDisplay(FlxG.camera.width * 0.5, FlxG.camera.height * 0.5);
			m_blankDisplay.y -= 45;
			m_blankDisplay.scrollFactor = new FlxPoint(0, 0);
			
			m_midField.add(m_blankDisplay);
			
			m_arrowDisplay = new ArrowDisplay(FlxG.camera.width * 0.5, FlxG.camera.height * 0.5);
			m_arrowDisplay.y -= 45;
			m_arrowDisplay.scrollFactor = new FlxPoint(0, 0);
			
			m_midField.add(m_arrowDisplay);
		}
		private function initPlayers():void 
		{
			m_leftPlayer = new Ken(m_background.width * 0.5, m_background.height - 82);
			m_rightPlayer = new Ryu(m_background.width * 0.5, m_background.height - 82);
			m_leftPlayer.addEventListener(AnimationEvent.PLAYER_HIT_ANIMATION, this.onPlayerHitAnimationTriggered);
			m_rightPlayer.addEventListener(AnimationEvent.PLAYER_HIT_ANIMATION, this.onPlayerHitAnimationTriggered);
			m_leftPlayer.x -= m_leftPlayer.width;
			
			m_playerReferences[LEFTS_TURN] = m_leftPlayer;
			m_playerReferences[RIGHTS_TURN] = m_rightPlayer;
			
			m_foreGround.add(m_leftPlayer);
			m_foreGround.add(m_rightPlayer);
			
			m_leftPlayerHealthBar = new FlxBar(8, 8, FlxBar.FILL_LEFT_TO_RIGHT, 130, 24, m_leftPlayer, "health");
			m_leftPlayerHealthBar.createFilledBar(0xFFFFFF00, 0xFFFF0000, true, 0xFFFFFFFF);
			m_leftPlayerHealthBar.scrollFactor = new FlxPoint(0, 0);
			
			m_rightPlayerHealthBar = new FlxBar(FlxG.width - (130 + 8), 8, FlxBar.FILL_LEFT_TO_RIGHT, 130, 24, m_rightPlayer, "health");
			m_rightPlayerHealthBar.createFilledBar(0xFFFFFF00, 0xFFFF0000, true, 0xFFFFFFFF);
			m_rightPlayerHealthBar.scrollFactor = new FlxPoint(0, 0);
			
			m_midField.add(m_leftPlayerHealthBar);
			m_midField.add(m_rightPlayerHealthBar);
		}

//overrides--------------------------------------------------------------------------------------------------

		override public function update():void
		{
			doPlayerInput();//handlers manage simonEngine outcomes
			super.update();
		}

//handlers---------------------------------------------------------------------------------------------------
		
		private function onEntryCorrect(event:SimonEvent):void
		{
			var action:uint = event.inputKeycode;
			displayArrow(action, Arrow.CORRECT);
			doHitAnimation(action);
		}
		private function onEntryIncorrect(event:SimonEvent):void
		{
			var action:uint = event.inputKeycode;
			displayArrow(action, Arrow.INCORRECT);
			doDefenseAnimation(action);
		}
		private function onFinalEntry(event:SimonEvent):void
		{
			m_flagKeyBlock.type = Keyblock.NON_CANCELLABLE;
			
			if (Player(m_playerReferences[m_whosTurn]).isPerformingActionSequence)
			{
				var forPlayer:IAnimationEventDispatcher = m_playerReferences[m_whosTurn]
				queueFunctionUntilAnimationCompleted(forPlayer, releaseKeyBlock);
				queueFunctionUntilAnimationCompleted(forPlayer, clearArrows);
				queueFunctionUntilAnimationCompleted(forPlayer, doHouseKeeping);
				listenForAnimationComplete(forPlayer);
			}
			else
			{
				doHouseKeeping();
			}
		}
		private function onPlayerHitAnimationTriggered(event:AnimationEvent):void
		{
			updateHealth();
			updatePositions();
		}
		private function onSequenceEnded(event:SimonEvent):void
		{
			switchTurns();
		}
		private function onPlayerAnimationComplete(event:AnimationEvent):void 
		{
			event.sprite.removeEventListener(AnimationEvent.ANIMATION_COMPLETE, onPlayerAnimationComplete);
			dequeueMethods(event.sprite);
		}
		private function dequeueMethods(forDispatcher:IAnimationEventDispatcher):void 
		{
			var functionQueue:Array = m_sandbox[forDispatcher];
			
			if (functionQueue == null)
			{
				return;
			}
				
			while(functionQueue.length > 0)
			{
				var unQueuedMethod:QueuedMethod = functionQueue.shift();//FILO
				var method:Function = unQueuedMethod.method;
				var params:Array = unQueuedMethod.params;
				method.apply(this, params);
			}
			//get rid of empty array
			m_sandbox[forDispatcher] = null;
		}
		
//scenes------------------------------------------------------------------------------------------------------
		
		private function doIntroductionTutorialScene():void 
		{
			m_flagKeyBlock.type = Keyblock.CANCELLABLE;
			
			displayText(INTRODUCTION, TEXT_COLOUR, m_instructionTextDurationLong);
			
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, releaseKeyBlock);
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, doSequenceExtensionTutorialScene);
			listenForAnimationComplete(m_onscreenMessage);
		}
		
		//explains what will happen next...
		private function doSequenceExtensionTutorialScene():void 
		{
			m_flagKeyBlock.type = Keyblock.CANCELLABLE;
			
			displayText(SEQUENCE_TUTORIAL, TEXT_COLOUR, m_instructionTextDurationLong);
			
			showPlayerControls();
			
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, hidePlayerControls);
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, releaseKeyBlock);
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, doSequenceExtensionScene);
			listenForAnimationComplete(m_onscreenMessage);
		}
		//computer picks a new random arrow for the sequence
		private function doSequenceExtensionScene():void
		{
			//FlxG.bgColor = 0xFF333333;
			m_flagKeyBlock.type = Keyblock.NON_CANCELLABLE; //this causes confusion if the player can skip - they accidentally enter their first attack
			
			var insertplayer:String;
			if (m_previousTurn == LEFTS_TURN)
			{
				insertplayer = "Left Player:";
			}
			else if (m_previousTurn == RIGHTS_TURN)
			{
				insertplayer = "Right Player:";
			}
			var playerTextColour:uint = 0xFF000000 | Player(m_playerReferences[m_previousTurn]).colour;
			displayText(SEQUENCE_EXTENSION.replace("{player}", insertplayer), 
						playerTextColour, m_sequenceExtensionTextDuration);
			
			var randomArrow:int = Math.floor(Math.random() * 3);
			switch (randomArrow) 
			{
				case 0:
					m_arrowDisplay.addArrow(Arrow.UP, Arrow.REGULAR, 1);
					m_simonEngine.inputAction(GameState.HIGH_KICK);
				break;
				case 1:
					m_arrowDisplay.addArrow(Arrow.DOWN, Arrow.REGULAR, 1);
					m_simonEngine.inputAction(GameState.LOW_KICK);
				break;
				case 2:
					m_arrowDisplay.addArrow(Arrow.LEFT, Arrow.REGULAR, 1);
					m_simonEngine.inputAction(GameState.HIGH_PUNCH);
				break;
				case 3:
					m_arrowDisplay.addArrow(Arrow.RIGHT, Arrow.REGULAR, 1);
					m_simonEngine.inputAction(GameState.LOW_PUNCH);
				break;
				default:
					throw new Error(randomArrow + ": is out of range");
			}
			
			
			var nextScene:Function = doAttackScene;
			if (m_simonEngine.sequenceLength == 2 && Registry.showTutorial)
			{
				nextScene = doAttackTutorialScene;
			}
			
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, releaseKeyBlock);
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, clearArrows);
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, nextScene);
			listenForAnimationComplete(m_onscreenMessage);
		}
		//explains what will happen in the attack tutorial section
		private function doAttackTutorialScene():void 
		{
			m_flagKeyBlock.type = Keyblock.CANCELLABLE;
			
			var insertplayer:String;
			if (m_whosTurn == LEFTS_TURN)
			{
				insertplayer = "Left player";
			}
			else if (m_whosTurn == RIGHTS_TURN)
			{
				insertplayer = "Right player";
			}
			
			displayText(ATTACK_TUTORIAL.replace("{player}", insertplayer), TEXT_COLOUR, m_instructionTextDurationShort);
				
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, releaseKeyBlock);
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, doAttackScene);
			listenForAnimationComplete(m_onscreenMessage);
		}
		
		private function doAttackScene():void
		{
			bringPlayerToFront(Player(m_playerReferences[m_whosTurn]));
			var playerTextColour:uint = 0xFF000000 | Player(m_playerReferences[m_whosTurn]).colour;
			displayText(ATTACK_TEXT, 
						playerTextColour, 
						m_playerAttackTextDuration);
			
			displayArrowPlaceholders();
			//events from simon engine drive next section of gameplay
		}
		
		private function doPostAttackTutorialScene():void
		{
			m_flagKeyBlock.type = Keyblock.CANCELLABLE;
			
			var attacker:IPlayer = m_playerReferences[m_whosTurn];
			var defender:IPlayer = m_playerReferences[m_previousTurn];
			
			var insertPlayer:String;
			if (m_whosTurn == LEFTS_TURN)
			{
				insertPlayer = "left Player's";
			}
			else if (m_whosTurn == RIGHTS_TURN)
			{
				insertPlayer = "right player's";
			}
			
			var feedback:String;
			if ((defender as Player).health < 100)
			{
				feedback = POST_ATTACK_TUTORIAL_SUCCESS.replace("{player}", insertPlayer); 
			}
			else
			{
				feedback = POST_ATTACK_TUTORIAL_FAILURE.replace("{player}", insertPlayer);
			}
			
			displayText(feedback, 0xFFFFFF, m_instructionTextDurationShort);
			
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, doEndTutorialScene);
			listenForAnimationComplete(m_onscreenMessage);
		}
		private function doEndTutorialScene():void 
		{
			m_flagKeyBlock.type = Keyblock.CANCELLABLE;
			displayText(END_OF_TUTORIAL, 0xFFFFFF, m_instructionTextDurationShort);
			
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, releaseKeyBlock);
			queueFunctionUntilAnimationCompleted(m_onscreenMessage, doSequenceExtensionScene);
			listenForAnimationComplete(m_onscreenMessage);
		}
		private function doGameOverScene():void
		{
			var loser:IPlayer = m_playerReferences[m_previousTurn];
			var direction:int;
			if (loser == m_leftPlayer)
			{
				direction = m_leftPlayer.x - 50;
			}
			else if (loser == m_rightPlayer)
			{
				direction = m_rightPlayer.x + 50;
			}
			
			if (direction > (m_background.width - 32))
			{
				direction = (m_background.width - 32);
			}
			else if (direction < 0)
			{
				direction = 0;
			}
			
			TweenMax.to(loser, 1.5, { onInit:loser.youGotKnockedTheFuckOut, 
						startAt: { y:m_background.height - 102 }, ease:Bounce.easeOut, y:m_background.height - 82, 
						onComplete: gotoGameOverState} );
			TweenMax.to(loser, 1.5, { x:direction });
		}
		//after the animations from the attack scene have completed we need
		//to branch appropriately
		private function doHouseKeeping():void 
		{
			var nextScene:Function = doSequenceExtensionScene;
			
			if (m_simonEngine.sequenceLength == 0 && Registry.showTutorial)
			{
				nextScene = doSequenceExtensionTutorialScene;
			}
			
			if (m_simonEngine.sequenceLength == 1 && Registry.showTutorial)
			{
				nextScene = doPostAttackTutorialScene;
			}
			
			if (m_simonEngine.sequenceLength == 2 && Registry.showTutorial)
			{
				Registry.showTutorial == false;
			}
			
			if (checkFatality())
			{
				nextScene = doGameOverScene;
			}
			
			nextScene();
		}
		
//animations---------------------------------------------------------------------------------------

		private function doPlayerInput():void
		{
			if (m_flagKeyBlock.type == Keyblock.NON_CANCELLABLE)
			{
				return;
			}
			
			if (m_flagKeyBlock.type == Keyblock.CANCELLABLE)
			{
				if (FlxG.keys.any() && m_onscreenMessage != null)
				{
					m_onscreenMessage.cancel();
				}
				return;
			}
			
			if (m_whosTurn == RIGHTS_TURN)
			{
				if (FlxG.keys.justReleased("UP"))//moves should be mutually exclusive 
				{
					m_simonEngine.inputAction(GameState.HIGH_KICK);
				}
				else if (FlxG.keys.justReleased("DOWN"))
				{
					m_simonEngine.inputAction(GameState.LOW_KICK);
				}
				else if (FlxG.keys.justReleased("LEFT"))
				{	
					m_simonEngine.inputAction(GameState.HIGH_PUNCH);
				}
				else if (FlxG.keys.justReleased("RIGHT"))
				{	
					m_simonEngine.inputAction(GameState.LOW_PUNCH);
				}
			}
			else if (m_whosTurn == LEFTS_TURN)
			{
				if (FlxG.keys.justReleased("W"))//moves should be mutually exclusive 
				{
					m_simonEngine.inputAction(GameState.HIGH_KICK);
				}
				else if (FlxG.keys.justReleased("S"))
				{
					m_simonEngine.inputAction(GameState.LOW_KICK);
				}
				else if (FlxG.keys.justReleased("A"))
				{	
					m_simonEngine.inputAction(GameState.HIGH_PUNCH);
				}
				else if (FlxG.keys.justReleased("D"))
				{	
					m_simonEngine.inputAction(GameState.LOW_PUNCH);
				}
			}
		}
		private function doHitAnimation(keycode:uint):void
		{
			//cast as interface for methods
			var attacker:IPlayer = m_playerReferences[m_whosTurn];
			var defender:IPlayer = m_playerReferences[m_previousTurn];
			
			switch(keycode)
			{
				case GameState.HIGH_KICK:
					attacker.highKick();
					defender.highInjury();
				break;
				case GameState.LOW_KICK:
					attacker.lowKick();
					defender.lowInjury();
				break;
				case GameState.HIGH_PUNCH:
					attacker.highPunch();
					defender.highInjury();
				break;
				case GameState.LOW_PUNCH:
					attacker.lowPunch();
					defender.lowInjury();
				break;
			}
		}
		private function doDefenseAnimation(keycode:uint):void
		{
			//cast as interface for methods
			var attacker:IPlayer = m_playerReferences[m_whosTurn];
			var defender:IPlayer = m_playerReferences[m_previousTurn];
			
			switch(keycode)
			{
				case GameState.HIGH_KICK:
					attacker.highKick();
					defender.highBlock();
				break;
				case GameState.LOW_KICK:
					attacker.lowKick();
					defender.lowBlock();
				break;
				case GameState.HIGH_PUNCH:
					attacker.highPunch();
					defender.highBlock();
				break;
				case GameState.LOW_PUNCH:
					attacker.lowPunch();
					defender.lowBlock();
				break;
			}
		}
		private function displayText(text:String, withColour:uint, forDuration:int = 1):void 
		{
			if (m_onscreenMessage !== null)
			{
				m_onscreenMessage.kill();//may not remove the reference due to garbage collection
				m_onscreenMessage = null;
			}
			
			var instruction:Message = new Message(text, forDuration, withColour);
			add(instruction);
			instruction.begin();
			m_onscreenMessage = instruction;
		}
		private function displayArrow(keycode:uint, state:String):void
		{
			switch(keycode)
			{
				case GameState.HIGH_KICK:
					m_arrowDisplay.addArrow(Arrow.UP, state, m_simonEngine.sequenceLength);
				break;
				case GameState.LOW_KICK:
					m_arrowDisplay.addArrow(Arrow.DOWN, state, m_simonEngine.sequenceLength);
				break;
				case GameState.HIGH_PUNCH:
					m_arrowDisplay.addArrow(Arrow.LEFT, state, m_simonEngine.sequenceLength);
				break;
				case GameState.LOW_PUNCH:
					m_arrowDisplay.addArrow(Arrow.RIGHT, state, m_simonEngine.sequenceLength);
				break;
			}
		}
		private function displayArrowPlaceholders():void
		{
			for (var i:int = 0; i<m_simonEngine.sequenceLength; i++)
			{
				m_blankDisplay.addArrow(0, Arrow.BLANK,  m_simonEngine.sequenceLength);
			}
		}

//helpers-----------------------------------------------------------------------------------------

		private function queueFunctionUntilAnimationCompleted(dispatcher:IAnimationEventDispatcher, doAction:Function, ...rest):void
		{
			if (m_sandbox[dispatcher] == null)
			{
				m_sandbox[dispatcher] = new Array();
			}
			m_sandbox[dispatcher].push(new QueuedMethod(doAction, rest));
		}
		private function checkFatality():Boolean
		{
			var isFatality:Boolean = false;
			var defender:Player = m_playerReferences[m_previousTurn];
			if (defender.health <= 0)
			{
				isFatality = true;
			}
			
			return isFatality;
		}
		private function updatePositions():void
		{
			var attacker:Player = m_playerReferences[m_whosTurn];
			var defender:Player = m_playerReferences[m_previousTurn];
			
			if (attacker == m_leftPlayer && m_rightPlayer.x < (m_background.width - 32) )
			{
				TweenMax.to(attacker, 0.3, { x: attacker.x + m_playerMovementInPixels, ease:Linear.easeNone} );
				TweenMax.to(defender, 0.3, { x: defender.x + m_playerMovementInPixels, ease:Linear.easeNone } );
			}
			if (attacker == m_rightPlayer && m_leftPlayer.x > 0)
			{
				TweenMax.to(attacker, 0.3, { x: attacker.x - m_playerMovementInPixels, ease:Linear.easeNone } );
				TweenMax.to(defender, 0.3, { x: defender.x - m_playerMovementInPixels, ease:Linear.easeNone } );
			}
		}
		private function updateHealth():void
		{
			var defender:Player = m_playerReferences[m_previousTurn];
			defender.health -= m_healthDecrement;
		}
		private function switchTurns():void
		{
			m_previousTurn = m_whosTurn;
			if (m_whosTurn == LEFTS_TURN)
			{
				m_whosTurn = RIGHTS_TURN;
			}
			else
			{
				m_whosTurn = LEFTS_TURN;
			}
			
			FlxG.camera.follow(m_playerReferences[m_whosTurn] as Player);
		}
		private function clearArrows():void
		{
			m_blankDisplay.clearArrows();
			m_arrowDisplay.clearArrows();
		}
		private function releaseKeyBlock():void 
		{
			m_flagKeyBlock.type = Keyblock.NONE;
		}
		private function bringPlayerToFront(playerToFront:Player):void 
		{
			if (m_foreGround.members[0] == playerToFront)
			{
				m_foreGround.members.reverse();
			}
		}
		private function showPlayerControls():void 
		{
			m_leftPlayerKeyGraphic.visible = true;
			m_rightPlayerKeyGraphic.visible = true;
		}
		private function hidePlayerControls():void 
		{
			m_leftPlayerKeyGraphic.visible = false;
			m_rightPlayerKeyGraphic.visible = false;
		}
		private function gotoGameOverState():void 
		{
			Registry.showTutorial = false;
			var winnerIsLeftPlayer:Boolean = (m_whosTurn == LEFTS_TURN)
			new DelayedCallback(FlxG, 2, FlxG.switchState, new WinnerState(winnerIsLeftPlayer));
		}
		private function listenForAnimationComplete(to:IAnimationEventDispatcher):void
		{
			to.addEventListener(AnimationEvent.ANIMATION_COMPLETE, this.onPlayerAnimationComplete);
		}
		private function removeAnimationListeners():void
		{
			if (m_leftPlayer.hasEventListener(AnimationEvent.ANIMATION_COMPLETE))
			{
				m_leftPlayer.addEventListener(AnimationEvent.ANIMATION_COMPLETE, this.onPlayerAnimationComplete);
			}
			if (m_rightPlayer.hasEventListener(AnimationEvent.ANIMATION_COMPLETE))
			{
				m_leftPlayer.addEventListener(AnimationEvent.ANIMATION_COMPLETE, this.onPlayerAnimationComplete);
			}
		}
		private function addSimonListeners():void
		{
			m_simonEngine.addEventListener(SimonEvent.ENTRY_CORRECT, this.onEntryCorrect);
			m_simonEngine.addEventListener(SimonEvent.ENTRY_INCORRECT, this.onEntryIncorrect);
			m_simonEngine.addEventListener(SimonEvent.FINAL_ENTRY, this.onFinalEntry);
			m_simonEngine.addEventListener(SimonEvent.SEQUENCE_ENDED, this.onSequenceEnded);
		}
		private function removeSimonListeners():void
		{
			m_simonEngine.removeEventListener(SimonEvent.ENTRY_CORRECT, this.onEntryCorrect);
			m_simonEngine.removeEventListener(SimonEvent.ENTRY_INCORRECT, this.onEntryIncorrect);
			m_simonEngine.removeEventListener(SimonEvent.FINAL_ENTRY, this.onFinalEntry);
			m_simonEngine.removeEventListener(SimonEvent.SEQUENCE_ENDED, this.onSequenceEnded);
		}
	}
}
internal class QueuedMethod
{
	public var method:Function;
	public var params:Array;
	public function QueuedMethod(method:Function, params:Array)
	{
		this.method = method;
		this.params = params;
	}
}
internal class Keyblock
{
	public static const NONE:int = 0;
	public static const CANCELLABLE:int = 1;
	public static const NON_CANCELLABLE:int = 2;
	
	public var type:int = NONE;
}