class VirtualDesktopManagerClass
{
	__new()
	{	
		debugger("creating th vdm")
		;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186440(v=vs.85).aspx
		CLSID := "{aa509086-5ca9-4c25-8f95-589d3c07b48a}" ;search VirtualDesktopManager clsid
		IID := "{a5cd92ff-29be-454c-8d04-d82879fb3f1b}" ;search IID_IVirtualDesktopManager
		this.iVirtualDesktopManager := ComObjCreate(CLSID, IID)
		
		this.isWindowOnCurrentVirtualDesktopAddress := NumGet(NumGet(this.iVirtualDesktopManager+0), 3*A_PtrSize)
		this.getWindowDesktopIdAddress := NumGet(NumGet(this.iVirtualDesktopManager+0), 4*A_PtrSize)
		this.moveWindowToDesktopAddress := NumGet(NumGet(this.iVirtualDesktopManager+0), 5*A_PtrSize)
		
		return this
	}
	
	getWindowDesktopId(hWnd, tryAgain := true) 
	{
		desktopId := ""
		VarSetCapacity(desktopID, 16, 0)
		;IVirtualDesktopManager::GetWindowDesktopId  method
		;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186441(v=vs.85).aspx
 
		Error := DllCall(this.getWindowDesktopIdAddress, "Ptr", this.iVirtualDesktopManager, "Ptr", hWnd, "Ptr", &desktopID)	
		if(Error != 0) {
			if(tryAgain) 
			{
				return this.getWindowDesktopId(hwnd, false)
			}
			msgbox % "error in getWindowDesktopId " Error
			clipboard := error
		}
 
		return &desktopID
	}
	
	getDesktopGuid(hwnd)
	{
		debugger("getting the guid")
		return this._guidToStr(this.getWindowDesktopId(hwnd))
	}
	; https://github.com/cocobelgica/AutoHotkey-Util/blob/master/Guid.ahk#L36
	_guidToStr(ByRef VarOrAddress)
	{
		;~ debugger(&VarOrAddress " address")
		pGuid := IsByRef(VarOrAddress) ? &VarOrAddress : VarOrAddress
		VarSetCapacity(sGuid, 78) ; (38 + 1) * 2
		if !DllCall("ole32\StringFromGUID2", "Ptr", pGuid, "Ptr", &sGuid, "Int", 39)
			throw Exception("Invalid GUID", -1, Format("<at {1:p}>", pGuid))
		return StrGet(&sGuid, "UTF-16")
	}
	
	
	isDesktopCurrentlyActive(hWnd) 
	{
		;IVirtualDesktopManager::IsWindowOnCurrentVirtualDesktop method
		;Indicates whether the provided window is on the currently active virtual desktop.
		;https://msdn.microsoft.com/en-us/library/windows/desktop/mt186442(v=vs.85).aspx
		Error := DllCall(this.isWindowOnCurrentVirtualDesktopAddress, "Ptr", this.iVirtualDesktopManager, "Ptr", hWnd, "IntP", onCurrentDesktop)
		if(Error != 0) {
			msgbox % "error in isDesktopCurrentlyActive " Error
			clipboard := error
		}

		return onCurrentDesktop
	}
	
	moveWindowToDesktop(hWnd, ByRef desktopId)
	{
		Error := DllCall(this.moveWindowToDesktopAddress, "Ptr", this.iVirtualDesktopManager, "Ptr", activeHwnd, "Ptr", &desktopId)
		if(Error != 0) {
			msgbox % "error in moveWindowToDesktop " Error "but no error?"
			clipboard := error
		}
		return this
	}
}