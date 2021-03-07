; Title:   	How to send a text message via UDP with socket.ahk form github
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=76&t=45978&hilit=TCP
; Author:	Bukan
; Date:   	02 Apr 2018, 20:51
; for:     	AHK_L

/*


*/

	#SingleInstance Force
	#Include Socket.ahk
    OnExit, GuiClose
	isConnected := False ;start condition

    ;Set up the GUI
    Gui, +Resize +OwnDialogs +AlwaysOnTop +LastFound
    Gui, Add, Edit, r10 w300 vtxtDialog ReadOnly hwndhtxtDialog
    Gui, Add, Edit, xm w250 vtxtInput ReadOnly hwndhtxtInput Limit65535
    Gui, Add, Button, x+5 w45 hp vbtnSend Disabled hwndhbtnSend, Send
	Gui, Add, Text, xm  vIPlbl hwndhIPlbl, IP:
	Gui, Add, Edit, x+1 w90 vIPadress hwndhIPadress, 127.0.0.1
	Gui, Add, Text, x+10  vPortlbl hwndhPortlbl , Port:
	Gui, Add, Edit, x+1 w90 vport hwndhPort, 32167
	Gui, Add, Button, x+8 w65 h21 vbtnConnect hwndhbtnConnect, Connect
	Gui, Add, Text, xm w240 vlblStatus hwndhlblStatus, Disconnected
    Gui, +MinSize
    Gui, Show

GuiSize:
    Anchor(htxtDialog, "wh")
    Anchor(htxtInput, "wy")
    Anchor(hbtnSend, "xy")
	Anchor(hbtnConnect, "xy")
    Anchor(hlblStatus, "wy", 1)
	Anchor(hPortlbl, "xy")
	Anchor(hIPadress, "xy")
	Anchor(hPort, "xy")
	Anchor(hIPlbl, "xy")
Return

;Show GUI
Gui, Show
Return

GuiClose:
ExitApp

;this function disable/enable part of Gui depends on connection status.
ToggleGui(isConnected){
	IF (isConnected){
	GuiControl, -ReadOnly, IPadress
	GuiControl, +ReadOnly, txtInput
	GuiControl, -ReadOnly, port
	GuiControl, Disable, btnSend
	GuiControl,, btnConnect, Connect
	} else {
	GuiControl, +ReadOnly, IPadress
	GuiControl, Enable, btnSend
	GuiControl, +ReadOnly, port
	GuiControl, -ReadOnly, txtInput
	GuiControl,, btnConnect, Disconnect
	}
}

;this is actually Connect/Disconnect button
ButtonConnect:

	GuiControlGet, sIP,, IPadress
	GuiControlGet, sPort,, port
	GuiControlGet, sBtn,, btnConnect

	IF (isConnected){
		Client.Disconnect() ;disconnecting from the server
		ToggleGui(isConnected)
		GuiControl,, lblStatus, Disconnected
		isConnected := False
	} else {
		Client := new SocketTCP()	;creating instance of Socket.ahk class
		Client.Connect([sIP, sPort]) ; connecting to server
		Client.onRecv := Func("OnRecieve") ;this was least obvious part for me. There is no implementation of this method in Socket.ahk, so you need to create it by yourself


	ToggleGui(isConnected)
	GuiControl,, lblStatus, Connected to %sIP% : %sPort%
	isConnected := True
	}

Return



ButtonSend:
    ;Get the text to send
    GuiControlGet, sText,, txtInput

	;Sending text
	Client.SendText(sText)

	;Data was sent. Add it to the dialog.
    AddDialog(&sText)

    ;Clear the Edit control and give focus
    GuiControl,, txtInput
    GuiControl, Focus, txtInput
Return

OnRecieve(){
	global Client ;calling for our instanse of Socket.ahk
	inText := Client.RecvText() ;recieving actual message
	ackn1 := "Recieved" ;just for debugging
	AddDialog(&ackn1, bYou = False) ;just for debugging
	AddDialog(&inText, bYou = False) ; show inc message in Gui
return
}

AddDialog(ptrText, bYou = True) {
    Global htxtDialog

    ;Append the interlocutor
    sAppend := bYou ? "You > " : "Server > "
    InsertText(htxtDialog, &sAppend)

    ;Append the new text
    InsertText(htxtDialog, ptrText)

    ;Append a new line
    sAppend := "`r`n"
    InsertText(htxtDialog, &sAppend)

    ;Scroll to bottom
    SendMessage, 0x0115, 7, 0,, ahk_id %htxtDialog% ;WM_VSCROLL
}



/*! TheGood
    Append text to an Edit control
    http://www.autohotkey.com/forum/viewtopic.php?t=56717
*/
InsertText(hEdit, ptrText, iPos = -1) {

    If (iPos = -1) {
        SendMessage, 0x000E, 0, 0,, ahk_id %hEdit% ;WM_GETTEXTLENGTH
        iPos := ErrorLevel
    }

    SendMessage, 0x00B1, iPos, iPos,, ahk_id %hEdit% ;EM_SETSEL
    SendMessage, 0x00C2, False, ptrText,, ahk_id %hEdit% ;EM_REPLACESEL
}

;Anchor by Titan, adapted by TheGood
;http://www.autohotkey.com/forum/viewtopic.php?p=377395#377395
Anchor(i, a = "", r = false) {
	static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff, ptr
	If z = 0
		VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), ptr := A_PtrSize ? "Ptr" : "UInt", z := true
	If (!WinExist("ahk_id" . i)) {
		GuiControlGet, t, Hwnd, %i%
		If ErrorLevel = 0
			i := t
		Else ControlGet, i, Hwnd, , %i%
	}
	VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), ptr, &gi)
		, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	If (gp != gpi) {
		gpi := gp
		Loop, %gl%
			If (NumGet(g, cb := gs * (A_Index - 1)) == gp, "UInt") {
				gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
				Break
			}
		If (!gf)
			NumPut(gp, g, gl, "UInt"), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
	}
	ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
	Loop, %cl%
		If (NumGet(c, cb := cs * (A_Index - 1), "UInt") == i) {
			If a =
			{
				cf = 1
				Break
			}
			giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
				, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
			Loop, Parse, a, xywh
				If A_Index > 1
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
						, d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
			DllCall("SetWindowPos", "UInt", i, "UInt", 0, "Int", dx, "Int", dy
				, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
			If r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
			Return
		}
	If cf != 1
		cb := cl, cl += cs
	bx := NumGet(gi, 48, "UInt"), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52, "UInt")
	If cf = 1
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb, "UInt"), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
		, NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
	Return, true
}