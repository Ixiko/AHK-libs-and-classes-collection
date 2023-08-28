#NoEnv
SetBatchLines, -1

#Include ../WebSocket.ahk

x := new Example("wss://ws.postman-echo.com/raw")
return


class Example extends WebSocket
{
	OnOpen(Event)
	{
		InputBox, Data, WebSocket, Enter some text to send through the websocket.
		this.Send(Data)
	}
	
	OnMessage(Event)
	{
		MsgBox, % "Received Data: " Event.data
		this.Close()
	}
	
	OnClose(Event)
	{
		MsgBox, Websocket Closed
		this.Disconnect()
	}
	
	OnError(Event)
	{
		MsgBox, Websocket Error
	}
	
	__Delete()
	{
		MsgBox, Exiting
		ExitApp
	}
}
