### Cmd, Value1, Value2  
The Cmd, Value1 and Value2 parameters are dependent upon each other and their usage is described below.

**Unicode [, String]**: (This command is not available in Unicode versions of AutoHotkey.) Retrieves or stores Unicode
text on the clipboard. Note: The entire clipboard may be saved and restored by means of 
[ClipboardAll](http://ahkscript.org/docs/misc/Clipboard.htm#ClipboardAll){_blank}, which allows "Transform Unicode"
to operate without losing the original contents of the clipboard.

There are two modes of operation as illustrated in the following examples:
> OutputVar := Mfunc.Transform("Unicode") ; Retrieves the clipboard's Unicode text as a UTF-8 string.
> Clipboard := Mfunc.Transform("Unicode", MyUTF_String)  ; Places Unicode text onto the clipboard.
In the second example above, a literal UTF-8 string ( wrapped in double quotes ) may be optionally used in place of MyUTF_String.

Use a hotkey such as the following to determine the UTF-8 string that corresponds to a given Unicode string:
> ^!u::  ; Control+Alt+U hotkey.
> MsgBox Copy some Unicode text onto the clipboard, then return to this window and press OK to continue.
> ClipUTF := Mfunc.Transform("Unicode")
> Clipboard := Mfunc.Transform("Unicode", ClipUTF . "`r`n")
> MsgBox The clipboard now contains the following line that you can paste into your script. When executed, this line will cause the original Unicode string you copied to be placed onto the clipboard:`n`n%Clipboard%
> return
Note: The [Send \{U+nnnn\}](http://ahkscript.org/docs/commands/Send.htm#sendu){_blank} command is an alternate way to produce Unicode characters.

**Asc, String:** Retrieves the ASCII code (a number between 1 and 255) for the first character in String.
If String is empty, OutputVar will also be made empty. For example: `OutputVar := Mfunc.Transform("Asc", VarContainingString)`.
Corresponding function: [Asc(String)](http://ahkscript.org/docs/Functions.htm#Asc){_blank}.

**Deref, String**: Expands variable references and [escape sequences](http://ahkscript.org/docs/commands/_EscapeChar.htm){_blank}
contained inside other variables. Any badly formatted variable references will be omitted from the expanded result.
The same is true if OutputVar is expanded into itself; in other words, any references to OutputVar inside String's variables
will be omitted from the expansion (note however that String itself can be %OutputVar%). In the following example, if var1
contains the string "test" and var2 contains the literal string "%var1%", OutputVar will be set to the
string "test": `OutputVar := Mfunc.Transform("deref", var2)`. Within a [function](http://ahkscript.org/docs/Functions.htm){_blank},
each variable in String always resolves to a local variable unless there is no such variable, in which case it resolves to a global
variable (or blank if none).

**HTML, String [, Flags]**:  

For ANSI executables: Converts String into its HTML equivalent by translating characters whose ASCII values are above 127 to their HTML names (e.g. £ becomes &pound;). In addition, the four characters "&<> are translated to &quot;&amp;&lt;&gt;. Finally, each linefeed (\`n) is translated to <br>\`n (i.e. <br> followed by a linefeed). The Flags parameter is ignored.

For Unicode executables: In addition of the functionality above, Flags can be zero or a combination (sum) of the following values. If omitted, it defaults to 1.
* 1: Converts certain characters to named expressions. e.g. € is converted to `&euro;`
* 2: Converts certain characters to numbered expressions. e.g. € is converted to `&#8364;`
Only non-ASCII characters are affected. If Flags = 3, numbered expressions are used only where a named expression is not available.
The following characters are always converted: `<>"&` and `\`n` (line feed).

**FromCodePage / ToCodePage**: Deprecated. Use [StrPut() / StrGet()](http://ahkscript.org/docs/commands/StrPutGet.htm){_blank} instead.

**Mod, Dividend, Divisor**: Retrieves the remainder of Dividend divided by Divisor. If Divisor is zero, Return value will be null (empty).
Dividend and Divisor can both contain a decimal point. If negative, Divisor will be treated as positive for the calculation.
In the following example, the result is 2: `OutputVar := Mfunc.Transform("mod", 5, 3)`. Corresponding function:
[Mod(Dividend, Divisor)](http://ahkscript.org/docs/Functions.htm#Mod){_blank}.

**Pow, Base, Exponent**: Retrieves Base raised to the power of Exponent. Both Base and Exponent may contain a decimal point.
If Exponent is negative, Return value will be formatted as a floating point number even if Base and Exponent are both integers.
A negative Base combined with a fractional Exponent such as 1.5 is not supported; it will cause OutputVar to be made blank.
See also: [\*\* operator](http://ahkscript.org/docs/Variables.htm#pow){_blank}.

**Exp, N**: Retrieves e (which is approximately 2.71828182845905) raised to the *N*th power. N may be negative and may contain a decimal point. Corresponding function: [Exp(N)](http://ahkscript.org/docs/Functions.htm#Exp){_blank}.

**Sqrt, Value1**: Retrieves the square root of *Value1*. If *Value1* is negative, Return value will be made null (empty).
Corresponding function: [Sqrt(Number)](http://ahkscript.org/docs/Functions.htm#Sqrt){_blank}.

**Log, Value1**: Retrieves the logarithm (base 10) of *Value1*. If *Value1* is negative, Return value will be made null (empty).
Corresponding function: [Log(Number)](http://ahkscript.org/docs/Functions.htm#Log){_blank}.

**Ln, Value1**: Retrieves the natural logarithm (base e) of *Value1*. If *Value1* is negative, Return value will be made null (empty).
Corresponding function: [Ln(Number)](http://ahkscript.org/docs/Functions.htm#Ln){_blank}.

**Round, Value1 \[, N\]**: If N is omitted, OutputVar will be set to Value1 rounded to the nearest integer.
If *N* is positive number, *Value1 *will be rounded to *N* decimal places. If *N* is negative, *Value1* will be rounded
by *N* digits to the left of the decimal point. For example, -1 rounds to the ones place, -2 rounds to the tens place, and-3
rounds to the hundreds place. Note: Round does not remove trailing zeros when rounding decimal places. For example, 12.333
rounded to one decimal place would become 12.300000. This behavior can be altered by using something like 
`[Mfunc.SetFormat](Mfunc.SetFormat.html)("Float", 0.1)` prior to the operation
\(in fact, [Mfunc.SetFormat](Mfunc.SetFormat.html) might eliminate the need to use Round in the first place\).
Corresponding function: [Round(Number \[, N\]](http://ahkscript.org/docs/Functions.htm#Round){_blank}).

**Ceil, Value1**: Retrieves *Value1* rounded up to the nearest integer. Corresponding function: [Ceil(Number)](Ceil(Number)){_blank}.

**Floor, Value1**: Retrieves *Value1* rounded down to the nearest integer. Corresponding function: 
[Floor(Number)](http://ahkscript.org/docs/Functions.htm#Floor){_blank}.

**Abs, Value1**: Retrieves the absolute value of *Value1*, which is computed by removing the leading minus sign (dash) from
*Value1* if it has one. Corresponding function: [Abs(Number)](http://ahkscript.org/docs/Functions.htm#Abs){_blank}.

**Sin, Value1**: Retrieves the trigonometric sine of *Value1*. *Value1* must be expressed in radians. Corresponding
function: [Sin(Number)](http://ahkscript.org/docs/Functions.htm#Sin){_blank}.

**Cos, Value1**: Retrieves the trigonometric cosine of Value1. Value1 must be expressed in radians.
Corresponding function: [Cos(Number)](http://ahkscript.org/docs/Functions.htm#Cos){_blank}.

**Tan, Value1**: Retrieves the trigonometric tangent of *Value1*. *Value1* must be expressed in radians.
Corresponding function: [Tan(Number)](http://ahkscript.org/docs/Functions.htm#Tan){_blank}.

**ASin, Value1**: Retrieves the arcsine \(the number whose sine is *Value1*\) in radians. If *Value1* is less than -1 or greater
than 1, Return value will be made null (empty). Corresponding function: [ASin(Number)](http://ahkscript.org/docs/Functions.htm#ASin){_blank}.

**ACos, Value1**: Retrieves the arccosine \(the number whose cosine is *Value1*\) in radians. If *Value1* is less than -1 or
greater than 1, Return value will be made null (empty). Corresponding function: 
[ACos(Number)](http://ahkscript.org/docs/Functions.htm#ACos){_blank}.

**ATan, Value1**: Retrieves the arctangent \(the number whose tangent is *Value1*\) in radians.
Corresponding function: [ATan(Number)](http://ahkscript.org/docs/Functions.htm#ATan){_blank}.


NOTE: Each of the following bitwise operations has a more concise
[bitwise operator](http://ahkscript.org/docs/Variables.htm#bitwise){_blank} for use in expressions.

**BitNot, Value1**: Stores the bit-inverted version of *Value1* in Return value (if *Value1* is floating point, it is truncated to
an integer prior to the calculation). If *Value1* is between 0 and 4294967295 \(0xffffffff\), it will be treated as an
[u]unsigned[/u] 32-bit value. Otherwise, it is treated as a [u]signed[/u] 64-bit value. In the following example,
the result is 0xfffff0f0 \(4294963440\): `OutputVar := Mfunc.Transform("BitNot", 0xf0f)`.

**BitAnd, Value1, Value2**: Retrieves the result of the bitwise-AND of *Value1* and *Value2* (floating point values are truncated to
integers prior to the calculation). In the following example, the result is 0xff00 (65280):
`OutputVar := Mfunc.Transform("BitAnd", 0xff0f, 0xfff0)`.

**BitOr, Value1, Value2**: Retrieves the result of the bitwise-OR of *Value1* and *Value2* \(floating point values are truncated
to integers prior to the calculation\). In the following example, the result is 0xf0f0 (61680):
`OutputVar := Mfunc.Transform("BitOr", 0xf000, 0x00f0)`.

**BitXOr, Value1, Value2**: Retrieves the result of the bitwise-EXCLUSIVE-OR of *Value1* and *Value2* \(floating point values are
truncated to integers prior to the calculation\). In the following example, the result is 0xff00 (65280):
`OutputVar := Mfunc.Transform("BitXOr", 0xf00f, 0x0f0f)`.

**BitShiftLeft, Value1, Value2**: Retrieves the result of shifting *Value1* to the left by *Value2* bit positions, which is
equivalent to multiplying Value1 by "2 to the Value2th power" \(floating point values are truncated to integers prior to the
calculation\). In the following example, the result is 8:
`OutputVar := Mfunc.Transform("BitShiftLeft", 1, 3)`.

**BitShiftRight, Value1, Value2**: Retrieves the result of shifting *Value1* to the right by *Value2* bit positions, which is
equivalent to dividing Value1 by "2 to the Value2th power", truncating the remainder \(floating point values are truncated to
integers prior to the calculation\). In the following example, the result is 2:
`OutputVar := Mfunc.Transform("BitShiftRight", 17, 3)`.

### Remarks  
Wrapper for [AutoHotkey Docs - Transform](http://ahkscript.org/docs/commands/Transform.htm){_blank}.  
Static method.

Sub-commands that accept numeric parameters can also use [expressions](http://ahkscript.org/docs/Variables.htm#Expressions){_blank}
for those parameters.

If either Value1 or Value2 is a floating point number, the following Cmds will retrieve a floating point number rather than an integer: Mod, Pow, Round, and Abs. The number of decimal places retrieved is determined by [Mfunc.SetFormat](Mfunc.SetFormat.html).

To convert a radians value to degrees, multiply it by 180/pi (approximately 57.29578). To convert a degrees value to radians, multiply it by pi/180 (approximately 0.01745329252).

The value of pi (approximately 3.141592653589793) is 4 times the arctangent of 1.

Any and/or all parameter for this function can be instance of [MfString](MfString.html) or var containing string.

See Also:[AutoHotkey Docs - Transform](http://ahkscript.org/docs/commands/Transform.htm){_blank}.

### Example  
> OutputVar := Mfunc.Transform("Asc", "A")  ; Get the ASCII code of the letter A.