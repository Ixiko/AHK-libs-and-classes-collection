; Title:   	DragBoxGuiDropFiles() : Tiny auto-pop UI to dragaccept content from File explorer/Web browser
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=80247&sid=7b34eec1d2e4134a67868308ab093fd1
; Author:	SKAN
; Date:   	23.08.2020
; for:     	AHK_L

/*  DragBoxGuiDropFiles()

      - Include the function in your script and it will auto-initialize.
      - Default handler label is DragBoxHandler (in lieu of GuiDropFiles)

      - Global A_Args array will contain the following keys when a Drop was successful
         - A_Args.DragBox.hWnd :  Handle to the window under mouse when Drag was initiated
         - A_Args.DragBox.DropType :  will be "File" if files were dropped or "Text" otherwise.
         - A_Args.DragBox.Contents :   will contain the files(s) or text

      - DragBoxGuiDropFiles() runs a SetWinEventHook to monitor the appearance of ahk_class SysDragImage
        To disable/enable hook use DragBoxGuiDropFiles("Hook", Var) where Var should contain False to UnHook or True to SetHook

      - DragBox UI uses wingdings font to display a pseudo-icon. It should be available in Windows OS unless was intentionally uninstalled.

      - Internet explorer cannot be supported.

      Example script:

      Run the following script (unelevated). DragBoxGuiDropFiles() will auto-initiallize and start monitoring.
      Click and drag Files(s), URL or text blocks and momentarily stop and wait for Drag UI to appear under mouse.
      You may now release mouse button to Drop or press Esc to cancel.
      If drop was successful a MsgBox would appear or you will hear a SoundBeep otherwise.
      To disable/enable monitoring, use hotkey Ctrl+Win+D

*/

/* Example

   #NoEnv
   #SingleInstance, Force
   SetBatchLines, -1
   Hook := 1
   Return                                                             ; end of auto-execute section

   DragBoxHandler:
     WinGet, Exe, ProcessName, % "ahk_id" . A_Args.DragBox.hWnd
     MsgBox,, DragBox, % "Exe:`t" . Exe . "`n"  . "Type`t" . A_Args.DragBox.DropType . "`n`n"
              . A_Args.DragBox.Content, 5
   Return

   ^#d::DragBoxHook(Hook:=!Hook)                       ; Use Hotkey Ctrl+Win+D to toggle monitoring

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   DragBoxNotify(P*) {
   Local
   Global A_Args
   Static Msg:=0, Label:="DragBoxHandler", Init:=DragBoxNotify()
     If (Msg=0)
     {
        If IsLabel(Label)
        {
            Msg:=DllCall("RegisterWindowMessage", "Str","DragBox")
            OnMessage(Msg, Func(A_ThisFunc))
            DllCall("ChangeWindowMessageFilterEx", "Ptr",A_ScriptHwnd, "Int",Msg, "Int",1, "Ptr",0)
        }
     }
     Else
     {
        DetectHiddenWindows, % ("On", DHW:=A_DetectHiddenWindows)
        WinGetTitle, Title, % "ahk_id" . P[1]
        DetectHiddenWindows, % DHW
        F := StrSplit(Title, Chr(27))
        A_Args.DragBox := {"DropType":F[2], "hWnd":P[2], "Content":F[3]}
        SetTimer, %Label%, -1
     }
   }

   DragBoxHook(Hook:=-1) {
   Local
     DetectHiddenWindows, % ("On", DHW:=A_DetectHiddenWindows)
     SendMessage, 0x6000, Hook,,, DragBox UI.. ahk_class AutoHotkeyGUI
     DetectHiddenWindows, %DHW%
   Return ErrorLevel
   }

*/

DragBoxGuiDropFiles(P*) {                   ; v0.65 by SKAN on D38I/D38P @ tiny.cc/dragbox
Local
Global A_Args
Static hDui, hRich, hHook:=0, Text:="", hookFn, hWnd, MOffset, WxH, Msg, DropType, Drag:=0
Static Label:="DragBoxHandler", WinEventProc:=0, V,            Init:=DragBoxGuiDropFiles()

  If ! (WinEventProc) {                                                     ; RunOnce/Init
     Gui, DragBox:New,    +AlwaysOnTop -Caption -DPIScale +Owner +Border +HwndhDui
     Gui, DragBox:Color,  00AAAA
     Gui, DragBox:Margin, 0, 0

     WxH:=56*(A_ScreenDPI/96),  WxH1:=WxH-4,  MOffset:=(WxH+2)/2
     hRich := DllCall("CreateWindowEx", "Int",0, "Str","RichEdit20W", "Ptr",0
      ,"Int",0x503011C4, "Int",0, "Int",-100, "Int",WxH+300, "Int",WxH+200, "Ptr",hDui
      ,"Int",0, "Ptr",DllCall("LoadLibrary", "Str","RichEd20.dll", "Ptr"), "Int",0, "Ptr")

     Gui, DragBox:Font,   S36 Bold cFFFFFF, Wingdings
     Gui, DragBox:Add,    Text, x2 y2 w%WxH1% h%WxH1% c111111    0x200 Center, % Chr(0x76)
     Gui, DragBox:Add,    Text, x4 y4 wp-4 hp-2 BackgroundTrans  0x200 Center, % Chr(0x76)
     Gui, DragBox:Show,   w%WxH% h%WxH% Hide, DragBox UI..

     Msg := IsLabel(Label) ? 0 : DllCall("RegisterWindowMessage", "Str","DragBox")
     OnMessage(0x6000, HookFn:=Func(A_ThisFunc).Bind("Hook"), 1) ; WM_USER+0x5C00 = 0x6000
     WinEventProc := RegisterCallBack(A_ThisFunc,,,1234321),           VarSetCapacity(V,8)
     Return ( Hook := DragBoxGuiDropFiles("Hook", True) )
  }

  If (P[1]="Hook") {                                                        ;  Hook ON/OFF
     Return ( P[2]=1 && !hHook ? !!(hHook := DllCall("SetWinEventHook", "Int",0x8002
           , "Int",0x8002, "Ptr",0, "Ptr",WinEventProc, "Int",0, "Int",0, "Int",0, "Ptr"))
    : P[2]=0 && hHook ? (0, DllCall("UnhookWinEvent", "Ptr",hHook), hHook:= 0) : !!hHook )
  }

  If ( !IsObject(P) and A_EventInfo=1234321 ) {                             ; WinEventProc
     If !WinExist("ahk_class SysDragImage")
        Return
     MouseGetPos,,, hWnd
     Hook := DragBoxGuiDropFiles("Hook", False),  OnMessage(0x6000, HookFn, 0),  Drag := 1
     DragBoxGuiDropFiles()
     Hook := DragBoxGuiDropFiles("Hook", True),   OnMessage(0x6000, HookFn, 1),  Drag := 0
     Return
  }

  If ( P.Count()=5 && (DropType:="File") ) {                                ; GuiDropFiles
     For N, File in P[2]
         Text .= File . "`n"
     Return (Text := RTrim(Text, "`n"))
  }

  If (Drag=False)
     Return
  While ( A_TimeIdle<100 )
     Sleep, 1
  DllCall("GetCursorPos","Ptr",&V), MX:=NumGet(V,"Int"),  MY:=NumGet(V,4,"Int")

  Text:="", DropType:="", A_Args.DragBox:="", NA:=(GetKeyState("LButton","P") ? "NA" : "")
  Gui, DragBox:Show, % Format("x{} y{} {}", MX-MOffset, MY-MOffset, NA), DragBox UI..
  If (NA="")
     While ! WinActive("ahk_id" . hDui)
       Sleep, 1

  While ( !GetKeyState("Esc", "P") && GetKeyState("LButton", "P") )
     Sleep, 1
  Sleep, 1                                                            ; Allow GuiDropFiles

  MouseGetPos,,, Dui
  Gui, DragBox:Hide
  If (Dui!=hDui)
     Return

  If (DropType="") {
     ControlGetText, Text,, ahk_id %hRich%
     If StrLen(Text) && (DropType:="Text")
        DllCall("SetWindowText", "Ptr",hRich, "Ptr",0)
  }

  If (DropType) {
     If (Msg)   {
         Gui, DragBox:Show, Hide
            , % Format("DragBox UI..{3:}{1:}{3:}{2:}", DropType, Text, Chr(27))
         PostMessage, %Msg%, %hDui%,%hWnd%,, ahk_id 0xFFFF       ; HWND_BROADCAST = 0xFFFF
     }   Else   {
         A_Args.DragBox := {"DropType":DropType, "hWnd":hWnd, "Content":Text}
         SetTimer, % Label:="DragBoxHandler", -1
     }
  }
  Else SoundBeep

Return VarSetCapacity(Text,0)
}