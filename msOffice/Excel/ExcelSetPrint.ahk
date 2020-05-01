#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance,off
SetBatchLines, -1
coordMode,mouse,screen
coordMode,pixel,screen
coordMode,tooltip,screen
SetTitleMatchMode,2
SetControlDelay,-1
#include <Acc>

;~ #include <Printer>

;~ printerStr:=GetInstalledPrinters()
;~ defaultPrinter:=GetDefaultPrinter()
;~ str=
;~ loop,parse,printerStr,|
;~ {
	;~ if !a_loopfield
		;~ continue
	;~ str.=a_loopfield
	;~ str.=(defaultPrinter=a_loopfield)?"||":"|"
;~ }

updateInterval=500
oExcel:=excel_get()
ComObjError(false)

gui +lastfound +AlwaysOnTop
guiHwnd:=WinExist()
gui,font,s8,Verdana
;~ gui,add,DropDownList,vprinter w300,% str

gui,add,text,,direction
gui,add,radio,yp xp+100 gchange,Straight
gui,add,radio,yp xp+50 gchange,Landscape
;~ gui,add,checkbox,yp xp+60 vlockorientation,Lock

gui,add,text,xs,straight
gui,add,dropdownlist,vpagewidth yp xp+100 w50 gchange,1|2|3|4|5|6|7|8|9|0
;~ gui,add,checkbox,yp xp+60 vlockpagewidth,Lock

gui,add,text,xs,Landscape
gui,add,dropdownlist,vpageheight yp xp+100 w50 gchange,1|2|3|4|5|6|7|8|9|0
;~ gui,add,checkbox,yp xp+60 vlockpageheight,Lock

gui,add,button,gA4 xs w90,A4
gui,add,button,gprintPreview yp xp+100 w90,orientation
gui,add,button,gprint xs w90,Print
gui,add,button,gprintAll yp xp+100 w90,All India

gui,add,radio,xs,Single-sided printing
gui,add,radio,yp xp+100 checked,Double-sided printing

gui,add,button,gprior xs w90,<
gui,add,button,gnext yp xp+100 w90,>



gui,show,w250 h200,Excel Print Setting


setTimer,update,% updateInterval
return

change:
gui,submit,nohide
if excelStatus() {
	oExcel:=Excel_Get()
	if (a_guicontrol="straight")
		oExcel.activeWorkBook.activeSheet.pageSetup.orientation:=1
	else if (a_guicontrol="Landscape")
		oExcel.activeWorkBook.activeSheet.pageSetup.orientation:=2
	else if (a_guicontrol="pagewidth" || a_guicontrol="pageheight")
		oExcel.activeWorkBook.activeSheet.pageSetup.Zoom:=comobj(0xB,0)
		,oExcel.activeWorkBook.activeSheet.pageSetup.FitToPagesWide:=pagewidth?comobj(3,pagewidth):comobj(0xB,0)
		,oExcel.activeWorkBook.activeSheet.pageSetup.FitToPagesTall:=pageheight?comobj(3,pageheight):comobj(0xB,0)
	;~ else if (a_guicontrol="pageheight")
		;~ oExcel.activeWorkBook.activeSheet.pageSetup.Zoom:=comobj(0xB,0)
		;~ ,oExcel.activeWorkBook.activeSheet.pageSetup.FitToPagesTall:=pageheight?comobj(3,pageheight):comobj(0xB,0)
}else{
	;~ winget,list,controllisthwnd,ahk_class XLMAIN
	;~ loop,parse,list,`n 
	;~ {
		;~ if (acc_objectfromWindow(a_loopfield).accName="版面設定")
			;~ controlclick,,ahk_id %a_loopfield%
			;~ ,break
	;~ }
	winactivate,ahk_class XLMAIN
	winwaitactive,ahk_class XLMAIN,,5
	if errorlevel
		return
	
	send !psp
	winwait,Layout setting ahk_class bosa_sdm_XL9,,5
	if errorlevel
		return
	if (a_guicontrol="直向")
		send {tab}t
	else if (a_guicontrol="橫向")
		send {tab}l
	else if (a_guicontrol="pagewidth")
		send {tab}f%pagewidth%
	else if (a_guicontrol="pageheight")
		send {tab}f{tab}%pageheight%
	send {enter}
}	
return



A4:
if excelstatus() {
	oExcel.activeWorkBook.activeSheet.pageSetup.paperSize:=9
	guicontrol,disable,A4
}else  {
	winactivate,ahk_class XLMAIN
	winwaitactive,ahk_class XLMAIN,,5
	if errorlevel
		return
	
	send !psp
	winwait,版面設定 ahk_class bosa_sdm_XL9,,5
	if errorlevel
		return
	send {tab}z
}
return

printPreview:
winactivate,ahk_class XLMAIN
winwaitactive,ahk_class XLMAIN,,5
if errorlevel
	return
if excelStatus() {
	;~ oExcel.activeWorkBook.activeSheet.printOut(comobjmissing(),comobjmissing(),comobjmissing(),comobj(0xB,-1))
	send ^{F2}
}else{
	send {esc}
}
return

print:
winactivate,ahk_class XLMAIN
winwaitactive,ahk_class XLMAIN,,5
if errorlevel
	return

if excelStatus() {
	send ^p
}else{
	send !pp
}
winwait,列印 ahk_class bosa_sdm_XL9,,5
if errorlevel
	return

gosub setDuplexPrint

return

printAll:
Msgbox,4,Print ALL !!,Are you sure?
IfMsgBox,No
	return
oExcel:=Excel_Get()
loop % (sh:=oExcel.activeWorkBook.sheets).count {
	winactivate,ahk_class XLMAIN
	sh.item(a_index).select()
	winwaitactive,ahk_class XLMAIN,,5
	if errorlevel
		return

	send ^p
	winwait,列印 ahk_class bosa_sdm_XL9,,5
	if errorlevel
		return

	gosub setDuplexPrint
	send {enter}
}
return

setDuplexPrint:
guicontrolget,duplexPrint,,雙面列印
send {tab}r
winwait,Properties #32770,,5
if errorlevel
	return

controlget,currentDuplexSetting,checked,,Button25,Properties #32770
if (duplexPrint^currentDuplexSetting)
	controlclick,Button25,Properties #32770
controlclick,Button38,Properties #32770
return


prior:
if !oExcel:=Excel_Get()
	return
winactivate,ahk_class XLMAIN
if (sheetIndex:=oExcel.activeWorkBook.activeSheet.index)=1
	oExcel.activeWorkBook.sheets.item(oExcel.activeWorkBook.sheets.count).activate
else
	oExcel.activeWorkBook.sheets.item(sheetIndex-1).activate
return

next:
if !oExcel:=Excel_Get()
	return
winactivate,ahk_class XLMAIN
if (sheetIndex:=oExcel.activeWorkBook.activeSheet.index)=oExcel.activeWorkBook.sheets.count
	oExcel.activeWorkBook.sheets.item(1).activate
else
	oExcel.activeWorkBook.sheets.item(sheetIndex+1).activate

return


update:
priorActiveW:=nowActiveW
winget,nowActiveW,id,A
if(priorActiveW!=nowActiveW)
	if(nowActiveW=guiHwnd)
		winset,Transparent,off,ahk_id %guiHwnd%
	else
		winset,Transparent,150,ahk_id %guiHwnd%


;~ oExcel:=ComObjActive("Excel.Application")
if !excelStatus()
	return
if !oExcel:=Excel_Get()
	return

if !((nowWb:=oExcel.activeWorkBook.name)=priorWb && (nowSh:=oExcel.activeWorkBook.activeSheet.name)=priorSh)
	;~ return
;~ else
	priorWb:=nowWb,priorSh:=nowSh

if ((pageSetup:=oExcel.activeWorkBook.activeSheet.pageSetup).orientation) 
	guicontrol,,直向,1
else
	guicontrol,,橫向,1

if !(PageSetup.Zoom) {
	guicontrol,choosestring,pageWidth,% pageSetup.FitToPagesWide
	guicontrol,choosestring,pageHeight,% pageSetup.FitToPagesTall
}else {
	guicontrol,choose,pageWidth,0
	guicontrol,choose,pageHeight,0
}

if (pageSetup.paperSize=9)
	guicontrol,disable,A4
else
	guicontrol,enable,A4

return


Excel_Get(WinTitle="ahk_class XLMAIN") {	; by Sean and Jethrow http://www.autohotkey.com/forum/viewtopic.php?p=492566#492566
	global excelHwnd
	ControlGet, hwnd, hwnd, , Excel71, %WinTitle%
	Window := Acc_ObjectFromWindow(hwnd, -16)
	Loop
		try
			Application := Window.Application
		catch {
 			ControlSend, Excel71, {esc}, %WinTitle%
			controlsend, ,{esc},ahk_class bosa_sdm_XL9
		}
	Until !!Application || a_index>10
	winget,excelHwnd,id,%wintitle%
	return Application
}

; 0 for print preview mode, 1 for others
; if excel is not accessible (eg. edit mode of cell), send tab and shift+tab
ExcelStatus(WinTitle="ahk_class XLMAIN"){
	ControlGet, hwnd, hwnd, , ExcelB1, %WinTitle%
	ret:=hwnd?0:1
	
	if (ret) {
		controlget,hwnd,hwnd,,Excel71,%wintitle%
		try 
			app:=Acc_ObjectFromWindow(hwnd, -16).Application
		catch 
			controlsend,,{tab}+{tab},ahk_id %hwnd%
	}
	return ret
}


#ifwinactive,Excel Print Setting ahk_class AutoHotkeyGUI
~^F2::
gosub printPreview
return

~^p::
gosub print
return

~left::
gosub prior
return

~right::
gosub next
return
#ifwinactive

guiclose:
;~ ~$esc::
;~ winactivate,SciTE
exitapp
return