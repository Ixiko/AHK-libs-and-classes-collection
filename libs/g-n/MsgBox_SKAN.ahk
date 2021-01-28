; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=83007
; Author:	SKAN
; Date:   	08 Nov 2020
; A wrapper function that mimics V2 MsgBox()
; for:     	AHK_L

/*
#NoEnv
#Warn
#SingleInstance, Force

Gui, SKAN: +OwnDialogs
Gui, SKAN: Show, x100 y100 w400 h200
MsgBox("You can't close the GUI`nunless this Message is dismissed")
Return

SKANGuiClose:
 ExitApp
*/

/*
Gui, +HwndGuiHwnd
Gui, Show, x50 y50 w300 h200, My GUI
MsgBox("This is my MsgBox", "My MsgBox", GuiHwnd)

Return
*/

MsgBox( Text:="", Title:="", Options:=0 ) {  ; v0.63 by SKAN on D3AS/D3AS @ tiny.cc/msgbox
Local                                        ;    MsgBox() requires AutoHotkey 1.1.33.02 +

  UT := 0, Opts := (A_Space . Options)
  Loop, Parse, % Trim(Options), %A_Space%
  Switch (A_LoopField)
  {
      Default:                                    UT := (UT | Format("{:d}", A_LoopField))
      Case          "O",   "OK"                                 :  UT := (UT &~ 0xF) | 0x0
      Case 0x1,     "OC",  "O/C",   "OKCancel"                  :  UT := (UT &~ 0xF) | 0x1
      Case 0x2,     "ARI", "A/R/I", "AbortRetryIgnore"          :  UT := (UT &~ 0xF) | 0x2
      Case 0x3,     "YNC", "Y/N/C", "YesNoCancel"               :  UT := (UT &~ 0xF) | 0x3
      Case 0x4,     "YN",  "Y/N",   "YesNo"                     :  UT := (UT &~ 0xF) | 0x4
      Case 0x5,     "RC",  "R/C",   "RetryCancel"               :  UT := (UT &~ 0xF) | 0x5
      Case 0x6,     "CTC", "C/T/C", "CancelTryAgainContinue"    :  UT := (UT &~ 0xF) | 0x6
      Case 0x00010, "Iconx"                             :  UT := (UT &~    0x60) |    0x10
      Case 0x00020, "Icon?"                             :  UT := (UT &~    0x50) |    0x20
      Case 0x00030, "Icon!"                             :  UT := (UT &~    0x40) |    0x30
      Case 0x00040, "Iconi"                             :  UT := (UT &~    0x30) |    0x40
      Case 0x00100, "Default2"                          :  UT := (UT &~   0x200) |   0x100
      Case 0x00200, "Default3"                          :  UT := (UT &~   0x100) |   0x200
      Case 0x00300, "Default4"                          :  UT := (UT &~   0x000) |   0x300
      Case 0x01000, "+Sys",  "+SystemModal"             :  UT := (UT &~ 0x42000) | 0x01000
      Case 0x02000, "+Task", "+TaskModal"               :  UT := (UT &~ 0x41000) | 0x02000
      Case 0x40000, "+Top",  "+Topmost", "+AlwaysOnTop" :  UT := (UT &~ 0x03000) | 0x40000
  }

  Hwnd := ( (f := InStr(Opts, " Owner",, 0)) ? Format("{:d}", SubStr(Opts, f+6)) : 0 )
  DetectHiddenWindows, % ("On", DHW := A_DetectHiddenWindows)
  SetWinDelay, % (0, SWD := A_WinDelay)
  SplashImage, 8:, x0 y0 w0 h0 B Hide,,, OwnDialogTest
  WinWait, OwnDialogTest ahk_class AutoHotkey2,, 10
  hOwner := DllCall("GetWindow", "Ptr",WinExist(), "Int",4 ,"Ptr")          ; GW_OWNER = 4
  SplashImage, 8:Off
  Hwnd := (hOwner!=A_ScriptHwnd) ? hOwner : WinExist("ahk_id" . Hwnd)
  SetWinDelay, %SWD%
  DetectHiddenWindows, %DHW%

  Res := DllCall("User32.dll\MessageBoxTimeout", "Ptr",Hwnd
     ,"Str",Text  ? Text  : "Press OK to continue."
     ,"Str",Title ? Title : A_ScriptName,   "Int",UT,   "Short",0
     ,"Int",( (f:=InStr(Opts, " T",, 0)) ? Format("{:d}", SubStr(Opts, f+2)) : 0) * 1000 )

Return { 1:"OK", 2:"Cancel", 3:"Abort", 4:"Retry", 5:"Ignore", 6:"Yes", 7:"No"
     , 10:"TryAgain", 11:"Continue", 32000:"Timeout" }[Res]
}