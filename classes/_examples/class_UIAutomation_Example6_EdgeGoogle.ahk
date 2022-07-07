#NoEnv
#SingleInstance force
SetTitleMatchMode, 2
#include <UIA_Interface>
#include <UIA_Browser>

;~ ^F1::ExitApp
;~ F1::
	browserExe := "msedge.exe"
	Run, %browserExe% -inprivate --force-renderer-accessibility ; Run in Incognito mode to avoid any extensions interfering. Force accessibility in case its disabled by default.
	WinWaitActive, ahk_exe %browserExe%

	cUIA := new UIA_Browser("ahk_exe " browserExe) ; Initialize UIA_Browser, which also initializes UIA_Interface
	;~ cUIA.WaitPageLoad("New Tab", 5000) ; Wait the New Tab page to load with a timeout of 5 seconds
	ToolTip, %  (t.= "Warte auf neuen Tab`n")
	res := cUIA.WaitPageLoad("Neuer Tab", 5000) ; Wait the New Tab page to load with a timeout of 5 seconds
	ToolTip, %  t.= "Neuer Tab ist da!`n"
	sleep 4000
	SoundBeep
	ToolTip, %  t.= "URL Google eingeben!`n"
	cUIA.SetURL("google.com", True) ; Set the URL to google and navigate
	cUIA.WaitPageLoad()

	langBut := cUIA.WaitElementExist("ClassName=neDYw tHlp8d AND ControlType=Button") ; First lets make sure the selected language is correct. First lets get the language menu button using its ClassName
	expandCollapsePattern := langBut.GetCurrentPatternAs("ExpandCollapse") ; Since this isn't a normal button, we need to get the ExpandCollapse pattern for it and then call the correct method.
	if (expandCollapsePattern.CurrentExpandCollapseState == UIA_ExpandCollapseState_Collapsed) ; Check that it is collapsed
		expandCollapsePattern.Expand() ; Expand the menu
	ToolTip, % t.= "englische sprache auswählen`n"
	cUIA.WaitElementExist("Name=English AND ControlType=MenuItem").Click() ; Select the English language
	ToolTip, % t.= "ich stimme zu auswählen`n"

	cUIA.WaitElementExistByNameAndType("I agree", UIA_ButtonControlTypeId).Click() ; If the "I agree" button exists, then click it to get rid of the consent form

	; Looking for a partial name match "Searc" using matchMode=2. FindFirstByNameAndType is not used here, because if the "I agree" button was clicked then this element might not exist right away, so lets first wait for it to exist.
	ToolTip, % t.= "warte auf Combobox`n"
	searchBox := cUIA.WaitElementExist("Name=Searc AND ControlType=ComboBox",,2)
	ToolTip, % t.= "Autohotkey Forum auswählen`n"
	searchBox.SetValue("autohotkey forums") ; Set the search box text to "autohotkey forums"
	ToolTip, % t.= "Google suchen`n"
	cUIA.FindFirstByName("Google Search").Click() ; Click the search button to search
	cUIA.WaitPageLoad()
	ToolTip, % t.= "Google gefunden`n"
	; Now that the Google search results have loaded, lets scroll the page to the end.
	docEl := cUIA.GetCurrentDocumentElement() ; Get the document element
	ToolTip, % t.= "Google scrollen`n"
	sbPat := docEl.GetCurrentPatternAs("Scroll") ; Get the Scroll pattern to access scrolling methods and properties
	hPer := sbPat.CurrentHorizontalScrollPercent ; Horizontal scroll percent doesn't actually interest us, but the SetScrollPercent method requires both horizontal and vertical scroll percents...
	ToolTip, % "Current scroll percent: " sbPat.CurrentVerticalScrollPercent
	for k, v in [10, 20, 30, 40, 50, 60, 70, 80, 90, 100] { ; Lets scroll down in steps of 10%
		sbPat.SetScrollPercent(hPer, v)
		Sleep, 500
		ToolTip, % "Current scroll percent: " sbPat.CurrentVerticalScrollPercent
	}
	Sleep, 3000
	ToolTip, % t.= "`nFERTIG!"
	sleep 10000

ExitApp