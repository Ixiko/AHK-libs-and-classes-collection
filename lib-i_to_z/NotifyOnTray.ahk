;——————————————————————————————————————————————————————
;————————      Notify() 0.4993 by gwarble      ————————
;—————                                            —————
;———      easy multiple tray area notifications     ———
;——        http://www.gwarble.com/ahk/Notify/        ——
;——————————————————————————————————————————————————————
;
; Notify( [ Title, Message, Duration, Options ] )
;
; Duration  seconds to show notification [Default: 30], ie:
;             0  for permanent/remain until clicked (flashing)
;            -3  negative value to ExitApp on click/timeout
;           "-0" for permanent and ExitApp when clicked (needs "")
;
; Options   string of options, single-space seperated, ie:
;           "TS=16 TM=8 TF=Times New Roman GC_=Blue SI_=1000"
;           most options are remembered (static), some not (local)
;           Option_= can be used for non-static call, ie:
;           "GC=Blue" makes all future blue, "GC_=Blue" only takes effect once
;           "Wait=ID"   to wait for a notification
;           "Update=ID" to change Title, Message, and Progress Bar (with 'Duration')
;
; Return   ID (Gui Number used)
;          0 if failed (too many open most likely)
;          VarValue if Options includes: Return=VarName
;——————————————————————————————————————————————————————

Notify(Title="Notify()",Message="",Duration="",Options="")
{
 static GNList, ACList, ATList, AXList, Exit, _Wallpaper_, _Title_, _Message_, _Progress_, _Image_, Saved
 static GF := 50 					; Gui First Number
 static GL := 74 					; Gui Last  Number (which defines range and allowed count)
 static GC,GR,GT,BC,BK,BW,BR,BT,BF			; static options, remembered between calls
 static TS,TW,TC,TF,MS,MW,MC,MF
 static SI,SC,ST,IW,IH,IN,XC,XS,XW,PC,PB

 If (Options)						; skip parsing steps if Options param isn't used
 {
  If (A_AutoTrim = "Off")
  {
   AutoTrim, On
   _AutoTrim = 1
  } ; ¶
  Options = %Options%
  Options.=" "						; poor whitespace handling for next parsing step (ensures last option is parsed)
  Loop,Parse,Options,= 					; parse options string at "="s, needs better whitespace handling
  {
      If A_Index = 1					; first option handling
        Option := A_LoopField				; sets options VarName
      Else						; for the rest after the first,
      {							; split at the last space, apply the first chunk to the VarValue for the last Option
        %Option% := SubStr(A_LoopField, 1, (pos := InStr(A_LoopField, A_Space, false, 0))-1)
        %Option% = % %Option%
        Option   := SubStr(A_LoopField, pos+1)		; and set the next option to the last chunk (from the last space to the "=")
      }
  }
  If _AutoTrim
   AutoTrim, Off
  If Wait <>						; option Wait=ID used, normal Notify window not being created
  {
      If Wait Is Number					; waits for a specific notify
      {
        Gui %Wait%:+LastFound				; i'd like to remove this to not affect calling script... 
        If NotifyGuiID := WinExist()			; but think i have to use hWnd's for reference instead of gui numbers which will
        {						; probably happen in my AHK_L transition since gui numbers won't matter anymore
          WinWaitClose, , , % Abs(Duration)		; wait to close for duration
          If (ErrorLevel && Duration < 1)		; destroys window when done waiting if duration is negative
          {						; otherwise lets the calling script proceed after waiting the duration (without destroying)
            Gui, % Wait + GL - GF + 1 ":Destroy"	; destroys border gui
            If ST
              DllCall("AnimateWindow","UInt",NotifyGuiID,"Int",ST,"UInt","0x00050001") ; slides window out to the right if ST or SC are used
            Gui, %Wait%:Destroy				; and destroys it
            StringReplace, GNList, GNList, % "|" Wait "|", |, All 
          }
        }
      }
      Else						; wait for all notify's if "Wait=All" is used in the options string
      {							; loops through all existing notify's and performs the same wait logic 
        Loop, % GL-GF					; (with or without destroying if negative or not)
        {
          Wait := A_Index + GF - 1
          Gui %Wait%:+LastFound
          If NotifyGuiID := WinExist()
          {
            WinWaitClose, , , % Abs(Duration)
            If (ErrorLevel && Duration < 1)
            {
              Gui, % Wait + GL - GF + 1 ":Destroy"	; destroys border gui
              If ST
                DllCall("AnimateWindow","UInt",NotifyGuiID,"Int",ST,"UInt","0x00050001") ; slides window out to the right if ST or SC are used
              Gui, %Wait%:Destroy			; and destroys it
            }
          }
        }
        GNList := ACList := ATList := AXList := ""	; clears internal variables since they're all destroyed now
      }
      Return
  }
  If Update <>						; option "Update=ID" being used, Notify window will not be created
  {							; title, message, image and progress position can be updated
      If Title <>
       GuiControl, %Update%:,_Title_,%Title%
      If Message <>
       GuiControl, %Update%:,_Message_,%Message%
      If Duration <>
       GuiControl, %Update%:,_Progress_,%Duration%
      If Image <>
       GuiControl, %Update%:,_Image_,%Image%
      If Wallpaper <>
       GuiControl, %Update%:,_Wallpaper_,%Image%
      Return
  }
  If Style = Save					; option "Style=Save" is used to save the existing window style
  {							; and call it back later with "Style=Load"
   Saved := Options " GC=" GC " GR=" GR " GT=" GT " BC=" BC " BK=" BK " BW=" BW " BR=" BR " BT=" BT " BF=" BF
   Saved .= " TS=" TS " TW=" TW " TC=" TC " TF=" TF " MS=" MS " MW=" MW " MC=" MC " MF=" MF
   Saved .= " IW=" IW " IH=" IH " IN=" IN " PW=" PW " PH=" PH " PC=" PC " PB=" PB " XC=" XC " XS=" MS " XW=" XW
   Saved .= " SI=" SI " SC=" SC " ST=" ST " WF=" Image " IF=" IF
  }							; this needs some major improvement to have multiple saved instead of just one, otherwise pointless
  If Return <>
   Return, % (%Return%)
  If Style <>						; option "Style=Default will reset all variables back to defaults... except options also specified
  {							; so "Style=Default GC=Blue" is allowed, which will reset all defaults and then set GC=Blue
   If Style = Default
    Return % Notify(Title,Message,Duration,		; maybe handled poorly by calling itself, but it saves having to have the defaults set in two areas... thoughts?
(
"GC= GR= GT= BC= BK= BW= BR= BT= BF= TS= TW= TC= TF= 
 MS= MW= MC= MF= SI= ST= SC= IW=
 IH= IN= XC= XS= XW= PC= PB= " Options "Style=")
)							; below are more internally saved styles, which may move to an auxiliary function at some point, but could use some improvement
   Else If Style = ToolTip
    Return % Notify(Title,Message,Duration,"SI=50 GC=FFFFAA BC=00000 GR=0 BR=0 BW=1 BT=255 TS=8 MS=8 " Options "Style=")
   Else If Style = BalloonTip
    Return % Notify(Title,Message,Duration,"SI=350 GC=FFFFAA BC=00000 GR=13 BR=15 BW=1 BT=255 TS=10 MS=8 AX=1 XC=999922 IN=8 Image=" A_WinDir "\explorer.exe " Options "Style=")
   Else If Style = Error
    Return % Notify(Title,Message,Duration,"SI=250 GC=Default BC=00000 GR=0 BR=0 BW=1 BT=255 TS=12 MS=12 AX=1 XC=666666 IN=10 IW=32 IH=32 Image=" A_WinDir "\explorer.exe " Options "Style=")
   Else If Style = Warning
    Return % Notify(Title,Message,Duration,"SI=250 GC=Default BC=00000 GR=0 BR=0 BW=1 BT=255 TS=12 MS=12 AX=1 XC=666666 IN=9 IW=32 IH=32 Image=" A_WinDir "\explorer.exe " Options "Style=")
   Else If Style = Info
    Return % Notify(Title,Message,Duration,"SI=250 GC=Default BC=00000 GR=0 BR=0 BW=1 BT=255 TS=12 MS=12 AX=1 XC=666666 IN=8 IW=32 IH=32 Image=" A_WinDir "\explorer.exe " Options "Style=")
   Else If Style = Question
    Return % Notify(Title,Message,Duration,"SI=250 GC=Default BC=00000 GR=0 BR=0 BW=1 BT=255 TS=12 MS=12 AX=1 XC=666666 Image=24 IW=32 IH=32 " Options "Style=")
   Else If Style = Progress
    Return % Notify(Title,Message,Duration,"SI=100 GC=Default BC=00000 GR=9 BR=13 BW=2 BT=105 TS=10 MS=10 PG=100 PH=10 GW=300 " Options "Style=")
   Else If Style = Huge
    Return % Notify(Title,Message,Duration,"SI=100 ST=200 SC=200 GC=FFFFAA BC=00000 GR=27 BR=39 BW=6 BT=105 TS=24 MS=22 " Options "Style=")
   Else If Style = Load
    Return % Notify(Title,Message,Duration,Saved)
  }
 }
;—————— end if options ————————————————————————————————————————————————————————————————————————————

  GC_ := GC_<>"" ? GC_ : GC := GC<>"" ? GC : "FFFFAA"	; defaults are set here, and static overrides are used and saved
  GR_ := GR_<>"" ? GR_ : GR := GR<>"" ? GR : 9		; and non static options (with OP_=) are used but not saved
  GT_ := GT_<>"" ? GT_ : GT := GT<>"" ? GT : "Off"
  BC_ := BC_<>"" ? BC_ : BC := BC<>"" ? BC : "000000"
  BK_ := BK_<>"" ? BK_ : BK := BK<>"" ? BK : "Silver"
  BW_ := BW_<>"" ? BW_ : BW := BW<>"" ? BW : 2
  BR_ := BR_<>"" ? BR_ : BR := BR<>"" ? BR : 13
  BT_ := BT_<>"" ? BT_ : BT := BT<>"" ? BT : 105
  BF_ := BF_<>"" ? BF_ : BF := BF<>"" ? BF : 350
  TS_ := TS_<>"" ? TS_ : TS := TS<>"" ? TS : 10
  TW_ := TW_<>"" ? TW_ : TW := TW<>"" ? TW : 625
  TC_ := TC_<>"" ? TC_ : TC := TC<>"" ? TC : "Default"
  TF_ := TF_<>"" ? TF_ : TF := TF<>"" ? TF : "Default"
  MS_ := MS_<>"" ? MS_ : MS := MS<>"" ? MS : 10
  MW_ := MW_<>"" ? MW_ : MW := MW<>"" ? MW : "Default"
  MC_ := MC_<>"" ? MC_ : MC := MC<>"" ? MC : "Default"
  MF_ := MF_<>"" ? MF_ : MF := MF<>"" ? MF : "Default"
  SI_ := SI_<>"" ? SI_ : SI := SI<>"" ? SI : 0
  SC_ := SC_<>"" ? SC_ : SC := SC<>"" ? SC : 0
  ST_ := ST_<>"" ? ST_ : ST := ST<>"" ? ST : 0
  IW_ := IW_<>"" ? IW_ : IW := IW<>"" ? IW : 32
  IH_ := IH_<>"" ? IH_ : IH := IH<>"" ? IH : 32
  IN_ := IN_<>"" ? IN_ : IN := IN<>"" ? IN : 0
  XF_ := XF_<>"" ? XF_ : XF := XF<>"" ? XF : "Arial Black"
  XC_ := XC_<>"" ? XC_ : XC := XC<>"" ? XC : "Default"
  XS_ := XS_<>"" ? XS_ : XS := XS<>"" ? XS : 12
  XW_ := XW_<>"" ? XW_ : XW := XW<>"" ? XW : 800
  PC_ := PC_<>"" ? PC_ : PC := PC<>"" ? PC : "Default"
  PB_ := PB_<>"" ? PB_ : PB := PB<>"" ? PB : "Default"

  wPW := ((PW<>"") ? ("w" PW) : (""))			; needs improvement, poor handling of explicit sizes and progress widths
  hPH := ((PH<>"") ? ("h" PH) : (""))
  If GW <>
  {
   wGW = w%GW%
   wPW := "w" GW - 20
  }
  hGH := ((GH<>"") ? ("h" GH) : (""))
  wGW_ := ((GW<>"") ? ("w" GW - 20) : (""))
  hGH_ := ((GH<>"") ? ("h" GH - 20) : (""))
;————————————————————————————————————————————————————————————————————————
 If Duration =						; default if duration is not used or set to ""
  Duration = 30
 GN := GF						; find the next available gui number to use, starting from GF (default 50)
 Loop							; within the defined range GF to GL
  IfNotInString, GNList, % "|" GN
   Break
  Else
   If (++GN > GL)					;=== too many notifications open, returns 0, handle this error in the calling script
    Return 0            	  			; this is uncommon as the screen is too cluttered by this point anyway
 GNList .= "|" GN
 GN2 := GN + GL - GF + 1

 If AC <>						; saves the action to be used when clicked or timeout (or x-button is clicked)
  ACList .= "|" GN "=" AC				; need to add different clicks for Title, Message, Image as well
 If AT <>						; saved internally in a list, then parsed by the timer or click routine
  ATList .= "|" GN "=" AT				; to run the script-side subroutine/label "AC=LabelName"
 If AX <>
  AXList .= "|" GN "=" AX


 P_DHW := A_DetectHiddenWindows				; start finding location based on what other Notify() windows are on the screen
 P_TMM := A_TitleMatchMode				; saved to restore these settings after changing them, so the calling script won't know
 DetectHiddenWindows On					; as they are needed to find all as they are being made as well... or hidden for some reason...
 SetTitleMatchMode 1					; and specific window title match is a little more failsafe
 If (WinExist("_Notify()_GUI_"))  			;=== find all Notifications from ALL scripts, for placement
  WinGetPos, OtherX, OtherY       			;=== change this to a loop for all open notifications and find the highest?
 DetectHiddenWindows %P_DHW%				;=== using the last Notify() made at this point, which may be better
 SetTitleMatchMode %P_TMM%				; and the global settings are restored for the calling thread

 Gui, %GN%:-Caption +ToolWindow +AlwaysOnTop -Border	; here begins the creation of the window
 Gui, %GN%:Color, %GC_%					; with the logic to add or not add certain controls, Wallpaper, Image, Title, Progress, Message
 If FileExist(WP)					; and some placement logic depending if they are used or not... could definitely be improved
 {
  Gui, %GN%:Add, Picture, x0 y0 w0 h0 v_Wallpaper_, % WP	; wallpaper added first, stretched to size later
  ImageOptions = x+8 y+4
 }
 If Image <>							; icon image added next, sized, and spacing added for whats next
 {
  If FileExist(Image)
   Gui, %GN%:Add, Picture, w%IW_% h%IH_% Icon%IN_% v_Image_ %ImageOptions%, % Image
  Else
   Gui, %GN%:Add, Picture, w%IW_% h%IH_% Icon%Image% v_Image_ %ImageOptions%, %A_WinDir%\system32\shell32.dll
  ImageOptions = x+10
 }
 If Title <>							; title text control added next, if used
 {
  Gui, %GN%:Font, w%TW_% s%TS_% c%TC_%, %TF_%
  Gui, %GN%:Add, Text, %ImageOptions% BackgroundTrans v_Title_, % Title
 }
 If PG								; then the progress bar, if called for
  Gui, %GN%:Add, Progress, Range0-%PG% %wPW% %hPH% c%PC_% Background%PB_% v_Progress_
 Else
  If ((Title) && (Message))					; some spacing tweaks if both used
   Gui, %GN%:Margin, , -5
 If Message <>							; and finally the message text control if used
 {
  Gui, %GN%:Font, w%MW_% s%MS_% c%MC_%, %MF_%
  Gui, %GN%:Add, Text, BackgroundTrans v_Message_, % Message
 }
 If ((Title) && (Message))					; final spacing
  Gui, %GN%:Margin, , 8			
 Gui, %GN%:Show, Hide %wGW% %hGH%, _Notify()_GUI_		; final sizing
 Gui  %GN%:+LastFound						; would like to get rid of this to prevent calling script being affected
 WinGetPos, GX, GY, GW, GH					; final positioning
 GuiControl, %GN%:, _Wallpaper_, % "*w" GW " *h" GH " " WP	; stretch that wallpaper to size
 GuiControl, %GN%:MoveDraw, _Title_,    % "w" GW-20 " h" GH-10	; poor handling of text wrapping when gui has explicit size called
 GuiControl, %GN%:MoveDraw, _Message_,  % "w" GW-20 " h" GH-10	; needs improvement (and if image is used or not)
 If AX <>							; add the corner "X" for closing with a different action than otherwise clicked
 {
  GW += 10
  Gui, %GN%:Font, w%XW_% s%XS_% c%XC_%, Arial Black  		; × (multiply) is the character used for the X-Button
  Gui, %GN%:Add, Text, % "x" GW-15 " y-2 Center w12 h20 g_Notify_Kill_" GN - GF + 1, % chr(0x00D7) ;××
 }
 Gui, %GN%:Add, Text, x0 y0 w%GW% h%GH% BackgroundTrans g_Notify_Action_Clicked_ 	; to catch clicks anywhere on the gui
 If (GR_)							; may have to be removed for seperate title/message/etc actions
  WinSet, Region, % "0-0 w" GW " h" GH " R" GR_ "-" GR_
 If (GT_)							; non-functioning GT option, since the border gui gets in the way
  WinSet, Transparent, % GT_					; will be addressed someday, leaving it in

 SysGet, Workspace, MonitorWorkArea				; positioning
 NewX := WorkSpaceRight-GW-5
 If (OtherY)
  NewY := OtherY-GH-2-BW_*2
 Else
  NewY := WorkspaceBottom-GH-5
 If NewY < % WorkspaceTop
  NewY := WorkspaceBottom-GH-5

 Gui, %GN2%:-Caption +ToolWindow +AlwaysOnTop -Border +E0x20	; border gui
 Gui, %GN2%:Color, %BC_%
 Gui  %GN2%:+LastFound
 If (BR_)
  WinSet, Region, % "0-0 w" GW+(BW_*2) " h" GH+(BW_*2) " R" BR_ "-" BR_
 If (BT_)
  WinSet, Transparent, % BT_

 Gui, %GN2%:Show, % "Hide x" NewX-BW_ " y" NewY-BW_ " w" GW+(BW_*2) " h" GH+(BW_*2), _Notify()_BGGUI_ 	; actual creation of border gui! but still not shown
 Gui, %GN%:Show,  % "Hide x" NewX " y" NewY " w" GW, _Notify()_GUI_					; actual creation of Notify() gui! but still not shown
 Gui  %GN%:+LastFound											; need to get rid of this so calling script isn't affected
 If SI_
  DllCall("AnimateWindow","UInt",WinExist(),"Int",SI_,"UInt","0x00040008")				; animated in, if SI is used
 Else
  Gui, %GN%:Show, NA, _Notify()_GUI_									; otherwise, just shown
 Gui, %GN2%:Show, NA, _Notify()_BGGUI_									; and the border shown
 WinSet, AlwaysOnTop, On										; and set to Always on Top

 If ((Duration < 0) OR (Duration = "-0"))				; saves internally that ExitApp should happen when this
  Exit := GN								; notify dissappears
 If (Duration)	
  SetTimer, % "_Notify_Kill_" GN - GF + 1, % - Abs(Duration) * 1000	; timer set depending on Duration parameter
 Else
  SetTimer, % "_Notify_Flash_" GN - GF + 1, % BF_			; timer set to flash border if the Notify has 0 (infinite) duration

Return %GN%								; end of Notify(), returns Gui ID number used

;==================================================================================================
;======== option AC=Label means Label: subroutine will be run when a notification is clicked: =====
;==================================================================================================
_Notify_Action_Clicked_:
 ; Critical
 SetTimer, % "_Notify_Kill_" A_Gui - GF + 1, Off
 Gui, % A_Gui + GL - GF + 1 ":Destroy"
 If SC
 {
  Gui, %A_Gui%:+LastFound
  DllCall("AnimateWindow","UInt",WinExist(),"Int",SC,"UInt", "0x00050001")
 }
 Gui, %A_Gui%:Destroy
 If (ACList)
  Loop,Parse,ACList,|
   If ((Action := SubStr(A_LoopField,1,2)) = A_Gui)
   {
    Temp_Notify_Action:= SubStr(A_LoopField,4)
    StringReplace, ACList, ACList, % "|" A_Gui "=" Temp_Notify_Action, , All
    If IsLabel(_Notify_Action := Temp_Notify_Action)
     Gosub, %_Notify_Action%
    _Notify_Action =
    Break
   }
 StringReplace, GNList, GNList, % "|" A_Gui, , All
 SetTimer, % "_Notify_Flash_" A_Gui - GF + 1, Off
 If (Exit = A_Gui)
  ExitApp
Return

;==================================================================================================
;============================================================= when a notification times out: =====
;==================================================================================================
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
 Critical
 StringReplace, GK, A_ThisLabel, _Notify_Kill_
 SetTimer, _Notify_Flash_%GK%, Off
 GK := GK + GF - 1
 Gui, % GK + GL - GF + 1 ":Destroy"
 If ST
 {
  Gui, %GK%:+LastFound
  DllCall("AnimateWindow","UInt",WinExist(),"Int",ST,"UInt", "0x00050001")
 }
 Gui, %GK%:Destroy
 StringReplace, GNList, GNList, % "|" GK, , All
 If (Exit = GK)
  ExitApp
Return 1

;==================================================================================================
;======================================== flashes a permanent notification: =======================
;==================================================================================================
_Notify_Flash_1:
_Notify_Flash_2:
_Notify_Flash_3:
_Notify_Flash_4:		; this needs a different method, too many labels
_Notify_Flash_5:		; they are used for Timers, different for each Notify() based on flash speed...
_Notify_Flash_6:		; when duration is 0 (infinite)
_Notify_Flash_7:		; this may feature may be removed completely, Update given the ability to affect GC and BC
_Notify_Flash_8:		; and then the flashing could be handled script-side via returned gui number and a script-side timer
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
  Gui, %FlashGN2%:Color, %BK%
 Else
  Gui, %FlashGN2%:Color, %BC%
Return
}
