/*
	Usage:
		GuiAddF(oText = "", oEdit = "", oFSel = "")
		
	Parameters:
		oText := {Opt: "", Text: ""}
		oEdit := {Opt: "", Text: ""}
		oFSel := {Opt: "", defPath: "", Prompt: "", Filter: "", cmd: "", OnFinish: ""}
	Return:
		{HEdit: HEdit, HBtn_Browse: HBtn_Browse, HBtn_Open: HBtn_Open}
	Example:
		GuiAddF({text:"      Dir", opt:"xm cBlue"}, {opt:"w350 vrootDir", text: rootDir}, {cmd:"FileSelectFolder"})
		GuiAddF({text:"Text File"}, {opt:"w350 vtxtFile", text: txtFile}, {Filter:"*.txt", OnFinish: "selectFinish"})
		GuiAddF_2({text:"Select Files"}, {opt:"w470 r3 vFile3"}, {cmd:"FileSelectFile", opt:"m"})
		Gui, Show
		Return

		GuiClose:
		ExitApp
		
		selectFinish(HEDIT, SelectedPath) {
			MsgBox, % HEDIT . "`n" . SelectedPath
		}
*/

GuiAddF(p*) {
	Return GuiAddF.AddControl(p*)
}

GuiAddF_2(p*) {
	Return GuiAddF.AddControl_Style2(p*)
}

Class GuiAddF {

	static oSel := {}, oOpen := {}
	static Init := GuiAddF.InitBtnText()

	AddControl(oText = "", oEdit = "", oFSel = "") {
		global
		local HEdit, HBtn_Browse, HBtn_Open

		Gui, Add, Text, % oText.Opt ? oText.Opt : "xm", % oText.Text
		Gui, Add, Edit, % "x+5 w300 HwndHEdit r1 " . oEdit.Opt, % oEdit.Text
		Gui, Add, Button, % "x+5 HwndHBtn_Browse gGuiAddF.FileSelect", % this.BtnText.Browse
		Gui, Add, Button, % "x+5 HwndHBtn_Open gGuiAddF.Open", % this.BtnText.Open

		oFSel.defPath := (oFSel.defPath = "") ? "*" A_ScriptDir : oFSel.defPath
		this.oSel[HBtn_Browse] := {HEdit: HEdit, base: oFSel}
		this.oOpen[HBtn_Open] := {HEdit: HEdit}
		Return {HEdit: HEdit, HBtn_Browse: HBtn_Browse, HBtn_Open: HBtn_Open}
	}

	AddControl_Style2(oText = "", oEdit = "", oFSel = "") {
		global
		local HEdit, HBtn_Browse, HBtn_Open

		Gui, Add, Text, % (oText.Opt ? oText.Opt : "xm") . " Section", % oText.Text
		Gui, Add, Link, % "x+20 HwndHBtn_Browse gGuiAddF.FileSelect", % "<a>" . this.BtnText.Browse . "</a>"
		Gui, Add, Link, % "x+20 HwndHBtn_Open gGuiAddF.Open", % "<a>" . this.BtnText.Open . "</a>"
		Gui, Add, Edit, % "xs+20 w400 HwndHEdit r1 " . oEdit.Opt, % oEdit.Text

		oFSel.defPath := (oFSel.defPath = "") ? "*" A_ScriptDir : oFSel.defPath
		this.oSel[HBtn_Browse] := {HEdit: HEdit, base: oFSel}
		this.oOpen[HBtn_Open] := {HEdit: HEdit}

		this.KillFocus(HBtn_Browse)
		this.KillFocus(HBtn_Open)
		Return {HEdit: HEdit, HBtn_Browse: HBtn_Browse, HBtn_Open: HBtn_Open}
	}

	FileSelect() {
		oFSel := GuiAddF.oSel[this]

		Gui, +OwnDialogs
		If (oFSel.cmd = "FileSelectFolder")
			FileSelectFolder, fPath, % oFSel.defPath, % oFSel.Opt, % oFSel.Prompt
		Else
			FileSelectFile, fPath, % oFSel.Opt, % oFSel.defPath, % oFSel.Prompt, % oFSel.Filter

		If fPath {
			If InStr(oFSel.Opt, "m") {
				Loop, Parse, fPath, `n, `r
				{
					If (A_Index = 1)
						dir := A_LoopField
					Else
						fullPathList .= dir . "\" A_LoopField . "`n"
				}
				fPath := Trim(fullPathList, "`n")
			}
			
			GuiControl,, % oFSel.HEdit, % StrReplace(fPath, A_ScriptDir "\")

			If oFSel.OnFinish
				Func(oFSel.OnFinish).Call(oFSel.HEdit, fPath)
		}

		GuiAddF.KillFocus(this)
	}

	Open() {
		GuiAddF.KillFocus(this)
		GuiControlGet, value,, % GuiAddF.oOpen[this].HEdit
		Run, % value,, UseErrorLevel
	}

	InitBtnText() {
		this.BtnText := {}
		this.BtnText.Browse := this.Read_StringTable("shell32.dll", 9015)
		this.BtnText.Open := this.Read_StringTable("shell32.dll", 12850)
		Return True
	}

	Read_StringTable(DllFile, StringNum) {
		hModule := DllCall("LoadLibrary", "str", DllFile, "Ptr")
		VarSetCapacity(string, 1024)
		DllCall("LoadString", "uint", hModule, "uint", StringNum, "uint", &string, "int", 1024)
		DllCall("FreeLibrary", "Ptr", hModule)
		Return string
	}

	KillFocus(HCTRL) {
		PostMessage, 0x0008, 0, 0, , % "ahk_id " HCTRL ; WM_KILLFOCUS := 0x0008
	}
}