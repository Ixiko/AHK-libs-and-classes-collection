#Include <JSON>
class Discord
{
	static BaseURL := "https://discordapp.com/api"
	
	__New(Token)
	{
		; Bind some functions for later use
		this.SendHeartbeatBound := this.SendHeartbeat.Bind(this)
		
		; Save the token
		this.Token := Token
		
		; Get the gateway websocket URL
		URL := this.CallAPI("GET", "/gateway/bot").url
		
		; Connect to the server
		this.ws := {"base": this.WebSocket, "_Event": this._Event, "Parent": &this}
		this.ws.__New(URL "?v=6&encoding=json")
	}
	
	; Calls the REST API
	CallAPI(Method, Endpoint, Data="")
	{
		Http := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
		
		; Try the request multiple times if necessary
		Loop, 2
		{
			; Send the request
			Http.Open(Method, this.BaseURL . Endpoint)
			Http.SetRequestHeader("Authorization", "Bot " this.Token)
			Http.SetRequestHeader("Content-Type", "application/json")
			(Data ? Http.Send(JSON.Dump(Data)) : Http.Send())
			
			; Handle rate limiting
			if (Http.status == 429)
			{
				Response := JSON.Load(Http.ResponseText())
				if (Response.retry_after == "")
					throw Exception("Failed to load rate limit retry_after")
				
				; Wait then retry the request
				Sleep, % Response.retry_after
				continue
			}
			
			break
		}
		
		; Request was unsuccessful
		if (Http.status != 200 && Http.status != 204)
		{
			throw Exception("Request failed: " Http.status
				,, Method " " Endpoint "`n" Http.responseText)
		}
		
		return JSON.Load(Http.responseText)
	}
	
	; Sends data through the websocket
	Send(Data)
	{
		this.ws.Send(JSON.Dump(Data))
	}
	
	; Sends the Identify operation
	SendIdentify()
	{
		this.Send(
		( LTrim Join
		{
			"op": 2,
			"d": {
				"token": this.Token,
				"properties": {
					"$os": "windows",
					"$browser": "Discord.ahk",
					"$device": "Discord.ahk",
					"$referrer": "",
					"$referring_domain": ""
				},
				"compress": true,
				"large_threshold": 250
			}
		}
		))
	}
	
	; Sends a message to a channel
	SendMessage(channel_id, content)
	{
		return this.CallAPI("POST", "/channels/" channel_id "/messages", {"content": content})
	}
	
	/*
		Internal function triggered when the script receives a message on
		the WebSocket connected to the page.
	*/
	_Event(EventName, Event)
	{
		; If it was called from the WebSocket adjust the class context
		if this.Parent
			this := Object(this.Parent)
		
		this["On" EventName](Event)
	}
	
	; Called by the JS on WS open
	OnOpen(Event)
	{
		this.SendIdentify()
	}
	
	; Called by the JS on WS message
	OnMessage(Event)
	{
		Data := JSON.Load(Event.data)
		
		; Save the most recent sequence number for heartbeats
		if Data.s
			this.Seq := data.s
		
		; Call the defined handler, if any
		fn := this["OP" Data.op]
		%fn%(this, Data)
	}
	
	; OP 10 Hello
	OP10(Data)
	{
		this.HeartbeatACK := True
		Interval := Data.d.heartbeat_interval
		SendHeartbeat := this.SendHeartbeatBound
		SetTimer, %SendHeartbeat%, %Interval%
	}
	
	; OP 11 Heartbeat ACK
	OP11(Data)
	{
		this.HeartbeatACK := True
	}
	
	; OP 0 Dispatch
	OP0(Data)
	{
		; Call the defined handler, if any
		fn := this["OP0_" Data.t]
		%fn%(this, Data.d)
	}
	
	
	; Gets called periodically by a timer to send a heartbeat operation
	SendHeartbeat()
	{
		if !this.HeartbeatACK
		{
			throw Exception("Heartbeat did not respond")
			/*
				If a client does not receive a heartbeat ack between its
				attempts at sending heartbeats, it should immediately terminate
				the connection with a non 1000 close code, reconnect, and
				attempt to resume.
			*/
		}
		
		this.HeartbeatACK := False
		this.Send({"op": 1, "d": this.Seq})
	}
	
	#Include <WebSocket>
}
