#NoEnv
SetBatchLines, -1

#Include %A_ScriptDir%\..\..\class_WebSocket.ahk

new Example("wss://echo.websocket.org/")
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
