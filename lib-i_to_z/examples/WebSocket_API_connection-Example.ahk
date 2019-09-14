#NoEnv
#SingleInstance Force
#include %A_ScriptDir%\..\websocket.ahk

Gui, Add, ListBox, x12 y10 w590 h400 vView ,

; Edits
Gui, Add, Edit, x372 y420 w120 h20 vHost, ws://echo.websocket.org/
Gui, Add, Edit, x22 y420 w260 h20 vMessage, Hello World

; Buttons
Gui, Add, Button, x502 y410 w100 h20 gBtnConnect, Connect
Gui, Add, Button, x502 y430 w100 h20 gBtnDisconnect, Disconnect
Gui, Add, Button, x292 y420 w70 h20 gBtnSend, Send

; Register callbacks
websocket_registerCallback(0, "on_connect")
websocket_registerCallback(1, "on_fail")
websocket_registerCallback(2, "on_disconnect")
websocket_registerCallback(3, "on_data")

; Show GUI
Gui, Show, w620 h471, Websocket-API

return


GuiClose:
websocket_disconnect()
ExitApp

BtnConnect:
GuiControlGet, ip,, Host
if(strLen(ip) == 0)
{
	addText("The IP textfield doesn't contain any string!")
	return
}


res := websocket_connect(ip)
if(res == 0)
{
	addText("websocket_connect() returned 0.")
	return
}
return

BtnDisconnect:
if(!websocket_disconnect())
{
	addText("The connection couldn't be closed. The connection is already closed!")

	return
}

addText("The connection has been closed!")

return

BtnSend:
if(!websocket_isconnected())
{
	addText("The connection isn't estabilshed!")
	return
}

GuiControlGet, msg,, Message
if(strLen(msg) == 0)
{
	addText("The message textfield doesn't contain any string!")
	return
}

if(websocket_send(msg, strLen(msg), false))
	addText("The message has been sent!")
else
	addText("The message couldn't be sent!")

return

on_connect()
{
	Critical

	addText("The connection has been established!")
}

on_fail()
{
	Critical

	addText("The connection couldn't be created!")
}

on_disconnect()
{
	Critical

	addText("The connection has been closed!")
}

on_data(data, len)
{
	Critical

	addText("Data has been received [" . len . "]: " . StrGet(data, len) )
}

addText(t)
{
	GuiControl,, View, %t%
}