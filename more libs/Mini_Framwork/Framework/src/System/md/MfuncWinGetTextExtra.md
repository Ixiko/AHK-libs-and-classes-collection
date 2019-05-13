### Returns  
Returns the retrieved text.

### Remarks  
Wrapper for [AutoHotkey Docs - WinGetText](http://ahkscript.org/docs/commands/WinGetText.htm){_blank}.  
Static method.
		
The text retrieved is generally the same as what Window Spy shows for that window. However, if 
[DetectHiddenText](http://ahkscript.org/docs/commands/DetectHiddenText.htm){_blank} has been turned off, hidden text is omitted from OutputVar.

Each text element ends with a carriage return and linefeed (CR+LF), which can be represented in the script as \`r\`n. To extract individual
lines or substrings, use commands such as [Mfunc.StringGetPos](Mfunc.StringGetPos.html) and [Mfunc.StringMid](Mfunc.StringMid.html).
A [parsing loop](http://ahkscript.org/docs/commands/LoopParse.htm){_blank} can also be used to examine each line or word one by one.

If the retrieved text appears to be truncated (incomplete), try using
`[VarSetCapacity(OutputVar, 55)](http://ahkscript.org/docs/commands/VarSetCapacity.htm){_blank}` prior to WinGetText
[replace 55 with a size that is considerably longer than the truncated text]. This is necessary because some applications do not
respond properly to the WM_GETTEXTLENGTH message, which causes AutoHotkey to make the output variable too small to fit all the text.

The amount of text retrieved is limited to a variable's maximum capacity (which can be changed via
the [#MaxMem](http://ahkscript.org/docs/commands/_MaxMem.htm){_blank} directive). As a result, this command might use a large
amount of RAM if the target window (e.g. an editor with a large document open) contains a large quantity of text. To avoid this,
it might be possible to retrieve only portions of the window's text by using 
[ControlGetText](http://ahkscript.org/docs/commands/ControlGetText.htm){_blank} instead. In any case, a variable's
memory can be freed later by assigning it to nothing, i.e. `OutputVar =`.

To retrieve a list of all controls in a window, follow this example: `WinGet, OutputVar, ControlList, WinTitle`

Window titles and text are case sensitive. Hidden windows are not detected unless
[DetectHiddenWindows](http://ahkscript.org/docs/commands/DetectHiddenWindows.htm){_blank} has been turned on.

See Also:[AutoHotkey Docs - WinGetText](http://ahkscript.org/docs/commands/WinGetText.htm){_blank}.