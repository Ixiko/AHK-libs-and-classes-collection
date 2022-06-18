; *************************
; Internet explorer library
; *************************


Class IE_control
{
	; Class variable initialisation
	found := 0
	IE := ""
	
	
	; initialise the class and IE session
    __New(address := "", title := "", visible := True, IE := "", function := "new")
    {
		loop, 5
		{
			try
			{	
				; Grab already open session
				if (function = "grab")
				{
					SetTitleMatchMode, 1 ; 1 = starts with
					
					TabToTab(title)
					WinGet, hWnd, ID, %title%
					this.IE := WBGet("ahk_id " hWnd)
					this.busy()
				}
				; Create new session
				else if (IE == "")
				{
					this.IE := ComObjCreate("{D5E8041D-920F-45e9-B8FB-B1DEB82C6E5E}") ; create a InternetExplorerMedium instance 
					this.IE.Visible := visible
					this.IE.Navigate(address)
					this.busy()
				}
				; Use supplied pointer to IE
				else
				{
					this.IE := IE
					this.busy()
				}
				
				break
			}
			catch
			{
				if (A_index < 4)
				{
					GroupAdd, IEGroup, %title%
					WinClose, ahk_group IEGroup
				}
				else
				{
					throw Exception("IE class initialisation fail", 1)
				}
			}
		}
		
		return this
    }




	; Set the IE pointer
	setPointer(IE)
	{
		this.IE := IE
		return
	}
	
	
	
	
	; Get the IE pointer
	getPointer()
	{
		return this.IE
	}
	
	
	
	
	; !!! need to check if this works correctly
	quitAll()
	{
		title := this.IE.document.title
		this.IE.quit
		GroupAdd, IEGroup, %title%
		WinClose, ahk_group IEGroup
		return
	}
	
	
	
	
	quit()
	{
		this.IE.quit
		return
	}
	
	
	
	; This is kind of a mini-thread. Opens up another AHK session to press the OK button
	clickOK()
	{
		Path := A_WorkingDir . "\ClickOKIE.ahk"

		code =
		(
			Found := False
			MessageTitle := "Message from webpage"

			Loop 20
			{
				if WinExist(MessageTitle)
				{
					Found := True
					ControlClick, OK, Message from webpage
				}
				else if !WinExist(MessageTitle) AND Found
				{
					break
				}

				sleep 200
			}	

			FileDelete, %Path%		

			ExitApp
		)

		FPtr := FileOpen(Path, "w")
		FPtr.Write(code)
		FPtr.Close()

		run, % Path
		return True
	}




	busy()
	{
		sleepAmount := 50

		Loop, 5
		{
			try
			{
				while this.IE.busy || this.IE.ReadyState != 4
					sleep %sleepAmount%

				return 2000
			}
			catch
			{
				sleep 200
			}
		}

		throw Exception("IE fail", -1)
	}




	set(Frame := "", GetBy := "Name", SearchValue := "", Value := "")
	{
		Results := ""
		
		try
		{
			if (Frame = "")
			{
				if (GetBy = "Name")
				{
					Results := this.IE.document.getelementsbyName(SearchValue)
					Results[0].value := Value
					return True
				}
			}
			else
			{
				if (GetBy = "Name")
				{
					Results := this.IE.document.parentWindow.frames(Frame).document.getElementsByName(SearchValue)
					Results[0].value := Value
					return True
				}
			}
		}
		catch
		{
			throw Exception("IE fail", -1)
		}
	}




	; !!! Have not fully tested
	getValue(Frame := "", GetBy := "Name", SearchValue := "", SearchValue2 := "")
	{
		Results := ""
		
		try
		{
			if (Frame = "")
			{
				if (GetBy = "Name")
				{
					Results := this.IE.document.getelementsbyName(SearchValue)
					return Results[0].value
				}
				else if (GetBy = "ID")
				{
					return this.IE.document.GetElementByID(SearchValue).value
				}
				else if (GetBy = "TagNameID")
				{
					Results := this.IE.document.GetElementsByTagName(SearchValue)
					
					Loop % Results.length
					{
						if (Results[A_index-1].ID == SearchValue2)
						{
							return Results[A_index-1].innerHTML
						}
					}
					
					return False
				}
			}
			else
			{
				if (GetBy = "Name")
				{
					Results := this.IE.document.parentWindow.frames(Frame).document.getElementsByName(SearchValue)
					return Results[0].value
				}
			}
		}
		catch
		{
			throw Exception("IE fail", -1)
		}
	}




	elementPresent(Frame := "", GetBy := "Name", SearchValue := "")
	{
		Results := ""

		try
		{
			if (Frame = "")
			{
				if (GetBy = "Name")
				{
					Results := this.IE.document.getelementsbyName(SearchValue)

					if (Results.Length == 0)
						return False
					else
						return True
				}
				else if (GetBy = "ID")
				{
					return this.IE.document.GetElementByID(SearchValue)
				}
			}
			else
			{
				if (GetBy = "Name")
				{
					try
						Results := this.IE.document.parentWindow.frames(Frame).document.getElementsByName(SearchValue)
					catch
						return False
						
					if (Results.Length == 0)
						return False
					else
						return True
				}
				else if (GetBy = "ID")
				{	
					return this.IE.document.parentWindow.frames(Frame).document.GetElementByID(SearchValue)
				}
			}
		}
		catch
		{
			throw Exception("IE fail", -1)
		}
	}




	click(Frame := "", GetBy := "Name", SearchValue := "", SearchValue2 := "")
	{
		Results := ""
		
		try
		{
			if (Frame = "")
			{
				if (GetBy = "Name")
				{
					Results := this.IE.document.getelementsbyName(SearchValue)
					Results[0].click()
					this.busy()
					return True
				}
				else if (GetBy = "TagNameSRC")
				{
					Results := this.IE.document.GetElementsByTagName(SearchValue)

					Loop % Results.length
					{	
						if (InStr(Results[A_index-1].src, SearchValue2))
						{
							Results[A_index-1].click()
							this.busy()
							return True
						}
					}
					
					return False
				}
				else if (GetBy = "ID")
				{
					this.IE.document.GetElementByID(SearchValue).Click()
					this.busy()
					return True
				}
			}
			else
			{
				if (GetBy = "Name")
				{
					Results := this.IE.document.parentWindow.frames(Frame).document.getElementsByName(SearchValue)
					Results[0].click()
					this.busy()
					return True
				}
				else if(GetBy = "ID")
				{
					this.IE.document.parentWindow.frames(Frame).document.getElementById(SearchValue).Click()
					this.busy()
					return True
				}
				else if (GetBy = "TagNameSRC")
				{
					; !!! Have not actually tried this
					Results := this.IE.document.parentWindow.frames(Frame).document.GetElementsByTagName(SearchValue)

					Loop % Results.length
					{	
						if (InStr(Results[A_index-1].src, SearchValue2))
						{
							Results[A_index-1].click()
							this.busy()
							return True
						}
					}
					
					return False
				}

				else if (GetBy = "TagNameclassname")
				{
					Results := this.IE.document.parentWindow.frames(Frame).document.getElementsByTagname(SearchValue)

					Loop % Results.length
					{
						if (Results[A_index-1].getAttribute("classname") == SearchValue2)
						{
							Results[A_index-1].click
							this.busy()
							return True
						}		
					}
					
					return False
				}
				else if (GetBy = "TagNameTitle")
				{
					Results := this.IE.document.parentWindow.frames(Frame).document.GetElementsByTagName(SearchValue)

					Loop % Results.length
					{	
						if (InStr(Results[A_index-1].title, SearchValue2))
						{
							Results[A_index-1].click()
							this.busy()
							return True
						}
					}
					
					return False
				}
			}
		}
		catch
		{
			throw Exception("IE fail", -1)
		}
	}




	HTMLFind(Frame := "", GetBy := "Name", SearchValue := "", SearchValue2 := "")
	{
		Results := ""
		FramesList := ""
		HTMLText := ""
		
		try
		{
			if (Frame = "")
			{
				if (GetBy = "OuterHTML")
				{
					HTMLText := this.IE.document.documentElement.outerHTML
				
					if InStr(HTMLText, SearchValue)
						return True
					else
						return False
				}
				else (GetBy = "TagNameInnerHTML")
				{
					Results := this.IE.document.documentElement.getElementsByTagName(SearchValue)
					
					loop, % Results.length
					{
						if (InStr(Results[A_index-1].innerHTML, SearchValue2))
							return True
					}
					
					return False
				}
			}
			else
			{
				if (GetBy = "NameInnerHTML")
				{
					FramesList := this.IE.document.ParentWindow.Frames
							
					Loop % FramesList.length
					{
						if inStr(FramesList[A_index - 1].name, Frame) > 0
						{
							if inStr(FramesList[A_index - 1].document.getElementById(SearchValue).InnerHTML, SearchValue2) > 0
								return True
							else	
								return False
						}
					}
				}
				else (GetBy = "TagNameInnerHTML")
				{
					Results := this.IE.document.parentWindow.frames(Frame).document.getElementsByTagName(SearchValue)
					
					loop, % Results.length
					{
						if (InStr(Results[A_index-1].innerHTML, SearchValue2))
							return True
					}
					
					return False
				}
			}
		}
		catch
		{
			throw Exception("IE fail", -1)
		}
	}




	; euras - https://www.autohotkey.com/boards/viewtopic.php?t=36660 - 04/09/2017
	get(Name="", HwndFilter="") 
	{
		if (Name = "")	;// Get active window name if no parameter
			WinGetTitle, Name, % "ahk_id" HwndFilter:=WinExist("ahk_class IEFrame")
		else if (HwndFilter="A" or HwndFilter="Active")
			WinGet, HwndFilter, ID, ahk_class IEFrame
			
		Name := (Name="New Tab - Windows Internet Explorer")? "about:Tabs":RegExReplace(Name, " - (Windows|Microsoft) Internet Explorer")
		
		for wb in ComObjCreate("Shell.Application").Windows
			if wb.LocationName=Name and InStr(wb.FullName, "iexplore.exe")
				if Not HwndFilter or (HwndFilter and wb.hwnd=HwndFilter)
					return wb
	}
	

	
	
	; [WBGet function for AHK v1.1]
	; WBGet function - AutoHotkey Community
	; jeeswg
	; https://autohotkey.com/boards/viewtopic.php?f=6&t=39869
	WBGet(WinTitle="ahk_class IEFrame", Svr#=1) ;// based on ComObjQuery docs
	{               
	   static msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
			, IID := "{0002DF05-0000-0000-C000-000000000046}"   ;// IID_IWebBrowserApp
	;//     , IID := "{332C4427-26CB-11D0-B483-00C04FD90119}"   ;// IID_IHTMLWindow2
	   SendMessage msg, 0, 0, Internet Explorer_Server%Svr#%, %WinTitle%
	   
	   if (ErrorLevel != "FAIL") 
	   {
		  lResult:= ErrorLevel, VarSetCapacity(GUID,16,0)
		  
		  if DllCall("ole32\CLSIDFromString", "wstr","{332C4425-26CB-11D0-B483-00C04FD90119}", "ptr",&GUID) >= 0 
		  {
			 DllCall("oleacc\ObjectFromLresult", "ptr",lResult, "ptr",&GUID, "ptr",0, "ptr*",pdoc)
			 return ComObj(9,ComObjQuery(pdoc,IID,IID),1), ObjRelease(pdoc)
		  }
	   }
	}




	TabToTab(UrlOrTitle)
	{	
		wb := this.getFirst(UrlOrTitle)
		hwnd := wb.HWND
		
		if(this.found)
		{
			loop 
			{
				ControlGetText, wbUrl, Edit1, ahk_id %hwnd%
				WinGetTitle, wbTitle, ahk_id %hwnd%
				
				if(InStr(wbUrl, UrlOrTitle) or InStr(wbTitle, UrlOrTitle))
				{
					ControlSend, , {Ctrl up}, ahk_id %hwnd%
					Break
				}
				
				ControlSend, , {Ctrl down}{Tab}, ahk_id %hwnd%
				sleep, 100
			}
			
			WinActivate, ahk_id %hwnd%
		}
	}
	
	
	
	
	getFirst(UrlOrTitle)
	{
		this.found := 0
		
		for wb in ComObjCreate("Shell.Application").Windows()
		{
			if(InStr(wb.FullName, "iexplore.exe"))
			{
				if(InStr(wb.LocationURL, UrlOrTitle) or InStr(wb.LocationName, UrlOrTitle))
				{
					this.found := 1
					Return wb
				}
			}
		}
	}
}



; Use this for finding element names and IDs
;HTMLText := IE.document.documentElement.outerHTML
;HTMLText := IE.document.parentWindow.frames("frame name").document.documentElement.outerHTML
;HTML2Notepad(HTMLText)
HTML2Notepad(HTMLText)
{
	global IE
	
	clipboard := HTMLText
	Run, Notepad
	WinWait, Untitled - Notepad
	sleep 200
	Send, ^v
	return True
}




; Use this to find a IE session if other tabs open
IEWinExist(WindowName)
{
	For IE in ComObjCreate("Shell.Application").Windows ; for each open window
	{
		If InStr(IE.FullName, "iexplore.exe") && InStr(IE.LocationName, WindowName)
		{
			return True
		}
	}

	return False
}



; *******************************************************************************
; Old code - will have to try and convert other functions to use the new IE class 
; and delete the below functions
; *******************************************************************************



; Internet explorer library

found := 0 ;  For changing tabs




ClickOKIE()
{
	Path := A_WorkingDir . "\ClickOKIE.ahk"

	code =
	(
		Found := False
		MessageTitle := "Message from webpage"

		Loop 20
		{
			if WinExist(MessageTitle)
			{
				Found := True
				ControlClick, OK, Message from webpage
			}
			else if !WinExist(MessageTitle) AND Found
			{
				break
			}

			sleep 200
		}	

		FileDelete, %Path%		

		ExitApp
	)

	FPtr := FileOpen(Path, "w")
	FPtr.Write(code)
	FPtr.Close()

	run, % Path
	return True
}




IEBusy(IE)
{
	sleepAmount := 50
	
	Loop, 5
	{
		try
		{
			while IE.busy || IE.ReadyState != 4
				sleep %sleepAmount%
		
			return True
		}
		catch
		{
			sleep 200
		}
	}

	throw Exception("IE fail", -1)
}




IESet(Frame := "", GetBy := "Name", SearchValue := "", Value := "", IE := "")
{
	Results := ""
	
	try
	{
		if (Frame = "")
		{
			if (GetBy = "Name")
			{
				Results := IE.document.getelementsbyName(SearchValue)
				Results[0].value := Value
				return True
			}
		}
		else
		{
			if (GetBy = "Name")
			{
				Results := IE.document.parentWindow.frames(Frame).document.getElementsByName(SearchValue)
				Results[0].value := Value
				return True
			}
		}
	}
	catch
	{
		throw Exception("IE fail", -1)
	}
}




; !!! Have not fully tested
IEGetValue(Frame := "", GetBy := "Name", SearchValue := "", SearchValue2 := "", IE := "")
{
	Results := ""
	
	try
	{
		if (Frame = "")
		{
			if (GetBy = "Name")
			{
				Results := IE.document.getelementsbyName(SearchValue)
				return Results[0].value
			}
			else if (GetBy = "ID")
			{
				return IE.document.GetElementByID(SearchValue).value
			}
			else if (GetBy = "TagNameID")
			{
				Results := IE.document.GetElementsByTagName(SearchValue)
				
				Loop % Results.length
				{
					if (Results[A_index-1].ID == SearchValue2)
					{
						return Results[A_index-1].innerHTML
					}
				}
				
				return False
			}
		}
		else
		{
			if (GetBy = "Name")
			{
				Results := IE.document.parentWindow.frames(Frame).document.getElementsByName(SearchValue)
				return Results[0].value
			}
		}
	}
	catch
	{
		throw Exception("IE fail", -1)
	}
}




IEElementPresent(Frame := "", GetBy := "Name", SearchValue := "", IE := "")
{
	Results := ""

	try
	{
		if (Frame = "")
		{
			if (GetBy = "Name")
			{
				Results := IE.document.getelementsbyName(SearchValue)
				
				if (Results.Length == 0)
					return False
				else
					return True
			}
			else if (GetBy = "ID")
			{
				return IE.document.GetElementByID(SearchValue)
			}
		}
		else
		{
			if (GetBy = "Name")
			{
				try
					Results := IE.document.parentWindow.frames(Frame).document.getElementsByName(SearchValue)
				catch
					return False
					
				if (Results.Length == 0)
					return False
				else
					return True
			}
			else if (GetBy = "ID")
			{	
				return IE.document.parentWindow.frames(Frame).document.GetElementByID(SearchValue)
			}
		}
	}
	catch
	{
		throw Exception("IE fail", -1)
	}
}




IEClick(Frame := "", GetBy := "Name", SearchValue := "", SearchValue2 := "", IE := "")
{
	Results := ""
	
	try
	{
		if (Frame = "")
		{
			if (GetBy = "Name")
			{
				Results := IE.document.getelementsbyName(SearchValue)
				Results[0].click()
				IEBusy(IE)
				return True
			}
			else if (GetBy = "TagNameSRC")
			{
				Results := IE.document.GetElementsByTagName(SearchValue)

				Loop % Results.length
				{	
					if (InStr(Results[A_index-1].src, SearchValue2))
					{
						Results[A_index-1].click()
						IEBusy(IE)
						return True
					}
				}
				
				return False
			}
			else if (GetBy = "ID")
			{
				IE.document.GetElementByID(SearchValue).Click()
				IEBusy(IE)
				return True
			}
		}
		else
		{
			if (GetBy = "Name")
			{
				Results := IE.document.parentWindow.frames(Frame).document.getElementsByName(SearchValue)
				Results[0].click()
				IEBusy(IE)
				return True
			}
			else if(GetBy = "ID")
			{
				IE.document.parentWindow.frames(Frame).document.getElementById(SearchValue).Click()
				IEBusy(IE)
				return True
			}
			else if (GetBy = "TagNameSRC")
			{
				; !!! Have not actually tried this
				Results := IE.document.parentWindow.frames(Frame).document.GetElementsByTagName(SearchValue)

				Loop % Results.length
				{	
					if (InStr(Results[A_index-1].src, SearchValue2))
					{
						Results[A_index-1].click()
						IEBusy(IE)
						return True
					}
				}
				
				return False
			}

			else if (GetBy = "TagNameclassname")
			{
				Results := IE.document.parentWindow.frames(Frame).document.getElementsByTagname(SearchValue)

				Loop % Results.length
				{
					if (Results[A_index-1].getAttribute("classname") == SearchValue2)
					{
						Results[A_index-1].click
						IEBusy(IE)
						return True
					}		
				}
				
				return False
			}
			else if (GetBy = "TagNameTitle")
			{
				Results := IE.document.parentWindow.frames(Frame).document.GetElementsByTagName(SearchValue)

				Loop % Results.length
				{	
					if (InStr(Results[A_index-1].title, SearchValue2))
					{
						Results[A_index-1].click()
						IEBusy(IE)
						return True
					}
				}
				
				return False
			}
		}
	}
	catch
	{
		throw Exception("IE fail", -1)
	}
}




IEHTMLFind(Frame := "", GetBy := "Name", SearchValue := "", SearchValue2 := "", IE := "")
{
	Results := ""
	FramesList := ""
	HTMLText := ""
	
	try
	{
		if (Frame = "")
		{
			if (GetBy = "OuterHTML")
			{
				HTMLText := IE.document.documentElement.outerHTML
			
				if InStr(HTMLText, SearchValue)
					return True
				else
					return False
			}
			else (GetBy = "TagNameInnerHTML")
			{
				Results := IE.document.documentElement.getElementsByTagName(SearchValue)
				
				loop, % Results.length
				{
					if (InStr(Results[A_index-1].innerHTML, SearchValue2))
						return True
				}
				
				return False
			}
		}
		else
		{
			if (GetBy = "NameInnerHTML")
			{
				FramesList := IE.document.ParentWindow.Frames
						
				Loop % FramesList.length
				{
					if inStr(FramesList[A_index - 1].name, Frame) > 0
					{
						if inStr(FramesList[A_index - 1].document.getElementById(SearchValue).InnerHTML, SearchValue2) > 0
							return True
						else	
							return False
					}
				}
			}
			else (GetBy = "TagNameInnerHTML")
			{
				Results := IE.document.parentWindow.frames(Frame).document.getElementsByTagName(SearchValue)
				
				loop, % Results.length
				{
					if (InStr(Results[A_index-1].innerHTML, SearchValue2))
						return True
				}
				
				return False
			}
		}
	}
	catch
	{
		throw Exception("IE fail", -1)
	}
}




IEGet(Name="", HwndFilter="") 
{
	if (Name = "")	;// Get active window name if no parameter
		WinGetTitle, Name, % "ahk_id" HwndFilter:=WinExist("ahk_class IEFrame")
	else if (HwndFilter="A" or HwndFilter="Active")
		WinGet, HwndFilter, ID, ahk_class IEFrame
		
	Name := (Name="New Tab - Windows Internet Explorer")? "about:Tabs":RegExReplace(Name, " - (Windows|Microsoft) Internet Explorer")
	
	for wb in ComObjCreate("Shell.Application").Windows
		if wb.LocationName=Name and InStr(wb.FullName, "iexplore.exe")
			if Not HwndFilter or (HwndFilter and wb.hwnd=HwndFilter)
				return wb
}



; [WBGet function for AHK v1.1]
; WBGet function - AutoHotkey Community
; jeeswg
; https://autohotkey.com/boards/viewtopic.php?f=6&t=39869
WBGet(WinTitle="ahk_class IEFrame", Svr#=1) ;// based on ComObjQuery docs
{               
   static msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
        , IID := "{0002DF05-0000-0000-C000-000000000046}"   ;// IID_IWebBrowserApp
;//     , IID := "{332C4427-26CB-11D0-B483-00C04FD90119}"   ;// IID_IHTMLWindow2
   SendMessage msg, 0, 0, Internet Explorer_Server%Svr#%, %WinTitle%
   
   if (ErrorLevel != "FAIL") 
   {
      lResult:= ErrorLevel, VarSetCapacity(GUID,16,0)
	  
      if DllCall("ole32\CLSIDFromString", "wstr","{332C4425-26CB-11D0-B483-00C04FD90119}", "ptr",&GUID) >= 0 
	  {
         DllCall("oleacc\ObjectFromLresult", "ptr",lResult, "ptr",&GUID, "ptr",0, "ptr*",pdoc)
         return ComObj(9,ComObjQuery(pdoc,IID,IID),1), ObjRelease(pdoc)
      }
   }
}




GrabOpenIESession(Title)
{
	TabToTab(Title)
	WinGet, hWnd, ID, %Title%
	IE := WBGet("ahk_id " hWnd)
	IEBusy(IE)
	return IE
}



; Capn Odin - https://www.autohotkey.com/boards/viewtopic.php?t=17524, 09/05/2016
TabToTab(UrlOrTitle)
{
	Global found
	
	wb := IEGetFirst(UrlOrTitle)
	hwnd := wb.HWND
	
	if(found)
	{
		loop 
		{
			ControlGetText, wbUrl, Edit1, ahk_id %hwnd%
			WinGetTitle, wbTitle, ahk_id %hwnd%
			
			if(InStr(wbUrl, UrlOrTitle) or InStr(wbTitle, UrlOrTitle))
			{
				ControlSend, , {Ctrl up}, ahk_id %hwnd%
				Break
			}
			
			ControlSend, , {Ctrl down}{Tab}, ahk_id %hwnd%
			sleep, 100
		}
		
		WinActivate, ahk_id %hwnd%
	}
}




IEGetFirst(UrlOrTitle)
{
	Global found
	
	found := 0
	
	for wb in ComObjCreate("Shell.Application").Windows()
	{
		if(InStr(wb.FullName, "iexplore.exe"))
		{
			if(InStr(wb.LocationURL, UrlOrTitle) or InStr(wb.LocationName, UrlOrTitle))
			{
				found := 1
				Return wb
			}
		}
	}
}



