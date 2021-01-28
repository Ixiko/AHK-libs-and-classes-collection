; examples for xStr.ahk function by SKAN
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=74050

#NoEnv
SetBatchLines, -1

labels := ""

FileRead, script, % A_ScriptDir "\" A_ScriptName
Loop, Parse, script, `n, `r
	If RegExMatch(A_LoopField, "^([\w]+_[\w]+)\:", labelname)
		labels .= labelname1 "|"

labels := RTrim(labels, "|")

Gui, New, AlwaysOnTop HWNDhMyGui
Gui, Add, ListBox, vMyListBox gMyListBox w340 r10, % labels
Gui, Add, Button, Default, Exit
Gui, Show, % "AutoSize", double click to run label

return

MyListBox:

	if !Instr(A_GuiEvent, "DoubleClick")
		return

	WinSet, AlwaysOnTop, Off, % "ahk_id " hMyGui
	GuiControlGet, choosed,, MyListBox
	gosub % choosed
	WinSet, AlwaysOnTop, On, % "ahk_id " hMyGui

return


ButtonExit:
GuiClose:
GuiEscape:
ExitApp


; ######################################################################################################
Documentation_example1:
; ###################################################################################################### ;{
; A sub string can be extracted from text by using SubStr() with staring position and Length parameters..
	MsgBox % SubStr("This is <b>BOLD</b> text", 12, 4) ; Returns "BOLD"

; Since the sub string "BOLD" lies between HTML tag pair <b> and </b>, we may extract it dynamically using two Instr() calls.
	H   := "This is <b>BOLD</b> text"  ; Haystack
	B   := "<b>"                       ; Begin match
	E   := "</b>"                      ; End match
	P1  := InStr(H, B)                 ; Position of Begin match
	P2  := InStr(H, E)                 ; Position of End match
	Res := SubStr(H, P1:=P1+StrLen(B), P2-P1)
	MsgBox % Res

; xStr() can do both
	H := "This is <b>BOLD</b> text"   	; Haystack
	MsgBox % xStr(H,,,,12,4)                     	; Equivalent of SubStr(H,12,4)
	MsgBox % xStr(H,,"<b>","</b>")    	; Dynamic extraction

	MsgBox % SubStr("This is <b>BOLD</b> text", 12, 4) ; Returns "BOLD"

	return
; More importantly, you can mix both the methods.. just remember to ignore the parameters you don't require.
	;}

; ######################################################################################################
Usage_example1:
; ###################################################################################################### ;{
	H := "CornflowerBlue <b>#6495ED</b>, Cornsilk <b>#FFF8DC</b>, Crimson <b>#DC143C</b>."

	;       Example 1  :: xStr() works like SubStr() with BO,EO parameters
	MsgBox,,Example 1, % SubStr(H,19,7)
				. "`n" . xStr(H,,,,19,7) ; H,,,,BO,EO

	;       Example 2  :: Begin match is passed instead of Starting pos = 19
	MsgBox,,Example 2, % xStr(H,,"<b>",,,7) ; H,,B,,,EO

	;       Example 3  :: End match is passed instead of Length = 7
	MsgBox,,Example 3, % xStr(H,,,"</b>",19) ; H,,,E,BO

	;       Example 4  :: Begin match / End match is used instead of Starting pos / Length
	MsgBox,,Example 4, % xStr(H,,"<b>","</b>") ; H,,B,E

	;       Example 5  :: Second instance of <b> is matched because Begin instance = 2
	MsgBox,,Example 5, % xStr(H,,"<b>","</b>",,,2) ; H,,B,E,,,BI

	;       Example 6  :: Third instance  of <b> is matched because Begin instance = 3
	MsgBox,,Example 6, % xStr(H,,"<b>","</b>",,,3) ; H,,B,E,,,BI
	;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	/*
	 Parameter BO (Begin offset) is ByRef. When you pass a Var instead of value
	 then the var is updated with next Starting pos for every call.
	*/
	;       Example 7  :: Extract all between <b> and </b>
	P:=1  ; Starting pos / Begin offset
	T:= ""
	While V := xStr(H,,"<b>","</b>",P)  ; H,,B,E,BO
		T .= V "`n"
	MsgBox,,Example 7, % T

	return
	;}

; ######################################################################################################
Usage_example2:
; ###################################################################################################### ;{
	H := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	P:=1, V:="", T:=""
	While V := xStr(H,,,,P,4)
		T .= V "`n"
	MsgBox,% H "`n`nis sliced in to 4 char lines`n`n" T

	return
	;}

; ######################################################################################################
Usage_example3:
; ###################################################################################################### ;{
	H := "<p><a href='https://en.wikipedia.org/wiki/Romeo_and_Juliet'><b>Romeo &amp; Juliet</b></a></p>"

	;       Example 1  :: By default, xStr removes Begin match/End match strings from result
	MsgBox,,Example 1, % xStr(H,,"href='","'") ; H,,B,E

	;       Example 2  :: To retain match strings (B,E) in result pass 0 for parameters BT,ET (either or both)
	MsgBox,,Example 2, % xStr(H,,"href='","'",,,,,0,0) ; H,,B,E,,,,,BT,ET

	;       Example 3  :: To expand (Untrim) resulting string pass negative values as BT,ET (either or both)
	MsgBox,,Example 3, % xStr(H,,"href='","'",,,,,-3,-1) ; H,,B,E,,,,,BT,ET

	;       Example 4  :: To truncate (trim) resulting string pass positive values as BT,ET (either or both)
	MsgBox,,Example 4, % xStr(H,,"href='","'",,,,,14,1) ; H,,B,E,,,,,BT,ET

	/*
	Here follows a complicated example
	Target string length = 10
	End match is available and = "<br>" but no begin match to work with!
	Pass End match as Begin match and specify BT as -10 so that Starting pos will expand by 10 chars
	and the specify length (EO) as 10 to extract 10 chars from adjusted postion.
	*/

	H := "Jonathan 9841098410<br>Jane9841198411<br>Austin 9841298412<br>"
	MsgBox,,Example 5, % xStr(H,,"<br>",,,10,,,-10  )

	; When parameters B,E,BO,EO are omitted then parameters BT,ET can emulate
	; the deprecated StringTrimLeft and StringTrimRight commands

	H := "AutoHotkey", BT:=4, ET:=3
	MsgBox,,Example 6, % xStr(H,,,,,,,,BT  )  ; StringTrimLeft         = Hotkey
	MsgBox,,Example 7, % xStr(H,,,,,,,,,ET )  ; StringTrimRight        = AutoHot
	MsgBox,,Example 8, % xStr(H,,,,,,,,BT,ET) ; StringTrimLeftAndRight = Hot

	return
	;}

; ######################################################################################################
Usage_example4:
; ###################################################################################################### ;{
	H =
	(LTrim
	<!DOCTYPE html>
	<html>
	<body>
	<p><h1>Hello World</h1></p>

	<table border='1'>
	<tr><td>Table1Row1Col1</td><td>Table1Row1Col2</td><td>Table1Row1Col3</td></tr>
	<tr><td>Table1Row2Col1</td><td>Table1Row2Col2</td><td>Table1Row2Col3</td></tr>
	<tr><td>Table1Row3Col1</td><td>Table1Row3Col2</td><td>Table1Row3Col3</td></tr>
	<tr><td>Table1Row4Col1</td><td>Table1Row4Col2</td><td>Table1Row4Col3</td></tr>
	</table>
	&nbsp;
	<table border='1'>
	<tr><td>Table2Row1Col1</td><td>Table2Row1Col2</td><td>Table2Row1Col3</td></tr>
	<tr><td>Table2Row2Col1</td><td>Table2Row2Col2</td><td>Table2Row2Col3</td></tr>
	<tr><td>Table2Row3Col1</td><td>Table2Row3Col2</td><td>Table2Row3Col3</td></tr>
	<tr><td>Table2Row4Col1</td><td>Table2Row4Col2</td><td>Table2Row4Col3</td></tr>
	</table>
	&nbsp;
	<table border='1'>
	<tr><td>Table3Row1Col1</td><td>Table3Row1Col2</td><td>Table3Row1Col3</td></tr>
	<tr><td>Table3Row2Col1</td><td>Table3Row2Col2</td><td>Table3Row2Col3</td></tr>
	<tr><td>Table3Row3Col1</td><td>Table3Row3Col2</td><td>Needle is here</td></tr>
	<tr><td>Table3Row4Col1</td><td>Table3Row4Col2</td><td>Table3Row4Col3</td></tr>
	</table>
	</body>
	</html>
	)

	;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	; Example 1
	; Extract Table 3, Row 3,  Col 3
	MsgBox,,Example 1 | Table 3, % T := xStr(H,,"<table ","</table>",,,3,,0,0)   ; H,,B,E,,,BI,,BT,ET
	MsgBox,,Example 1 | Row 3,   % T := xStr(T,,"<tr>",   "</tr>",,,   3,,0,0)   ; H,,B,E,,,BI,,BT,ET
	MsgBox,,Example 1 | Col 3,   % T := xStr(T,,"<td>",   "</td>",,,   3     )   ; H,,B,E,,,BI

	; Example 2
	; Extract Table 2 and convert data to CSV
	T := xStr(H,,"<table ","</table>",,,2,,0,0) ; H,,B,E,,,BI,,BT,ET

	P := 1 ; Starting position
	CSV := "", Q := """", C := ",", LF := "`n"

	While (TR := xStr(T,,"<tr>","</tr>",P)) 	{
		N := 1 ; Starting position
		CSV .= Q . xStr(TR,,"<td>","</td>",N) . Q . C
			.  Q . xStr(TR,,"<td>","</td>",N) . Q . C
			.  Q . xStr(TR,,"<td>","</td>",N) . Q . LF
	}

	MsgBox,,Example 2 | CSV, % CSV

	return
	;}

; ######################################################################################################
Usage_example5:
; ###################################################################################################### ;{
	H =
	(LTrim
	Line_1
	Line_2
	Line_3
	Line_4
	Line_5
	Line_6
	Line_7
	Line_8
	Line_9
	)

	LF := "`n"
	; Note: When B and BO is omitted Starting Pos will be 1.

	MsgBox,,Example 1, % "Extract first line`n`n" .                      xStr(H,,,LF)          ; H,,,E
	MsgBox,,Example 2, % "Extract line 4`n`n" .                          xStr(H,,LF,LF,,,3)    ; H,,B,E,,,BI
	MsgBox,,Example 3, % "Extract line 5`n`n" .                          xStr(H,,LF,LF,,,4)    ; H,,B,E,,,BI
	MsgBox,,Example 4, % "Extract first two lines`n`n" .                 xStr(H,,,LF,,,,2)     ; H,,,E,,,EI

	; Note: When BO or EO is 0 InStr() will search for B or E from the right of haystack
	;       When EO is omitted,  EO will be Length of Haystack

	MsgBox,,Example 5, % "Extract last line`n`n" .                       xStr(H,,LF,,0)        ; H,,B,,BO
	MsgBox,,Example 6, % "Extract last 2 lines`n`n" .                    xStr(H,,LF,,0,,2)     ; H,,B,,BO,,BI
	MsgBox,,Example 7, % "Extract 2 lines preceding last line`n`n" .     xStr(H,,LF,LF,0,,3,2) ; H,,B,E,BO,,BI,EI
	MsgBox,,Example 8, % "Extract all lines except first and last`n`n" . xStr(H,,LF,LF,,0)     ; H,,B,E,,EO

	return
	;}

; ######################################################################################################
Usage_example6:
; ###################################################################################################### ;{
	rPath := A_AhkPath . "/../AutoHotkey.chm"                            ; Relative path
	H := Format("{:-260}", "")                                           ; Instead of VarSetCapacity(H,260)
	DllCall("GetFullPathName","Str",rPath, "UInt",260, "Str",H, "Ptr",0) ; Convert relative path to full path

	OutFileName  := xStr(H,,"\",,0)       ; H,,B,,BO
	OutDir       := xStr(H,,,"\",,0)      ; H,,,E,,EO
	OutExtension := xStr(H,,".",,0)       ; H,,B,,BO
	OutNameNoExt := xStr(H,,"\",".",0)    ; H,,B,E,BO
	OutDrive     := xStr(H,,,":",,,,,,0)  ; H,,,E,,,,,,ET

	MsgBox % OutFileName  . "`n"
		   . OutDir       . "`n"
		   . OutExtension . "`n"
		   . OutNameNoExt . "`n"
		   . OutDrive

	return

	;}

; ######################################################################################################
Real_World_Example1:
; ###################################################################################################### ;{
	URLDownloadToFile, http://www.floatrates.com/daily/usd.xml, usd.xml ; file size < 82 KiB
	FileRead, XML, usd.xml

	Pos := 1
	List := "USD currency rate as on:`n"
	List .= xStr(XML, 0, "<pubDate>","</pubDate>",Pos,,,,14) . "`n"            ; H,,B,E,BO,,,,BT

	While  Item := xStr(XML,,"<item>","</item>",Pos,,,,0,0)                    ; H,,B,E,BO,,,,BT,ET
	  {
		sPos := 1
	  , TC := xStr(Item,, "<targetCurrency>","</targetCurrency>",sPos)         ; H,,B,E,BO
	  , TN := xStr(Item,, "<targetName>",    "</targetName>",    sPos)         ; H,,B,E,BO
	  , TN := LTrim(SubStr(TN,1,25))
	  , EX := xStr(Item,, "<exchangeRate>",  "</exchangeRate>",  sPos)         ; H,,B,E,BO
	  , IN := xStr(Item,, "<inverseRate>",   "</inverseRate>",   sPos)         ; H,,B,E,BO
	  , List .= Format("`n{1:-27}`t1 {2:} = USD {3:}`t`t1 USD = {2:} {4:15}", TN,TC,IN,EX)
	  }

	FileDelete, usd.txt
	FileAppend, %List%, usd.txt
	Run Notepad usd.txt,,Max

	return
	;}

#include %A_ScriptDir%\..\xStr.ahk
