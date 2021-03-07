/* Class: EditView
 *     Wraps the Windows standard Edit control to provide an interface for
 *     high-level text editing/manipulation.
 * Requirements:
 *     Tested on AHK 1.1.19.02. It should work on v2.0a+ once Func.Call() is
 *     implemented.
 * License:
 *     WTFPL [http://wtfpl.net]
 */
class EditView {
	/* Constructor: __New
	 *     Creates an object representing a view to the Edit control's buffer.
	 * Syntax:
	 *     view := new EditView( hWnd [ , nn := 1 ] )
	 * Parameter(s):
	 *     view    	[retval] 	- 	an EditView object
	 *     hWnd 	[in] 		- 	handle to the Edit control or a parent window with
	 *                         			a child Edit control
	 *     nn      	[in, opt]	- 	if 'hWnd' is a handle to a parent window, 'nn' is
	 *                         			the instance number of the child Edit control.
	 * Remarks:
	 *     For convenience, the user may call the EditView() function. This is
	 *     to avoid having to use the 'new' keyword and also for auto-inclusion
	 *     in scripts if EditView.ahk is in a function library.
	 */
	__New(hWnd, nn:=1)	{
		prev_DHW := A_DetectHiddenWindows
		DetectHiddenWindows On

		WinGetClass, WinClass, ahk_id %hWnd%
		if (WinClass != "Edit")
			ControlGet hWnd, Hwnd,, Edit%nn%, ahk_id %hWnd%

		DetectHiddenWindows %prev_DHW%
		if !DllCall("IsWindow", "Ptr", hWnd)
			throw Exception("Invalid window handle", -1, hWnd)

		this.__Handle := hWnd + 0
	}
	/* Property: Len
	 *     Retrieves the length of the text content of the Edit control or the
	 *     length of a particular line.
	 * Syntax:
	 *     get()
	 *         len := view.Len[ [ row := "" ] ]
	 * Parameter(s):
	 *     row     [in, opt] - 1-based line number. If 'row' is negative, it is
	 *                         considered to be an offset from the last line.
	 *                         If 0 or explicitly blank(""), the length of the
	 *                         current line is returned. Otherwise, if omitted,
	 *                         the length of the entire text content is returned.
	 */
	Len[row*] {
		get {
			return ObjHasKey(row, 1) ? this.EM_LINELENGTH(this.Point(row[1])) : this.WM_GETTEXTLENGTH()
		}
	}
	/* Property: Text
	 *     Sets or gets the text content of the Edit control
	 * Syntax:
	 *     get()
	 *         text := view.Text
	 *     set()
	 *         view.Text := text
	 */
	Text {
		get {
			return this._Cmd.Call(this, "Get", "Text")
		}
		set {
			return this._Cmd.Call(this, "Set", "Text", RegExReplace(value, "\R", "`r`n"))
		}
	}
	/* Property: Line
	 *     Sets or gets the text at the specified line in the Edit control
	 * Syntax:
	 *     get()
	 *         line := view.Line[ [ row := "" ] ]
	 *     set()
	 *         view.Line[ [ row := "" ] ] := line
	 * Parameter(s):
	 *     row   [in, opt] - 1-based line number
	 */
	Line[row:=0] {
		get {
			return this.Sub[row, 1, "`n"]
		}
		set {
			return this.Sub[row, 1, "`n"] := value
		}
	}
	/* Property: Sub
	 *     Inserts or extracts a (sub)string in the Edit control
	 * Syntax:
	 *     get()
	 *         substr := view.Sub[ [ row := 1, col := 1, len ] ]
	 *     set()
	 *         view.Sub[ [ row := 1, col := 1, len ] ] := text
	 * Parameter(s):
	 *     substr   [retval] - get(), the substring to retrieve
	 *     text  [in, value] - set(), the text to insert
	 *     row     [in, opt] - 1-based line number.
	 *     col     [in, opt] - 1-based column number
	 *     len     [in, opt] - for set(), the length(from the position as defined
	 *                         by 'row' and 'col') of the region at which 'text'
	 *                         is inserted to. Characters within this region are
	 *                         replaced. For get(), the length of substring to retrieve.
	 * Remarks:
	 *     Parameters 'row' and 'col' determine the start position of the region.
	 *     Blank(""), 0 or a negative number may be specified for 'row' and 'col',
	 *     see Point() method for behavior if any of the above is specified.
	 *     Specify a linefeed(`n) to span the region until end-of-line. If 'len'
	 *     is omitted, the region will span until end-of-text.
	 */
	Sub[row:=1, col:=1, len:=""] {
		get {
			pos := this.Point(row, col) + 1
			if (len == "`n")
				rowcol := this.RowCol(pos-1)
				, text := this._Cmd.Call(this, "Get", "Line", rowcol[1])
				, pos := rowcol[2]
			else
				text := this.Text

			len := InStr("`n", len) ? [] : [len]
			return SubStr(text, pos, len*)
		}
		set {
			this.Sel[a, b] ; get current pos/selection
			this.Sel[row, col] := len == "" ? 0 : len
			this.EM_REPLACESEL(true, &(v := RegExReplace(value, "\R", "`r`n")))
			this.EM_SETSEL(a, b) ; restore previous pos/selection
		}
	}
	/* Property: Sel
	 *     Retrieves the text of current selection(if any) OR selects a region
	 * Syntax:
	 *     get()
	 *         sel := view.Sel[ [ ByRef begin, ByRef end ] ]
	 *     set()
	 *         sel := view.Sel[ [ ByRef a, ByRef b ] ] := len
	 * Parameter(s):
	 *     sel        [retval] - text of the selection
	 *     begin  [out, ByRef] - get(), 0-based starting position of the selection.
	 *     end    [out, ByRef] - get(), 0-based positon of the first unselected
	 *                           character after the end of the selection.
	 *     a  [in, out, ByRef] - set(), 1-based line number on call, the same as
	 *                           'begin' on return.
	 *     b  [in, out, ByRef] - set(), 1-based column number on call, the same
	 *                           as 'end' on return.
	 *     len     [in, value] - set(), the length of the text to select. Specify
	 *                           a linefeed(`n) w/ an optional carriage return(`r)
	 *                           before it to select until end-of-line. If '`r' is
	 *                           specified, eol chars(`r`n) are included. Specify
	 *                           a dollar char($) to select up to the last character.
	 * Remarks:
	 *     For set(): if both 'a' and 'b' are omitted, selection will start from
	 *     current position of the caret.
	 */
	Sel[ByRef begin:="", ByRef end:=""] {
		get {
			VarSetCapacity(sel, 8, 0)
			this.EM_GETSEL(&sel, &sel + 4)
			begin := NumGet(sel, 0, "UInt"), end := NumGet(sel, 4, "UInt")

			if ((end - begin) > 0)
				return this.Selected
		}
		set {
			begin := this.Point(a := begin, end)

			; $ := select to end; `n := select to eol, `r`n := select to eol + include eol
			if ( InStr(" $`r`n", value) > 1 )
			{
				end := this.Point(value=="$" ? -1 : a, 0)
				if InStr(value, "`r") ; include eol
					if (begin < this.Point(0)) ; line_index < last_line_index
						end += 2
			}
			else
				end := begin + value

			this.EM_SETSEL(begin, end)
			return this.Sel[begin, end]
		}
	}
	/* Method: Point
	 *     Returns the 0-based position at the specifed line and column.
	 * Syntax:
	 *     point := view.RowCol( [ row, col ] )
	 * Parameter(s):
	 *     row    [in, opt] - 1-based line number. If 0 or blank(""), the current
	 *                        line number is used. If 'row' is negative, it is
	 *                        considered to be an offset from the last line, that
	 *                        is, -1 is the last line and so on...
	 *     col    [in, opt] - 1-based column number. If blank(""), the current
	 *                        column number is used. If 'col' <= 0, it is considered
	 *                        to be a negative offset from the end-of-line as
	 *                        determined by 'row', that is, 0 is the position
	 *                        after the last character in the line and so on...
	 * Remarks:
	 *     If both 'row' and 'col' are omitted, the current 0-based position of
	 *     the caret is returned.
	 */
	Point(row:=0, col*)	{
		col := ObjHasKey(col, 1) ? col[1] : row ? 1 : ""

		if !row
			row := this.EM_LINEFROMCHAR(-1) + 1
		else if (row < 0)
			row += this.EM_GETLINECOUNT() + 1

		a := this.EM_LINEINDEX(row-1) << 32 >> 32

		if ((b := col) == "")
			b := this.CurrentCol
		else if (col <= 0)
			b := col + this.EM_LINELENGTH(a) + 1

		return a + b - 1
	}
	/* Method: RowCol
	 *     Calculates the 1-based line and column numbers of the point.
	 * Syntax:
	 *     rowcol := view.RowCol( [ point ] )
	 * Parameter(s):
	 *     rowcol    [retval] - a two-element array with the first element
	 *                          containing the line number and the second one
	 *                          the column number.
	 *     point    [in, opt] - 0-based point/position
	 */
	RowCol(pos:="")	{
		if (pos == "")
			pos := this.Point()
		row := this.EM_LINEFROMCHAR(pos)
		idx := this.EM_LINEINDEX(row) << 32 >> 32
		return [ row + 1, pos - idx + 1 ]
	}
	/* Method: _SendMsg
	 *     Sends a window message to the Edit control.
	 * Syntax:
	 *     LRESULT := view._SendMsg( msg [ , wParam := 0, lParam := 0 ] )
	 * Parameter(s):
	 *     LRESULT    [retval] - SendMessage LRESULT
	 *     msg            [in] - number of the message to send. For convenience,
	 *                           the caller may pass(as string) the message
	 *                           name(e.g.:EM_SETSEL). See static class variables
	 *                           defined at the bottom for valid message names.
	 *     wParam    [in, opt] - SendMessage wParam parameter
	 *     lParam    [in, opt] - SendMessage lParam parameter
	 * Remarks:
	 *     For convenience, the caller may send a window(WM)/edit(EM) message to
	 *     the Edit control by specifying the message name(e.g.: EM_SETSEL) as the
	 *     method name with 'wParam' and 'lParam' as its arguments respectively.
	 *     If the argument is a structure or a buffer, its pointer must be passed.
	 *     To see which messages are defined, see static class variables defined
	 *     at the bottom of the class definition.
	 */
	_SendMsg(msg, wParam:=0, lParam:=0)	{
		static integer := "integer" ; v1.1+ and v2.0a+ compatibility
		if msg is %integer%
			return this._SendMsgN.Call(this, msg, wParam, lParam) ; bypass __Call
		msg := this[msg] + 0
		if msg is %integer%
			return this._SendMsgN.Call(this, msg, wParam, lParam)
	}
; END OF PUBLIC INTERFACE

; METHODS and/or PROPERTIES DEFINED BELOW ARE PRIVATE TO THE CLASS
	_SendMsgN(msg, wParam:=0, lParam:=0) { ; internal
		hEdit := this.__Handle
		return DllCall("SendMessage", "Ptr", hEdit, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
	}

	__Call(name, args*)	{
		static integer := "integer"
		nMsg := this[name] + 0
		if nMsg is %integer%
			return this._SendMsgN.Call(this, nMsg, args*) ; bypass __Call
	}

	__Get(name, args*)	{
		if InStr(",LineCount,CurrentLine,CurrentCol,Selected,", Format(",{},", name))
			return this._Cmd.Call(this, "Get", name, args*)
	}

	_Cmd(GetOrSet, cmd, value:="")	{
		prev_DHW := A_DetectHiddenWindows
		DetectHiddenWindows On
		hEdit := this.__Handle
		out := ""

		if (GetOrSet = "Get") { ;  cmd := "Text,LineCount,CurrentLine,CurrentCol,(Line,N),Selected"

			if (cmd != "Text")
				ControlGet out, %cmd%, %value%,, ahk_id %hEdit%
			else
				ControlGetText out,, ahk_id %hEdit%
		}
		else if (GetOrSet = "Set")		{
			if (cmd != "Text")
				Control %cmd%, %value%,, ahk_id %hEdit%
			else
				ControlSetText,, %value%, ahk_id %hEdit%
		}

		DetectHiddenWindows %prev_DHW%
		return out
	}

	static EM_CANUNDO := 0x00C6, EM_CHARFROMPOS := 0x00D7, EM_EMPTYUNDOBUFFER := 0x00CD
	     , EM_FMTLINES := 0x00C8, EM_GETCUEBANNER := 0x1502, EM_GETFIRSTVISIBLELINE := 0x00CE
	     , EM_GETHANDLE := 0x00BD, EM_GETHILITE := 0x1506, EM_GETIMESTATUS := 0x00D9
	     , EM_GETLIMITTEXT := 0x00D5, EM_GETLINE := 0x00C4, EM_GETLINECOUNT := 0x00BA
	     , EM_GETMARGINS := 0x00D4, EM_GETMODIFY := 0x00B8, EM_GETPASSWORDCHAR := 0x00D2
	     , EM_GETRECT := 0x00B2, EM_GETSEL := 0x00B0, EM_GETTHUMB := 0x00BE
	     , EM_GETWORDBREAKPROC := 0x00D1, EM_HIDEBALLOONTIP := 0x1504, EM_LIMITTEXT := 0x00C5
	     , EM_LINEFROMCHAR := 0x00C9, EM_LINEINDEX := 0x00BB, EM_LINELENGTH := 0x00C1
	     , EM_LINESCROLL := 0x00B6, EM_POSFROMCHAR := 0x00D6, EM_REPLACESEL := 0x00C2
	     , EM_SCROLL := 0x00B5, EM_SCROLLCARET := 0x00B7, EM_SETCUEBANNER := 0x1501
	     , EM_SETHANDLE := 0x00BC, EM_SETHILITE := 0x1505, EM_SETIMESTATUS := 0x00D8
	     , EM_SETLIMITTEXT := 0x00C5, EM_SETMARGINS := 0x00D3, EM_SETMODIFY := 0x00B9
	     , EM_SETPASSWORDCHAR := 0x00CC, EM_SETREADONLY := 0x00CF, EM_SETRECT := 0x00B3
	     , EM_SETRECTNP := 0x00B4, EM_SETSEL := 0x00B1, EM_SETTABSTOPS := 0x00CB
	     , EM_SETWORDBREAKPROC := 0x00D0, EM_SHOWBALLOONTIP := 0x1503, EM_UNDO := 0x00C7
	     , WM_CLEAR := 0x0303, WM_COPY := 0x0301, WM_CUT := 0x0300, WM_PASTE := 0x0302
	     , WM_GETTEXT := 0x000D, WM_GETTEXTLENGTH := 0x000E
}
/* Function: EditView
 *     Utility function to allow auto-inclusion. Provided for convenience. For
 *     usage, see EditView.__New().
 */
EditView(hWnd, nn:=1) {
	return new EditView(hWnd, nn)
}