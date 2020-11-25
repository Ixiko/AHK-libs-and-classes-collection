#NoEnv
SetBatchLines, -1

#Include %A_ScriptDir%\..\..\class_Socket.ahk

Random, Rand, 1000, 9999

Serv := ["chat.freenode.net", 6667]
Chan := "#ahk"
Nick := "Socket" Rand

; Create the Gui
Gui, Margin, 5, 5
Gui, Add, Edit, w640 h240 ReadOnly hWndhLog
Gui, Add, Edit, w640 h240 ReadOnly hWndhChat
Gui, Add, Edit, w580 h20 vMessage
Gui, Add, Button, x+m yp-1 w55 h22 gSubmit Default, Submit
GuiControl, Focus, Message
Gui, Show

; Create the IRC client class instance
Client := new IRC()
Client.hLog := hLog
Client.hChat := hChat

Client.Connect(Serv, Nick)
Client.SendText("JOIN " Chan)
return

GuiClose() {
	ExitApp
}

Submit() {
	global Client, Chan, hChat

	; Get the message box contents and empty the message box
	GuiControlGet, Message
	GuiControl,, Message

	Client.SendText("PRIVMSG " Chan " :" Message)
	EditAppend(hChat, Chan " <" Client.Nick "> " Message)
}

; Use the windows API to append text to an edit control quickly and efficiently
EditAppend(hEdit, Text) {
	Text .= "`r`n"
	GuiControl, -Redraw, %hEdit%
	SendMessage, 0x00E, 0, 0,, ahk_id %hEdit% ; WM_GETTEXTLENGTH
	SendMessage, 0x0B1, ErrorLevel, ErrorLevel,, ahk_id %hEdit% ; EM_SETSEL
	SendMessage, 0x0C2, False, &Text,, ahk_id %hEdit% ; EM_REPLACESEL
	SendMessage, 0x115, 7, 0,, ahk_id %hEdit% ; WM_VSCROLL SB_BOTTOM
	GuiControl, +Redraw, %hEdit%
}

class IRC extends SocketTCP{

	static Blocking := False
	static Buffer, hLog, hChat

	Connect(Address, Nick, User:="", Name:="", Pass:="") 	{

		this.Nick := Nick
		this.User := (User == "") ? Nick : User
		this.Name := (Name == "") ? Nick : Name
		Socket.Connect.Call(this, Address)
		if (Pass != "")
			this.SendText("PASS " Pass)
		this.SendText("NICK " this.Nick)
		this.SendText("USER " this.User " 0 * :" this.Name)

	}

	SendText(Text, Encoding:="UTF-8")	{

		EditAppend(this.hLog, ">" Text)

		; Because we're overriding SendText, we have
		; to use the SendText from the base class.
		SocketTCP.SendText.Call(this, Text "`r`n",, Encoding)
	}

	OnRecv() 	{

		; Read the incoming bytes as ANSI (single byte encoding)
		; so we won't accidentally destroy partial UTF-8 multi-byte sequences.
		this.Buffer .= this.RecvText(,, "CP0")

		; Split the buffer into one or more lines, putting
		; any remaining text back into the buffer.
		Lines := StrSplit(this.Buffer, "`n", "`r")
		this.Buffer := Lines.Pop()

		for Index, Line in Lines
		{
			; Convert to UTF-8 now that we have a full line.
			; Because we read until the end of the line,
			; we know there won't be any partially read sequences.
			VarSetCapacity(ConvBuf, StrPut(Line, "CP0"))
			StrPut(Line, &ConvBuf, "CP0")
			Line := StrGet(&ConvBuf, "UTF-8")

			EditAppend(this.hLog, "<" Line)
			this.ParseLine(Line)
		}

	}

	ParseLine(Line)	{
		IRCRE := "O)^(?::(\S+?)(?:!(\S+?))?(?:@(\S+?))? )?" ; Nick!User@Host
		. "(\S+)(?: (?!:)(.+?))?(?: :(.+))?$" ; CMD Params Params :Message
		if !RegExMatch(Line, IRCRE, Match)
			EditAppend(this.hLog, "PARSING ERROR")

		; Call the class method by the name OnCMD
		this["On" Match[4]](Match)

	}

	OnNICK(Match)	{

		if (Match[1] == this.Nick)
			this.Nick := Match[6]

	}

	OnPING(Match)	{

		this.SendText("PONG :" Match[6])

	}

	OnPRIVMSG(Match)	{

		EditAppend(this.hChat, Match[5] " <" Match[1] "> " Match[6])

	}
}
