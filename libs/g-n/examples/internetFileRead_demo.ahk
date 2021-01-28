; #Include InternetFileRead.ahk
; Modified third example by SKAN
; Example: Download a http file: AutoHotkey installer (~2 MB) and save & run it.
URL := "http://www.autohotkey.com/download/AutoHotkeyInstall.exe"
If ( InternetFileRead( binData, URL ) > 0 && !ErrorLevel )
    If InternetFileRead_VarZ_Save( binData, A_Temp "\AutoHotkeyInstall.exe" ) {
         Sleep 500
         InternetFileRead_DLP( false ) ; or use Progress, off
         Run %A_Temp%\AutoHotkeyInstall.exe
       }