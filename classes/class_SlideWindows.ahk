;TODO:
;-When a 7plus dialog is shown while a slide window was activated(not through border), it mostly happens that the window doesn't slide out.
;If it does, it sometimes gets activated improperly after confirming the dialog. The window is not lost anymore however. Activating it again in taskbar makes it slide in.
;TODO on Return:
;FileOpen Dialog messes up on XP when sliding out
;Issue with window position on Clearlooks skin (offset of 3, i.e. y = 3 is recognized as 0)
;

;Slide Directions:
Class SlideDirections
{
	static INVALID := 0
	static LEFT := 1
	static TOP := 2
	static RIGHT := 3
	static BOTTOM := 4
}
;Slide States:
Class SlideStates
{
	static NO_SLIDEWINDOW := -1
	static HIDDEN := 0
	static VISIBLE := 1
	static SLIDING_IN := 2
	static SLIDING_OUT := 3
	static RELEASING := 4
}
Class CSlideWindow
{
	__New(hwnd, Direction)
	{
		global SlideWindows
		if(!SlideWindows.CanAddSlideWindow(hwnd, Direction))
			return 0
		this.hwnd := hwnd
		this.SlideState := SlideStates.NO_SLIDEWINDOW
		this.Direction := Direction
		; this.ParentWindows := GetParentWindows(hwnd) ;Parent windows might be used later to dynamically consider this window at screen borders
		this.GetChildWindows(0) ;Child windows are fetched when sliding takes place so they're more recent, but the always on top state is stored here the first time
		WinGet, ExStyle, ExStyle, % "ahk_id " this.hwnd
		this.WasOnTop := ExStyle & 0x8
		this.OriginalPosition := WinGetPos("ahk_id " this.hwnd)
		Loop % this.ChildWindows.MaxIndex()
			this.ChildWindows.OriginalPosition := WinGetPos("ahk_id " this.ChildWindows.hwnd)
		this.SlideOut()
	}
	__Delete()
	{
		if(this.SlideState = SlideStates.HIDDEN) ;only release windows that were not already released
			this.Release()
	}
	;This function slides a window into the screen, making it visible
	SlideIn()
	{
		outputdebug Slide in
		DetectHiddenWindows, On
		;Disable Minimize/Restore animation
		;RegRead, Animate, HKCU, Control Panel\Desktop\WindowMetrics , MinAnimate
		;VarSetCapacity(struct, 8, 0)
		;NumPut(8, struct, 0, "UInt")
		;NumPut(0, struct, 4, "Int")
		;DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"STR", struct,"UINT", 0x0003) ;SPI_SETANIMATION            0x0049 SPIF_SENDWININICHANGE 0x0002
		this.GetChildWindows(0)
		SetWinDelay, 0
		this.SlideState := SlideStates.SLIDING_IN
		Loop % this.ChildWindows.MaxIndex() + 1 ;Set all windows to always on top
		{
			hwnd := A_Index = 1 ? this.hwnd : this.ChildWindows[A_Index - 1].hwnd
			WinSet, AlwaysOnTop, On , ahk_id %hwnd%
			if(Settings.Windows.SlideWindows.HideSlideWindows)
				if(A_Index = 1 || this.ChildWindows[A_Index - 1].WasVisible)
					WinShow ahk_id %hwnd%
		}
		WinActivate % "ahk_id " this.Active
		
		GetVirtualScreenCoordinates(VirtualLeft, VirtualTop, VirtualRight, VirtualBottom) ;We want the coordinates of the upper left and lower right point
		VirtualRight += VirtualLeft
		VirtualBottom += VirtualTop
		
		;Calculate target position
		this.Position := WinGetPos("ahk_id " this.hwnd)
		Loop % this.ChildWindows.MaxIndex()
			this.ChildWindows[A_Index].Position := WinGetPos("ahk_id " this.ChildWindows[A_Index].hwnd)
		if(this.Direction = SlideDirections.LEFT)
		{
			this.ToX := VirtualLeft
			this.ToY := this.Position.y
			Loop % this.ChildWindows.MaxIndex()
			{
				this.ChildWindows[A_Index].ToX := max(this.ToX + this.ChildWindows[A_Index].Position.x - this.Position.x, VirtualLeft)
				this.ChildWindows[A_Index].ToY := this.ChildWindows[A_Index].Position.y
			}
		}
		else if(this.Direction = SlideDirections.TOP)
		{
			this.ToX := this.Position.x
			this.ToY := VirtualTop
			Loop % this.ChildWindows.MaxIndex()
			{
				this.ChildWindows[A_Index].ToX := this.ChildWindows[A_Index].Position.x
				this.ChildWindows[A_Index].ToY := max(this.ToY + this.ChildWindows[A_Index].Position.y - this.Position.y, VirtualTop)
			}
		}
		else if(this.Direction = SlideDirections.RIGHT)
		{
			this.ToX := VirtualRight - this.Position.w
			this.ToY := this.Position.y
			Loop % this.ChildWindows.MaxIndex()
			{
				this.ChildWindows[A_Index].ToX := min(this.ToX + this.ChildWindows[A_Index].Position.x - this.Position.x, VirtualRight - this.ChildWindows[A_Index].Position.w)
				this.ChildWindows[A_Index].ToY := this.ChildWindows[A_Index].Position.y
			}
		}
		else if(this.Direction = SlideDirections.BOTTOM)
		{
			this.ToX := this.Position.x
			this.ToY := VirtualBottom - this.Position.h
			Loop % this.ChildWindows.MaxIndex()
			{
				this.ChildWindows[A_Index].ToX := this.ChildWindows[A_Index].Position.x
				this.ChildWindows[A_Index].ToY := min(this.ToY + this.ChildWindows[A_Index].Position.y - this.Position.y, VirtualBottom - this.ChildWindows[A_Index].Position.h)
			}
		}
		this.Move()
		this.SlideState := SlideStates.VISIBLE
		;Possibly activate Minimize animation again
		;if(Animate = 1)
		;{
		;	NumPut(1, struct, 4, "UInt")
		;	DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"STR", struct,"UINT", 0x0003) ;SPI_SETANIMATION            0x0049 SPIF_SENDWININICHANGE 0x0002
		;}
	}
	;This function slides a window outside the screen, hiding it
	SlideOut()
	{
		global PreviousWindow, SlideWindows
		outputdebug Slide out
		DetectHiddenWindows, On
		;Disable Minimize/Restore animation
		;RegRead, Animate, HKCU, Control Panel\Desktop\WindowMetrics , MinAnimate
		;VarSetCapacity(struct, 8, 0)	
		;NumPut(8, struct, 0, "UInt")
		;NumPut(0, struct, 4, "Int")
		;DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"STR", struct,"UINT", 0x0003) ;SPI_SETANIMATION            0x0049 SPIF_SENDWININICHANGE 0x0002
		SetWinDelay 0
		this.SlideState := SlideStates.SLIDING_OUT
		this.GetChildWindows(1) ;Update the current visibility state of child windows
		Active := WinExist("A") + 0 ;Store the active slide/child window so it can be activated on next slide in
		if(this.hwnd = Active)
			this.Active := Active
		else if(this.ChildWindows.FindKeyWithValue("hwnd", Active))
			this.Active := Active
		else
			PreviousWindow := Active
		GetVirtualScreenCoordinates(VirtualLeft, VirtualTop, VirtualRight, VirtualBottom) ;We want the coordinates of the upper left and lower right point
		VirtualRight += VirtualLeft
		VirtualBottom += VirtualTop
		OffsetFromScreen := 10
		;Calculate target position
		this.Position := WinGetPos("ahk_id " this.hwnd)
		Loop % this.ChildWindows.MaxIndex()
			this.ChildWindows[A_Index].Position := WinGetPos("ahk_id " this.ChildWindows[A_Index].hwnd)
		if(this.Direction = SlideDirections.LEFT)
		{
			this.ToX := VirtualLeft - this.Position.w - OffsetFromScreen
			this.ToY := this.Position.y
			Loop % this.ChildWindows.MaxIndex() ;Correct for offset of child windows
				this.ToX := min(this.ToX, this.ToX - ((this.ChildWindows[A_Index].Position.x + this.ChildWindows[A_Index].Position.w) - (this.Position.x + this.Position.w)))
			Loop % this.ChildWindows.MaxIndex()
			{
				this.ChildWindows[A_Index].ToX := min(this.ToX + this.ChildWindows[A_Index].Position.x - this.Position.x, VirtualLeft - this.ChildWindows[A_Index].Position.w)
				this.ChildWindows[A_Index].ToY := this.ChildWindows[A_Index].Position.y
			}
			this.SlideOutPos := this.Position.y
			this.SlideOutLen := this.Position.h
		}
		else if(this.Direction = SlideDirections.TOP)
		{
			this.ToX := this.Position.x
			this.ToY := VirtualTop - this.Position.h - OffsetFromScreen
			Loop % this.ChildWindows.MaxIndex() ;Correct for offset of child windows
				this.ToY := min(this.ToY, this.ToY - ((this.ChildWindows[A_Index].Position.y + this.ChildWindows[A_Index].Position.h) - (this.Position.y + this.Position.h)))
			Loop % this.ChildWindows.MaxIndex()
			{
				this.ChildWindows[A_Index].ToX := this.ChildWindows[A_Index].Position.x
				this.ChildWindows[A_Index].ToY := min(this.ToY + this.ChildWindows[A_Index].Position.y - this.Position.y, VirtualTop - this.ChildWindows[A_Index].Position.h)
			}
			this.SlideOutPos := this.Position.x
			this.SlideOutLen := this.Position.w
		}
		else if(this.Direction = SlideDirections.RIGHT)
		{
			this.ToX := VirtualRight + OffsetFromScreen
			this.ToY := this.Position.y
			Loop % this.ChildWindows.MaxIndex() ;Correct for offset of child windows
				this.ToX := max(this.ToX, this.ToX + (this.Position.x - this.ChildWindows[A_Index].Position.x))
			Loop % this.ChildWindows.MaxIndex()
			{
				this.ChildWindows[A_Index].ToX := max(this.ToX + this.ChildWindows[A_Index].Position.x - this.Position.x, VirtualRight)
				this.ChildWindows[A_Index].ToY := this.ChildWindows[A_Index].Position.y
			}
			this.SlideOutPos := this.Position.y
			this.SlideOutLen := this.Position.h
		}
		else if(this.Direction = SlideDirections.BOTTOM)
		{
			this.ToX := this.Position.x
			this.ToY := VirtualBottom + OffsetFromScreen
			Loop % this.ChildWindows.MaxIndex() ;Correct for offset of child windows
				this.ToY := max(this.ToY, this.ToY + (this.Position.y - this.ChildWindows[A_Index].Position.y))
			Loop % this.ChildWindows.MaxIndex()
			{
				this.ChildWindows[A_Index].ToX := this.ChildWindows[A_Index].Position.x
				this.ChildWindows[A_Index].ToY := max(this.ToY + this.ChildWindows[A_Index].Position.y - this.Position.y, VirtualBottom)
			}
			this.SlideOutPos := this.Position.x
			this.SlideOutLen := this.Position.w
		}
		this.Move()

		WinGet, win, List
		found := false
		Loop, %win%
			if (win%A_Index% = this.hwnd)
				found := true
			else if(found && !SlideWindows.GetByWindowHandle(win%A_Index%))
			{
				found := win%A_Index%
				break
			}
		WinActivate, % "ahk_id " found
		if(!Length := this.ChildWindows.MaxIndex())
			Length := 0
		;hide/minimize all child windows and main wind
		if(Settings.Windows.SlideWindows.HideSlideWindows)
			Loop % Length + 1
			{
				hwnd := A_Index = 1 ? this.hwnd : this.ChildWindows[A_Index - 1].hwnd
				WinHide, ahk_id %hwnd%
			}
		;~ WaitForEvent("SlideWindowResize", 1000)
		;outputdebug post minimize
		this.SlideState := SlideStates.HIDDEN
		outputdebug slidestate set to HIDDEN
		;Possibly activate Minimize animation again
		;if(Animate = 1)
		;{
		;	NumPut(1, struct, 4, "UInt")
		;	DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"STR", struct,"UINT", 0x0003) ;SPI_SETANIMATION            0x0049 SPIF_SENDWININICHANGE 0x0002
		;}
	}
	;This function moves all involved windows to the stored coordinates
	Move()
	{
		Moved := true
		while(Moved) ;While target position is not reached, move all child windows and the main window
		{
			Moved := false
			diffX := this.toX - this.Position.x
			diffY := this.toY - this.Position.y
			StepX := Round(absmin(dirmax(diffX * 2 / 10, 10), diffX))
			StepY := Round(absmin(dirmax(diffY * 2 / 10, 10), diffY))
			if(StepX != 0 || StepY != 0) ;Move the main window
			{
				this.Position.x += StepX
				this.Position.y += StepY
				WinMove, % "ahk_id " this.hwnd, , % this.Position.x, % this.Position.y
				Moved := true
			}
			Loop % this.ChildWindows.MaxIndex() ;Move all child windows
			{
				hwnd := this.ChildWindows[A_Index].hwnd
				diffX := this.ChildWindows[A_Index].toX - this.ChildWindows[A_Index].Position.x
				diffY := this.ChildWindows[A_Index].toY - this.ChildWindows[A_Index].Position.y
				StepX := Round(absmin(dirmax(diffX * 2 / 10, 10), diffX))
				StepY := Round(absmin(dirmax(diffY * 2 / 10, 10), diffY))
			
				WinGet, minstate , minmax, ahk_id %hwnd% ;Don't move child windows which might be hidden/minimized
				if(minstate = -1)
					continue
				if(StepX = 0 && StepY = 0)
					continue
				this.ChildWindows[A_Index].Position.x += StepX
				this.ChildWindows[A_Index].Position.y += StepY
				WinMove, ahk_id %hwnd%, , % this.ChildWindows[A_Index].Position.x, % this.ChildWindows[A_Index].Position.y
				Moved := true
			}
			Sleep 10
		}
		this.Remove("Position")
		this.Remove("ToX")
		this.Remove("ToY")
		Loop % this.ChildWindows.MaxIndex()
		{
			this.ChildWindows[A_Index].Remove("Position")
			this.ChildWindows[A_Index].Remove("ToX")
			this.ChildWindows[A_Index].Remove("ToY")	
		}
	}
	;This functions removes the "Slide window" property from a window, sliding it in and showing it
	;If Soft is true, the window will not be moved. This is used for releasing because of window moving and resizing
	Release(Soft = 0)
	{
		global SlideWindows
		if(!this.hwnd) ;Make sure the slide window was actually successfully created
			return
		outputdebug Release Slide Window
		DetectHiddenWindows, On
		
		;Make sure that no window is accidently released outside of the screen.
		GetVirtualScreenCoordinates(VirtualLeft, VirtualTop, VirtualWidth, VirtualHeight)
		if(Soft && IsObject(WindowList[hwnd]) && RectsSeparate(VirtualLeft, VirtualTop, VirtualWidth, VirtualHeight, WindowList[hwnd].x, WindowList[hwnd].y, WindowList[hwnd].w, WindowList[hwnd].h))
			Soft := 0
		
		this.SlideState := SlideStates.RELEASING
		if(!Soft)
		{
			WinShow, % "ahk_id " this.hwnd
			this.Position := WinGetPos("ahk_id " this.hwnd)
			this.ToX := this.OriginalPosition.x
			this.ToY := this.OriginalPosition.y
			Loop % this.ChildWindows.MaxIndex()
			{
				this.ChildWindows[A_Index].Position := WinGetPos("ahk_id " this.ChildWindows[A_Index].hwnd)
				this.ChildWindows[A_Index].ToX := this.ChildWindows[A_Index].OriginalPosition.x
				this.ChildWindows[A_Index].ToY := this.ChildWindows[A_Index].OriginalPosition.y
				if(this.ChildWindows[A_Index].WasVisible)
					WinShow, % "ahk_id " this.ChildWindows[A_Index].hwnd
			}
			WinActivate, % "ahk_id " this.Active
			this.Move()
		}
		WinSet, AlwaysOnTop, % this.WasOnTop ? "On" : "Off", % "ahk_id " this.hwnd
		Loop % this.ChildWindows.MaxIndex()
			WinSet, AlwaysOnTop, % this.ChildWindows.WasOnTop ? "On" : "Off", % "ahk_id " this.ChildWindows[A_Index].hwnd
		if(index := SlideWindows.FindKeyWithValue("hwnd", this.hwnd)) ;Remove if not already done so
			SlideWindows.Remove(index)
	}
	;Calculates a bounding box around the slide window and its child windows
	CalculateBoundingBox(ByRef bLeft, ByRef bTop, ByRef bRight, ByRef bBottom)
	{
		WinGetPos, x, y, w, h, % "ahk_id " this.hwnd
		bLeft := x
		bRight := x + w
		bTop := y
		bBottom := y + h
		Loop % this.ChildWindows.MaxIndex() ;Create a bounding box of all involved windows
		{
			WinGet, Style, Style, % "ahk_id " this.ChildWindows[A_Index].hwnd
			if(!(Style & 0x10000000))
				continue
			WinGetPos l, t, r, b, % "ahk_id " this.ChildWindows[A_Index].hwnd
			r += l
			b += t
			if(l < bLeft) 
				bLeft := l
			if(r > bRight)
				bRight := r
			if(t < bTop)
				bTop := t
			if(b > bBottom)
				bBottom := b
		}
	}
	;Get child windows
	GetChildWindows(UpdateVisibility)
	{
		DetectHiddenWindows, On
		WinGet, Windows, List
		if(!IsObject(this.ChildWindows))
			this.ChildWindows := Array()
		FoundChildWindows := Array()
		Loop % Windows ;Iterate over all windows, find out which ones are child windows of hwnd and add them to the list
		{
			hParent := Windows%A_Index%
			if(hParent = this.hwnd) ;Skip the window itself
				continue
			while(hParent && hParent != this.hwnd)
				hParent := DllCall("GetParent", "PTR", hParent)
			if(hParent = this.hwnd)
			{
				class := WinGetClass("ahk_id " Windows%A_Index%)
				classParent := WinGetClass("ahk_id " hParent) ;Some stuff here is only added for debugging, may be removed later if all really works fine.
				if(InStr("tooltips_class32,WorkerW,IME,MSCTFIME UI", class)) ;Ignore some common helper windows
					continue
				FoundChildWindows.Insert(Windows%A_Index%)
				WinGet, Style, Style, % "ahk_id " Windows%A_Index% ;Store if the child window is visible
				if(index := this.ChildWindows.FindKeyWithValue("hwnd", Windows%A_Index%)) ;By refreshing the ChildWindows array instead of replacing it, we make sure to keep the original visible and always on top states of child windows
				{
					if(UpdateVisibility)
						this.ChildWindows[index].WasVisible := Style & 0x10000000 ? 1 : 0
					continue
				}
				WinGet, ExStyle, ExStyle, % "ahk_id " Windows%A_Index% ;Also store always on top state of new child windows
				if(this.SlideState = SlideStates.VISIBLE) ;Make sure that newly created windows will be set to always on top when the window is already slided out
					WinSet, AlwaysOnTop, On, % "ahk_id " Windows%A_Index%
				this.ChildWindows.Insert(Object("hwnd", Windows%A_Index%, "WasOnTop", ExStyle & 0x8, "WasVisible", Style & 0x10000000, "Class", class, "ClassParent", ClassParent))
			}
		}
		index := 1
		Loop % this.ChildWindows.MaxIndex() ;Delete loop for child windows which were closed
		{
			if(FoundChildWindows.IndexOf(this.ChildWindows[index].hwnd))
				index++
			else
				this.ChildWindows.Remove(index)
		}
	}
}
Class CSlideWindows
{
	__New()
	{
		this.base.base := Array()
		;Read list of window classes that were closed outside of the screen
		if(FileExist(Settings.ConfigPath "\ClosedWindowsOutsideScreen.xml"))
		{
			FileRead, xml, % Settings.ConfigPath "\ClosedWindowsOutsideScreen.xml"
			XMLObject := XML_Read(xml)
			this.ClosedWindowsOutsideScreen := IsObject(XMLObject) && IsObject(XMLObject.Window) && XMLObject.Window.MaxIndex() > 0 ? XMLObject.Window : Array(XMLObject.Window)
		}
		else
			this.ClosedWindowsOutsideScreen := Array()
	}
	OnExit()
	{
		if(this.ClosedWindowsOutsideScreen.MaxIndex() > 0)
			XML_Save(Object("Window", this.ClosedWindowsOutsideScreen), Settings.ConfigPath "\ClosedWindowsOutsideScreen.xml")
		else
			FileDelete, % Settings.ConfigPath "\ClosedWindowsOutsideScreen.xml"
		this.ReleaseAll()
	}
	
	;Called when the property is changed so existing slide windows can be updated.
	On_HideSlideWindows_Changed()
	{
		return ;TODO: This doesn't work unfortunately.
		for index, SlideWindow in this
		{
			if(SlideWindow.SlideState = SlideStates.HIDDEN)
			{
				if(Settings.Windows.SlideWindows.HideSlideWindows)
					WinHide, % "ahk_id " SlideWindow.hwnd
				else
					PostMessage, 0x112, 0xF020, , , % "ahk_id " SlideWindow.hwnd
			}
		}
	}
	
	;Called when the property is changed so existing slide windows can be updated.
	On_LimitToOnePerSide_Changed()
	{
		dir := []
		pos := 1
		if(Settings.Windows.SlideWindows.LimitToOnePerSide)
			Loop % this.MaxIndex()
			{
				SlideWindow := this[pos]
				if(dir[SlideWindow.dir])
					SlideWindow.Release()
				else
				{
					dir[SlideWindow.dir] := 1
					pos++
				}
			}
	}
	CanAddSlideWindow(hwnd, Direction)
	{
		Class := WinGetClass("ahk_id " hwnd)
		if(!Class || InStr("WorkerW,Progman,Shell_TrayWnd,BaseBar,DV2ControlHost,Static", Class))
			return false
		if(IsFullScreen("A", true, true))
			return false
		if(Direction = GetTaskbarDirection())
			return false
		;Ignore maximized windows
		WinGet, maxstate , minmax, ahk_id %hwnd%
		if(maxstate = 1)
			return
		;Accessor doesn't support sliding yet
		if(hwnd = CAccessor.Instance.GUI.hwnd)
			return false
		return this.IsSlideSpaceFree(hwnd, Direction)
	}
	IsSlideSpaceOccupied(px, py, width, height, dir)
	{
		if(dir = 1 || dir = 3)
		{
			Loop % this.MaxIndex() ;Check all slide windows
			{
				SlideWindow := this[A_INDEX]
				if(SlideWindow.Direction = dir)
				{
					BorderY := (Height - 2 * Settings.Windows.SlideWindows.BorderSize > 0) ? Settings.Windows.SlideWindows.BorderSize : 0
					objBorderY := (SlideWindow.SlideOutLen - 2 * Settings.Windows.SlideWindows.BorderSize > 0) ? Settings.Windows.SlideWindows.BorderSize : 0
					Y1 := pY + borderY
					Y2 := pY + Height - borderY
					objY1 := SlideWindow.SlideOutPos + objBorderY
					objY2 := SlideWindow.SlideOutPos + SlideWindow.SlideOutLen - objBorderY
					if Y1 between %objY1% and %objY2%
						return SlideWindow
					if Y2 between %objY1% and %objY2%
						return SlideWindow
					if objY1 between %Y1% and %Y2%
						return SlideWindow
					if objY2 between %Y1% and %Y2%
						return SlideWindow
				}			
			}
		}
		else if(dir = 2 || dir = 4)
		{
			Loop % this.MaxIndex() ;Check all slide windows
			{
				SlideWindow := this[A_INDEX]
				if(SlideWindow.Direction = dir)
				{
					borderX := (Width - 2 * Settings.Windows.SlideWindows.BorderSize > 0) ? Settings.Windows.SlideWindows.BorderSize : 0
					objBorderX := (SlideWindow.SlideOutLen - 2 * Settings.Windows.SlideWindows.BorderSize > 0) ? Settings.Windows.SlideWindows.BorderSize : 0
					X1 := pX + borderX
					X2 := pX + Width - borderX
					objX1 := SlideWindow.SlideOutPos + objBorderX
					objX2 := SlideWindow.SlideOutPos + SlideWindow.SlideOutLen - objBorderX
					if X1 between %objX1% and %objX2%
						return SlideWindow
					if X2 between %objX1% and %objX2%
						return SlideWindow
					if objX1 between %X1% and %X2%
						return SlideWindow
					if objX2 between %X1% and %X2%
						return SlideWindow
				}
			}
		}
		return 0
	}
	IsSlideSpaceFree(hwnd, dir)
	{
		if(Settings.Windows.SlideWindows.LimitToOnePerSide)
			return this.FindKeyWithValue("Direction", dir) = 0
		WinGetPos X, Y, Width, Height, ahk_id %hwnd%
		return !this.IsSlideSpaceOccupied(X, Y, Width, Height, dir)
	}
	ReleaseAll()
	{
		Loop % this.MaxIndex()
			this[1].Release(0)
	}
	;This is called when a window gets resized to see if it needs to be released
	CheckResizeReleaseCondition(hwnd)
	{
		GetVirtualScreenCoordinates(VirtualLeft, VirtualTop, VirtualWidth, VirtualHeight)
		SlideWindow := this.GetItemWithValue("hwnd", hwnd)
		if(!SlideWindow)
			return
		if(SlideWindow.SlideState = SlideStates.VISIBLE)
		{
			WinGetPos, , , w, h, % "ahk_id " slidewindow.hwnd
			outputdebug % "release due to resize, state: " SlideWindow.SlideState ", w: " w ", h: " h
			SlideWindow.Release(SlideWindow.SlideState = SlideStates.VISIBLE)
		}
		RaiseEvent("SlideWindowResize")
	}
	;This is called when a window gets closed to see if a slide window needs to be released
	WindowClosed(hwnd)
	{
		global WindowList
		index := 1
		DetectHiddenWindows, On
		Loop % this.MaxIndex()
		{
			SlideWindow := this[index]
			if(!WinExist("ahk_id " SlideWindow.hwnd))
			{
				outputdebug release due to close
				SlideWindow.Release()
			}
			else
				index++
		}
		;Check if a window was closed outside of the screen and add it to a list so it can be moved inside again when it gets opened again
		if(IsObject(WindowList[hwnd]) && !IsWindowOnScreen(WindowList[hwnd]))
		{
			class := WindowList[hwnd].class
			if(!this.ClosedWindowsOutsideScreen.IndexOf(class))
				this.ClosedWindowsOutsideScreen.Insert(class)
		}
	}
	;This is called when a window gets activated and takes care of sliding windows out/in that were (de)activated
	WindowActivated()
	{
		if(IsContextMenuActive()) ;Ignore context menus
			return
		outputdebug Window activated
		hwnd := WinExist("A") + 0
		this.ActivatedWindow := hwnd
		SetTimer, CheckForNewChildWindows, -100
		SlideWindow := this.GetByWindowHandle(hwnd, ChildIndex)
		if(IsObject(SlideWindow) && SlideWindow.SlideState = SlideStates.VISIBLE)
			SlideWindow.Active := WinExist("A") + 0 ;Last active slide window
		index := this.FindKeyWithValueBetween("SlideState", SlideStates.VISIBLE, SlideStates.RELEASING)
		CurrentSlideWindow := this[index]
		class := WinGetClass("ahk_id " hwnd)
		;If a window outside of the screen was activated and it's stored in the list of windows that were closed while being outside of the screen, move it in
		if(!SlideWindow && index := this.ClosedWindowsOutsideScreen.indexOf(class) && !IsWindowOnScreen(hwnd))
		{
			WinMove, ahk_id %hwnd%, , % A_ScreenWidth / 2 - w / 2, % A_ScreenHeight / 2 - h / 2
			this.ClosedWindowsOutsideScreen.Remove(index)
		}
		if(CurrentSlideWindow && CurrentSlideWindow = SlideWindow) ;A window from the same slide window group was activated
			return
		if(CurrentSlideWindow)
		{
			WinGet, minstate , minmax, % "ahk_id " CurrentSlideWindow.hwnd
			if(minstate = -1 && CurrentSlideWindow.SlideState = SlideStates.VISIBLE) ;Release slide window that was minimized (but is not currently sliding)
			{
				outputdebug % "release due to minimize, state: " CurrentSlideWindow.SlideState
				CurrentSlideWindow.Release(1)
			}
			else if(!CurrentSlideWindow.AutoSlideOut)
				CurrentSlideWindow.SlideOut()
		}
		if(SlideWindow && SlideWindow.SlideState = SlideStates.HIDDEN)
		{
			WinGet, minstate , minmax, % "ahk_id " SlideWindow.hwnd
			if(minstate != -1) ;Make sure the window is not minimized anymore
			{
				SlideWindow.AutoSlideOut := false ;Slide windows that were activated directly will only slide out when they're deactivated
				SlideWindow.SlideIn()
			}
		}
	}
	;Slide windows need to monitor window creation to update child window list when appropriate, but this does not seem to work.
	;Instead window activation is monitored with a slight delay that allows the window to set its parent state. Function is only left here for reference.
	WindowCreated(hwnd)
	{
	}
	;Finds a slide window object by one of its windows
	GetByWindowHandle(hwnd, ByRef ChildIndex)
	{
		Loop % this.MaxIndex()
		{
			if(this[A_Index].hwnd = hwnd)
			{
				ChildIndex := 0
				return this[A_Index]
			}
			else if(ChildIndex := this[A_Index].ChildWindows.FindKeyWithValue("hwnd", hwnd))
				return this[A_Index]
		}
	}
	;This is called when the mouse is moved and takes care of screen border slide window activation and deactivation when the mouse leaves the window
	OnMouseMove(x, y)
	{
		GetVirtualScreenCoordinates(VirtualLeft, VirtualTop, VirtualWidth, VirtualHeight)
		VirtualRight += VirtualLeft
		VirtualBottom += VirtualTop
		if(x = VirtualLeft)
			dir = 1
		else if(y = VirtualTop)
			dir = 2
		else if(x = VirtualLeft + VirtualWidth - 1)
			dir = 3
		else if(y = VirtualTop + VirtualHeight - 1)
			dir = 4
		if((z := GetTaskbarDirection()) = dir || z <= 0)
			return
		if(this.FindKeyWithValueBetween("SlideState", SlideStates.SLIDING_IN, SlideStates.RELEASING)) ;Currently sliding a window, ignore mouse
			return
		;Check if mouse position matches a slide window border and don't slide in while other slide window is on the screen
		SlideWindow := this.IsSlideSpaceOccupied(x, y, 0, 0, dir)
		if(dir > 0 && SlideWindow && (!Settings.Windows.SlideWindows.BorderActivationRequiresMouseUp || !GetKeyState("LButton", "P") || GetKeyState(Settings.Windows.SlideWindows.ModifierKey, "P")) && !this.FindKeyWithValue("SlideState", SlideStates.VISIBLE))
		{
			this.ActiveWindow := WinExist("A")
			SlideWindow.AutoSlideOut := true
			SlideWindow.SlideIn()
			return
		}
		;Now see if mouse is currently over a shown slide window and maybe hide it
		MouseGetPos, , , win
		win += 0
		SlideWindow := this.GetItemWithValue("SlideState", SlideStates.VISIBLE)
		if(SlideWindow && SlideWindow.AutoSlideOut && SlideWindow.hwnd != win && !SlideWindow.ChildWindows.FindKeyWithValue("hwnd", win) && !IsContextMenuActive() && !GetKeyState(Settings.Windows.SlideWindows.ModifierKey, "P"))
		{
			SlideWindow.SlideOut()
			WinActivate % "ahk_id " this.ActiveWindow
		}
	}
	CheckForNewChildWindows()
	{
		Parents := GetParentWindows(this.ActivatedWindow)
		Loop % Parents.MaxIndex()
			if(SubItem := this.GetItemWithValue("hwnd", Parents[A_Index]))
			{
				SubItem.GetChildWindows(0)
				break
			}
	}
}
CheckForNewChildWindows:
SlideWindows.CheckForNewChildWindows()
return

;Get parent windows, ignoring some default windows
GetParentWindows(hwnd) {
	Parents := Array()
	hParent := hwnd
	while(true)
	{
		hParent := DllCall("GetParent", "PTR", hParent)
		Class := WinGetClass("ahk_id " hParent)
		if(InStr("WorkerW,Progman,Shell_TrayWnd,BaseBar,DV2ControlHost,Static", Class)) ;Ignore taskbar and desktop windows
			break
		Parents.Insert(hParent)
	}
	return Parents
}