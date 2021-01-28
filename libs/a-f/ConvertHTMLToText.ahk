; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?p=319141#p319141
; Author:	malcev
; Date:
; for:     	AHK_L

/*


HTM := "<a href='https://en.wikipedia.org/wiki/Romeo_and_Juliet'><b>Romeo &amp; Juliet</b></a>"
msgbox % ConvertToText(HTM)

*/


ConvertToText(string){
   static HtmlUtilities
   if (HtmlUtilities = "")
      CreateClass("Windows.Data.Html.HtmlUtilities", IHtmlUtilities := "{FEC00ADD-2399-4FAC-B5A7-05E9ACD7181D}", HtmlUtilities)
   CreateHString(string, hHtml)
   DllCall(NumGet(NumGet(HtmlUtilities+0)+6*A_PtrSize), "ptr", HtmlUtilities, "ptr", hHtml, "ptr*", hText)   ; ConvertToText
   DeleteHString(hHtml)
   buffer := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", length, "ptr")
   return StrGet(buffer, "UTF-16")
}

CreateClass(string, interface, ByRef Class){
   CreateHString(string, hString)
   VarSetCapacity(GUID, 16)
   DllCall("ole32\CLSIDFromString", "wstr", interface, "ptr", &GUID)
   result := DllCall("Combase.dll\RoGetActivationFactory", "ptr", hString, "ptr", &GUID, "ptr*", Class, "uint")
   if (result != 0)
   {
      if (result = 0x80004002)
         msgbox No such interface supported
      else if (result = 0x80040154)
         msgbox Class not registered
      else
         msgbox error: %result%
      ExitApp
   }
   DeleteHString(hString)
}

CreateHString(string, ByRef hString){
    DllCall("Combase.dll\WindowsCreateString", "wstr", string, "uint", StrLen(string), "ptr*", hString)
}

DeleteHString(hString){
   DllCall("Combase.dll\WindowsDeleteString", "ptr", hString)
}