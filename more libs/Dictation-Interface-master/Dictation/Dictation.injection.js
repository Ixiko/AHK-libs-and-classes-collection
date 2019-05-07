var wrapper;
(wrapper = function () {

	var _w = window.outerWidth, _h = window.outerHeight;

	return {

		Init: function() {
			window.addEventListener("resize", function() {
			var _width = window.outerWidth - _w;
				wrapper._winResizeEventMonitor(_width, !_width);
			});
		},
		set recognitionLanguage(_LID) {
			if (_LID < 1) return;
				var _e = document.getElementById("lang");
				_e.selectedIndex = _LID - 1;
				var _event = document.createEvent("HTMLEvents");
				_event.initEvent("change", false, true), _e.dispatchEvent(_event);
		},
		recognitionState: 0,
		start: function() {

		var _e = document.getElementsByClassName("ql-editor")[0];
		_e.innerText = "";

		this.recognitionState = 1;
		document.getElementsByClassName("btn-mic btn btn--primary-1")[0].click();
		document.title = this.recognitionState;

			this._titleUpdater = window.setInterval(function(_e) {
				document.title = _e.innerText;
			}, 700, _e);

		},
		stop: function() {

		this.recognitionState = -1;
		document.getElementsByClassName("btn-mic btn bg--pinterest")[0].click();
		document.title = this.recognitionState;

			clearInterval(this._titleUpdater), window.setTimeout(function(_wrapper) {
				document.title = (_wrapper.recognitionState=0);
			}, 700, this);

		},
		setRecognitionLanguage: function(_language) {
		if (this.recognitionState) return;
			this.recognitionLanguage = _language;
		},

			_winResizeEventMonitor: function(_width, _height) {

				if (_height)
				{
					switch(this.recognitionState) {
						case 1:
							this.stop();
						break;
						case 0:
							this.start();
						break;
						case -1:
						break;
					}
					_h = window.outerHeight;

				}
				else if (_width)
				{
					this.setRecognitionLanguage(_width);
				_w = window.outerWidth;
				}

			}

	}

}()).Init();
console.log(document.title=chrome.runtime.id);
