package states
{
	import flash.utils.Dictionary;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import simon.Simon;
	import simon.SimonEvent;
	import sprites.AnimationEvent;
	import sprites.Arrow;
	import sprites.IAnimationEventDispatcher;
	import sprites.IPlayer;
	import sprites.Ken;
	import sprites.Player;
	import sprites.PlayerShadow;
	import sprites.Ryu;
	
	import org.flixel.plugin.photonstorm.*;
	
	/**
	 * ...
	 * @author Gareth Williams
	 */
	public class GameState extends FlxState
	{
		public static var whosTurn:String;
		
		public static var LEFTS_TURN:String = "Left Players Turn";
		public static var RIGHTS_TURN:String = "Right Players Turn";
		public static var SEQUENCE_EXTENSION:String = "Next item in the sequence";
		private static var ATTACK_TEXT:String = "Repeat the next {num} items in the sequence";
		
		public static var HIGH_KICK:uint = 87;//these are the corresponding flash keycodes, but that is really arbitrary.
		public static var LOW_KICK:uint = 68;
		public static var HIGH_PUNCH:uint = 65;
		public static var LOW_PUNCH:uint = 69;//dudes :P
		//private static var TOTAL_POINTS:uint = 10;
		
		private var sequenceExtensionTextDuration:int = 1;
		private var playerAttackTextDuration:int = 2;
		private var healthDecrement:int = 10;
		
		private var simonEngine:Simon = new Simon();
		private var previousTurn:String;
		
		private var blankDisplay:ArrowDisplay;
		private var arrowDisplay:ArrowDisplay;
		//later on it would be nice if you could choose a player so we keep these reference names generic
		private var leftPlayer:Player;
		private var rightPlayer:Player;
		//private var shadow:PlayerShadow;
		private var leftPlayerHealthBar:FlxBar;
		private var rightPlayerHealthBar:FlxBar;
		//private var rightPlayerHealth:FlxBar;
		private var playerReferences:Dictionary = new Dictionary(true);
		private var keyBlock:Boolean = false;
		private var playerMovementInPixels:int;
		
		private var cx:Number = FlxG.width / 2;
		private var cy:Number = FlxG.height / 2;
		
		private var sandbox:Dictionary = new Dictionary(false);
		
		private var onscreenMessage:Message;
		private var backgroundGraphic:FlxSprite;
		private var background:FlxGroup = new FlxGroup();
		private var midField:FlxGroup = new FlxGroup();
		private var foreGround:FlxGroup = new FlxGroup();
		
		public function GameState() 
		{
			super();
			playerMovementInPixels = FlxG.width / 10;// / TOTAL_POINTS;
			whosTurn = Math.random() > 0.5 ? LEFTS_TURN : RIGHTS_TURN;
			previousTurn = whosTurn == LEFTS_TURN ? RIGHTS_TURN : LEFTS_TURN;
			//init game objects into groups
			initArrowDisplay();
			initPlayers();
			//game logic is driven by simon abstract.
			addSimonListeners();
			//add groups
			add(midField);
			add(foreGround);
			
			//initialise game
			doSequenceExtensionScene();
		}
		override public function destroy():void //called on swap out of FlxGame::switchstate();
		{
			//sprite memory management is taken care of internally by flxgroup
			leftPlayer.removeEventListener(AnimationEvent.PLAYER_HIT_ANIMATION, this.onPlayerHitAnimationTriggered);
			rightPlayer.removeEventListener(AnimationEvent.PLAYER_HIT_ANIMATION, this.onPlayerHitAnimationTriggered);
			removeAnimationListeners();
			removeSimonListeners();
			simonEngine.destructor();
			super.destroy();
		}
		
//initialisers-------------------------------------------------------------------------------------

		private function initArrowDisplay():void 
		{
			blankDisplay = new ArrowDisplay(cx, cy);
			blankDisplay.y -= 45;
			midField.add(blankDisplay);
			arrowDisplay = new ArrowDisplay(cx, cy);
			arrowDisplay.y -= 45;
			midField.add(arrowDisplay);
		}
		private function initPlayers():void 
		{
			//shadow	= new PlayerShadow(150, 30);
			leftPlayer = new Ken(cx, cy);
			rightPlayer = new Ryu(cx, cy);
			leftPlayer.addEventListener(AnimationEvent.PLAYER_HIT_ANIMATION, this.onPlayerHitAnimationTriggered);
			rightPlayer.addEventListener(AnimationEvent.PLAYER_HIT_ANIMATION, this.onPlayerHitAnimationTriggered);
			//shadow.x = cx - shadow.width * 0.5;
			//shadow.y = (leftPlayer.y + leftPlayer.height);
			//shadow.alpha = 0.2;
			leftPlayer.x -= leftPlayer.width;
			playerReferences[LEFTS_TURN] = leftPlayer;
			//leftPlayer.health = TOTAL_POINTS / 2;
			//rightPlayer.health = TOTAL_POINTS / 2;
			playerReferences[RIGHTS_TURN] = rightPlayer;
			//foreGround.add(shadow);
			foreGround.add(leftPlayer);
			foreGround.add(rightPlayer);
			
			leftPlayerHealthBar = new FlxBar(8, 8, FlxBar.FILL_LEFT_TO_RIGHT, 130, 24, leftPlayer, "health");
			leftPlayerHealthBar.createFilledBar(0xFFFFFF00, 0xFFFF0000, true, 0xFFFFFFFF);
			rightPlayerHealthBar = new FlxBar(FlxG.width - (130 + 8), 8, FlxBar.FILL_LEFT_TO_RIGHT, 130, 24, rightPlayer, "health");
			rightPlayerHealthBar.createFilledBar(0xFFFFFF00, 0xFFFF0000, true, 0xFFFFFFFF);
			midField.add(leftPlayerHealthBar);
			midField.add(rightPlayerHealthBar);
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
			keyBlock = true;
			if (Player(playerReferences[whosTurn]).isPerformingActionSequence)
			{
				var forPlayer:IAnimationEventDispatcher = playerReferences[whosTurn]
				queueFunctionUntilAnimationCompleted(forPlayer, releaseKeyBlock);
				queueFunctionUntilAnimationCompleted(forPlayer, clearArrows);
				queueFunctionUntilAnimationCompleted(forPlayer, doSequenceExtensionScene);
				listenForAnimationComplete(forPlayer);
			}
			else
			{
				doSequenceExtensionScene();
			}
		}
		private function onPlayerHitAnimationTriggered(event:AnimationEvent):void
		{
			updateHealth();
			updatePositions();
			checkFatality();
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
			var functionQueue:Array = sandbox[forDispatcher];
			
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
			sandbox[forDispatcher] = null;
		}
		
//scenes------------------------------------------------------------------------------------------------------

		//computer picks a new random arrow for the sequence
		private function doSequenceExtensionScene():void
		{
			FlxG.bgColor = 0xFF333333;
			keyBlock = true; //attack scene needs to pause the game while the player reads the text
			//hideOtherPlayer();
			displayText(SEQUENCE_EXTENSION, 0xFFFFFFFF, sequenceExtensionTextDuration);
			
			var randomArrow:int = Math.floor(Math.random() * 3);
			switch (randomArrow) 
			{
				case 0:
					arrowDisplay.addArrow(Arrow.UP, Arrow.REGULAR);
					simonEngine.inputAction(GameState.HIGH_KICK);
				break;
				case 1:
					arrowDisplay.addArrow(Arrow.DOWN, Arrow.REGULAR);
					simonEngine.inputAction(GameState.LOW_KICK);
				break;
				case 2:
					arrowDisplay.addArrow(Arrow.LEFT, Arrow.REGULAR);
					simonEngine.inputAction(GameState.HIGH_PUNCH);
				break;
				case 3:
					arrowDisplay.addArrow(Arrow.RIGHT, Arrow.REGULAR);
					simonEngine.inputAction(GameState.LOW_PUNCH);
				break;
				default:
					throw new Error(randomArrow + ": is out of range");
			}
			
			queueFunctionUntilAnimationCompleted(onscreenMessage, releaseKeyBlock);
			queueFunctionUntilAnimationCompleted(onscreenMessage, clearArrows);
			queueFunctionUntilAnimationCompleted(onscreenMessage, doAttackScene);
			listenForAnimationComplete(onscreenMessage);
		}
		private function doAttackScene():void
		{
			//keyBlock = true; //attack scene needs to pause the game while the player reads the text
			
			FlxG.bgColor = 0xFF000000 | playerReferences[whosTurn].colour;
			
			bringPlayerToFront(Player(playerReferences[whosTurn]));
			var attackTextWithCount:String = ATTACK_TEXT.replace("{num}", simonEngine.sequenceLength);
			displayText(whosTurn + ": " + attackTextWithCount, 0xFFFFFFFF, playerAttackTextDuration);
			
			//queueFunctionUntilAnimationCompleted(onscreenMessage, releaseKeyBlock);
			//listenForAnimationComplete(onscreenMessage);
			
			doArrowPlaceholders();
		}
		
//animations---------------------------------------------------------------------------------------

		private function doPlayerInput():void
		{
			if (keyBlock)
			{
				return;
			}
			
			if (FlxG.keys.justReleased("UP"))//moves should be mutually exclusive 
			{
				simonEngine.inputAction(GameState.HIGH_KICK);
			}
			else if (FlxG.keys.justReleased("DOWN"))
			{
				simonEngine.inputAction(GameState.LOW_KICK);
			}
			else if (FlxG.keys.justReleased("LEFT"))
			{	
				simonEngine.inputAction(GameState.HIGH_PUNCH);
			}
			else if (FlxG.keys.justReleased("RIGHT"))
			{	
				simonEngine.inputAction(GameState.LOW_PUNCH);
			}
		}
		private function doHitAnimation(keycode:uint):void
		{
			//cast as interface for methods
			var attacker:IPlayer = playerReferences[whosTurn];
			var defender:IPlayer = playerReferences[previousTurn];
			
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
			var attacker:IPlayer = playerReferences[whosTurn];
			var defender:IPlayer = playerReferences[previousTurn];
			
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
			if (onscreenMessage !== null)
			{
				onscreenMessage.kill();//may not remove the reference due to garbage collection
				onscreenMessage = null;
			}
			
			var instruction:Message = new Message(text, forDuration, withColour);
			add(instruction);
			instruction.begin();
			onscreenMessage = instruction;
		}
		private function displayArrow(keycode:uint, state:String):void
		{
			switch(keycode)
			{
				case GameState.HIGH_KICK:
					arrowDisplay.addArrow(Arrow.UP, state, simonEngine.sequenceLength);
				break;
				case GameState.LOW_KICK:
					arrowDisplay.addArrow(Arrow.DOWN, state, simonEngine.sequenceLength);
				break;
				case GameState.HIGH_PUNCH:
					arrowDisplay.addArrow(Arrow.LEFT, state, simonEngine.sequenceLength);
				break;
				case GameState.LOW_PUNCH:
					arrowDisplay.addArrow(Arrow.RIGHT, state, simonEngine.sequenceLength);
				break;
			}
		}
		private function doArrowPlaceholders()
		{
			for (var i=0; i<simonEngine.sequenceLength; i++)
			{
				blankDisplay.addArrow(0, Arrow.BLANK);
			}
		}

//helpers-----------------------------------------------------------------------------------------

		private function queueFunctionUntilAnimationCompleted(dispatcher:IAnimationEventDispatcher, doAction:Function, ...rest):void
		{
			if (sandbox[dispatcher] == null)
			{
				sandbox[dispatcher] = new Array();
			}
			sandbox[dispatcher].push(new QueuedMethod(doAction, rest));
		}
		//see if the win condition is satisfied mid-fight
		private function checkFatality():void
		{
			var defender:Player = playerReferences[whosTurn];
			if (defender.health <= 0)
			{
				doGameOver();
			}
		}
		private function updatePositions():void
		{
			var attacker:Player = playerReferences[whosTurn];
			var defender:Player = playerReferences[previousTurn];
			
			var leftEdge:int = 0 + 32;
			var rightEdge:int = FlxG.width - 32;
			
			if (attacker == leftPlayer && rightPlayer.x < rightEdge)
			{
				attacker.x += playerMovementInPixels;
				defender.x += playerMovementInPixels;
			}
			if (attacker == rightPlayer && leftPlayer.x > leftEdge)
			{
				attacker.x -= playerMovementInPixels;
				defender.x -= playerMovementInPixels;
			}
			
			/*
			leftPlayer.x = 	leftPlayer.health * playerMovementInPixels - leftPlayer.width;
			rightPlayer.x = leftPlayer.health * playerMovementInPixels;
			shadow.x = 		leftPlayer.health * playerMovementInPixels - shadow.width * 0.5;
			*/
		}
		private function updateHealth():void
		{
			var defender:Player = playerReferences[previousTurn];
			defender.health -= healthDecrement;
		}
		private function switchTurns():void
		{
			previousTurn = whosTurn;
			if (whosTurn == LEFTS_TURN)
			{
				whosTurn = RIGHTS_TURN;
			}
			else
			{
				whosTurn = LEFTS_TURN;
			}
		}
		private function clearArrows()
		{
			blankDisplay.clearArrows();
			arrowDisplay.clearArrows();
		}
		private function releaseKeyBlock():void 
		{
			keyBlock = false;
		}
		private function bringPlayerToFront(playerToFront:Player):void 
		{
			if (foreGround.members[0] !== playerToFront)
			{
				foreGround.members.reverse();
			}
		}
		private function listenForAnimationComplete(to:IAnimationEventDispatcher):void
		{
			to.addEventListener(AnimationEvent.ANIMATION_COMPLETE, this.onPlayerAnimationComplete);
		}
		private function removeAnimationListeners():void
		{
			if (leftPlayer.hasEventListener(AnimationEvent.ANIMATION_COMPLETE))
			{
				leftPlayer.addEventListener(AnimationEvent.ANIMATION_COMPLETE, this.onPlayerAnimationComplete);
			}
			if (rightPlayer.hasEventListener(AnimationEvent.ANIMATION_COMPLETE))
			{
				leftPlayer.addEventListener(AnimationEvent.ANIMATION_COMPLETE, this.onPlayerAnimationComplete);
			}
		}
		private function addSimonListeners():void
		{
			simonEngine.addEventListener(SimonEvent.ENTRY_CORRECT, this.onEntryCorrect);
			simonEngine.addEventListener(SimonEvent.ENTRY_INCORRECT, this.onEntryIncorrect);
			simonEngine.addEventListener(SimonEvent.FINAL_ENTRY, this.onFinalEntry);
			simonEngine.addEventListener(SimonEvent.SEQUENCE_ENDED, this.onSequenceEnded);
		}
		private function removeSimonListeners():void
		{
			simonEngine.removeEventListener(SimonEvent.ENTRY_CORRECT, this.onEntryCorrect);
			simonEngine.removeEventListener(SimonEvent.ENTRY_INCORRECT, this.onEntryIncorrect);
			simonEngine.removeEventListener(SimonEvent.FINAL_ENTRY, this.onFinalEntry);
			simonEngine.removeEventListener(SimonEvent.SEQUENCE_ENDED, this.onSequenceEnded);
		}
		//lazy game over
		private function doGameOver():void
		{
			FlxG.switchState(new WinnerState());
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