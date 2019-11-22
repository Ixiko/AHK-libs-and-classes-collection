
/*  Excel_Functions() V4, Date: Sun April 24, 2011, Author: tidbit

Forum: http://www.autohotkey.com/forum/viewtopic.php?t=70421
version: 4

Credits:  BigVent, jethrow, rippa, sinkfaze

Please Note: I only have excel 2002. and I have had someone with Excel 2007 help test SOME of these functions. Several values in certain functions may ONLY work in Excel 2007+.


What's new in 4:
 - Excel_SetSplit
 - Excel_SplitPanes
 - Excel_ScreenUpdate
 - Excel_GetSelection
 - Preparing the Docs for Natural Docs


todo list (no order):
 - Better Documentation
 - PasteSpecial


Function list:

  Note: Everything inside of the []'s are OPTIONAL.
  Note: DO NOT include the []'s in your actual code.
  Note: More documentation and samples can be found below.

  Excel_Get([_WinTitle])

  Excel_ActiveCell(_ID)
  Excel_GetActiveRow(_ID)
  Excel_GetActiveColumn(_ID)
  Excel_GetActiveText(_ID)
  Excel_GetSelection(_ID)

  Excel_GetValue(_ID [, _start])
  Excel_GetRowHeight(_ID [, _start, _end])
  Excel_GetColWidth(_ID [, _start, _end])

  Excel_AutoFill(_ID [, _start, _end, _Sources, _type])
  Excel_SetRowHeight(_ID [, _start, _end, _value])
  Excel_SetColWidth(_ID [, _start, _end, _value])
  Excel_SetValue(_ID [, _start, _end, _value])
  Excel_SetStyle(_ID [, _start, _end, _style])
  Excel_Select(_ID [, _start, _end])
  Excel_SetActive(_ID [, _start])
  Excel_SetFormula(_ID [, _start, _end, _value])

  Excel_ScreenUpdate(_ID)
  Excel_SplitPanes(_ID)
  Excel_SetSplit(_ID [, _which, _where)

  Excel_DelCells(_ID [, _start, _end, _direction])
  Excel_ClearText(_ID [, _start, _end])
  Excel_ClearAll(_ID [, _start, _end])

  Excel_ClearFormatting(_ID [, _start, _end])

  Excel_BgColor(_ID [, _start, _end, _color])
  Excel_Font(_ID [,_start, _end, _options, _Font])
  Excel_Borders(_ID [, _start, _end, _options])

*/

; Important Stuff
Excel_Get(_WinTitle="ahk_class XLMAIN") {													;-- Create an _ID variable used in all other commands.
	/*									Function: Excel_Get([_WinTitle])


		Create an _ID variable used in all other commands.

	  Parameters:

		_WinTitle - Default is the main/active document. Otherwise specify the title of your desired Excel document.

	  Sample:
		; NOTE: this value (xls) will be used throughout all other samples.
		xls:=Excel_Get() ; Get the current Active Excel window/document.

	*/
	ControlGet, hwnd, hwnd, , Excel71, %_WinTitle%
    return, Excel_Acc_ObjectFromWindow(hwnd, -16).Application
}

;  Active Cell
Excel_ActiveCell(_ID) {																					;-- A combination of Excel_GetActiveCol() and Excel_GetActiveRow()

	/*													Excel_GetActiveCell(_ID [, _Name])

	  A combination of Excel_GetActiveCol() and Excel_GetActiveRow()

	  Parameters:

	  _ID - The specified Excel Object.
	  _Name - Default is 1. If the _value is 1, the it retrieves the columns name. Such as: C. Otherwise it returns the column index number.

	  Sample:

	  OutputVar:=Excel_GetActiveCell(xls)
	  Msgbox %OutputVar%
	*/

  Return _ID.ActiveCell.Address[0,0]
}
Excel_GetActiveRow(_ID) {																				;--
	/*										Excel_GetActiveRow(_ID)


	  Parameters:

		_ID - The specified Excel Object.

	  Sample:
		OutputVar:=Excel_GetActiveRow(xls)
		Msgbox %OutputVar%
	*/
	Return _ID.ActiveCell.Row
}
Excel_GetActiveCol(_ID) {																				;--
	/*										Excel_GetActiveColumn(_ID [, _Name])


	  Parameters:

		_ID - The specified Excel Object.
		_Name - Default is 1. If the value is 1, the it retrieves the columns name. E.g. C. Otherwise it returns the column index number.

	  Sample:
		OutputVar:=Excel_GetActiveCol(xls)
	*/
	Return RegExReplace(_ID.ActiveCell.Address[0,0], "\d")
}
Excel_GetActiveText(_ID) {																				;--
	/*										Excel_GetActiveText(_ID)


	  Parameters:

		_ID - The specified Excel Object.

	  Sample:
		OutputVar:=Excel_GetActiveText(xls)
		Msgbox %OutputVar%
	*/
  Return _ID.ActiveCell.value
}
Excel_GetSelection(_ID) {																				;--
	/*
	Excel_GetSelection(_ID)


	  Parameters:

		_ID - The specified Excel Object.

	  Sample:
		OutputVar:=Excel_GetActiveText(xls)
		Msgbox %OutputVar%
	*/
Return _ID.Selection.Address[0,0]
}

; Get
Excel_GetValue(_ID, _start="A1") {																	;--
	/*											Excel_GetText(_ID [, _start])

	  Parameters:

		_ID - The specified Excel Object.
		_start - Default is A1. Retrieve the text of the specified cell.

	  Sample:
		OutputVar:=Excel_GetActiveCell(xls, "C4")
		Msgbox %OutputVar%
	*/
	If (StrLen(_start)<2)
		Return 1
	Return _ID.Range(_start).value
}
Excel_GetRowHeight(_ID, _start="1", _end="") {												;--
	/* 									Excel_GetRowHeight(_ID [, _start, _end])


	  Parameters:

		_ID - The specified Excel Object.
		_start - Default is 1. The starting cell row number.
		_end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending row number.

	  Sample:
		OutputVar:=Excel_GetRowHeight(xls, 3)
		Msgbox %OutputVar%
	*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<1 || StrLen(_end)<1)
    Return 1
  _value:=_ID.Rows(_start ":" _end).RowHeight
  Return (_value!="") ? _value : "Varying"
}
Excel_GetColWidth(_ID, _start="A", _end="") {												;--
	/*									Excel_GetColWidth(_ID [, _start, _end])
	   Parameters:

		_ID - The specified Excel Object.
		_start - Default is A. The starting cell column letter.
		_end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending column letter.

	  Sample:
		OutputVar:=Excel_GetColWidth(xls, C)
		Msgbox %OutputVar%
	*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<1 || StrLen(_end)<1)
    Return 1
  _value:=_ID.Columns(_start ":" _end).ColumnWidth
  Return (_value!="") ? _value : "Varying"
}

; Set
Excel_AutoFill(_ID, _start="A1", _end="", _Sources="A1", _Type="Default") {	;--
	/*
	Excel_AutoFill(_ID [, _start, _end, _Sources, _Type])


	  Parameters:

		_ID - The specified Excel Object.
		_start - Default is 1. The starting row number.
		_end - Default is "" Blank. If blank, it defaults to _start. Otherwise specify the ending row number.
		_Sources - Default is A1. Specify a cell or cell range in Excel format. E.g. A1 or A2:D2
		_Type - Default is Default. View chart below for other options.

	Options:
	  Default  | xlFillDefault  | 0  | Excel determines the values and formats used to fill the target range.
	  Copy     | xlFillCopy     | 1  | Copy the values and formats from the source range to the target range, repeating if necessary.
	  Values   | xlFillValues   | 4  | Copy only the values from the source range to the target range, repeating if necessary.
	  Days     | xlFillDays     | 5  | Extend the names of the days of the week in the source range into the target range. Formats are copied from the source range to the target range, repeating if necessary.
	  Weekdays | xlFillWeekdays | 6  | Extend the names of the days of the workweek in the source range into the target range. Formats are copied from the source range to the target range, repeating if necessary.
	  Months   | xlFillMonths   | 7  | Extend the names of the months in the source range into the target range. Formats are copied from the source range to the target range, repeating if necessary.
	  Years    | xlFillYears    | 8  | Extend the years in the source range into the target range. Formats are copied from the source range to the target range, repeating if necessary.
	  Formats  | xlFillFormats  | 3  | Copy only the formats from the source range to the target range, repeating if necessary.
	  Series   | xlFillSeries   | 2  | Extend the values in the source range into the target range as a series (for example, '1, 2' is extended as '3, 4, 5'). Formats are copied from the source range to the target range, repeating if necessary.
	  Gtrend   | xlGrowthTrend  | 10 | Extend the numeric values from the source range into the target range, assuming that the relationships between the numbers in the source range are multiplicative (for example, '1, 2,' is extended as '4, 8, 16', assuming that each number is a result of multiplying the previous number by some value). Formats are copied from the source range to the target range, repeating if necessary.
	  Ltrend   | xlLinearTrend  | 9  | Extend the numeric values from the source range into the target range, assuming that the relationships between the numbers is additive (for example, '1, 2,' is extended as '3, 4, 5', assuming that each number is a result of adding some value to the previous number). Formats are copied from the source range to the target range, repeating if necessary.

	  Sample:
		; As a test, open excel and insert 1 into A1 and 2 into A2
		Excel_Autofill(xls, "A1", "A22", "A1:A2", "Copy")
	*/
  static _Table:=Object("Copy", 1, "Days", 5, "Default", 0, "Formats", 3
                , "Months", 7, "Series", 2, "Values", 4, "Weekdays", 6
                , "Years", 8, "Gtrend", 10, "Ltrend", 9)

	_end:=(_end=="") ? _start : _end
  If (StrLen(_start)<2 || StrLen(_end)<2)
    Return 1

  _SourceRange:=_ID.Range(_Sources)
  _FillRange:=_ID.Range(_start ":" _end)
  _SourceRange.AutoFill(_FillRange, _Table[_Type])

; _sourceRange := _id.Range(_Sources)
; _fillRange := _id.Range(_start ":" _end)
; _sourceRange.AutoFill(_fillRange, _Table[_Type])


	}
Excel_SetRowHeight(_ID, _start="1", _end="", _value="Default" ) {					;--
/*
Excel_SetRowHeight(_ID [, _start, _end, _value])


  Parameters:

    _ID - The specified Excel Object.
    _start - Default is 1. The starting row number.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending row number.
    _value - Default is Default. If Default, row height is adjusted to the documents standard row height. Otherwise specify the height you want in Points (Same unit as text height).

  Sample:
    ; This will adjust rows 1 through 5 to the height of a size 16 font.
    Excel_SetRowHeight(xls, 1, 5, 16)
*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<1 || StrLen(_end)<1)
    Return 1

  if (_value="Default")
    _ID.Rows(_start ":" _end).RowHeight:=_ID.StandardHeight
  else if (_value!="")
    _ID.Rows(_start ":" _end).RowHeight:=_value
  Else
    Return 1
}
Excel_SetColWidth(_ID, _start="A", _end="", _value="AutoFit") {						;--
/*
Excel_SetColWidth(_ID [, _start, _end, _value])


  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A. The starting column letter.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending column letter.
    _value - Default is Autofit. Otherwise specify a custom number or the word Default
      Autofit : Auto adjust the columns with to fit the contents.
      Default : Adjust to the documents standard column width.
      Custom #: A width of 1 would adjust the column to 1 letter wide, using the default font size.

  Sample:
    ; This will set Columns A, B and C to 12 letters wide using the default font size.
    Excel_SetColWidth(xls, "A", "C", 12)
*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<1 || StrLen(_end)<1)
    Return 1

  if (_value="Default")
    _ID.Columns(_start ":" _end).ColumnWidth:=_ID.StandardWidth
  else if (_value="AutoFit")
    _ID.Columns(_start ":" _end).AutoFit
  else if (_value!="")
    _ID.Columns(_start ":" _end).ColumnWidth:=_value
  Else
    Return 1
}
Excel_SetValue(_ID, _start="A1", _end="", _value="") {									;--
/*
Excel_SetText(_ID [, _start, _end, _value])


  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A1. The starting cell.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending cell.
    _value - Default is "" (blank). The text you want to fill the specified cell(s) with.

  Sample:
    Excel_SetText(xls, "A1", "", "Hello")
*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<2 || StrLen(_end)<2)
    Return 1

  _ID.Range(_start ":" _end).value:=_value
}
Excel_SetStyle(_ID, _start="A1", _end="", _Style="Normal") {							;--
/*
Excel_SetStyle(_ID [, _start, _end, _Style])


  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A1. The starting cell.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending cell.
    _Style - Default is Normal. NOTE: I couldn't find any list or documentation on this. But I think this is fairly accurate: For a list of available styles: 1)open Excel, 2)Go to Format --> Cells, 3)You should then see a tab called "Numbers". 4)Choose a name from that list.

  Sample:
    ; Set the text/number style in range A1:G100 to the Normal style.
    Excel_SetStyle(xls, "A1", "G100")
*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<2 || StrLen(_end)<2)
    Return 1

  _ID.Range(_start ":" _end).Style:=_Style
}
Excel_Select(_ID, _start="A1", _end="") {														;--
/*
Excel_Select(_ID [, _start, _end])


  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A1. The starting cell.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending cell for the selection range.

  Sample:
    ; Select all cells in the range A1:G100
    Excel_Select(xls, "A1", "G100")
*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<2 || StrLen(_end)<2)
    Return 1

  _ID.Range(_start ":" _end).Select
}
Excel_SetActive(_ID, _start="A1") {																	;--
/*
Excel_SetActive(_ID [, _start])


  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A1. The cell you want to set as the active cell.

  Sample:
    Excel_SetActive(xls, "B7")
*/
  If (StrLen(_start)<2)
    Return 1

  _ID.Range(_start).Activate
}
Excel_SetFormula(_ID, _start="A1", _end="", _value="SUM") {							;--
/*
Excel_SetFormula(_ID [, _start, _end, _value])


  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A1. The starting cell.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending cell.
    _value - Default is SUM. enter a valid Excel formula. The preceding = is optional.

  Sample:
    Excel_SetFormula(xls, "A1", "B1", "Sum(6+7)")
    Excel_SetFormula(xls, "A1", "B1", "=Sum(8+9)")
*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<2 || StrLen(_end)<2)
    Return 1

  If (SubStr(_value, 1, 1)=="=")
    _ID.Range(_start ":" _end).Formula:= _value
  Else
    _ID.Range(_start ":" _end).Formula:= "=" _value
}

; General
Excel_ScreenUpdate(_ID) {																				;--
/*
Excel_ScreenUpdate(_ID)

  Parameters:

    _ID - The specified Excel Object.

*/
   return _ID.ScreenUpdating := !_ID.ScreenUpdating ? True : False
}
Excel_SplitPanes(_ID) {																					;--
/*
Excel_SplitPanes(_ID)

  Parameters:

    _ID - The specified Excel Object.

*/
   _ID.ActiveSheet.Activate()
   return   _ID.ActiveWindow.FreezePanes :=   !_ID.ActiveWindow.FreezePanes ? True : False
}
Excel_SetSplit(_ID,_Which="Row",_Where=1) {  												;-- specify 'Row' or 'Col' for Which
/*
Excel_SetSplit(_ID [, _Which, _Where)

  Parameters:

    _ID - The specified Excel Object.
    _Which - Default is Row. Specify how you would like to split: Col or Row
    _Where - Default is 1. Specify the row or column number you want to split.

*/

   sheet.Activate()
   if   (_Which="Row")
      _ID.ActiveWindow.SplitRow :=   _Where
   else   _ID.ActiveWindow.SplitColumn :=   _Where
   return   _ID.ActiveWindow.FreezePanes :=   True
}
Excel_DelCells(_ID, _start="A1", _end="", _Direction="Up") {							;--
/*
Excel_DelCells(_ID [, _start, _end, _Direction])

    Deletes and moves other cells

  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A1. The starting cell.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending cell.
    _Direction - Default is Up. Specify the direction you wan the other cells to shift.
      Up  : Shift the below cells upwards.
      Left: Shift the cells to the right leftwards.

  Sample:
    Excel_DelCells(xls, "A1", "Z1")
*/
  _Direction:=(_Direction="Up") ? -4162 : -4159

  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<2 || StrLen(_end)<2)
    Return 1

  _ID.Range(_start ":" _end).Delete(_Direction)
}
Excel_ClearText(_ID, _start="A1", _end="") {													;--
/*
Excel_ClearText(_ID [, _start, _end])

    Deletes text and formulas

  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A1. The starting cell.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending cell.

  Sample:
    Excel_ClearText(xls, "A1", "ZZ100")
*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<2 || StrLen(_end)<2)
    Return 1

  _ID.Range(_start ":" _end).ClearContents
}
Excel_ClearAll(_ID, _start="A1", _end="") {														;--
/*
Excel_ClearAll(_ID [, _start, _end])

    clears everything, even formatting and colors

  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A1. The starting cell.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending cell.

  Sample:
    Excel_ClearAll(xls, "A1", "B2")
*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<2 || StrLen(_end)<2)
    Return 1

  _ID.Range(_start ":" _end).Clear
}

; Formatting
Excel_ClearFormatting(_ID, _start="A1", _end="") {										;--
/*
Excel_ClearFormatting(_ID [, _start, _end])


  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A1. The starting cell.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending cell.

  Sample:
    Excel_ClearFormatting(xls, "A1", "D97")
*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<2 || StrLen(_end)<2)
    Return 1

  _ID.Range(_start ":" _end).ClearFormats
}
Excel_BgColor(_ID, _start="A1", _end="", _Color="19") {								;--
/*
Excel_BgColor(_ID [, _start, _end, _Color])


  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A1. The starting cell.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending cell.
    _Color - Default is 19. Specify the Excel Color Index value.

  Sample:
    Excel_BgColor(xls, "A1", "F1", 8)
*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<2 || StrLen(_end)<2)
    Return 1

  _ID.Range(_start ":" _end).Interior.ColorIndex:=_Color
}
Excel_Font(_ID, _start="A1", _end="", _Options="B", _Font="") {						;--
/*
Excel_Font(_ID [,_start, _end, Options, Font])


  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A1. The starting cell.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending cell.
    _Options - Default is B. See below for more options.


Options:
  On or On:   | (Default) If specified, B, I, U, S, Sub, Sup, or Strike Will be applied to the cell(s).
  Off or Off: | If specified, B, I, U, S, Sub, Sup, or Strike Will be removed from the cell(s).
  Sub         | Subscript.
  Sup         | Superscript.
  Strike      | Strikethrough.
  B           | Bold.
  I           | Italic.
  U#          | Underline. If no number is given, it uses a standard solid underline. View chart below for more.
  S#          | Size. Specify a font size number. Example: S12.
  J#          | Justify or Align the Cells. if no value is given, Defaults to Left. View chart below for more.
  C#          | Text color. Give a valid Excel ColorIndex value.
  BG#         | Background color. Give a valid Excel ColorIndex value. View chart below for more.

Background options:
  bg# | Any valid Excel Color Index number
  bgA | xlBackgroundAutomatic   | -4105 | Excel controls the background.
  bgO | xlBackgroundOpaque      | 3     | Opaque background.
  bgT | xlBackgroundTransparent | 2     | Transparent background.

Underline styles:
  u  | xlUnderlineStyleSingle           | 2     | Single underlining.
  u2 | xlUnderlineStyleDoubleAccounting | 5     | Two thin underlines placed close together.
  u3 | xlUnderlineStyleDouble           | -4119 | Double thick underline.
  u4 | xlUnderlineStyleNone             | -4142 | No underlining.

Align Options:
  j   | xlHAlignLeft                  | -4131 | Align the text to the left.
  jl  | xlHAlignLeft                  | -4131 | Align the text to the left.
  jR  | xlHAlignRight                 | -4152 | Align the text to the right.
  jC  | xlHAlignCenterAcrossSelection | 7     | Align the text to the center of the cell.
  jJ  | xlHAlignJustify               | -4130 | Align the text to the justified.
  jD  | xlHAlignDistributed           | -4117 | Distribute the text evenly thoughout the cell.
  jG  | xlHAlignGeneral               | 1     | Standard alignment.
  jF  | xlHAlignFill                  | 5     | Repeat the text in the cell until filled.
  jA  | xlHAlignCenter                | -4108 | Align the text to the center of the cell.
  jvT | xlVAlignTop                   | -4160 | Center the text on the top of the cell.
  jvC | xlVAlignCenter                | -4108 | Center the text in the center of the cell.
  jvB | xlVAlignBottom                | -4107 | Center the text on the bottom of the cell.
  jvD | xlVAlignDistributed           | -4117 | Center the text evenly (vertically) throughout the cell.
  jvJ | xlVAlignJustify               | -4130 | Center the text evenly (vertically) throughout the cell.

  Samples:
    ; Make the text Bold and underlined
    Excel_Font(xls, "A1", "B2", "B U")

    ; Remove Italics from the range.
    Excel_Font(xls, "A1", "B2", "Off: I")

    ; Add Italics and remove any Superscript from the range.
    Excel_Font(xls, "A1", "B2", "Off: Sub On: I")


*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<2 || StrLen(_end)<2)
    Return 1

  Mode:=1
  static _Table:=Object("u", 2, "u2", 5, "u3", -4119, "u4", -4142            ; Underline
                ,"bgA", -4105, "bgO", 3, "bgT", 2                     ; Backgrounds
                ,"j", -4131, "jl", -4131, "jR", -4152, "jA", -4108    ; Horizontal Alignment
                ,"jJ", -4130, "jD", -4117, "jG", 1, "jF", 5, "jC", 7  ; Horizontal Alignment
                ,"jvT", -4160, "jvC", -4108, "jvB", -4017             ; Vertical Alignment
                , "jvD", -4117, "jvJ", -4130)                         ; Vertical Alignment


  FontObject:=_ID.Range(_start ":" _end).Font

  loop, parse, _Options, %A_Space% %A_Tab%
  {
    ; rename A_LoopField as ALF just to reduce the length of the code a bit.
    ALF:=A_LoopField

    If (ALF=="")
      Continue

    If (ALF="On" || ALF="On:")
      Mode:=1
    If (ALF="Off" || ALF="Off:")
      Mode:=0

    ; msgbox % ALF " - " Backgrounds[ALF]

    letter:=SubStr(ALF, 1, 1)
    If (ALF="Sub")
      FontObject.SubScript:=Mode
    Else If (ALF="Sup")
      FontObject.Superscript:=Mode
    Else If (ALF="Strike")
      FontObject.StrikeThrough:=Mode
    Else If (SubStr(ALF, 1, 2)="BG"
         && (SubStr(ALF, 3, 1)="T"
         || SubStr(ALF, 3, 1)="O"
         || SubStr(ALF, 3, 1)="A"))
      _ID.Range(_start ":" _end).Interior.ColorIndex:=_Table[ALF]
    Else If (SubStr(ALF, 1, 2)="BG")
      _ID.Range(_start ":" _end).Interior.ColorIndex:=SubStr(ALF, 3, StrLen(ALF))
    Else If (letter="B")
      FontObject.Bold:=Mode
    Else If (letter="I")
      FontObject.Italic:=Mode
    Else If (letter="U")
      FontObject.Underline:=_Table[ALF]
    Else If (letter="S")
      FontObject.Size:=SubStr(ALF, 2, StrLen(ALF)-1)
    Else If (SubStr(ALF, 1, 2)="jv")
      _ID.Range(_start ":" _end).VerticalAlignment:=_Table[ALF]
    Else If (letter="J")
      _ID.Range(_start ":" _end).HorizontalAlignment:=_Table[ALF]
    Else If (letter="C")
      FontObject.ColorIndex:=SubStr(ALF, 2, StrLen(ALF)-1)
    Else
      Continue
  }
  If (Font!="")
    FontObject.FontStyle:=_Font
}
Excel_Borders(_ID, _start="A1", _end="", _Options="s1 w2 c1 pt pb pl pr") {	;--
/*
Excel_Borders(_ID [, _start, _end, _Options])


  Parameters:

    _ID - The specified Excel Object.
    _start - Default is A1. The starting cell.
    _end - Default is "" (Blank). If blank, it defaults to _start. Otherwise specify the ending cell.
    _options - Default is "s1 w2 c1 pt pb pl pr" (A thin solid outline of the cell). See below for more options.

Some values may only work on Office 2007 and up.

Line styles:
  s0 | xlLineStyleNone | -4142 | No line.
  s1 | xlContinuous    | 1     | Continuous line.
  s2 | xlDash          | -4115 | Dashed line.
  s3 | xlDashDot       | 4     | Alternating dashes and dots.
  s4 | xlDashDotDot    | 5     | Dash followed by two dots.
  s5 | xlDot           | -4118 | Dotted line.
  s6 | xlDouble        | -4119 | Double line.
  s7 | xlSlantDashDot  | 13    | Slanted dashes.

Line positions:
  pT  | xlEdgeTop          |  8 | Border at the top of the range.
  pB  | xlEdgeBottom       |  9 | Border at the bottom of the range.
  pL  | xlEdgeLeft         |  7 | Border at the left-hand edge of the range.
  pR  | xlEdgeRight        | 10 | Border at the right-hand edge of the range.
  pH  | xlInsideHorizontal | 12 | Horizontal borders for all cells in the range except borders on the outside of the range.
  pV  | xlInsideVertical   | 11 | Vertical borders for all the cells in the range except borders on the outside of the range.
  p\  | xlDiagonalDown     |  5 | Upper left-hand corner _start the lower right of each cell.
  p/  | xlDiagonalUp       |  6 | Lower left-hand corner _start the upper right of each cell.

Weight/thickness:
  w1 | xlHairline | 1     | Hairline (thinnest border).
  w2 | xlThin     | 2     | Thin.
  w3 | xlMedium   | -4138 | Medium.
  w4 | xlThick    | 4     | Thick (widest border).

Colors:
  For No Color, use: C-4142.
  For Automatic Color, use: C-4105.

  Sample:
    ; Add a colored underline to the cells.
    Excel_Borders(xls, "A1", "B2", "pB C12")
*/
  _end:=(_end=="") ? _start : _end
  If (StrLen(_start)<2 || StrLen(_end)<2)
    Return 1

  static _Table:=Object("pT", 8,"pB", 9,"pL", 7,"pR", 10  ; Position.
  , "pH", 12,"pV", 11,"p/", 5,"p\", 6             ; Position.
  , "s1", 1,"s2", -4115,"s3", 4,"s4", 5           ; Line Styles.
  , "s5", -4118,"s6", -4119,"s7", 13,"s0", -4142  ; Line Styles.
  , "w1", 1, "w2", 2, "w3", -4138, "w4", 4)       ; Line Weight.

  ; Get and set the style options, such as bold, line type and color index.
  ; ignore any border positions (prefixed with p).
  Loop, Parse, _options, %A_Space% %A_tab%
  {
    letter:=SubStr(A_LoopField, 1, 1)
    If (letter="s")
      Style:=_Table[A_LoopField]
    Else If (letter="w")
      weight:=_Table[A_LoopField]
    Else If (letter="c")
      Color:=SubStr(A_LoopField, 2, StrLen(A_LoopField)-1)
    Else If (letter="p")
      Continue
  }

  ; double-check the above values. if anything is blank,
  ; slap in some default values.
  Style:=(Style=="") ? 1 : Style
  weight:=(weight=="") ? 2 : weight
  Color:=(Color=="") ? 1 : Color

  ; apply the styles above into _start specified border elements.
  ; ignore everything except border positions.
  Loop, Parse, _options, %A_Space% %A_tab%
  {
    letter:=SubStr(A_LoopField, 1, 1)
    If (a_loopfield=="" || letter="s" || letter="w" || letter="c")
      Continue
    Cells:=_ID.Range(_start ":" _end).Borders(_Table[A_LoopField])
    Cells.LineStyle:=Style
    Cells.Weight:=Weight
    Cells.ColorIndex:=Color
  }
}

; Not Mine
; ACC  -  jethrow & Sean http://www.autohotkey.com/forum/viewtopic.php?t=67931
Excel_Acc_Init() {
  Static  h
  If Not  h
    h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}
Excel_Acc_ObjectFromWindow(hWnd, idObject = -4) {
  Excel_Acc_Init()
  If  DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
  Return  ComObjEnwrap(9,pacc,1)
}





