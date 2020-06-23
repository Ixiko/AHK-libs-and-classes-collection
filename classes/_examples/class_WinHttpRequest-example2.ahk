; Link:   	https://raw.githubusercontent.com/infogulch/WinHttpRequest/master/testing-whr2.ahk_l
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

#Persistent
#Include COM.ahk
OnExit, CleanUp

COM_Init()
pwhr    := COM_CreateObject("WinHttp.WinHttpRequest.5.1")
psink   := ConnectIWinHttpRequestEvents(pwhr)

msgbox % pwhr "`n" psink

COM_Invoke(pwhr, "Open", "GET", "http://www.autohotkey.com/", "True")
COM_Invoke(pwhr, "Send")
Sleep, 3000
COM_Invoke(pwhr, "Open", "GET", "http://www.autohotkey.com/forum/", "True")
COM_Invoke(pwhr, "Send")
Return

CleanUp:
COM_Unadvise(NumGet(psink+8), NumGet(psink+12))
COM_Release(NumGet(psink+8))
COM_Release(pwhr)
COM_Term()
ExitApp

IWinHttpRequestEvents(this, nStatus = "", pType = "")
{
   Critical
   If   A_EventInfo = 0
      NumPut(this,pType+0)
;   Else If   A_EventInfo = 1
;   Else If   A_EventInfo = 2
   Else If   A_EventInfo = 3
      msgbox, % "[START]`t" . nStatus . ": " . pType . "`n`n"
;   Else If   A_EventInfo = 4
   Else If   A_EventInfo = 5
      msgbox, % COM_Invoke(NumGet(this+4), "ResponseText") . "`n[END]`n"   
   Else If   A_EventInfo = 6
      msgbox, % "[ERROR]`t" . nStatus . ": " . pType . "`n`n"
   Return   0
}

ConnectIWinHttpRequestEvents(pwhr)
{
   Static   IWinHttpRequestEvents
   If Not   VarSetCapacity(IWinHttpRequestEvents)
   {
      VarSetCapacity(IWinHttpRequestEvents,28,0), nParams=3113213
      Loop,   Parse,   nParams
      NumPut(RegisterCallback("IWinHttpRequestEvents","",A_LoopField,A_Index-1),IWinHttpRequestEvents,4*(A_Index-1))
   }
   pconn:=COM_FindConnectionPoint(pwhr,IID_IWinHttpRequestEvents:="{F97F4E15-B787-4212-80D1-D380CBBF982E}")
   psink:=COM_CoTaskMemAlloc(16)
   NumPut(&IWinHttpRequestEvents,psink+0)
   NumPut(pwhr,)
   NumPut(pconn,psink+8)
   NumPut(COM_Advise(pconn,psink),)
   Return   psink
}