;; http://www.autohotkey.com/forum/topic39649.html

#SingleInstance, Force

SetBatchLines -1
SetWorkingDir, %A_ScriptDir%
IfNotExist, WinAPI.txt
   UrlDownloadToFile, http://www.autohotkey.net/~Skan/Utils/MSDN/WinAPI.txt, WinAPI.txt
FileRead, Data, WinAPI.txt
VarSetCapacity( SS,20,32 ), Ctr := 0
Loop, Parse, Data, `n, `r
{ StringSplit, F, A_LoopField, `,
  ExpF .= SubStr( F3 SS,1,19) "|" SubStr( F2 SS,1,19) "|" F1 "`n", CTR := CTR+1
} StringTrimRight, ExpF, ExpF, 1
Gui, Font, s10, Tahoma
Gui, Add, Edit, w439 h20 -E0x200 UpperCase hWndhEdit cAA1010 Border vQuery gSTimer
SendMessage, 0xD3, 0x1,5,, ahk_id %hEdit%
Gui, Add, ListView, Yp+19 R15 w439  -E0x200 +Border gDClick, Function|Library|Link
LV_ModifyCol( 1, "290" ),LV_ModifyCol( 2, "125" ), LV_ModifyCol( 3, "0" ), Data := ""
Gui, Show,, MSDN - %CTR% Documented API Functions
Loop, Parse, ExpF, `n
     LV_Add("",SubStr(A_LoopField,41 ),SubStr(A_LoopField,21,19),SubStr(A_LoopField,1,19))
Return

sTimer:
 SetTimer, FunctionSearch, -250
Return

FunctionSearch:
 Critical
 GuiControlGet, Query
 LV_Delete()
 If ( Query="" ) {
  Loop, Parse, ExpF, `n, `r
     LV_Add("",SubStr(A_LoopField,41 ),SubStr(A_LoopField,21,19),SubStr(A_LoopField,1,19))   
    Return
 } StringReplace, Query, Query, +, +, UseErrorLevel
 SearchItems := ErrorLevel+1
 Loop, Parse, ExpF, `n, `r
 { Data := A_LoopField, Result := 0
   Loop, Parse, Query, +
   Result := InStr( Data,A_LoopField,0,41 ) ? Result+1 : Result
   If ( Result = SearchItems )
     LV_Add("",SubStr(A_LoopField,41 ),SubStr(A_LoopField,21,19),SubStr(A_LoopField,1,19))
} Return

DClick:
 IfNotEqual, A_GuiEvent, DoubleClick, Return
GotoURL:
 Critical
 Row := LV_GetNext( 0, "Focused" ), LV_GetText( Page,Row,3 ), LV_GetText( Func,Row,1 )
 Url1 := "http://www.google.com/search?hl=en&safe=off&as_qdr=all&q="
       . Func "+site%3Amicrosoft.com"
 Url2 := "http://msdn.microsoft.com/en-us/library/" RegExReplace(Page,"\s*$") ".aspx"
 If GetKeyState( "LControl", "P" )
      Run, %Url1%,,Max
 Else Run, %Url2%,,Max   
Return