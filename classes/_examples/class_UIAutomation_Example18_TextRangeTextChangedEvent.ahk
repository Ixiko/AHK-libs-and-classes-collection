#NoEnv
#SingleInstance force
SetTitleMatchMode, 2

#include <UIA_Interface>

UIA := UIA_Interface() ; Initialize UIA interface
program := "Document1 - Word"
WinActivate, %program%
WinWaitActive, %program%
wordEl := UIA.ElementFromHandle(WinExist(program))
bodyEl := wordEl.FindFirstBy("AutomationId=Body") ; First get the body element of Word
textPattern := bodyEl.GetCurrentPatternAs("Text") ; Get TextPattern for the body element
document := textPattern.DocumentRange ; Get the TextRange for the whole document

MsgBox, % "Current text inside Word body element:`n" document.GetText() ; Display the text from the TextRange
WinActivate, %program%

MsgBox, % "We can get text from a specific attribute, such as text within a ""bullet list"".`nTo test this, create a bullet list (with filled bullets) in Word and press OK."
MsgBox, % "Found the following text in bullet list:`n" document.FindAttribute(UIA_Enum.UIA_BulletStyleAttributeId, UIA_Enum.BulletStyle_FilledRoundBullet).GetText()

Loop {
	InputBox, font, Find, % "Search text in Word by font. Type some example text in Word.`nThen write a font (such as ""Calibri"") and press OK`n`nNote that this is case-sensitive, and fonts start with a capital letter`n(""calibri"" is not the same as ""Calibri"")"
	if ErrorLevel
		break
	else if !font
		MsgBox, You need to type a font to search!
	else if (found := document.FindAttribute(UIA_Enum.UIA_FontNameAttributeId, font).GetText())
		MsgBox, % "Found the following text:`n" found
	else
		MsgBox, No text with the font %font% found!
}

MsgBox, % "Press OK to create a new EventHandler for the TextChangedEvent.`nTo test this, type some new text inside Word, and a tooltip should pop up.`n`nTo exit the script, press F5."
handler := UIA_CreateEventHandler("TextChangedEventHandler") ; Create a new event handler that points to the function TextChangedEventHandler, which must accept two arguments: element and eventId.
UIA.AddAutomationEventHandler(UIA.Text_TextChangedEventId, wordEl,,, handler) ; Add a new automation handler for the TextChanged event. Note that we can only use wordEl here, not bodyEd, because the event is handled for the whole window.
OnExit("ExitFunc") ; Set up an OnExit call to clean up the handler when exiting the script

return

TextChangedEventHandler(el, eventId) {
	try {
		textPattern := el.GetCurrentPatternAs("Text")
		ToolTip, % "You changed text in Word:`n`n" textPattern.DocumentRange.GetText()
		SetTimer, RemoveToolTip, -2000
	}
}

ExitFunc() {
	global UIA, handler, bodyEl
	UIA.RemoveAutomationEventHandler(UIA.Text_ChangedEventId, bodyEl, handler) ; Remove the event handler. Alternatively use UIA.RemoveAllEventHandlers() to remove all handlers
}

RemoveToolTip:
	ToolTip
	return

F5::ExitApp
