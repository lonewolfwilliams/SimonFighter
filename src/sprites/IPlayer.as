package sprites 
{
	
	/**
	 * ...
	 * @author Gareth Williams
	 */
	public interface IPlayer //to enable delegate functionality
	{
		function taunt():void;
		//attacks
		function highPunch():void;
		function highKick():void;
		function lowPunch():void;
		function lowKick():void;
		//defenses
		function highBlock():void;
		function lowBlock():void;
		//injuries
		function highInjury():void;
		function lowInjury():void;
		//death
		function youGotKnockedTheFuckOut():void;
	}
}