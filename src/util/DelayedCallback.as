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
		private var m_isDead = false;
		public function get isDead():Boolean
		{
			return m_isDead;
		}
		
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
		public function Cancel():void 
		{
			if (m_isDead)
			{
				return;
			}
			destroy();
		}
		private function OnTimerComplete(e:TimerEvent):void 
		{
			m_callback.apply(m_context, m_callbackParameters);
			destroy();
		}
		public function destroy():void
		{
			if (m_isDead) 
			{
				return;
			}
			
			m_timer.stop();
			m_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, OnTimerComplete);
			m_timer = null;
			m_callback = null;
			m_context = null;
			
			m_isDead = true;
		}
	}
}