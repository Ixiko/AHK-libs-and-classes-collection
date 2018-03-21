sApplication := "firefox"  ; iexplore, opera
sTopic := "WWW_GetWindowInfo"
sItem  := "0xFFFFFFFF"

CF_TEXT      := 1
WM_DDE_INITIATE   := 0x3E0
WM_DDE_TERMINATE:= 0x3E1
WM_DDE_ADVISE   := 0x3E2
WM_DDE_UNADVISE   := 0x3E3
WM_DDE_ACK   := 0x3E4
WM_DDE_DATA   := 0x3E5
WM_DDE_REQUEST   := 0x3E6
WM_DDE_POKE   := 0x3E7
WM_DDE_EXECUTE   := 0x3E8

DetectHiddenWindows, On

OnMessage(WM_DDE_ACK , "DDE_ACK")
OnMessage(WM_DDE_DATA, "DDE_DATA")

nAppli := DllCall("GlobalAddAtom", "str", sApplication, "Ushort")
nTopic := DllCall("GlobalAddAtom", "str", sTopic, "Ushort")

Process, Exist
WinGet, hAHK, ID, ahk_pid %ErrorLevel%

SendMessage, WM_DDE_INITIATE, hAHK, nAppli | nTopic << 16,, ahk_id 0xFFFF

DllCall("GlobalDeleteAtom", "Ushort", nAppli)
DllCall("GlobalDeleteAtom", "Ushort", nTopic)


DDE_ACK(wParam, lParam, MsgID, hWnd)
{
   Global sItem, CF_TEXT, WM_DDE_REQUEST
   nItem := DllCall("GlobalAddAtom", "str", sItem, "Ushort")
   PostMessage, WM_DDE_REQUEST, hWnd, CF_TEXT | nItem << 16,, ahk_id %wParam%
   If ErrorLevel
   DllCall("GlobalDeleteAtom", "Ushort", nItem)
}

DDE_DATA(wParam, lParam, MsgID)
{
   Global WM_DDE_ACK
   DllCall("UnpackDDElParam", "Uint", MsgID, "Uint", lParam, "UintP", hData, "UintP", nItem)
   DllCall(  "FreeDDElParam", "Uint", MsgID, "Uint", lParam)

   pData := DllCall("GlobalLock", "Uint", hData)
   VarSetCapacity(sInfo, DllCall("lstrlen", "Uint", pData+4))
   DllCall("lstrcpy", "str", sInfo, "Uint", pData+4)
   DllCall("GlobalUnlock", "Uint", hData)
   If (*(pData+1) & 0x20)
      DllCall("GlobalFree", "Uint", hData)
   If (*(pData+1) & 0x80)
      PostMessage, WM_DDE_ACK, hWnd, 0x80 << 8 | nItem << 16,, ahk_id %wParam%

   ;MsgBox % sInfo      ; "URL", "Title"
   return sInfo
   ExitApp
}

DDE_POKE(sItem, sData)
{
   Global  WM_DDE_POKE, hWndClient, hWndServer
   If SubStr(sData, -1) <> "`r`n"
      sData .= "`r`n"

   hItem := DllCall("GlobalAddAtom", "str", sItem, "Ushort")
   hData := DllCall("GlobalAlloc", "Uint", 0x0002, "Uint", 2+2+StrLen(sData)+1)   ; GMEM_MOVEABLE
   pData := DllCall("GlobalLock" , "Uint", hData)
   DllCall("ntdll\RtlFillMemoryUlong", "Uint", pData, "Uint", 4, "Uint", 1<<13|1<<14|1<<16) ; bRelease, CF_TEXT
   DllCall("lstrcpy", "Uint", pData+4, "Uint",&sData)
   DllCall("GlobalUnlock", "Uint", hData)

   lParam := DllCall("PackDDElParam", "Uint", WM_DDE_POKE, "Uint", hData, "Uint", hItem)
   PostMessage, WM_DDE_POKE, hWndClient, lParam,, ahk_id %hWndServer%
   If ErrorLevel
   {
      DllCall("GlobalFree", "Uint"  , hData)
      DllCall("GlobalDeleteAtom", "Ushort", hItem)
      DllCall("FreeDDElParam", "Uint", WM_DDE_POKE, "Uint", lParam)
   }
}

DDE_EXECUTE(sCmd)
{
   Global  WM_DDE_EXECUTE, hWndClient, hWndServer

   hCmd := DllCall("GlobalAlloc", "Uint", 0x0002, "Uint", StrLen(sCmd)+1)
   pCmd := DllCall("GlobalLock" , "Uint", hCmd)
   DllCall("lstrcpy", "Uint", pCmd, "str",sCmd)
   DllCall("GlobalUnlock", "Uint", hCmd)

   PostMessage, WM_DDE_EXECUTE, hWndClient, hCmd,, ahk_id %hWndServer%
   If ErrorLevel
   DllCall("GlobalFree", "Uint", hCmd)
}
