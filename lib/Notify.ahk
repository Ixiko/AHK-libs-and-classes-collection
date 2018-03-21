;;;;;;;
;;;;;  Notify() 0.45                made by gwarble - sept 09
;;;      multiple tray area notifications
;          thanks to Rhys/engunneer/HugoV/Forum Posters
;
;   Notify([Title,Message,Duration,Options,Image])
;
;     Title      [!!!]          "" to omit title line
;     Message      []           "" to omit message line
;     Duration    [15]          seconds to show notification
;                                 0  to flash until clicked
;                                <0  to ExitApp on click/timeout
;                               "-0" for permanent and exitOnClick
;     Options                   string of options... see function
;          [SI=999 GC=Blue...]  most options are remembered (static)
;                               "Reset" to restore default options
;                                 if you want to show as well, use NO=Reset
;                               "Wait" to wait for a notification  ***
;     Image []                  Image file name/library or
;                               number of icon in shell32.dll
;                               Gui Number to "Wait" for          ***
;
;     Return                    Gui Number used                   ***
;                               0 if failed (too many open)
;
Notify(Title="!!!",Message="",Duration=30,Options="",Image="")
{
 Static                ;Options string: "TS=12 GC=Blue..."
 static GF := 50       ;    Gui First Number  ;= override Gui: # used
 static GL := 74       ;    Gui Last Number   ;= between GF and GL
 static GC := "FFFFAA" ;    Gui Color         ;   ie: don't use GF<=Gui#<=GL
 static GR := 9        ;    Gui Radius        ;       elsewhere in your script
 static GT := "Off"    ;    Gui Transparency
 static TS := 8        ;  Title Font Size
 static TW := 625      ;  Title Font Weight
 static TC := "Black"  ;  Title Font Color
 static TF := "Arial"  ;  Title Font Face
 static MS := 8        ;Message Font Size
 static MW := 550      ;Message Font Weight
 static MC := "Black"  ;Message Font Color
 static MF := "Arial"  ;Message Font Face
 static BC := "000000"  ; Border Colors
 static BW := 2        ; Border Width/Thickness
 static BR := 13       ; Border Radius
 static BT := 105      ; Border Transpacency
 static BF := 150      ; Border Flash Speed
 static SI := 350      ;  Speed In (AnimateWindow)
 static SC := 100      ;  Speed Clicked (AnimateWindow)
 static ST := 450      ;  Speed TimeOut (AnimateWindow)
 static IW := 32       ;  Image Width
 static IH := 32       ;  Image Height
 static IN := 0        ;  Image Icon Number (from Image)
 static AX := 0        ; Action X Close Button (maybe add yes/no ok/cancel, etc...)
 local AC, AT          ;Actions Clicked/Timeout
 local _Notify_Action, ImageOptions, GY, OtherY

_Notify_:
 local NO := 0         ;NO is Notify Option [NO=Reset]
 If (Options)
 {
  IfInString, Options, =
  {
   Loop,Parse,Options,%A_Space%
    If (Option:= SubStr(A_LoopField,1,2))
     %Option%:= SubStr(A_LoopField,4)
   If NO = Reset
   {
    Options := "GF=50 GL=74 GC=FFFFAA GR=9 GT=Off "
     . "TS=8 TW=625 TC=Black TF=Arial MS=8 MW=550 MC=Black MF=Arial "
     . "BC=Black BW=2 BR=9 BT=105 BF=150 SC=300 SI=250 ST=100 "
     . "IW=32 IH=32 IN=0"
    Goto, _Notify_
   }
  }
  Else If Options = Wait
   Goto, _Notify_Wait_
 }


 GN := GF
 Loop
  IfNotInString, NotifyList, % "|" GN
   Break
  Else
  If (++GN > GL)
    Return 0              ;=== too many notifications open!
 NotifyList .= "|" GN
 GN2 := GN + GL - GF + 1
 If AC <>
  ActionList .= "|" GN "=" AC

 Prev_DetectHiddenWindows := A_DetectHiddenWindows
 Prev_TitleMatchMode := A_TitleMatchMode
 DetectHiddenWindows On
 SetTitleMatchMode 1
 If (WinExist("NotifyGui"))  ;=== find all Notifications from ALL scripts, for placement
  WinGetPos, OtherX, OtherY  ;=== change this to a loop for all open notifications?
 DetectHiddenWindows %Prev_DetectHiddenWindows%
 SetTitleMatchMode %Prev_TitleMatchMode%

 Gui, %GN%:-Caption +ToolWindow +AlwaysOnTop -Border
 Gui, %GN%:Color, %GC%
 Gui, %GN%:Font, w%TW% s%TS% c%TC%, %TF%
 If (Image)
 {
  If FileExist(Image)
   Gui, %GN%:Add, Picture, w%IW% h%IH% Icon%IN%, % Image
  Else
   Gui, %GN%:Add, Picture, w%IW% h%IH% Icon%Image%, c:\windows\system32\shell32.dll
  ImageOptions = x+10
 }
 If Title <>
  Gui, %GN%:Add, Text, % ImageOptions, % Title
 Gui, %GN%:Font, w%MW% s%MS% c%MC%, %MF%
 If ((Title) && (Message))
  Gui, %GN%:Margin, , -5
 If Message <>
  Gui, %GN%:Add, Text,, % Message
 If ((Title) && (Message))
  Gui, %GN%:Margin, , 8
 Gui, %GN%:Show, Hide, NotifyGui
 Gui  %GN%:+LastFound
 WinGetPos, GX, GY, GW, GH

 If AX =
 {
  GW += 10
  Gui, %GN%:Font, w800 s6 c%MC%
  Gui, %GN%:Add, Text, % "x" GW-11 " y-1 Border Center w12 h12 g_Notify_Kill_" GN - GF + 1, X
 }

 Gui, %GN%:Add, Text, x0 y0 w%GW% h%GH% g_Notify_Action BackgroundTrans
 If (GR)
  WinSet, Region, % "0-0 w" GW " h" GH " R" GR "-" GR
 If (GT)
  WinSet, Transparent, % GT

 SysGet, Workspace, MonitorWorkArea
 NewX := WorkSpaceRight-GW-5
 If (OtherY)
  NewY := OtherY-GH-5
 Else
  NewY := WorkspaceBottom-GH-5
 If NewY < % WorkspaceTop
  NewY := WorkspaceBottom-GH-5

 Gui, %GN2%:-Caption +ToolWindow +AlwaysOnTop -Border +E0x20
 Gui, %GN2%:Color, %BC%
 Gui  %GN2%:+LastFound
 If (BR)
  WinSet, Region, % "0-0 w" GW+(BW*2) " h" GH+(BW*2) " R" BR "-" BR
 If (BT)
  WinSet, Transparent, % BT

 Gui, %GN2%:Show, % "Hide x" NewX-BW " y" NewY-BW " w" GW+(BW*2) " h" GH+(BW*2)
 Gui, %GN%:Show,  % "Hide x" NewX " y" NewY " w" GW, NotifyGui
 Gui  %GN%:+LastFound
 If SI
  DllCall("AnimateWindow","UInt",WinExist(),"Int",SI,"UInt","0x00040008")
 Else
  Gui, %GN%:Show, NA, NotifyGui
 Gui, %GN2%:Show, NA
 WinSet, AlwaysOnTop, On

 If ((Duration < 0) OR (Duration = "-0"))
  Exit := GN
 If (Duration)
   SetTimer, % "_Notify_Kill_" GN - GF + 1, % - Abs(Duration) * 1000
 Else
  SetTimer, % "_Notify_Flash_" GN - GF + 1, % BF

Return % GN

;==========================================================================
;========================================== when a notification is clicked:
_Notify_Action:
 ;Critical
 SetTimer, % "_Notify_Kill_" A_Gui - GF + 1, Off
 Gui, % A_Gui + GL - GF + 1 ":Destroy"
 Gui  %A_Gui%:+LastFound
 If SC
  DllCall("AnimateWindow","UInt",WinExist(),"Int",SC,"UInt", "0x00050001")
 Gui, %A_Gui%:Destroy
 If (ActionList)
  Loop,Parse,ActionList,|
   If ((Action := SubStr(A_LoopField,1,2)) = A_Gui)
   {
    Temp_Notify_Action:= SubStr(A_LoopField,4)
    StringReplace, ActionList, ActionList, % "|" A_Gui "=" Temp_Notify_Action, , All
    If IsLabel(_Notify_Action := Temp_Notify_Action)
     Gosub, %_Notify_Action%
    _Notify_Action =
    Break
   }
 StringReplace, NotifyList, NotifyList, % "|" GN, , All
 SetTimer, % "_Notify_Flash_" A_Gui - GF + 1, Off
 If (Exit = A_Gui)
  ExitApp
Return

;==========================================================================
;=========================================== when a notification times out:
_Notify_Kill_1:
_Notify_Kill_2:
_Notify_Kill_3:
_Notify_Kill_4:
_Notify_Kill_5:
_Notify_Kill_6:
_Notify_Kill_7:
_Notify_Kill_8:
_Notify_Kill_9:
_Notify_Kill_10:
_Notify_Kill_11:
_Notify_Kill_12:
_Notify_Kill_13:
_Notify_Kill_14:
_Notify_Kill_15:
_Notify_Kill_16:
_Notify_Kill_17:
_Notify_Kill_18:
_Notify_Kill_19:
_Notify_Kill_20:
_Notify_Kill_21:
_Notify_Kill_22:
_Notify_Kill_23:
_Notify_Kill_24:
_Notify_Kill_25:
 ;Critical
 StringReplace, GK, A_ThisLabel, _Notify_Kill_
 SetTimer, _Notify_Flash_%GK%, Off
 GK += GF - 1
 Gui, % GK + GL - GF + 1 ":Destroy"
 Gui  %GK%:+LastFound
 If ST
  DllCall("AnimateWindow","UInt",WinExist(),"Int",ST,"UInt", "0x00050001")
 Gui, %GK%:Destroy
 StringReplace, NotifyList, NotifyList, % "|" GK
 If (Exit = GK)
  ExitApp
Return

;==========================================================================
;======================================== flashes a permanent notification:
_Notify_Flash_1:
_Notify_Flash_2:
_Notify_Flash_3:
_Notify_Flash_4:
_Notify_Flash_5:
_Notify_Flash_6:
_Notify_Flash_7:
_Notify_Flash_8:
_Notify_Flash_9:
_Notify_Flash_10:
_Notify_Flash_11:
_Notify_Flash_12:
_Notify_Flash_13:
_Notify_Flash_14:
_Notify_Flash_15:
_Notify_Flash_16:
_Notify_Flash_17:
_Notify_Flash_18:
_Notify_Flash_19:
_Notify_Flash_20:
_Notify_Flash_21:
_Notify_Flash_22:
_Notify_Flash_23:
_Notify_Flash_24:
_Notify_Flash_25:
 StringReplace, FlashGN, A_ThisLabel, _Notify_Flash_
 FlashGN += GF - 1
 FlashGN2 := FlashGN + GL - GF + 1
 If Flashed%FlashGN2% := !Flashed%FlashGN2%
  Gui, %FlashGN2%:Color, Silver
 Else
  Gui, %FlashGN2%:Color, % BC
Return

;==========================================================================
;============================= wait for (or force) a notification to close:
_Notify_Wait_:
 ;Critical
 If (Image)
 {
  Gui %Image%:+LastFound
  If NotifyGuiID := WinExist()
  {
   WinWaitClose, , , % Abs(Duration)
   If (ErrorLevel && Duration < 1)
   {
    Gui, % Image + GL - GF + 1 ":Destroy"
    DllCall("AnimateWindow","UInt",NotifyGuiID,"Int",ST,"UInt","0x00050001")
    Gui, %Image%:Destroy
   }
  }
 }
 Else
 Loop, % GL-GF
 {
  Image := GL - (A_Index) ;+ GF - 1)
  Gui %Image%:+LastFound
  If NotifyGuiID := WinExist()
  {
   ;WinWaitClose, , , % Abs(Duration)
   ;If (ErrorLevel && Duration < 1)
   ;{
    Gui, % Image + GL - GF + 1 ":Destroy"
    DllCall("AnimateWindow","UInt",NotifyGuiID,"Int",ST,"UInt","0x00050001")
    Gui, %Image%:Destroy
   ;}
  }
 }
Return
}