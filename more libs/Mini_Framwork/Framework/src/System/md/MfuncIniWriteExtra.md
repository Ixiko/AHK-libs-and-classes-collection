## Mfunc.IniWrite(Pairs, Filename, Section)  
Writes the *Pairs*  to the *Section* for a standard format .ini file.

## Mfunc.IniWrite(Value, Filename, Section, Key)  
Writes a *value* to the *Section* for a standard format .ini file.

### Remarks  
Wrapper for [AutoHotkey Docs - IniWrite](http://ahkscript.org/docs/commands/IniWrite.htm){_blank}.  
Static method.
Values longer than 65,535 characters can be written to the file, but may produce inconsistent results as they usually
cannot be read correctly by [Mfunc.IniRead](Mfunc.IniRead.html) or other applications.

A standard ini file looks like:
> [SectionName]
> Key=Value
New files are created in either the system's default ANSI code page or UTF-16, depending on
[the version of AutoHotkey](http://ahkscript.org/docs/Variables.htm#IsUnicode){_blank}. UTF-16 files may appear to
begin with a blank line, as the first line contains the UTF-16 byte order mark. See below for a workaround.

**Unicode**: IniRead and IniWrite rely on the external functions
[GetPrivateProfileString](http://msdn.microsoft.com/en-us/library/ms724353.aspx){_blank} and
[WritePrivateProfileString](http://msdn.microsoft.com/en-us/library/ms725501.aspx){_blank} to read and write values.
These functions support Unicode only in UTF-16 files; all other files are assumed to use the system's default ANSI code page.
In Unicode scripts, IniWrite uses UTF-16 for each new file. If this is undesired, ensure the file exists before calling IniWrite.  
For example:  
> Mfunc.FileAppend(, "NonUnicode.ini", "CP0") ; The last parameter is optional in most cases.

Any and/or all parameter for this function can be instance of [MfString](MfString.html) or var containing string.

See Also:[AutoHotkey Docs - IniWrite](http://ahkscript.org/docs/commands/IniWrite.htm){_blank}.

### Example  
> Mfunc.IniWrite("this is a new value", "C:\Temp\myfile.ini", "section2", "key")