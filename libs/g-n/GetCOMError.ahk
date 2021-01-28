;MsgBox % GetSysErrorText(-2147352570)


GetSysErrorText(errNr) ;http://msdn.microsoft.com/en-us/library/ms679351(v=vs.85).aspx
{ ; http://www.autohotkey.com/forum/post-72230.html#72230 by PhiLho
  bufferSize = 1024 ; Arbitrary, should be large enough for most uses
  VarSetCapacity(buffer, bufferSize)
  DllCall("FormatMessage"
     , "UInt", FORMAT_MESSAGE_FROM_SYSTEM := 0x1000
     , "UInt", 0
     , "UInt", errNr
     , "UInt", 0 ;0 - looks in following order -> langNuetral->thread->user->system->USEnglish ;LANG_USER_DEFAULT := 0x20000 ; LANG_SYSTEM_DEFAULT := 0x10000
     , "Str", buffer
     , "UInt", bufferSize
     , "UInt", 0)
  Return buffer
}



