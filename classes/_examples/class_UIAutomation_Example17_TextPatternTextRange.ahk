#NoEnv
#SingleInstance force
SetTitleMatchMode, 2

#include <UIA_Interface>

lorem =
(
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
)

Run notepad.exe
;WinActivate, ahk_exe notepad.exe
UIA := UIA_Interface()
WinWaitActive, ahk_exe notepad.exe
;MsgBox, % UIA.TextPatternRangeEndpoint_Start " " UIA.TextPatternRangeEndpoint_End " " UIA.TextUnit_Character
NotepadEl := UIA.ElementFromHandle(WinExist("ahk_exe notepad.exe"))
editEl := NotepadEl.FindFirstBy("ControlType=Document OR ControlType=Edit") ; Get the Edit or Document element (differs between UIAutomation versions)
editEl.CurrentValue := lorem ; Set the text to our sample text
textPattern := editEl.GetCurrentPatternAs("Text") ; Get the TextPattern

MsgBox, % "TextPattern properties:"
	. "`nDocumentRange: returns the TextRange for all the text inside the element"
	. "`nSupportedTextSelection: " textPattern.SupportedTextSelection
	. "`n`nTextPattern methods:"
	. "`nRangeFromPoint(x,y): retrieves an empty TextRange nearest to the specified screen coordinates"
	. "`nRangeFromChild(child): retrieves a text range enclosing a child element such as an image, hyperlink, Microsoft Excel spreadsheet, or other embedded object."
	. "`nGetSelection(): returns the currently selected text"
	. "`nGetVisibleRanges(): retrieves an array of disjoint text ranges from a text-based control where each text range represents a contiguous span of visible text"

wholeRange := textPattern.DocumentRange ; Get the TextRange for all the text inside the Edit element

MsgBox, % "To select a certain phrase inside the text, use FindText() method to get the corresponding TextRange, then Select() to select it.`n`nPress OK to select the text ""dolor sit amet"""
WinActivate, ahk_exe notepad.exe
wholeRange.FindText("dolor sit amet").Select()
Sleep, 1000

; For the next example we need to clone the TextRange, because some methods change the supplied TextRange directly (here we don't want to change our original wholeRange TextRange). An alternative would be to use wholeRange, and after moving the endpoints and selecting the new range, we could call ExpandToEnclosingUnit() to reset the endpoints and get the whole TextRange back 
textSpan := wholeRange.Clone()

MsgBox, % "To select a span of text, we need to move the endpoints of the TextRange. This can be done with MoveEndpointByUnit.`n`nPress OK to select the text with startpoint of 28 characters from start`nand 390 characters from the end of the sample text"
WinActivate, ahk_exe notepad.exe
textSpan.MoveEndpointByUnit(UIA.TextPatternRangeEndpoint_Start, UIA.TextUnit_Character, 28) ; Move 28 characters from the start of the sample text
textSpan.MoveEndpointByUnit(UIA.TextPatternRangeEndpoint_End, UIA.TextUnit_Character, -390) ; Move 390 characters backwards from the end of the sample text
textSpan.Select()
Sleep, 1000

MsgBox, % "We can also get the location of texts. Press OK to test it"
br := wholeRange.GetBoundingRectangles()
;MsgBox, % br.MaxIndex() " " br[1].l " " br[1].t " " br[1].r " " br[1].b
for _, v in br {
	RangeTip(v.x, v.y, v.w, v.h)
	Sleep, 1000
}
RangeTip()

ExitApp

RangeTip(x:="", y:="", w:="", h:="", color:="Red", d:=2) ; from the FindText library, credit goes to feiyue
{
  local
  static id:=0
  if (x="")
  {
    id:=0
    Loop 4
      Gui, Range_%A_Index%: Destroy
    return
  }
  if (!id)
  {
    Loop 4
      Gui, Range_%A_Index%: +Hwndid +AlwaysOnTop -Caption +ToolWindow
        -DPIScale +E0x08000000
  }
  x:=Floor(x), y:=Floor(y), w:=Floor(w), h:=Floor(h), d:=Floor(d)
  Loop 4
  {
    i:=A_Index
    , x1:=(i=2 ? x+w : x-d)
    , y1:=(i=3 ? y+h : y-d)
    , w1:=(i=1 or i=3 ? w+2*d : d)
    , h1:=(i=2 or i=4 ? h+2*d : d)
    Gui, Range_%i%: Color, %color%
    Gui, Range_%i%: Show, NA x%x1% y%y1% w%w1% h%h1%
  }
}