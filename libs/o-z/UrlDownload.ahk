;================================================================================;
;	UrlDownload - An AutoHotkey library for downloading files                    ;
;	Copyright (C) 2016  Brian Baker https://github.com/Fooly-Cooly               ;
;	Licensed with GPL v3 https://www.gnu.org/licenses/gpl-3.0.txt                ;
;	Works with AHK ANSI, Unicode & 64-bit                                        ;
;	Base http://www.autohotkey.com/board/topic/17915-urldownloadtofile-progress  ;
;================================================================================;

urlDownload_Call(ptrThis, intProgCur = 0, intProgMax = 0, intStatCode = 0, ptrStatText = 0)
{
	static  guiDownload, guiDownloadProg, guiDownloadText, dtmCompl := A_TickCount

	If !guiDownload
	{
		Gui, +HwndguiDownload +Border +ToolWindow -MaximizeBox -MinimizeBox -SysMenu 
		Gui, Color, White
		Gui, Add, Button, Default, OK
		Gui, Add, Progress, % "vguiDownloadProg Xp+37 Yp W" . A_ScreenWidth//4
		Gui, Add, Text, vguiDownloadText Xp Yp+20 Wp
		Gui, Show
		return
			
		ButtonOK:
			VarSetCapacity(guiDownloadProg, 0)
			VarSetCapacity(guiDownloadText, 0)
			Gui Destroy
			Exit
		return
	}
	
	If A_EventInfo = 6
	{
		GuiControl,, guiDownloadProg, % intProg := 100 * intProgCur//intProgMax
		GuiControl,, guiDownloadText, % intProgCur "/" intProgMax .= intProg == 100 ? " Downloaded in " ((A_TickCount - dtmCompl) / 1000) " seconds" : ""
	}
}

urlDownload_File(strUrl, strDest = ".", blnOver = True)
{
	If !strUrl
		return

	SplitPath, strUrl, strFile
	strDest .= "\" strFile

	If FileExist(strDest) AND blnOver
	   FileDelete %strDest%

	VarSetCapacity(ptrCallback, A_PtrSize*11)

	Loop, Parse, % "31132253353"
		NumPut(RegisterCallback("urlDownload_Call", "Fast", A_LoopField, A_Index-1), ptrCallback, A_PtrSize*(A_Index-1))
	DllCall("urlmon\URLDownloadToFile", "UInt", 0, "str", strUrl, "str", strDest, "UInt", 0, "UIntP", &ptrCallback)

	Loop 11
		DllCall("GlobalFree", "Ptr", NumGet(ptrCallback,  A_PtrSize*(A_Index-1)), "Ptr")
}