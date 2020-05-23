#NoEnv

IFileDialogEvents_new(){
	vtbl := IFileDialogEvents_Vtbl()
	; VarSetCapacity apparently tries to emulate the peculiarities of stack allocation so use GlobalAlloc here
	fde := DllCall("GlobalAlloc", "UInt", 0x0000, "Ptr", A_PtrSize + 4, "Ptr") ; A_PtrSize to store the pointer to the vtable struct + sizeof unsigned int to store this object's refcount
	if (!fde)
		return 0

	NumPut(vtbl, fde+0,, "Ptr") ; place pointer to vtable in beginning of the IFileDialogEvents structure (you know how all this works from the other side)
	NumPut(1, fde+0, A_PtrSize, "UInt") ; Start with a refcount of one (thanks, just me)

	return fde
}

IFileDialogEvents_Vtbl(ByRef vtblSize := 0){
	/* This vtable approach is quite rigid and unflexible in its approach.
		I mean, ideally, you'd want each object to have its own set of methods that are called.
		With this, however, nope - same methods, just a different "this".

		I leave fixing that part up to you. I imagine it involves each object getting its own
		vtable (you could leave all the callback pointers inside the IFileDialogEvents struct after the vtable pointer)
		instead of sharing this one, with the functions to be called for each object determined at creation. Or something like that.
	*/
	static vtable ; This mustn't be freed automatically when it goes out of scope
	if (!VarSetCapacity(vtable)) {
		; Three IUnknown methods that must be implemented, along with the many methods IFileDialogEvents adds on top
		extfuncs := ["QueryInterface", "AddRef", "Release", "OnFileOk", "OnFolderChanging", "OnFolderChange", "OnSelectionChange", "OnShareViolation", "OnTypeChange", "OnOverwrite"]

		; Create IFileDialogEventsVtbl struct
		VarSetCapacity(vtable, extfuncs.Length() * A_PtrSize)

		for i, name in extfuncs
			NumPut(RegisterCallback("IFileDialogEvents_" . name), vtable, (i-1) * A_PtrSize)
	}
	if (IsByRef(vtblSize))
		vtblSize := VarSetCapacity(vtable)
	return &vtable
}

; Called on a "ComObjQuery"
IFileDialogEvents_QueryInterface(this_, riid, ppvObject){
	static IID_IUnknown, IID_IFileDialogEvents
	if (!VarSetCapacity(IID_IUnknown))
		VarSetCapacity(IID_IUnknown, 16), VarSetCapacity(IID_IFileDialogEvents, 16)
		,DllCall("ole32\CLSIDFromString", "WStr", "{00000000-0000-0000-C000-000000000046}", "Ptr", &IID_IUnknown)
		,DllCall("ole32\CLSIDFromString", "WStr", "{973510db-7d7f-452b-8975-74a85828d354}", "Ptr", &IID_IFileDialogEvents)

	; If someone calls our QI asking for IUnknown or IFileDialogEvents, then respond by:
	if (DllCall("ole32\IsEqualGUID", "Ptr", riid, "Ptr", &IID_IFileDialogEvents) || DllCall("ole32\IsEqualGUID", "Ptr", riid, "Ptr", &IID_IUnknown)) {
		NumPut(this_, ppvObject+0, "Ptr") ; filling in the pointer to a pointer with the address of this object
		IFileDialogEvents_AddRef(this_)
		return 0 ; S_OK
	}

	; Else
	NumPut(0, ppvObject+0, "Ptr") ; no object for the caller
	return 0x80004002 ; E_NOINTERFACE
}

; Called on an "ObjAddRef"
IFileDialogEvents_AddRef(this_){
	; get and increment our reference count member inside the IFileDialogEvents struct
	NumPut((_refCount := NumGet(this_+0, A_PtrSize, "UInt") + 1), this_+0, A_PtrSize, "UInt")
	return _refCount ; new refcount must be returned
}

; Called on an "ObjRelease"
IFileDialogEvents_Release(this_) {
	_refCount := NumGet(this_+0, A_PtrSize, "UInt") ; read current refcount from IFileDialogEvents struct
	if (_refCount > 0) {
		_refCount -= 1 ; decrease it
		NumPut(_refCount, this_+0, A_PtrSize, "UInt") ; store it
		if (_refCount == 0) ; if it's zero, then
			DllCall("GlobalFree", "Ptr", this_, "Ptr") ; it's time for this object to free itself
	}
	return _refCount ; new refcount must be returned
}

IFileDialogEvents_OnFileOk(this_, pfd){
	return 0x80004001 ; E_NOTIMPL ("[IFileDialogEvents] methods that are not implemented should return E_NOTIMPL.")
}

IFileDialogEvents_OnFolderChanging(this_, pfd, psiFolder){
	return 0x80004001 ; E_NOTIMPL
}

IFileDialogEvents_OnFolderChange(this_, pfd){
	return 0x80004001 ; E_NOTIMPL
}

IFileDialogEvents_OnSelectionChange(this_, pfd){
	if (DllCall(NumGet(NumGet(pfd+0)+14*A_PtrSize), "Ptr", pfd, "Ptr*", psi) >= 0) { ; IFileDialog::GetCurrentSelection
         GetDisplayName := NumGet(NumGet(psi + 0, "UPtr"), A_PtrSize * 5, "UPtr")
         If !DllCall(GetDisplayName, "Ptr", psi, "UInt", 0x80028000, "PtrP", StrPtr) { ; SIGDN_DESKTOPABSOLUTEPARSING
            SelectedFolder := StrGet(StrPtr, "UTF-16"), DllCall("Ole32.dll\CoTaskMemFree", "Ptr", StrPtr)
			ToolTip % SelectedFolder
		 }
		ObjRelease(psi)
	}
	return 0 ; S_OK
}

IFileDialogEvents_OnShareViolation(this_, pfd, psi, pResponse){
	return 0x80004001 ; E_NOTIMPL
}

IFileDialogEvents_OnTypeChange(this_, pfd){
	return 0x80004001 ; E_NOTIMPL
}

IFileDialogEvents_OnOverwrite(this_, pfd, psi, pResponse){
	return 0x80004001 ; E_NOTIMPL
}

; ---

SelectFolder(fde := 0) {
   ; Common Item Dialog -> msdn.microsoft.com/en-us/library/bb776913%28v=vs.85%29.aspx
   ; IFileDialog        -> msdn.microsoft.com/en-us/library/bb775966%28v=vs.85%29.aspx
   ; IShellItem         -> msdn.microsoft.com/en-us/library/bb761140%28v=vs.85%29.aspx
   Static OsVersion := DllCall("GetVersion", "UChar")
   Static Show := A_PtrSize * 3
   Static SetOptions := A_PtrSize * 9
   Static GetResult := A_PtrSize * 20
   SelectedFolder := ""
   If (OsVersion < 6) { ; IFileDialog requires Win Vista+
      FileSelectFolder, SelectedFolder
      Return SelectedFolder
   }
   If !(FileDialog := ComObjCreate("{DC1C5A9C-E88A-4dde-A5A1-60F82A20AEF7}", "{42f85136-db7e-439c-85f1-e4075d135fc8}"))
      Return ""
   VTBL := NumGet(FileDialog + 0, "UPtr")
   DllCall(NumGet(VTBL + SetOptions, "UPtr"), "Ptr", FileDialog, "UInt", 0x00000028, "UInt") ; FOS_NOCHANGEDIR | FOS_PICKFOLDERS

	if (fde) {
		DllCall(NumGet(NumGet(FileDialog+0)+7*A_PtrSize), "Ptr", FileDialog, "Ptr", fde, "UInt*", dwCookie := 0)
	}

	showSucceeded := DllCall(NumGet(VTBL + Show, "UPtr"), "Ptr", FileDialog, "Ptr", 0) >= 0

	if (dwCookie)
		DllCall(NumGet(NumGet(FileDialog+0)+8*A_PtrSize), "Ptr", FileDialog, "UInt", dwCookie)

   If (showSucceeded) {
	   If !DllCall(NumGet(VTBL + GetResult, "UPtr"), "Ptr", FileDialog, "PtrP", ShellItem, "UInt") {
         GetDisplayName := NumGet(NumGet(ShellItem + 0, "UPtr"), A_PtrSize * 5, "UPtr")
         If !DllCall(GetDisplayName, "Ptr", ShellItem, "UInt", 0x80028000, "PtrP", StrPtr) ; SIGDN_DESKTOPABSOLUTEPARSING
            SelectedFolder := StrGet(StrPtr, "UTF-16"), DllCall("Ole32.dll\CoTaskMemFree", "Ptr", StrPtr)
         ObjRelease(ShellItem)
      }
   }

   ObjRelease(FileDialog)
   Return SelectedFolder
}

if ((fde := IFileDialogEvents_new())) {
	MsgBox % SelectFolder(fde)
	ObjRelease(fde)
}