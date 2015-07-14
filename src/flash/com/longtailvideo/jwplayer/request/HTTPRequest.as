package com.longtailvideo.jwplayer.request
{
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.player.PlayerState;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	public class HTTPRequest
	{
		private var player:IPlayer;
		public function HTTPRequest(player:IPlayer)
		{
			this.player = player;
		}
		
		/**
		 * 视频观看时间计时器
		 * */
		public function startTimer(timerHandler:Function):void{
			var myTimer:Timer = new Timer(60000, 0); //一分钟保存一次
			//				var myTimer:Timer = new Timer(6000, 0);
			myTimer.addEventListener("timer", timerHandler);
			myTimer.start();
		}
		
		/**
		 * 向服务器端发送数据
		 * */
		private function sendServer(requestVars:URLVariables, url:String, loaderCompleteHandler:Function):void
		{
			var request:URLRequest  = new URLRequest();
			request.url = url;
			request.method = URLRequestMethod.GET;
			request.data = requestVars;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat =URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			try
			{
				loader.load(request);
			}
			catch (error:Error)
			{
				trace("Unable to load URL");
			}

			
		}
		
		
		/**
		 * 向数据库更新查看数据 ，定时保存教学活动中的视频查看时长
		 */
		public function teachingTimerHandler(event:TimerEvent = null):void {
//			trace("当前状态："+ player.state);
//			trace("当前时间："+ player.getCurrentCaptions());
//			if(player.state == PlayerState.PLAYING){
				updateResActComProAction();
//			}
		}
		/**
		 * 向数据库更新查看数据 ，定时保存教学活动中的视频查看时长
		 */
		public function teachingScanNumberHandler(event:TimerEvent = null):void {
//			trace("当前状态："+ player.state);
//			trace("当前时间："+ player.getCurrentCaptions());
//			if(player.state == PlayerState.PLAYING){
			saveResourceBrowserScanNumber();
//			}
		}
		/**
		 * 向数据库更新查看数据 ，定时保存视频资源查看时长
		 */
		public function resoueceTimerHanlder(event:TimerEvent = null):void {
//			trace("当前状态："+ player.state);
//			trace("当前时间："+ player.getCurrentCaptions());
//			if(player.state == PlayerState.PLAYING){
			saveResourceBrowserDuration();
//			}
		}
		
		/**
		 * 服务器方法
		 * */
		
		/**
		 * 保存视频资源观看时长
		 * */
		private function saveResourceBrowserDuration():void
		{
			var requestVars:URLVariables = new URLVariables();
			requestVars.resourceInfoId = player.config.resourceinfoid;
			if(player.config.teachingactivitydetailsid > 0)
			{
				requestVars.teachingActivityDetailsId = player.config.teachingactivitydetailsid;
			}
			requestVars.lastViewLocation = Math.round(player.position);
			var url:String = player.config.hosturl + "/saveResourceBrowserDuration.action";
			sendServer(requestVars,url,loaderSuccessfulHandler);
		}
		
		/**
		 * 更新教学活动视频资源观看时长
		 * */
		private function updateResActComProAction():void
		{
			var requestVars:URLVariables = new URLVariables();
			requestVars.teachingActivityDetailsId = player.config.teachingactivitydetailsid;
//			requestVars.lastViewLocation = player.getCurrentCaptions();
			requestVars.lastViewLocation = Math.round(player.position);
			var url:String = player.config.hosturl + "/updateResActComProAction.action";
			sendServer(requestVars,url,loaderSuccessfulHandler);
		}
		/**
		 * 更新教学活动视频资源浏览次数
		 * */
		private function saveResourceBrowserScanNumber():void
		{
			var requestVars:URLVariables = new URLVariables();
			requestVars.teachingActivityDetailsId = player.config.teachingactivitydetailsid;
//			requestVars.lastViewLocation = player.getCurrentCaptions();
//			requestVars.lastViewLocation = Math.round(player.position);
			var url:String = player.config.hosturl + "/saveResourceBrowserScanNumber.action";
			sendServer(requestVars,url,loaderSuccessfulHandler);
		}
		
		/**
		 * 服务器方法
		 * 
		 * */
		public function getLastViewLocationInfo():void{
			var requestVars:URLVariables = new URLVariables();
			requestVars.teachingActivityDetailsId = player.config.teachingactivitydetailsid;
			var url:String = player.config.hosturl + "/getLastViewLocationInfo.action";
			sendServer(requestVars,url,lastTimeLocation_resultHandler);
			
		}
		
		/**
		 *Result 处理 
		 * */
		
		protected function lastTimeLocation_resultHandler(event:Event):void
		{
			var lastTimeLocation:Number = Number(event.target.data);
			player.seek(lastTimeLocation);
		}
		
		private function loaderSuccessfulHandler(e:Event):void
		{
//			var variables:URLVariables	 = new URLVariables( e.target.data );
//			if(variables.success)
//			{
//				trace(variables.path);     
				trace("success");     
//			}
		}
		private function httpStatusHandler (e:Event):void
		{
			//trace("httpStatusHandler:" + e);
		}
		private function securityErrorHandler (e:Event):void
		{
			trace("securityErrorHandler:" + e);
		}
		private function ioErrorHandler(e:Event):void
		{
			trace("ioErrorHandler: " + e);
		}
		
		
	}
}