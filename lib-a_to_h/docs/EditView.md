# EditView.ahk

Wraps the [Windows standard Edit control](https://msdn.microsoft.com/en-us/library/windows/desktop/bb775458%28v=vs.85%29.aspx) to provide an interface for high-level text editing and manipulation.

**Requirements**: Tested on AutoHotkey v1.1.19.02

**License:** [WTFPL](http://wtfpl.net/)

<br>

- - -

# Installation

 * Basic - copy _EditView.ahk_ into a [function library](http://lexikos.github.io/v2/docs/Functions.htm#lib)
 * For Git users and for convenience, clone the repo into a local folder then create a symlink_(using the [mklink](http://ss64.com/nt/mklink.html) command -> Windows Vista and newer)_ in your Lib folder with the symbolic link pointing to _EditView.ahk_ in the cloned repo. This allows you to pull any future changes/updates without having to update your copy in the Lib folder. `C:\Path-To-Function-Lib> mklink EditView.ahk Path-To-EditView-Repo\EditView.ahk`

<br>

- - -

# Constructor

### **__New / EditView()**

Creates an object representing a view to the Edit control's buffer.

### Syntax:

    view := new EditView( hWnd [ , nn := 1 ] )
    view := EditView( hWnd [ , nn := 1 ] )

### Parameter(s):

 * _**view**_ `[retval]` - an _EditView_ object
 * _**hWnd**_ `[in]` - handle to the Edit control or a parent window with a child Edit control
 * _**nn**_ `[in, opt]` - if _hWnd_ is a handle to a parent window, _nn_ is the instance number of the child Edit control.
 
### Remarks:

For convenience, the user may call the `EditView()` function. This is to avoid having to use the `new` keyword and also for  auto-inclusion in scripts if _EditView.ahk_ is in a [function library](http://lexikos.github.io/v2/docs/Functions.htm#lib).
 
<br>

- - -

# Properties

### **Len**

Retrieves the length of the text content of the Edit control or the length of the specified line.

### Syntax:

    len := view.Len[ [ row := "" ] ] ; get()

### Parameter(s):

 * _**row**_ `[in, opt]` - 1-based line number. If _row_ is negative, it is considered to be an offset from the last line. If `0` or explicitly blank(`""`), the length of the current line is returned. Otherwise, if omitted, the length of the entire text content is returned.
 
<br>

- - -

### **Text**

Sets or gets the text content of the Edit control

### Syntax:

    ; get()
    text := view.Text
    
    ; set()
    view.Text := text

<br>

- - -

### **Line**

Sets or gets the text at the specified line in the Edit control

### Syntax:

    ; get()
    line := view.Line[ [ row := "" ] ]
    
    ; set()
    view.Line[ [ row := "" ] ] := line

### Parameter(s):

 * _**row**_ `[in, opt]` - 1-based line number

<br>

- - -

### **Sub**

Inserts or extracts a (sub)string in the Edit control.

### Syntax:

    ; get()
    substr := view.Sub[ [ row := 1, col := 1, len ] ]
    
    ; set()
    view.Sub[ [ row := 1, col := 1, len ] ] := text

### Parameter(s):

 * _**substr**_ `[retval]` - `get()`, the substring to retrieve
 * _**text**_ `[in, value]` - `set()`, the text to insert
 * _**row**_ `[in, opt]` - 1-based line number.
 * _**col**_ `[in, opt]` - 1-based column number
 * _**len**_ `[in, opt]` - for `set()`, the length_(from the position as defined by `row` and `col`)_ of the region at which _text_ is inserted to. Characters within this region are replaced. For `get()`, the length of substring to retrieve.

### Remarks:

Parameters _row_ and _col_ determine the start position of the region. Blank(`""`), `0` or a negative number may be specified for _row_ and _col_ -> _see `Point()` method for behavior if any of the above is specified_. Specify a linefeed(`` `n ``) to span the region until end-of-line. If _len_ is omitted, the region will span until end-of-text.

<br>

- - -

### **Sel**

Retrieves the text of current selection(if any) OR selects a region

### Syntax:

    ; get()
    sel := view.Sel[ [ ByRef begin, ByRef end ] ]
    
    ; set()
    sel := view.Sel[ [ ByRef a, ByRef b ] ] := len

### Parameter(s):

 * _**sel**_ `[retval]` - text of the selection
 * _**begin**_ `[out, ByRef]` - `get()`, 0-based starting position of the selection.
 * _**end**_ `[out, ByRef]` - `get()`, 0-based positon of the first unselected character after the end of the selection.
 * _**a**_ `[in, out, ByRef]` - `set()`, 1-based line number on call, the same as _begin_ on return.
 * _**b**_ `[in, out, ByRef]` - `set()`, 1-based column number on call, the same as _end_ on return.
 * _**len**_ `[in, value]` - `set()`, the length of the text to select. Specify a linefeed(`` `n ``) w/ an optional carriage return(`` `r ``) specified, eol chars(`` `r`n ``) are included. Specify a dollar char(`$`) to select up to the last character.

### Remarks:

For `set()`: if both _a_ and _b_ are omitted, selection will start from current position of the caret.

<br>

- - -

# Methods

### **Point**

Returns the zero-based position at the specifed line and column.

### Syntax:

    point := view.RowCol( [ row, col ] )

### Parameter(s):

 * _**row**_ `[in, opt]` - 1-based line number. If `0` or blank(`""`), the current line number is used. If _row_ is negative, it is considered to be an offset from the last line, that is, `-1` is the last line and so on ...
 * _**col**_ `[in, opt]` - 1-based column number. If blank(`""`), the current column number is used. If `col <= 0`, it is considered to be a negative offset from the end-of-line as determined by _row_, that is, `0` is the position after the last character in the line and so on ...

### Remarks:

If both _row_ and _col_ are omitted, the current 0-based position of the caret is returned.

<br>

- - -

### **RowCol**

Calculates the one-based line and column numbers of the point.

### Syntax:

    rowcol := view.RowCol( [ point ] )

### Parameter(s):

 * _**rowcol**_ `[retval]` - a two-element array(`[row, col]`) with the first element containing the line number and the second one the column number.
 * _**point**_ `[in, opt]` - 0-based point/position

<br>

- - -

### ** \_SendMsg **

Sends a window message to the Edit control.

### Syntax:

    LRESULT := view._SendMsg( msg [ , wParam := 0, lParam := 0 ] )

### Parameter(s):

 * _**LRESULT**_ `[retval]` - [SendMessage](https://msdn.microsoft.com/en-us/library/windows/desktop/ms644950%28v=vs.85%29.aspx) LRESULT
 * _**msg**_ `[in]` - number (or name, see Remarks) of the message to send
 * _**wParam**_ `[in, opt]` - SendMessage wParam parameter
 * _**lParam**_ `[in, opt]` - SendMessage lParam parameter

### Remarks:

For convenience, the caller may send a window(`WM`)/edit(`EM`) message to the Edit control by specifying the message name_(e.g.: EM\_SETSEL)_ as the method name with _wParam_ and _lParam_ as its arguments respectively. If the argument is a structure or a buffer, its pointer must be passed.
 
<br>