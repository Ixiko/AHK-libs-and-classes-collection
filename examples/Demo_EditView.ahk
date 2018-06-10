#Include EditView.ahk

; For the demo, we'll use the script's Main window's Edit control
DetectHiddenWindows On
WinMove ahk_id %A_ScriptHwnd%,, % A_ScreenWidth//2, 0, % A_ScreenWidth//2
WinShow ahk_id %A_ScriptHwnd% ; show the window

; Create an EditView object
view := new EditView(A_ScriptHwnd)

; Set the text content
view.Text := "
(
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
)"

; We'll use a console for I/O
cnsl := new Console()
WinMove % "ahk_id " . cnsl.Window,, 0, 0

; Start REPL
cnsl.WriteLine("This is an interactive demo, follow the instructions in the console.`n")


; LINE EDITING
cnsl.Write("[LINE EDITING]`nEnter the line number of the line whose text you want to retrieve`n>>> ")

; Retrieve
ln := RTrim(cnsl.ReadLine(), "`n")
cnsl.PrintF("Line #{}: {}`n", ln, view.Line[ln])

; Replace/Set
cnsl.Write("Enter the line number of the line whose text you want to replace`n>>> ")
ln := RTrim(cnsl.ReadLine(), "`n")
cnsl.Write("Type the replacement text`n>>> ")
text := RTrim(cnsl.ReadLine(), "`n")
view.Line[ln] := text ; replace the line
cnsl.PrintF("Line replaced [line {}]: {}", ln, text)


; SELECTION
cnsl.Write("`n[SELECTION]`nEnter the row, column number and length of the "
           . "selection(each separated by a space)`n>>> ")
sel := StrSplit(RTrim(cnsl.ReadLine(), "`n"), " ")
selection := view.Sel[sel[1], sel[2]] := sel[3]
cnsl.WriteLine(Format("Selected text: {}", selection))


; EXTRACTING and INSERTING TEXT
; Extract
cnsl.Write("`n[EXTRACTING and INSERTING TEXT]`nEnter the row, column number "
           . "and length of the substring you want to extract(each separated by a space)`n>>> ")
sub := StrSplit(RTrim(cnsl.ReadLine(), "`n"), " ")
sub[4] := view.Sub[sub*]
cnsl.PrintF("Extracted string [row {}; col {}; len {}]: {}", sub*)

; Insert
cnsl.Write("`nEnter the row, column number and length where you want to "
           . "insert the substring(each separated by a space)`n>>> ")
sub := StrSplit(RTrim(cnsl.ReadLine(), "`n"), " ")
cnsl.Write("Type the substring to insert`n>>> ")
substring := RTrim(cnsl.ReadLine(), "`n")
view.Sub[sub*] := substring, sub[4] := substring
cnsl.PrintF("Inserted string [row {}; col {}; len {}]: {}", sub*)

; DEMO DONE
cnsl.WriteLine("`nThat's all for now, press 'Escape' to exit demo.")
Loop
	KeyWait Escape, D
until (WinActive("A") == cnsl.Window || WinActive("A") == A_ScriptHwnd)

cnsl := "" ; free console
ExitApp

class Console
{
	static Self := 0
	__New(pid:=0)
	{
		if ptr := Console.Self
		{
			try self := Object(ptr)
			if self
				return self
		}

		if this._Alloc := !this.Window
		{
			if pid
				DllCall("AttachConsole", "UInt", pid)
			else
			{
				DllCall("AllocConsole")
				if !DllCall("IsWindowVisible", "Ptr", hCon := this.Window)
					WinShow ahk_id %hCon%
			}
		}
		
		this._IsInstance := true
		Console.Self := &this
	}

	__Delete()
	{
		if this._IsInstance
		{
			if this.Window && this._Alloc
				DllCall("FreeConsole")
			Console.Self := 0
		}
	}

	__Get(key, args*)
	{
		if (key = "Window")
			return DllCall("GetConsoleWindow")
		if (key = "Writer")
			return FileOpen("CONOUT$", 1|4)
		else if (key = "Reader")
			return FileOpen("CONIN$", 0|4)
	}

	__Call(name, args*)
	{
		if InStr(",Read,ReadLine,Write,WriteLine,PrintF,", "," . name . ",")
		{
			if (name = "PrintF")
				name := "WriteLine", args := [Format(args*)]
			io := this[ SubStr(name, 1, 4) . "er" ]
			return io[name](args*)
		}
	}
}