SetWorkingDir, %A_ScriptDir%
global rtffile := ""
global TomDoc := ""
global TomFile := ""
global RE := ""

RTFtoClip(rtffile) {
   ;msgbox %rtffile%
DetectHiddenWindows, On
clipboard =
RE_Dll := DllCall("LoadLibrary", "Str", "Msftedit.dll", "Ptr")
Gui, +hwndhGui
Gui +LastFound
Winset, Transparent
Gui, Margin, 10, 10
Gui, Font, s10, Arial
Gui, Add, Custom, ClassRICHEDIT50W w400 h400 vRE hwndHRE +VScroll +0x0804 ; ES_MULTILINE | ES_READONLY
RE_SetOleCallback(HRE) ; Thanks to DigiDon and just me. This uses a function from RichEdit OleCallback.ahk
Gui, Show, , RichEdit

TomDoc := GetTomDoc(hRE)
TomFile := rtffile
TomDoc.Open(TomFile, 0x01, 0)

ControlFocus, ahk_class RICHEDIT50W1
Send, ^a^c
ControlClick, RICHEDIT50W1, RichEdit
Gui, Destroy
}


GetTomDoc(HRE) {
   ; Get the document object of the specified RichEdit control
   Static IID_ITextDocument := "{8CC497C0-A1DF-11CE-8098-00AA0047BE5D}"
   DocObj := 0
   If DllCall("SendMessage", "Ptr", HRE, "UInt", 0x043C, "Ptr", 0, "PtrP", IRichEditOle, "UInt") { ; EM_GETOLEINTERFACE
      DocObj := ComObject(9, ComObjQuery(IRichEditOle, IID_ITextDocument), 1) ; ITextDocument
      ObjRelease(IRichEditOle)
   }
   Return DocObj
}

#Include %A_ScriptDir%\..\RichEdit OleCallback.ahk