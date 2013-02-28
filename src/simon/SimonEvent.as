package simon 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Gareth Williams
	 */
	public class SimonEvent extends Event 
	{
		public static var SEQUENCE_ENDED:String = "input position has reached the end of the sequence";
		public static var ENTRY_CORRECT:String = "the input matches the sequence";
		public static var ENTRY_INCORRECT:String = "the input does not match the sequence";
		public static var FINAL_ENTRY:String = "next input will be added to the sequence";
		public var inputKeycode:uint;
		public function SimonEvent(type:String, inputKeycode:uint=0, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			this.inputKeycode = inputKeycode;
		} 
		public override function clone():Event 
		{ 
			return new SimonEvent(type, inputKeycode, bubbles, cancelable);
		} 
		public override function toString():String 
		{ 
			return formatToString("SimonEvent", "inputKeycode", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}
