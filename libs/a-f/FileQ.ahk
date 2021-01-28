FileQ( List, Folder := "", D := "|" ) {  ; by SKAN | 01-Oct-2018 | Topic: goo.gl/R4QrF4
Local NewList := "", F := ( Folder<> "" ? Folder "\" : "" ) 
  Loop, Parse, List, %D%
    If FileExist( F A_LoopField )
       NewList .= A_LoopField D 
Return RTrim( NewList,D )
}

; Usage example

#NoEnv
#SingleInstance, Force

FileList := "asd.txt|fgh.ahk|Installer.ahk|license.txt|AutoHotkey.chm|qwerty"
SplitPath, A_AhkPath,, Folder
MsgBOx % FileQ( FileList, Folder )