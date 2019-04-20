
Class ExplorerTool {
	
	SetViewMode( pMode := 0 ) {
		Static viewModes := {"Icon": 1, "SmallIcon":2, "List":3, "Details":4, "Thumbs":5, "Tile":6, "ThumbStrip":7}
		
		activeSFV := this.GetActiveShellFolderView()
		
		If (activeSFV == "")
			Return
		
		If (viewModes[pMode] != "")
			pMode := viewModes[pMode]
		
		If ((pMode < 1) || (pMode > 7))
			Return
		
		activeSFV.CurrentViewMode := pMode
	}
	
	
	CreateNewFolder( pName := "New Folder" ) {
		activeSFV := this.GetActiveShellFolderView()
		
		If (activeSFV == "")
			Return
		
		newFolderNameX := pName
		
		Loop {
			isAlreadyExists := activeSFV.Folder.ParseName(newFolderNameX)
			
			If (isAlreadyExists == "") {
				activeSFV.Folder.NewFolder(newFolderNameX)
				Break
			}
			
			newFolderNameX := Format("{1} ({2})", newFolderName, A_Index)
		}
		
		newFolderAsItem := activeSFV.Folder.ParseName(newFolderNameX)
		activeSFV.SelectItem(newFolderAsItem, 3|4|8|16)
	}
	
	
	Class LiveQuery {
		Static __Parent     := ""
		Static guiControls  := ""
		Static activeSFV    := ""
		Static focusHandler := ""
		
		
		Init() {
			If (this.__Parent == "") {
				parentClassName := RegexReplace(this.__Class, "\.[^\.]+$", "")
				this.__Parent := %parentClassName%
			}
			
			If (this.focusHandler == "") {
				this.focusHandler := ObjBindMethod(this, "GuiCheckFocus", this)
			}
			
			If (this.guiControls != "")
				Return
			
			
			ETGuiWindowTitle := "ExplorerTool Filter Query"
			ETGuiTextHint    := "Enter query. You can use wildcards * ? #, ""quotes"", pipe|bar,"
					   . "`n" . "size filters >10k <10m and folder keys keys /d /D"
			
			
			Gui, ETGui: New       ,      HWNDhETGuiWindow , % ETGuiWindowTitle
			Gui, ETGui: Add, Text , w500 HWNDhETGuiText   , % ETGuiTextHint
			Gui, ETGui: Add, Edit , w500 HWNDhETGuiEdit   , % ""
			
			Gui, ETGui: +ToolWindow
			
			
			this.guiControls := {}
			this.guiControls["Window"] := hETGuiWindow
			this.guiControls["Edit"  ] := hETGuiEdit
			
			
			Gui, % ("ETGui:+Label" . this.__Class . ".GuiOn")
			
			editHandler := ObjBindMethod(this, "GuiOnEdit", this)
			GuiControl, ETGui: +g, % hETGuiEdit, % editHandler
			
			enterHandler := ObjBindMethod(this, "GuiOnClose", this)
			HotKey, IfWinActive, % ("ahk_id " . this.guiControls["Window"])
			HotKey, Enter, % enterHandler
			HotKey, If
		}
		
		
		GuiOnClose() {
			Gui, ETGui: Hide
		}
		
		GuiOnEscape() {
			Gui, ETGui: Hide
		}
		
		GuiCheckFocus() {
			If (WinActive("A") != this.guiControls["Window"]) {
				this.GuiOnClose()
				Return
			}
			
			focusHandler := this.focusHandler
			SetTimer, % focusHandler, -250
		}
		
		
		GuiOnEdit() {
			GuiControlGet, queryText,, % this.guiControls["Edit"]
			this.__Parent.SelectFiltered(this.activeSFV, queryText)
		}
		
		
		Show() {
			this.Init()
			this.activeSFV := this.__Parent.GetActiveShellFolderView()
			
			If (this.activeSFV == "")
				Return
			
			Gui, ETGui: Show, Y0
			GuiControl,, % this.guiControls["Edit"]
			GuiControl, Focus, % this.guiControls["Edit"]
			
			WinWaitActive % "ahk_id " this.guiControls["Window"]
			this.GuiCheckFocus()
		}
	}
	
	
	SimpleQuery() {
		activeSFV := this.GetActiveShellFolderView()
		
		If (activeSFV == "")
			Return
		
		InputBox, query, % "Enter filter query"
		, % "You can use wildcards *, ? and # for digits"
		. "`nInclude folders with /d or select only folders with /D"
		. "`nFilter size with >100k and <100m"
		. "`nUse quotes if query ""contains spaces"""
		. "`nSelect multiple|several variants with pipe"
		,,,, , 0
		
		If (ErrorLevel == 1)
			Return
		
		this.SelectFiltered(activeSFV, query)
	}
	
	
	GetActiveShellFolderView() {
		activeWindowHWND := WinActive("A")
		
		comShell := ComObjCreate("Shell.Application")
		comShellWindows := comShell.Windows()
		
		comActiveShellView := ""
		
		Loop % comShellWindows.Count {
			comShellWindow := comShellWindows.Item(A_Index-1)
			
			If (comShellWindow.HWND == activeWindowHWND) {
				comActiveShellView := comShellWindow.Document
				Break
			}
		}
		
		Return comActiveShellView
	}
	
	
	SelectFiltered(pSFView, pQuery) {
		Critical
		
		If (pSFView == "")
			Return
		
		filter := this.Filter.Prepare(pQuery)
		comFolderItems := pSFView.Folder.Items
		
		Loop % comFolderItems.Count {
			item := comFolderItems.Item(A_Index-1)
			itemMatch := this.Filter.Match(item, filter)
			
			pSFView.SelectItem(item, itemMatch)
		}
	}
	
	
	Class Filter {
		Static escapeChars := Format("([{1}])", RegexReplace("^$.+\()[]{}", "(.)", "\$1"))
		Static sizeFactors := {B:1,  K:1024,  M:1024**2,  G:1024**3}
		Static sizeRegexp  := "Oi)^(<|>)(\d+)([bkmg]?)$"
		
		Prepare( pQueryText ) {
			filter := {tokens: []}
			
			queryDequote := StrSplit(pQueryText, """")
			
			Loop % queryDequote.Length() {
				newToken := queryDequote[A_Index]
				newToken := RegexReplace(newToken, this.escapeChars, "\$1")
				
				If (A_Index & 1 == 0) {
					filter.tokens.Push(newToken)
					Continue
				}
				
				
				tokens := StrSplit(newToken, " ")
				
				For i, token In tokens {
					If (token == "")
						Continue
					
					token := StrReplace(token, "?", ".")
					token := StrReplace(token, "*", ".*?")
					token := StrReplace(token, "#", "\d")
					
					filter.tokens.Push(token)
				}
			}
			
			
			filter.folders := 0
			filter.sizeMin := -1
			filter.sizeMax := -1
			
			tokensCount := filter.tokens.Length()
			
			Loop % tokensCount {
				tokenIndex := tokensCount + 1 - A_Index
				token := filter.tokens[tokenIndex]
				
				If (token ~= "i)^/d$") {
					filter.folders := (token == "/d") ? 1 : 2
					filter.tokens.RemoveAt(tokenIndex)
					Continue
				}
				
				RegexMatch(token, this.sizeRegexp, tokenSize)
				
				If (tokenSize) {
					sizeFactor := tokenSize[3] ? this.sizeFactors[tokenSize[3]] : 1
					totalSize := Floor(tokenSize[2]) * sizeFactor
					
					If (tokenSize[1] == ">") {
						filter.sizeMin := totalSize
					} Else {
						filter.sizeMax := totalSize
					}
					
					filter.tokens.RemoveAt(tokenIndex)
				}
			}
			
			Return filter
		}
		
		
		Match( pItem, pFilter ) {
			itemIsFolder := (pItem.IsFolder && (pItem.Size == 0))
			
			If (((pFilter.folders == 0) && (itemIsFolder == True))
			||  ((pFilter.folders == 2) && (itemIsFolder == False))
			||  ((pFilter.sizeMin != -1) && (pItem.Size < pFilter.sizeMin))
			||  ((pFilter.sizeMax != -1) && (pItem.Size > pFilter.sizeMax)))
				Return False
			
			If ((pFilter.tokens.Length() == 0)
			&&  (pFilter.sizeMin == -1)
			&&  (pFilter.sizeMax == -1))
				Return False
			
			itemName   := pItem.Name
			
			For i, token In pFilter.tokens {
				If ((itemName ~= ("i)" . token)) == 0) {
					Return False
				}
			}
			
			Return True
		}
	}
}


#If WinActive("ahk_class ExploreWClass") || WinActive("ahk_class CabinetWClass")
^q::
	; ExplorerTool.SimpleQuery()
	ExplorerTool.LiveQuery.Show()
	Return

^n::
	ExplorerTool.CreateNewFolder()
	Return

^1::
	ExplorerTool.SetViewMode("List")
	Return

^2::
	ExplorerTool.SetViewMode("Details")
	Return

^3::
	ExplorerTool.SetViewMode("Thumbs")
	Return
