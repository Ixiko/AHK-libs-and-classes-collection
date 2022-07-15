
class UIA_Browser {
	; Initiates UIA and hooks to the browser window specified with wTitle. customNames can be an object that defines custom CurrentName values for locale-specific elements (such as the name of the URL bar): {URLEditName:"My URL Edit name", TabBarName:"Tab bar name", HomeButtonName:"Home button name", StopButtonName:"Stop button", NewTabButtonName:"New tab button name"}. maxVersion specifies the highest UIA version that will be used (default is up to version 7).
	__New(wTitle="A", customNames="", maxVersion="") { 
		this.UIA := UIA_Interface(maxVersion)
		this.TWT := this.UIA.TreeWalkerTrue
		this.CustomNames := (customNames == "") ? {} : customNames
		
		this.TextCondition := this.CreatePropertyCondition(this.UIA.ControlTypePropertyId, this.UIA.TextControlTypeId)
		this.ButtonCondition := this.CreatePropertyCondition(this.UIA.ControlTypePropertyId, this.UIA.ButtonControlTypeId)
		this.BrowserElement := this.UIA.ElementFromHandle(this.BrowserId := WinExist(wTitle), True)
		if this.BrowserId {
			WinGet, wExe, ProcessName, % "ahk_id" this.BrowserId
			this.BrowserType := (wExe == "chrome.exe") ? "Chrome" : (wExe == "msedge.exe") ? "Edge" : "Unknown"
			this.GetCurrentMainPaneElement(this.CustomNames.URLEditName)
		}
	}
	
	__Get(member) {
		if member not in base 
		{
			if RegexMatch(member, "PatternId|EventId|PropertyId|AttributeId|ControlTypeId|AnnotationType|StyleId|LandmarkTypeId|HeadingLevel|ChangeId|MetadataId", match) 
				return IsFunc("UIA_Enum.UIA_" match) ? UIA_Enum["UIA_" match](member) : UIA_Enum[match](member)
			else if (SubStr(member,1,1) != "_") {
				try
					return this.UIA[member]
				try
					return this.BrowserElement[member]
			}
		}
	}
	
	__Call(member, params*) {
		if !ObjHasKey(this.base, member) {
			try
				return this.UIA[member].Call(this.UIA, params*)
			catch e {
				if !InStr(e.Message, "Property not supported by the")
					throw Exception(e.Message, -1, e.What)
			}
			try
				return this.BrowserElement[member].Call(this.BrowserElement, params*)
			catch e {
				if !InStr(e.Message, "Property not supported by the")
					throw Exception(e.Message, -1, e.What)
			}
			throw Exception("Method call not supported by " this.__Class " nor UIA_Interface or UIA_Element class or an error was encountered.",-1,member)
		}
	}
	
	; Refreshes UIA_Browser.MainPaneElement and returns it
	GetCurrentMainPaneElement() { 
		static EditControlCondition, EditNameCondition, EditAndCondition, ToolbarControlCondition, ToolbarWalker
		if !EditControlCondition {
			for i, address in ["Address and search bar", "Search or enter an address", "Address field", this.CustomNames.URLEditName] {
				if (address != "") {
					NameCondition := this.UIA.CreatePropertyCondition(this.UIA.NamePropertyId, address)
					EditNameCondition := (i==1) ? NameCondition : this.UIA.CreateOrCondition(EditNameCondition, NameCondition)
				}
			}
			EditControlCondition := this.UIA.CreatePropertyCondition(this.UIA.ControlTypePropertyId, this.UIA.EditControlTypeId), EditAndCondition := this.UIA.CreateAndCondition(EditControlCondition, EditNameCondition), ToolbarControlCondition := this.UIA.CreatePropertyCondition(this.UIA.ControlTypePropertyId, this.UIA.ToolBarControlTypeId)
		}
		; Finding the correct Toolbar ends up to be quite tricky. In Chrome the toolbar element is located in the tree after the content element, so if the content contains a toolbar then that will be returned. Two workarounds I can think of: either look for the Toolbar by name ("Address and search bar" both in Chrome and edge), or by location (it must be the topmost toolbar). I opted for a combination of two, so if finding by name fails, all toolbar elements are evaluated.
		Loop, 2 
		{
			try {
				if !(this.URLEditElement := this.BrowserElement.FindFirst(EditAndCondition)) {	
					this.ToolbarElements := this.BrowserElement.FindAll(ToolbarControlCondition), topCoord := 10000000
					for k, v in this.ToolbarElements {
						if ((bT := v.CurrentBoundingRectangle.t) && (bt < topCoord))
							topCoord := bT, this.NavigationBarElement := v
					}
					this.URLEditElement := this.NavigationBarElement.FindFirst(EditControlCondition)
					if this.URLEditElement.GetChildren().MaxIndex()
						this.URLEditElement := (el := this.URLEditElement.FindFirst(EditControlCondition)) ? el : this.URLEditElement
				} Else {
					this.NavigationBarElement := this.UIA.CreateTreeWalker(ToolbarControlCondition).GetParentElement(this.URLEditElement)
				}
				this.MainPaneElement := this.TWT.GetParentElement(this.NavigationBarElement)
				if !this.NavigationBarElement
					this.NavigationBarElement := this.BrowserElement
				if !this.MainPaneElement
					this.MainPaneElement := this.BrowserElement
				if !(this.TabBarElement := this.BrowserElement.FindFirstByNameAndType(this.CustomNames.TabBarName ? this.CustomNames.TabBarName : "Tab bar", "Tab"))
					this.TabBarElement := this.MainPaneElement
				return this.MainPaneElement
				break
			} catch {
				WinActivate, % "ahk_id " this.BrowserId
				WinWaitActive, % "ahk_id " this.BrowserId,,1
			}
		}
		; If all goes well, this part is not reached
	}
	
	; Returns the current document/content element of the browser
	GetCurrentDocumentElement() { 
		static docType
		if !docType
			docType := this.UIA.CreatePropertyCondition(this.UIA.ControlTypePropertyId, this.UIA.DocumentControlTypeId)
		return (this.CurrentDocumentElement := this.BrowserElement.FindFirst(docType))
	}
	
	; Uses Javascript to set the title of the browser.
	JSSetTitle(newTitle) {
		this.SetURL("javascriptdocument.title=""" js """; void(0);", True)
	}
	
	JSExecute(js) {
		this.SetURL("javascript:" js, True)
	}
	
	JSAlert(js, closeAlert=True, timeOut=3000) {
		this.SetURL("javascript:alert(" js ");", True)
		return this.GetAlertText(closeAlert, timeOut)
	}
	
	; Executes Javascript code through the address bar and returns the return value through the clipboard.
	JSReturnThroughClipboard(js) {
		saveClip := ClipboardAll
		Clipboard=
		this.SetURL("javascript:copyToClipboard(" js ");function copyToClipboard(text) {const elem = document.createElement('textarea');elem.value = text;document.body.appendChild(elem);elem.select();document.execCommand('copy');document.body.removeChild(elem);}", True)
		ClipWait,2
		returnText := Clipboard
		Clipboard := saveClip
		saveClip=
		return returnText
	}
	
	; Executes Javascript code through the address bar and returns the return value through the browser windows title.
	JSReturnThroughTitle(js, timeOut=500) {
		WinGetTitle, origTitle, % "ahk_id " this.BrowserId
		this.SetURL("javascript:origTitle=document.title;document.title=(" js ");void(0);setTimeout(function() {document.title=origTitle;void(0);}, " timeOut ")", True)
		startTime := A_TickCount
		Loop {
			WinGetTitle, newTitle, % "ahk_id " this.BrowserId
			Sleep, 40
		} Until ((origTitle != newTitle) || (A_TickCount - startTime > timeOut))
		return (origTitle == newTitle) ? "" : RegexReplace(newTitle, "(?: - Personal)? - [^-]+$")
	}
	
	; Uses Javascript's querySelector to get a Javascript element and then its position. useRenderWidgetPos=True uses position of the Chrome_RenderWidgetHostHWND1 control to locate the position element relative to the window, otherwise it uses UIA_Browsers CurrentDocumentElement position.
    JSGetElementPos(selector, useRenderWidgetPos=False) { ; based on code by AHK Forums user william_ahk
        js =
        (
(() => {
    let bounds = document.querySelector("%selector%").getBoundingClientRect().toJSON();
    let zoom = window.devicePixelRatio.toFixed(2);
    for (const key in bounds) {
        bounds[key] = bounds[key] * zoom;
    }
    return JSON.stringify(bounds);
})()
        )
        bounds_str := this.JSReturnThroughClipboard(js)
        RegexMatch(bounds_str, """x"":(\d+).?\d*?,""y"":(\d+).?\d*?,""width"":(\d+).?\d*?,""height"":(\d+).?\d*?", size)
		if useRenderWidgetPos {
			ControlGetPos, win_x, win_y, win_w, win_h, Chrome_RenderWidgetHostHWND1, % "ahk_id " this.BrowserId
			return {x:size1+win_x,y:size2+win_y,w:size3,h:size4}
		} else {
			br := this.GetCurrentDocumentElement().GetCurrentPos("window")
			return {x:size1+br.x,y:size2+br.y,w:size3,h:size4}
		}
    }
	
	; Uses Javascript's querySelector to get and click a Javascript element. Compared with ClickJSElement method, this method has the advantage of skipping the need to wait for a return value from the clipboard, but it might be more unreliable (some elements might not support Javascript's "click()" properly).
	JSClickElement(selector) {
        this.JSExecute("document.querySelector(""" selector """).click();")
	}
    
	; Uses Javascript's querySelector to get a Javascript element and then ControlClicks that position. useRenderWidgetPos=True uses position of the Chrome_RenderWidgetHostHWND1 control to locate the position element relative to the window, otherwise it uses UIA_Browsers CurrentDocumentElement position.
    ControlClickJSElement(selector, WhichButton="", ClickCount="", Options="", useRenderWidgetPos=False) {
        bounds := this.JSGetElementPos(selector, useRenderWidgetPos)
        ControlClick % "X" (bounds.x + bounds.w // 2) " Y" (bounds.y + bounds.h // 2), % "ahk_id " this.browserId,, % WhichButton, % ClickCount, % Options
    }

	; Uses Javascript's querySelector to get a Javascript element and then Clicks that position. useRenderWidgetPos=True uses position of the Chrome_RenderWidgetHostHWND1 control to locate the position element relative to the window, otherwise it uses UIA_Browsers CurrentDocumentElement position.
    ClickJSElement(selector, WhichButton="", ClickCount=1, DownOrUp="", Relative="", useRenderWidgetPos=False) {
        bounds := this.JSGetElementPos(selector, useRenderWidgetPos)
        Click % (bounds.x + bounds.w / 2) " " (bounds.y + bounds.h / 2)" " WhichButton (ClickCount ? " " ClickCount : "") (DownOrUp ? " " DownOrUp : "") (Relative ? " " Relative : "")
    }
	
	; Gets text from an alert-box created with for example javascript:alert('message')
	GetAlertText(closeAlert=True, timeOut=3000) {
		static DialogCondition, DialogTW
		if !IsObject(DialogCondition)
			DialogCondition := this.CreateOrCondition(this.CreatePropertyCondition(this.UIA.ControlTypePropertyId, this.UIA.CustomControlTypeId), this.CreatePropertyCondition(this.UIA.ControlTypePropertyId, this.UIA.WindowControlTypeId)), DialogTW := this.UIA.CreateTreeWalker(DialogCondition)
		startTime := A_TickCount
		while (!(IsObject(dialogEl := DialogTW.GetLastChildElement(this.BrowserElement)) && IsObject(OKBut := dialogEl.FindFirst(this.ButtonCondition))) && ((A_tickCount - startTime) < timeOut))
			Sleep, 100

		try
			text := dialogEl.FindFirst(this.TextCondition).CurrentName
		if closeAlert {
			Sleep, 500
			try OKBut.Click()
		}
		return text
	}
	
	CloseAlert() {
		static DialogCondition, DialogTW
		if !IsObject(DialogCondition)
			DialogCondition := this.CreateOrCondition(this.CreatePropertyCondition(this.UIA.ControlTypePropertyId, this.UIA.CustomControlTypeId), this.CreatePropertyCondition(this.UIA.ControlTypePropertyId, this.UIA.WindowControlTypeId)), DialogTW := this.UIA.CreateTreeWalker(DialogCondition)
		try {
			dialogEl := DialogTW.GetLastChildElement(this.BrowserElement)
			OKBut := dialogEl.FindFirst(this.ButtonCondition)
			OKBut.Click()
		}
	}
	
	; Gets all text from the browser element (CurrentName properties for all Text elements)
	GetAllText() { 
		if !this.IsBrowserVisible()
			WinActivate, % "ahk_id" this.BrowserId
			
		TextArray := this.BrowserElement.FindAll(this.TextCondition)
		Text := ""
		for k, v in TextArray
			Text .= v.CurrentName "`n"
		return Text
	}
	; Gets all link elements from the browser
	GetAllLinks() {
		if !this.IsBrowserVisible()
			WinActivate, % "ahk_id" this.BrowserId			
		LinkCondition := this.UIA.CreatePropertyCondition(this.UIA.ControlTypePropertyId, this.UIA.HyperlinkControlTypeId)
		return this.BrowserElement.FindAll(LinkCondition)

	}
	
	__CompareTitles(compareTitle, winTitle) {
		if (A_TitleMatchMode == 1) {
			if (SubStr(winTitle, 1, StrLen(compareTitle)) == compareTitle)
				return 1
		} else if (A_TitleMatchMode == 2) {
			if InStr(winTitle, compareTitle)
				return 1
		} else if (A_TitleMatchMode == 3) {
			if compareTitle == winTitle
				return 1
		} else if (A_TitleMatchMode == "RegEx") {
			if RegexMatch(winTitle, compareTitle)
				return 1
		}
		return 0
	}
	
	; Waits the browser title to change to targetTitle (by default just waits for the title to change), timeOut is in milliseconds (default is 10 seconds)
	WaitTitleChange(targetTitle="", timeOut=10000) { 
		WinGetTitle, origTitle, % "ahk_id" this.BrowserId
		startTime := A_TickCount, newTitle := origTitle
		while (((A_TickCount - startTime) < timeOut) && (targetTitle ? !this.__CompareTitles(targetTitle, newTitle) : (origTitle == newTitle))) {
			Sleep, 200
			WinGetActiveTitle, newTitle
		}
	}
	
	; Waits the browser page to load to targetTitle, default timeOut is 10 seconds, sleepAfter additionally sleeps for 500ms after the page has loaded. In Edge browser this just waits for the title to change, so its better to use the WaitElementExist function.; Waits the browser page to load to targetTitle, default timeOut is 10 seconds, sleepAfter additionally sleeps for 500ms after the page has loaded. In Edge browser this just waits for the title to change, so its better to use the WaitElementExist function.
	WaitPageLoad(targetTitle="", timeOut=10000, sleepAfter=500, stopButtonText="Stop") { 
		reloadBut := this.UIA.TreeWalkerTrue.GetNextSiblingElement(this.UIA.TreeWalkerTrue.GetNextSiblingElement(this.UIA.TreeWalkerTrue.GetFirstChildElement(this.NavigationBarElement)))
		legacyPattern := reloadBut.GetCurrentPatternAs("LegacyIAccessible")
		startTime := A_TickCount, stopButtonText := this.CustomNames.StopButtonName ? this.CustomNames.StopButtonName : stopButtonText
		while ((A_TickCount - startTime) < timeOut) {
			if (!InStr(reloadBut.CurrentName, stopButtonText) && !InStr(legacyPattern.CurrentDescription, stopButtonText) && !InStr(reloadBut.CurrentFullDescription, stopButtonText)) {
				if targetTitle {
					WinGetTitle, wTitle, % "ahk_id" this.BrowserId
					if this.__CompareTitles(targetTitle, wTitle)
						break
				} else
					break
			}
			Sleep, 200
		}
		if ((A_TickCount - startTime) < timeOut)
			Sleep, %sleepAfter%
	}
	
	; Presses the Back button
	Back() { 
		this.TWT.GetFirstChildElement(this.NavigationBarElement).Click()
	}
	
	; Presses the Forward button
	Forward() { 
		this.TWT.GetNextSiblingElement(this.TWT.GetFirstChildElement(this.NavigationBarElement)).Click()
	}

	; Presses the Reload button
	Reload() { 
		this.TWT.GetNextSiblingElement(this.TWT.GetNextSiblingElement(this.TWT.GetFirstChildElement(this.NavigationBarElement))).Click()
	}

	; Presses the Home button if it exists. If the browser language is not set to English, the correct butName can be specified.
	Home(butName="Home") { 
		NameCondition := this.UIA.CreatePropertyCondition(this.UIA.NamePropertyId, this.CustomNames.HomeButtonName ? this.CustomNames.HomeButtonName : butName)
		this.NavigationBarElement.FindFirst(this.UIA.CreateAndCondition(NameCondition, this.ButtonCondition)).Click()
	}
	
	; Gets the current URL. fromAddressBar=True gets it straight from the URL bar element, which is not a very good method, because the text might be changed by the user and doesn't start with "http(s)://". Default of fromAddressBar=False will cause the real URL to be fetched, but the browser must be visible for it to work (if is not visible, it will be automatically activated).
	GetCurrentURL(fromAddressBar=False) { 
		if fromAddressBar {
			URL := this.URLEditElement.CurrentValue
			return URL ? (RegexMatch(URL, "^https?:\/\/") ? URL : "https://" URL) : ""
		} else {
			; This can be used in Chrome and Edge, but works only if the window is active
			if !this.IsBrowserVisible()
				WinActivate, % "ahk_id" this.BrowserId
			return this.GetCurrentDocumentElement().CurrentValue
		}
	}
	
	; Sets the URL bar to newUrl, optionally also navigates to it if navigateToNewUrl=True
	SetURL(newUrl, navigateToNewUrl = False) { 
		this.URLEditElement.SetFocus()
		valuePattern := this.URLEditElement.GetCurrentPatternAs("Value")
		valuePattern.SetValue(newUrl " ")
		if !InStr(this.URLEditElement.CurrentValue, newUrl) {
			legacyPattern := this.URLEditElement.GetCurrentPatternAs("LegacyIAccessible")
			legacyPattern.SetValue(newUrl " ")
			legacyPattern.Select()
		}
		if (navigateToNewUrl&&InStr(this.URLEditElement.CurrentValue, newUrl))
			ControlSend,, {LCtrl up}{LAlt up}{LShift up}{RCtrl up}{RAlt up}{RShift up}{Enter}, % "ahk_id" this.BrowserId ; Or would it be better to use BlockInput instead of releasing modifier keys?
	}
	
	; Presses the New tab button. The button name might differ if the browser language is not set to English and can be specified with butName
	NewTab(butName="New tab", matchMode=2, caseSensitive=False) { 
		newTabBut := this.TabBarElement.FindFirstByNameAndType(this.CustomNames.NewTabButtonName ? this.CustomNames.NewTabButtonName : butName, UIA_Enum.UIA_ButtonControlTypeId,,matchMode,caseSensitive)
		newTabBut.Click()
	}
	
	; Gets all tab elements
	GetAllTabs() { 
		TabItemControlCondition := this.UIA.CreatePropertyCondition(this.UIA.ControlTypePropertyId, UIA_Enum.UIA_ControlTypeId("TabItem"))
		return this.TabBarElement.FindAll(TabItemControlCondition)
	}

	; Gets all the titles of tabs
	GetAllTabNames() { 
		names := []
		for k, v in this.GetAllTabs() {
			names.Push(v.CurrentName)
		}
		return names
	}
	
	; Returns a tab element with text of searchPhrase, or if empty then the currently selected tab. matchMode follows SetTitleMatchMode scheme: 1=tab name must must start with tabName; 2=can contain anywhere; 3=exact match; RegEx
	GetTab(searchPhrase="", matchMode=3, caseSensitive=True) { 
		return (searchPhrase == "") ? this.TabBarElement.FindFirstBy("ControlType=TabItem AND SelectionItemIsSelected=1") : this.TabBarElement.FindFirstByNameAndType(searchPhrase, "TabItem",, matchMode, caseSensitive)
	}
	
	; Selects a tab with the text of tabName. matchMode follows SetTitleMatchMode scheme: 1=tab name must must start with tabName; 2=can contain anywhere; 3=exact match; RegEx
	SelectTab(tabName, matchMode=3, caseSensitive=True) { 
		(selectedTab := this.TabBarElement.FindFirstByNameAndType(tabName, "TabItem",, matchMode, caseSensitive)).Click()
		return selectedTab
	}
	
	; Close tab by either providing the tab element or the name of the tab. If tabElementOrName is left empty, the current tab will be closed.
	CloseTab(tabElementOrName="", matchMode=3, caseSensitive=True) { 
		if IsObject(tabElementOrName) {
			if (tabElementOrName.CurrentControlType == this.UIA.TabItemControlType)
				try tabElementOrName.FindFirstByName("Close",,1,False).Click()
		} else {
			if (tabElementOrName == "") {
				this.GetTab().FindFirstByName("Close",,1,False).Click()
			} else
				try this.TabBarElement.FindFirstByNameAndType(searchPhrase, "TabItem",, matchMode, caseSensitive).FindFirstByName("Close",,1,False).Click()
		}
	}
	
	; Returns True if any of window 4 corners are visible
	IsBrowserVisible() { 
		WinGetPos, X, Y, W, H, % "ahk_id" this.BrowserId
		if ((this.BrowserId == this.WindowFromPoint(X, Y)) || (this.BrowserId == this.WindowFromPoint(X, Y+H-1)) || (this.BrowserId == this.WindowFromPoint(X+W-1, Y)) || (this.BrowserId == this.WindowFromPoint(X+W-1, Y+H-1)))
			return True
		return False
	}
	
	WindowFromPoint(X, Y) { ; by SKAN and Linear Spoon
		return DllCall( "GetAncestor", "UInt"
			   , DllCall( "WindowFromPoint", "UInt64", X | (Y << 32))
			   , "UInt", GA_ROOT := 2 )
	}

	PrintArray(arr) {
		ret := ""
		for k, v in arr
			ret .= "Key: " k " Value: " (IsFunc(v)? v.name:IsObject(v)?UIA_Browser.PrintArray(v):v) "`n"
		return ret
	}
}