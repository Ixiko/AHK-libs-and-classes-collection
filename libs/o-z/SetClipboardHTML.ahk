; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=80706
; Author:	SKAN
; Date:      SetClipboardHTML(HtmlBody, HtmlHead, AltText)
; for:     	AHK_L

/*

     #NoEnv
     #SingleInstance, Force
     Hotstring(":*X:]d", "DatePaste")
     Return

     DatePaste:
       FormatTime, DTH,, '<div><i>'dddd'</i>', '<b>'dd-MMM-yyyy'</b>' h:mm tt'</div>'
       FormatTime, DTT,, dddd, dd-MMM-yyyy h:mm tt
       SetClipboardHTML(DTH,, DTT)
       SendInput ^v
     Return

*/

/*       SetClipboardHTML(HtmlBody, HtmlHead, AltText)

     Sets CF_HTML data in clipboard which can then be pasted with Ctrl+v
     Sample: SetClipboardHTML("<div><b>Welcome to AutoHotkey</b></div>",, "Welcome to AutoHotkey")

     Parameters:

     HtmlBody : Body of the HTML, without <body></body> tags. Paste will work only in html capable input.
     HtmlHead : Optional Head content of the HTML, without <head></head> tags.
     You may use this for limited CSS styling with supported editors like MS Word.
     For browser input (Gmail/YahooMail etc.), you may use limited inline styling in Body.
     AltText : Optional alternative (unicode) text for html incapable editors like Notepad, PSPad etc.

*/

SetClipboardHTML(HtmlBody, HtmlHead:="", AltText:="") {       ; v0.66 by SKAN on D393/D396
Local  F, Html, pMem, Bytes, hMemHTM:=0, hMemTXT:=0, Res1:=1, Res2:=1   ; @ tiny.cc/t80706
Static CF_UNICODETEXT:=13,   CFID:=DllCall("RegisterClipboardFormat", "Str","HTML Format")

  If ! DllCall("OpenClipboard", "Ptr",A_ScriptHwnd)
    Return 0
  Else DllCall("EmptyClipboard")

  If (HtmlBody!="")
  {
      Html     := "Version:0.9`r`nStartHTML:00000000`r`nEndHTML:00000000`r`nStartFragment"
               . ":00000000`r`nEndFragment:00000000`r`n<!DOCTYPE>`r`n<html>`r`n<head>`r`n"
                         . HtmlHead . "`r`n</head>`r`n<body>`r`n<!--StartFragment -->`r`n"
                              . HtmlBody . "`r`n<!--EndFragment -->`r`n</body>`r`n</html>"

      Bytes    := StrPut(Html, "utf-8")
      hMemHTM  := DllCall("GlobalAlloc", "Int",0x42, "Ptr",Bytes+4, "Ptr")
      pMem     := DllCall("GlobalLock", "Ptr",hMemHTM, "Ptr")
      StrPut(Html, pMem, Bytes, "utf-8")

      F := DllCall("Shlwapi.dll\StrStrA", "Ptr",pMem, "AStr","<html>", "Ptr") - pMem
      StrPut(Format("{:08}", F), pMem+23, 8, "utf-8")
      F := DllCall("Shlwapi.dll\StrStrA", "Ptr",pMem, "AStr","</html>", "Ptr") - pMem
      StrPut(Format("{:08}", F), pMem+41, 8, "utf-8")
      F := DllCall("Shlwapi.dll\StrStrA", "Ptr",pMem, "AStr","<!--StartFra", "Ptr") - pMem
      StrPut(Format("{:08}", F), pMem+65, 8, "utf-8")
      F := DllCall("Shlwapi.dll\StrStrA", "Ptr",pMem, "AStr","<!--EndFragm", "Ptr") - pMem
      StrPut(Format("{:08}", F), pMem+87, 8, "utf-8")

      DllCall("GlobalUnlock", "Ptr",hMemHTM)
      Res1  := DllCall("SetClipboardData", "Int",CFID, "Ptr",hMemHTM)
  }

  If (AltText!="")
  {
      Bytes    := StrPut(AltText, "utf-16")
      hMemTXT  := DllCall("GlobalAlloc", "Int",0x42, "Ptr",(Bytes*2)+8, "Ptr")
      pMem     := DllCall("GlobalLock", "Ptr",hMemTXT, "Ptr")
      StrPut(AltText, pMem, Bytes, "utf-16")
      DllCall("GlobalUnlock", "Ptr",hMemHTM)
      Res2  := DllCall("SetClipboardData", "Int",CF_UNICODETEXT, "Ptr",hMemTXT)
  }

  DllCall("CloseClipboard")

  hMemHTM := hMemHTM ? DllCall("GlobalFree", "Ptr",hMemHTM) : 0
  hMemTXT := hMemTXT ? DllCall("GlobalFree", "Ptr",hMemTXT) : 0

Return (Res1 & Res2)
}