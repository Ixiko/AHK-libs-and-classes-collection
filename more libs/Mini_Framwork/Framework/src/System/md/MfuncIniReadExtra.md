## Mfunc.IniRead(Filename)  
Returns a linefeed (\`n) delimited list of section names.  

## Mfunc.IniRead(Filename, Section)  
Returns an entire section. Comments and empty lines are omitted. Only the first 65,533 characters of the section are retrieved.  

## Mfunc.IniRead(Filename, Section, Key)  
Returns a value from the ini file for the current *Section* and *Key*. If the value cannot be retrieved,
the variable is set to the value "ERROR"

## Mfunc.IniRead(Filename, Section, Key, Default)  
Returns a value from the ini file for the current *Section* and *Key*. If the value cannot be retrieved,
the variable is set to the value indicated by the *Default* parameter.

### Remarks  
Wrapper for [AutoHotkey Docs - IniRead](http://ahkscript.org/docs/commands/IniRead.htm){_blank}.  
Static method.
The operating system automatically omits leading and trailing spaces/tabs from the retrieved string.
To prevent this, enclose the string in single or double quote marks. The outermost set of single or
double quote marks is also omitted, but any spaces inside the quote marks are preserved.

Values longer than 65,535 characters are likely to yield inconsistent results.

A standard ini file looks like:
> [SectionName]
> Key=Value

**Unicode**: Mfunc.IniRead and Mfunc.IniWrite rely on the external functions GetPrivateProfileString and WritePrivateProfileString
to read and write values. These functions support Unicode only in UTF-16 files; all other files are assumed to use the
system's default ANSI code page.  

This method does not throw any exceptions. If there is an error then then null or the value of *Default* parameter is returned.

Any and/or all parameter for this function can be instance of [MfString](MfString.html) or var containing string.

See Also:[AutoHotkey Docs - IniRead](http://ahkscript.org/docs/commands/IniRead.htm){_blank}.