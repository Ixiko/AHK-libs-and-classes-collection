; Link:
; Author:
; Date:
; for:     	AHK_L

/*


*/

;DebugHelper.ahk
global DebugWindow_TextBox_Control
global hDebugWindow_TextBox_Control
global DebugWindow_

Class Debug{

	static m_WindowOn := false
	static m_stack:=0
	static m_DebugLevel:=0
	MsgBox(Text) 	{
		MsgBox, 262144, Debug, %Text%
	}
	InitDebugWindow() 	{
		last:=a_defaultgui
		this.m_WindowOn := true
		this.m_stack := 0
		this.m_DebugLevel:=0
		this.m_MaxSize := 128*1024
		Gui, DebugWindow_:Default

		;allow resize
		Gui, +resize

		Gui, Color, 000000, 000022
		Gui, Font, q5 cAAAAAA s11,Courier New
		;Gui, Color, 000000, %DebugBackColor%
		;Gui, Font, c%DebugFontColor% w%DebugFontWeight% s%DebugFontSize%, %DebugFontName%

		Gui, Add, Edit, -Wrap +HScroll x0 y0 W400 H400 hwndhDebugWindow_TextBox_Control vDebugWindow_TextBox_Control

		Gui, Show, , Debug Console
		WinSet, Top, , Debug Console
		Gui, %last%:Default
	}
	;basic write functions
	Write(Text, DebugLevel:=0) 	{
		if(DebugLevel<this.GetDebugLevel())
		{
			return
		}
		if(!this.m_WindowOn)
		{
			this.InitDebugWindow()
		}
		this._AppendText(hDebugWindow_TextBox_Control,Text)
	}
	WriteNL(Text, DebugLevel:=0)
	{
		if(DebugLevel<this.GetDebugLevel())
		{
			return
		}
		this.Write(Text . chr(13) . chr(10),DebugLevel)
	}
	WriteSP(Text, DebugLevel:=0)
	{
		if(DebugLevel<this.GetDebugLevel())
		{
			return
		}
		this.Write(Text . " ",DebugLevel)
	}
	WriteClear(Text, DebugLevel:=0)
	{
		if(DebugLevel<this.GetDebugLevel())
		{
			return
		}
		this._SetText(hDebugWindow_TextBox_Control,Text)
	}
	;The Max Size of the content, before the ouput is cleared
	GetMaxSize()
	{
		return this.m_MaxSize
	}
	SetMaxSize(MaxSize)
	{
		this.m_MaxSize := MaxSize
	}
	;DebugLevel, setting the debug level to 0,1,2,.... commands now take a Debug Level, 0 being default.
	;the write calls will show if above or equal to the debug level
	;If you WriteNL at debug level 2 and the debug level is 1, meaning out every message of level 1 and above
	;the message will log to the output window
	;Debug Level 0 is considered System Level, log every call
	;One could have a debug level of 3 for useful things
	;2 for more information
	;1 for things like try catch failures
	;0 to log everything your program does
	SetDebugLevel(DebugLevel)
	{
		this.m_DebugLevel := DebugLevel
	}
	GetDebugLevel()
	{
		return this.m_DebugLevel
	}
	;Stack write function to indent/un-intend, each function returns the stack position if you need to reset after a break call for example
	GetStack()
	{
		return this.m_stack
	}
	SetStack(Level)
	{
		this.m_stack :=level
		return this.m_stack
	}
	ClearStack()
	{
		this.m_stack := 0
		return this.m_stack
	}
	IncStack()
	{
		this.m_stack ++
		return this.GetStack()
	}
	DecStack()
	{
		this.m_stack --
		return this.GetStack()
	}
	WriteStackPush(Text, DebugLevel:=0)
	{
		if(DebugLevel<this.GetDebugLevel())
		{
			return this.IncStack()
		}
		this.WriteStack(Text,DebugLevel)
		this.IncStack()
		return this.GetStack()
	}
	WriteStackPop(Text, DebugLevel:=0)
	{
		if(DebugLevel<this.GetDebugLevel())
		{
			return this.DecStack()
		}
		this.DecStack()
		this.WriteStack(Text)
		return this.GetStack()
	}
	WriteStackClear(Text, DebugLevel:=0)
	{
		if(DebugLevel<this.GetDebugLevel())
		{
			return this.ClearStack()
		}
		this.ClearStack()
		this.WriteStack(Text,DebugLevel)
		return this.GetStack()
	}
	WriteStackClearTo(Text,Level, DebugLevel:=0)
	{
		if(DebugLevel<this.GetDebugLevel())
		{
			return this.SetStack(Level)
		}
		this.SetStack(Level)
		this.WriteStack(Text,DebugLevel)
		return this.GetStack()
	}
	WriteStack(Text, DebugLevel:=0)
	{
		if(DebugLevel<this.GetDebugLevel())
		{
			return this.GetStack()
		}
		ct := this.m_stack
		loop, %ct%
		{
			this.Write("  ",DebugLevel)
		}
		this.WriteNL(Text,DebugLevel)
		return this.GetStack()
	}

	_AppendText(hEdit, Text)
	{
		if(DllCall( "GetWindowTextLength", UInt, hEdit)>this.GetMaxSize())
		{
			this._SetText(hEdit,"")
		}

		SendMessage, 0x000E, 0, 0,, ahk_id %hEdit% ;WM_GETTEXTLENGTH
		SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, ahk_id %hEdit% ;EM_SETSEL
		SendMessage, 0x00C2, False, &Text,, ahk_id %hEdit% ;EM_REPLACESEL
	}

	_SetText(hEdit,Text)
	{
		SendMessage, 0x000C, False, &Text,, ahk_id %hEdit% ;EM_SETTEX
	}
	CloseOutput()
	{
		last:=a_defaultgui
		Gui, DebugWindow_:Default
		Gui, Destroy
		Gui, %last%:Default
		this.m_WindowOn := false
	}
	OnEnter()
	{
		last:=a_defaultgui
		Gui, DebugWindow_:Default
		GuiControlGet, DebugWindow_TextBox_Control
		LastText := ""

		LastText:=substr(DebugWindow_TextBox_Control,inStr(DebugWindow_TextBox_Control,"`n",,0)+1)

		DoCaret:=true
		;Output Window Commands
		if(LastText = ">Close")
		{
			DoCaret := false
			this.CloseOutput()

		}
		else if(LastText = ">Exit")
		{
			DoCaret := false
			ExitApp
		}
		else if(LastText = ">Clear")
		{
			DoCaret := false
			this.WriteClear("",100000)
		}
		else if(LastText = ">set debug level 0") ;I'll be lazy
		{
			this.SetDebugLevel(0)
			this.WriteNL("",100000)
			this.WriteNL("debug level -> 0",100000)

		}
		else if(LastText = ">set debug level 1") ;I'll be lazy
		{
			this.SetDebugLevel(1)
			this.WriteNL("",100000)
			this.WriteNL("debug level -> 1",100000)

		}
		else if(LastText = ">set debug level 2") ;I'll be lazy
		{
			this.SetDebugLevel(2)
			this.WriteNL("",100000)
			this.WriteNL("debug level -> 2",100000)

		}
		else if(LastText = ">set debug level 3") ;I'll be lazy
		{
			this.SetDebugLevel(3)
			this.WriteNL("",100000)
			this.WriteNL("debug level -> 3",100000)

		}
		else if(LastText = ">set debug level 4") ;I'll be lazy
		{
			this.SetDebugLevel(4)
			this.WriteNL("",100000)
			this.WriteNL("debug level -> 4",100000)

		}
		else if(LastText = ">set debug level 5") ;I'll be lazy
		{
			this.SetDebugLevel(5)
			this.WriteNL("",100000)
			this.WriteNL("debug level -> 5",100000)

		}
		else if(LastText = ">get debug level") ;I'll be lazy
		{
			this.WriteNL("",100000)
			this.WriteNL("debug level is " . this.GetDebugLevel(),100000)

		}
		if(DoCaret)
		{
			;Force the caret to be on the last line, add a > prompt. For commands, a first enter is needed to get to the prompt
			send, ^{end}{enter}>
		}
		Gui, %last%:Default
	}
}

;Window Resize event
DebugWindow_GuiSize(GuiHwnd, EventInfo, Width, Height)
{
	; The window has been minimized.  No action needed.
	if(EventInfo <> 1)
	{
		last:=a_defaultgui
		Gui, DebugWindow_:Default
		GuiControl, Move, DebugWindow_TextBox_Control, % "H" . (Height) . " W" . (Width)
		Gui, %last%:Default
	}
	return
}
DebugWindow_GuiClose()
{
	Debug.CloseOutput()
}
DebugWindow_GuiEscape()
{
	Debug.CloseOutput()
}


return
#IfWinActive , Debug Console
enter::
Debug.OnEnter()
return