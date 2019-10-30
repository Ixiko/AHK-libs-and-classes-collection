;=========================================Total Commander=====================
TcmdSelByMask(mask) {
	IfWinActive ahk_class TTOTAL_CMD
	{
		PostMessage 1075, 521, , , ahk_class TTOTAL_CMD
		send, % mask
		Controlclick, OK, ahk_class TCOMBOINPUT
	}
}

TcmdDeselByMask(mask) {
	IfWinActive ahk_class TTOTAL_CMD
	{
		PostMessage 1075, 522, , , ahk_class TTOTAL_CMD
		send, % mask
		Controlclick, OK, ahk_class TCOMBOINPUT
	}
}

TcmdSelByList(selection) {
	temp := Clipboard
	Clipboard := selection
	SendMessage, 1075, 2033	; cm_LoadSelectionFromClip, inactive panel
	Clipboard := temp
}

TcmdGetSel() {
	IfWinActive, ahk_class TTOTAL_CMD 
	{
		temp := Clipboard
			Clipboard := ""
			SendMessage, 1075, 2017	; cm_CopyNamesToClip, active panel
			ClipWait, 2
			if (Clipboard = "")
			{
				MsgBox, 16,, Timeout while trying to get selection info (active window).
				Return
			}
			selection := Clipboard
		Clipboard := temp
		tooltip, % selection
		return selection
	}
}

TcmdGetSrcPath() {
	IfWinActive, ahk_class TTOTAL_CMD 
	{
		temp := Clipboard
			Clipboard := ""
			SendMessage, 1075, 2029	; copy source to CB
			ClipWait, 2
			if (Clipboard = "")
			{
				MsgBox, 16,, Timeout while trying to get selection info (active window).
				Return
			}
			selection := Clipboard
		Clipboard := temp
		return selection
	}
}

TcmdToggleWindowed() {
	IfWinActive, ahk_class TTOTAL_CMD 
	{
		WinGet, maximized, MinMax
		if (maximized = 1) {
			WinRestore ;windowize
			SendMessage, 1075, 910	;separator 100%
			SendMessage, 1075, 2901	;hide button bars
			SendMessage, 1075, 2903	;hide two drive bars
			SendMessage, 1075, 2909	;hide status
			SendMessage, 1075, 2910	;hide cmd
			SendMessage, 1075, 2911	;hide func
		} else {
			WinMaximize ;maximize
			SendMessage, 1075, 909 ;separator 50%
			SendMessage, 1075, 2901	;show button bars
			SendMessage, 1075, 2903	;show two drive bars
			SendMessage, 1075, 2909	;show status
			SendMessage, 1075, 2910	;show cmd
			SendMessage, 1075, 2911	;show func
		}
	}
}

resetConsoleCommand(args, arg1) {
	console.commandStr := ""
	loop, % arg1-1
	{
		console.commandStr := console.commandStr args[A_Index] " "
	}
}

global prevSel = ""
CDX(args, arg1) {
	RunOrActivateApp(Path_totalcmd, Wnd_totalcmd)
	if (!WinActive(Wnd_totalcmd)) {
		console.Accept("Total Commander is not running.", -1, 0xFFDD5555)
		return
	}
	if (!args[arg1]) {														;just display a message that cdx command is found
		console.Accept("cdx...", -1, 0xFF99DD99)
		send, ^{NumpadSub}{Home}
		return
	}
	if (args[arg1] = ".") {												;send home key
		Send, {Home}
		console.Accept("cdx: go home", -1, 0xFF55DD55)
		return
	}
	if (args[arg1] = "..") {											;go to parent and reset command
		SendMessage, 1075, 2002	;Go to parent directory
		resetConsoleCommand(args, arg1)
		console.Accept("cdx: go up", -1, 0xFF55DD55)
		return
	}
	mask := "*" args[arg1] "*"
	send, ^{NumpadSub}{Home}
	dir := TcmdGetSrcPath()
	files := GetFilesFromDir(dir, mask)
	if (!files) {
		console.Accept("cdx: no matches", -1, 0xFFDD5555)
		return
	}
	TcmdSelByList(files)
	SendMessage, 1075, 2053 ;Go to next selected file
	
	splitted := StrSplit(files, "`n")
	numMatches := splitted.MaxIndex()
	;tooltip, % files "`n`n" prevSelection
	if (numMatches = 1) {
		;if (prevSel = files) {
			SendMessage, 1075, 1001 ;Simulate: Return pressed
			resetConsoleCommand(args, arg1)
			console.Accept("cdx: " splitted[1], -1, 0xFF00DD00)
			;path := TcmdGetSrcPath() "\" splitted[1]
			;Run, % Path_filemanager " /O " path
			prevSel := ""
			return
		;} else {
		;	console.Accept("cdx: " files, -1, 0xFF006600)
		;	return
		;}
	}
	prevSel := files
	console.Accept("cdx: " numMatches " items...", -1, 0xFF006600)
}