### Fast vs. Slow Mode  
In [v1.0.48+], IntegerFast may be used instead of Integer, and FloatFast may be used instead of Float.
* **Advantages**: The fast mode preserves the ability of variables to cache integers and floating point numbers, which substantially accelerates numerically-intensive operations. (By contrast, the slow mode forces all numeric results to be immediately converted and stored as strings.)
* **Disadvantages**: When storing a number in a variable, the fast mode delays the effects of SetFormat until the script actually needs a text/string version of that variable (e.g. to display in a [MsgBox](http://ahkscript.org/docs/commands/MsgBox.htm){_blank}). Since a different SetFormat may be in effect at that time (e.g. more or fewer decimal places), this can lead to unexpected results. To make the current fast format take effect immediately, use an operation like HexValue .= "", which appends an empty string to the number currently stored in HexValue.

If the slow mode "Integer" or "Float" is used anywhere in the script, even if that SetFormat line is never executed, the caching of integers or floating point numbers (respectively) is disabled the moment the script launches.

### Floating Point Format  
In [v1.0.48+], floating point variables have about 15 digits of precision internally unless `SetFormat Float` (i.e. the slow mode) is present anywhere in the script.
In that case, the stored precision of floating point numbers is determined by [DecimalPlaces](http://ahkscript.org/docs/commands/SetFormat.htm#DecimalPlaces){_blank}
(like it was in [pre-1.0.48] versions). In other words, once a floating point result is stored in a variable, the extra precision is lost and cannot be
reclaimed without redoing the calculation with something like `Mfunc.SetFormat("Float", 0.15)`. To avoid this loss of precision, avoid using `SetFormat Float`
anywhere in the script, or use `SetFormat FloatFast` instead.

Regardless of whether slow or fast mode is in effect, floating point results and variables are rounded off to 
[DecimalPlaces](http://ahkscript.org/docs/commands/SetFormat.htm#DecimalPlaces){_blank} whenever they are displayed or converted to a string of text (e.g. 
[MsgBox](http://ahkscript.org/docs/commands/MsgBox.htm){_blank} or [FileAppend](http://ahkscript.org/docs/commands/FileAppend.htm){_blank}).
To see the full precision, use something like `Mfunc.SetFormat("FloatFast", 0.15)`.

To convert a floating point number to an integer, use` Var:=Round(Var)`, `Var:=Floor(Var)`, or `Var:=Ceil(Var)`. To convert an integer to a floating
point number, add 0.0 to it (e.g. `Var+=0.0`) or use something like `MyFloat:=Round(MyInteger, 1)`.

The built-in variable A_FormatFloat contains the current floating point format (e.g. `0.6`).

### Integer Format  
Integer results are normally displayed as decimal, not hexadecimal. To switch to hexadecimal, use `Mfunc.SetFormat("IntegerFast", "Hex")`. This may also
be used to convert an integer from decimal to hexadecimal (or vice versa) as shown in the example at the very bottom of this page.

Literal integers specified in a script may be written as either hexadecimal or decimal. Hexadecimal integers all start with the
prefix 0x (e.g. `0xA9`). They may be used anywhere a numerical value is expected. For example, `Sleep 0xFF` is equivalent to
Sleep 255 regardless of the current integer format set by SetFormat.

AutoHotkey supports 64-bit signed integers, which range from -9223372036854775808 (-0x8000000000000000) to 9223372036854775807 (0x7FFFFFFFFFFFFFFF).

The built-in variable **A_FormatInteger** contains the current integer format (H or D).

### General Remarks  
Wrapper for [AutoHotkey Docs - SetFormat](http://ahkscript.org/docs/commands/SetFormat.htm){_blank}.  
Static method.

If SetFormat is not used in a script, integers default to decimal format, and floating point numbers default
to `TotalWidth.DecimalPlaces` = `0.6`. Every newly launched [thread](http://ahkscript.org/docs/misc/Threads.htm){_blank}
(such as a [hotkey](http://ahkscript.org/docs/Hotkeys.htm){_blank}, [custom menu item](http://ahkscript.org/docs/commands/Menu.htm){_blank},
or [timed](http://ahkscript.org/docs/commands/SetTimer.htm){_blank} subroutine) starts off fresh with these defaults; but the defaults
may be changed by using SetFormat in the auto-execute section (top part of the script).

An old-style assignment like `x=%y%` omits any leading or trailing spaces (i.e. padding). To avoid this, use
[AutoTrim](http://ahkscript.org/docs/commands/AutoTrim.htm){_blank} or the
[colon-equals operator](http://ahkscript.org/docs/commands/SetExpression.htm){_blank} (e.g. x:=y).

You can determine whether a variable contains a numeric value by using
"[if var is number/integer/float](http://ahkscript.org/docs/commands/IfIs.htm){_blank}"

To pad an integer with zeros or spaces without having to use floating point math on it, follow this example:
> Var := "          " . Var     ; The quotes contain 10 spaces.  To pad with zeros, substitute zeros for the spaces.
> StringRight, Var, Var, 10  ; This pads the number in Var with enough spaces to make its total width 10 characters.
> Var := SubStr("          " . Var, -9)  ; A single-line alternative to the above two lines.
See Also:[AutoHotkey Docs - SetFormat](http://ahkscript.org/docs/commands/SetFormat.htm){_blank}.