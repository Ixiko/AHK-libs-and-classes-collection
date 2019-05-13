;{ License
/* This file is part of Mini-Framework For AutoHotkey.
 * 
 * Mini-Framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 2 of the License.m_ChunkOffset := ""
 m_ChunkPrevious := ""
 m_MaxCapacity := 0
 static MaxCapacityField = "m_MaxCapacity"
 * 
 * Mini-Framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Mini-Framework.  If not, see <http://www.gnu.org/licenses/>.
 */
; End:License ;}
class MfStringBuilder extends MfObject
{
	static DefaultCapacity := 16
	m_ChunkChars := 0
	m_ChunkLength := 0
	m_ChunkOffset := 0
	m_ChunkPrevious := ""
	m_MaxCapacity := 0
	MaxChunkSize := 8000
	static m_BytesPerChar := A_IsUnicode ? 2 : 1
	m_Encoding := ""
	m_Nl := ""
	m_HasNullChar := false
;{ 	Constructor
/*
	OutputVar := new MfText.StringBuilder()
	OutputVar := new MfText.StringBuilder(capacity)
	OutputVar := new MfText.StringBuilder(capacity, maxCapacity)
	OutputVar := new MfText.StringBuilder(value)
	OutputVar := new MfText.StringBuilder(value, capacity)
	OutputVar := new MfText.StringBuilder(value, startIndex, length, capacity)
*/
/*
	Method: Constructor()
		Initializes a new instance of the StringBuilder class.
		The string value of this instance is set to empty string, and the capacity is set to the implementation-specific default capacity.
*/
/*
	Method: Constructor(capacity)
		Initializes a new instance of the StringBuilder class using the specified capacity.

	Parameters:
		capacity
			The suggested starting size of the StringBuilder.
			Can be any type that matches IsInteger or var integer
	Throws:
		Throws MfArgumentOutOfRangeException if capacity is less than zero.
	Remarks:
		The capacity parameter defines the maximum number of characters that can be stored in the memory allocated by the current instance.
		Its value is assigned to the Capacity property. If the number of characters to be stored in the current instance exceeds this capacity value,
		the StringBuilder object allocates additional memory to store them.
		If capacity is zero, the implementation-specific default capacity is used.
		The string value of this instance is set to null. If capacity is zero, the implementation-specific default capacity is used.
		If you intend to call the Constructor(value) method by passing in numeric integer string then wrap the in an instance of MfString
		to ensure the correct overload is called. sb := new MfText.StringBuilder("1000") will call the Constructor(capacity) overload.
		sb := new MfText.StringBuilder(new MfString("1000")) will call the Constructor(value) overload. 
		sb := new MfText.StringBuilder("1000.0") will call the Constructor(value) overload.
*/
/*
	Method: Constructor(capacity, maxCapacity)
		Initializes a new instance of the StringBuilder class that starts with a specified capacity and can grow to a specified maximum.
	Parameters:
		capacity
			The suggested starting size of the StringBuilder.
			Can be any type that matches IsInteger or var integer
		maxCapacity
			The maximum number of characters the current string can contain.
			Can be any type that matches IsInteger or var integer.
	Throws:
		Throws MfArgumentOutOfRangeException if maxCapacity is less than one, capacity is less than zero, or capacity is greater than maxCapacity.
	Remarks:
		The capacity parameter defines the maximum number of characters that can be stored in the memory allocated by the current instance.
		Its value is assigned to the Capacity property. If the number of characters to be stored in the current instance exceeds this capacity value,
		the StringBuilder object allocates additional memory to store them.
		If capacity is zero, the implementation-specific default capacity is used.
		The maxCapacity property defines the maximum number of characters that the current instance can hold. Its value is assigned to the MaxCapacity property.
		If the number of characters to be stored in the current instance exceeds this maxCapacity value, the StringBuilder object does not allocate additional memory,
		but instead throws an exception.
*/
/*
	Method: Constructor(value)
		Initializes a new instance of the StringBuilder class using the specified string.
	Parameters:
		value
			The string that contains the substring used to initialize the value of this instance. If value is null, the new StringBuilder will contain the empty string.
			Can be var number or string or any object that derives from MfObject.
	Remarks:
		If value is null, the new StringBuilder will contain the empty string.
		If value is an object then its ToString output is used.
		If var integer is passed into Constructor(value) such as sb := new MfText.StringBuilder("1000") it will result
		in the Constructor(capacity) overload being called. To pass integer var into Constructor(value) first wrap the integer
		var in instance of MfString as follows sb := new MfText.StringBuilder(new MfString("1000"))
		Calling Constructor(value) and passing in a non-integer number is fine such as  sb := new MfText.StringBuilder("1000.0")
*/
/*
	Method: Constructor(value, capacity)
		Initializes a new instance of the StringBuilder class using the specified string and capacity.
	Parameters:
		value
			The string that contains the substring used to initialize the value of this instance. If value is null, the new StringBuilder will contain the empty string.
			Can be var number or string or any object that derives from MfObject.
		capacity
			The suggested starting size of the StringBuilder.
			Can be any type that matches IsInteger or var integer.
	Throws:
		Throws MfArgumentOutOfRangeException if capacity is less than zero.
	Remarks:
		The capacity parameter defines the maximum number of characters that can be stored in the memory allocated by the current instance.
		Its value is assigned to the Capacity property. If the number of characters to be stored in the current instance exceeds this capacity value,
		the StringBuilder object allocates additional memory to store them.
		If capacity is zero, the implementation-specific default capacity is used.
		If value is an object then its ToString output is used.
		If var integer is passed into Constructor(value, capacity) such as sb := new MfText.StringBuilder("1000", 255) it will result
		in the Constructor(capacity, maxCapacity) overload being called. To pass integer var into Constructor(value, capacity) first wrap the
		integer var in instance of MfString as follows sb :=  new MfText.StringBuilder(new MfString("1000"), 255)
		Calling Constructor(value, capacity) and passing in a non-integer number is fine such as  sb := new MfText.StringBuilder("1000.0", 255)
*/
/*
	Method: Constructor(value, startIndex, length, capacity)
		Initializes a new instance of the StringBuilder class from the specified substring and capacity.
	Parameters:
		value
			The string that contains the substring used to initialize the value of this instance. If value is null, the new StringBuilder will contain the empty string.
			Can be var number or string or any object that derives from MfObject.
		startIndex
			The position within value where the substring begins.
			Can be any type that matches IsInteger or var integer.
		length
			The number of characters in the substring.
			Can be any type that matches IsInteger or var integer.
		capacity
			The suggested starting size of the StringBuilder.
			Can be any type that matches IsInteger or var integer.
	Throws:
		Throws MfArgumentOutOfRangeException if capacity is less than zero or startIndex plus length is not a position within value.
	Remarks:
		The capacity parameter defines the maximum number of characters that can be stored in the memory allocated by the current instance.
		Its value is assigned to the Capacity property. If the number of characters to be stored in the current instance exceeds this capacity value,
		the StringBuilder object allocates additional memory to store them.
		If capacity is zero, the implementation-specific default capacity is used.
		If value is an object then its ToString output is used.
*/
	__new(args*) {
		if (this.__Class != "MfStringBuilder")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfStringBuilder"))
		}
		; cp1252
		base.__new()
		this.m_isInherited := false
		this.m_Encoding := A_IsUnicode ? "UTF-16" : "cp1252"
		this.m_Nl := MfEnvironment.Instance.NewLine
		
		
		
		pArgs := this._ConstructorParams(A_ThisFunc, args*)
		strP := ""
		IsInit := false
		if (pArgs.Count = 0)
		{
			this._new()
			IsInit := true
		}
		else
		{
			strP := pArgs.ToString()
		}
		
		if (IsInit = false && strP = "MfInteger") ; Capacity
		{
			this._newInt(pArgs.Item[0])
			IsInit := true
		}
		else if (IsInit = false && strP = "MfString") ; string
		{
			this._newStr(pArgs.Item[0])
			IsInit := true
		}
		else if (IsInit = false && strP = "MfString,MfInteger") ; string, Capacity
		{
			this._newStrInt(pArgs.Item[0], pArgs.Item[1])
			IsInit := true
		}
		else if (IsInit = false && strP = "MfInteger,MfInteger") ; Capacity, Max Capacity or size, maxCapacity, previousBlock
		{
			if (pArgs.Data.Contains("_nullSb"))
			{
				if (pArgs.Data.Contains("_InternalOnly") && pArgs.Data.Item["_InternalOnly"] = true)
				{
					this._newIntIntSb(pArgs.Item[0], pArgs.Item[1])
					IsInit := true
				}
			}
			else
			{
				this._newIntInt(pArgs.Item[0], pArgs.Item[1])
				IsInit := true
			}
		}
		else if (IsInit = false && strP = "MfInteger,MfInteger,MfStringBuilder") ; size, maxCapacity, previousBlock
		{
			if (pArgs.Data.Contains("_InternalOnly") && pArgs.Data.Item["_InternalOnly"] = true)
			{
				this._newIntIntSb(pArgs.Item[0], pArgs.Item[1], pArgs.Item[2])
				IsInit := true
			}
		}
		else if (IsInit = false && strP = "MfString,MfInteger,MfInteger,MfInteger") ; string, index, length, capacity
		{
			this._newStrIntIntInt(pArgs.Item[0], pArgs.Item[1], pArgs.Item[2], pArgs.Item[3])
			IsInit := true
		}
		
		if (IsInit = false && pArgs.Data.Contains("_internalsb") = false)
		{
			e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			e.SetProp(A_LineFile, A_LineNumber, MethodName)
			throw e
		}
		else if (IsInit = false && strP = "MfStringBuilder")
		{
			; internal constructor base
			this._newSB(pArgs.Item[0])
			IsInit := true
		}
	}
; 	End:Constructor ;}
;{ Methods
;{ 	Append
/*
	OutputVar := instance.Append(chars)
	OutputVar := instance.Append(chars, startIndex, charCount)
	OutputVar := instance.Append(char, repeatCount)
	OutputVar := instance.Append(value)
	OutputVar := instance.Append(value, startIndex, count)
*/
/*
	Method: Append(chars)
		Appends the string representation of the Unicode characters in a specified list to this instance.
	Parameters:
		chars
			Instance of MfCharList to append.
	Returns:
		A reference to this instance after the append operation has completed.
	Throws:
		Throws MfArgumentOutOfRangeException if enlarging the value of this instance would exceed MaxCapacity.
	Remarks:
		This method appends all the characters in the specified MfCharList to the current instance in the same order as they appear in value.
		If value is null, no changes are made.
		The Append(chars) method modifies the existing instance of this class; it does not return a new class instance.
		Because of this, you can call a method or property on the existing reference and you do not have to assign the return value
		to a StringBuilder object, as the following example illustrates.
	Example:
		lst := new MfCharList()
		lst.AddString("aeiou")
		sb := new MfText.StringBuilder()
		sb.Append("The characters in the array: ").Append(lst)
		MsgBox % sb.ToString() ; The characters in the array: aeiou
		
*/
/*
	Method: Append(chars, startIndex, charCount)
		Appends the string representation of a specified sublist of Unicode characters to this instance.
	Parameters:
		chars
			Instance of MfCharList to append.
		startIndex
			The starting position in chars.
			Can var integer or any type that matches IsInteger.
		charCount
			The number of characters to append.
			Can var integer or any type that matches IsInteger.
	Returns:
		A reference to this instance after the append operation has completed.
	Throws:
		Throws MfArgumentNullException if chars is null or chars.Count is 0 and startIndex or charCount is not equal to zero.
		Throws MfArgumentOutOfRangeException if charCount is less than zero.
		- or -
		startIndex is less than zero.
		- or -
		startIndex + charCount is greater than the length of value.
		- or -
		Enlarging the value of this instance would exceed MaxCapacity.
	Remarks:
		This method appends the specified range of characters in value to the current instance.
		If value is null and startIndex and charCount are both zero, no changes are made.
		The Append(chars, startIndex, charCount) method modifies the existing instance of this class;
		it does not return a new class instance. Because of this, you can call a method or property on the existing reference and
		you do not have to assign the return value to a StringBuilder object, as the following example illustrates.
	Example:
		lst := new MfCharList()
		lst.AddString("abcde")
		startPosition := lst.IndexOf("a")
		endPosition := lst.IndexOf("c")
		sb := new MfText.StringBuilder()
		if (startPosition >= 0 && endPosition >= 0)
		{
			sb.Append("The list from positions ").Append(startPosition)
				.Append(" to ").Append(endPosition).Append(" contains ")
				.Append(lst, startPosition, endPosition + 1).Append(".")
		}
		MsgBox % sb.ToString() ; The list from positions 0 to 2 contains abc.
*/
/*
	Method: Append(char, repeatCount)
		Appends a specified number of copies of the string representation of a Unicode character to this instance.
	Parameters:
		char
			The character to append.
			Can be var, instance of MfChar or Instance of MfString.
			Only the first char will be used if var or MfString has more then one char.
		repeatCount
			The number of times to append value.
			Can var integer or any type that matches IsInteger.
	Returns:
		A reference to this instance after the append operation has completed.
	Throws:
		Throws MfArgumentOutOfRangeException repeatCount is less than zero or enlarging the value of this instance would exceed MaxCapacity.
		Throws MfOutOfMemoryException Out of memory.
	Remarks:
		The Append(char, repeatCount) method modifies the existing instance of this class; it does not return a new class instance.
		Because of this, you can call a method or property on the existing reference and you do not have to assign the return value to
		a StringBuilder object, as the following example illustrates.
	Example:
		sb := new MfText.StringBuilder()
		flt := new MfFloat(1589.1965,,,"0.4")
		sb.Append("*", 5)
			.AppendFormat("{0}{1:0.2f}", MfNumberFormatInfo.InvariantInfo.CurrencySymbol, flt.Value)
			.Append("*", 5)
		MsgBox % sb.ToString() ; *****$1589.20*****
*/
/*
	Method: Append(value)
		Appends a copy of the specified string var or object to this instance.
	Parameters:
		value
			Value to append to current instance.
			Can be var number or string or any object that derives from MfObject.
	Returns:
		A reference to this instance after the append operation has completed.
	Throws:
		Throws MfArgumentOutOfRangeException if enlarging the value of this instance would exceed MaxCapacity.
	Remarks:
		The Append(value) method modifies the existing instance of this class; it does not return a new class instance.
		Because of this, you can call a method or property on the existing reference and you do not have to assign the return value to a StringBuilder object.
		When value is an object derived from MfObject it will be added to the current instance by calling the objects
		ToString() method. Eg: sb.Append(new MfInt16(26)) equals sb.Append(new MfInt16(26).ToString())
	Example:
		flt := new MfFloat(1589.1965)
		sb := new MfText.StringBuilder()
		sb.Append(flt)
		MsgBox % sb.ToString() ; 1589.1965
		sb := new MfText.StringBuilder()
		sb.Append("Hello World").Append(". Nice to See You!")
		MsgBox % sb.ToString() ; Hello World. Nice to See You!
		sb := new MfText.StringBuilder()
		sb.Append(5).Append(2 + 2).Append(".").Append(3 * 21)
		MsgBox % sb.ToString() ; 54.63
		sb := new MfText.StringBuilder()
		sb.Append(new MfSByte(-124))
		MsgBox % sb.ToString() ; -124
		sb := new MfText.StringBuilder()
		sb.Append(new MfInt64(MfInt64.MinValue))
		MsgBox % sb.ToString() ; -9223372036854775808
		sb := new MfText.StringBuilder()
		sb.Append(new MfUInt64(MfUInt64.MaxValue))
		MsgBox % sb.ToString() ; 18446744073709551615
		sb := new MfText.StringBuilder()
		sb.Append(MfUInt64.MaxValue)
		MsgBox % sb.ToString() ; 18446744073709551615
		sb := new MfText.StringBuilder()
		sb.Append(new MfChar("Z"))
		MsgBox % sb.ToString() ; Z
		sb := new MfText.StringBuilder()
		ex := new MfFormatException("This is a format Exception")
		ex.SetProp(A_LineFile, A_LineNumber, "My Special Script")
		sb.Append(ex)
		MsgBox % sb.ToString()
		; MfFormatException: This is a format Exception
		; Source:My Special Script
		; Line:21
		; File:D:\Users\user\Documents\AutoHotkey\Scripts\Sample.ahk
*/		
/*
	Method: Append(value, startIndex, count)
		Appends a copy of the specified substring to this instance.
	Parameters:
		value
			Value to append to current instance.
			Can be var number or string or instance of MfString.
		startIndex
			The starting position of the substring within value.
			Can var integer or any type that matches IsInteger.
		count
			The number of characters in value to append.
			Can var integer or any type that matches IsInteger.
	Returns:
		A reference to this instance after the append operation has completed.
	Throws:
		Throws MfArgumentOutOfRangeException if count is less than zero.
		- or -
		startIndex is less than zero.
		- or -
		startIndex + count is greater than the length of value.
		- or -
		Enlarging the value of this instance would exceed MaxCapacity.
	Remarks:
		This method appends the specified range of characters in value to the current instance. If value is null and startIndex and count are both zero, no changes are made.
		The Append(value, startIndex, count) method modifies the existing instance of this class; it does not return a new class instance. Because of this, you can call a method or property on the existing reference and you do not have to assign the return value to a StringBuilder object, as the following example illustrates.
	Example:
		str := new MfString("First;George Washington;1789;1797", true)
		sb := new MfText.StringBuilder()
		index := 0
		length := str.IndexOf(";", index)
		sb.Append(str, index, length).Append(" President of the United States: ")
		index += length + 1
		length := str.IndexOf(";", index) - index
		sb.Append(str, index, length).Append(", from ")
		index += length + 1
		length := str.IndexOf(";", index) - index
		sb.Append(str, index, length).Append(" to ")
		index += length + 1
		sb.Append(str, index, str.Length - index)
		MsgBox % sb.ToString() ; First President of the United States: George Washington, from 1789 to 1797
*/
	Append(args*) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		cnt := MfParams.GetArgCount(args*)
		; by checking for single item via cout it is much faster then loading from _AppendParams and then processing
		; most usage if Append will be appending a single itemd such as a string or var.
		if (cnt = 1)
		{
			obj := args[1]
			if (MfObject.IsObjInstance(obj, MfCharList))
			{
				this._AppendCharList(obj, 0, obj.Count)
				return this
			}
			; can handel null values
			return this._AppendString(obj)
		}

		pArgs := this._AppendParams(A_ThisFunc, args*)
		pList := pArgs.ToStringList()

		if (cnt = 2)
		{
			; only valid choice is MfChar and Repeat count
			if (pList.Item[0].Value = "MfChar")
			{
				num :=  MfInt64.GetValue(pArgs.Item[1])
				cc := pArgs.Item[0].Charcode
				this._AppendCharCode(cc, num)
				return this
			}
		}
		if (cnt = 3)
		{
			; MfCharList, StartIndex, Count
			; MfString, StartIndex, Count
			s := pList.Item[0].Value
			If (s = "MfCharList")
			{
				obj := pArgs.Item[0]
				StartIndex := MfInt64.GetValue(pArgs.Item[1])
				Count := MfInt64.GetValue(pArgs.Item[2])
				this._AppendCharList(obj, StartIndex, Count)
				return this
			}
			else if (s = "MfString")
			{
				obj := pArgs.Item[0]
				StartIndex := MfInt64.GetValue(pArgs.Item[1])
				Count := MfInt64.GetValue(pArgs.Item[2])
				ms := MfMemoryString.FromAny(obj, this.m_Encoding)
				if (Count > ms.Length - startIndex)
				{
					ex := new MfArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				this._AppendString(ms.SubString(StartIndex,Count))
				return this
			}
		}
		e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw e
	}
; 	End:Append ;}
;{ 	AppendString
	; internal Method
	; use Append(value) method for public use
	AppendString(str) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._AppendString(str)
		return this
	}
; 	End:AppendString ;}
;{ 	AppendFormat
/*
	Method: AppendFormat(str, arg, arg2, ..., argN)
		Appends the string returned by processing a composite format string, which contains zero or more format items,
		to this instance. Each format item is replaced by the string representation of a corresponding argument in a parameter array.
	Parameters:
		str
			String to format. Can be any object derived from MfObject or var containing string.
			A format string composed of literal text and placeholders of the form {Index:Format}.
			Index is an integer indicating which input value to use, where 0 is the first value.
			Format is an optional format specifier, as described below.
			Omit the index to use the next input value in the sequence (even if it has been used earlier in the string).
			For example, "{2:i} {:i}" formats the second and third input values as decimal integers, separated by a space.
			If Index is omitted, Format must still be preceded by :. Specify empty braces to use the next input value with default formatting: {}
			Use {{} and {}} to include literal braces in the string. Any other invalid placeholders are included in the result as is.
		arg
			One or more args to format str with.
			Input values to be formatted and inserted into the final string. Each value is a separate parameter. The first value has an index of 0.
	Remarks:
		This method uses the composite formatting feature to convert the value of an object to its text representation and embed
		that representation in the current StringBuilder object.
	Related:
		MfString.Format()
	Example:
		sb := new MfText.StringBuilder()
		int := new MfInteger(5432)
		str := "abcd"
		flt := new MfFloat(456.789)
		sb.AppendLine("StringBuilder.AppendFormat method:")
		sb.AppendFormat("1) {0}", int)
		sb.AppendLine()
		sb.AppendFormat("2) {0}, {1}", int, str)
		sb.AppendLine()
		sb.AppendFormat("3) {0}, {1}, {2}", int, str, flt)
		MsgBox % sb.ToString()
		; StringBuilder.AppendFormat method:
		; 1) 5432
		; 2) 5432, abcd
		; 3) 5432, abcd, 456.789
*/

	AppendFormat(str, args*) {
		_str := MfString.GetValue(str)
		fStr := MfString.Format(_str, args*)
		return this._AppendString(fStr)
	}
; 	End:AppendFormat ;}
;{ 	AppendLine
/*
	Method: AppendLine()
		Appends the default line terminator to the end of the current StringBuilder object.
		A reference to this instance after the append operation has completed.
	Throws:
		Throws MfArgumentOutOfRangeException if enlarging the value of this instance would exceed MaxCapacity.
	Remarks:
		The default line terminator is the current value of the MfEnvironment.NewLine property.
		The capacity of this instance is adjusted as needed.
*/
/*
	Method: AppendLine(value)
		Appends a copy of the specified string followed by the default line terminator to the end of the current StringBuilder object.
		value
		The string to append.
	Returns:
		A reference to this instance after the append operation has completed.
	Throws:
		Throws MfArgumentOutOfRangeException if enlarging the value of this instance would exceed MaxCapacity.
	Remarks:
		The default line terminator is the current value of the MfEnvironment.NewLine property.
		The capacity of this instance is adjusted as needed.
	Example:
		sb := new MfText.StringBuilder()
		line := "A line of text."
		num := 123
		; Append two lines of text.
		sb.AppendLine("The first line of text.")
		sb.AppendLine(line)
		sb.AppendLine()
		sb.AppendLine("")
		; Append the non-string value, 123, and two new lines
		sb.Append(num).AppendLine().AppendLine()
		; Append two lines of text.
		sb.AppendLine(line)
		sb.AppendLine("The last line of text.")
		MsgBox % sb.ToString()
		; The first line of text.
		; A line of text.


		; 123

		; A line of text.
		; The last line of text.
*/

	AppendLine(value = "") {
		if (MfNull.IsNull(value) = false)
		{
			this._AppendString(value)
		}
		return this._AppendString(this.m_Nl)
	}
; 	End:AppendLine ;}
;{ 	Clear
/*
	Method: Clear()
		Removes all characters from the current StringBuilder instance.

	OutputVar := instance.Clear()

	Clear()
		Removes all characters from the current StringBuilder instance.
	Returns:
		A reference to this instance after the append operation has completed.
	Remarks:
		Clear is a convenience method that is equivalent to setting the Length property of the current instance to 0 (zero).
		Calling the Clear method does not modify the current instance's Capacity or MaxCapacity property.
*/
	Clear() {
		this.Length := 0
		return this
	}
; 	End:Clear ;}
;{ 	CompareTo - Overrides MfObject CompareTo
/*
	Method: CompareTo()
		Overrides MfObject.CompareTo
	CompareTo(obj)
		Compares this instance to a specified StringBuilder instance.
	Parameters:
		obj
			A StringBuilder object to compare to current instance.
	Returns:
		Returns a var containing integer indicating the position of this instance in the sort order in relation to the value parameter.
		Return Value Description Less than zero This instance precedes obj value.
		Zero This instance has the same position in the sort order as value. Greater than zero This instance follows
	Throws:
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of StringBuilder.
	Remarks:
		Compares this instance to a specified StringBuilder instance and indicates whether this instance precedes,
		follows, or appears in the same position in the sort order as the specified StringBuilder instance.
		Compare is done as ordinal.
*/
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(obj))
		{
			return 1
		}
		if(MfObject.IsObjInstance(obj, MfStringBuilder) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "obj", "StringBuilder"), "obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfObject.ReferenceEquals(this, obj))
		{
			return 0
		}
		thisMs := this._ToMemoryString()
		ObjMs := obj._ToMemoryString()
		return thisMs.CompareOrdinal(objMs, false)
	}
; 	End:CompareTo ;}
;{ 	CopyTo
/*
	Method: CopyTo()
	CopyTo(sourceIndex, destination, destinationIndex, count)
		Copies the characters from a specified segment of this instance to a specified segment of a destination MfCharList.
	Parameters:
		sourceIndex
			The starting position in this instance where characters will be copied from. The index is zero-based
			Can be any type that matches IsInteger or var integer.
		destination
			The MfCharList instance where characters will be copied.
		destinationIndex
			The starting position in destination where characters will be copied. The index is zero-based.
			Can be any type that matches IsInteger or var integer.
		count
			The number of characters to be copied.
			Can be any type that matches IsInteger or var integer.
	Throws:
		Throws MfArgumentNullException if destination is null.
		Throws MfArgumentOutOfRangeException sourceIndex, destinationIndex, or count, is less than zero -or- sourceIndex is greater than the length of this instance.
		Throws MfArgumentException if sourceIndex + count is greater than the length of this instance. -or- destinationIndex + count is greater than the length of destination.
	Remarks:
		The CopyTo method is intended to be used in the rare situation when you need to efficiently copy successive sections of a StringBuilder object to a list.
		For example, your application could populate a StringBuilder object with a large number of characters then use the
		CopyTo method to copy small, successive pieces of the StringBuilder object to a list where the pieces are processed.
		When all the data in the StringBuilder object is processed, the size of the StringBuilder object is set to zero and the cycle is repeated.
*/
	CopyTo(sourceIndex, destination, destinationIndex, count) {
			sourceIndex := MfInteger.GetValue(sourceIndex, -1)
			destinationIndex := MfInteger.GetValue(destinationIndex, -1)
			count := MfInteger.GetValue(count, -1)

			if (MfNull.IsNull(destination))
			{
				ex := new MfArgumentNullException("destination")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!MfObject.IsObjInstance(destination, MfCharList))
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", "destination"), "destination")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}

			if (destinationIndex < 0)
			{
				ex := new MfArgumentOutOfRangeException("destinationIndex", mfEnvironment.Instance.GetResourceString("Arg_NegativeArgCount"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (sourceIndex < 0)
			{
				ex := new MFArgumentOutOfRangeException("sourceIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}

			if (count < 0)
			{
				ex := new MFArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}

			if (sourceIndex > this.Length)
			{
				ex := new MfArgumentOutOfRangeException("sourceIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}

			if (sourceIndex > this.Length - count)
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_LongerThanSrcString"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}

			chunk := this
			sourceEndIndex := sourceIndex + count
			curDestIndex := destinationIndex + count
			while (count > 0)
			{
				chunkEndIndex := sourceEndIndex - chunk.m_ChunkOffset
				if (chunkEndIndex >= 0)
				{
					if (chunkEndIndex > chunk.m_ChunkLength)
					{
						chunkEndIndex := chunk.m_ChunkLength
					}

					chunkCount := count
					chunkStartIndex := chunkEndIndex - count
					if (chunkStartIndex < 0)
					{
						chunkCount += chunkStartIndex
						chunkStartIndex := 0
					}
					curDestIndex -= chunkCount
					count -= chunkCount
					MfMemoryString.CopyToCharList(chunk.m_ChunkChars, chunkStartIndex, destination, curDestIndex, chunkCount)
				}
				chunk := chunk.m_ChunkPrevious
			}
		}
; 	End:CopyTo ;}

;{ 	EnsureCapacity
/*
	Method: EnsureCapacity()

	OutputVar := instance.EnsureCapacity(capacity)

	EnsureCapacity(capacity)
		Ensures that the capacity of this instance of StringBuilder is at least the specified value.
	Parameters:
		capacity
			The minimum capacity to ensure.
			Can be any type that matches IsInteger or var integer.
	Returns:
		The new capacity of this instance as var integer.
	Throws:
		Throws MfArgumentOutOfRangeException capacity is less than zero -or- Enlarging the value of this instance would exceed MaxCapacity.
	Remarks:
		If the current capacity is less than the capacity parameter, memory for this instance is reallocated to hold at
		least capacity number of characters; otherwise, no memory is changed.
*/
	EnsureCapacity(capacity) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		capacity := MfInteger.GetValue(capacity)
		if (capacity < 0)
		{
			ex := new new MfArgumentOutOfRangeException("capacity", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeCapacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Capacity < capacity)
		{
			this.Capacity := capacity
		}
		return this.Capacity
	}
; 	End:EnsureCapacity ;}
;{ 	Insert
/*
	OutputVar := instance.Insert(index, chars)
	OutputVar := instance.Insert(index, chars, startIndex, charCount)
	OutputVar := instance.Insert(index, value)
	OutputVar := instance.Insert(index, value, repeatCount)
*/
/*
	Method: Insert(index, chars)
		Inserts the string representation of the Unicode characters in a specified list to this instance.
	Parameters:
		index
			The position in this instance where insertion begins.
			Can be any type that matches IsInteger or var integer.
		chars
			Instance of MfCharList to insert.
	Returns:
		A reference to this instance after the insert operation has completed.
	Throws:
		Throws MfArgumentOutOfRangeException if index is less than zero or greater than the Length of this instance
		-or-
		enlarging the value of this instance would exceed MaxCapacity.
	Remarks:
		This method inserts at the index position all the characters in the specified MfCharList to the current instance
		in the same order as they appear in value. If value is null, no changes are made.
*/
/*
	Method: Insert(index, chars, startIndex, charCount)
		Inserts the string representation of a specified sublist of Unicode characters to this instance.
	Parameters:
		index
			The position in this instance where insertion begins.
			Can be any type that matches IsInteger or var integer.
		chars
			Instance of MfCharList to insert.
		startIndex
			The starting position in chars.
			Can var integer or any type that matches IsInteger.
		charCount
			The number of characters to append.
			Can var integer or any type that matches IsInteger.
	Returns:
		A reference to this instance after the insert operation has completed.
	Throws:
		Throws MfArgumentNullException if chars is null or chars.Count is 0 and startIndex or charCount is not equal to zero.
		Throws MfArgumentOutOfRangeException if index, startIndex or charCount is less than zero.
		- or -
		index is greater than the length of this instance.
		- or -
		startIndex + charCount is greater than the length of value.
		- or -
		Enlarging the value of this instance would exceed MaxCapacity.
	Remarks:
		Existing characters are shifted to make room for the new text. The Capacity of this instance is adjusted as needed.
*/
/*
	Method: Insert(index, value)
		Insert a copy of the specified string var or object to this instance.
	Parameters:
		index
			The position in this instance where insertion begins.
			Can be any type that matches IsInteger or var integer.
		value
			Value to append to current instance.
			Can be var number or string or any object that derives from MfObject.
	Returns:
		A reference to this instance after the insert operation has completed.
	Throws:
		Throws MfArgumentOutOfRangeException if index is less than zero or greater than the current Length of this instance
		or enlarging the value of this instance would exceed MaxCapacity.
	Remarks:
		Existing characters are shifted to make room for the new text. The Capacity of this instance is adjusted as needed.
*/
/*
	Method: Insert(index, value, repeatCount)
		Inserts a specified number of copies of the string representation of a Unicode characters to this instance.
	Parameters:
		index
			The position in this instance where insertion begins.
			Can be any type that matches IsInteger or var integer.
		value
			Value to append to current instance.
			Can be var number or string or any object that derives from MfObject.
		repeatCount
			The number of times to append value.
			Can var integer or any type that matches IsInteger.
	Returns:
		A reference to this instance after the insert operation has completed.
	Throws:
		Throws MfArgumentOutOfRangeException repeatCount is less than zero or enlarging the value of this instance would exceed MaxCapacity.
		Throws MfOutOfMemoryException Out of memory.
	Remarks:
		Existing characters are shifted to make room for the new text. The Capacity of this instance is adjusted as needed.
*/
	Insert(args*) {
		pArgs := this._InsertParams(A_ThisFunc, args*)
		pList := pArgs.ToStringList()
		cnt := pArgs.Count
		if (pArgs.Count < 2)
		{
			e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw e
		}
		index := 0
		try
		{
			index := MfInteger.GetValue(pArgs.Item[0])
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "index")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		length := this.Length
		if (index > length)
		{
			ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (cnt = 2)
		{
			; only valid choice is MfChar and Repeat count
			if (pList.Item[1].Value = "MfCharList")
			{
				try
				{
					this._InsertObjInt(index, pArgs.Item[1].ToString(), 1)
					return this
				}
				catch e
				{
					ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			else
			{
				try
				{
					this._InsertObjInt(index, pArgs.Item[1], 1)
					return this
				}
				catch e
				{
					ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
		}
		if (cnt = 3)
		{
			count := 0
			try
			{
				; index, value, repeatCount
				count := MfInteger.GetValue(pArgs.Item[2])
				this._InsertObjInt(index, pArgs.Item[1].ToString(), count)
				return this
			}
			catch e
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "count")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			
			try
			{
				this._InsertObjInt(index, pArgs.Item[1], count)
				return this
			}
			catch e
			{
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else if (cnt = 4)
		{
			; index, MfCharList, startIndex, CharCount
			if (pList.Item[1].Value = "MfCharList")
			{
				lst := pArgs.Item[1]
				startIndex := 0
				try
				{
					startIndex := MfInteger.GetValue(pArgs.Item[2])
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "startIndex")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				CharCount := 0
				try
				{
					CharCount := MfInteger.GetValue(pArgs.Item[3])
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "CharCount")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (lst.Count = 0)
				{
					if (startIndex = 0 && charCount = 0)
					{
						return this
					}
					ex := new MfArgumentNullException("value"fEnvironment.Instance.GetResourceString("ArgumentNull_String"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (startIndex < 0)
				{
					ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (startIndex > lst.Count - charCount)
				{
					ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (charCount > 0)
				{
					this._InsertObjInt(index, lst.ToString(false, startIndex, charCount), 1)
				}
				return this
			}
		}
		e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw e
	}
; 	End:Insert ;}
;{ 	Replace
/*
	OutputVar := instance.Replace(oldValue, newValue)
	OutputVar := instance.Replace(oldValue, newValue, startIndex, count)
*/
/*
	Method: Replace(oldValue, newValue)
		Replaces, within a substring of this instance, all occurrences of a specified string with another specified string.
	Parameters:
		oldValue
			The string to replace.
			Can be var number or string or any object that derives from MfObject.
		newValue
			The string that replaces oldValue, or null.
			Can be var number or string or any object that derives from MfObject.
	Returns:
		A reference to this instance with all instances of oldValue replaced by newValue.
	Throws:
		Throws MfArgumentNullException if oldValue is null.
		Throws MfArgumentException if The length of oldValue is zero.
		Throws MfArgumentOutOfRangeException if enlarging the value of this instance would exceed MaxCapacity.
	Remarks:
		This method performs an ordinal, case-sensitive comparison to identify occurrences of oldValue in the specified substring.
		If newValue is null, all occurrences of oldValue are removed.
*/
/*
	Method: Replace(oldValue, newValue, startIndex, count)
		Replaces, within a substring of this instance, all occurrences of a specified string with another specified string.
	Parameters:
		oldValue
			The string to replace.
			Can be var number or string or any object that derives from MfObject.
		newValue
			The string that replaces oldValue, or null.
			Can be var number or string or any object that derives from MfObject.
		startIndex
			The position in this instance where the substring begins.
			Can be any type that matches IsInteger or var integer.
		count
			The length of the substring.
			Can be any type that matches IsInteger or var integer.
	Returns:
		A reference to this instance with all instances of oldValue replaced by newValue in the range from startIndex to startIndex + count - 1.
	Throws:
		Throws MfArgumentNullException if oldValue is null.
		Throws MfArgumentException if The length of oldValue is zero.
		Throws MfArgumentOutOfRangeException if startIndex or count is less than zero.
		- or -
		startIndex plus count indicates a character position not within this instance.
		- or -
		Enlarging the value of this instance would exceed MaxCapacity.
	Remarks:
		This method performs an ordinal, case-sensitive comparison to identify occurrences of oldValue in the specified substring.
		If newValue is null, all occurrences of oldValue are removed.
*/
	Replace(oldValue, newValue, startIndex=0, count=-1) {
		if (MfNull.IsNull(oldValue))
		{
			ex := new MfArgumentNullException("oldValue")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		startIndex := MfInteger.GetValue(startIndex, 0)
		count := MfInteger.GetValue(count, -1)
		currentLength := this.Length
				
		if ((startIndex < 0) || (startIndex > currentLength))
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (count < 0)
		{
			count := currentLength
		}
		
		if (count < 0 || startIndex > currentLength - count)
		{
			ex := new MfArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		MsOldVal := MfMemoryString.FromAny(oldValue, this.m_Encoding)
		if (MsOldVal.Length = 0)
		{
			ex := new  MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_EmptyName"), "oldValue")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MsNewVal := MfMemoryString.FromAny(newValue, this.m_Encoding)
		deltaLength := MsNewVal.Length - MsOldVal.Length

		; this._Replace(MsOldVal, MsNewVal, startIndex, Count)
		; return this

		; the method of of mergin and replacing was 30 time faster
		; on a string with 4200 chars with a initial buffer of 3000 chars.
		; the MsMemoryString is much faster with find and replace
		; mostly because it does not have to work on multible chunks
		; and consider peices here and there.
		; Also the case insenstive MfMemoryString method uses a special
		; fast machine code method to find the index of the old value ( on 32 bit machine only ).
		; When the newValue and oldValue length are the same the replacements
		; are even faster as the replacement is done by just overwriting the bytes
		; and not mem copy method are used to move and copy bytes to rebuild the string.
		; Due to the speed advantages it is worth merging the smaller chunks together
		; into one chunk and then using MfMemoryString to replace.
		; Note that the maching code fast index searching of MfMemoryString only works on 32 bit machines currently. This is not
		; an issue as there are fallbacks for 64 bit machines but would affect the prefromace some what.
		if (this.m_ChunkOffset > 0 && this.Length < this.MaxChunkSize)
		{
			if (deltaLength = 0)
			{
				this._Merge()
			}
			else
			{
				this._Merge(MfMath.Min(this.Length + MfStringBuilder.DefaultCapacity, this.MaxChunkSize - this.Length))
			}
			
		}

		sIndex := startIndex
		if (this.m_ChunkOffset = 0)
		{
			Indexes := this._GetReplaceIndexsForChunk(this, MsOldVal, sIndex, count)
			ReplacedAll := false
			iCount := count
			i := Indexes.Count
			lst := Indexes.m_InnerList
			iLen := MsOldVal.Length
			while (i >= 1)
			{
				indexValue := lst[i]
				If (indexValue > count)
				{
					i--
					Continue
				}
				if (this.m_ChunkChars.FreeCharCapacity > deltaLength)
				{
					this.m_ChunkChars.ReplaceAtIndex(indexValue, iLen, MsNewVal)
					this.m_ChunkLength := this.m_ChunkChars.Length
				}
				else
				{
					ReplacedAll := false
					break
				}
				iCount := indexValue
				i--
			}
			if (i = 0)
			{
				ReplacedAll = true
			}
			
			; if all the space avaailable in this chunk is used and we
			; are not yet at the max chunk size then add an chunk and
			; call this method again recursivly to mearge chunks and 
			; start replacing again
			; The reason to call recursion here is that the MsMemoryString
			; operates much faster then the MfStringBuilder replace does
			; so for string under the length of MaxChunkSize we can
			; use MsMemoryString repalce method
			if (ReplacedAll = false && this.Length < this.MaxChunkSize)
			{
				this._ExpandByABlock(MfStringBuilder.DefaultCapacity)
				this.Replace(MsOldVal, MsNewVal, sIndex, iCount)
			}
			if (ReplacedAll = false && iCount > 0)
			{
				this._Replace(MsOldVal, MsNewVal, sIndex,  iCount)
			}
		}
		else
		{
			this._Replace(MsOldVal, MsNewVal, sIndex, Count)
		}

		return this
	}
; 	End:Replace ;}
;{ 	Remove
/*
	Method: Remove()
		Removes the specified range of characters from this instance.

	OutputVar := instance.Remove(startIndex, length)

	Remove(startIndex, length)
		Removes the specified range of characters from this instance.
	Parameters:
		startIndex
			The zero-based position in this instance where removal begins.
			Can be any type that matches IsInteger or var integer.
		length
			The number of characters to remove.
			Can be any type that matches IsInteger or var integer.
	Returns:
		A reference to this instance after the insert operation has completed.
	Throws:
		Throws MfArgumentException if startIndex or length are not valid integers.
		Throws MfArgumentOutOfRangeException if If startIndex or length is less than zero, or startIndex + length is greater than the length of this instance.
	Remarks:
		The current method removes the specified range of characters from the current instance.
		The characters at (startIndex + length) are moved to startIndex, and the string value of the current instance is shortened by length.
		The capacity of the current instance is unaffected.
*/
	Remove(startIndex, length) {
		try
		{
			startIndex := MfInteger.GetValue(startIndex)
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try
		{
			length := MfInteger.GetValue(length)
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "length")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length < 0)
		{
			ex := new MFArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (startIndex < 0)
		{
			ex := new MFArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length > this.Length - startIndex)
		{
			ex := new MFArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Length = length && startIndex = 0)
		{
			this.Length := 0
			return this
		}
		if (length > 0)
		{
			stringBuilder := ""
			num := 0
			this._Remove(startIndex, length, stringBuilder, num)
		}
		return this
	}
; 	End:Remove ;}

;{ 	Equals
/*
	Method: Equals()
		Overrides MfObject.Equals()

	OutputVar := instance.Equals(sb)

	Equals(sb)
		Returns a value indicating whether this instance is equal to a specified StringBuilder.
	Parameters:
		sb
			An StringBuilder to compare with this instance.
	Returns:
		true if this instance and sb have equal string, Capacity, and MaxCapacity values; otherwise, false.
*/
	Equals(sb) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(sb))
		{
			return false
		}
		if(MfObject.IsObjInstance(sb, MfStringBuilder) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "sb", "thisChunk"), "sb")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (this.Capacity != sb.Capacity || this.MaxCapacity != sb.MaxCapacity || this.Length != sb.Length)
		{
			return false
		}
		if (MfObject.ReferenceEquals(this, sb))
		{
			return true
		}
		; if this instance and sb instance both have one chununk the compare as MemoryString
		if (this.m_ChunkOffset = 0 && sb.m_ChunkOffset = 0)
		{
			return this.m_ChunkChars.Equals(sb.m_ChunkChars)
		}
		thisChunk := this
		i := thisChunk.m_ChunkLength
		sbChunk := sb
		j := sbChunk.m_ChunkLength
		ContinueOutLoop := false
		while (true)
		{
			ContinueOutLoop := false
			i--
			j--
			while (i < 0)
			{
				thisChunk := thisChunk.m_ChunkPrevious
				if (MfNull.IsNull(thisChunk) = false)
				{
					i := thisChunk.m_ChunkLength + i
				}
				else
				{
					ContinueOutLoop := false
					while (j < 0)
					{
						sbChunk := sbChunk.m_ChunkPrevious
						if (MfNull.IsNull(sbChunk))
						{
							break
						}
						j := sbChunk.m_ChunkLength + j
					}
					if (i < 0)
					{
						return j < 0
					}
					if (j < 0)
					{
						return false
					}
					c1 := thisChunk.m_ChunkChars.CharCode[i]
					c2 := sbChunk.m_ChunkChars.CharCode[j]
					if (c1 != c2)
					{
						return false
					}
					ContinueOutLoop := true
					break
				}
			}
			if (ContinueOutLoop = true)
			{
				continue
			}
			while (j < 0)
			{
				sbChunk := sbChunk.m_ChunkPrevious
				if (MfNull.IsNull(sbChunk))
				{
					break
				}
				j := sbChunk.m_ChunkLength + j
			}
			if (i < 0)
			{
				return j < 0
			}
			if (j < 0)
			{
				return false
			}
			c1 := thisChunk.m_ChunkChars.CharCode[i]
			c2 := sbChunk.m_ChunkChars.CharCode[j]
			if (c1 != c2)
			{
				return false
			}
		}
		return j < 0
	}
; 	End:Equals ;}
;{ 	Is - Overrides MfObject
/*
	Method: Is()
		Overrides MfObject.Is().

	OutputVar := instance.Is(ObjType)

	Is(ObjType)
		Gets if current instance of StringBuilder is of the same type as ObjType or derived from ObjType.
	Parameters:
		ObjType
			The object or type to compare to this instance Type.
			ObjType can be an instance of MfType or an object derived from MfObject or an instance of or
			a string containing the name of the object type such as "MfObject"
	Returns:
		Returns true if current object instance is of the same Type as the ObjType or if current instance is derived from ObjType or
		if ObjType = "MfText.StringBuilder" or ObjType = "MfStringBuilder" or if ObjType = "MfText.StringBuilder"; Otherwise false.
	Remarks:
		If a string is used as the Type case is ignored so "MfObject" is the same as "mfobject"
	Example:
		sb := new MfText.StringBuilder("Initial string for stringbuilder.")
		MsgBox % sb.Is("MfText.StringBuilder") ; display 1 for true
		MsgBox % sb.Is("StringBuilder")        ; display 1 for true
		MsgBox % sb.Is("MfStringBuilder")      ; display 1 for true
		MsgBox % sb.Is(MfObject)               ; display 1 for true
		MsgBox % sb.Is(MfString)               ; display 0 for false
*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = "MfText.StringBuilder")
		{
			return true
		}
		if (typeName = "StringBuilder")
		{
			return true
		}
		return base.Is(ObjType)
	}
; 	End:Is ;}
;{ 	ToString - Overrides MfObject
/*
	OutputVar := instance.ToString()
	OutputVar := instance.ToString(AsStringObj)
	OutputVar := instance.ToString(AsStringObj, startIndex)
	OutputVar := instance.ToString(AsStringObj, startIndex, length)
*/
/*
	Method: ToString()
		Converts the value of this instance to a string var.
		A string var whose value is the same as this instance.
	Remarks:
		You must call the ToString() method to convert the StringBuilder object to a String var.
*/
/*
	Method: ToString(AsStringObj)
		Converts the value of this instance to a string var or instance of MfString.
	Parameters:
		AsStringObj
			Boolean value; If true return value will be instance of MfString; Otherwise returns var string.
			Can be boolean var or instance of MfBool.
	Returns:
		If AsStringObj is true a MfString whose value is the same as the specified string of this instance;
		Otherwise a string var whose value is the same as the specified string of this instance.
*/
/*
	Method: ToString(AsStringObj, startIndex)
		Converts the value of this instance to a substring var or instance of MfString.
	Parameters:
		AsStringObj
			Boolean value; If true return value will be instance of MfString; Otherwise returns var string.
			Can be boolean var or instance of MfBool.
			Optional Parameter. Default value is false.
		startIndex
			The zero-based starting position of the substring in this instance.
			Can be any type that matches IsInteger or var integer.
	Returns:
		If AsStringObj is true a MfString whose value is the same as the specified substring of this instance;
		Otherwise a string var whose value is the same as the specified substring of this instance.
		The return substring will be from the zero-base position of startIndex to the end of the instance length.
	Throws:
		Throws MfArgumentOutOfRangeException startIndex is less than zero.
	Remarks:
		You must call the ToString(AsStringObj, startIndex) method to convert the StringBuilder object to a substring var or instance of MfString.
*/
/*
	Method: ToString(AsStringObj, startIndex, length)
		Converts the value of this instance to a substring var or instance of MfString.
	Parameters:
		AsStringObj
			Boolean value; If true return value will be instance of MfString; Otherwise returns var string.
			Can be boolean var or instance of MfBool.
			Optional Parameter. Default value is false.
		startIndex
			The zero-based starting position of the substring in this instance.
			Can be any type that matches IsInteger or var integer.
		length
			The length of the substring.
			Can be any type that matches IsInteger or var integer.
	Returns:
		If AsStringObj is true a MfString whose value is the same as the specified substring of this instance;
		Otherwise a string var whose value is the same as the specified substring of this instance.
	Throws:
		Throws MfArgumentOutOfRangeException if startIndex or length is less than zero or the sum of startIndex and
		length is greater than the length of the current instance.
	Remarks:
		You must call the ToString(AsStringObj, startIndex, length) method to convert the StringBuilder object to a substring var or instance of MfString.
*/
	ToString(AsStringObj:=false, startIndex:=0, length:=-1) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		currentLength := this.Length
		if (currentLength = 0)
		{
			return ""
		}
		startIndex := MfInteger.GetValue(startIndex, 0)
		length := MfInteger.GetValue(length, -1)
		AsStringObj := MfBool.GetValue(AsStringObj, false)
		
		if (length < 0)
		{
			length := currentLength
		}
		if (startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (startIndex > currentLength)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndexLargerThanLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (startIndex > (currentLength - length))
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		DoSub := false
		if (startIndex > 0 || length < currentLength)
		{
			DoSub := true
		}
		stringBuilder := this
		OutOfRange := true
		;~ iLen := 0 ; (this.Length + 1) * this.m_BytesPerChar
		;~ sb := this
		;~ while (MfNull.IsNull(sb) = False)
		;~ {
			;~ iLen += (sb.m_ChunkChars.Length + this.m_BytesPerChar) * this.m_BytesPerChar
			;~ sb := sb.m_ChunkPrevious
		;~ }
		ms := ""

		HasOtherchunk := false
		if (MfNull.IsNull(this.m_ChunkPrevious))
		{
			ms := this.m_ChunkChars
		}
		else
		{
			HasOtherchunk := true
			iLen := (currentLength + 1)
			ms := new MfMemoryString(iLen,, this.m_Encoding)
		}
		if (HasOtherchunk)
		{
			stringBuilder := this
			loop
			{
				if (stringBuilder.m_ChunkLength > 0)
				{
					chunkChars := stringBuilder.m_ChunkChars
					chunkOffset := stringBuilder.m_ChunkOffset
					chunkLength := stringBuilder.m_ChunkLength
					;OutputDebug % chunkChars.ToString()
					if (chunkLength + chunkOffset > ms.CharCapacity || chunkLength > chunkChars.Length)
					{
						break
					}
					ms.OverWrite(stringBuilder.m_ChunkChars, chunkOffset, chunkLength)
				}
				stringBuilder := stringBuilder.m_ChunkPrevious
				if (MfNull.IsNull(stringBuilder))
				{
					OutOfRange := false
					break
				}
			}
			if (OutOfRange)
			{
				ms := ""
				ex := new MfArgumentOutOfRangeException("chunkLength", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			ms.m_MemView.Pos := (currentLength + 1) * this.m_BytesPerChar
			ms.m_CharCount := currentLength
		}
		

		; if flag has been set that this instance contains null char ( unicode 0 ) values
		; or any Latin1 (char 0 to 255 ) not printing char
		; in the string then we will get a new MfMemoryString that ignores all non-printing
		; chars for latin1 and output text from there.
		; If we did not get this new MfMemoryString instance then the text output would stop
		; at the first null char ( unicode 0) encountered in the string.
		; Null value can be added into the current instance by extending the length
		; Other non printing chars cna be added by adding not printing char value
		; with methods such as this._AppendCharCode(8, 1)

		; a := ms.ToArray()
		; i := 1
		; While (i < a.Length())
		; {
		; 	OutputDebug % a[i]
		; 	i += 2
		; }
			

		if (this.m_HasNullChar = true)
		{
			
			if (DoSub)
			{
				ms2 := ms.SubString(startIndex, Length).GetStringIgnoreNull()
			}
			else
			{
				ms2 := ms.GetStringIgnoreNull()
			}
			if (AsStringObj)
			{
				str := new MfString(ms2.ToString(), true)
				return str
			}
			return ms2.ToString()
		}
		if (DoSub)
		{
			if (AsStringObj)
			{
				str := new MfString(ms.ToString(startIndex, Length), true)
				return str
			}
			return ms.ToString(startIndex, Length)
		}
		if (AsStringObj)
		{
			str := new MfString(ms.ToString(), true)
			return str
		}
		return ms.ToString()
	}
; 	End:ToString ;}
;{ 	__Delete
	; automatically called by AutoHotkey when class instance is destroyed
	; do a little clean up to release memory
	__Delete() {
		this.m_ChunkPrevious := ""
		this.m_ChunkChars := ""
	}
; 	End:__Delete ;}
; End:Methods ;}
;{ 	Properties
;{ Capacity
/*
	Property: Capacity [get\set]
		Gets or sets the maximum number of characters that can be contained in the memory allocated by the current instance.
	Value:
		Value is an integer and can be var or any type that matches IsIntegerNumber.
	Gets:
		Gets integer var of the capacity of the current StringBuilder object.
	Sets:
		Set the capacity of the current StringBuilder object.
		Can  be var or any type that matches IsIntegerNumber.
	Throws:
		Throws MfArgumentOutOfRangeException if the value specified for a set operation is less than zero or greater than MaxCapacity.
	Remarks:
		The maximum number of characters that can be contained in the memory allocated by the current instance. Its value can range from Length to MaxCapacity.
		Capacity does not affect the string value of the current instance. Capacity can be decreased as long as it is not less than Length.
		The StringBuilder dynamically allocates more space when required and increases Capacity accordingly.
		For performance reasons, a StringBuilder might allocate more memory than needed. The amount of memory allocated is implementation-specific.
*/
		Capacity[]
		{
			get {
				return this.m_ChunkChars.CharCapacity + this.m_ChunkOffset
			}
			set {
				_value := MfInteger.GetValue(value)
				if (_value < 0)
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeCapacity"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (_value > this.m_MaxCapacity)
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Capacity"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (_value < this.Length)
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_SmallCapacity"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (this.Capacity != _value)
				{
					; this will expand the current chunk to add the new expanded Capacity
					v := _value - this.m_ChunkOffset
					
					ms := new MfMemoryString(v,, this.m_Encoding)
					ms.Append(this.m_ChunkChars)
					this.m_ChunkChars := ""
					this.m_ChunkChars := ms
				}
			}
		}
	; End:Capacity ;}
;{ MaxCapacity
/*
	Property: MaxCapacity [get]
		Gets the maximum capacity of the current StringBuilder object.
	Value:
		Value is an integer and can be var or any type that matches IsIntegerNumber.
	Gets:
		Gets integer var of the maximum capacity of the current StringBuilder object
	Throws:
		Throws MfArgumentOutOfRangeException if the value specified for a set operation is less than zero or greater than MaxCapacity.
	Remarks:
		The length of a StringBuilder object is defined by its number of Char objects.
		Like the MfString.Length property, the Length property indicates the length of the current string object.
		Unlike the MfString.Length property, which is read-only, the Length property allows you to modify the length of the string stored to the
		StringBuilder object.
		If the specified length is less than the current length, the current StringBuilder object is truncated to the specified length.
		If the specified length is greater than the current length, the end of the string value of the current StringBuilder object is
		padded with the Unicode NULL character (U+0000).
		If the specified length is greater than the current capacity, Capacity increases so that it is greater than or equal to the specified length.
		When you instantiate the StringBuilder object by calling Constructor(capacity, maxCapacity), both the length and the capacity of
		the StringBuilder instance can grow beyond the value of its MaxCapacity property. This can occur particularly when you call the Append,
		 and AppendFormat methods to append small strings.
*/
		MaxCapacity[]
		{
			get {
				return this.m_MaxCapacity
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "MaxCapacity")
				Throw ex
			}
		}
; End:MaxCapacity ;}
;{ Chars
/*
	Property: Chars [get\set]
		Gets or sets the character at the specified character position in this instance.
	Parameters:
		Index:
			The zero-based position of the character.
			Can be any type that matches IsInteger or var integer.
		Value:
			When setting can be var string or instance of MfChar or MfString.
	Gets:
		Returns var string containing the char value at the position of the argument index.
	Sets:
		Sets the char value at the position of the argument index.
	Throws:
		Throws MfArgumentOutOfRangeException if index is outside the bounds of this instance while setting a character.
		Throws MfIndexOutOfRangeException if index is outside the bounds of this instance while getting a character.
	Remarks:
		The index parameter is the position of a character within the StringBuilder.
		The first character in the string is at index 0. The length of a string is the number of characters it contains.
		The last accessible character of a StringBuilder instance is at index Length - 1.
*/
		Chars[index]
		{
			get {
				;return this.m_Item
				stringBuilder := this
				_index := MfInteger.GetValue(index)
				i := 0
				loop
				{
					i := _index - stringBuilder.m_ChunkOffset
					if (i >= 0)
					{
						break
					}
					stringBuilder := stringBuilder.m_ChunkPrevious
					if (MfNull.IsNull(stringBuilder))
					{
						ex := new MfIndexOutOfRangeException()
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					if (i >= stringBuilder.m_ChunkLength)
					{
						ex := new MfIndexOutOfRangeException()
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
				}
				return this._GetCharFromChunk(stringBuilder.m_ChunkChars, i)
			}
			set {
				;this.m_Item := value
				;return this.m_Item
				stringBuilder := this
				_index := MfInteger.GetValue(index)
				i := 0
				Loop
				{
					i := _index - stringBuilder.m_ChunkOffset
					if (i >= 0)
					{
						break
					}
					stringBuilder := stringBuilder.m_ChunkPrevious
					if (MfNull.IsNull(stringBuilder))
					{
						ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					if (i >= stringBuilder.m_ChunkLength)
					{
						ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					;this._SetCharFromChunk(stringBuilder.m_ChunkChars, i, value)
				}
				this._SetChar(stringBuilder, i, MfString.GetValue(value))
			}
		}
; End:Chars ;}
;{ Length
/*
	Property: Length [get\set]
		Gets or sets the length of the current StringBuilder object.
	Value:
		Value is an integer and can be var or any type that matches IsIntegerNumber.
	Gets:
		Gets integer var of the length of the current StringBuilder object
	Sets:
		Set the length of the current StringBuilder object.
		Can  be var or any type that matches IsIntegerNumber.
	Throws:
		Throws MfArgumentOutOfRangeException if the value specified for a set operation is less than zero or greater than MaxCapacity.
	Remarks:
		The length of a StringBuilder object is defined by its number of Char objects.
		Like the MfString.Length property, the Length property indicates the length of the current string object. Unlike the MfString.Length
		property, which is read-only, the Length property allows you to modify the length of the string stored to the StringBuilder object.
		If the specified length is less than the current length, the current StringBuilder object is truncated to the specified length.
		If the specified length is greater than the current length, the end of the string value of the current StringBuilder object is
		padded with the Unicode NULL character (U+0000).
		If the specified length is greater than the current capacity, Capacity increases so that it is greater than or equal to the specified length.
*/
		Length[]
		{
			get {
				return this.m_ChunkOffset + this.m_ChunkLength
			}
			set {
				_value := MfInteger.GetValue(value)
				if (_value < 0)
				{
					ex := new MfArgumentOutOfRangeException("value", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeLength"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (_value > this.m_MaxCapacity)
				{
					ex := new MfArgumentOutOfRangeException("value", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_SmallCapacity"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				capacity := this.Capacity
				if (_value = 0 && MfNull.IsNull(this.m_ChunkPrevious))
				{
					this.m_ChunkLength := 0
					this.m_ChunkOffset := 0
					this.m_ChunkChars.Clear()
					return
				}
				i := _value - this.Length
				if (i > 0)
				{
					this._AppendCharCode(0, i)
					return
				}
				BytesPerChar := MfStringBuilder.m_BytesPerChar
				stringBuilder := this._FindChunkForIndex(_value)
				if (this.Equals(stringBuilder) = false)
				{
					ms := new MfMemoryString(capacity - stringBuilder.m_ChunkOffset,, this.m_Encoding)
					ms.Append(stringBuilder.m_ChunkChars)
					this.m_ChunkChars := ""
					this.m_ChunkChars := ms
					this.m_ChunkPrevious := ""
					this.m_ChunkPrevious := stringBuilder.m_ChunkPrevious
					this.m_ChunkOffset := stringBuilder.m_ChunkOffset
				}
				
				this.m_ChunkLength := value - stringBuilder.m_ChunkOffset
				if (this.m_ChunkChars.m_MemView.Size > (this.m_ChunkLength * BytesPerChar))
				{
					this.m_ChunkChars.m_MemView.Pos := (this.m_ChunkLength + 1) * BytesPerChar
					this.m_ChunkChars.m_CharCount := this.m_ChunkLength
				}
				else
				{
					this.m_ChunkChars.m_MemView.Pos := this.m_ChunkChars.m_MemView.Size
					this.m_ChunkLength := this.m_ChunkChars.m_MemView.Size // BytesPerChar
					this.m_ChunkChars.m_CharCount := this.m_ChunkLength
				}
				if (this.m_ChunkChars.FreeCapacity > 0)
				{
					; set the next char past m_MemView.Pos to 0 for good measure
					i := 1
					While (i <= BytesPerChar)
					{
						this.m_ChunkChars.Byte[this.m_ChunkChars.m_MemView.Pos - i] := 0
						i++
					}
				}
			}
		}
	; End:Length ;}
; 	End:Properties ;}
;{ 	Internal Methods
;{ 	_AppendString
/*
	_AppendString()
		Appends any MfObject or var to current instance
	Parameters:
		obj
			Object or var to add
	Returns:
		Returns current instance after append
	Throws:
		Throws MfArgumentOutOfRangeException if Adding obj goes beyond Max Capacity
	Remarks:
		Private Method
*/
	_AppendString(obj) {
		ms := MfMemoryString.FromAny(obj, this.m_Encoding)
		sLen := ms.m_CharCount
		if (sLen = 0)
		{
			ms := ""
			return this
		}
		chunkChars := this.m_ChunkChars
		chunkLength := this.m_ChunkLength
		num := chunkLength + sLen
		if (sLen <= chunkChars.FreeCharCapacity)
		{
			chunkChars.Append(ms)
			this.m_ChunkLength := num
		}
		else
		{
			return this._AppendHelper(ms, sLen)
		}
		return this
	}
; 	End:_AppendString ;}
	;{ 	_AppendHelper
	; msObj is MfMemoryString instance
/*
	_AppendHelper()
		Determines if current instance can append to current chunk or if expansion is needed
		and then appends the value of msObj
	Parameters:
		msObj
			MfMemoryString Instance
		valueCount
			The count in chars that is to be added
	Returns:
		Returns current instance
	Throws:
		Throws MfArgumentOutOfRangeException if Adding obj goes beyond Max Capacity
	Remarks:
		Private Method
*/
	_AppendHelper(msObj, valueCount) {
		
		num := valueCount + this.m_ChunkLength
		if (num <= this.m_ChunkChars.FreeCharCapacity)
		{
			chunkChars.Append(msObj)
			this.m_ChunkLength := num
		}
		else
		{
			num2 := this.m_ChunkChars.CharCapacity - this.m_ChunkLength
			if (num2 > 0)
			{
				if (msObj.m_CharCount > num2)
				{
					msSub := msObj.SubString(0, num2)
					this.m_ChunkChars.Append(msSub)
					msSub := ""
				}
				else
				{
					this.m_ChunkChars.Append(msObj)
				}
				this.m_ChunkLength := this.m_ChunkChars.m_CharCount
			}
			num3 := valueCount - num2
			this._ExpandByABlock(num3)
			if (num3 > 0)
			{
				if (num2 <= 0)
				{
					this.m_ChunkChars.Append(msObj)
				}
				else
				{
					msSub := msObj.SubString(num2)
					this.m_ChunkChars.Append(msSub)
					msSub := ""
				}
			}
			else
			{
				this.m_ChunkChars.Append(msObj)
			}
			this.m_ChunkLength := this.m_ChunkChars.m_CharCount
		}
		return this
	}
; 	End:_AppendHelper ;}
;{ 	_AppendChar
	; appends a char (character) to the end of the current instance repeatCount number of times
	; internal method
	_AppendChar(value, repeatCount=1)	{
		if (repeatCount < 0)
		{
			ex := new MfArgumentOutOfRangeException("repeatCount", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeCount"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (repeatCount = 0)
		{
			return this
		}
		num := this.m_ChunkLength
		charCode := 0
		if (MfObject.IsObjInstance(value, MfObject))
		{
			charCode := Asc(value.ToString())
		}
		else
		{
			charCode := Asc(value . "")
		}
		return this._AppendCharCode(charCode, repeatCount)
	}

; 	End:_AppendChar ;}
;{ 	_AppendCharCode
	; appends a char code (number) to the end of the current instance repeatCount number of times
	; internal method
	_AppendCharCode(charCode, repeatCount=1)	{
		if (repeatCount < 0)
		{
			ex := new MfArgumentOutOfRangeException("repeatCount", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeCount"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (repeatCount = 0)
		{
			return this
		}
		num := this.m_ChunkLength
		
		If (this.m_HasNullChar = false && MfMemStrView.IsIgnoreCharLatin1(charCode))
		{
			; set a flag to note that this instance may have one or more null chars
			; this will be checked in the ToString() method to allow displaying of
			; text ignoring null chars (unicode 0)
			this.m_HasNullChar := true
		}
		while (repeatCount > 0)
		{
			if (num < this.m_ChunkChars.FreeCharCapacity)
			{
				;this._SetCharFromChunk(this.m_ChunkChars, num, value)
				this.m_ChunkChars.AppendCharCode(charCode)
				num++
				repeatCount--
			}
			else
			{
				this.m_ChunkLength := num
				this._ExpandByABlock(repeatCount)
				num := 0
			}
		}
		this.m_ChunkLength := num
		return this
	}
; 	End:_AppendCharCode ;}
;{ 	_AppendCharList
/*
	Method: _AppendCharList()

	_AppendCharList()
		Add a list of MfCharList to the current instance
	Parameters:
		lst
			The instance of MfCharList to add to the current instance
		startIndex
			The zero base Index to start reading form lst
		CharCount
			The number of Chars to add from lst to the current instance
	Returns:
		Returns current instance
	Throws:
		Throws MfArgumentOutOfRangeException, MfArgumentNullException
	Remarks:
		Private method
*/
	_AppendCharList(lst, startIndex, charCount) {
		if (startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_GenericPositive"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (charCount < 0)
		{
			ex := new MfArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_GenericPositive"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (MfNull.IsNull(lst) || lst.m_Count = 0)
		{
			if (startIndex = 0 && charCount = 0)
			{
				return this
			}
			ex := new MfArgumentNullException("lst")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		else
		{
			if (charCount > lst.m_Count - startIndex)
			{
				ex := new MfArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (charCount = 0)
			{
				return this
			}
			if (!(lst.m_Encoding = this.m_Encoding))
			{
				; different encodings add differently
				ms := new MfMemoryString(charCount + 1, , this.m_Encoding)
				ms.Append(lst.ToString(false, StartIndex, charCount))
				this._AppendString(ms)
				return this
			}
			StartIndex++
			i := 0
			a := lst.m_InnerList
			While (i < charCount)
			{
				this._AppendCharCode(a[StartIndex + i], 1)
				i++
			}
			return this
		}
	}
; 	End:_AppendCharList ;}
;{ 	_GetReplaceIndexsForChunk
/*
	_GetReplaceIndexsForChunk()
		Gets a MfListVar containing the index of all the replacements from
		smalet index to biggest index in a MfStringBuilder chunk
	Parameters:
		Chunk
			MfStringBuilder Chunk
		MsVal
			MfMemoryString instance that is the needle
		startIndex
			The index in the haystack to starch searhing in
		count
			Then number of chars to search
	Returns:
		Returns MfListVar instance containing all the found index values
	Remarks:
		Private method
*/
	_GetReplaceIndexsForChunk(Chunk, MsVal, startIndex, count) {
		; _startsWithMs(chunk, indexInChunk, count, MsValue) {
		replacements := new MfListVar()
		searchLen := MsVal.Length
		if (searchLen = 0)
		{
			return replacements
		}
		i := startIndex
		iCount := count
		while (i < iCount)
		{
			ix := this._startsWithMs(chunk, i, count, MsVal)
			if (ix >= 0)
			{
				replacements.Add(ix)
				i := ix + searchLen
			}
			Else
			{
				break
			}
		}
		return replacements
			
	}
; 	End:_GetReplaceIndexsForChunk ;}
;{ 	_GetCharFromChunk
	; Gets Char letter from mStr at index
	; mStr is instance of MfMemoryString
	; index is the integer positive number position of the index
	; private method
	_GetCharFromChunk(byref mStr, index) {
		return mStr.Char[index]
	}
; 	End:_GetCharFromChunk ;}
;{ 	_GetCharCodeFromChunk
	; Gets Char Number from mStr at index
	; mStr is instance of MfMemoryString
	; index is the integer positive number position of the index
	; private method
	_GetCharCodeFromChunk(byref mStr, index) {
		return mStr.CharCode[index]
	}
; 	End:_GetCharCodeFromChunk ;}
;{ 	_ExpandByABlock
	; Expands the current instance of MfStringBuilder by adding a new block
	; minBlockCharCount is the minimuim number of characters then new block will hold
	; private method
	_ExpandByABlock(minBlockCharCount) {
		if (minBlockCharCount + this.Length > this.m_MaxCapacity)
		{
			ex := new MfArgumentOutOfRangeException("requiredLength", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_SmallCapacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		; Compute the length of the new block we need 
		; We make the new chunk at least big enough for the current need (minBlockCharCount)
		; But also as big as the current length (thus doubling capacity), up to a maximum
		; (so we stay in the small object heap, and never allocate really big chunks even if
		; the string gets really big.
		newBlockLength := MfMath.Max(minBlockCharCount, MfMath.Min(this.Length, this.MaxChunkSize))
		params := new MfParams()
		params.Data.Add("_internalsb", true)
		params.Add(this)

		this.m_ChunkPrevious := new MfStringBuilder(params)
		this.m_ChunkOffset += this.m_ChunkLength
		this.m_ChunkLength := 0
		if (this.m_ChunkOffset + newBlockLength < newBlockLength)
		{
			this.m_ChunkChars := null
			ex := new MfOutOfMemoryException()
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_ChunkChars := new MfMemoryString(newBlockLength,, this.m_Encoding)
		
		
	}
; 	End:_ExpandByABlock ;}
;{ _FindChunkForIndex
	; finds the chunk the contains the index
	; index - the Positive integer number of an index within the current instance Length
	; returns MfStringBuilder instance
	; Private method
	_FindChunkForIndex(index) {
		chunk := this
		while (chunk.m_ChunkOffset > index)
		{
			chunk := chunk.m_ChunkPrevious
		}
		return chunk
	}
; End:_FindChunkForIndex ;}

;{ _ConstructorParams
	; Gets the Parameters for the __new(args*) method
	; private Method
	_ConstructorParams(MethodName, args*) {

		p := Null
		cnt := MfParams.GetArgCount(args*)

	
		if ((cnt > 0) && MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			; can be up to five parameters
			; Two parameters is not a possibility
			if (p.Count > 4)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
		}
		else
		{

			p := new MfParams()
			p.AllowEmptyString := false ; no strings for parameters in this case
			p.AllowOnlyAhkObj := false ; needed to allow for undefined to be added
			p.AllowEmptyValue := true ; all empty/null params will be added as undefined

			;p.AddInteger(0)
			;return p
			
			; can be up to five parameters
			; Two parameters is not a possibility
			if (cnt > 4)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
			
			i := 1
			while i <= cnt
			{
				arg := args[i]
				try
				{
					if (IsObject(arg))
					{
						p.Add(arg)
					} 
					else
					{
						if (i = 1)
						{
							if (cnt = 1 || cnt = 2)
							{
								if (Mfunc.IsInteger(arg))
								{
									p.AddInteger(arg)
								}
								else
								{
									p.AddString(arg)
								}
								i++
								continue
							}
							if (cnt = 3)
							{
								p.AddInteger(arg)
								i++
								continue
							}
							p.AddString(arg)
							i++
							continue
						}
						if (i = 2)
						{
							; param 2 is always an int when not an MfObject
							result := new MfInteger(arg)
							p.Add(result)
							i++
							continue

						}
						if (i = 3)
						{
							if (cnt = 3 && MfNull.IsNull(arg))
							{
								p.Data.Add("_nullSb", true)
								i++
								continue
							}
							result := new MfInteger(arg)
							p.Add(result)
							i++
							continue
						}
						if (i = 4)
						{
							; param 4 is always an int when not an MfObject
							result := new MfInteger(arg)
							p.Add(result)
							i++
							continue
						}
						i++
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", i), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				i++
			}
			
		}
		;return new MfParams()
		return p
	}
; End:_ConstructorParams ;}
;{ 	_AppendParams
	; Gets the parameters for the Append(args*) method
	; private method
	_AppendParams(MethodName, args*) {

		p := Null
		cnt := MfParams.GetArgCount(args*)

	
		if ((cnt > 0) && MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			; can be up to five parameters
			; Two parameters is not a possibility
			if (p.Count > 3)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
		}
		else
		{

			p := new MfParams()
			p.AllowEmptyString := false ; no strings for parameters in this case
			p.AllowOnlyAhkObj := false ; needed to allow for undefined to be added
			p.AllowEmptyValue := true ; all empty/null params will be added as undefined

			;p.AddInteger(0)
			;return p
			
			; can be up to five parameters
			; Two parameters is not a possibility
			if (cnt > 3)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
			
			i := 1
			while i <= cnt
			{
				arg := args[i]
				try
				{
					if (IsObject(arg))
					{
						p.Add(arg)
					} 
					else
					{
						if (i = 1)
						{
							if (cnt = 2)
							{
								; when count is 2 must be char and repeat count
								p.Add(new MfChar(arg))
							}
							else
							{
								p.AddString(arg)
							}
							
						}
						if (i = 2)
						{
							
							p.AddInteger(arg)

						}
						if (i = 3)
						{
							p.AddInteger(arg)
						}
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", i), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				i++
			}
			
		}
		;return new MfParams()
		return p
	}
; 	End:_AppendParams ;}
;{ 	_InsertParams
	; Gets the parameters for the Insert(args*) method
	; private method
	_InsertParams(MethodName, args*) {

		p := Null
		cnt := MfParams.GetArgCount(args*)

	
		if ((cnt > 0) && MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			; can be up to five parameters
			; Two parameters is not a possibility
			if (p.Count > 4)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
		}
		else
		{

			p := new MfParams()
			p.AllowEmptyString := false ; no strings for parameters in this case
			p.AllowOnlyAhkObj := false ; needed to allow for undefined to be added
			p.AllowEmptyValue := true ; all empty/null params will be added as undefined
			if (cnt > 4)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
			
			i := 1
			while i <= cnt
			{
				arg := args[i]
				try
				{
					if (IsObject(arg))
					{
						p.Add(arg)
					} 
					else
					{
						if (i = 2)
						{
							p.AddString(arg)			
						}
						else 
						{
							p.AddInteger(arg)
						}
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", i), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				i++
			}
			
		}
		;return new MfParams()
		return p
	}
; 	End:_InsertParams ;}
;{ 	_InsertStrInt
	; Inserts one or more copies of a specified string into this instance at the specified character position.
	; index - zero based postive integer index withing the current instance
	; obj, Most any MfObject based object or var string or var number
	; count - the number of times to insert the object
	; MfObject instances are added by calling the ToString() method of the MfObject instance
	; Private Method
	_InsertObjInt(index, obj, count) {
		if (count < 0)
		{
			ex := new MfArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NeedNonNegNum"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		mStr := MfMemoryString.FromAny(obj, this.m_Encoding)
		
		
		if (mStr.Length = 0 || count = 0)
		{
			return this
		}
		insertingChars := mStr.Length * count
		if (insertingChars > this.MaxCapacity - this.Length)
		{
			ex := new MfOutOfMemoryException()
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		chunk := ""
		indexInChunk := 0
		; index in the insert location within the entire instance
		; insertingChars is the length of the string to insert times the count
		this._MakeRoom(index, insertingChars, chunk, indexInChunk, false)
		
		while (count > 0)
		{
			this._ReplaceInPlaceAtChunk(chunk, indexInChunk, mStr, mStr.m_CharCount)
			count--
		}
	}
; 	End:_InsertStrInt ;}
;{ 	_MakeRoom
/*
	_MakeRoom()
		Makes room inside of string builder
	Parameters:
		index
			Integer Index
		count
			Integer Count
		chunk
			MfString Builder Instance ( out )
		indexInChunk
			Integer ( out )
		doneMoveFollowingChars
			Boolean value
	Remarks:
		Private Method
*/
	_MakeRoom(index, count, byRef chunk, ByRef indexInChunk, doneMoveFollowingChars) {
		; index in the insert location within the entire instance
		; copyCount1 is the length of the string to insert times the count
		if (count + this.Length > this.m_MaxCapacity)
		{
			ex := new MfArgumentOutOfRangeException("requiredLength", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_SmallCapacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		chunk := this
		while (chunk.m_ChunkOffset > index)
		{
			chunk.m_ChunkOffset += count
			chunk := chunk.m_ChunkPrevious
		}
		BytesPerChar := MfStringBuilder.m_BytesPerChar
		indexInChunk := index - chunk.m_ChunkOffset ; grab the index within the current chunck
		if (!doneMoveFollowingChars && chunk.m_ChunkLength <= (MfStringBuilder.DefaultCapacity * 2) && chunk.m_ChunkChars.CharCapacity - chunk.m_ChunkLength >= count)
		{
			; Advance Position before calling MoveCharsRight
			chunk.m_ChunkChars.SetPosFromCharIndex(chunk.m_ChunkLength)
			;chunk.m_ChunkChars.MoveCharsRight(indexInChunk, Count, Count)
			chunk.m_ChunkChars.MoveCharsRight(indexInChunk, Count)
			
	
			chunk.m_ChunkLength += count
			chunk.m_ChunkChars.SetPosFromCharIndex(chunk.m_ChunkLength)
			return
		}
		Capacity := MfMath.Max(count, MfStringBuilder.DefaultCapacity)
		params := new MfParams()
		Params.AddInteger(Capacity)
		Params.AddInteger(chunk.m_MaxCapacity)
		If (MfNull.IsNull(chunk.m_ChunkPrevious))
		{
			params.Data.Add("_nullSb", true)
		}
		else
		{
			Params.Add(chunk.m_ChunkPrevious)
		}
		params.Data.Add("_InternalOnly", true)
		;newChunk := new MfStringBuilder(Capacity, chunk.m_MaxCapacity, chunk.m_ChunkPrevious)
		newChunk := new MfStringBuilder(Params)
		; the new newChunk will at least the capacity of the string to insert times then number of number of repeats to insert
		newChunk.m_ChunkLength := count
		; Copy the head of the buffer to the  new buffer. 
		copyCount1 := MfMath.Min(count, indexInChunk)
		
		if (copyCount1 > 0)
		{
			ptr := chunk.m_ChunkChars.BufferPtr
			BytesPerChar := MfStringBuilder.m_BytesPerChar
			MfMemoryString.CopyFromAddress(ptr, newChunk.m_ChunkChars, 0, copyCount1)
			
			;Slide characters in the current buffer over to make room. 
			copyCount2 := indexInChunk - copyCount1
			if (copyCount2 >= 0)
			{	
				;ptr := chunk.m_ChunkChars.BufferPtr
				MfMemoryString.CopyFromAddress(ptr + (copyCount1 * BytesPerChar), chunk.m_ChunkChars, 0, copyCount2)
				;chunk.m_ChunkLength := chunk.m_ChunkChars.Length
				indexInChunk := copyCount2
			}
		}
		newChunk.m_ChunkChars.SetPosFromCharIndex(newChunk.m_ChunkLength)
		;newChunk.m_ChunkLength := newChunk.m_ChunkChars.Length
		; chunk previous string builder will now become the current newChunk
		chunk.m_ChunkPrevious := newChunk
		chunk.m_ChunkOffset += count
		if (copyCount1 < count)
		{
			chunk := newChunk
			indexInChunk := copyCount1
		}
	}
; 	End:_MakeRoom ;}
;{ 	_Merge
	; merges current chunks of into a single chunk optionally adding capacity of ExtraCharCount
	; ExtraCharCount - Extra capacity in chars to add the the merged chunk
	; Merge is valuable in some method such as replace() where mergin a bunch of smaller chunks
	; can result in a much faster find and replace
	; Private method
	_Merge(ExtraCharCount=0) {
		if (this.Length = 0)
		{
			return ""
		}
		stringBuilder := this
		OutOfRange := true
		
		iLen := (this.Length + 1)
		ExtraCharCount := ExtraCharCount * MfStringBuilder.m_BytesPerChar
		ms := new MfMemoryString(iLen + ExtraCharCount,, this.m_Encoding)
		stringBuilder := this
		loop
		{
			if (stringBuilder.m_ChunkLength > 0)
			{
				chunkChars := stringBuilder.m_ChunkChars
				chunkOffset := stringBuilder.m_ChunkOffset
				chunkLength := stringBuilder.m_ChunkLength
				if (chunkLength + chunkOffset > ms.CharCapacity || chunkLength > chunkChars.Length)
				{
					break
				}
				ms.OverWrite(stringBuilder.m_ChunkChars, chunkOffset, chunkLength)
			}
			stringBuilder := stringBuilder.m_ChunkPrevious
			if (MfNull.IsNull(stringBuilder))
			{
				OutOfRange := false
				break
			}
		}
		if (OutOfRange)
		{
			ms := ""
			ex := new MfArgumentOutOfRangeException("chunkLength", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		ms.m_MemView.Pos := (this.Length + 1) * this.m_BytesPerChar
		ms.m_CharCount := this.Length
		this.m_ChunkLength := ms.m_CharCount
		this.m_ChunkOffset := 0
		this.m_ChunkPrevious := ""
		this.m_ChunkChars := ""
		this.m_ChunkChars := ms
	}
; 	End:_Merge ;}
;{ 	_Next
	; chunk - MfStringBuilder instance
	; Gets then next chunk from chunk
	; return MfStringBuilder instance
	; Private Method
	 _Next(chunk) {
		if (this.Equals(chunk))
		{
			return Null
		}
		return this._FindChunkForIndex(chunk.m_ChunkOffset + chunk.m_ChunkLength)
	}
; 	End:_Next ;}
;{ 	_Remove
	; removes from an instance of MfStringBuilder
	; startIndex - int
	; count - int
	; chunk - MfStringBuilder
	; indexInChunk - int
	; Private Method
	_Remove(startIndex, count, ByRef chunk, ByRef indexInChunk) {
		endIndex := startIndex + count
		; Find the chunks for the start and end of the block to delete. 
		chunk := this
		endChunk := ""
		endIndexInChunk := 0

		loop
		{
			if (endIndex - chunk.m_ChunkOffset >= 0)
			{
				if (endChunk == "")
				{
					endChunk := chunk
					endIndexInChunk := endIndex - endChunk.m_ChunkOffset
				}
				if (startIndex - chunk.m_ChunkOffset >= 0)
				{
					break
				}
			}
			else
			{
				chunk.m_ChunkOffset -= count
			}
			chunk := chunk.m_ChunkPrevious
		}
		indexInChunk := startIndex - chunk.m_ChunkOffset
		copyTargetIndexInChunk := indexInChunk
		copyCount := endChunk.m_ChunkLength - endIndexInChunk
		if (endChunk.Equals(chunk) = false)
		{
			copyTargetIndexInChunk := 0
			;  Remove the characters after startIndex to end of the chunk
			chunk.m_ChunkLength := indexInChunk
			; set pos in MemoryString to reflect m_ChunkLength
			chunk.m_ChunkChars.SetPosFromCharIndex(chunk.m_ChunkLength)
			
			endChunk.m_ChunkPrevious := chunk
			endChunk.m_ChunkOffset := chunk.m_ChunkOffset + chunk.m_ChunkLength
			;  If the start is 0 then we can throw away the whole start chunk
			if (indexInChunk = 0)
			{
				endChunk.m_ChunkPrevious := chunk.m_ChunkPrevious
				chunk := endChunk
			}
		}
		endChunk.m_ChunkLength -= endIndexInChunk - copyTargetIndexInChunk
		
		
		; remove any characters in the end chunk, by sliding the characters down. 
		if (copyTargetIndexInChunk != endIndexInChunk) ; sometimes no move is necessary
		{
			MfMemoryString.CopyFromIndex(endChunk.m_ChunkChars, endIndexInChunk, endChunk.m_ChunkChars, copyTargetIndexInChunk, copyCount)
			;endChunk.m_ChunkChars.MoveCharsLeft(copyTargetIndexInChunk, endIndexInChunk, copyCount)
		}
		endChunk.m_ChunkChars.SetPosFromCharIndex(endChunk.m_ChunkLength)
		
	}
; 	End:_Remove ;}
;{ 	_Replace
	; helper method to find and replace string value within the current instance
	; MsOldVal - Instance of MfMemoryString of the value to find
	; MsNewVal - Instance of MfMemoryString of the value to replace
	; startIndex - then zero based index to start searching
	; count - the number of chars to limit the search to
	; Private method
	_Replace(byref MsOldVal, byref MsNewVal, startIndex, count) {
		replacements := new MfListVar() ; A list of replacement positions in a chunk to apply
		replacementsCount := 0
		; Find the chunk, indexInChunk for the starting point
		chunk := this._FindChunkForIndex(startIndex)
		indexInChunk := startIndex - chunk.m_ChunkOffset
		iPrev := -1
		searchLen := MsOldVal.m_CharCount
		iPrevIndexChunk := 0
		
		while (count > 0)
		{
			; The folowing commeted out block  was intended to do faster finding of index with chunks. For some reason
			; it was much slower on instances with longer length. It seeem the most effecient way is to exclude it for now
			; Anoter consideration is to get the indexs for current chunk in a seperate list as _GetReplaceIndexsForChunk method does
			; and then add those indexes to the current list.
			; Note that the maching code fast index searching of MfMemoryString only works on 32 bit machines currently. This is not
			; an issue as there are fallbacks for 64 bit machines but would affect the prefromace of the block that is commented out below.

			;if (iPrev != chunk.m_ChunkOffset && iPrev < -2) ; this line would ensure the entire block was bypassed
			;~ if (iPrev != chunk.m_ChunkOffset)
			;~ {
				;~ if (chunk.m_ChunkLength < searchLen)
				;~ {
					;~ iPrev := chunk.m_ChunkOffset
					;~ count++
					;~ indexInChunk--
				;~ }
				;~ else
				;~ {
					;~ ; only check once per chunk once all index are found
					;~ ; this section will search the entire chunk up to the
					;~ ; end minus the length of (MsOldVal - 1)
					;~ ; usint this _startsWithMs method seem to be about 20 percent faster than _StartsWith
					;~ ; _startsWithMs will not searc from the end of one chunk into the beginning of the next
					;~ ; this is why _startsWith is still included to pick up the oldvalues that cross chuncks
					;~ ix := this._startsWithMs(chunk, indexInChunk, count, MsOldVal)
					;~ if (ix >= 0)
					;~ {
						;~ if (MfNull.IsNull(replacements) || replacements.Count = 0)
						;~ {
							;~ replacements := new MfListVar(5)
						;~ }
						;~ else if (replacementsCount >= replacements.Count)
						;~ {
							;~ newArray := new MfListVar(replacements.Count * 3 // 2 + 4) ; grow by 1.5X but more in the begining
							;~ MfListbase.Copy(replacements, newArray, replacements.Count)
							;~ replacements := newArray
						;~ }
						;~ replacements.Item[replacementsCount++] := ix
						;~ indexInChunk += ix + searchLen
						
						;~ cntAdjust := iPrevIndexChunk > 0 ? iPrevIndexChunk + (ix - searchLen):  (ix + searchLen)
						;~ if (iPrevIndexChunk > 0)
						;~ {
							;~ count += iPrevIndexChunk - (ix + searchLen)
						;~ }
						;~ Else
						;~ {
							;~ count -=  (ix + searchLen)
						;~ }
						
						;~ iPrevIndexChunk := indexInChunk
					;~ }
					;~ else
					;~ {
						;~ ; if there is not match or out of matches for chunk then
						;~ ; set value to one less then the chunk length to search the rest of the chars
						;~ ; posssibly into the next chunk
						;~ iPrev := chunk.m_ChunkOffset
						;~ count -= (chunk.m_ChunkLength - (searchLen - 1))
						;~ indexInChunk :=  (chunk.m_ChunkLength - (searchLen - 1))
					;~ }

				;~ }
			;~ }
			;~ else if (this._StartsWith(chunk, indexInChunk, count, MsOldVal)) ; Look for a match in the chunk,indexInChunk pointer
			if (this._StartsWith(chunk, indexInChunk, count, MsOldVal)) ; Look for a match in the chunk,indexInChunk pointer
			{
				; Push it on my replacements array (with growth), we will do all replacements in a
				; given chunk in one operation below (see ReplaceAllInChunk) so we don't have to slide
				; many times.
				if (MfNull.IsNull(replacements) || replacements.Count = 0)
				{
					replacements := new MfListVar(5)
				}
				else if (replacementsCount >= replacements.Count)
				{
					newArray := new MfListVar(replacements.Count * 3 // 2 + 4) ; grow by 1.5X but more in the begining
					MfListbase.Copy(replacements, newArray, replacements.Count)
					replacements := newArray
				}
				replacements.Item[replacementsCount++] := indexInChunk
				;OutputDebug % "Replacement Count: " . replacementsCount . " Index: " . indexInChunk
				;OutputDebug % "2: Before count:" . count . " indexInChunk: " . indexInChunk
				indexInChunk += searchLen
				count -= searchLen
				;OutputDebug % "2: After  count:" . count . " indexInChunk: " . indexInChunk

			}
			else
			{
				indexInChunk++
				--count
			}
			if (indexInChunk >= chunk.m_ChunkLength || count = 0) ; Have we moved out of the current chunk
			{
				; Replacing mutates the blocks, so we need to convert to logical index and back afterward. 
				index := indexInChunk + chunk.m_ChunkOffset
				indexBeforeAdjustment := index

				; See if we accumulated any replacements, if so apply them 
				this._ReplaceAllInChunk(replacements, replacementsCount, chunk, MsOldVal.m_CharCount, MsNewVal)
				; The replacement has affected the logical index.  Adjust it.  
				index += ((MsNewVal.m_CharCount - MsOldVal.m_CharCount) * replacementsCount)
				replacementsCount := 0

				chunk := this._FindChunkForIndex(index)
				indexInChunk := index - chunk.m_ChunkOffset
			}
		}
	}
; 	End:_Replace ;}
;{ 	_ReplaceAllInChunk
/*
 *	'replacements' is a MfListVar list of index (relative to the begining of the 'chunk' to remove
 *	'removeCount' characters and replace them with 'value'.   This routine does all those 
 *	replacements in bulk (and therefore very efficiently. 
 *	with the string 'value'.
 *	'sourceChunk' is instance of MfStringBuilder
 *	'Value' is instance of MfMemoryString
 *	Private Method
*/
	_ReplaceAllInChunk(replacements, replacementsCount, sourceChunk, removeCount, value) {
		if (replacementsCount <= 0)
		{
			return
		}

		delta := (value.m_CharCount - removeCount) * replacementsCount
		targetChunk := sourceChunk ; the target as we copy chars down
		targetIndexInChunk := replacements.Item[0]

		; Make the room needed for all the new characters if needed. 
		if (delta > 0)
		{
			this._MakeRoom(targetChunk.m_ChunkOffset + targetIndexInChunk, delta, targetChunk, targetIndexInChunk, true)
		}
		i := 0
		Loop
		{
			; Copy in the new string for the ith replacement
			this._ReplaceInPlaceAtChunk(targetChunk, targetIndexInChunk, value, value.m_CharCount)
			gapStart := replacements.Item[i] + removeCount
			i++
			if (i >= replacementsCount)
			{
				;targetChunk.m_ChunkChars.SetPosFromCharIndex(targetChunk.m_ChunkLength)
				break
			}
			gapEnd := replacements.Item[i]
			if (delta != 0) ; can skip the sliding of gaps if source an target string are the same size.
			{
				subValue := sourceChunk.m_ChunkChars.SubString(gapStart)
				this._ReplaceInPlaceAtChunk(targetChunk, targetIndexInChunk, subValue, gapEnd - gapStart)
			}
			else
			{
				targetIndexInChunk += gapEnd - gapStart
			}
		}
		if (delta < 0)
		{
			; flip delta to remove
			this._Remove(targetChunk.m_ChunkOffset + targetIndexInChunk, Abs(delta), targetChunk, targetIndexInChunk)
		}
	}
; 	End:_ReplaceAllInChunk ;}
;{ 	_ReplaceInPlaceAtChunk
/*
 *	ReplaceInPlaceAtChunk is the logical equivalent of 'memcpy'.  Given a chunk and an index in
 *	that chunk, it copies in 'count' characters from 'value' and updates 'chunk, and indexInChunk to 
 *	point at the end of the characters just copyied (thus you can splice in strings from multiple 
 *	places by calling this mulitple times.  
 *	chunk - StringBuilder
 *	indexInChunk - positive zero based integer of index
 *	value - instance of MfMemoryString to replace
 *	count - integer count of the lendh of value
 *	Private Method
*/
	_ReplaceInPlaceAtChunk(ByRef chunk, ByRef indexInChunk, value, count) {
		; first pass chunk.m_ChunkChars inserts at index 3 the first 8 chars of value
		
		if (count != 0)
		{
			ptr := Value.BufferPtr
			BytesPerChar := MfStringBuilder.m_BytesPerChar
			loop
			{
				lengthInChunk := chunk.m_ChunkLength - indexInChunk
				lengthToCopy := MfMath.Min(lengthInChunk, count)
				
				MfMemoryString.CopyFromAddress(ptr, chunk.m_ChunkChars, indexInChunk, lengthToCopy)
				
				; Advance the index.
				indexInChunk += lengthToCopy
				if (indexInChunk >= chunk.m_ChunkLength)
				{
					chunk := this._Next(chunk)
					indexInChunk := 0
				}
				count -= lengthToCopy
				if (count = 0)
				{
					break
				}
				ptr += (lengthToCopy * BytesPerChar)
			}
		}
	}
	
; 	End:_ReplaceInPlaceAtChunk ;}
;{ 	_StartsWith
	; Returns true if the string that is starts at 'chunk' and 'indexInChunk, and has a logical
	; length of 'count' starts with the string 'value'. 
	; chunk - instance of MfStringBuilder
	; indexInChunk - The zero based positive index within the chunk to start the search
	; count - the number of chars to limit the search to
	; MsValue - instance of MfMemoryString to search for
	; This method will span from the end of one chunk to the start of the next chunk and
	; therefore is suitalbe for searching when there is more then one chunk in the current instance.
	; Private Method
	_StartsWith(chunk, indexInChunk, count, MsValue) {
		if (count = 0)
		{
			return false
		}
		PtrA := chunk.m_ChunkChars.BufferPtr
		PtrB := MsValue.BufferPtr
		BytesPerChar := chunk.m_ChunkChars.m_BytesPerChar
		sType := chunk.m_ChunkChars.m_sType
		len := MsValue.Length ; * BytesPerChar
		indexInChunk := indexInChunk ; * BytesPerChar
		i := 0
		While (i < len)
		{
			if (count = 0)
			{
				return false
			}
			if (indexInChunk >= chunk.m_ChunkLength) 
			{
				chunk := this._Next(chunk)
				if (MfNull.IsNull(chunk))
				{
					return false
				}
				indexInChunk := 0
				PtrA := chunk.m_ChunkChars.BufferPtr
			}

			; See if there no match, break out of the inner for loop
			numA := NumGet(ptrA + 0, indexInChunk * BytesPerChar, sType)
			numB := NumGet(ptrB + 0, i * BytesPerChar, sType)
			
			if (numA != numB)
			{
				return false
			}
			indexInChunk++
			--count
			i++
		}
		return true
	}
; 	End:_StartsWith ;}
;{ 	_startsWithMs
	; Returns found index if the string that is starts at 'chunk' and 'indexInChunk, and has a logical
	; length of 'count' starts with the string 'value'. 
	; chunk - instance of MfStringBuilder
	; indexInChunk - The zero based positive index within the chunk to start the search
	; count - the number of chars to limit the search to
	; MsValue - instance of MfMemoryString to search for
	; This method will NOT span chunks and
	; therefore is NOT suitalbe for searching when there is more then one chunk in the current instance.
	; Method is faster for searching single chunk instances of MfStringBuilder then _StartsWith() because
	; the MfMemoryString.IndexOf() uses a machine code base search to locate the index.
	; Private Method
	_startsWithMs(chunk, indexInChunk, count, MsValue) {
		if (count = 0)
		{
			return -1
		}
		index := chunk.m_ChunkChars.IndexOf(MsValue,indexInChunk)
		return index
	}
; 	End:_startsWithMs ;}
;{ 	_SetChar
	; Sets char letter at index for given sb
	; sb is instance of MfStringBuilder
	; index is the integer positive number position of the index
	; value is the value as single character of string
	; Private method
	_SetChar(ByRef sb, index, value) {
		sb.m_ChunkChars.Char[index] := value
	}
; 	End:_SetChar ;}
;{ 	_SetCharFromChunk
	; Sets char letter at index for given mStr
	; mStr is instance of MfMemoryString
	; index is the integer positive number position of the index
	; value is the value as single character of string
	; Private method
	_SetCharFromChunk(byref mStr, index, value) {
		mStr.Char[index] := value
	}
; 	End:_SetCharFromChunk ;}
;{ 	_ToMemoryString
	; gets a MfMemoryString Instance representing the current string value
	; If current length is less then MaxChunkSize then merge will be called
	; if only one chunk then that chunk MfMemoryString instance is returned
	; otherwise a new MfMemoryString intance is returned from ToString() method
	_ToMemoryString() {
		if (this.m_ChunkOffset > 0 && this.Length < this.MaxChunkSize)
		{
			this._Merge()
		}
		if (this.m_ChunkOffset > 0)
		{
			str := this.ToString()
			ms := new MfMemoryString(str, , this.m_Encoding)
			return ms
		}
		return this.m_ChunkChars
	}
; 	End:_ToMemoryString ;}
;{ 	Constructor Helpers
	_new() {
		this._newInt(MfStringBuilder.DefaultCapacity)
	}
	_newInt(capacity) {
		
		this._newStrInt("",capacity)
	}
	_newStr(value) {
		this._newStrInt(value, MfStringBuilder.DefaultCapacity)
	}
	_newStrInt(value, capacity) {
		if (MfObject.IsObjInstance(value, MfString) = false)
		{
			value := new MfString(value)
		}
		this._newStrIntIntInt(value, 0, value.Length, capacity)
	}
	_newIntInt(capacity, maxCapacity) {
		capacity := MfInteger.GetValue(capacity)
		maxCapacity := MfInteger.GetValue(maxCapacity)
		if (capacity > maxCapacity)
		{
			ex := new MfArgumentOutOfRangeException("capacity", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Capacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (maxCapacity < 1)
		{
			ex := new ArgumentOutOfRangeException("maxCapacity", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_SmallMaxCapacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (capacity < 0)
		{
			ex := new MfArgumentOutOfRangeException("capacity", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_MustBePositive","capacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (capacity = 0)
		{
			capacity := MfMath.Min(MfStringBuilder.DefaultCapacity, maxCapacity)
		}
		this.m_MaxCapacity := maxCapacity
		this.m_ChunkChars := new MfMemoryString(capacity,,this.m_Encoding)
	}
	
	_newStrIntIntInt(value, startIndex, length, capacity) {
		startIndex := MfInteger.GetValue(startIndex)
		length := MfInteger.GetValue(length)
		capacity := MfInteger.GetValue(capacity)
		if (capacity < 0)
		{
			ex := new MfArgumentOutOfRangeException("capacity", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_MustBePositive","capacity"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length < 0)
		{
			ex := new MfArgumentOutOfRangeException("Length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_MustBeNonNegNum","length"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ms := MfMemoryString.FromAny(value, this.m_Encoding)
		
		if (startIndex > ms.Length - length)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_MaxCapacity := 2147483647
		BytesPerChar := MfStringBuilder.m_BytesPerChar
		if (capacity <= 0)
		{
			capacity :=  MfStringBuilder.DefaultCapacity
		}
		if (capacity < length)
		{
			capacity := length
		}
		
		this.m_ChunkChars := new MfMemoryString(capacity,,this.m_Encoding)
		if (length < ms.Length || startIndex > 0)
		{
			this.m_ChunkChars.Append(ms.Substring(startIndex, length))
		}
		else
		{
			this.m_ChunkChars.Append(ms)
		}
		this.m_ChunkLength := length
		ms := ""

	}
	_newSB(from) {
		this.m_ChunkLength := from.m_ChunkLength
		this.m_ChunkOffset := from.m_ChunkOffset
		this.m_ChunkChars := from.m_ChunkChars
		this.m_ChunkPrevious := from.m_ChunkPrevious
		this.m_MaxCapacity := from.m_MaxCapacity
		this.m_HasNullChar := from.m_HasNullChar
	}
	_newIntIntSb(size, maxCapacity, previousBlock="") {
		size := MfInteger.GetValue(size)
		maxCapacity := MfInteger.GetValue(maxCapacity)
		this.m_ChunkChars := ""
		this.m_ChunkChars := new MfMemoryString(size,,this.m_Encoding)
		this.m_MaxCapacity := maxCapacity
		this.m_ChunkPrevious := previousBlock
		if (MfNull.IsNull(previousBlock) = false)
		{
			this.m_ChunkOffset := previousBlock.m_ChunkOffset + previousBlock.m_ChunkLength
			this.m_HasNullChar := previousBlock.m_HasNullChar
		}
	}
; 	End:Constructor Helpers ;}
; 	End:Internal Methods ;}
}