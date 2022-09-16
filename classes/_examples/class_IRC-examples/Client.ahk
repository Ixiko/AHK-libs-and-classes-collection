#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include <Socket>
#Include ..\MyRC.ahk
#Include lib\Class_RichEdit.ahk
#Include lib\Utils.ahk

SettingsFile := "Settings.ini"

if !(Settings := Ini_Read(SettingsFile))
{
	FileCopy, ClientDefaultSettings.ini, %SettingsFile%, 1
	MsgBox, There was a problem reading your Settings.ini file. Please fill in the newly generated Settings.ini
	ExitApp
}

Server := Settings.Server
Nicks := StrSplit(Server.Nicks, ",", " `t")

Gui, Margin, 5, 5
Gui, Font, s9, Lucida Console
Gui, +HWNDhWnd +Resize
Gui, Add, Edit, w1000 h300 ReadOnly vLog HWNDhLog

;Gui, Add, Edit, xm y310 w1000 h299 ReadOnly vChat HWNDhChat
Chat := new RichEdit(1, "xm y310 w1000 h299 vChat")
Chat.SetBkgndColor(0x3F3F3F)
Chat.SetOptions(["READONLY"], "Set")
Font := {"Name":"Courier New","Color":0xDCDCCC,"Size":9}
Colors := ["DCDCCC", "262626"
, "6C6C9C", "9ECE9E"
, "E89393", "BC6C4C"
, "BC6C9C", "DC8C6C"
, "F8F893", "CBECD0"
, "80D4AA", "8CD0D3"
, "C0BED1", "ECBCBC"
, "8F8F8F", "DFDFDF"]
Chat.SetFont(Font)
Chat.AutoUrl(True)
Chat.HideSelection(False)
Chat.SetEventMask(["LINK"])
Chat.ID := DllCall("GetWindowLong", "UPtr", Chat.hWnd, "Int", -12) ; GWL_ID

Gui, Add, ListView, ym x1010 w130 h610 vListView -hdr, Hide
LV_ModifyCol(1, 130)
Gui, Add, DropDownList, xm w145 h20 vChannel r20 gDropDown, % Nicks[1] "||"
Gui, Add, Edit, w935 h20 x155 yp vMessage
Gui, Add, Button, yp-1 xp940 w45 h22 vSend gSend Default, SEND
Gui, Show

OnMessage(0x4E, "WM_NOTIFY")

MyBot := new Bot(Settings.Trigger, Settings.Greetings, Settings.Aliases, Nicks, Settings.ShowHex)
MyBot.Connect(Server.Addr, Server.Port, Nicks[1], Server.User, Server.Nick, Server.Pass)
MyBot.SendJOIN(StrSplit(Server.Channels, ",", " `t")*)
return

WM_NOTIFY(wParam, lParam, Msg, hWnd)
{
	static WM_LBUTTONDBLCLK := 0x203
	global Chat
	
	if (wParam == Chat.ID)
	{
		Msg := NumGet(lParam+A_PtrSize*2+4, "UInt")
		if (Msg == WM_LBUTTONDBLCLK)
		{
			Min := NumGet(lParam+A_PtrSize*4+8, "Int")
			Max := NumGet(lParam+A_PtrSize*4+12, "Int")
			Run, % Chat.GetTextRange(Min, Max)
		}
	}
}

GuiSize:
EditH := Floor((A_GuiHeight-40) / 2)
EditW := A_GuiWidth - (15 + 150)
ChatY := 10 + EditH
ListViewX := A_GuiWidth - 155
ListViewH := A_GuiHeight - 35

BarY := A_GuiHeight - 25
TextW := A_GuiWidth - (20 + 145 + 45) ; Margin + DDL + Send
SendX := A_GuiWidth - 50
SendY := BarY - 1

GuiControl, Move, Log, x5 y5 w%EditW% h%EditH%
GuiControl, Move, Chat, x5 y%ChatY% w%EditW% h%EditH%
GuiControl, Move, ListView, x%ListViewX% y5 w150 h%ListViewH%
GuiControl, Move, Channel, x5 y%BarY% w145 h20
GuiControl, Move, Message, x155 y%BarY% w%TextW% h20
GuiControl, Move, Send, x%SendX% y%SendY% w45 h22
return

DropDown:
MyBot.UpdateListView()
return

Send:
GuiControlGet, Message
GuiControl,, Message ; Clear input box

GuiControlGet, Channel

if RegexMatch(Message, "^/([^ ]+)(?: (.+))?$", Match)
{
	if (Match1 = "join")
		MyBot._SendRAW("JOIN " Match2)
	else if (Match1 = "me")
	{
		MyBot.SendACTION(Channel, Match2)
		AppendChat(Channel " * " NickColor(MyBot.Nick) " " Match2)
	}
	else if (Match1 = "part")
		MyBot.SendPART(Channel, Match2)
	else if (Match1 = "reload")
		Reload
	else if (Match1 = "say")
		MyBot.SendPRIVMSG(Channel, Match2)
	else if (Match1 = "raw")
		MyBot._SendRaw(Match2)
	else if (Match1 = "nick")
		MyBot.SendNICK(Match2)
	else if (Match1 = "quit")
	{
		MyBot.SendQUIT(Match2)
		ExitApp
	}
	else
		MyBot.Log("ERROR: Unkown command " Match1)
	return
}

; Send chat and handle it
Messages := MyBot.SendPRIVMSG(Channel, Message)
for each, Message in Messages
	MyBot.onPRIVMSG(MyBot.Nick,MyBot.User,MyBot.Host,"PRIVMSG",[Channel],Message,"")
return

GuiClose:
ExitSub:
ExitApp
return

class Bot extends IRC
{
	__New(Trigger, Greetings, Aliases, DefaultNicks, ShowHex=false)
	{
		this.Trigger := Trigger
		this.Greetings := Greetings
		this.Aliases := Aliases
		this.DefaultNicks := DefaultNicks
		return base.__New(ShowHex)
	}
	
	onMODE(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		this.UpdateListView()
	}
	
	onJOIN(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		if (Nick == this.Nick)
			this.UpdateDropDown(Params[1])
		AppendChat(Params[1] " " NickColor(Nick) " has joined")
		this.UpdateListView()
	}
	
	; RPL_ENDOFNAMES
	on366(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		this.UpdateListView()
	}
	
	onPART(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		if (Nick == this.Nick)
			this.UpdateDropDown()
		AppendChat(Params[1] " " NickColor(Nick) " has parted" (Msg ? " (" Msg ")" : ""))
		this.UpdateListView()
	}
	
	onNICK(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		; Can't use nick, was already handled by class
		if (User == this.User)
			this.UpdateDropDown()
		AppendChat(NickColor(Nick) " changed its nick to " NickColor(Msg))
		this.UpdateListView()
	}
	
	onKICK(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		if (Params[2] == this.Nick)
			this.UpdateDropDown()
		AppendChat(Params[1] " " NickColor(Params[2]) " was kicked by " NickColor(Nick) " (" Msg ")")
		this.UpdateListView()
	}
	
	onQUIT(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		AppendChat(NickColor(Nick) " has quit (" Msg ")")
		this.UpdateListView()
	}
	
	UpdateDropDown(Default="")
	{
		DropDL := "|" this.Nick "|"
		if (!Default)
			GuiControlGet, Default,, Channel
		for Channel in this.Channels
			DropDL .= Channel "|" (Channel==Default ? "|" : "")
		if (!this.Channels.hasKey(Default))
			DropDL .= "|"
		GuiControl,, Channel, % DropDL
	}
	
	UpdateListView()
	{
		GuiControlGet, Channel
		
		GuiControl, -Redraw, ListView
		LV_Delete()
		for Nick in this.GetMODE(Channel, "o")
			LV_Add("", this.Prefix.Letters["o"] . Nick)
		for Nick in this.GetMODE(Channel, "v -o") ; voiced not opped
			LV_Add("", this.Prefix.Letters["v"] . Nick)
		for Nick in this.GetMODE(Channel, "-ov") ; not opped or voiced
			LV_Add("", Nick)
		GuiControl, +Redraw, ListView
	}
	
	onINVITE(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		if (User == this.User)
			this.SendJOIN(Msg)
	}
	
	onCTCP(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		if (Cmd = "ACTION")
			AppendChat(Params[1] " * " NickColor(Nick) " " Msg)
		else
			this.SendCTCPReply(Nick, Cmd, "Zark off!")
	}
	
	onNOTICE(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		AppendChat("-" NickColor(Nick) "- " Msg)
	}
	
	onPRIVMSG(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		AppendChat(Params[1] " <" NickColor(Nick) "> " Msg)
		
		if (Nick == this.Nick)
			return
		
		if InStr(Msg, this.Nick)
		{
			SoundBeep
			TrayTip, % this.Nick, % "<" Nick "> " Msg
		}
	}
	
	OnDisconnect(Socket)
	{
		ChannelBuffer := []
		for Channel in this.Channels
			ChannelBuffer.Insert(Channel)
		
		AppendLog("Attempting to reconnect: try #1")
		while !this.Connect(this.Server, this.Port, this.DefaultNicks[1], this.DefaultUser, this.Name, this.Pass)
		{
			Sleep, 5000
			AppendLog("Attempting to reconnect: try #" A_Index+1)
		}
		
		this.SendJOIN(ChannelBuffer*)
		
		this.UpdateDropDown()
		this.UpdateListView()
	}
	
	Chat(Channel, Message)
	{
		Messages := this.SendPRIVMSG(Channel, Message)
		for each, Message in Messages
			AppendChat(Channel " <" NickColor(this.Nick) "> " Message)
		return Messages
	}
	
	; ERR_NICKNAMEINUSE
	on433(Nick,User,Host,Cmd,Params,Msg,Data)
	{
		this.Reconnect()
	}
	
	Reconnect()
	{
		for Index, Nick in this.DefaultNicks
			if (Nick == this.Nick)
				Break
		Index := (Index >= this.DefaultNicks.MaxIndex()) ? 1 : Index+1
		NewNick := this.DefaultNicks[Index]
		
		AppendChat(NickColor(this.Nick) " changed its nick to " NickColor(NewNick))
		
		this.SendNICK(newNick)
		this.Nick := newNick
		
		this.UpdateDropDown()
		this.UpdateListView()
	}
	
	Log(Message)
	{
		AppendLog(Message)
	}
	
	AppendChat(Message)
	{
		AppendChat(Message)
	}
}

AppendLog(Message)
{
	static WM_VSCROLL := 0x115, SB_BOTTOM := 7
	, EM_SETSEL := 0xB1, EM_REPLACESEL := 0xC2
	, EM_GETSEL := 0xB0, WM_GETTEXTLENGTH := 0xE
	, EM_SCROLLCARET := 0xB7
	global hLog
	
	Message := RegExReplace(Message, "\R", "") "`r`n"
	
	GuiControl, -Redraw, %hLog%
	
	VarSetCapacity(Sel, 16, 0)
	SendMessage(hLog, EM_GETSEL, &Sel, &Sel+8)
	Min := NumGet(Sel, 0, "UInt")
	Max := NumGet(Sel, 8, "UInt")
	
	Len := SendMessage(hLog, WM_GETTEXTLENGTH, 0, 0)
	SendMessage(hLog, EM_SETSEL, Len, Len)
	SendMessage(hLog, EM_REPLACESEL, False, &Message)
	
	if (Min != Len)
	{
		SendMessage(hLog, EM_SETSEL, Min, Max)
		GuiControl, +Redraw, %hLog%
	}
	else
	{
		GuiControl, +Redraw, %hLog%
		SendMessage(hLog, WM_VSCROLL, SB_BOTTOM, 0)
	}
}

AppendChat(Message)
{
	static WM_VSCROLL := 0x115, SB_BOTTOM := 7
	global Chat, Colors, Font
	
	Message := RegExReplace(Message, "\R", "") "`n"
	
	FormatTime, Stamp,, [hh:mm]
	RTF := ToRTF(Stamp " " Message, Colors, Font)
	
	GuiControl, -Redraw, % Chat.hWnd
	
	Sel := Chat.GetSel()
	Len := Chat.GetTextLen()
	Chat.SetSel(Len, Len)
	Chat.SetText(RTF, ["SELECTION"])
	
	if (Sel.S == Len)
	{
		GuiControl, +Redraw, % Chat.hWnd
		SendMessage(Chat.hWnd, WM_VSCROLL, SB_BOTTOM, 0)
	}
	else
	{
		Chat.SetSel(Sel.S, Sel.E)
		GuiControl, +Redraw, % Chat.hWnd
	}
	
	GuiControl, MoveDraw, % Chat.hWnd ; Updates scrollbar position in WINE
}

SendMessage(hWnd, Msg, wParam, lParam)
{
	return DllCall("SendMessage", "UPtr", hWnd, "UInt", Msg, "UPtr", wParam, "Ptr", lParam)
}

ToRTF(Text, Colors, Font)
{
	FontTable := "{\fonttbl{\f0\fnil\fcharset0 "
	FontTable .= Font.Name
	FontTable .= ";`}}"
	
	ColorTable := "{\colortbl"
	for each, Color in Colors
	{
		Red := "0x" SubStr(Color, 1, 2)
		Green := "0x" SubStr(Color, 3, 2)
		Blue := "0x" SubStr(Color, 5, 2)
		ColorTable .= ";\red" Red+0 "\green" Green+0 "\blue" Blue+0
	}
	Color := Font.Color & 0xFFFFFF
	ColorTable .= ";\red" Color>>16&0xFF "\green" Color>>8&0xFF "\blue" Color&0xFF
	ColorTable .= ";`}"
	
	RTF := "{\rtf"
	RTF .= FontTable
	RTF .= ColorTable
	
	for each, Char in ["\", "{", "}", "`r", "`n"]
		StringReplace, Text, Text, %Char%, \%Char%, All
	
	While RegExMatch(Text, "^(.*)\x03(\d{0,2})(?:,(\d{1,2}))?(.*)$", Match)
		Text := Match1 . ((Match2!="") ? "\cf" Match2+1 : "\cf1") . ((Match3!="") ? "\highlight" Match3+1 : "") " " Match4
	
	Bold := Chr(2)
	Color := Chr(3)
	Normal := Chr(15)
	Italic := Chr(29)
	Under := Chr(31)
	NormalFlags := "\b0\i0\ul0\cf17\highlight0\f0\fs" Font.Size*2
	
	tBold := tItalic := tUnder := false
	For each, Char in StrSplit(Normal . Text . Normal)
	{
		if (Char == Bold)
			RTF .= ((tBold := !tBold) ? "\b1" : "\b0") " "
		else if (Char == Italic)
			RTF .= ((tItalic := !tItalic) ? "\i1" : "\i0") " "
		else if (Char == Under)
			RTF .= ((tUnder := !tUnder) ? "\ul1" : "\ul0") " "
		else if (Char == Normal)
			RTF .= NormalFlags " ", tBold := tItalic := tUnder := False
		else if (Asc(Char) > 0xFF)
			RTF .= "\u" Asc(Char) . Char
		else
			RTF .= Char
	}
	
	RTF .= "}"
	return RTF
}

GetScrollInfo(hWnd)
{
	SizeOf := VarSetCapacity(SIF, 28, 0) ; 7 ints/uints
	NumPut(SizeOf, SIF, 0, "UInt")
	NumPut(23, SIF, 4, "UInt") ; SIF_ALL
	DllCall("GetScrollInfo", "Ptr", hWnd, "Int", 0x1, "Ptr", &SIF)
	Min := NumGet(SIF, 2*4, "Int")
	Max := NumGet(SIF, 3*4, "Int")
	Page := NumGet(SIF, 4*4, "UInt")
	Pos := NumGet(SIF, 5*4, "Int")
	return {"Min": Min, "Max": Max, "Page": Page, "Pos": Pos}
}

NickColor(Nick)
{
	for each, Char in StrSplit(Nick)
		Sum += Asc(Char)
	
	Color := Mod(Sum, 16)
	if Color in 0,1,14,15
		Color := Mod(Sum, 12) + 2
	
	return Chr(2) . Chr(3) . Color . Nick . Chr(3) . Chr(2)
}
