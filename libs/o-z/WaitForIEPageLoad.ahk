;http://www.autohotkey.com/forum/topic19256.html

#Persistent
sUrl :=   "http://www.autohotkey.com/forum/"

COM_Init()
pweb :=   COM_CreateObject("InternetExplorer.Application")
sink :=   COM_ConnectObject(pweb, "IE_")
COM_Invoke(pweb, "Visible", True)

bComplete := False
COM_Invoke(pweb, "Navigate2", sUrl)
While !bComplete
      Sleep, 500

COM_DisconnectObject(sink)
COM_Release(pweb)
COM_Term()
Return

OnComplete:
bComplete := True
Return

IE_DocumentComplete(prms, sink)
{
   If   NumGet(NumGet(prms+0)+24) = NumGet(sink+12)
      SetTimer, OnComplete, -10
/* more rigorous way
   COM_Release(punk1:=COM_QueryInterface(NumGet(NumGet(prms+0)+24),0))
   COM_Release(punk2:=COM_QueryInterface(NumGet(sink+12),0))
   If   (punk1 = punk2)
      SetTimer, OnComplete, -10
*/
}

IEReady(hIESvr = 0)
{
   If Not   hIESvr
   {
      Loop,   50
      {
         ControlGet, hIESvr, hWnd, , Internet Explorer_Server1, A ; ahk_class IEFrame
         If   hIESvr
            Break
         Else   Sleep 100
      }
      If Not   hIESvr
         Return   """Internet Explorer_Server"" Not Found."
   }
   Else
   {
      WinGetClass, sClass, ahk_id %hIESvr%
      If Not   sClass == "Internet Explorer_Server"
         Return   "The specified control is not ""Internet Explorer_Server""."
   }

   COM_Init()
   If   DllCall("SendMessageTimeout", "Uint", hIESvr, "Uint", DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT"), "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 1000, "UintP", lResult)
   &&   DllCall("oleacc\ObjectFromLresult", "Uint", lResult, "Uint", COM_GUID4String(IID_IHTMLDocument2,"{332C4425-26CB-11D0-B483-00C04FD90119}"), "int", 0, "UintP", pdoc)=0
   &&   pdoc && pweb:=COM_QueryService(pdoc,IID_IWebBrowserApp:="{0002DF05-0000-0000-C000-000000000046}")
   {
      While,   COM_Invoke(pweb, "ReadyState") <> 4
      Sleep,   500
      While,   COM_Invoke(pweb, "document.readyState") <> "complete"
      Sleep,   500
      COM_Release(pweb)
   }
   COM_Release(pdoc)
   COM_Term()
   Return   pweb ? "DONE!" : False
}

