#include HTTPClient.ahk
#include WSClient.ahk

class WSSession extends EventEmitter {
	 __New(host, port := 80, url := "/", subprotocol := "")
    {
        this.host := host
        this.port := port
        this.url := url
        this.subprotocol := subprotocol
        
        this.HTTP := new HTTPClient(this.host, this.port, ObjBindMethod(this, "HandleHTTP"))

        this.DoHandshake()
    }
    
    DoHandshake()
    {
        UpgradeRequest := new HTTPRequest()

        this.key := createHandshakeKey()
        
        UpgradeRequest.headers["Host"] := this.host . ":" . this.port
        UpgradeRequest.headers["Origin"] := "http://" . this.host . ":" . this.port
        UpgradeRequest.headers["Connection"] := "Upgrade"
        UpgradeRequest.headers["Upgrade"] := "websocket"
        UpgradeRequest.headers["Sec-WebSocket-Key"] := this.key

        if(this.subprotocol)
        {
            request.headers["Sec-WebSocket-Protocol"] := this.subprotocol
        }

        UpgradeRequest.headers["Sec-WebSocket-Version"] := 13
        
        UpgradeRequest.method := "GET"
        UpgradeRequest.url := this.url

        this.HTTP.SendRequest(UpgradeRequest)
    }
    
    HandleHTTP(HTTP, Response)
    {
        if(Response.statuscode == 101)
        {
            if(sec_websocket_accept(this.key) != Response.headers["Sec-WebSocket-Accept"]) {
                console.log("WS Handshake error: key returned from server doesn't match.")
                return
            }
            
			WS := this.HTTP
			ObjSetBase(WS, WSClient)
			this.WS := WS

			this.WS.OnRequest := ObjBindMethod(this, "HandleWS")
        }
        else
        {
            console.log(response.raw)
        }
    }

	HandleWS(Response) {
		OpcodeName := WSOpcodes.ToString(Response.Opcode)

		if (ObjGetBase(this).HasKey("On" OpcodeName)) {
			this["On" OpcodeName](Response)
		}
		
		return this.Emit(Response.Opcode, Response)
	}

	OnPing(Response) {
		; To handle a PING, we just need to reply with a PONG containing the exact same application data as the pong

		this.WS.SendFrame(WSOpcodes.Pong, Response.pPayload, Response.PayloadSize)

		console.log("Pong'd")
	}

	OnClose(Response) {
		; To handle a CLOSE, we just reply with a CLOSE and then close the socket

		this.WS.SendFrame(WSOpcodes.Close)

		this.WS.Disconnect()

		console.log("Closed")
	}

	SendText(Message) {
		this.WS.SendText(Message)
	}
}