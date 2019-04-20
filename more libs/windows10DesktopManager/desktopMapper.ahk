class DesktopMapperClass
{	
	desktopIds := []
	
	__new(virtualDesktopManager)
	{
		this._setupGui()
		this.virtualDesktopManager := virtualDesktopManager
		return this
	}
	
	/*
	 * Populates the desktopIds array with the current virtual deskops according to the registry key
	 */
	mapVirtualDesktops() 
	{
		regIdLength := 32
		RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
	
		this.desktopIds := []
		while, true
		{
			desktopId := SubStr(DesktopList, ((A_index-1) * regIdLength) + 1, regIdLength)
			if(desktopId) 
			{
				this.desktopIds.Insert(this._idFromReg(desktopId))
			} else
			{
				break
			}
		}
		debugger("there are " this.desktopIds.MaxIndex() " things")
		return this
	}
	
	/*
	 * Gets the desktop id of the current desktop
	 */
	getCurrentDesktopId()
	{
		hwnd := this.hwnd
		Gui %hwnd%:show, NA ;show but don't activate
		winwait, % "Ahk_id " hwnd
		
		guid := this.virtualDesktopManager.getDesktopGuid(hwnd)

		Gui %hwnd%:hide 
		;if you don't wait until it closes (and sleep a little) then the desktop the gui is on can get focus
		WinWaitClose,  % "Ahk_id " hwnd
		sleep 50 

		return this._idFromGuid(guid)
	}
	
	getNumberOfDesktops() 
	{
		this.mapVirtualDesktops()
		return this.desktopIds.maxIndex()
	}
	
	/*
	 * returns the number of the current desktop
	 */
	getDesktopNumber()
	{
		this.mapVirtualDesktops()
		currentDesktop := this.getCurrentDesktopId()
		
		return this._indexOfId(currentDesktop)
	}
	
	/*
	 * takes an ID from the registry and extracts the last 16 characters (which matches the last 16 characters of the GUID)
	 */
	_idFromReg(regString) 
	{
		return SubStr(regString, 17)
	}
	
	/*
	 * takes an ID from microsofts IVirtualDesktopManager and extracts the last 16 characters (which matches the last 16 characters of the ID from the registry)
	 */
	_idFromGuid(guidString)
	{
		return SubStr(RegExReplace(guidString, "[-{}]"), 17)
	}

	_indexOfId(guid) 
	{
		loop, % this.desktopIds.MaxIndex()
		{
			debugger("looking for `n" guid "`n" this.desktopIds[A_index])
			if(this.desktopIds[A_index] == guid) 
			{
				debugger("Found it! desktop is " A_Index)
				return A_Index
			}
		}
		return -1
	}

	_setupGui()
	{
		Gui, new
		Gui, show
		Gui, +HwndMyGuiHwnd
		this.hwnd := MyGuiHwnd
		Gui, hide
		return this
	}
}
