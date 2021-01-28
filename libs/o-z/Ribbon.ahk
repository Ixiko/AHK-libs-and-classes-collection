; Insert header here?

; Initializes the Ribbon library
Ribbon() {
	Global
	
	; Initialize COM
	DllCall("ole32\OleInitialize", "Uint", 0)
	
	;; UIRibbonFramework CLSIDs ;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; CLSID_UIRibbonFramework
	VarSetCapacity(CLSID_UIRibbonFramework, 16)
	NumPut(0x926749fa, CLSID_UIRibbonFramework, 0)
	NumPut(0x49872615, CLSID_UIRibbonFramework, 4)
	NumPut(0x3ec34588, CLSID_UIRibbonFramework, 8)
	NumPut(0x57b9f265, CLSID_UIRibbonFramework, 12)
	
	; IID_IUIRibbonFramework
	VarSetCapacity(IID_IUIRibbonFramework, 16)
	NumPut(0xf4f0385d, IID_IUIRibbonFramework, 0)
	NumPut(0x43a86872, IID_IUIRibbonFramework, 4)
	NumPut(0x334c09ad, IID_IUIRibbonFramework, 8)
	NumPut(0xc5f5b39c, IID_IUIRibbonFramework, 12)
	
	;; MCode IUnknown and IUIApplication implementations ;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; IUnknown::AddRef() and IUnknown::Release()
	VarSetCapacity(_Dummy_AddRef, 8)
	NumPut(0xc240c033, _Dummy_AddRef, 0)
	NumPut(0x00000004, _Dummy_AddRef, 4)
	
	; IUnknown::QueryInterface()
	VarSetCapacity(_Dummy_QueryIface, 8)
	NumPut(0xc0330889, _Dummy_QueryIface, 0)
	NumPut(0x00000cc2, _Dummy_QueryIface, 4)
	
	; IUIApplication::OnCreateUICommand
	VarSetCapacity(_Dummy_OnCreate, 20)
	NumPut(0x0424448b, _Dummy_OnCreate, 0)
	NumPut(0x10244c8b, _Dummy_OnCreate, 4)
	NumPut(0x891cc083, _Dummy_OnCreate, 8)
	NumPut(0xc2c03301, _Dummy_OnCreate, 12)
	NumPut(0x00000010, _Dummy_OnCreate, 16)
	
	; IUIApplication::OnDestroyUICommand
	VarSetCapacity(_Dummy_OnDestroy, 8)
	NumPut(0x004001b8, _Dummy_OnDestroy, 0)
	NumPut(0x0010c280, _Dummy_OnDestroy, 4)
}

; Creates a UIRibbonFramework object
UIRibbonFramework(ByRef out) {
	Global
	return DllCall("ole32\CoCreateInstance", "uint", &CLSID_UIRibbonFramework, "uint", 0, "uint", 1, "uint", &IID_IUIRibbonFramework, "uint*", out)
}

; Creates a ribbon
Ribbon_Create(hwnd, app) {
	if(UIRibbonFramework(obj) < 0)
		return 0
	if(DllCall(NumGet(NumGet(obj+0)+12), "uint", obj, "uint", hwnd, "uint", app) < 0)
		return 0
	return obj
}

; Loads ribbon markup from a resource
Ribbon_Load(obj, hmod, str) {
	return DllCall(NumGet(NumGet(obj+0)+20), "uint", obj, "uint", hmod, "uint", MyAnsiToUnicode(str,str))
}

; Frees a ribbon
Ribbon_Free(obj) {
	if(rc := DllCall(NumGet(NumGet(obj+0)+16), "uint", obj) < 0)
		return rc
	return _Ribbon_Release(obj)
}

_Ribbon_Release(obj) {
	return DllCall(NumGet(NumGet(obj+0)+8), "uint", obj)
}

; Creates a UIApplication object that the ribbon will speak to
RibbonApp_Create(OnView, OnProperty, OnExecute) {
	global _Dummy_AddRef, _Dummy_QueryIface, _Dummy_OnCreate, _Dummy_OnDestroy

	; Create the object
	st := DllCall("GlobalAlloc", "uint", 0, "uint", 52)
	
	; IUIApplication
	NumPut(st+4, st+0)
	NumPut(&_Dummy_QueryIface, st+4)
	NumPut(&_Dummy_AddRef, st+8)
	NumPut(&_Dummy_AddRef, st+12)
	NumPut(RegisterCallback(OnView), st+16)
	NumPut(&_Dummy_OnCreate, st+20)
	NumPut(&_Dummy_OnDestroy, st+24)
	
	; IUICommandHandler
	NumPut(st+32, st+28)
	NumPut(&_Dummy_QueryIface, st+32)
	NumPut(&_Dummy_AddRef, st+36)
	NumPut(&_Dummy_AddRef, st+40)
	NumPut(RegisterCallback(OnExecute), st+44)
	NumPut(RegisterCallback(OnProperty), st+48)

	return st
}

; Frees a UICommandHandler object
RibbonApp_Free(obj) {
	; Free the AutoHotkey callbacks
	DllCall("GlobalFree", "uint", NumGet(obj+16))
	DllCall("GlobalFree", "uint", NumGet(obj+44))
	DllCall("GlobalFree", "uint", NumGet(obj+48))
	; Free the object
	DllCall("GlobalFree", "uint", obj)
}

MyAnsiToUnicode(ByRef wString, sString, nSize = "") {
	if !A_IsUnicode
	{
		if nSize =
			nSize := DllCall("kernel32\MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wString, nSize*2 + 1)
		DllCall("kernel32\MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", &wString, "int", nSize+1)
		return &wString
	}else
	{
		wString := sString
		return &wString
	}
}
