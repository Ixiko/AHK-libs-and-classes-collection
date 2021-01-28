; Return the current Window Version
; [Used in FileExtensionToggle, HiddenFilesToggle.ahk, SnippingShortcut.ahk]


WinVer()
{
  RegRead, Version, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentVersion
  Return Version
}

; If Windows Vista/2008 or later (v 6.0)