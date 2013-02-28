package simon
{
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Gareth Williams
	 */
	public class Simon extends EventDispatcher
	{
		private var sequence:Array = new Array();
		private var currentIndex:int = 0;
		public function Simon() 
		{
			//default...	
		}
		public function destructor():void
		{
			resetSequence();
		}
		//interface
		public function inputAction(keyCode:uint):void
		{
			//trace("input action:", keyCode);
			var isStartOfSequence:Boolean = Boolean(currentIndex == 0);
			var isEndOfSequence:Boolean = Boolean(currentIndex >= sequence.length);
			if (isEndOfSequence)
			{
				//trace("end of sequence");
				addActionToSequence(keyCode)
				dispatchEvent(new SimonEvent(SimonEvent.SEQUENCE_ENDED, keyCode));//end of turn
				currentIndex = 0;
			}
			else
			{
				//trace("testing against sequence");
				var isCorrectCharacter:Boolean = checkActionAgainstSequence(keyCode);
				if (isCorrectCharacter)
				{
					dispatchEvent(new SimonEvent(SimonEvent.ENTRY_CORRECT, keyCode));
				}
				else 
				{
					dispatchEvent(new SimonEvent(SimonEvent.ENTRY_INCORRECT, keyCode));
				}
				
				if (++currentIndex == sequenceLength) 
				{
					dispatchEvent(new SimonEvent(SimonEvent.FINAL_ENTRY));
				}
			}
		}
		public function resetSequence():void
		{
			sequence.splice();
			currentIndex = 0;
		}
		public function get sequenceLength():int
		{
			return sequence.length;
		}
		public function get index():int
		{
			return currentIndex;
		}
		public function get currentCharacter():uint
		{
			return sequence[currentIndex];
		}
		//helpers
		private function checkActionAgainstSequence(keyCode:uint):Boolean
		{
			//trace(keyCode, sequence[currentIndex]);
			var isMatchingKeycode:Boolean = false;
			if (keyCode == sequence[currentIndex]) 
			{
				isMatchingKeycode = true;
			}
			else
			{
				isMatchingKeycode = false;
			}
			return isMatchingKeycode;
		}
		private function addActionToSequence(keyCode:uint):void
		{
			//trace("adding", keyCode, "to sequence");
			sequence.push(keyCode);
			//trace("\t", sequence);
		}
	}
}
