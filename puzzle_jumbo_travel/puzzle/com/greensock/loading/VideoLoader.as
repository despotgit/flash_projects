	if ("width" in info) {
				_video.width = Number(info.width); 
				_video.height = Number(info.height);
			}
			_forceInit();
			dispatchEvent(new LoaderEvent(LoaderEvent.INIT, this, "", info));
		}
		
		/** @private **/
		protected function _cuePointHandler(info:Object):void {
			if (!_videoPaused) { //in case there's a cue point very early on and autoPlay was set to false - remember, to work around bugs in NetStream, we cannot pause() it until we receive metaData and the first frame renders.
				dispatchEvent(new LoaderEvent(VIDEO_CUE_POINT, this, "", info));
			}
		}
		
		/** @private **/
		protected function _playProgressHandler(event:Event):void {
			if (!_bufferFull && _ns.bufferLength >= _ns.bufferTime) {
				_onBufferFull();
			}
			if (_firstCuePoint || _dispatchPlayProgress) {
				var prevTime:Number = _prevTime;
				_prevTime = this.videoTime;
				var next:CuePoint;
				var cp:CuePoint = _firstCuePoint;
				while (cp) {
					next = cp.next;
					if (cp.time > prevTime && cp.time <= _prevTime && !cp.gc) {
						dispatchEvent(new LoaderEvent(VIDEO_CUE_POINT, this, "", cp));
					}
					cp = next;
				}
				if (_dispatchPlayProgress && prevTime != _prevTime) {
					dispatchEvent(new LoaderEvent(PLAY_PROGRESS, this));
				}
			}
		}
		
		/** @private **/
		protected function _statusHandler(event:NetStatusEvent):void {
			var code:String = event.info.code;
			if (code == "NetStream.Play.Start") { //remember, NetStream.Play.Start can be received BEFORE the buffer is full.
				if (!_pausePending) {
					_sprite.addEventListener(Event.ENTER_FRAME, _playProgressHandler);
					dispatchEvent(new LoaderEvent(VIDEO_PLAY, this));
				}
			}
			dispatchEvent(new LoaderEvent(NetStatusEvent.NET_STATUS, this, code, event.info));
			if (code == "NetStream.Play.Stop") {
				_bufferFull = false;
				if (_videoPaused) {
					return; //Can happen when we seek() to a time in the video between the last keyframe and the end of the video file - NetStream.Play.Stop gets received even though the NetStream was paused.
				}
				if (this.vars.repeat == -1 || uint(this.vars.repeat) > _repeatCount) {
					_repeatCount++;
					dispatchEvent(new LoaderEvent(VIDEO_COMPLETE, this));
					gotoVideoTime(0, true, true);
				} else {
					_videoComplete = true;
					this.videoPaused = true;
					_playProgressHandler(null);
					dispatchEvent(new LoaderEvent(VIDEO_COMPLETE, this));
				}
			} else if (code == "NetStream.Buffer.Full") {
				_onBufferFull();
			} else if (code == "NetStream.Buffer.Empty") {
				_bufferFull = false;
				var videoRemaining:Number = this.duration - this.videoTime;
				var loadRemaining:Number = (1 / this.progress) * this.loadTime;
				if (this.autoAdjustBuffer && loadRemaining > videoRemaining) {
					_ns.bufferTime = videoRemaining * (1 - (videoRemaining / loadRemaining)) * 0.9; //90% of the estimated time because typically you'd want the video to start playing again sooner and the 10% might be made up while it's playing anyway.
				}
				dispatchEvent(new LoaderEvent(VIDEO_BUFFER_EMPTY, this));
			} else if (code == "NetStream.Play.StreamNotFound" || 
					   code == "NetConnection.Connect.Failed" ||
					   code == "NetStream.Play.Failed" ||
					   code == "NetStream.Play.FileStructureInvalid" || 
					   code == "The MP4 doesn't contain any supported tracks") {
				_failHandler(new LoaderEvent(LoaderEvent.ERROR, this, code));
			}
		}
		
		/** @private **/
		protected function _loadingProgressCheck(event:Event):void {
			var bl:uint = _cachedBytesLoaded;
			var bt:uint = _cachedBytesTotal;
			if (!_bufferFull && _ns.bufferLength >= _ns.bufferTime) {
				_onBufferFull();
			}
			_calculateProgress();
			if (_cachedBytesLoaded == _cachedBytesTotal) { 
				_sprite.removeEventListener(Event.ENTER_FRAME, _loadingProgressCheck);
				if (!_bufferFull) {
					_onBufferFull();
				}
				if (!_initted) {
					_forceInit();
					_errorHandler(new LoaderEvent(LoaderEvent.ERROR, this, "No metaData was received."));
				}
				_completeHandler(event);
			} else if (_dispatchProgress && (_cachedBytesLoaded / _cachedBytesTotal) != (bl / bt)) {
				dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
			}
		}
		
		/** @inheritDoc 
		 * Flash has a bug/inconsistency that causes NetStreams to load relative URLs as being relative to the swf file itself
		 * rather than relative to the HTML file in which it is embedded (all other loaders exhibit the opposite behavior), so 
		 * we need to make sure the audits use NetStreams instead of URLStreams (for relative urls at least). 
		 **/
		override public function auditSize():void {
			if (_url.substr(0, 4) == "http" && _url.indexOf("://") != -1) { //if the url isn't relative, use the regular URLStream to do the audit because it's faster/more efficient. 
				super.auditSize();
			} else if (_auditNS == null) {
				_auditNS = new NetStream(_nc);
				_auditNS.bufferTime = isNaN(this.vars.bufferTime) ? 5 : Number(this.vars.bufferTime);
				_auditNS.client = {onMetaData:_auditHandler, onCuePoint:_auditHandler};
				_auditNS.addEventListener(NetStatusEvent.NET_STATUS, _auditHandler, false, 0, true);
				_auditNS.addEventListener("ioError", _auditHandler, false, 0, true);
				_auditNS.addEventListener("asyncError", _auditHandler, false, 0, true);
				_auditNS.soundTransform = new SoundTransform(0);
				var request:URLRequest = new URLRequest();
				request.data = _request.data;
				_setRequestURL(request, _url, (!_isLocal || _url.substr(0, 4) == "http") ? "gsCacheBusterID=" + (_cacheID++) + "&purpose=audit" : "");
				_auditNS.play(request.url);
			}
		}
			
		/** @private **/
		protected function _auditHandler(event:Event=null):void {
			var type:String = (event == null) ? "" : event.type;
			var code:String = (event == null || !(event is NetStatusEvent)) ? "" : NetStatusEvent(event).info.code;
			if (event != null && "duration" in event) {
				_duration = Object(event).duration;
			}
			if (_auditNS != null) {
				_cachedBytesTotal = _auditNS.bytesTotal; 
				if (_bufferMode && _duration != 0) {
					_cachedBytesTotal *= (_auditNS.bufferTime / _duration);
				}
			}
			if (type == "ioError" ||
				type == "asyncError" || 
				code == "NetStream.Play.StreamNotFound" || 
				code == "NetConnection.Connect.Failed" ||
				code == "NetStream.Play.Failed" ||
				code == "NetStream.Play.FileStructureInvalid" || 
				code == "The MP4 doesn't contain any supported tracks") {
				if (this.vars.alternateURL != undefined && this.vars.alternateURL != "" && this.vars.alternateURL != _url) {
					_url = this.vars.alternateURL;
					_setRequestURL(_request, _url);
					var request:URLRequest = new URLRequest();
					request.data = _request.data;
					_setRequestURL(request, _url, (!_isLocal || _url.substr(0, 4) == "http") ? "gsCacheBusterID=" + (_cacheID++) + "&purpose=audit" : "");
					_auditNS.play(request.url);
					_errorHandler(new LoaderEvent(LoaderEvent.ERROR, this, code));
					return;
				} else {	
					//note: a CANCEL event won't be dispatched because technically the loader wasn't officially loading - we were only briefly checking the bytesTotal with a NetStream.
					super._failHandler(new LoaderEvent(LoaderEvent.ERROR, this, code));
				}
			}
			_auditedSize = true;
			_closeStream();
			dispatchEvent(new Event("auditedSize"));
		}
		
		/** @private **/
		override protected function _closeStream():void {
			if (_auditNS != null) {
				_auditNS.pause();
				try {
					_auditNS.close();
				} catch (error:Error) {
					
				}
				_auditNS.client = {};
				_auditNS.removeEventListener(NetStatusEvent.NET_STATUS, _auditHandler);
				_auditNS.removeEventListener("ioError", _auditHandler);
				_auditNS.removeEventListener("asyncError", _auditHandler);
				_auditNS = null;
			} else {
				super._closeStream();
			}
		}
		
		/** @private **/
		override protected function _auditStreamHandler(event:Event):void {
			if (event is ProgressEvent && _bufferMode) {
				(event as ProgressEvent).bytesTotal *= (_ns.bufferTime / _duration);
			}
			super._auditStreamHandler(event);
		}
		
		/** @private **/
		protected function _renderHandler(event:Event):void {
			_renderedOnce = true;
			if (!_videoPaused || _initted) { //if the video hasn't initted yet and it's paused, keep reporting the _forceTime and let the _timer keep calling until the condition is no longer met. 
				_forceTime = NaN;
				_timer.stop();
				_ns.removeEventListener(Event.RENDER, _renderHandler);
			}
			if (_pausePending) {
				if (_bufferFull) {
					_applyPendingPause();
				} else {
					//if the NetStream is still buffering, there's a good chance that the video will appear to play briefly right before we pause it, so we detach the NetStream from the Video briefly to avoid that funky visual behavior (we attach it again as soon as it buffers).
					//we cannot do _video.attachNetStream(null) here (within this RENDER handler) because it causes Flash Pro to crash! We must wait for an ENTER_FRAME event.
					_sprite.addEventListener(Event.ENTER_FRAME, _detachNS, false, 100, true);
				}
			}
		}
		
		/** @private see notes in _renderHandler() **/
		private function _detachNS(event:Event):void {
			_sprite.removeEventListener(Event.ENTER_FRAME, _detachNS);
			if (!_bufferFull && _pausePending) {
				_video.attachNetStream(null); //if the NetStream is still buffering, there's a good chance that the video will appear to play briefly right before we pause it, so we detach the NetStream from the Video briefly to avoid that funky visual behavior (we attach it again as soon as it buffers).
			}
		}
		
		/** @private The video isn't decoded into memory fully until the NetStream is attached to the Video object. We only attach it when it is in the display list (thus can be seen) in order to conserve memory. **/
		protected function _videoAddedToStage(event:Event):void {
			_video.attachNetStream(_ns);
			_ns.seek(this.videoTime); //if the video is paused and we don't seek(), it won't render visually (bug in Flash apparently)
		}
		
		/** @private **/
		protected function _videoRemovedFromStage(event:Event):void {
			_video.attachNetStream(null);
			_video.clear();
		}
		
		
//---- GETTERS / SETTERS -------------------------------------------------------------------------
		
		/** A ContentDisplay (a Sprite) that contains a Video object to which the NetStream is attached. This ContentDisplay Sprite can be accessed immediately; you do not need to wait for the video to load. **/
		override public function get content():* {
			return _sprite;
		}
		
		/** The <code>Video</code> object to which the NetStream was attached (automatically created by VideoLoader internally) **/
		public function get rawContent():Video {
			return _video;
		}
		
		/** The <code>NetStream</code> object used to load the video **/
		public function get netStream():NetStream {
			return _ns;
		}
		
		/** The playback status of the video: <code>true</code> if the video's playback is paused, <code>false</code> if it isn't. **/
		public function get videoPaused():Boolean {
			return _videoPaused;
		}
		public function set videoPaused(value:Boolean):void {
			var changed:Boolean = Boolean(value != _videoPaused);
			_videoPaused = value;
			if (_videoPaused) {
				//If we're trying to pause a NetStream that hasn't even been buffered yet, we run into problems where it won't load. So we need to set the _pausePending to true and then when it's buffered, it'll pause it at the beginning.
				if (!_renderedOnce) {
					_setForceTime(0);
					_pausePending = true;
					_sound.volume = 0; //temporarily make it silent while buffering.
					_ns.soundTransform = _sound;
				} else {
					_pausePending = false;
					this.volume = _volume; //Just resets the volume to where it should be in case we temporarily made it silent during the buffer.
					_ns.pause();
				}
				if (changed) {
					_sprite.removeEventListener(Event.ENTER_FRAME, _playProgressHandler);
					dispatchEvent(new LoaderEvent(VIDEO_PAUSE, this));
				}
			} else {
				if (_pausePending || !_bufferFull) {
					if (_video.stage != null) {
						_video.attachNetStream(_ns); //in case we had to detach it while buffering and waiting for the metaData
					}
					//if we don't seek() first, sometimes the NetStream doesn't attach to the video properly!
					//if we don't seek() first and the NetStream was previously rendered between its last keyframe and the end of the file, the "NetStream.Play.Stop" will have been called and it will refuse to continue playing even after resume() is called!
					//if we seek() before the metaData has been received (_initted==true), it typically prevents it from being received at all!
					//if we seek() before the NetStream has rendered once, it can lose audio completely!
					if (_initted && _renderedOnce) {
						_ns.seek(this.videoTime); 
						_bufferFull = false;
					}
					_pausePending = false;
				}
				this.volume = _volume; //Just resets the volume to where it should be in case we temporarily made it silent during the buffer.
				_ns.resume();
				if (changed) {
					_sprite.addEventListener(Event.ENTER_FRAME, _playProgressHandler);
					dispatchEvent(new LoaderEvent(VIDEO_PLAY, this));
				}
			}
		}
		
		/** A value between 0 and 1 describing the progress of the buffer (0 = not buffered at all, 0.5 = halfway buffered, and 1 = fully buffered). The buffer progress is in relation to the <code>bufferTime</code> which is 5 seconds by default or you can pass a custom value in through the <code>vars</code> parameter in the constructor like <code>{bufferTime:20}</code>. **/
		public function get bufferProgress():Number {
			if (uint(_ns.bytesTotal) < 5) {
				return 0;
			}
			return (_ns.bufferLength > _ns.bufferTime) ? 1 : _ns.bufferLength / _ns.bufferTime;
		}
		
		/** A value between 0 and 1 describing the playback progress where 0 means the virtual playhead is at the very beginning of the video, 0.5 means it is at the halfway point and 1 means it is at the end of the video. **/
		public function get playProgress():Number {
			//Often times the duration MetaData that gets passed in doesn't exactly reflect the duration, so after the FLV is finished playing, the time and duration wouldn't equal each other, so we'd get percentPlayed values of 99.26978. We have to use this _videoComplete variable to accurately reflect the status.
			//If for example, after an FLV has finished playing, we gotoVideoTime(0) the FLV and immediately check the playProgress, it returns 1 instead of 0 because it takes a short time to render the first frame and accurately reflect the _ns.time variable. So we use an interval to help us override the _ns.time value briefly.
			return (_videoComplete) ? 1 : (this.videoTime / _duration);
		}
		public function set playProgress(value:Number):void {
			if (_duration != 0) {
				gotoVideoTime((value * _duration), !_videoPaused, true);
			}
		}
		
		/** The volume of the video (a value between 0 and 1). **/
		public function get volume():Number {
			return _volume;
		}
		public function set volume(value:Number):void {
			_sound.volume = _volume = value;
			_ns.soundTransform = _sound;
		}
		
		/** The time (in seconds) at which the virtual playhead is positioned on the video. For example, if the virtual playhead is currently at the 3-second position (3 seconds from the beginning), this value would be 3. **/
		public function get videoTime():Number {
			if (_videoComplete) {
				return _duration;
			} else if (_forceTime || _forceTime == 0) {
				return _forceTime;
			} else if (_ns.time > _duration) {
				return _duration * 0.995; //sometimes the NetStream reports a time that's greater than the duration so we must correct for that.
			} else {
				return _ns.time;
			}
		}
		public function set videoTime(value:Number):void {
			gotoVideoTime(value, !_videoPaused, true);
		}
		
		/** The duration (in seconds) of the video. This value is only accurate AFTER the metaData has been received and the <code>INIT</code> event has been dispatched. **/
		public function get duration():Number {
			return _duration;
		}
		
		/** 
		 * When <code>bufferMode</code> is <code>true</code>, the loader will report its progress only in terms of the 
		 * video's buffer instead of its overall file loading progress which has the following effects:
		 * <ul>
		 * 		<li>The <code>bytesTotal</code> will be calculated based on the NetStream's <code>duration</code>, <code>bufferLength</code>, and <code>bufferTime</code> meaning it may fluctuate in order to accurately reflect the overall <code>progress</code> ratio.</li> 
		 * 		<li>Its <code>COMPLETE</code> event will be dispatched as soon as the buffer is full, so if the VideoLoader is nested in a LoaderMax, the LoaderMax will move on to the next loader in its queue at that point. However, the VideoLoader's NetStream will continue to load in the background, using up bandwidth.</li>
		 * </ul>
		 * 
		 * This can be very convenient if, for example, you want to display loading progress based on the video's buffer
		 * or if you want to load a series of loaders in a LoaderMax and have it fire its <code>COMPLETE</code> event
		 * when the buffer is full (as opposed to waiting for the entire video to load). 
		 **/
		public function get bufferMode():Boolean {
			return _bufferMode;
		}
		public function set bufferMode(value:Boolean):void {
			_bufferMode = value;
			_preferEstimatedBytesInAudit = _bufferMode;
			_calculateProgress();
			if (_cachedBytesLoaded < _cachedBytesTotal && _status == LoaderStatus.COMPLETED) {
				_status = LoaderStatus.LOADING;
				_sprite.addEventListener(Event.ENTER_FRAME, _loadingProgressCheck);
			}
		}
		
	}
}

/** @private for the linked list of cue points - makes processing very fast. **/
internal class CuePoint {
	public var next:CuePoint;
	public var prev:CuePoint;
	public var time:Number;
	public var name:String;
	public var parameters:Object;
	public var gc:Boolean;
	
	public function CuePoint(time:Number, name:String, params:Object, prev:CuePoint) {
		this.time = time;
		this.name = name;
		this.parameters = params;
		if (prev) {
			this.prev = prev;
			if (prev.next) {
				prev.next.prev = this;
				this.next = prev.next;
			}
			prev.next = this;
		}
	}
	
}