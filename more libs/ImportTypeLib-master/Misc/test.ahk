#NoEnv
#SingleInstance off
#Warn
#KeyHistory 0
SetBatchLines -1
ListLines Off

#include GetParamInfo.ahk
#include ..\
#include Main.ahk

try {
	;std := ImportTypeLib("C:\Program Files\Microsoft SDKs\Windows\v7.1\Lib\StdOle2.Tlb")
	;picDisp := ComObjCreate("StdPicture")

	;MsgBox % "Return value: " ITL_FormatError(std.StdFunctions.SavePicture("Ptr", ComObjUnwrap(picDisp), "Str", A_Desktop "\test.jpg", "Int")) " - " ErrorLevel " - " A_LastError

	UIAutomation := ImportTypeLib(A_WinDir "\System32\UIAutomationCore.dll")

	myArray := UIAutomation.tagRECT[3]

	struct := myArray[0]
	struct.left := 16

	rect := struct.Clone()
	rect.bottom := 42
	struct.top := 9

	list := "TreeScope:`n"
	for field, value in UIAutomation.TreeScope
		list .= "`tTreeScope." field " = " value "`n"
	list .= "`nOrientationType:`n"
	for field, value in UIAutomation.OrientationType
		list .= "`tOrientationType." field " = " value "`n"
	list .= "`nstruct (tagRECT):`n"
	for field, value in struct
		list .= "`tstruct." field " = " value "`n"
	list .= "`nrect (tagRECT):`n"
	for field, value in rect
		list .= "`trect." field " = " value "`n"
	MsgBox % "Enumeration and structure fields:`n`n" list

	automation := new UIAutomation.IUIAutomation(new UIAutomation.CUIAutomation())

	desktop := new UIAutomation.IUIAutomationElement(automation.GetRootElement())
	MsgBox % "The desktop:`n`n" GetElementInfo(desktop) "`n`nClick [OK] and wait 3 seconds."

	sleep 3000

	MouseGetPos,,,hwin

	request := new UIAutomation.IUIAutomationCacheRequest(automation.CreateCacheRequest())
	request.TreeScope := UIAutomation.TreeScope.Element|UIAutomation.TreeScope.Children
	cond := new UIAutomation.IUIAutomationCondition(automation.CreateFalseCondition())
	request.TreeFilter := cond
	MsgBox % "filter: " request.TreeFilter " == " cond[ITL.Properties.INSTANCE_POINTER]

	elem := new UIAutomation.IUIAutomationElement(automation.ElementFromHandleBuildCache(ComObjParameter(0x4000, hwin), request))
	MsgBox % "The window under the mouse:`n`n" GetElementInfo(elem)

	pt := new UIAutomation.tagPOINT(), pt.x := 400, pt.y := 400
	elem2 := automation.ElementFromPoint(pt)
	MsgBox % "The element at 400,400:`n`n" GetElementInfo(elem2)

} catch ex {
	MsgBox 4112, Exception!, % "An exception occured`n`tin """ ex.What """`n`tin file """ ex.File """`n`tat line " ex.Line "!`n`nMessage: " ex.Message "`n`nDetails: " ex.Extra
}

GetElementInfo(elem)
{
	global UIAutomation
	return "Process ID:`t"  elem.CurrentProcessId "`nWindow name:`t" elem.CurrentName "`nControl Class:`t" elem.CurrentClassName "`nUI Framework:`t" elem.CurrentFrameworkId
}