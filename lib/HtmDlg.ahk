;                                                      _     _            _____   _
;  HtmDlg() - HTML DialogBox v0.51                    | |   | |_         (____ \ | | v0.51
;                                                     | |__ | | |_  ____  _   \ \| | ____
;  Suresh Kumar A N (arian.suresh@gmail.com)          |  __)| |  _)|    \| |   | | |/ _  |
;                                                     | |   | | |__| | | | |__/ /| ( ( | |
;  Created  : 09-Jul-2010                             |_|   |_|\___)_|_|_|_____/ |_|\_|| |
;  Last Mod : 13-Jul-2010                                                          (_____|
;
;  Usage : HtmDlg( URL, hwndOwner, Options, OptionsDelimiter )
;        :  For Options, please refer the bottom of this script
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HtmDlg( _URL="", _Owner=0, _Options="", _ODL="," ) {

; HTML DialogBox v0.50 - scripted by SKAN : www.autohotkey.com/forum/viewtopic.php?t=60215

 static _Ins, _hDLG, _DlgT, _DlgP, _STRU, _pIWEB, _pV,                      BDef=1, BEsc=0

 If ( A_EventInfo = 0xCBF ) {                                    ; nested CallBackFunction
 hWnd := _URL,  uMsg := _Owner,  wP := _Options,  lP := _ODL

 If ( uMsg=0x112 && wP=0xF060 )  ; WM_SYSCOMMAND && SC_ClOSE
  Return DllCall( "EndDialog", UInt,_hDLG, UInt,BDEf := BEsc )

 If ( uMsg=0x111 && (wP>>16)=0 ) ; WM_COMMAND && BN_CLICKED
  Return DllCall( "EndDialog", UInt,_hDLG, UInt,BDef := (wP=2) ? BEsc : wP-100  )

 Return False
 }

 If ! ( _Ins ) {

 _Ins := DllCall( "GetModuleHandle", Str,A_AhkPath )
 _DT=
 ( Ltrim Join
   61160CD3AFCDD0118A3EGC04FC9E26EZPCHC88OAZO8G4DG53G2H53G68G65G6CG6CG2H44G6CG67Q58ZHDG741
   G74G6CG41G78G57G69G6EK7BG38G38G35G36G46G39G36G31G2DG33G34G3H41G2DG31G31G44G3H2DG41G39G3
   6G42G2DG3H3H43G3H34G46G44G37G3H35G41G32G7DT14NFBFFQ65GFFFF8Y14NFBFFQ66GFFFF8Y14NFBFFQ67
   GFFFF8Y14NFBFFQ68GFFFF8Y14NFBFFQ69GFFFF8Y14NFBFFQ6AGFFFF8Y14NFBFFQ6BGFFFF8Y14NFBFFQ6CGF
   FFF8Y14NFBFFQ6DGFFFF8T
 )

 Loop 20  ;  Decompressing Nulls : www.autohotkey.com/forum/viewtopic.php?p=198560#198560
  StringReplace,_DT,_DT,% Chr(70+21-A_Index),% SubStr("000000000000000000000",A_Index),All

 VarSetCapacity( _STRU, ( _DTLEN := StrLen(_DT) // 2 ) + 256, 0 )
 Loop %_DTLEN%                                       ;  Creating Binary Structure from Hex
  NumPut( "0x" . SubStr(_DT, 2*A_Index-1,2),_STRU,A_Index-1,"Char" )

 _pIWEB := &_STRU, _pV := &_STRU+16, _DlgT := &_STRU+32

 If ! DllCall( "GetModuleHandle", Str,"atl.dll" )
      DllCall( "LoadLibrary", Str,"atl.dll" )
      DllCall( "atl\AtlAxWinInit" )
 _DlgP := RegisterCallback( A_ThisFunc,0,4,0xCBF )

 }

 _hDLG := DllCall( "CreateDialogIndirectParam", UInt,_Ins, UInt,_DlgT, UInt, ( _Owner="" )
         ? DllCall("FindWindowA", Str,"AutoHotkey", Str,A_ScriptFullPath " - AutoHotkey v"
         . A_AhkVersion ) : _Owner, UInt,_DlgP, UInt,0 )

 VarSetCapacity( _WU,StrLen(_URL)*2+2 ), sLen := StrLen(_URL)+1
 DllCall( "MultiByteToWideChar", UInt,0, UInt,0, UInt,&_URL, Int,-1, UInt,&_WU, Int,sLen )

 _hHTM := DllCall( "GetDlgItem", UInt,_hDLG, UInt,2000, UInt )

 ; www.autohotkey.com/forum/viewtopic.php?p=103987#103987  WebBrowser Control Demo by Sean
 ; ---------------------------------------------------------------------------------------
 DllCall( "atl\AtlAxGetControl", UInt,_hHTM, UIntP,_ppunk )
 DllCall( NumGet( NumGet( _ppunk+0 )+4*0 ), UInt,_ppunk, UInt,_pIWEB, UIntP,_ppwb )
 DllCall( NumGet( NumGet( _ppunk+0 )+4*2 ), UInt,_ppunk ), _pwb := NumGet( _ppwb+0 )
 DllCall( NumGet(_pwb+4*11),UInt,_ppwb, UInt,&_WU, UInt,_pV,UInt,_pV,UInt,_pV,UInt,_pV )
 ; ---------------------------------------------------------------------------------------

 Slee:=-1, HtmD:=1
 Butt:="OK", BWid:=75, BHei:=23, BSpH:=5, BSpV:=8, BAli:=1
 DlgX:="", DlgY:="", HtmW:=280, HtmH:=140, Left:=5, TopM:=5

 Loop, Parse, _Options, =%_ODL%, %A_Space%
   A_Index & 1  ? ( __ := (SubStr(A_LoopField,1,1)="_") ? "_" : SubStr(A_LoopField,1,4))
                : ( %__% := A_LoopField )

 If ( HtmD )
   DllCall( "MoveWindow", UInt,_hHTM, UInt,0, UInt,0, UInt,HtmW, UInt,HtmH, Int,1 )
 Else {
   DllCall( "MoveWindow", UInt,_hHTM, UInt,Left, UInt,TopM, UInt,HtmW, UInt,HtmH, Int,1 )
   Control, Enable,,, ahk_id %_hHTM%
 }

 Cap := DllCall( "GetSystemMetrics", UInt,4  ) ; SM_CYCAPTION    = Window Caption
 Frm := DllCall( "GetSystemMetrics", UInt,7  ) ; SM_CXFIXEDFRAME = Window Frame
 SBW := DllCall( "GetSystemMetrics", UInt,2  ) ; SM_CXVSCROLL    = VScrollbar Width

 DlgW := Frm + HtmW + Frm + ( HtmD ? 0-SBW : Left+Left )
 DlgH := Cap + Frm + HtmH + BSpV + BHei + BSpV + Frm + ( HtmD ? 0 : TopM )
 DlgX := ( DlgX <> "" ) ? DlgX : ( A_ScreenWidth - DlgW ) // 2
 DlgY := ( DlgY <> "" ) ? DlgY : ( A_ScreenHeight - DlgH ) // 2
 ClAW := DlgW - Frm - Frm                                               ; ClientArea Width

 DllCall( "MoveWindow", UInt,_hDLG, UInt,DlgX, UInt,DlgY, UInt,DlgW, UInt,DlgH, Int,1 )

 StringReplace, Butt,Butt, /,/, UseErrorLevel
 bCount := ErrorLevel+1

 If BAli = 0                                                       
 BX := ( BSpH * 2 ) + ( HtmD ? 0 : Left )
 Else If BAli = 1                                                   
 BX := ( ClAW - (BSpH*(bCount-1)) - (BWid*bCount) ) / 2
 Else
 BX := ClAW - (BSpH*(bCount+1)) - (BWid*bCount) - ( HtmD ? 0 : Left )

 BY := HtmH + BSpV + ( HtmD ? 0 : TopM )

 Loop, Parse, Butt, /
  {
    BHwnd := DllCall( "GetDlgItem", UInt,_hDLG, UInt,100+A_Index )
    DllCall( "MoveWindow", UInt,BHwnd, UInt,BX, UInt,BY, UInt,BWid, UInt,BHei, Int,1 )
    DllCall( "SetWindowTextA", UInt,BHwnd, Str,A_LoopField ), BX := BX+BSpH+BWid
    DllCall( "ShowWindow", UInt,BHwnd, Int,True )
  }
 BDef := ( BDef<1 || BDef>bCount ) ? 1 : BDef
 DllCall( "SendMessageA", UInt,_hDLG, UInt,0x401, UInt,100+BDef, UInt,0 )    ; DM_SETDEFID
 ControlFocus,, % "ahk_id " DllCall( "GetDlgItem", UInt,_hDLG, UInt,100+BDef )

 DllCall( "SetWindowTextA", UInt,_hDLG, Str,Titl ? Titl : A_ScriptName )
 Sleep, %Slee%

 WinShow, ahk_id %_hDLG%
 WinWaitClose, ahk_id %_hDLG%,, %Time%

 If ( TimedOut := Errorlevel ) {
  DllCall( "EndDialog", UInt,_hDLG, UInt,0 )
 }

 If ( AltR=1 && BDef ) {
   StringSplit, B, Butt, /
   BDef := B%BDef%
 }

 DllCall( NumGet(_pwb+4*2), UInt,_ppwb ), DllCall( "SetLastError", UInt,TimedOut ? 1 : 0 )
Return BDEf
}

/*

/- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
>-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - O P T I O N S -
\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Usage: HtmDlg( URL, hwndOwner, Options, OptionsDelimiter )

Parameters :

URL              - A valid URL supported by Internet Explorer including Res:// and File://

hWndOwner        - Handle to the parent window. If invalid handle or 0 ( zero ) is passed,
                   the dialog will have a taskbar button. Passing "" as a parameter will
                   definitely supress the Taskbar Button.

Options          - A series of 'variable overrides' delimited with character specified in
                   Options delimiter. Please refer 'VARIABLE OVERRIDES' below.

OptionsDelimiter - The delimiter used in seperating 'variable overrides'


;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;  * * *   V A R I A B L E   O V E R R I D E S   * * *
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Important Note: leading 4 characters of a variable will be sufficient.
                for eg., Instead of 'AltReturn=1' you may use 'AltR=1'

Title         = Captionbar Text
                Default is A_ScriptName

DlgXpos       = X coordinate in pixels, relative to screen
                Dialog is horizontally centered by default

DlgYpos       = Y coordinate in pixels, relative to screen
                Dialog is vertically centered by default

AltReturn     = 1 will return Button-text
                0 is default and Button Instance will be returned

TimeOut       = Seconds
                No Default value
                Note: A_LastError will be true when a TimeOut occurs

Sleep         = MilliSeconds ( Will be used just before Dialog is shown )
                No Sleep by Default

LeftMargin    = Spacing in Pixels ( on the left/right sides of Htm Control )
                Default value is 5. Ignored if Htm control is disabled. See: HtmDisable

TopMargin     = Spacing in Pixels ( above the Htm Control )
                Default value is 5. Ignored if Htm control is disabled. See: HtmDisable

HtmDisable    = 0 to enable
                Htm Control is disabled by default.

HtmWidth      = Width of WebControl in Pixels
                Default value is 240

HtmHeight     = Height of WebControl in pixels
                Default value is 140

Buttons       = Button labels seperated with "/"  ( eg: Buttons=Yes/No/Cancel )
                Default is "OK"

BDefault      = Instance of Default Button ( eg: To make 3rd Button default, use BDef=3 )
                Default forced value is 1

BEscape       = Instance of Cancel Button ( Used when dialog is closed or Esc is pressed )
                Default is 0

BWidth        = Button Width in Pixels
                Default Value is 75

BHeight       = Button height Pixels
                Default value is 23

BSpHorizontal = Pixels ( affects the spacing on the sides of a button )

BSpVertical   = Pixels ( affects the spacing above/below a button )

BAlign        = 0 or 1 or 2  ( for Left, Center, Right alignment of Buttons )
                Default is 1

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -