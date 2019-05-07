document.addEventListener("DOMContentLoaded", function () {

	var _url = chrome.extension.getURL("popup.html#initialize");

    if (window.location.href == _url) {

        document.title = _url, window.addEventListener("resize", function () {

            var _e = document.createElement("progress");
            _e.value = -1, _e.max = 100, document.body.appendChild(_e);

                window.setInterval(function (_progressControl) {
                    if (_progressControl.value == 100) clearInterval();
                    else _progressControl.value = _progressControl.value + 1, document.title = "Dictation loading... " + _e.value + "%";
                }, 25, _e);

                window.setTimeout(function () {
                    window.location.href = "https://dictation.io/speech";
                }, (25 + 10) * 100);

        }, {"once": true});

    }

});