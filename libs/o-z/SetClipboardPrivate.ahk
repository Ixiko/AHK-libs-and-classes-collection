/*
	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=97251
	Windows 10+ introduced Clipboard History and syncing.
	Useful, but it makes transferring data with the clipboard problematic.
	I couldn't find any examples of avoiding this without disabling these tools entirely, but programs like password managers already were.
	You'll have to handle the clipboard directly. After you set your actual data, you must also set some 0 values with specific formats:
*/


SetClipboardPrivate(str) {
   Bytes := StrPut(str, "utf-16")
   hMemTXT := DllCall("GlobalAlloc", "Int", 0x42, "Ptr", (Bytes*2)+8, "Ptr")
   pMem := DllCall("GlobalLock", "Ptr", hMemTXT, "Ptr")
   StrPut(str, pMem, Bytes, "utf-16")
   DllCall("GlobalUnlock", "Ptr", hMemTXT)
   DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
   DllCall("EmptyClipboard")
   DllCall("SetClipboardData", "Int", 13, "Ptr", hMemTXT)
   DllCall("SetClipboardData", "Int", DllCall("RegisterClipboardFormat", "Str", "ExcludeClipboardContentFromMonitorProcessing"), "Ptr", 0)
   DllCall("SetClipboardData", "Int", DllCall("RegisterClipboardFormat", "Str", "CanIncludeInClipboardHistory"), "Ptr", 0)
   DllCall("SetClipboardData", "Int", DllCall("RegisterClipboardFormat", "Str", "CanUploadToCloudClipboard"), "Ptr", 0)
   DllCall("CloseClipboard")
}