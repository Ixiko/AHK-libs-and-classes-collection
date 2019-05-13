## instance.IndexOf(searchChar)  
Reports the zero-based index position of the first occurrence of a specified character within this instance.

## instance.IndexOf(searchChar, startIndex)  
Reports the zero-based index position of the first occurrence of a specified character within
this instance. The search starts at a specified character position.

## instance.IndexOf(searchChar, startIndex, count)  
Reports the zero-based index position of the first occurrence of the specified character
in a substring within this instance. The search starts at a specified character position and examines a specified number of character positions.

## instance.IndexOf(str)  
Reports the zero-based index position of the first occurrence of a specified string within this instance.

## instance.IndexOf(str, startIndex)  
Reports the zero-based index position of the first occurrence of a specified string within this instance.
The search starts at a specified character position.

## instance.IndexOf(str, startIndex, count)  
Reports the zero-based index position of the first occurrence of a specified string within this instance.
The search starts at a specified character position and examines a specified number of character positions.

## MfString.IndexOf(strMain, searchChar)  
Reports the zero-based index position of the first occurrence of a specified character within this instance.  
Static Method.

## MfString.IndexOf(strMain, searchChar, startIndex)  
Reports the zero-based index position of the first occurrence of a specified character within
this instance. The search starts at a specified character position.  
Static Method.

## MfString.IndexOf(strMain, searchChar, startIndex, count)  
Reports the zero-based index position of the first occurrence of the specified character
in a substring within this instance. The search starts at a specified character position and examines a specified number of character positions.  
Static Method.

## MfString.IndexOf(strMain, str)  
Reports the zero-based index position of the first occurrence of a specified string within this instance.  
Static Method.

## MfString.IndexOf(strMain, str, startIndex)  
Reports the zero-based index position of the first occurrence of a specified string within this instance.
The search starts at a specified character position.  
Static Method.

## MfString.IndexOf(strMain, str, startIndex, count)  
Reports the zero-based index position of the first occurrence of a specified string within this instance.
The search starts at a specified character position and examines a specified number of character positions.  
Static Method.

### Returns  
Returns a zero-based index value as var containing Integer of the first position of the
*searchChar* or *str* in current instance of [MfString](MfString.html), if *SearchChar* or *str* is not
found  [MfInteger](MfInteger.html) object contanins a value of -1.  
If [ReturnAsObject](MfString.ReturnAsObject.html) Property for this instance is true then
returns [MfInteger](MfInteger.html) otherwise returns var containing Integer.

### Remarks  
Index numbering starts from 0 (zero). The *startIndex* parameter can range from 0 to the length of the string instance.

Overloads method supports using all vars or all objects. Mixing of vars and Objects are not supported for this method.  
For example `.IndexOf(new MfChar("."), new MfInteger(0))`; [u]objects only[/u] is fine, `.IndexOf(".", 0)`; [u]vars only[/u] is fine,
but `.IndexOf(".", new MfInteger(0))`; [u]var and object[/u] will result in an error

See Also:[LastIndexOf](MfString.LastIndexOf.html)

### Throws  
Throws [MfNotSupportedException](MfNotSupportedException.html) if Overloads can not match Parameters.  
Throws [MfNullReferenceException](MfNullReferenceException.html) if [MfString](MfString.html) is not an instance.  
Throws [MfArgumentOutOfRangeException](MfArgumentOutOfRangeException.html) if *startIndex* is out of range.