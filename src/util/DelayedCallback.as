package util
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author LoneWolfWilliams
	 */
	public class DelayedCallback 
	{
		private var m_context:Object;
		private var m_callback:Function;
		private var m_callbackParameters:Array;
		private var m_timer:Timer;
		public function DelayedCallback(context:Object, delayInSeconds:Number, 
										callBack:Function, ...callbackParameters) 
		{
			m_context = context;
			m_callback = callBack;
			m_callbackParameters = callbackParameters;
			m_timer = new Timer(delayInSeconds * 1000, 1);
			m_timer.addEventListener(TimerEvent.TIMER_COMPLETE, OnTimerComplete);
			m_timer.start();
		}
		
		private function OnTimerComplete(e:TimerEvent):void 
		{
			m_callback.apply(m_context, m_callbackParameters);
			destroy();
		}
		
		public function destroy():void
		{
			m_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, OnTimerComplete);
			m_timer = null;
			m_callback = null;
			m_context = null;
		}
	}

}