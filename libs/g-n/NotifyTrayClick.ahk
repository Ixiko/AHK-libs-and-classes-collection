; Title:   	NotifyTrayClick() : Notifies when AHK tray icon is clicked
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=81157
; Author:	SKAN
; Date:   	18.09.2020
; for:     	AHK_L

/*  Introduction:

   Back in classic days, @lexikos discovered and described a simple way to hook mouse events on the script's tray icon. Since then I have
   used this AHK_NOTIFYICON method in some of my scripts, but every time I had to figure it out on how to customize it for specific needs.
   AHK_NOTIFYICON mesage handler will receive 9 click notifications, 3 each for Left, Middle and Right mouse buttons and how nice it would be
   if we had labels, one for each? Something like individual GuiContextMenu label where we handle right-click event for every GUI.
   Most surely it will not happen!.
   I give you the second best solution. NotifyTrayClick() : A function based implementation which provides individual labels for all 9 click events.

   How to use it:
   1) Copy/paste my function in to your script.
   2) Handle events by using any/some/all of the following labels. (You may use functions instead of labels... or a mix of both)
   Code: Select all - Toggle Line numbers

   NotifyTrayClick_201:   ; Left click (Button down)
   NotifyTrayClick_202:   ; Left click (Button up)
   NotifyTrayClick_203:   ; Left double click
   NotifyTrayClick_204:   ; Right click (Button down)
   NotifyTrayClick_205:   ; Right click (Button up)
   NotifyTrayClick_206:   ; Right double click
   NotifyTrayClick_207:   ; Middle click (Button down)
   NotifyTrayClick_208:   ; Middle click (Button up)
   NotifyTrayClick_209:   ; Middle double click
   Notes:
   NotifyTrayClick_201 label (Left click down) is not of much use. You will receive the event only when you release the mouse left button.
   I suggest using only Button up/Double click event for one mouse button.
   If you attempt to all handle three events i.e., Button down/Button up/Double click for a button, then Double click event will be followed
   by a Button down event. It is easy to work-around though. A demo is available in examples.
   The mere existence of a label will suppress its original functionality. If you have NotifyTrayClick_205: (Right click up) in your script,
   then right click menu wouldn't work and script can't be exited. Bind ExitApp to a hotkey when your script is in testing stage.
   The cursor has to be over tray icon to receive a "button up" event. For eg. If you click on the tray icon - move the cursor away from the icon - release
   the button, then script will never receive the event.

   NotifyTrayClick(DoubleClickTime)

   By default, the function will auto-initialize with DoubleClickTime of 250 ms. This time duration is used by the function to differentiate single
   from double clicks. To override it with a custom value, say 300 ms, call the function from auto-execute section, like: NotifyTrayClick(300).
   Or, if you want to apply the system default value, pass API function GetDoubleClickTime() as parameter.
   :arrow:  NotifyTrayClick( DllCall("GetDoubleClickTime") )
   Note: DoubleClickTime will be applied to single click of a button, only if its counter-part double click handler is present in script.

*/

/* Examples

#SingleInstance, Force
Return                 ; end of auto-execute section

NotifyTrayClick_202:   ; Left click (Button up)
  Menu, Tray, Show
Return

NotifyTrayClick_205:   ; Right click (Button up)
Return                 ; Supress right click menu

; Copy paste NotifyTrayClick() below

#NoEnv
#SingleInstance, Force
SetBatchLines, -1

Gui, Dsk:New, +ToolWindow +AlwaysOnTop +HwndhGui, Disk stats
Gui, Font,     S12, Consolas
Gui, Add,      Edit, ReadOnly -0x200000 hWndhEdit, % DiskSts()
Gui, Add,      Edit, w0 h0       ; dummy edit
GuiControl, Focus, Edit2         ; so that Edit1 doesn't do Ctrl+A
Gui, Show, Hide
DblClk:=0
Return                                                                 ; end of auto-execute section

*/

/* Complex example
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


NotifyTrayClick_202:   ; Left click (Button up)
  Menu, Tray, Show
Return

NotifyTrayClick_206:   ; Right double click
  GuiControl,,%hEdit%, % DiskSts()
  Gui, Dsk:Show,, Disk stats
  DblClk := 1
Return

NotifyTrayClick_204:   ; Right click (Button down)
  If ( DblClk && !(DblClk:=0) )                         ; testing and resetting DblClk in same line
    Return
  If DllCall("IsWindowVisible", "Ptr",hGui)
    Return
  GuiControl,,%hEdit%, % DiskSts()
  Gui, Dsk:Show,, Disk stats (quick peek)
Return

NotifyTrayClick_205:   ; Right click (Button up)
  Gui, Dsk:Hide
Return

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DiskSts() {
Local  DskSts := "", FBA := 0, TNB := 0
  DriveGet, List, List
  Loop, Parse, List
    If DllCall( "GetDiskFreeSpaceEx", "Str",A_LoopField ":\", "Int64P",FBA, "Int64P",TNB, "Ptr",0 )
       DskSts .= Format( A_LoopField . ":\`t{}`t[{}]`n", FormatBytes(FBA), FormatBytes(TNB))
Return DskSts
}

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FormatBytes(N) { ; By SKAN on CT5H/D351 @ tiny.cc/formatbytes
Return DllCall("Shlwapi\StrFormatByteSize64A", "Int64",N, "Str",Format("{:16}",N), "Int",16, "AStr")
}

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; copy/paste NotifyTrayClick() below

*/

/* Click History Script

#NoEnv
#SingleInstance, Force
Menu, Tray, Tip, Menu not available`n Use Close button to Exit this APP

WM := {0x201:"WM_LBUTTONDOWN", 0x202:"WM_LBUTTONUP", 0x203:"WM_LBUTTONDBLCLK"
     , 0x204:"WM_RBUTTONDOWN", 0x205:"WM_RBUTTONUP", 0x206:"WM_RBUTTONDBLCLK"
     , 0x207:"WM_MBUTTONDOWN", 0x208:"WM_MBUTTONUP", 0x209:"WM_MBUTTONDBLCLK"}

Gui, NTC_:New, +ToolWindow +AlwaysOnTop, NotifyTrayClick() - History
Gui, Font,     S10, Consolas
Gui, Add,      Edit, R13 ReadOnly hWndhEdit, % Format("{:-27}", "")
GuiControl,,%hEdit%
Gui, Show, NA
NotifyTrayClick(300)
Return                                                            ; end of auto-execute section

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

`::GuiControl,,%hEdit%
NTC_GuiClose:
ExitApp

NotifyTrayClick_201:   ; Left click (Button down)
NotifyTrayClick_202:   ; Left click (Button up)
NotifyTrayClick_203:   ; Left double click
NotifyTrayClick_204:   ; Right click (Button down)
NotifyTrayClick_205:   ; Right click (Button up)
NotifyTrayClick_206:   ; Right double click
NotifyTrayClick_207:   ; Middle click (Button down)
NotifyTrayClick_208:   ; Middle click (Button up)
NotifyTrayClick_209:   ; Middle double click
  NM := StrReplace(A_ThisLabel, "NotifyTrayClick_", "0x")
  Edit_Append(hEdit, NM . A_Tab . WM[NM] . "`r`n")
Return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Edit_Append(hEdit, Txt) { ; Modified version by SKAN
Local        ; Original by TheGood on 09-Apr-2010 @ autohotkey.com/board/topic/52441-/?p=328342
  L := DllCall("SendMessage", "Ptr",hEdit, "UInt",0x0E, "Ptr",0 , "Ptr",0)   ; WM_GETTEXTLENGTH
       DllCall("SendMessage", "Ptr",hEdit, "UInt",0xB1, "Ptr",L , "Ptr",L)   ; EM_SETSEL
       DllCall("SendMessage", "Ptr",hEdit, "UInt",0xC2, "Ptr",0 , "Str",Txt) ; EM_REPLACESEL
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

NotifyTrayClick(P*) {              ;  v0.41 by SKAN on D39E/D39N @ tiny.cc/notifytrayclick
Static Msg, Fun:="NotifyTrayClick", NM:=OnMessage(0x404,Func(Fun),-1),  Chk,T:=-250,Clk:=1
  If ( (NM := Format(Fun . "_{:03X}", Msg := P[2])) && P.Count()<4 )
     Return ( T := Max(-5000, 0-(P[1] ? Abs(P[1]) : 250)) )
  Critical
  If ( ( Msg<0x201 || Msg>0x209 ) || ( IsFunc(NM) || Islabel(NM) )=0 )
     Return
  Chk := (Fun . "_" . (Msg<=0x203 ? "203" : Msg<=0x206 ? "206" : Msg<=0x209 ? "209" : ""))
  SetTimer, %NM%,  %  (Msg==0x203        || Msg==0x206        || Msg==0x209)
    ? (-1, Clk:=2) : ( Clk=2 ? ("Off", Clk:=1) : ( IsFunc(Chk) || IsLabel(Chk) ? T : -1) )
Return True
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*/

NotifyTrayClick(P*) {              ;  v0.41 by SKAN on D39E/D39N @ tiny.cc/notifytrayclick
Static Msg, Fun:="NotifyTrayClick", NM:=OnMessage(0x404,Func(Fun),-1),  Chk,T:=-250,Clk:=1
  If ( (NM := Format(Fun . "_{:03X}", Msg := P[2])) && P.Count()<4 )
     Return ( T := Max(-5000, 0-(P[1] ? Abs(P[1]) : 250)) )
  Critical
  If ( ( Msg<0x201 || Msg>0x209 ) || ( IsFunc(NM) || Islabel(NM) )=0 )
     Return
  Chk := (Fun . "_" . (Msg<=0x203 ? "203" : Msg<=0x206 ? "206" : Msg<=0x209 ? "209" : ""))
  SetTimer, %NM%,  %  (Msg==0x203        || Msg==0x206        || Msg==0x209)
    ? (-1, Clk:=2) : ( Clk=2 ? ("Off", Clk:=1) : ( IsFunc(Chk) || IsLabel(Chk) ? T : -1) )
Return True
}