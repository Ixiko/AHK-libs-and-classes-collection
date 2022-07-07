; AHK v2
; #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.

Global IconSelectInputHook, ; IconIndexArray ; IconSelectStandalone ; IconSelectFile ; IconSelectIndex ; IconSelectUserGui

; IconSelectStandalone := 1	; comment out to use as library
; If (IconSelectStandalone)	; comment out to use as library
	; IconSelectGui()			; comment out to use as library
; ================================================================
; EXAMPLE
; ================================================================
g := GuiCreate()
g.Show("w600 h600 x100 y100")

i := "%SystemRoot%\system32\shell32.dll"
oIcon := IconSelectGui(i,g.hwnd)

If (oIcon.handle)
	msgbox "Index: " oIcon.index "`r`nHandle: " oIcon.handle "`r`ntype: " oIcon.type "`r`nfile: " oIcon.file

ExitApp
; ================================================================
; Parameters
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; sIconFile = used to save selected icon file
; outputType = "index" or "handle"
; ================================================================
; returns object with properties:
;    type, handle, index, file
IconSelectGui(sIconFile := "",hwnd:=0) {
	IconSelectFileList := "%SystemRoot%\explorer.exe|"
		  . "%SystemRoot%\system32\accessibilitycpl.dll|"
		  . "%SystemRoot%\system32\ddores.dll|"
		  . "%SystemRoot%\system32\gameux.dll|"
		  . "%SystemRoot%\system32\imageres.dll|"
		  . "%SystemRoot%\system32\mmcndmgr.dll|"
		  . "%SystemRoot%\system32\mmres.dll|"
		  . "%SystemRoot%\system32\mstscax.dll|"
		  . "%SystemRoot%\system32\netshell.dll|"
		  . "%SystemRoot%\system32\networkmap.dll|"
		  . "%SystemRoot%\system32\pifmgr.dll|"
		  . "%SystemRoot%\system32\SensorsCpl.dll|"
		  . "%SystemRoot%\system32\setupapi.dll|"
		  . "%SystemRoot%\system32\shell32.dll|"
		  . "%SystemRoot%\system32\UIHub.dll|"
		  . "%SystemRoot%\system32\vpc.exe|"
		  . "%SystemRoot%\system32\wmp.dll|"
		  . "%SystemRoot%\system32\wmploc.dll|"
		  . "%SystemRoot%\system32\wpdshext.dll|"
		  . "%SystemRoot%\system32\wucltux.dll|"
		  . "%SystemRoot%\system32\xpsrchvw.exe"
		 
	Loop Parse IconSelectFileList, "|"
	{
		sillyFile := StrReplace(A_LoopField,"%SystemRoot%",A_WinDir)
		If (FileExist(sillyFile))
			newList .= sillyFile "|"
	}
	newList := Trim(newList,"|")
	IconSelectFileList := newList
	
	IconSelectIndex := ""
	hwndStr := WinActive("ahk_id " hwnd) ? " +Owner" hwnd : ""

	IconSelectUserGui := GuiCreate("-MaximizeBox -MinimizeBox" hwndStr,"List Icons")
	IconSelectUserGui.OnEvent("close","IconSelectClose")
	
	IconSelectUserGui.AddText("","File:")
	ctl := IconSelectUserGui.AddComboBox("vIconFile x+m yp-3 w420",IconSelectFileList)
	ctl.OnEvent("change","IconSelectSelFile")
	ctl.Text := sIconFile
	
	ctl := IconSelectUserGui.AddButton("vPickFileBtn x+m yp w20","...")
	ctl.OnEvent("click","IconSelectSelFile")
	
	LV := IconSelectUserGui.AddListView("vIconList xm w480 h220 Icon","Icon")
	LV.OnEvent("doubleclick","IconSelectSelFile")
	
	ctl := IconSelectUserGui.AddButton("vOkBtn x+-150 y+5 w75","OK")
	ctl.OnEvent("click","IconSelectSelFile")
	
	ctl := IconSelectUserGui.AddButton("vCancelBtn x+0 w75","Cancel")
	ctl.OnEvent("click","IconSelectSelFile")
	
	If (WinActive("ahk_id " hwnd)) {
		p := GuiFromHwnd(hwnd)
		x := p.pos.x + (p.pos.w / 2) - (261 * (A_ScreenDPI / 96))
		y := p.pos.y + (p.pos.h / 2) - (149 * (A_ScreenDPI / 96))
		params := "x" x " y" y
		IconSelectUserGui.Show(params)
	} Else
		IconSelectUserGui.Show()
	
	IconSelectInputHook := InputHook("V") ; "V" for not blocking input
	IconSelectInputHook.KeyOpt("{Escape}","N")
	IconSelectInputHook.OnKeyDown := Func("IconSelectInputHookKeyDown")
	IconSelectInputHook.Start()
	
	If (sIconFile)
		IconSelectListIcons(IconSelectUserGui,sIconFile)
		
	IconSelectInputHook.Wait()
	
	IconSelectIndex := IconSelectInputHook.IconSelectIndex
	IconIndexArray := IconSelectInputHook.IconIndexArray
	
	sIconFile := IconSelectUserGui["IconFile"].Text
	sIconFile := StrReplace(sIconFile,"%SystemRoot%",A_WinDir)
	
	oOutput := {}
	If (IconSelectIndex) {
		oOutput := IconIndexArray[IconSelectIndex]
		oOutput.file := sIconFile
	} Else {
		oOutput.index := 0
		oOutput.type := ""
		oOutput.handle := 0
		oOutput.file := ""
	}
	
	IconIndexArray := ""
	IconSelectUserGui.Destroy()
	
	return oOutput
}

IconSelectInputHookKeyDown(iHook, VK, SC) { ; input hook ESC event
	IconSelectInputHook.IconSelectIndex := 0
	IconSelectInputHook.Stop()
}

IconSelectClose(guiObj) { ; GUI close sys button
	IconSelectInputHook.IconSelectIndex := 0
	IconSelectInputHook.Stop()
}

IconSelectSelFile(ctl,info) { ; pick file from ComboBox
	If (ctl.Name = "IconFile") {
		IconFile := StrReplace(ctl.Text,"%SystemRoot%",A_WinDir)
		IconSelectListIcons(ctl.gui,IconFile)
	} Else If (ctl.Name = "PickFileBtn") {
		IconFile := ctl.gui["IconFile"]
		IconFileStr := FileSelect("","C:\Windows\System32","Select an icon file:")
		
		If (IconFileStr)
			IconSelectListIcons(ctl.gui,IconFile)
	} Else if (ctl.Name = "IconList" Or ctl.Name = "OkBtn") {
		curCtl := ctl.gui["IconList"]
		curRow := curCtl.GetNext()
		
		IconSelectIndex := curCtl.GetText(curRow)
		IconSelectInputHook.IconSelectIndex := IconSelectIndex
		IconSelectInputHook.Stop()
	} Else If (ctl.Name = "CancelBtn") {
		IconSelectInputHook.IconSelectIndex := 0
		IconSelectInputHook.Stop()
	}
}

IconSelectListIcons(oGui,IconFile) { ; list icons after picking file
	IconFile := StrReplace(IconFile,"%SystemRoot%",A_WinDir)
	If (FileExist(IconFile)) {
		IconIndexArray := Map()
		
		If (IsObject(oGui))
			LV := oGui["IconList"]
		
		LV.Delete()
		LV.Opt("-Redraw")
		
		ImgList := IL_Create(400,5,1), tryAgain := 10
		LV.SetImageList(ImgList,0)
		
		MaxIcons := 0
		Loop {
			; Progress, %A_Index%
			handleType := ""
			hPic := LoadPicture(IconFile,"Icon" A_Index,handleType)
			prefix := !handleType ? "HBITMAP" : ((handleType = 2) ? "HCURSOR" : "HICON")
			
			IconIndexObj := {}
			IconIndexObj.type := prefix
			IconIndexObj.handle := hPic
			IconIndexObj.index := A_Index
			IconIndexArray[String(A_Index)] := IconIndexObj
			IconIndexObj := ""
			
			result := IL_Add(ImgList,prefix ":" hPic)
			dll := DllCall("DestroyIcon", "ptr", hPic)
			
			If (result)
				MaxIcons++
			Else If (tryAgain)
				tryAgain -= 1, IL_Add(ImgList,"shell32.dll",50) ; add blank icon if needed
			Else
				Break
		}
		
		Loop MaxIcons {
			; Progress, %A_Index%
			LV.Add("Icon" A_Index,A_Index)
		}
		
		IconSelectInputHook.IconIndexArray := IconIndexArray
		; Progress, Off
		
		LV.Opt("+Redraw")
	} Else
		Msgbox "Invalid file selected."
}
