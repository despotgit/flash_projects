oot</code> set to the swf's root. This is only useful 
		 * in situations where the swf contains other loaders that are required. 
		 * 
		 * @param nameOrURL The name or url associated with the loader whose content should be found.
		 * @return The content associated with the name or url. Returns <code>null</code> if none was found.
		 */
		public function getContent(nameOrURL:String):* {
			if (nameOrURL == this.name || nameOrURL == _url) {
				return this.content;
			}
			var loader:LoaderCore = this.getLoader(nameOrURL);
			return (loader != null) ? loader.content : null;
		}
		
		/**
		 * Returns and array of all LoaderMax-related loaders (if any) that were found inside the swf and 
		 * had their <code>requireWithRoot</code> special vars property set to the swf's root. For example, 
		 * if the following code was run on the first frame of the swf, it would be identified as a child
		 * of this SWFLoader: <br /><br /><code>
		 * 
		 * var loader:ImageLoader = new ImageLoader("1.jpg", {requireWithRoot:this.root});<br /><br /></code>
		 * 
		 * Even if loaders are created later (not on frame 1), as long as their <code>requireWithRoot</code> 
		 * points to this swf's root, the loader(s) will be considered a child of this SWFLoader and will be 
		 * returned in the array that <code>getChildren()</code> creates. Beware, however, that by default 
		 * child loaders are integrated into the SWFLoader's <code>progress</code>, so if the swf finishes 
		 * loading and then a while later a loader is created inside that swf that has its <code>requireWithRoot</code>
		 * set to the swf's root, at that point the SWFLoader's <code>progress</code> would no longer be 1 (it would
		 * be less) but the SWFLoader's <code>status</code> remains unchanged.<br /><br />
		 * 
		 * No child loader can be found until the SWFLoader's INIT event is dispatched, meaning the first
		 * frame of the swf has loaded and instantiated. 
		 * 
		 * @param includeNested If <code>true</code>, loaders that are nested inside child LoaderMax, XMLLoader, or SWFLoader instances will be included in the returned array as well. The default is <code>false</code>.
		 * @param omitLoaderMaxes If <code>true</code>, no LoaderMax instances will be returned in the array; only LoaderItems like ImageLoaders, XMLLoaders, SWFLoaders, MP3Loaders, etc. The default is <code>false</code>. 
		 * @return An array of loaders.
		 */
		public function getChildren(includeNested:Boolean=false, omitLoaderMaxes:Boolean=false):Array {
			return (_queue != null) ?  _queue.getChildren(includeNested, omitLoaderMaxes) : [];
		}
	
		
//---- EVENT HANDLERS ------------------------------------------------------------------------------------
		
		/** @private **/
		override protected function _initHandler(event:Event):void {
			//if the SWFLoader was cancelled before _initHandler() was called, Flash will refuse to properly unload it, so we allow it to continue but check the status here and _dump() if necessary.
			if (_stealthMode) {
				_initted = true;
				var awaitingLoad:Boolean = _loadOnExitStealth;
				_dump(((_status == LoaderStatus.DISPOSED) ? 3 : 1), _status, true);
				if (awaitingLoad) {
					_load();
				}
				return;
			}
			
			//swfs with TLF use their own funky preloader system that causes problems, so we need to work around them here...
			_hasRSL = false;
			try {
				var tempContent:DisplayObject = _loader.content;
				var className:String = getQualifiedClassName(tempContent);
				if (className.substr(-13) == "__Preloader__") {
					var rslPreloader:Object = tempContent["__rslPreloader"];
					if (rslPreloader != null) {
						className = getQualifiedClassName(rslPreloader);
						if (className == "fl.rsl::RSLPreloader") {
							_hasRSL = true;
							_rslAddedCount = 0;
							tempContent.addEventListener(Event.ADDED, _rslAddedHandler);
						}
					}
				}
			} catch (error:Error) {
				
			}
			if (!_hasRSL) {
				_init();
			}
		}
		
		/** @private **/
		protected function _init():void {
			_determineScriptAccess();
			if (!_scriptAccessDenied) {
				if (!_hasRSL) { 
					_content = _loader.content;
				}
				if (_content != null) {
					if (this.vars.autoPlay == false && _content is MovieClip) {
						var st:SoundTransform = _content.soundTransform;
						st.volume = 0; //just make sure you can't hear any sounds as it's loading in the background.
						_content.soundTransform = st;
						_content.stop();
					}
					_checkRequiredLoaders();
				}
				if (_loader.parent == _sprite) {
					if (_sprite.stage != null && this.vars.suppressInitReparentEvents == true) {
						_sprite.addEventListener(Event.ADDED_TO_STAGE, _captureFirstEvent, true, 1000, true);
						_loader.addEventListener(Event.REMOVED_FROM_STAGE, _captureFirstEvent, true, 1000, true);
					}
					_sprite.removeChild(_loader); //we only added it temporarily so that if the child swf references "stage" somewhere, it could avoid errors (as long as this SWFLoader's ContentDisplay is on the stage, like if a "container" is defined in vars)
				}
				
			} else {
				_content = _loader;
				_loader.visible = true;
			}
			super._initHandler(null);
		}
		
		/** @private **/
		protected function _captureFirstEvent(event:Event):void {
			event.stopImmediatePropagation();
			event.currentTarget.removeEventListener(event.type, _captureFirstEvent);
		}
		
		/** @private Works around bug - see http://kb2.adobe.com/cps/838/cpsid_83812.html **/
		protected function _rslAddedHandler(event:Event):void {
			// check to ensure this was actually something added to the _loader.content
			if (event.target is DisplayObject && event.currentTarget is DisplayObjectContainer && event.target.parent == event.currentTarget) {
				_rslAddedCount++;
			}
			// the first thing added will be the loader animation swf - ignore that
			if (_rslAddedCount > 1) {
				event.currentTarget.removeEventListener(Event.ADDED, _rslAddedHandler);
				if (_status == LoaderStatus.LOADING) {
					_content = event.target;
					_init();
					_calculateProgress();
					dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
					_completeHandler(null);
				}
			}
		}
		
		/** @private **/
		override protected function _passThroughEvent(event:Event):void {
			if (event.target != _queue) {
				super._passThroughEvent(event);
			}
		}
		
		/** @private **/
		override protected function _progressHandler(event:Event):void {
			if (_status == LoaderStatus.LOADING) {
				if (_queue == null && _initted) {
					_checkRequiredLoaders();
				}
				if (_dispatchProgress) {
					var bl:uint = _cachedBytesLoaded;
					var bt:uint = _cachedBytesTotal;
					_calculateProgress();
					if (_cachedBytesLoaded != _cachedBytesTotal && (bl != _cachedBytesLoaded || bt != _cachedBytesTotal)) {
						dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
					}
				} else {
					_cacheIsDirty = true;
				}
			}
		}
		
		/** @private **/
		override protected function _completeHandler(event:Event=null):void {
			_loaderCompleted = true;
			_checkRequiredLoaders();
			_calculateProgress();
			if (this.progress == 1) {
				if (!_scriptAccessDenied && this.vars.autoPlay == false && _content is MovieClip) {
					var st:SoundTransform = _content.soundTransform;
					st.volume = 1;
					_content.soundTransform = st;
				}
				_changeQueueListeners(false);
				super._determineScriptAccess(); //now do the BitmapData.draw() test.
				super._completeHandler(event);
			}
		}
		
		/** @private **/
		override protected function _failHandler(event:Event, dispatchError:Boolean=true):void {
			if ((event.type == "ioError" || event.type == "securityError") && event.target == _loader.contentLoaderInfo) {
				_loaderFailed = true;
				if (_loadOnExitStealth) { //could happen if the url is set to another value between the time the SWFLoader starts loading and when it fails.
					_dump(1, _status, true);
					_load();
					return;
				}
			}
			if (event.target == _queue) {
				//this is a unique situation where we don't want the failure to unload the content because only one of the nested loaders failed but the swf may be perfectly good and usable. Also, we want to retain the _queue so that getChildren() works. Therefore we don't call super._failHandler();
				_status = LoaderStatus.FAILED;
				_time = getTimer() - _time;
				dispatchEvent(new LoaderEvent(LoaderEvent.CANCEL, this));
				dispatchEvent(new LoaderEvent(LoaderEvent.FAIL, this, this.toString() + " > " + (event as Object).text));
				return;
			}
			super._failHandler(event, dispatchError);
		}
		
		
//---- GETTERS / SETTERS ---------------------------------------------------------------
		
		/** @private **/
		override public function set url(value:String):void {
			if (_url != value) {
				if (_status == LoaderStatus.LOADING && !_initted && !_loaderFailed) {
					_loadOnExitStealth = true;
				}
				super.url = value; //will dump() too
			}
		}
		
	}
}