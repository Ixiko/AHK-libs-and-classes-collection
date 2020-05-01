#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;###################################
; BarcodeCreator39PDF - GUI - by AHK_fan
;-----------------------------------
; v1	2018-12-12
; 
;-----------------------------------
; --> you need BC39_2PDF.ahk
; Function based on 	https://www.pdflabs.com/tools/gnu-barcode-plus-pdf/
;
; start with comamandline or with gui
; GUI:
; Select Size A4/A3, select Orientation Landscape/Portrait
; Select Barcodetext for BC39, allowed 0-9,A-Z, -, ., Space,*(Start/end), $, /, +, %
; Select Distance from Top and left in [mm], ZeroPoint in PDF is on left side and bottom in 
; select hight of Barcode in [mm]
; Select free text an Position
; Select modul (see here: https://de.wikipedia.org/wiki/Code_39
; If you want to create a stamp an an other PDF, select "Create Stamp", put in File Name to Source-PDF file and put in path to pdftk.exe (https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)
;			you need only file pdftk.exe, not PDFToolkit or samething else
; select FileName of Destination and also Path without \
;-----------------------------------
; Commandline:
; Create an Example-INI-File
; start with "barcodecreator39PDF.exe -ex"
; --> there will be created a file in Scriptdirectory with nam "paramex.ini" with stored parameter same as in GUI
; --> you can change the parameter and
; start with: barcodecreator39PDF.exe -f"pathtofile\paramex.ini"
; -----------------------------------
; Library BC39_2PDF.ahk
; use this as in this example explained:
; barcode := BC39_2PDF(BCText, BCHeight, KordXBC, KordYBC, PathNamePDF, FileNamePDF, TextString, KordXText, KordYText, TextHeight, TextWidth, Xmodul, NRatio, Orientation, PageSize, WriteFile, Overwrite, OpenMyFile, StampPDFTK, Path2ndPDF, PathPDFTK)
;###################################
#Include %A_ScriptDir%\lib
#Include, BC39_2PDF.ahk
;###################################
if A_Args.Length() < 1
{
		gosub, GuiStarten
}
else
{
	Loop, %0%  ; For each parameter:
	{
		param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
		;MsgBox, 4,, Parameter number %A_Index% is %param%.  Continue?
		ifInString param, -f
		{
			Length := StrLen(param)
			Konfigfile := SubStr(param, 3, Length)
			Konfigfile := StrReplace(Konfigfile, """") 
			IniRead, BCText, %Konfigfile%, input, BCText
			IniRead, BCHeight, %Konfigfile%, input, BCHeight, 15
			IniRead, KordXBC, %Konfigfile%, input, KordXBC, 10
			IniRead, KordYBC, %Konfigfile%, input, KordYBC, 50
			IniRead, PathNamePDF, %Konfigfile%, input, PathNamePDF, %A_Temp%
			IniRead, FileNamePDF, %Konfigfile%, input, FileNamePDF, test.pdf
			IniRead, TextString, %Konfigfile%, input, TextString, my text
			IniRead, KordXText, %Konfigfile%, input, KordXText, 50
			IniRead, KordYText, %Konfigfile%, input, KordYText, 50
			IniRead, TextHeight, %Konfigfile%, input, TextHeight, 8
			IniRead, TextWidth, %Konfigfile%, input, TextWidth, 8
			IniRead, Xmodul, %Konfigfile%, input, Xmodul, 0.5
			IniRead, NRatio, %Konfigfile%, input, NRatio, 3.6
			IniRead, Orientation, %Konfigfile%, input, Orientation, 1
			IniRead, PageSize, %Konfigfile%, input, PageSize, 1
			IniRead, WriteFile, %Konfigfile%, input, WriteFile, 1
			IniRead, Overwrite, %Konfigfile%, input, Overwrite, 1
			IniRead, OpenMyFile, %Konfigfile%, input, OpenMyFile, 0
			IniRead, StampPDFTK, %Konfigfile%, input, StampPDFTK, 0
			IniRead, Path2ndPDF, %Konfigfile%, input, Path2ndPDF,
			IniRead, PathPDFTK, %Konfigfile%, input, PathPDFTK, pdftk.exe
			barcode := BC39_2PDF(BCText, BCHeight, KordXBC, KordYBC, PathNamePDF, FileNamePDF, TextString, KordXText, KordYText, TextHeight, TextWidth, Xmodul, NRatio, Orientation, PageSize, WriteFile, Overwrite, OpenMyFile, StampPDFTK, Path2ndPDF, PathPDFTK)
			ExitApp
		}
		ifInString, param, -ex
		{
			ifExist, %A_ScriptDir%\paramex.ini
				FileDelete, %A_ScriptDir%\paramex.ini
			IniWrite, 1234560, %A_ScriptDir%\paramex.ini, input, BCText
			IniWrite, 15, %A_ScriptDir%\paramex.ini, input, BCHeight
			IniWrite, 10, %A_ScriptDir%\paramex.ini, input, KordXBC
			IniWrite, 50, %A_ScriptDir%\paramex.ini, input, KordYBC
			IniWrite, %A_Temp%, %A_ScriptDir%\paramex.ini, input, PathNamePDF
			IniWrite, test.pdf, %A_ScriptDir%\paramex.ini, input, FileNamePDF
			IniWrite, my text, %A_ScriptDir%\paramex.ini, input, TextString
			IniWrite, 10, %A_ScriptDir%\paramex.ini, input, KordXText
			IniWrite, 60, %A_ScriptDir%\paramex.ini, input, KordYText
			IniWrite, 8, %A_ScriptDir%\paramex.ini, input, TextHeight
			IniWrite, 8, %A_ScriptDir%\paramex.ini, input, TextWidth
			IniWrite, 0.5, %A_ScriptDir%\paramex.ini, input, Xmodul
			IniWrite, 3.6, %A_ScriptDir%\paramex.ini, input, NRatio
			IniWrite, 1, %A_ScriptDir%\paramex.ini, input, Orientation
			IniWrite, 1, %A_ScriptDir%\paramex.ini, input, PageSize
			IniWrite, 1, %A_ScriptDir%\paramex.ini, input, WriteFile
			IniWrite, 1, %A_ScriptDir%\paramex.ini, input, Overwrite
			IniWrite, 1, %A_ScriptDir%\paramex.ini, input, OpenMyFile
			IniWrite, 0, %A_ScriptDir%\paramex.ini, input, StampPDFTK
			IniWrite, 2.pdf, %A_ScriptDir%\paramex.ini, input, Path2ndPDF
			IniWrite, pdftk.exe, %A_ScriptDir%\paramex.ini, input, PathPDFTK
			
			ExitApp
		}
	}
}
return

GuiStarten:
Gui, Add, Radio, xm Section vRadioFormat1 checked group , A4
Gui, Add, Radio, ys , A3
Gui, Add, Radio, ys vRadioAusr1  checked group , Portrait
Gui, Add, Radio, ys , Landscape

gui, add, Text, xs Section w120, Barcodetext:
Gui, add, Edit, ys w180 vTextBarcode, 1234560
gui, add, text, xs Section h40 w120, Dist. BC from `n Top[mm]:
Gui, add, Edit, ys w30 number limit3 vKordYBC, 10
gui, add, text, ys w120 h40, Dist. BC from left`n[mm]:
Gui, add, Edit, ys w30 number limit3 vKordXBC, 50
gui, add, text, xs Section w120, Height Barcode:
Gui, add, Edit, ys w30 number limit2 vBarcodehoeheEdit, 15

gui, add, text, xs Section w120, Free Text:
Gui, add, Edit, ys w180 vFreierText, 1234560 Example
gui, add, text, xs Section w120 h40, Dist. from Top [mm]:
Gui, add, Edit, ys w30 number limit3 vKordYText, 10
gui, add, text, ys w120 h40, Dist. from left [mm]:
Gui, add, Edit, ys w30 number limit3 vKordXText, 50
gui, add, text, xs Section w120, Height Text:
Gui, add, Edit, ys w30 number limit2 vTextHeightEdit, 8
gui, add, text, ys w80, Letter dist.:
Gui, add, Edit, ys w30 number limit2 vTextWidthEdit, 6
gui, add, text, xs Section w100, Modul:
Gui, add, Edit, ys w80 limit3 vXmodul gOnChangeMyText, 0.5
gui, add, text, ys w100, Factor N:
Gui, add, Edit, ys w80 limit3 vNRatio gOnChangeMyText, 3.6

Gui, Add, Checkbox, xs Section vStampwithPDF, Create stamp?
gui, add, Text, ys w120, Path to 2. PDF:
Gui, add, Edit, ys w180 vTextPathto2PDF,

gui, add, Text, ys w120, Path to PDFTK:
Gui, add, Edit, ys w180 vTextPathPDFtk, pdftk.exe

gui, add, text, xs Section w120, File Name:
Gui, add, Edit, ys w180 vFileNamePDF, myfile.pdf
gui, add, text, xs Section w120, Path Name:
Gui, add, Edit, ys w180 vPathNamePDF, %A_Temp%



gui, add, button, xs Section w100 glosgehts, Start
gui, add, button, xs Section w100 gOeffnen, Open
gui, add, button, ys w100 gNeuLaden, Reload
gui, show, , BarcodeCreator
return

Neuladen:
reload
return

GuiClose:
ExitApp

OnChangeMyText:
	Gui, Submit, NoHide 
	if RegExMatch(MyText, "[^\d\.]|\..*\.|\.\d{3.}")
	{
		ControlGet, cursorPos, CurrentCol,, %MyText%, A 
		GuiControl, Text, MyText, %prevText% 
		cursorPos := cursorPos - 2 
		SendMessage, 0xB1, cursorPos, cursorPos,, ahk_id %hMyText% 
	}
	else
		prevText := MyText
	GuiControl, Text, TypedText, %MyText% 
return

losgehts:
gui, submit, nohide
ifExist, %PathNamePDF%\%FileNamePDF%
{
	msgbox, 20, BarcodeCreator, File Exist', overwrite?
	IfMsgBox, Yes
		FileDelete, %PathNamePDF%\%FileNamePDF%
	else
		return
}
barcode := BC39_2PDF(TextBarcode, BarcodehoeheEdit, KordXBC, KordYBC, PathNamePDF, FileNamePDF, FreierText, KordXText, KordYText, TextHeightEdit, TextWidthEdit, Xmodul, NRatio, RadioAusr1, RadioFormat1, 1, 1, 0, StampwithPDF, TextPathto2PDF, TextPathPDFtk)
return

Oeffnen:
gui, submit, nohide
run, %PathNamePDF%\%FileNamePDF%
return


