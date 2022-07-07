const { createServer } = require('http');
const { WebSocketServer } = require('ws');

const server = createServer();
const wss = new WebSocketServer({ noServer: true });

wss.on('connection', function(ws) {
    console.log("websocket connected")
    ws.on('message', function(message) {
        console.log('received: %s', message);
    });
    
    ws.send('something');
});

server.on('upgrade', function(request, socket, head) {
    console.log("attempted upgrade")
    wss.handleUpgrade(request, socket, head, function(ws) {
        wss.emit('connection', ws, request);
    });
});

server.on("connection", function(socket) {
    console.log("connected")
    socket.on("data", function (data){
        console.log(data.toString())
    });
});

server.listen(8080);