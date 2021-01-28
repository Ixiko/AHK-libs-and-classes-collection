; Link:   	https://www.autohotkey.com/boards/viewtopic.php?style=17&t=64491&p=276956
; Author:
; Date:
; for:     	AHK_L

/*


*/

caretViaAcc() { ; based on 'caret - get information via Acc' sample subroutine by jeeswg (cf. https://www.autohotkey.com/boards/viewtopic.php?f=5&t=39615)
	static OBJID_CARET := -8
	static _h := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")
	local vCtlClassNN, hCtl
	ControlGetFocus, vCtlClassNN, A
	ControlGet, hCtl, Hwnd,, % vCtlClassNN, A
return Acc_Location(Acc_ObjectFromWindow(hCtl, OBJID_CARET)).x
}
; relevant functions extracted from acc.ahk (cf. https://github.com/Drugoy/Autohotkey-scripts-.ahk/blob/master/Libraries/Acc.ahk); note: for convinience Acc is loaded @ caretViaAcc
Acc_ObjectFromWindow(hWnd, idObject:=-4) {
local IID, pacc := ""
if (DllCall("oleacc\AccessibleObjectFromWindow","Ptr",hWnd,"UInt",idObject&=0xFFFFFFFF,"Ptr",-VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"),"Ptr*",pacc)=0)
	return ComObjEnwrap(9,pacc,1)
}
Acc_Location(acc, childId:=0, ByRef position:="") {
	try acc.accLocation(ComObj(0x4003,&x:=0),ComObj(0x4003,&y:=0),ComObj(0x4003,&w:=0),ComObj(0x4003,&h:=0),childId)
	catch
		return
	position := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
	return {x:NumGet(x,0,"int"), y:NumGet(y,0,"int"), w:NumGet(w,0,"int"), h:NumGet(h,0,"int")}
}