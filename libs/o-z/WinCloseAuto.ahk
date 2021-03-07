; Title:   	WinCloseAuto() : Closes automatically when specified windows show up
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=77461&sid=b484c430d6274b1ab118eee5108a707a
; Author:	SKAN
; Date:   	18.06.2020
; for:     	AHK_L

/*  WinCloseAuto(SetHook, WEP.1, WEP.2, WEP.3, WEP.4)

   WinCloseAuto() will monitor and close up to 4 windows.

   Parameters::
   SetHook parameter should not be omitted and should be True to set Hook on, or False to Unhook.
   WEP.1 .. WEP.4 are WinExist() parameters which needs to be passed as separate array for each parameter.
   Note: WinExist() has 4 parameters. The examples below utilizes only the first parameter

   Usage examples:
   The following code will auto-close whenever Calculator, Notepad or Windows Task Manager shows up.

*/

/*
   #NoEnv
   #Warn
   #SingleInstance, Force
   Process, Priority,,High
   #Persistent ; <== required

   WinCloseAuto( True, ["ahk_class Notepad"]
                     , ["ahk_class CalcFrame"]
                     , ["Windows Task Manager ahk_class #32770"] )

*/

/*

   #NoEnv
   #Warn
   #SingleInstance, Force
   Process, Priority,,High
   Hook := 0

   F2:: WinCloseAuto( Hook:=!Hook, ["ahk_class Notepad"]
                                 , ["ahk_class CalcFrame"]
                                 , ["Windows Task Manager ahk_class #32770"] )

*/

WinCloseAuto(P*) {        ; WinCloseAuto v0.50 by SKAN on D36I/D36I @ tiny.cc/wincloseauto
Static CBA:=RegisterCallBack("WinCloseAuto"), WEP:="", hHook:=0, EVENT_OBJECT_SHOW:=0x8002
  If IsObject(P)
     Return (P.1=1 && (WEP:=P)) ? hHook:=DllCall("SetWinEventHook","Int",EVENT_OBJECT_SHOW
           ,"Int",EVENT_OBJECT_SHOW, "Ptr",0, "Ptr",CBA, "Int",0, "Int",0, "Int",0, "Ptr")
          : (P.1=0 && (WEP:="")="") ? DllCall("UnhookWinEvent", "Ptr",hHook) : ""
  If WinExist((WEP.2)*) || WinExist((WEP.3)*)  || WinExist((WEP.4)*) || WinExist((WEP.5)*)
     PostMessage, 0x112, 0xF060 ;  WM_SYSCOMMAND, SC_CLOSE
}