# Default base object

AFC provides an experimental module which adds some object syntax sugar to non-object values.
In order to use it, `#include <CDefaultBase>`.

When including it, the following syntax is allowed:

* `value.Length` - Retrieves the string length of the value. Equivalent to `StrLen()`.
* `value.Split([delimiters, omitChars])` - Returns an array, and works like `Loop, Parse` or AutoHotkey v2 `StrSplit()`.
* `value.Replace(searchText [, replaceText, ByRef outputVarCount])` - Works in a similar way to AutoHotkey v2 `StrReplace()`. If `outputVarCount` is passed a literal value, it only replaces the first instance.
* `value.Find(...)` - Works like `InStr()`.
* `value.Match(...)` - Works like `RegExMatch()`.
* `value.MatchReplace(...)` - Works like `RegExReplace()`.
* `value.ToLower(...)` - Works like `StringLower` or AutoHotkey v2 `StrLower()`.
* `value.ToUpper(...)` - Works like `StringUpper` or AutoHotkey v2 `StrUpper()`.
* `value.Trim/LTrim/RTrim(...)` - Work exactly like their function counterparts.

## Example

> #include <CDefaultBase>
> 
> for k,v in "fiRsT And seCoND anD ThIrD aND fOUrTh".Replace("and", "|").Split("|")
>     MsgBox % v.Trim().ToUpper("T")
