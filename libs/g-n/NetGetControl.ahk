;#include <COM>
#include %A_ScriptDir%\RemoteScintilla.ahk
listAccChildProperty(hwnd){
	COM_AccInit()
	If	pacc :=	COM_AccessibleObjectFromWindow(hWnd)
	{
		;~ VarSetCapacity(l,4),VarSetCapacity(t,4),VarSetCapacity(w,4),VarSetCapacity(h,4)
		;~ COM_Invoke(pacc,"accLocation",l,t,w,h,0)
		;~ a:=COM_Invoke(pacc,"accParent")

		sResult	:="[Window]`n"
			. "Name:`t`t"		COM_Invoke(pacc,"accName",0) "`n"
			. "Value:`t`t"			COM_Invoke(pacc,"accValue",0) "`n"
			. "Description:`t"	COM_Invoke(pacc,"accDescription",0) "`n"
			. COM_Invoke(pacc,"accDefaultAction",0) "`n"
			. COM_Invoke(pacc,"accHelp",0) "`n"
			. COM_Invoke(pacc,"accKeyboardShortcut",0) "`n"
			. COM_Invoke(pacc,"accRole",0) "`n"
			. COM_Invoke(pacc,"accState",0) "`n"


		Loop, %	COM_AccessibleChildren(pacc, COM_Invoke(pacc,"accChildCount"), varChildren)
			If	NumGet(varChildren,16*(A_Index-1),"Ushort")=3 && idChild:=NumGet(varChildren,16*A_Index-8)
				sResult	.="[" A_Index "]`n"
					. "Name:`t`t"		COM_Invoke(pacc,"accName",idChild) "`n"
					. "Value:`t`t"	    	COM_Invoke(pacc,"accValue",idChild) "`n"
					. "Description:`t"	COM_Invoke(pacc,"accDescription",idChild) "`n"
					. COM_Invoke(pacc,"accParent",idChild) "`n"

			Else If	paccChild:=NumGet(varChildren,16*A_Index-8) {
				sResult	.="[" A_Index "]`n"
					. "Name:`t`t"		COM_Invoke(paccChild,"accName",0) "`n"
					. "Value:`t`t"	    	COM_Invoke(paccChild,"accValue",0) "`n"
					. "Description:`t"	COM_Invoke(paccChild,"accDescription",0) "`n"
				if a_index=3
				{
					numput(1,var,"UInt")
					COM_Invoke(pacc,"accSelect",1,paccChild)
				}
				 COM_Release(paccChild)
			}
		COM_Release(pacc)
	}
	COM_AccTerm()

	return sResult
}

getControlNameByHwnd(winHwnd,controlHwnd){
	bufSize=1024
	winget,processID,pid,ahk_id %winHwnd%
	VarSetCapacity(var1,bufSize)
	getName:=DllCall( "RegisterWindowMessage", "str", "WM_GETCONTROLNAME" )
	dwResult:=DllCall("GetWindowThreadProcessId", "UInt", winHwnd)
	hProcess:=DllCall("OpenProcess", "UInt", 0x8 | 0x10 | 0x20, "Uint", 0, "UInt", processID)
	otherMem:=DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "PTR", bufSize, "UInt", 0x3000, "UInt", 0x0004, "Ptr")

	SendMessage,%getName%,%bufSize%,%otherMem%,,ahk_id %controlHwnd%
	DllCall("ReadProcessMemory","UInt",hProcess,"UInt",otherMem,"Str",var1,"UInt",bufSize,"UInt *",0)
	DllCall("CloseHandle","Ptr",hProcess)
	DllCall("VirtualFreeEx","Ptr", hProcess,"UInt",otherMem,"UInt", 0, "UInt", 0x8000)
	return var1

}

; search by control name
; return hwnd
getByControlName(winHwnd,name){
	winget,controlList,controlListhwnd,ahk_id %winHwnd%
    arr:=[]
    ,bufSize=1024
	winget,processID,pid,ahk_id %winHwnd%
	VarSetCapacity(var1,bufSize)
	if !(getName:=DllCall( "RegisterWindowMessage", "str", "WM_GETCONTROLNAME" ))
        return []
	if !(dwResult:=DllCall("GetWindowThreadProcessId", "UInt", winHwnd))
        return []
	if !(hProcess:=DllCall("OpenProcess", "UInt", 0x8 | 0x10 | 0x20, "Uint", 0, "UInt", processID))
        return []
    if !(otherMem:=DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "PTR", bufSize, "UInt", 0x3000, "UInt", 0x0004, "Ptr"))
        return []

	loop,parse,controlList,`n
	{
        SendMessage,%getName%,%bufSize%,%otherMem%,,ahk_id %a_loopfield%
        if errorlevel=FAIL
            return []
        if !DllCall("ReadProcessMemory","UInt",hProcess,"UInt",otherMem,"Str",var1,"UInt",bufSize,"UInt *",0)
            return []
        if (var1=name)
            arr.insert(a_loopfield)
            ,var1:=""
	}

    DllCall("VirtualFreeEx","Ptr", hProcess,"UInt",otherMem,"UInt", 0, "UInt", 0x8000)
	DllCall("CloseHandle","Ptr",hProcess)
    return arr
}

controlGetText(hwnd){
	if IsObject(hwnd) {
		if (hwnd.__Class="Scintilla") {
			Text:=""
			if (len:=hwnd.GetTextLength())>0
				hwnd.GetText(hwnd.GetTextLength()+1, Text)
		}else if (hwnd.__Class="RemoteScintilla"){
			Text:=hwnd.GetText()
		}
		return Text
	}

	WinGetClass,class,ahk_id %hwnd%
	if (class="scintilla") {
		hwnd:=new RemoteScintilla(hwnd)
		return hwnd.GetText()
	}else {
		controlgettext,t,,ahk_id %hwnd%
	}
	return t
}

winGetClass(hwnd){
	WinGetClass,cl,ahk_id %hwnd%
	return cl
}

getNetAcc(winHwnd,controlName,classNN,shift=0,acc=true,name="",text=""){
	if acc
		return acc_objectfromwindow(getNetControl2(winHwnd,text,controlName,name,classNN,"","","",shift)[1])
	else
		return getNetControl2(winHwnd,text,controlName,name,classNN,"","","",shift)[1]
}

;getNetControl2(syngoViaState[2],"","myHostedTextbox","","WindowsForms10.EDIT","","","",0)[1]
;~ getSyngoCommonContainerWindows(){
		;~ winget,list,list,ahk_exe syngo.Common.Container.exe
		;~ arr:=[]
		;~ loop % list
			;~ arr.insert(list%a_index%)
		;~ return arr
	;~ }
;~ getNetAcc(getSyngoCommonContainerWindows(),"OncologyTask_CP_Oncology@ShowHideLungCAD","Button",0,0)
getNetControl2(winHwnd,text="",controlName="",accName="",classNN="",accHelp="",accRole="",style="",shift=0, result=""){
	if !isobject(result)
		result:=[]

	if isobject(winHwnd){

		for k,v in winHwnd
			result:=getNetControl2(v,text,controlName,accName,classNN,accHelp,accRole,style,shift,result)
		return result
	}

	winget,list,controllisthwnd,ahk_id %winHwnd%
	arr:=[],controlArr:=[]
	loop,parse,list,`n
	{
		controlArr.insert(a_loopfield)
		if (text="" || instr(controlgettext(a_loopfield),text)) && (classNN="" || instr(winGetClass(a_loopfield),classNN)) && (controlName="" || getControlNameByHwnd(winHwnd,a_loopfield)=controlName) && (accName="" || instr((acc:=acc_objectfromwindow(a_loopfield)).accName,accName)) && (accHelp="" || instr(acc.accHelp,accHelp)) && (accRole="" || instr(acc.accRole,accRole)) && (!style || DllCall("GetWindowLong",UInt,a_loopfield,Int,-16)=style)
			arr[a_index]:=a_loopfield
	}
	;~ result:=[]

	for k,v in arr
		if (r:=controlArr[k+shift])
			result.insert(r)

	return result
}

getNetControlGlobal(text="",controlName="",accName="",classNN="",accHelp="",accRole="",style="",shift=0){
	ret:=[],win=[]
	DetectHiddenWindows,on
	winget,lst,list
	loop % lst {
		winhwnd:=lst%a_index%
		a:=getNetControl2(winHwnd,text,controlName,accName,classNN,accHelp,accRole,style,shift)
		if (a.maxindex()){
			for k,v in a
				ret.insert(v)
			b:=[]
			b["" winHwnd]:=a
			win.insert(b)
		}
	}
	return [ret,win]
}

; search for specific control
; return hwnd
getNetControl(winHwnd,controlName="",accName="",classNN="",accHelp=""){
	winget,list,controllisthwnd,ahk_id %winHwnd%

	bufSize=1024
	winget,processID,pid,ahk_id %winHwnd%
	VarSetCapacity(var1,bufSize)
	getName:=DllCall( "RegisterWindowMessage", "str", "WM_GETCONTROLNAME" )
	dwResult:=DllCall("GetWindowThreadProcessId", "UInt", winHwnd)
	hProcess:=DllCall("OpenProcess", "UInt", 0x8 | 0x10 | 0x20, "Uint", 0, "UInt", processID)
	otherMem:=DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "PTR", bufSize, "UInt", 0x3000, "UInt", 0x0004, "Ptr")

	count=0
	;~ static hModule := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")
	;~ static hModule2 := DllCall("LoadLibrary", "Str", "Kernel32", "Ptr")
	;~ static AccessibleObjectFromWindowProc := DllCall("GetProcAddress", Ptr, DllCall("GetModuleHandle", Str, "oleacc", "Ptr"), AStr, "AccessibleObjectFromWindow", "Ptr")
	;~ static ReadProcessMemoryProc:=DllCall("ReadProcessMemory", Ptr, DllCall("GetModuleHandle", Str, "Kernel32", "Ptr"), AStr, "AccessibleChildren", "Ptr")
	;~ msgbox % AccessibleObjectFromWindowProc
	;~ static idObject:=-4
	loop,parse,list,`n
	{
		SendMessage,%getName%,%bufSize%,%otherMem%,,ahk_id %a_loopfield%
        DllCall("ReadProcessMemory","UInt",hProcess,"UInt",otherMem,"Str",var1,"UInt",bufSize,"UInt *",0)

		;~ acc:=acc_objectfromwindow2(a_loopfield)

		;~ if !DllCall(AccessibleObjectFromWindowProc, "Ptr", a_loopfield, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)
			;~ acc:=ComObjEnwrap(9,pacc,1)
		;~ else
			;~ acc:=""




	;&&(accParentHwnd=""||acc_windowfromobject(acc.accParent)=accParentHwnd)
		if ((var1&&var1=controlName)&&(accName=""||(acc:=Acc_ObjectFromWindow(a_loopfield)).accName=accName)){
			WinGetClass,cl,ahk_id %a_loopfield%
			if(instr(cl,classNN)=1&&(accHelp=""||acc.accHelp=accHelp)) {
				ret:=a_loopfield
				break
			}
		}

		var1:=""
	}

    DllCall("VirtualFreeEx","Ptr", hProcess,"UInt",otherMem,"UInt", 0, "UInt", 0x8000)
	DllCall("CloseHandle","Ptr",hProcess)
	DllCall("FreeLibrary", "Ptr", hModule)
	return ret

}

;~ clipboard:=getControlDescription(0x27048E,0x680532)
;~ clipboard:=getControlDescription(0x3e0784,0x380CA4)
getControlDescription(winHwnd,controlHwnd){
	return "getNetControl2(RisState[2],""" controlgettext(controlHwnd) """,""" getControlNameByHwnd(winHwnd,controlHwnd) """,""" (acc:=acc_objectfromwindow(controlHwnd)).accName """,""" winGetClass(controlHwnd) """,""" acc.accHelp """,""" acc.accRole """,""" DllCall("GetWindowLong",UInt,controlHwnd,Int,-16) """,0)"
}

