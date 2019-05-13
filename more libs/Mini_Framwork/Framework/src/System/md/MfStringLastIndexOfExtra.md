## instance.LastIndexOf(searchChar)  
Reports the zero-based index position of the last occurrence of a specified character within this instance.

## instance.LastIndexOf(searchChar, startIndex)  
Reports the zero-based index position of the last occurrence of a specified character within
this instance. The search starts at a specified character position.  
			
## instance.LastIndexOf(searchChar, startIndex, count)  
Reports the zero-based index position of the last occurrence of the specified character
in a substring within this instance. The search starts at a specified character position and examines a specified number of character positions.

## instance.LastIndexOf(str)  
Reports the zero-based index position of the last occurrence of a specified string within this instance.

## instance.LastIndexOf(str, startIndex)  
Reports the zero-based index position of the last occurrence of a specified string within this instance.  
The search starts at a specified character position.  

## instance.LastIndexOf(str, startIndex, count)  
Reports the zero-based index position of the last occurrence of a specified string within this instance.
The search starts at a specified character position and examines a specified number of character positions.

## MfString.LastIndexOf(strMain, searchChar)  
Reports the zero-based index position of the last occurrence of a specified character within *strMain*.  
Static Method.

## MfString.LastIndexOf(strMain, searchChar, startIndex)  
Reports the zero-based index position of the last occurrence of a specified character within
*strMain*. The search starts at a specified character position.  
Static Method.
			
## MfString.LastIndexOf(strMain, searchChar, startIndex, count)  
Reports the zero-based index position of the last occurrence of the specified character
in a substring within *strMain*. The search starts at a specified character position and examines a specified number of character positions.  
Static Method.

## MfString.LastIndexOf(strMain, str)  
Reports the zero-based index position of the last occurrence of a specified string within *strMain*.  
Static Method.

## MfString.LastIndexOf(strMain, str, startIndex)  
Reports the zero-based index position of the last occurrence of a specified string within *strMain*.  
The search starts at a specified character position.  
Static Method.

## MfString.LastIndexOf(strMain, str, startIndex, count)  
Reports the zero-based index position of the last occurrence of a specified string within *strMain*.
The search starts at a specified character position and examines a specified number of character positions.  
Static Method.


### Remarks  
Index numbering starts from zero. That is, the first character in the string is at index zero and the last is at Length - 1.

The search begins at the *startIndex* character position of this instance and proceeds backward toward the beginning until either value is
found or count character positions have been examined. For example, if *startIndex* is Length - 1, the method searches backward count characters from the last character in the string.

Overloads method supports using all vars or all objects. Mixing of vars and Objects are not supported for this method.  
For example `.LastIndexOf(new MfChar("."), new MfInteger(0))`; [u]objects only[/u] is fine, `.LastIndexOf(".", 0)`; [u]vars only[/u] is fine,
but `.LastIndexOf(".", new MfInteger(0))`; [u]var and object[/u] will result in an error

See Also:[IndexOf](MfString.IndexOf.html)

### Returns  
Returns a zero-based index value as var containing Integer of the last position of the
*searchChar* or *str* in current instance of [MfString](MfString.html), if *SearchChar* is not found integer var contaning
a value of -1.  
[ReturnAsObject](MfString.ReturnAsObject.html) Property is ignored for this method. Return values are always a var containing integer.

### Throws  
Throws [MfNotSupportedException](MfNotSupportedException.html) if Overloads can not match Parameters.  
Throws [MfNullReferenceException](MfNullReferenceException.html) if [MfString](MfString.html) is not an instance.  
Throws [MfArgumentOutOfRangeException](MfArgumentOutOfRangeException.html) if *startIndex* is out of range.