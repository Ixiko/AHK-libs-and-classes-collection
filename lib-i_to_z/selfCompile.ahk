; Include this code at the beginning of a script to provide self-compiling functionality.
; When the .ahk file is run it will prompt to compile, but the .exe will run as intended.
;
; You can set the following compile parameter variables:
; OUT    optional folder path (create exe with same name as script in that folder),
;        or full path including a different exe name if required.
; ICON   optional path & name of an icon file, default is AutoHotkey icon.
; PASS   optional password to encrypt the script within the exe.
;
; Example:
; OUT=D:\Temp\
; ICON=C:\Windows\System\Icons\Setup.ico
; PASS=encrypt
; #include,!compile.ahk
;
IfInString,A_ScriptName,.ahk
{
  StringTrimRight,name,A_ScriptName,4
  RegRead,cmd,HKEY_CLASSES_ROOT,AutoHotkeyScript\Shell\Compile\Command
  StringTrimRight,cmd,cmd,4
  IfEqual,out,,StringReplace,out,A_ScriptFullPath,.ahk,.exe ; default to same folder & name
  IfNotInString,out,.exe,SetEnv,out,%out%\%name%.exe ; same name in specified folder
  StringReplace,out,out,\\,\,All
  SetEnv,cmd,%cmd%  "%A_ScriptFullPath%" /out "%out%"
  SetEnv,msg,Input`t`t%A_ScriptFullPath%`nOutput`t`t%out%
  If icon>
  {
    SetEnv,cmd,%cmd% /icon "%icon%"
    SetEnv,msg,%msg%`nIcon`t`t%icon%
  }
  If pass>
  {
    SetEnv,cmd,%cmd% /pass "%pass%"
    SetEnv,msg,%msg%`nPassword`t`t%pass%
  }
  MsgBox,1,Compile this script?,%msg%
  IfMsgBox,ok,Run,%cmd%
  Exit
}