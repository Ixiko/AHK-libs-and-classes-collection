*Cmd* is the operation to perform, which if blank defaults to *ID*. It can be one of the following words:

**ID**: Retrieves the unique ID number (HWND/handle) of a window. If there is no matching window, return value is null (empty).
The functions [WinExist()](http://ahkscript.org/docs/commands/WinExist.htm){_blank} and 
[WinActive()](http://ahkscript.org/docs/commands/WinActive.htm){_blank} can also be used to retrieve the ID of a window; for example, 
`WinExist("A")` is a fast way to get the ID of the active window. To discover the HWND of a control
(for use with [Post/SendMessage](http://ahkscript.org/docs/commands/PostMessage.htm){_blank} or 
[DllCall](http://ahkscript.org/docs/commands/DllCall.htm){_blank}), use 
[ControlGet Hwnd](http://ahkscript.org/docs/commands/ControlGet.htm#Hwnd){_blank} or 
[MouseGetPos](http://ahkscript.org/docs/commands/MouseGetPos.htm){_blank}.

**IDLast**: Same as above except it retrieves the ID of the last/bottommost window if there is more than one match.
If there is only one match, it performs identically to *ID*. This concept is similar to that used
by [WinActivateBottom](http://ahkscript.org/docs/commands/WinActivateBottom.htm){_blank}.

**PID**: Retrieves the [Process ID (PID)](http://ahkscript.org/docs/commands/Process.htm){_blank} of a window.

**ProcessName**: Retrieves the name of the process (e.g. notepad.exe) that owns a window. If there are no matching windows,
Return value is made null (empty).

**ProcessPath** [dull]\[v1.1.01+\][/]: Similar to *ProcessName*, but retrieves the full path and name of the process instead of just the name.

**Count**: Retrieves the number of existing windows that match the specified *WinTitle*, *WinText*, *ExcludeTitle*, and *ExcludeText*
(0 if none). To count all windows on the system, omit all four title/text parameters. Hidden windows are included only if 
[DetectHiddenWindows](http://ahkscript.org/docs/commands/DetectHiddenWindows.htm){_blank} has been turned on.

**List**: Retrieves the unique ID numbers of all existing windows that match the specified *WinTitle*, *WinText*, *ExcludeTitle*,
and *ExcludeText* (to retrieve all windows on the entire system, omit all four title/text parameters). Each ID number is stored
in a variable whose name begins with OutputVar's own name (to form a pseudo-array), while Return value itself is set to the number of
retrieved items (0 if none). For example, if Return value is var OutputVar is MyArray and two matching windows are discovered, MyArray1
will be set to the ID of the first window, MyArray2 will be set to the ID of the second window, and MyArray itself will be set
to the number 2. Windows are retrieved in order from topmost to bottommost (according to how they are stacked on the desktop).
Hidden windows are included only if [DetectHiddenWindows](http://ahkscript.org/docs/commands/DetectHiddenWindows.htm){_blank} has
been turned on. Within a [function](http://ahkscript.org/docs/Functions.htm){_blank}, to create a pseudo-array that is global instead
of local, [declare](http://ahkscript.org/docs/Functions.htm#Global){_blank} MyArray as a global variable prior to using this command
(the converse is true for [assume-global](http://ahkscript.org/docs/Functions.htm#AssumeGlobal){_blank} functions).

**MinMax**: Retrieves the minimized/maximized state for a window. OuputVar is made blank if no matching window exists; otherwise, it is set to one of the following numbers:  
-1: The window is minimized ([WinRestore](http://ahkscript.org/docs/commands/WinRestore.htm){_blank} can unminimize it).  
1: The window is maximized ([WinRestore](http://ahkscript.org/docs/commands/WinRestore.htm){_blank} can unmaximize it).  
0: The window is neither minimized nor maximized.

**ControlList**: Retrieves the control names for all controls in a window. If no matching window exists or there are no controls in
the window, OutputVar is made blank. Otherwise, each control name consists of its class name followed immediately by its sequence
number (ClassNN), as shown by Window Spy.

Each item except the last is terminated by a linefeed (`n). To examine the individual control names one by one, use a parsing loop
as shown in the examples section below.

Controls are sorted according to their Z-order, which is usually the same order as TAB key navigation if the window supports tabbing.

The control currently under the mouse cursor can be retrieved via [MouseGetPos](http://ahkscript.org/docs/commands/MouseGetPos.htm){_blank}.

**ControlListHwnd** [dim]\[v1.0.43.06+\]:[/] Same as above except it retrieves the window handle (HWND) of each control rather than its ClassNN.

**Transparent**: Retrieves the degree of transparency of a window (see WinSet for how to set transparency). Return value is null
(empty) if:  
1) the OS is older than Windows XP  
2) there are no matching windows  
3) the window has no transparency level  
4) other conditions (caused by OS behavior)  
such as the window having been minimized, restored, and/or resized since it was made transparent. Otherwise,
a number between 0 and 255 is stored, where 0 indicates an invisible window and 255 indicates an opaque window. For example:
> Mfunc.MouseGetPos(,, MouseWin)
> Transparent := Mfunc.WinGet("Transparent", "ahk_id" . MouseWin) ; Transparency of window under the mouse cursor.

**TransColor**: Retrieves the color that is marked transparent in a window (see 
[WinSet](http://ahkscript.org/docs/commands/WinSet.htm#TransColor){_blank} for how to set the TransColor). Return value is null (empty) if:  
1) the OS is older than Windows XP  
2) there are no matching windows  
3) the window has no transparent color  
4) other conditions (caused by OS behavior)  
such as the window having been minimized, restored, and/or resized since it was made transparent. Otherwise, a six-digit hexadecimal RGB color is stored, e.g. 0x00CC99. For example:  
> Mfunc.MouseGetPos(,, MouseWin)
> TransColor := Mfunc.WinGet("TransColor", "ahk_id" . MouseWin)  ; TransColor of the window under the mouse cursor.

**Style** or **ExStyle**: Retrieves an 8-digit hexadecimal number representing style or extended style (respectively) of a window.
If there are no matching windows, OutputVar is made blank. The following example determines whether a window has the WS_DISABLED style:  
> Style := Mfunc.WinGet("Style", "My Window Title")
> if (Style & 0x8000000)  ; 0x8000000 is WS_DISABLED.
>   ... the window is disabled, so perform appropriate action.

The next example determines whether a window has the WS_EX_TOPMOST style (always-on-top):  
> ExStyle := Mfunc.WinGet("ExStyle", "My Window Title")
> if (ExStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST.
>   ... the window is always-on-top, so perform appropriate action.

See the [styles table](http://ahkscript.org/docs/misc/Styles.htm){_blank} for a partial listing of styles.

### Returns  
Returns the result of *Cmd*.
 
### Remarks  
Wrapper for [AutoHotkey Docs - WinGet](http://ahkscript.org/docs/commands/WinGet.htm){_blank}.  
Static method.

A window's ID number is valid only during its lifetime. In other words, if an application restarts, all of its windows will get new ID numbers.

ID numbers retrieved by this command are numeric (the prefix "ahk_id" is not included) and are stored in hexadecimal format regardless
of the setting of [Mfunc.SetFormat](Mfunc.SetFormat.html).

The ID of the window under the mouse cursor can be retrieved with [Mfunc.MouseGetPos](Mfunc.MouseGetPos.html).

Although ID numbers are currently 32-bit unsigned integers, they may become 64-bit in future versions. Therefore, it is unsafe
to perform numerical operations such as addition on these values because such operations require that their input strings be
parsable as [u]signed[/u] rather than [u]unsigned[/u] integers.

Window titles and text are case sensitive. Hidden windows are not detected unless 
[DetectHiddenWindows](http://ahkscript.org/docs/commands/DetectHiddenWindows.htm){_blank} has been turned on.

Any and/or all parameter for this function can be instance of [MfString](MfString.html) or var containing string.

See Also:[AutoHotkey Docs - WinGet](http://ahkscript.org/docs/commands/WinGet.htm){_blank}.