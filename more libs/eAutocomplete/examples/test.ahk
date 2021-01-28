#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir "\..\"
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode


; Menu.itemsBox.font.size
; Menu.itemsBox.font.color
; Menu.itemsBox.bkColor

CoordMode, ToolTip, Screen

#Include %A_ScriptDir%\eAutocomplete.ahk
list =
(Join`n
voiture	car	автомобиль
voir	car	автомобиль
voirie
voile	car	автомобиль
  voileaaa	car	автомобиль
 voilezz	car	автомобиль
	voilaaae	car	автомобиль
vie
jour	day	день
joie	day	день
juste	day	день
javelot
centre
)
; source := eAutocomplete.WordList.buildFromVar("", list)
; source := eAutocomplete.WordList.buildFromVar("mySource", list)
; MsgBox % source.name "," source.collectWords "," source.collectAt
; eAutocomplete.WordList.buildFromFile("mySource", A_ScriptDir . "\blabla", A_Desktop . "\blabla.dbg", true) ; -1
eAutocomplete.WordList.buildFromFile("mySource", A_ScriptDir . "\autocompletion\fr", A_ScriptDir . "\autocompletion\autocompletion.dbg", true) ; -1
; eAutocomplete.WordList.setFromFile("mySource", A_ScriptDir . "\autocompletion\autocompletion.dbg", -1, false)

Loop, 2 {
	GUI, New
	GUI, Font, s14, Segoe UI
	GUI, Add, Edit, hwndhEdit w200 h200
	GUI, Add, Text, w200 h200
	GUI, Add, Edit, w200 h200
	GUI, Show, AutoSize, eAutocomplete
	GUI, Show, w500, eAutocomplete
	; eAutocomplete.wrap("blabla")
	eAutocomplete.wrap(hEdit)
}
; eAutocomplete.WordList := "blabla"
; eAutocomplete.WordList.name := "blabla"
eAutocomplete.resource := "mySource"
; MsgBox % eAutocomplete.resource.name
source := eAutocomplete.resource
source.learnWords := true
source.collectWords := true
source.collectAt := 4
query := source.Query
; MsgBox % query.Sift.option := "blabla"
query.Sift.option := "OC"
; MsgBox % query.Word.minLength := "blabla"
; MsgBox % query.Word.minLength := 0
; MsgBox % query.Word.minLength := 1
; query.Sift.caseSensitive := "blabla"
; query.Sift.delimiter := "blabla"
; query.Sift := "blabla"
; query.Word := "blabla"
; query.Sift.option := "REGEX"
; query.Word.edgeKeys := ""
Menu := eAutocomplete.Menu
; Menu.itemsBox.font.size := 14
; Menu.itemsBox.font.size := "blabla"
; Menu.itemsBox.font.color := "FFFFFF"
; MsgBox % Menu.itemsBox.font.color := "blabla"
Menu.itemsBox.font.name := "Showcard Gothic"
; MsgBox % Menu.itemsBox.font.name := "blabla"
Menu.transparency := 230
; MsgBox % Menu.transparency := "blabla"
Menu.bkColor := "131584"
; MsgBox % Menu.bkColor := "blabla"
Menu.Positioning.offsetX := 10
; MsgBox % Menu.Positioning.offsetX := "blabla"
Menu.Positioning.offsetY := 10
Menu.InfoTip.Positioning.offsetX := 10
Menu.InfoTip.font.setCharacteristics("Showcard Gothic", "s15 bold italic")
; MsgBox % Menu.InfoTip.font.setCharacteristics("blabla", "blabla")
Menu.itemsBox.maxVisibleItems := 3
; MsgBox % Menu.itemsBox.maxVisibleItems := "blabla"
Hotkey := eAutocomplete.Hotkey
Hotkey.Menu.hide("^Esc")
; Hotkey.Menu.hide("blabla")
Hotkey.Menu.itemsBox.selectPrevious("") ; <<<<
Hotkey.Menu.itemsBox.selectNext("+Up")
Hotkey.Menu.itemsBox.selectPrevious("+Down")
Hotkey.complete("Tab")
; Hotkey.complete("blabla")
Hotkey.completeAndGoToNewLine("Enter")
Hotkey.lookUpSuggestion("+Right")
Hotkey.invokeMenu("^+Down")
; eAutocomplete.OnComplete("blabla")
eAutocomplete.OnComplete("eA_onComplete")
eAutocomplete.OnReplacement("eA_onReplacement")
eAutocomplete.OnSuggestionLookUp("eA_onSuggestionLookUp")
; ControlGet, hwnd, Hwnd,, Edit1, ahk_class Notepad
; eAutocomplete.wrap(hwnd)
; ControlGet, hwnd, Hwnd,, RICHEDIT50W1, ahk_class WordPadClass
; eAutocomplete.wrap(hwnd)
; ControlGet, hwnd, Hwnd,, RICHEDIT50W2, Poor Man's Rich Edit
; eAutocomplete.wrap(hwnd)
return

!x::
ExitApp

eA_onComplete(_suggestion, ByRef _expandModeOverride:="") {
return _suggestion "/" A_ThisFunc ; , _expandModeOverride:=1
; return "/" _suggestion "/" ; , _expandModeOverride:=1
}
eA_onReplacement(_suggestion, ByRef _expandModeOverride:="") {
return _suggestion "(" A_ThisFunc ")" ; , _expandModeOverride:=-1
; return "[" _suggestion "]" ; , _expandModeOverride:=-1
}
eA_onSuggestionLookUp(_selectionText) {
return _selectionText "(" A_ThisFunc ")"
; return "[" _selectionText "(" A_ThisFunc ")]"
}


^d::eAutocomplete.disabled := !eAutocomplete.disabled
!i::MsgBox, 64,, % eAutocomplete.__Version
!a::eAutocomplete.autoSuggest := !eAutocomplete.autoSuggest
; !w::eAutocomplete.unwrap(""), eAutocomplete.unwrap("blabla")
; ^w::eAutocomplete.wrap(hEdit)
!w::eAutocomplete.unwrap(hEdit), eAutocomplete.unwrap(hwnd)
; !c::eAutocomplete.Completor.expandMode := "blabla"
!c::eAutocomplete.Completor.expandMode := 0
^!c::eAutocomplete.Completor.correctCase := !eAutocomplete.Completor.correctCase
; !t::eAutocomplete.Menu.positioningStrategy := "blabla"
!t::eAutocomplete.Menu.positioningStrategy := "DropDownList"
!p::
	ListLines
	Pause
return
; !+p::ToolTip % "eAutocomplete.Menu.InfoTip.positioningStrategy " eAutocomplete.Menu.InfoTip.positioningStrategy:="blabla"
!+p::ToolTip % "eAutocomplete.Menu.InfoTip.positioningStrategy " eAutocomplete.Menu.InfoTip.positioningStrategy
; !b::ToolTip % "eAutocomplete.Menu.bkColor " eAutocomplete.Menu.bkColor:="blabla"
!b::ToolTip % "eAutocomplete.Menu.bkColor " eAutocomplete.Menu.bkColor
; ^!s::ToolTip % "eAutocomplete.Menu.itemsBox.selection.text " eAutocomplete.Menu.itemsBox.selection.text:="blabla"
^!s::ToolTip % "eAutocomplete.Menu.itemsBox.selection.text " eAutocomplete.Menu.itemsBox.selection.text
; !s::ToolTip % "eAutocomplete.Menu.itemsBox.selection.index " eAutocomplete.Menu.itemsBox.selection.index:=3.14
!s::ToolTip % "eAutocomplete.Menu.itemsBox.selection.index " eAutocomplete.Menu.itemsBox.selection.index
; !k::ToolTip % eAutocomplete.keypressThreshold := 45 ; <<<<
!k::eAutocomplete.keypressThreshold := 550 ; <<<<
!r::eAutocomplete.resource := (eAutocomplete.resource.name = "") ? "mySource" : ""
