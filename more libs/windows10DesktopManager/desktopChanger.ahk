class JPGIncDesktopChangerClass
{
	goToDesktopCallbackFunctionName := "goToDesktop"
	nextDesktopFunctionName := "goToNextDesktop"
	PreviousDesktopFunctionName := "goToPreviousDesktop"
	postGoToDesktopFunctionName := ""
	
	__new() 
	{
		this.DllWindowMover := new JPGIncDllWindowMover()
		this.desktopMapper := new DesktopMapperClass(new VirtualDesktopManagerClass())
		Gui, destkopChanginGUI: new,
		return this
	}

	goToNextDesktop(keyCombo := "")
	{
		send("^#{right}")
		return this.doPostGoToDesktop()
	}
	
	goToPreviousDesktop(keyCombo := "")
	{
		send("^#{left}")
		return this.doPostGoToDesktop()
	}
	
	/*
	 *	swap to the given virtual desktop number
	 */
	goToDesktop(newDesktopNumber) 
	{
		debugger("in go to desktop changing to " newDesktopNumber)
		this._makeDesktopsIfRequired(newDesktopNumber)
			._goToDesktop(newDesktopNumber)
		this.doPostGoToDesktop()
		return this
	}
	
	_makeDesktopsIfRequired(minimumNumberOfDesktops)
	{
		currentNumberOfDesktops := this.desktopMapper.getNumberOfDesktops()
		loop, % minimumNumberOfDesktops - currentNumberOfDesktops
		{
			send("#^d")
		}
		
		return this
	}

	_goToDesktop(newDesktopNumber)
	{
		if(this.DllWindowMover.isAvailable())
		{
			Gui destkopChanginGUI: show, W0 H0
			Gui destkopChanginGUI: +HwnddesktopChangingGuiHwnd
			this.DllWindowMover.moveWindowToDesktop(newDesktopNumber, desktopChangingGuiHwnd)
			;doing 2 win shows doesn't appear to change desktops
			WinActivate, ahk_class Shell_TrayWnd
			Gui destkopChanginGUI: show, W0 H0
			Gui destkopChanginGUI: hide,
		} else 
		{
			currentDesktop := this.desktopMapper.getDesktopNumber()
			direction := currentDesktop - newDesktopNumber
			distance := Abs(direction)
			debugger("distance to move is " distance "`ndirectin" direction)
			if(direction < 0)
			{
				debugger("Sending right! " distance "times")
				send("^#{right " distance "}")
			} else
			{
				send("^#{left " distance "}")
			}
		}
		return this
	}
	
	doPostGoToDesktop() 
	{
		this._activateTopMostWindow()
		callFunction(this.postGoToDesktopFunctionName)
		return this
	}
	
	_activateTopMostWindow()
	{
		;if the desktop has focus before changing virtual desktops then the top most window isn't activated on the new desktop
		;so check if the desktop has focus after switching to a new one. if it does send an alt + tab to focus the window on that desktop
		If(this._doesDesktopHaveFocus() && ! isMultiTaskingViewActive())
		{
			send !{tab}
		}
		return this
	}
	
	_doesDesktopHaveFocus() 
	{
		;CabinetWClass is file explorer
		return WinActive("ahk_exe explorer.exe") && ! WinActive("ahk_class CabinetWClass")
	}
}