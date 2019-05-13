### Cmd, Value  
The Cmd and Value parameters are dependent upon each other and their usage is described below.

**List**: Retrieves a list of items from a ListView, ListBox, ComboBox, or DropDownList.

[u]ListView[/u]: The syntax for ListView retrieval is:
> OutputVar := Mfunc.ControlGet("List", "Options", "SysListView321", "WinTitle", "WinText")
If the Options parameter is blank or omitted, all the text in the control is retrieved. Each row except the last will end with a linefeed character
(\`n). Within each row, each field (column) except the last will end with a tab character (\`t).

Specify for *Options* zero or more of the following words, each separated from the next with a space or tab:

*Selected*: Retrieves only the selected (highlighted) rows rather than all rows. If none, Return value is made null (empty).
*Focused*: Retrieves only the focused row. If none, Return value is made null (empty).
*Col4*: Retrieves only the fourth column (field) rather than all columns (replace 4 with a number of your choice). 
*Count*: Retrieves a single number that is the total number of rows in the control.
*Count Selected*: Retrieves the number of selected (highlighted) rows.
*Count Focused*: Retrieves the row number (position) of the focused row (0 if none).
*Count Col*: Retrieves the number of columns in the control (or -1 if the count cannot be determined).

NOTE: Some applications store their ListView text privately, which prevents their text from being retrieved.
In these cases, [ErrorLevel](http://ahkscript.org/docs/misc/ErrorLevel.htm){_blank} will usually be set to 0
(indicating success) but all the retrieved fields will be empty.
Also note that ListView text retrieval is not restricted by [#MaxMem](http://ahkscript.org/docs/commands/_MaxMem.htm){_blank}.

Upon success, [ErrorLevel](http://ahkscript.org/docs/misc/ErrorLevel.htm){_blank} is set to 0. Upon failure,
it is set to 1 and Return value is made null (empty)k. Failure occurs when: 1) the target window or control does not exist;
2) the target control is not of type SysListView32; 3) the process owning the ListView could not be opened,
perhaps due to a lack of user permissions or because it is locked; 4) the ColN option specifies a nonexistent column.

To extract the individual rows and fields out of a ListView, use a [parsing loop](http://ahkscript.org/docs/commands/LoopParse.htm){_blank}
as in this example:
> ControlGet, List, List, Selected, SysListView321, WinTitle
> Loop, Parse, List, `n  ; Rows are delimited by linefeeds (`n).
> {
> 	RowNumber := A_Index
> 	Loop, Parse, A_LoopField, %A_Tab%  ; Fields (columns) in each row are delimited by tabs (A_Tab).
> 		MsgBox Row #%RowNumber% Col #%A_Index% is %A_LoopField%.
> }