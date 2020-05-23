;===============================================
/* ObjCSV Demo Advanced v0.1
Written using AutoHotkey_L v1.1.09.03 (http://l.autohotkey.net/)
By JnLlnd on AHK forum
2013-08-22+
*/

/*
Make sure that the libray ObjCSV.ahk in copied in one of these folders:
  %A_ScriptDir%\Lib\
  %A_MyDocuments%\AutoHotkey\Lib\
  path-to-the-currently-running-AutoHotkey.exe\Lib\

The ObjCSV.ahk library can be downloaded here:
https://raw.github.com/JnLlnd/ObjCSV/master/Lib/ObjCSV.ahk

Also, download a copy of the CSV file "TheBeatles.txt" and save it in the script directory:
https://raw.github.com/JnLlnd/ObjCSV/master/TheBeatles.txt
*/

#NoEnv
#SingleInstance


; Gui creation
Gui, One:New, +Resize, One
Gui, One:Default
Gui, Add, Button, x10 Default gButtonLoadFileOneA, Load #1A
Gui, Add, Button, x110 yp gButtonSaveFileOneA vButtonSaveFileOneA, Save #1A
Gui, Add, Button, x310 yp gButtonLoadFileOneB, Load #1B
Gui, Add, Button, x680 yp gOneGuiClose, Quit #1
Gui, Add, ListView, x10 r20 w650 -ReadOnly vLVOne
GuiControl, Disable, ButtonSaveFileOneA
Gui, One:Show, x50 y20 Autosize
blnOneExist := true

Gui, Two:New, -Resize, Two
Gui, Two:Default
Gui, Add, Button, x10 Default gButtonLoadFileTwoA vButtonLoadFileTwoA, Load #2A
Gui, Add, Button, x110 yp gButtonSaveFileTwoA vButtonSaveFileTwoA, Save #2A
Gui, Add, Button, x380 yp gButtonLoadFileTwoB vButtonLoadFileTwoB, Load #2B
Gui, Add, Button, x480 yp gButtonSaveFileTwoB vButtonSaveFileTwoB, Save #2B
Gui, Add, Button, x690 yp gTwoGuiClose, Quit #2
Gui, Add, ListView, vLVTwoA x10 r20 w360
Gui, Add, ListView, vLVTwoB x380 yp r20 w360
GuiControl, Disable, ButtonLoadFileTwoA
GuiControl, Disable, ButtonSaveFileTwoA
GuiControl, Disable, ButtonLoadFileTwoB
GuiControl, Disable, ButtonSaveFileTwoB
intX := (A_ScreenWidth // 2) + 50
Gui, Two:Show, x%intX% y20 Autosize
blnTwoExist := true

return


ButtonLoadFileOneA:
Gui, ListView, LVOne
strFields := ""
obj := ObjCSV_CSV2Collection(A_ScriptDir . "\TheBeatles.txt", strFields, 1, 1, 1)
LV_Delete()
ObjCSV_Collection2ListView(obj, "One", "LVOne", "str_Name,str_Album,str_Genre,lng_Total_Time", , , "str_Album+str_Name", , 1)
Gui, ListView, LVOne
LV_ModifyCol(4, "Integer")
intWidth := 690
LV_ModifyCol(1, intWidth * 0.35)
LV_ModifyCol(2, intWidth * 0.35)
LV_ModifyCol(3, intWidth * 0.15)
LV_ModifyCol(4, intWidth * 0.15)
GuiControl, Enable, ButtonSaveFileOneA
MsgBox, File "TheBeatles.txt" loaded
return


ButtonSaveFileOneA:
strFile := A_ScriptDir . "\TheBeatles-LVOne-Semi-colon-Apostrophe.txt"
obj := ObjCSV_ListView2Collection("One", "LVOne", , , , 1)
ObjCSV_Collection2CSV(obj, strFile, 1, "str_Name;str_Album;str_Genre;lng_Total_Time", 1, 1, ";", "'")
GuiControl, Two:Enable, ButtonLoadFileTwoA
Gosub, FileSaved
return


ButtonLoadFileOneB:
Gui, ListView, LVOne
LV_Delete()
strFields := ""
obj := ObjCSV_CSV2Collection(A_ScriptDir . "\TheBeatles-LOVE.txt", strFields, 1, 1, 1)
ObjCSV_Collection2ListView(obj, "One", "LVOne", "str_Name,str_Album,str_Genre,lng_Total_Time", , , "str_Name", , 1)
Gui, ListView, LVOne
LV_ModifyCol(4, "Integer")
intWidth := 690
LV_ModifyCol(1, intWidth * 0.35)
LV_ModifyCol(2, intWidth * 0.35)
LV_ModifyCol(3, intWidth * 0.15)
LV_ModifyCol(4, intWidth * 0.15)
GuiControl, Disable, ButtonSaveFileOneA
MsgBox, File "TheBeatles-LOVE.txt" loaded
return


ButtonLoadFileTwoA:
strFile := A_ScriptDir . "\TheBeatles-LVOne-Semi-colon-Apostrophe.txt"
strFields := ""
obj := ObjCSV_CSV2Collection(strFile, strFields, 1, , ,";", "'")
ObjCSV_Collection2ListView(obj, "Two", "LVTwoA", "str_Name,str_Album,lng_Total_Time")
Gui, ListView, LVTwoA
LV_ModifyCol(3, "Integer")
intWidth := 335
LV_ModifyCol(1, intWidth * 0.4)
LV_ModifyCol(2, intWidth * 0.4)
LV_ModifyCol(3, intWidth * 0.2)
GuiControl, Enable, ButtonSaveFileTwoA
MsgBox, File "TheBeatles-LVOne-Semi-colon-Apostrophe.txt" loaded
return


ButtonSaveFileTwoA:
strFile := A_ScriptDir . "\TheBeatles-LVTwoA-NoHeader.txt"
obj := ObjCSV_ListView2Collection("Two", "LVTwoA")
ObjCSV_Collection2CSV(obj, strFile, 0, "str_Name,str_Album,lng_Total_Time", , 1)
GuiControl, Enable, ButtonLoadFileTwoB
Gosub, FileSaved
return


ButtonLoadFileTwoB:
strFile := A_ScriptDir . "\TheBeatles-LVTwoA-NoHeader.txt"
strFields := "Name,Album,Duration"
obj := ObjCSV_CSV2Collection(strFile, strFields, 0)
ObjCSV_Collection2ListView(obj, "Two", "LVTwoB", "Name,Album,Duration", , , "Duration", "N R")
Gui, ListView, LVTwoB
LV_ModifyCol(3, "Integer")
LV_ModifyCol(4, "Integer")
intWidth := 335
LV_ModifyCol(1, intWidth * 0.4)
LV_ModifyCol(2, intWidth * 0.4)
LV_ModifyCol(3, intWidth * 0.2)
GuiControl, Enable, ButtonSaveFileTwoB
MsgBox, File "TheBeatles-LVTwoA-NoHeader.txt" loaded
return


ButtonSaveFileTwoB:
strFile := A_ScriptDir . "\TheBeatles-LVTwoB-Tab.txt"
obj := ObjCSV_ListView2Collection("Two", "LVTwoB")
ObjCSV_Collection2CSV(obj, strFile, 1, , , 1, "`t")
Gosub, FileSaved
return


OneGuiSize:  ; Expand or shrink the ListView in response to the user's resizing of the window.
if A_EventInfo = 1  ; The window has been minimized.  No action needed.
    return
; Otherwise, the window has been resized or maximized. Resize the ListView to match.
GuiControl, Move, LVOne, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 40)
intWidth := A_GuiWidth - 40
LV_ModifyCol(1, intWidth * 0.35)
LV_ModifyCol(2, intWidth * 0.35)
LV_ModifyCol(3, intWidth * 0.15)
LV_ModifyCol(4, intWidth * 0.15)
return


OneGuiClose:
Gui, One:Destroy
if !(blnTwoExist)
	ExitApp
blnOneExist := false
return


TwoGuiClose:
Gui, Two:Destroy
if !(blnOneExist)
	ExitApp
blnTwoExist := false
return


FileSaved:
MsgBox, 4, Display file?, File saved:`n`n%strFile%`n`nDisplay file?
IfMsgBox, Yes
	Run %strFile%
