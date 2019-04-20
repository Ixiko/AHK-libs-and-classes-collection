class JPGIncDllWindowMover
{
	static 32BitPID
	static 64BitPID
	
	__new()
	{
		debugger("starting the dll window mover")
		this._startUpDllInjectors()
		return this
	}
	
	_startUpDllInjectors()
	{
		if(JPGIncDllWindowMover.32BitPID || JPGIncDllWindowMover.64BitPID)
		{
			debugger("the scripts to run the dll's are already running")
			;can only have one instance of the dll injectors
			return
		}
		
		myPID := DllCall("GetCurrentProcessId")
		run, AutoHotkeyU32.exe "injection dll/dllCaller.ahk" "%myPID%" "32", , useerrorlevel, 32BitPID
		if(ErrorLevel == "ERROR")
		{
			debugger("There was an error running the 32 bit dll injector!`nWindows error code is: " A_LastError)
		}
		
		run, AutoHotkeyU64.exe "injection dll/dllCaller.ahk" %myPID% 64, , useerrorlevel, 64BitPID
		if(ErrorLevel == "ERROR")
		{
			debugger("There was an error running the 64 bit dll injector!`nWindows error code is: " A_LastError)
		}
		
		debugger( "32 bit pid is " 32BitPID "`n64bit pid is " 64BitPID)
		JPGIncDllWindowMover.32BitPID := 32BitPID
		JPGIncDllWindowMover.64BitPID := 64BitPID
		return
	}
	
	isAvailable()
	{
		/*
		 * according to this page we can't hook into cmd.exe 
		 * http://microsoft.public.win32.programmer.tools.narkive.com/X4AmQ75v/setwindowshookex-failure-with-console-applications
		 */
		if(WinActive("ahk_class ConsoleWindowClass"))
		{
			return false
		}
		debugger("Checking availability")
		if(! JPGIncDllWindowMover.32BitPID || ! JPGIncDllWindowMover.64BitPID)
		{
			return false
		}
		process, exist, % JPGIncDllWindowMover.32BitPID
		if(ErrorLevel == 0)
		{
			debugger("32 bit isn't available")
			return false
		}
		process, exist, % JPGIncDllWindowMover.64BitPID
		if(ErrorLevel == 0)
		{
			debugger("64 bit isn't available")
			return false
		}
		return true
	}
	
	/*
	 * might return FAIL if the call fails?
	 */	
	__makeDllCall(desktopNumber, hwnd)
	{
		desktopNumber-- ;the dll starts desktop numbers at 0 not 1
		marker := 43968 ; 0xABC0
		wParam := desktopNUmber | marker
		lParam := hwnd
		WM_SYSCOMMAND := 274
		debugger("moving " hwnd " to desktop " desktopNumber)
		PostMessage, % WM_SYSCOMMAND , % wParam, % lParam, , % "ahk_id " hwnd
		return ErrorLevel
	}

	moveActiveWindowToDesktop(desktopNumber)
	{
		return this.__makeDllCall(desktopNumber, WinExist("A"))
	}
	
	moveWindowToDesktop(desktopNumber, windowHwnd)
	{
		return this.__makeDllCall(desktopNumber, windowHwnd)
	}
}