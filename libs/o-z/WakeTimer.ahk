Gui, Margin, 15, 15
Gui, Font, s12 q5, Calibri
Gui, Add, Text, y10, Set wake up time:
Gui, Font, s12 q5
Gui, Add, DateTime, vDT y+5 w180, HH:mm`, dd MMMM
GuiControlGet, Pos, Pos, DT
Gui, Add, Checkbox, gPutToSleep vPutToSleep, Put the PC to sleep now
Gui, Add, Radio, y+5 Checked Disabled, Sleep
Gui, Add, Radio, x+5 yp Disabled vSleepMode, Hibernation
Gui, Add, Button, % "x" 16 + (PosW - 100)/2 " h25 w100", OK
Gui, Show,, Alarm Clock
Return

#If WinActive( "Alarm Clock ahk_pid " DllCall("GetCurrentProcessId") )
WheelDown::
WheelUp::
   Send, % "{" . SubStr(A_ThisHotkey, 6) . "}"
   Return
#If

PutToSleep() {
   static toggle
   command := (toggle := !toggle) ? "Enable" : "Disable"
   GuiControl, % command, Button2
   GuiControl, % command, Button3
}

ButtonOK() {
   Gui, +OwnDialogs
   GuiControlGet, DT
   DT -= time, s
   if (DT < 0) {
      MsgBox, 48, % " ", The time you set has already passed!
      Return
   }
   if (DT < 60) {
      MsgBox, 48, % " ", Choose a longer time span!
      Return
   }
   hTimer := DllCall("CreateWaitableTimer", Ptr, 0, UInt, 0, Str, "MyTimer", Ptr)
   DllCall("SetWaitableTimer", Ptr, hTimer, Int64P, -DT*10000000, UInt, 0, Ptr, 0, Ptr, 0, UInt, 1)
   if ( A_LastError = (ERROR_NOT_SUPPORTED := 50) ) {
      DllCall("CloseHandle", Ptr, hTimer)
      MsgBox, This computer does not support wake on timer!
      ExitApp
   }
   OnMessage( msg := 0xFFF, Func("WM_WAKEUP").Bind(hTimer) )
   pAddr := GetProcAddr(hTimer, A_ScriptHwnd, msg)
   DllCall("CreateThread", Ptr, 0, Ptr, 0, Ptr, pAddr, Ptr, 0, UInt, 0, Ptr, 0)
   GuiControlGet, PutToSleep
   GuiControlGet, SleepMode
   Gui, Destroy
   if PutToSleep
      DllCall("PowrProf\SetSuspendState", UInt, SleepMode, UInt, 0, UInt, 0)
}

WM_WAKEUP(hTimer) {
   DllCall("CloseHandle", Ptr, hTimer)
   MsgBox, Hi!
   ExitApp
}

GuiClose() {
   ExitApp
}

GetProcAddr(Handle, hWnd, Msg, Timeout := -1)
{  ; http://forum.script-coding.com/viewtopic.php?pid=56073#p56073
   static MEM_COMMIT := 0x1000, PAGE_EXECUTE_READWRITE := 0x40
   ptr := DllCall("VirtualAlloc", Ptr, 0, Ptr, A_PtrSize = 4 ? 49 : 85, UInt, MEM_COMMIT, UInt, PAGE_EXECUTE_READWRITE, Ptr)
   hModule := DllCall("GetModuleHandle", Str, "kernel32.dll", Ptr)
   pWaitForSingleObject := DllCall("GetProcAddress", Ptr, hModule, AStr, "WaitForSingleObject", Ptr)
   hModule := DllCall("GetModuleHandle", Str, "user32.dll", Ptr)
   pSendMessageW := DllCall("GetProcAddress", Ptr, hModule, AStr, "SendMessageW", Ptr)
   NumPut(pWaitForSingleObject, ptr*1)
   NumPut(pSendMessageW, ptr + A_PtrSize)
   if (A_PtrSize = 4)  {
      NumPut(0x68, ptr + 8, "UChar")
      NumPut(Timeout, ptr + 9, "UInt"), NumPut(0x68, ptr + 13, "UChar")
      NumPut(Handle, ptr + 14), NumPut(0x15FF, ptr + 18, "UShort")
      NumPut(ptr, ptr + 20), NumPut(0x6850, ptr + 24, "UShort")
      NumPut(Handle, ptr + 26), NumPut(0x68, ptr + 30, "UChar")
      NumPut(Msg, ptr + 31, "UInt"), NumPut(0x68, ptr + 35, "UChar")
      NumPut(hWnd, ptr + 36), NumPut(0x15FF, ptr + 40, "UShort")
      NumPut(ptr+4, ptr + 42), NumPut(0xC2, ptr + 46, "UChar"), NumPut(4, ptr + 47, "UShort")
   }
   else  {
      NumPut(0x53, ptr + 16, "UChar")
      NumPut(0x20EC8348, ptr + 17, "UInt"), NumPut(0xBACB8948, ptr + 21, "UInt")
      NumPut(Timeout, ptr + 25, "UInt"), NumPut(0xB948, ptr + 29, "UShort")
      NumPut(Handle, ptr + 31), NumPut(0x15FF, ptr + 39, "UShort")
      NumPut(-45, ptr + 41, "UInt"), NumPut(0xB849, ptr + 45, "UShort")
      NumPut(Handle, ptr + 47), NumPut(0xBA, ptr + 55, "UChar")
      NumPut(Msg, ptr + 56, "UInt"), NumPut(0xB948, ptr + 60, "UShort")
      NumPut(hWnd, ptr + 62), NumPut(0xC18941, ptr + 70, "UInt")
      NumPut(0x15FF, ptr + 73, "UShort"), NumPut(-71, ptr + 75, "UInt")
      NumPut(0x20C48348, ptr + 79, "UInt"), NumPut(0xC35B, ptr + 83, "UShort")
   }
   Return ptr + A_PtrSize*2
}