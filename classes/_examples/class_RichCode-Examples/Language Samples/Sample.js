websocket = new WebSocket("wss://echo.websocket.org/");

websocket.onopen = function(evt){
	alert("Sending:\nHello World!");
	this.send("Hello World!");
};

websocket.onclose = function(evt) {
	alert("Socket closed.");
};

websocket.onmessage = function(evt) {
	alert("Received:\n" + evt.data);
	this.close(evt);
};

websocket.onerror = function(evt) {
	alert("Socket error");
};