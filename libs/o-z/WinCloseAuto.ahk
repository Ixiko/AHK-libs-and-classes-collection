; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=77461&sid=b484c430d6274b1ab118eee5108a707a
; Author:	
; Date:   	
; for:     	AHK_L

/*


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