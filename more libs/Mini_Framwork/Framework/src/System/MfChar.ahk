;{ License
/* This file is part of Mini-Framework For AutoHotkey.
 * 
 * Mini-Framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 2 of the License.
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

;{ MfChar Class;
/*!
	Class: MfChar
		Represents a character as a UTF-16 code unit.
	Inherits: MfPrimitive
*/
class MfChar extends MfPrimitive
{
;{ Internal members	
	
	m_ignoreCase := true
; End:Internal members ;}	
;{ Static members
	
	static m_categoryForLatin1 := ""
;{ categoryForLatin1
	/*!
		Property: categoryForLatin1 [get]
			Gets the categoryForLatin1 value associated with MfChar
		Value:
			Var representing the categoryForLatin1 property of MfChar
		Remarks:
			Readonly Property
	*/
	categoryForLatin1[index]
	{
		get {
			if (MfChar.m_categoryForLatin1 = "")
			{
				MfChar.m_categoryForLatin1 := MfChar._GetByteArray()
			}
			return MfChar.m_categoryForLatin1[index]
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "categoryForLatin1")
			Throw ex
		}
	}
; End:categoryForLatin1 ;}

;{ 	MaxValue								= 0xFFFF
	static m_MaxValue := 0xFFFF ; 65535
	/*!
		Property: MaxValue [get]
			Represents the largest possible value of an MfChar. This field is constant.
		Remarks:
			Value = 65535
			MfChar class supports chars from 0 to 65535
	*/
	MaxValue[]
	{
		get {
			return MfChar.m_MaxValue
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MaxValue ;}
;{ 	MinValue								= 0
	static m_MinValue := 0
	/*!
		Property: MinValue [get]
			Represents the smallest possible value of an MfChar. This field is constant.
		Remarks:
			Can be accessed using MfChar.MinValue
			Value = 0
			MfChar class supports chars from 0 to 65535
	*/
	MinValue[]
	{
		get {
			return MfChar.m_MinValue
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MinValue ;}
;{	TypeCode								= 14
	; type code unique to this class
	static m_TypeCode := 14
	TypeCode[]
	{
		get {
			return MfChar.m_TypeCode
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; End:TypeCode ;}
;{	Friend Const UNICODE_PLANE00_END		= 65535
	static m_UNICODE_PLANE00_END		:= 65535
	UNICODE_PLANE00_END[]
	{
		get {
			return MfChar.m_UNICODE_PLANE00_END
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Friend Const UNICODE_PLANE00_END ;}
;{	Friend Const UNICODE_PLANE01_START		= 65536
	static m_UNICODE_PLANE01_START := 65536
	UNICODE_PLANE01_START[]
	{
		get {
			return MfChar.m_UNICODE_PLANE01_START
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Friend Const UNICODE_PLANE01_START ;}
;{  Friend const UNICODE_PLANE16_END		= 1114111
	Static m_UNICODE_PLANE16_END := 1114111
	UNICODE_PLANE16_END[]
	{
		get {
			return MfChar.m_UNICODE_PLANE16_END
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Friend const UNICODE_PLANE16_END ;}
;{ 	Friend Const HIGH_SURROGATE_START		= 55296
	static m_HIGH_SURROGATE_START := 55296
	HIGH_SURROGATE_START[]
	{
		get {
			return MfChar.m_HIGH_SURROGATE_START
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Friend Const HIGH_SURROGATE_START ;}
;{ 	Friend Const LOW_SURROGATE_END			= 57343
	static m_LOW_SURROGATE_END := 57343
	LOW_SURROGATE_END[]
	{
		get {
			return MfChar.m_LOW_SURROGATE_END
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Friend Const LOW_SURROGATE_END ;}
; End:Static members ;}	
;{ Constructor
/*
	Constructor()
		Creates a new instance of MfChar Class
	
	OutputVar := new MfChar([c, returnAsObj, readonly])
	
	Constructor([c, retunAsObj, readonly])
		Initializes a new instance of the MfChar class optionally setting the Value property and the ReturnAsObject property and the Readonly property.
	Parameters
		c
			The object to get the char from. Can be instance of MfInteger, MfChar, or MfString. Can be integer var, string var.
		returnAsObj
			Determines if the current instance of MfChar class will return MfChar instances from functions or vars containing char. If omitted value is false
		readonly
			Determines if the current instance of MfChar class will allow its Value or CharCode to be altered after it is constructed.
			The Readonly propery will reflect this value after the classe is constructed.
			If omitted value is false
	Remarks
		Sealed Class.
		This constructor initializes the MfChar with the char value of c.
		Value property to the value of c.
		ReturnAsObject will have a value of returnAsObj
		If Readonly is true then any attempt to change the underlying value will result in MfNotSupportedException being thrown.
		Variadic Method; This method is Variadic so you may construct an instance of MfParams containing any of the overload method
		parameters listed above and pass in the MfParams instance to the method instead of using the overloads described above.
		See MfParams for more information.
	Throws
		Throws MfNotSupportedException if Class in extended.
		Throws MfArgumentException if there is an error getting the value of c
		Throws MfNotSupportedException if incorrect type of parameters or incorrect number of parameters.
*/
	__New(args*) {
		; c = "", returnAsObj = false, readonly = false
		; Throws MfNotSupportedException if MfChar Sealed class is extended
		; see http://ahkscript.org/docs/Compat.htm#Format
		if (this.__Class != "MfChar") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfChar"))
		}
		val := Null
		_returnAsObject := false
		_readonly := false

		pArgs := this._ConstructorParams(A_ThisFunc, args*)

		pList := pArgs.ToStringList()
		s := Null
		pIndex := 0
		if (pList.Count > 0)
		{
			s := pList.Item[pIndex].Value
			if (s = "MfChar")
			{
				val := pArgs.Item[pIndex].Value
			}
			else if ((s = "MfInteger")
				|| s = "MfString")
			{
				val := MfChar._GetCharValue(pArgs.Item[pIndex])
			}
			else
			{
				tErr := this._ErrorCheckParameter(pIndex, pArgs)
				if (tErr)
				{
					tErr.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					Throw tErr
				}
			}

		}
		if (pList.Count > 1)
		{
			pIndex++
			s := pList.Item[1].Value
			if (s = "MfBool")
			{
				_returnAsObject := pArgs.Item[pIndex].Value
			}
			else
			{
				tErr := this._ErrorCheckParameter(pIndex, pArgs)
				if (tErr)
				{
					tErr.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					Throw tErr
				}
			}
		}

		if (pList.Count > 2)
		{
			pIndex++
			s := pList.Item[pIndex].Value
			if (s = "MfBool")
			{
				_readonly := pArgs.Item[pIndex].Value
			}
			else
			{
				tErr := this._ErrorCheckParameter(pIndex, pArgs)
				if (tErr)
				{
					tErr.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					Throw tErr
				}
			}
		}
		
		Base.__New(val, _returnAsObject, _readonly)
		this.m_isInherited := this.__Class != "MfChar"
		;this.m_CharCode := "0x" . this._Text2Hex(this.m_Value)

		; MfGlobalOptions.CharObeyCaseSense is turned off by default and thus IngnoreCase is true by default
		; no matter the state of A_StringCaseSense
		if ((MfGlobalOptions._HasFlag(MfGlobalOptions.CharObeyCaseSense.Value))
			&& (A_StringCaseSense = "On"))
		{
			this.m_IgnoreCase := false
		}
	}

; End:Constructor ;}
;{ _ConstructorParams
	_ConstructorParams(MethodName, args*) {

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
						if (i > 1) ; all booleans from here
						{
							T := new MfType(arg)
							if (T.IsNumber)
							{
								; convert all mf number object to boolean
								b := new MfBool()
								b.Value := arg.Value > 0
								p.Add(b)
							}
							else
							{
								p.Add(arg)
							}
						}
						Else
						{
							p.Add(arg)
						}
						
					} 
					else
					{
						if (MfNull.IsNull(arg))
						{
							pIndex := p.Add(arg)
						}
						else if (i = 1) ; Char
						{
							try
							{
								c := MfChar._GetCharValue(arg)
								cObj := new MfChar()
								cObj.Value := c
								p.Add(cObj)
							}
							catch e
							{
								ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToChar"), e)
								ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
								throw ex
							}
						}
						else ; all params past 1 are boolean
						{
							pIndex := p.AddBool(arg)
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
; End:_ConstructorParams ;}
;{ Methods
;{  CompareTo(obj)	
/*
	Method: CompareTo()
		Overrides MfObject.CompareTo
	
	OutputVar := instance.CompareTo(obj)
	
	CompareTo(obj)
		Compares this instance to a specified MfChar object.
	Parameters
		obj
			A MfChar object to compare.
	Returns
		Returns A number indicating the position of this instance in the sort order in relation to the value parameter.
		Return obj  Less than zero This instance precedes obj value. Zero This instance has the same position in the sort order as obj.
		Greater than zero This instance follows obj.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfChar.
	Remarks
		Compares this instance to a specified MfChar object and indicates whether this instance precedes, follows,
		or appears in the same position in the sort order as the specified MfChar object.
*/
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!MfObject.IsObjInstance(obj, MfChar)) {
			err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Object_Equals"),"obj")
			err.Source := A_ThisFunc
			throw err
		}
			if (this.m_ignoreCase) {
			if (this.Value = obj.Value) {
				return 0
			}
		}
		return (this.CharCode = obj.CharCode)

	}
; End:CompareTo(c) ;}
;{ 	FromCharCode
	FromCharCode(charCode) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(charCode))
		{
			ex := new MfArgumentNullException("charCode")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		cc := MfInteger.GetValue(charCode)
		c := new MfChar(,true)
		c.CharCode := cc
		return c
	}
; 	End:FromCharCode ;}
;{ 	GetHashCode
	/*!
/*!
	Method:GetHashCode()
		Overrides MfObject.GetHashCode()
	
	OutputVar := instance.GetHashCode()
	
	GetHashCode()
		Gets A hash code for the current MfChar.
	Returns
		Returns A hash code for the current MfChar.
	Remarks
		A hash code is a numeric value that is used to insert and identify an object in a hash-based collection such as a Hash table.
		The GetHashCode() method provides this hash code for hashing algorithms and data structures such as a hash table.
		Two objects that are equal return hash codes that are equal. However, the reverse is not true: equal hash codes do not
		imply object equality, because different (unequal) objects can have identical hash codes. Furthermore, the this Framework
		does not guarantee the default implementation of the GetHashCode() method, and the value this method returns may differ between
		Framework versions such as 32-bit and 64-bit platforms. For these reasons, do not use the default implementation of this method
		as a unique object identifier for hashing purposes.
	Throws
		Throws MfNullReferenceException if called as a static method.
	Caution
		A hash code is intended for efficient insertion and lookup in collections that are based on a hash table.
		A hash code is not a permanent value. For this reason:
		* Do not serialize hash code values or store them in databases. 
		* Do not use the hash code as the key to retrieve an object from a keyed collection. 
		* Do not test for equality of hash codes to determine whether two objects are equal.
		  (Unequal objects can have identical hash codes.) To test for equality, call the MfObject.ReferenceEquals()
		  or MfObject.Equals() method. 
*/
	GetHashCode() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		var := MfInteger.GetValue(this.CharCode)
		chrVar := var | (var << 16)
		return chrVar
	}
; 	End:GetHashCode ;}
;{ 	GetNumericValue - Static
/*
	Method: GetNumericValue()
	
	OutputVar := MfChar.GetNumericValue(c)
	OutputVar := MfChar.GetNumericValue(s, index)
	
	GetNumericValue(c)
		Converts the specified numeric Unicode character to a decimal number for c.
	
	GetNumericValue(s, index)
		Converts the specified numeric Unicode character to a decimal number for the character in string s at the location of Zero-based index.
		Index can be instance of MfInteger or var containing integer.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
			Eg:"0x0061". containing hex value such as "0x00B2" (SUPERSCRIPT TWO) or MfInteger instance.
		s
			The String containing the Unicode character for which to get the numeric value.
			Can be MfString instance or String var.
			Can be instance of MfString, or var containing string.
		index
			The index of the Unicode character for which to get the numeric value. Can be MfInteger Instance or Integer var.
	Returns
		Returns the numeric value associated with the specified character.-or- -1, if the specified character is not a numeric character.
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfNotSupportedException of incorrect overload.
		Throws MfArgumentOutOfRangeException is outside the range of valid indexes in s.
		Throws MfArgumentException if c, s or index are object but not of the expected type.
	Remarks
		Static Method.
		The c parameter must be the Char representation of a numeric value. For example, if c is "5", the return value is 5. However, if c is "z", the return value is -1.0.
		A character has an associated numeric value if and only if it is a member of one of the following UnicodeCategory categories:
		DecimalDigitNumber, LetterNumber, or OtherNumber.

		The method assumes that c corresponds to a single linguistic character and checks whether that character can be converted to a decimal digit.
		However, some numbers in the Unicode standard are represented by two Char objects that form a surrogate pair.
		For example, the Aegean numbering system consists of code points U+10107 through U+10133.
*/
	 GetNumericValue(args*) {
	 	this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		try {
			return MfCharUnicodeInfo.GetNumericValue(args*)
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:GetNumericValue ;}
;{ 	GetTypeCode()
/*
	Method: GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfChar Type Code.
	Returns
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfChar.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.Char
	}
; End:GetTypeCode() ;}
;{ 	GetUnicodeCategory - Static
/*
	Method: GetUnicodeCategory(c)
		Categorizes a specified Unicode character into a group identified by one of the MfUnicodeCategory values for c.
	Parameters:
		c
			The Unicode character instance of MfChar to categorize.
			Can be a var containing character or MfChar instance.
	Returns:
		A MfUnicodeCategory value as instance of MfEnum.EnumItem that identifies the group.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfNotSupportedException if Overloads can not match Parameters.
	Remarks:
		Static Method

	Method: GetUnicodeCategory(s, index)
		Categorizes a specified Unicode character into a group identified by one of the MfUnicodeCategory values for the character
		in string s at the location of Zero-based index.
	Parameters:
		s
			The String containing the Unicode character for which to get the Unicode category.
			Can be MfString instance or var.
		index
			An integer that contains the zero-based index position of the character to categorize in s.
			Can be any type that matches IsInteger or var integer.
	Returns:
		A MfUnicodeCategory value as instance of MfEnum.EnumItem that identifies the group.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfNotSupportedException if Overloads can not match Parameters.
		Throws MfArgumentOutOfRangeException if argument index is out of range
	Remarks:
		Static Method
*/
	GetUnicodeCategory(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		try
		{
			return MfCharUnicodeInfo.GetUnicodeCategory(args*)
		}
		catch err
		{
			if (MfObject.IsObjInstance(err, MfNotSupportedException))
			{
				err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw err
			}
			throw err
		}
	}
; End:GetUnicodeCategory() ;}	
;{ 	GetValue - Static
/*
	Method: GetValue()
		Overrides MfPrimitive.GetValue()
	
	OutputVar := MfChar.GetValue(c)
	OutputVar := MfChar.GetValue(s, index)
	
	MfChar.GetValue(c)
		Gets the string value from MfChar instance or MfString instance or var containing a string.
		If string has more then one character then the first character is returned.
	
	MfChar.GetValue(s, index)
		Gets the string value from MfString instance or var containing a string at the location of Zero-based index.
	
	Parameters
		c
			The Unicode character to evaluate. The Can be a var containing character or MfChar instance or
			MfString instance or var containing string or string var containing hex value Eg:"0x0061".
		s
			The String containing the Unicode character for which to get the Unicode category. Can be MfString instance or String var.
			Can be instance of MfString, or var containing string.
		index
			An integer that contains the zero-based index position of the character to categorize in s. Can be MfInteger Instance or var containing Integer.
	Returns
		Returns a var containing a string or MfString.Empty if not value is found.
	Remarks
		Static Method
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentException if argument if any parameter is an Object but is not derived from MfObject or a valid instance of MfChar class.
*/
	GetValue(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := ""
		ch := MfChar._GetCharFromInput(args*)
		if (MfNull.IsNull(ch) = true) {
			return Null
		}
		retval := ch.Value
		return retval
	}
; 	End:GetValue() ;}
;{	IsControl Static
/*
	Method: IsControl()
	
	OutputVar := MfChar.IsControl(c)
	OutputVar := MfChar.IsControl(s, index)
	
	MfChar.IsControl(c)
		Indicates whether the specified Unicode character is categorized as a control character for c.
	Returns
		Returns true if c is control character; Otherwise, false.
	
	MfChar.IsControl(s, index)
		Indicates whether the specified Unicode character is categorized as a control character from MfString instance or
		var containing a string at the location of Zero-based index.
	Returns
		Returns true if the character at position index in s is control character; Otherwise, false.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
			Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
	Remarks
		Static method.
		Control characters are formatting and other non-printing characters, such as ACK, BEL, CR, FF, LF, and VT. T The Unicode standard
		assigns code points from U+0000 to U+001F, U+007F, and from U+0080 to U+009F to control characters. According to the Unicode standard,
		these values are to be interpreted as control characters unless their use is otherwise defined by an application.
		Valid control characters are members of the MfUnicodeCategory.Control category.
	Throws
		Throws MfInvalidOperationException if not called as a static method.
*/
	IsControl(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		try {
			c := MfChar._GetCharFromInput(args*)
			if (MfChar.IsLatin1(c))
			{
				Cat := MfChar.GetLatin1UnicodeCategory(c)
				retval := (cat.Value = MfUnicodeCategory.Instance.Control.Value)
			} else {
				Cat := MfCharUnicodeInfo.GetUnicodeCategory(c)
				retval := (cat.Value = MfUnicodeCategory.Instance.Control.Value)
			}
			
		} catch e {
			throw e
		}
		return retval
	}
;	End:IsControl ;}	
;{	IsDigit - Static
/*
	Method: IsDigit()
	
	OutputVar := MfChar.IsDigit(c)
	OutputVar := MfChar.IsDigit(s, index)
	
	MfChar.IsDigit(c)
		Indicates whether the specified character of c is categorized as a decimal digit.
	Returns
		Returns true if c is a decimal digit; Otherwise, false.
	
	MfChar.IsDigit(s, index)
		Indicates whether the specified character is categorized as a decimal digit for the character at position index in s.
	Returns
		Returns true if the character at position index in s is a decimal digit; Otherwise, false.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
			Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Method.
		This method determines whether a MfChar is a radix-10 digit. This contrasts with IsNumber, which determines whether
		a Char is of any numeric Unicode category.

		Numbers include characters such as fractions, subscripts, superscripts, Roman numerals, currency numerators,
		encircled numbers, and script-specific digits.
*/
	IsDigit(args*) { ;MfChar or String, MfInteger
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		c := MfChar._GetCharFromInput(args*)
		if (MfChar.IsLatin1(c) = true) {
			cVal := c.CharCode + 0
			;~ cVal .= "" ; necessary for integer fast
			if ((cVal >= 48) && (cVal <= 57)) {
				return true
			}
			return false
		} else {
			Cat := MfCharUnicodeInfo.GetUnicodeCategory(c)
			return cat.Equals(MfUnicodeCategory.Instance.DecimalDigitNumber)
		}
	}
; End:IsDigit() ;}
;{ 	IsHighSurrogate - static
/*
	Method: IsHighSurrogate()
	
	OutputVar := MfChar.IsHighSurrogate(c)
	OutputVar := MfChar.IsHighSurrogate(s, index)
	
	MfChar.IsHighSurrogate(c)
		Indicates whether the specified character of c is a high surrogate.
	Returns
		Returns true if c is high surrogate; Otherwise, false.
	
	MfChar.IsHighSurrogate(s, index)
		Indicates whether the specified character  is a high surrogate that ranges from U+D800 through U+DBFF for the character at position index in s.
	Returns
		Returns true if the character at position index in s is high surrogate that ranges from U+D800 through U+DBFF; Otherwise, false.
	Parameters
		c
		The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value Eg:"0x0061". c corresponds
		to a single linguistic Unicode character.
		s
		A string. Can be a string var or MfString instance.
		index
		The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Method.
		In addition to representing single characters using a 16-bit code point, UTF-16 encoding allows abstract characters to be represented using two
		16-bit code points, which is known as a surrogate pair. The first element in this pair is the high surrogate. Its code point can range from U+D800 to U+DBFF.
		An individual surrogate has no interpretation of its own; it is meaningful only when used as part of a surrogate pair.
	*/
	IsHighSurrogate(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		try {
			c := MfChar._GetCharFromInput(args*)
			cHex := c.CharCode
			retval := ((cHex >= 0xD800) && (cHex <= 0xDBFF))
		} catch e {
			throw e
		}
		return retval
	}
; 	End:IsHighSurrogate ;}
;{ 	IsLetter - static
/*
	Method: IsLetter()
	
	OutputVar := MfChar.IsLetter(c)
	OutputVar := MfChar.IsLetter(s, index)
	
	MfChar.IsLetter(c)
		Indicates whether the specified character of c is categorized as a Unicode letter.
	Returns
		Returns true if c is a Unicode letter; Otherwise, false.
	
	MfChar.IsLetter(s, index)
		Indicates whether the specified character is categorized as a Unicode letter for the character at position index in s.
	Returns
		Returns true if the character at position index in s is a Unicode letter; Otherwise, false.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
			Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Method.
		This method determines whether a Char is a member of any category of Unicode letter. Unicode letters include the following:
		Uppercase letters, such as U+0041 (LATIN CAPITAL LETTER A) through U+005A (LATIN CAPITAL LETTER Z),
		or U+0400 (CYRILLIC CAPITAL LETTER IE WITH GRAVE) through U+042F (CYRILLIC CAPITAL LETTER YA).
		These characters are members of the MfUnicodeCategory.UppercaseLetter category. 

		Lowercase letters, such as U+0061 (LATIN SMALL LETTER A) through U+007A (LATIN SMALL LETTER Z),
		or U+03AC (GREEK SMALL LETTER ALPHA WITH TONOS) through U+03CE (GREEK SMALL LETTER OMEGA WITH TONOS).
		These characters are members of the MfUnicodeCategory.LowercaseLetter category. 

		Title case letters, such as U+01C5 (LATIN CAPITAL LETTER D WITH SMALL LETTER Z WITH CARON) or U+1FFC (GREEK CAPITAL LETTER OMEGA WITH PROSGEGRAMMENI).
		These characters are members of the MfUnicodeCategory.TitlecaseLetter category. 

		Modifiers, such as U+02B0 (MODIFIER LETTER SMALL H) through U+02C1 (MODIFIER LETTER REVERSED GLOTTAL STOP), or
		U+1D2C (MODIFIER LETTER CAPITAL A) through U+1D61 (MODIFIER LETTER SMALL CHI). These characters are members of the MfUnicodeCategory.ModifierLetter category. 
		Other letters, such as U+05D0 (HEBREW LETTER ALEF) through U+05EA (HEBREW LETTER TAV), U+0621 (ARABIC LETTER HAMZA) through
		U+063A (ARABIC LETTER GHAIN), or U+4E00 (<CJK Ideograph, First>) through U+9FC3 (<CJK Ideograph, Last>).
		These characters are members of the MfUnicodeCategory.OtherLetter category. 
*/
	IsLetter(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		c := MfChar._GetCharFromInput(args*)
			
		if (!MfChar.IsLatin1(c)) {
			return MfChar.CheckLetter(MfCharUnicodeInfo.GetUnicodeCategory(c))
		} else if (MfChar.IsAscii(c)) {
			cc := c.Charcode
			return ((cc >= 65) && (cc <= 122))
		} else {
			return MfChar.CheckLetter(MfChar.GetLatin1UnicodeCategory(c))
		}
	}
; 	End:IsLetter ;}
;{ 	IsLetterOrDigit - static
/*
	Method: IsLetterOrDigit()
	
	OutputVar := MfChar.IsLetterOrDigit(c)
	OutputVar := MfChar.IsLetterOrDigit(s, index)
	
	MfChar.IsLetterOrDigit(c)
		Indicates whether the specified character of c is categorized as a letter or a decimal digit.
	Returns
		Returns true if c is a letter or a decimal digit; Otherwise, false.
	
	MfChar.IsLetterOrDigit(s, index)
		Indicates whether the specified character is categorized as a letter or a decimal digit for the character at position index in s.
	Returns
		Returns true if the character at position index in s is a letter or a decimal digit; Otherwise, false.
	
	Parameters 
		c
		The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
		Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
		A string. Can be a string var or MfString instance.
		index
		The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Method.
		Valid letters and decimal digits are members of the following categories in MfUnicodeCategory: UppercaseLetter, LowercaseLetter,
		TitlecaseLetter, ModifierLetter, OtherLetter, or DecimalDigitNumber.
*/
	IsLetterOrDigit(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		c := MfChar._GetCharFromInput(args*)
		If (MfChar.IsLatin1(c))
		{
			return MfChar.CheckLetterOrDigit(MfChar.GetLatin1UnicodeCategory(c))
		}
		else
		{
			return MfChar.CheckLetterOrDigit(MfCharUnicodeInfo.GetUnicodeCategory(c))
		}
	}
; 	End:IsLetterOrDigit ;}
;{ 	IsLower - static
/*
	Method: IsLower()
	
	OutputVar := MfChar.IsLower(c)
	OutputVar := MfChar.IsLower(s, index)
	
	MfChar.IsLower(c)
		Indicates whether the specified character of c is categorized as a lowercase letter.
	Returns
		Returns true if c is  a lowercase letter; Otherwise, false.
	
	MfChar.IsLower(s, index)
		Indicates whether the specified character is categorized as a lowercase letter for the character at position index in s.
	Returns
		Returns true if the character at position index in s is a lowercase letter; Otherwise, false.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
			Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Method.
		Valid lowercase letters are members of the following category in MfUnicodeCategory: LowercaseLetter.
	
*/
	IsLower(args*) {
		; Could use (MfChar.GetUnicodeCategory(c).Value = MfUnicodeCategory.Instance.LowercaseLetter.Value)
		; but using GetUnicodeCategory makes a call to the database which is a much longer round trip to get the info
		;
		; many characters are not categorized as lower or upper case. Only characters that have a corresponding case would have
		; this a lower or upper category.
		; charactores that are not categorized as lower or upper have the same value when converter to upper or lower
		; A faster way to check to is convert the char to upper and compare case insensitive operator ==
		; if char value is == char value converted to upper then it can not be lower.
		; Next test if char value == char lower then return the compare result
		; For example:
		; 	0x2764 ❤ heavy black heart, Lower 0x2764 upper 0x2764, IsLower for this char will always be false because
		;	it does not have the a lower or upper case category
		;
		;	Ox0561 "ա", Upper 0x0531 "Ա" IsLower("ա") reports true because it in in the catagory of Lower case
		retval := false
		c := MfChar._GetCharFromInput(args*)
		if (MfChar.IsLatin1(c))
		{
			return ((c.CharCode >= 0x0061) && (c.CharCode <= 0x007A))
		}
		else
		{
			val := c.Value
			cUpper := Mfunc.StringUpper(val)
			
			if (cUpper == val)
			{
				return false
			}
			cLower := Mfunc.StringLower(val)
			return cLower == val
		}
	}
; 	End:IsLower ;}
;{ 	IsLowSurrogate - static
/*
	Method: IsLowSurrogate()
	
	OutputVar := MfChar.IsLowSurrogate(c)
	OutputVar := MfChar.IsLowSurrogate(s, index)
	
	MfChar.IsLowSurrogate(c)
		Indicates whether the specified character of c is a low surrogate.
	Returns
		Returns true if c is a low surrogate that ranges from U+DC00 through U+DFFF; Otherwise, false.
	
	MfChar.IsLowSurrogate(s, index)
		Indicates whether the specified character is a low surrogate for the character at position index in s.
	Returns
		Returns true if the character at position index in s is a low surrogate that ranges from U+DC00 through U+DFFF; Otherwise, false.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
			Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
	Static Method.
	In addition to representing single characters using a 16-bit code point, UTF-16 encoding allows abstract characters to be represented
	using two 16-bit code points, which is known as a surrogate pair.

	The second element in this pair is the low surrogate.
	Its code point can range from U+DC00 to U+DFFF.
	An individual surrogate has no interpretation of its own; it is meaningful only when used as part of a surrogate pair.
*/
	IsLowSurrogate(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		c := MfChar._GetCharFromInput(args*)
		cHex := c.CharCode
		retval := ((cHex >= 0xDC00) && (cHex <= 0xDFFF))
		return retval
	}
; 	End:IsLowSurrogate ;}
;{ 	IsNumber - static
/*
	Method: IsNumber()
	
	OutputVar := MfChar.IsNumber(c)
	OutputVar := MfChar.IsNumber(s, index)
	
	MfChar.IsNumber(c)
		Indicates whether the specified character of c is categorized as a Unicode number.
	Returns
		Returns true if c is a Unicode number; Otherwise, false.
	
	MfChar.IsNumber(s, index)
		Indicates whether the specified character is categorized as a Unicode number for the character at position index in s.
	Returns
		Returns true if the character at position index in s is a Unicode number; Otherwise, false.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value Eg:"0x0061".
		c corresponds to a single linguistic character and checks whether that character represents a number.
		However, some numbers in the Unicode standard are represented by two Char objects that form a surrogate pair.
		For example, the Aegean numbering system consists of code points U+10107 through U+10133
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Method.
		This method determines whether a Char is of any numeric Unicode category.
		In addition to including digits, numbers include characters, fractions, subscripts, superscripts, Roman numerals, currency numerators, and encircled numbers.
		This method contrasts with the IsDigit method, which determines whether a Char is a radix-10 digit.
		Valid numbers are members of the MfUnicodeCategory.DecimalDigitNumber ,MfUnicodeCategory.LetterNumber, or MfUnicodeCategory.OtherNumber category.
*/
	IsNumber(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		c := MfChar._GetCharFromInput(args*)
		if (!MfChar.IsLatin1(c)) {
			retval := MfChar.CheckNumber(MfCharUnicodeInfo.GetUnicodeCategory(c))
		} else if (MfChar.IsAscii(c)) {
			retval := ((c.CharCode >= 0x0030) && (c.CharCode <= 0x0039))
		} else {
			retval := MfChar.CheckNumber(MfChar.GetLatin1UnicodeCategory(c))
		}
		return retval
	}
; 	End:IsNumber ;}
;{ 	IsPunctuation - static
/*!
	Method: IsPunctuation()
	
	OutputVar := MfChar.IsPunctuation(c)
	OutputVar := MfChar.IsPunctuation(s, index)
	
	MfChar.IsPunctuation(c)
		Indicates whether the specified character of c is categorized as a punctuation mark.
	
	Returns
		Returns true if c is a punctuation mark; Otherwise, false.
	
	MfChar.IsPunctuation(s, index)
		Indicates whether the specified character is categorized as a punctuation mark for the character at position index in s.
	Returns
		Returns true if the character at position index in s is a punctuation mark; Otherwise, false.
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
			Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Method.
		Valid punctuation marks are members of the following categories in MfUnicodeCategory: ConnectorPunctuation, DashPunctuation,
		OpenPunctuation, ClosePunctuation, InititalQuotePunctuation, FinalQuotePunctuation, or OtherPunctuation.
*/
	IsPunctuation(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		c := MfChar._GetCharFromInput(args*)
		if (MfChar.IsLatin1(c)) {
			retval := MfChar.CheckPunctuation(MfChar.GetLatin1UnicodeCategory(c))
		} else {
			retval := MfChar.CheckPunctuation(MfCharUnicodeInfo.GetUnicodeCategory(c))
		}
		return retval
	}
; 	End:IsPunctuation ;}
;{ 	IsSeparator - static
/*
	Method: IsSeparator()
	
	OutputVar := MfChar.IsSeparator(c)
	OutputVar := MfChar.IsSeparator(s, index)
	
	MfChar.IsSeparator(c)
		Indicates whether the specified character of c is categorized as a separator character.
	Returns
		Returns true if c is a separator character; Otherwise, false.
	
	MfChar.IsSeparator(s, index)
		Indicates whether the specified character is categorized as a separator character for the character at position index in s.
	Returns
		Returns true if the character at position index in s is a separator character; Otherwise, false.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
			Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Method.
		Valid separator characters are members of the following categories in MfUnicodeCategory: SpaceSeparator, LineSeparator, ParagraphSeparator.
*/
	IsSeparator(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		c := MfChar._GetCharFromInput(args*)
		if (MfChar.IsLatin1(c)) {
			retval := MfChar._IsSeparatorLatin1(c)
		} else {
			retval := MfChar.CheckSeparator(MfCharUnicodeInfo.GetUnicodeCategory(c))
		}
		return retval
	}
; 	End:IsSeparator ;}
;{	IsSurrogate - Static
/*
	Method: IsSurrogate()
	
	OutputVar := MfChar.IsSurrogate(c)
	OutputVar := MfChar.IsSurrogate(s, index)
	
	MfChar.IsSurrogate(c)
		Indicates whether the specified character of c has a surrogate code unit.
	Returns
		Returns true if c is either a high surrogate or a low surrogate; Otherwise, false.
	
	MfChar.IsSurrogate(s, index)
	Indicates whether the specified character has a surrogate code unit for the character at position index in s.
	Returns
		Returns true if the character at position index in s is either a high surrogate or a low surrogate; Otherwise, false.
	Parameters
		c
		The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
		Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
		A string. Can be a string var or MfString instance.
		index
		The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Method.
*/
	IsSurrogate(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		c := MfChar._GetCharFromInput(args*)
		retval := MfChar._IsSurrogateC(c)
		return retval
	}
;	End:IsSurrogate() ;}
;{	IsSurrogatePair - Static
/*
	Method: IsSurrogatePair()
	
	OutputVar := MfChar.IsSurrogatePair(highSurrogate, lowSurrogate)
	OutputVar := MfChar.IsSurrogatePair(s, index)
	
	MfChar.IsSurrogatePair(highSurrogate, lowSurrogate)
		Indicates whether the two specified MfChar objects form a surrogate pair.
	Returns
		Returns true if the CharCode value of the highSurrogate parameter ranges from 0xD800 through 0xDBFF, and the CharCode value of the lowSurrogate parameter ranges from 0xDC00 through 0xDFFF; Otherwise, false.
	
	MfChar.IsSurrogatePair(s, index)
		Indicates whether two adjacent characters in a string at a specified position form a surrogate pair.
	Returns
		Returns true if the s parameter includes adjacent characters at positions index and index + 1, and the numeric value of the character at position index ranges from 0xD800 through 0xDBFF, and the numeric value of the character at position index + 1 ranges from 0xDC00 through 0xDFFF; Otherwise false.
	
	Parameters
		highSurrogate
			The character instance of MfChar to evaluate as the high surrogate of a surrogate pair.
		lowSurrogate
			The character instance of MfChar to evaluate as the low surrogate of a surrogate pair.
		s
			A instance of MfString or a var containing string.
		index
			An instance of MfInteger or var containing integer that contains the starting position of the pair of characters to evaluate within s.
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		IsSurrogatePair(s, index) throws MfArgumentNullException if parameter s or index is null.
		IsSurrogatePair(s, index) throws MfArgumentOutOfRangeException if index is less than zero or greater than the last position in s.
		Throws MfNotSupportedException if Overloads can not match Parameters.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Function.
*/
	IsSurrogatePair(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		try
		{
			if (MfObject.IsObjInstance(args[1],MfParams)) {
				objParams := args[1] ; arg 1 is a MfParams object so we will use it
			} else {
				objParams := new MfParams()
				for index, arg in args
				{
					objParams.Add(arg)
				}
			}
			if (objParams.Count != 2) {
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"))
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw e
			}
			retval := false
			strParms := objParams.ToString()
			if (strParms = "MfChar,MfChar") {
				retval := MfChar._IsSurrogatePairCC(objParams.Item[0], objParams.Item[1])
			} else if (strParms = "MfString,MfInteger") {
				retval := MfChar._IsSurrogatePairSI(objParams.Item[0], objParams.Item[1], A_ThisFunc)
			} else if (strParms = "MfString,MfString") {
				; assume string string is string, index
				mfi := new MfInteger(objParams.Item[1].Value)
				retval := MfChar._IsSurrogatePairSI(objParams.Item[0], mfi, A_ThisFunc)
			} else {
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"))
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw e
			}
			return retval
		}
		catch err
		{
			if (MfObject.IsObjInstance(err, MfNotSupportedException))
				throw err

			if (MfObject.IsObjInstance(err, MfArgumentNullException))
				throw err
				
			if (MfObject.IsObjInstance(err, MfArgumentOutOfRangeException))
				throw err

			ex := new MfException(err.Message, err)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
			
	}
;	End:IsSurrogatePair() ;}
;{ 	IsSymbol
/*
	Methdo: IsSymbol()
	
	OutputVar := MfChar.IsSymbol(c)
	OutputVar := MfChar.IsSymbol(s, index)
	
	MfChar.IsSymbol(c)
		Indicates whether the specified character of c is categorized as a symbol character.
	Returns
		Returns true if c is a symbol character; Otherwise, false.
	
	MfChar.IsSymbol(s, index)
		Indicates whether the specified character is categorized as a symbol character for the character at position index in s.
	Returns
		Returns true if the character at position index in s is a symbol character; Otherwise, false.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
			Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Method.
		Valid symbol characters are members of the following categories in MfUnicodeCategory: MathSymbol,
		CurrencySymbol, ModifierSymbol and ClosePunctuation.
*/
	IsSymbol(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		c := MfChar._GetCharFromInput(args*)
		if (MfChar.IsLatin1(c)) {
			retval := MfChar.CheckSymbol(MfChar.GetLatin1UnicodeCategory(c))
		} else {
			retval := MfChar.CheckSymbol(MfCharUnicodeInfo.GetUnicodeCategory(c))
		}
		return retval
	}
; 	End:IsSymbol ;}
;{ 	IsUpper
/*
	Method: IsUpper()
	
	OutputVar := MfChar.IsUpper(c)
	OutputVar := MfChar.IsUpper(s, index)
	
	MfChar.IsUpper(c)
		Indicates whether the specified character of c is categorized as a uppercase letter.
	Returns
		Returns true if c is  a uppercase letter; Otherwise, false.
	
	MfChar.IsUpper(s, index)
		Indicates whether the specified character is categorized as a uppercase letter for the character at position index in s.
	Returns
		Returns true if the character at position index in s is a uppercase letter; Otherwise, false.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value Eg:"0x0061".
			c corresponds to a single linguistic Unicode character.
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Method.
		Valid uppercase letters are members of the following category in MfUnicodeCategory: UppercaseLetter.
	*/
	IsUpper(args*) {
		; Could use (MfChar.GetUnicodeCategory(c).Value = MfUnicodeCategory.Instance.UppercaseLetter.Value)
		; but using GetUnicodeCategory makes a call to the database which is a much longer round trip to get the info
		;
		; many characters are not categorized as lower or upper case. Only characters that have a corresponding case would have
		; this a lower or upper category.
		; charactores that are not categorized as lower or upper have the same value when converter to upper or lower
		; A faster way to check to is convert the char to lower and compare case insensitive operator ==
		; if char value is == char value converted to lower then it can not be upper.
		; Next test if char value == char upper then return the compare result
		; For example:
		; 	0x2764 ❤ heavy black heart, Lower 0x2764 upper 0x2764, IsUpper for this char will always be false because
		;	it does not have the a lower or upper case category
		;
		;	Ox0561 "ա", Upper 0x0531 "Ա" IsUpper("Ա") reports true because it in in the catagory of Upper case
		retval := false
		c := MfChar._GetCharFromInput(args*)
		if (MfChar.IsLatin1(c))
		{
			return ((c.CharCode >= 0x0041) && (c.CharCode <= 0x005A))
		}
		else
		{
			val := c.Value
			cLower := Mfunc.StringLower(val)
			
			if (cLower == val)
			{
				return false
			}
			cUpper := Mfunc.StringUpper(val)
			return cUpper == val
		}
	}
; 	End:IsUpper ;}
;{	IsWhiteSpace - static
/*
	Method: IsUpper()
	
	OutputVar := MfChar.IsUpper(c)
	OutputVar := MfChar.IsUpper(s, index)
	
	MfChar.IsUpper(c)
		Indicates whether the specified character of c is categorized as a uppercase letter.
	Returns
		Returns true if c is  a uppercase letter; Otherwise, false.
	
	MfChar.IsUpper(s, index)
		Indicates whether the specified character is categorized as a uppercase letter for the character at position index in s.
	Returns
		Returns true if the character at position index in s is a uppercase letter; Otherwise, false.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
			Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Throws
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfInvalidOperationException if not called as a static method.
	Remarks
		Static Method.
		Valid uppercase letters are members of the following category in MfUnicodeCategory: UppercaseLetter.	
*/
	IsWhiteSpace(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		retval := MfCharUnicodeInfo._IsWhiteSpace(args*)
		return retval
	}
; End:IsWhiteSpace() ;}
;{ 	Parse - Static
/*
	Method: Parse()
	
	OutputVar := MfChar.Parse()
	
	MfChar.Parse(s)
		Converts the value of the specified string to its equivalent Unicode character.
	Parameters
		s
			A string that contains a single character or a  hex value such as "0x0061".
			Can be a  MfString instance or var containing string..
	Returns
		Returns a Unicode character equivalent to the sole character in s as an instance of MfChar.
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
	Remarks
		Static Method.
*/
	Parse(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := null
		try {
			c := MfChar._GetCharFromInput(args*)
			retval := c
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; End:Parse ;}
;{ 	ToLower - static
/*
	Method: ToLower()
		Converts the value of a Unicode character to its lowercase equivalent
	
	OutputVar := MfChar.ToLower(c)
	OutputVar := MfChar.ToLower(s, index)
	
	ToLower(c)
		Returns the lowercase equivalent of c, or the unchanged value of c, if c is already lowercase or not alphabetic.
	
	ToLower(s, index)
		Returns the lowercase equivalent of the character at position index in s or the unchanged value of character at position
		index if character is already lowercase or not alphabetic.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
			Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Remarks
		Static Method.
		If ReturnAsObject is true for parameter c then an instance of MfChar representing the lowercase char is returned;
		Otherwise a string var is returned containing the lowercase value.
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfException on any general errors.
*/
	ToLower(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := Null
		c := MfChar._GetCharFromInput(args*)
		try {
			if (MfChar.IsLower(c)) {
				if (c.ReturnAsObject = true) {
					retval := c
				} else {
					retval := c.Value
				}
			} else {
				cLVal := Mfunc.StringLower(c.Value)
				if (c.ReturnAsObject = true) {
					retval := new MfChar(cLVal, true)
				} else {
					retval := cLVal
				}
			}
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; 	End:ToLower ;}
;{ 	ToUpper - static
/*
	Method: ToUpper()
		Converts the value of a Unicode character to its uppercase equivalent
	
	OutputVar := MfChar.ToUpper(c)
	OutputVar := MfChar.ToUpper(s,index)
	
	MfChar.ToUpper(c)
		Returns the uppercase equivalent of c, or the unchanged value of c, if c is already uppercase or not alphabetic.
	
	MfChar.ToUpper(s, index)
		Returns the uppercase equivalent of the character at position index in s or the unchanged value of character at position
		index if character is already uppercase or not alphabetic.
	
	Parameters
		c
			The character to evaluate. Can be a var containing character or MfChar instance or string var containing hex value
			Eg:"0x0061". c corresponds to a single linguistic Unicode character.
		s
			A string. Can be a string var or MfString instance.
		index
			The zero-based index position of the character to evaluate in s. Can be a Integer var or MfInteger instance.
	Remarks
		Static Method.
		If ReturnAsObject is true for parameter c then an instance of MfChar representing the uppercase char is returned;
		Otherwise a string var is returned containing the uppercase value.
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentOutOfRangeException if index is not in the valid range of s.
		Throws MfNotSupportedException if call to method is outside its overloads.
		Throws MfException on any general errors.
*/
	ToUpper(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := Null
		c := Null
		try {
			c := MfChar._GetCharFromInput(args*)
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try {
			if (MfChar.IsUpper(c)) {
				if (c.ReturnAsObject = true) {
					retval := c
				} else {
					retval := c.Value
				}
			} else {
				cUVal := Mfunc.StringUpper(c.Value)
				if (c.ReturnAsObject = true) {
					retval := new MfChar(cUVal, true)
				} else {
					retval := cUVal
				}
			}
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; 	End:ToUpper ;}
;{ 	ToString()
/*
	Method: ToString()
		Overrides MfPrimitive.ToString()

	OutputVar := instance.ToString()

	ToString()
		Gets a string representation of the MfChar instance.
	Returns
		Returns string var representing current instance. Returns true or false depending on state of instance
	Throws
		Throws MfNullReferenceException if called as a static method.
*/
	ToString() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return this.Value . ""
	}
;  End:ToString() ;}
;{ 	TryParse
/*
	Method: TryParse()
	
	OutputVar := MfChar.TryParse(result, s)
	
	MfChar.TryParse(byref result, s)
		Converts the value of the specified string to its equivalent Unicode character. A return code indicates whether the conversion succeeded or failed.
	Parameters
		result
			When this method returns, contains a Unicode character equivalent to the sole character in s,
			if the conversion succeeded, or an undefined value if the conversion failed.
			The conversion fails if the s parameter is null or the length of s is not 1. This parameter is passed uninitialized.
		s
			A string that contains a single character. Can be instance of MfString or string var.
	Returns
		Returns true if the s parameter was converted successfully; Otherwise false.
	Remarks
		The TryParse method is like the Parse method, except the TryParse method does not throw an exception if the conversion fails.
	Throws
		Throws MfInvalidOperationException if not called as a static method.
*/
	TryParse(ByRef result, s) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		result := New MfChar("0x0000")
		if (MfNull.IsNull(s)) {
			return false
		}
		if (IsObject(s)) {
			if (!MfObject.IsObjInstance(s, "MfString")) {
				return false
			} else {
				if (s.length != 1) {
					return false
				}
				result := new MfChar(s.Value)
			}
		} else {
			sObj := new MfString(s)
			if (sObj.Length != 1) {
				return false
			} else {
				result := new MfChar(sObj.Value)
			}
		}
		return true
	}
; 	End:TryParse ;}
;{ 	Equals(c)	
/*
	Method: Equals()
		Overrides MfPrimitive.Equals
	
	OutputVar := instance.Equals(obj)
	
	Equals(obj)
		Gets if this instance is the same as the obj instance
	Parameters
		obj
			The instance of MfChar to compare
	Returns
		Returns Boolean value of true if the objects are the same; Otherwise false.
	Remarks
		This instance of MfChar and the obj instance must be the same object for true to be returned.
	Throws
		Throws MfNullReferenceException if called as a static method
*/
	Equals(obj)	{
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfObject.IsObjInstance(obj, "MfChar")) {
			if (this.m_ignoreCase = true) {
				return this.Value = obj.Value
			}
			return this.CharCode = obj.CharCode
		}
		return false
	}
; End:Equals(c) ;}	
; End:Methods ;}
;{ Internal Methods
;{	check methods	
	CheckLetter(uc)	{
		; uc value is MfUnicodeCategory EnumItem
		; UppercaseLetter or LowercaseLetter or TitlecaseLetter
		; or ModifierLetter or OtherLetter
		val := MfInteger.GetValue(uc)
		if ((val => 0) && (val <= 4))
		{
			return true
		}
		else
		{
			return false
		}
	}
	CheckLetterOrDigit(uc) {
		; uc value is MfUnicodeCategory EnumItem
		; UppercaseLetter or LowercaseLetter or TitlecaseLetter
		; or ModifierLetter or OtherLetter or DecimalDigitNumber
		val := MfInteger.GetValue(uc)
		if ((val => 0) && (val <= 4) || val = 8)
		{
			return true
		}
		else
		{
			return false
		}
	}
	CheckNumber(uc) {
		val := MfInteger.GetValue(uc)
		; uc value is MfUnicodeCategory EnumItem
		; DecimalDigitNumber or LetterNumber or OtherNumber
		val := MfInteger.GetValue(uc)
		if ((val => 8) && (val <= 10))
		{
			return true
		}
		else
		{
			return false
		}
	}
	CheckPunctuation(uc) {
		; uc value is MfUnicodeCategory EnumItem
		; ConnectorPunctuation or DashPunctuation or OpenPunctuation
		; or ClosePunctuation or InitialQuotePunctuation or FinalQuotePunctuation
		; or OtherPunctuation
		val := MfInteger.GetValue(uc)
		if ((val => 18) && (val <= 24))
		{
			return true
		}
		else
		{
			return false
		}
	}
	CheckSeparator(uc) {
		; uc value is MfUnicodeCategory EnumItem
		; SpaceSeparator or LineSeparator or ParagraphSeparator
		val := MfInteger.GetValue(uc)
		if ((val => 11) && (val <= 13))
		{
			return true
		}
		else
		{
			return false
		}
	}
	CheckSymbol(uc)	{
		; uc value is MfUnicodeCategory EnumItem
		; MathSymbol or CurrencySymbol or ModifierSymbol or OtherSymbol
		val := MfInteger.GetValue(uc)
		if ((val => 25) && (val <= 28))
		{
			return true
		}
		else
		{
			return false
		}
	}
; End:check methods ;}	
;{ 	_GetCharFromInput
	_GetCharFromInput(args*) {
		if (MfObject.IsObjInstance(args[1], MfParams)) {
			objParams := args[1] ; arg 1 is a MfParams object so we will use it
		} else {
			objParams := new MfParams()
			for index, arg in args
			{
				objParams.Add(arg)
			}
		}
		if ((objParams.Count < 1) || (objParams.Count > 2)) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		WasFormat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, "D")
		retval := Null
		try {
			strP := objParams.ToString()
		
			if (strP = "MfChar") {
				retval := objParams.Item[0]
			} else if (strP = "MfString") {
				strV := objParams.Item[0].Value
				; check for hex values in string
				if (RegExMatch(strV, "i)^0x[0-9A-F]{4}$")) {
					retval := new MfChar(New MfInteger(strV))
				} else {
					retval := new MfChar(strV)
				}
			} else if (strP = "MfString,MfInteger") {
				str := objParams.Item[0]
				wasReturn := str.ReturnAsObject
				str.ReturnAsObject := true
				index := objParams.Item[1].Value
				
				if ((index < 0) || (index >= str.Length))
				{
					str.ReturnAsObject := wasReturn
					ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				retval := str.Index[index]
				str.ReturnAsObject := wasReturn
			} else if (strP = "MfString,MfString") {
				; MfString,MfString should be var passed as non objects. Assuming string and integer
				sObj := objParams.Item[0]
				wasReturn := str.ReturnAsObject
				sObj.ReturnAsObject := true
				iObj := MfInteger.Parse(objParams.Item[1].Value)
				index := iObj.Value
				
				if ((index < 0) || (index >= sObj.Length))
				{
					str.ReturnAsObject := wasReturn
					ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				retval := sObj.Index[iObj]
				str.ReturnAsObject := wasReturn
			} else {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} catch e {
			throw e
		} finally {
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, WasFormat)
		}
		return retval
	}
; 	End:_GetCharFromInput ;}
;{ 	_GetCharValue
/*
	Method: _GetCharValue(c)
		_GetCharValue() Get the value of c as a string representing a char
	Parameters:
		c - The object to get the char from. Can be instance of MfInteger, MfChar, or MfString.
			Can be integer var, string var.
	Remarks:
		Static Method  
		[MfInteger](MfInteger.html) objects are treated as Char numbers so _GEtCharValue(New MfInteger(5)) results
		in the char '|'. To get the char value of an integer _GEtCharValue(5) results in 5
		Pass it in as a MfInteger instance
	Returns:
		Returns a string var representing a char
*/
	_GetCharValue(c) {
		val := Null
		if (MfNull.IsNull(c)) {
			return chr(0)
		}
		;WasFormat := A_FormatInteger
		try
		{
			if (IsObject(c))
			{
				cType := new MfType(c)
				if (cType.IsIntegerNumber)
				{
					;Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, "H")
					_rValue := c.Value
					
					if ((_rValue >= 0x0000) && (_rValue <= 0xFFFF)) {
						;SetFormat, Integer, H
						val := Chr(c.Value)
					} else {
						ex := new MfException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_CharCode"))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
				}
				else if (cType.IsChar)
				{
					val := c.Value
				}
				else if (cType.IsString)
				{
					mStr := MfMemoryString.FromAny(c.Length,,, ObjGetAddress(c, "m_value"))
					if (mStr.Length = 0)
					{
						Return chr(0)
					}
					val := mStr.Charcode[0]
					mStr := ""
				}
				else
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Error", "c"), "c")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			else
			{
				str := new MfString(c, false)
				if (str.Length <= 0)
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_CharCode"), "c")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				else if ((str.Length = 6) && (str.Value ~= "i)^0x[0-9A-F]{4}$"))
				{
					; hex value convert to char	
					;SetFormat, IntegerFast, H
					iChar := MfInteger.GetValue(str.Value) + 0
					if ((iChar < MfChar.MinValue) || (iChar > MfChar.MaxValue))
					{
						ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Range"
						, MfChar.MinValue, MfChar.MaxValue), "c")
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					val := Chr(iChar)
				}
				else if (str.Length = 1)
				{
					val := str.Value
				}
				else
				{
					val := str.Index[0]
				}
			}
		}
		catch e
		{
			; if the exception was created in this function the just throw it
			; otherwise create a new one
			if (MfObject.IsObjInstance(e, MfException) && (e.Source = A_ThisFunc))
			{
				Throw e
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		finally
		{
			;Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, WasFormat)
		}
		
		return val
	}
; 	End:_GetCharValue ;}
;{	GetByteArray()
	_GetByteArray() {
		cArray := Object()
		loop, 32 ; Cc 0 to 31
		{
			cArray.Push(14)
		}
		cArray.Push(11) ; Zs 32
		loop, 3 ; 33-34
		{
			cArray.Push(24)
		}
		cArray.Push(26) ; Sc 36
		loop, 3 ; Po 37-39
		{
			cArray.Push(24)
		}
		; 40 - 47
		cArray.Push(20,21,24,25)
		cArray.Push(24,19,24,24)
		loop, 10 ; Nd 48 - 57
		{
			cArray.Push(8)
		}
		cArray.Push(24,24) ; Po 58, 59
		loop, 3 ; Sm 60 - 62
		{
			cArray.Push(25)
		}
		cArray.Push(24,24) ; Po 63 - 64
		loop, 26 ; Lu 65 - 90
		{
			cArray.Push(0)
		}
		cArray.Push(20,24,21,27,18,27) ; 91 - 96
		loop, 26 ; 97 - 122
		{
			cArray.Push(1)
		}
		cArray.Push(20,25,21,25) ; 123 - 126
		loop, 33 ; 127 - 159
		{
			cArray.Push(14)
		}
		cArray.Push(11,24) ; 161, 162
		loop, 4
		{
			cArray.Push(26)
		}
		cArray.Push(28,28,27,28,1,22,25,19,28,27,28,25,10,10,27,1,28,24,27,10,1,23)
		loop, 3
		{
			cArray.Push(10)
		}
		cArray.Push(24)
		loop, 23
		{
			cArray.Push(0)
		}
		cArray.Push(25)
		loop, 7
		{
			cArray.Push(0)
		}
		loop, 24
		{
			cArray.Push(1)
		}
		cArray.Push(25)
		loop, 8
		{
			cArray.Push(1)
		}
		return cArray
	}
; End:_GetByteArray ;}	
;{	GetLatin1UnicodeCategory()
	;private static MfUnicodeCategory GetLatin1UnicodeCategory(MfChar ch)
	; returns MfEnum.EnumItem
	GetLatin1UnicodeCategory(c)	{
		;wasformat := A_FormatInteger
		;SetFormat, Integer, D
		index := 0
		try {
			if (MfObject.IsObjInstance(c, MfChar)) {
				index := c.CharCode + 0
				
			} else if (!IsObject(c)) {
				ch := new MfChar(c)
				index := ch.CharCode
			} else {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType","c","MfChar"),"c")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			i := MfChar.categoryForLatin1[index + 1] ; returns an integer var
			;retvar := new MfUnicodeCategory(i)
			; MfEnum.ParseItem will parse integer first before attempting to search by name and return MfEnum.EnumItem
			return MfEnum.ParseItem(MfUnicodeCategory.GetType(), i)

		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; End:GetLatin1UnicodeCategory() ;}
;{ 	IsAscii()
	IsAscii(c) {
		;f := A_FormatInteger
		;SetFormat, IntegerFast, D
		try {
			if (MfObject.IsObjInstance(c, MfChar)) {
				return c.CharCode <= 127
			}
			if (!IsObject(c)) {
				ch := new MfChar(c)
				return ch.CharCode <= 127
			}
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		} finally {
			;SetFormat, IntegerFast, %f%
		}
	}
; 	End:IsAscii() ;}
;{ 	isCharInstance()
	_isCharInstance(ByRef c) {
		return MfObject.IsObjInstance(c, MfChar)
	}
; End:_isCharInstance(ByRef c) ;}
;{	IsLatin1()
	IsLatin1(c)	{
		;WasFormat := A_FormatInteger
		;SetFormat, IntegerFast, D
		retval := false
		if (MfObject.IsObjInstance(c,MfChar)) {
			retval := c.CharCode <= 255
		} else if (!IsObject(c)) {
			ch := new MfChar(c)
			retval := ch.CharCode <= 255
		} else {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType","c","MfChar"),"c")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
;	End:IsLatin1() ;}
;{ 	_IsSeparatorLatin1 - static
	; Gets is c is a Latin1 Seperator
	; c - instance of MfChar
	_IsSeparatorLatin1(c) {
		return MfChar._IsSeparatorCharNumLatin1(c.CharCode)
	}
	
; 	End:_IsSeparatorLatin1 ;}
;{ 	_IsSeparatorCharNumLatin1 - static
	; Gets is cNum is a Latin1 Seperator
	; cNum - integer number of char
	_IsSeparatorCharNumLatin1(cNum) {
		retval := ((cNum = 32 ) || (cNum = 160))
		return retval
	}
; 	End:_IsSeparatorCharNumLatin1 ;}
;{ 	IsSurrogate - static
;{ 	_IsSurrogateSI
	; gets if char at index of s is Surrogate
	; s can be MfString instance or string var
	; index can be MfInteger or var integer
	; Source string Var or object that is throw in errors. Defatult to current Method Name
	_IsSurrogateSI(s, index, Source:="") {
	
		if (MfNull.IsNull(index))
		{
			if (Source == "")
			{
				Source := A_ThisFunc
			}
			ex := new MfArgumentNullException("index")
			ex.SetProp(A_LineFile, A_LineNumber, Source)
			throw ex
		}
		_s := MfString.GetValue(s)
		_index := MfInteger.GetValue(index)
		slen := StrLen(_s)
		if (slen = 0)
		{
			ex := new MfArgumentNullException("s")
			ex.SetProp(A_LineFile, A_LineNumber, methodName)
			throw ex
		}
		if ((_index < 0) || (_index >= sLen))
		{
			if (Source == "")
			{
				Source := A_ThisFunc
			}
			ex := new MfArgumentOutOfRangeException("index")
			ex.SetProp(A_LineFile, A_LineNumber, Source)
			throw ex
		}
		mStr := new MfMemoryString(slen,,,&_s)
		c := mStr.CharCode[_index]
		mStr := ""
		return MfChar._IsSurrogateCharCode(c)
	}
; 	End:_IsSurrogateSI ;}
;{ 	_IsSurrogateC
	_IsSurrogateC(c) {
		return MfChar._IsSurrogateCharCode(c.CharCode)
	}
; 	End:_IsSurrogateC ;}
;{ 	_IsSurrogateCharCode
	_IsSurrogateCharCode(cNum) {
		retval :=  ((cNum >= 0xd800) && (cNum <= 0xdfff))
		return retval
	}
; 	End:_IsSurrogateCharCode ;}
; 	End:IsSurrogate() ;}
;{	IsSurrogatePair - Static
;{ 	_IsSurrogatePairCC
	; static method
	; highSurrogate - MfChar instance
	; lowSurrogate - MfChar instance
	_IsSurrogatePairCC(highSurrogate, lowSurrogate) {
		hc := highSurrogate.CharCode
		lc := lowSurrogate.CharCode
		return MfChar._IsSurrogatePairByteHiLoNums(hc,lc)
	}
; 	End:_IsSurrogatePairCC ;}
;{ 	_IsSurrogatePairByteHiLoNums
	; Static Method
	; highSurrogate - integer Number Byte value High
	; lowSurrogate - integer Number Byte value Low
	_IsSurrogatePairByteHiLoNums(highSurrogate, lowSurrogate) {
		
		hc := highSurrogate + 0x0
		lc := lowSurrogate + 0x0
		retval :=  ((hc >= 0xd800) && (hc <= 0xDBFF)) && ((lc >= 0xDC00) && (lc <= 0xDFFF))
		return retval
	}
; 	End:_IsSurrogatePairByteHiLoNums ;}
	_IsSurrogatePairSI(s, index, Source:="") {
		if(!A_IsUnicode)
		{
			return false
		}
		if (MfNull.IsNull(index))
		{
			if (Source == "")
			{
				Source := A_ThisFunc
			}
			ex := new MfArgumentNullException("index")
			ex.SetProp(A_LineFile, A_LineNumber, Source)
			throw ex
		}
		_s := MfString.GetValue(s)
		_index := MfInteger.GetValue(index)
		slen := StrLen(_s)
		
		if ((_index < 0) || (_index >= sLen))
		{
			if (Source == "")
			{
				Source := A_ThisFunc
			}
			ex := new MfArgumentOutOfRangeException("index")
			ex.SetProp(A_LineFile, A_LineNumber, Source)
			throw ex
		}
		mStr := new MfMemoryString(slen,,,&_s)
		if (mStr.Length < 0)
		{
			ex := new MfArgumentNullException("s")
			ex.SetProp(A_LineFile, A_LineNumber, methodName)
			throw ex
		}
		len := _index + 1 ; add 1 to offset zero based
		if (mStr.Length < len)
		{
			ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_OffsetOut"))
			ex.SetProp(A_LineFile, A_LineNumber, methodName)
			throw ex
		}
		
		try
		{
			_index := _index * 2 ; 2 bytes per char for unicode 16
			b1 := mStr.Byte[_index]
			b2 := mStr.Byte[_index + 1]
			retval := MfChar._IsSurrogatePairByteHiLoNums(b1, b2)
			return retval
		} catch e {
			if (Source == "")
			{
				Source := A_ThisFunc
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, Source)
			throw ex
		}
		
	}
;	End:IsSurrogatePair ;}
;{	IsCharObj(obj) - Static
	IsCharObj(obj) {
		return MfObject.IsObjInstance(obj, MfChar)
	}
; End:IsCharObj(obj) ;}
;{ 	StrPutVar - Static
	; http://l.autohotkey.net/docs/commands/StrPutGet.htm
	_StrPutVar(String, ByRef Var, encoding) {
		VarSetCapacity(Var, StrPut(String, encoding) * ((encoding="UTF-16"||encoding="CP1200") ? 2 : 1))
		Return StrPut(String, &var, encoding)
	}
; 	End:StrPutVar ;}
;{ 	Text2Hex
	_Text2Hex(String) {
		VarSetCapacity(Hex, len*(A_IsUnicode ? 2:1))
		len := MfChar._StrPutVar(String, Var, "UTF-16")
		pointer := &var
		f := Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, "H")
		Hex := ""
		Loop % len*2
		{		
			Hex := SubStr(0x100 + NumGet(pointer + A_Index - 0x1, 0x0, "uchar"), -0x1) . Hex
		}
		Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, f)
		Return Hex
	}
; 	End:Text2Hex ;}
;{ 	Hex2Text
	_Hex2Text(Hex) {
		f := Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, "D")
		startpos:=1
		n := ""
		Loop % StrLen(Hex)/2
		{
			strHex := "0x" . SubStr(Hex, StartPos , 2) . SubStr(Hex, StartPos + 2 , 2)
			if (strHex = "0x") {
				break
			}
			n .= chr(strHex)
			startpos +=4
		}
		Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, f)
		Return n
	}
; 	End:Hex2Text ;}
; Sealed Class Following methods cannot be overriden ; Do Not document for this class
; VerifyIsInstance([ClassName, LineFile, LineNumber, Source])
; VerifyIsNotInstance([MethodName, LineFile, LineNumber, Source])
; Sealed Class Following methods cannot be overriden
; VerifyReadOnly()
;{ MfObject Attribute Overrides - methods not used from MfObject - Do Not document for this class
;{	AddAttribute()
/*
	Method: AddAttribute()
	AddAttribute(attrib)
		Overrides MfObject.AddAttribute Sealed Class will never have attribute
	Parameters:
		attrib
			The object instance derived from MfAttribute to add.
	Throws:
		Throws MfNotSupportedException
*/
	AddAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex		
	}
;	End:AddAttribute() ;}
;{	GetAttribute()
/*
	Method: GetAttribute()

	OutputVar := instance.GetAttribute(index)

	GetAttribute(index)
		Overrides MfObject.GetAttribute Sealed Class will never have attribute
	Parameters:
		index
			the zero-based index. Can be MfInteger or var containing Integer number.
	Throws:
		Throws MfNotSupportedException
*/
	GetAttribute(index) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:GetAttribute() ;}
;	GetAttributes ;}
/*
	Method: GetAttributes()

	OutputVar := instance.GetAttributes()

	GetAttributes()
		Overrides MfObject.GetAttributes Sealed Class will never have attribute
	Throws:
		Throws MfNotSupportedException
*/
	GetAttributes()	{
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:GetAttributes ;}
;{	GetIndexOfAttribute()
/*
	GetIndexOfAttribute(attrib)
		Overrides MfObject.GetIndexOfAttribute. Sealed Class will never have attribute
	Parameters:
		attrib
			The object instance derived from MfAttribute.
	Throws:
		Throws MfNotSupportedException
*/
	GetIndexOfAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:GetIndexOfAttribute() ;}
;{	HasAttribute()
/*
	HasAttribute(attrib)
		Overrides MfObject.HasAttribute. Sealed Class will never have attribute
	Parameters:
		attrib
			The object instance derived from MfAttribute.
	Throws:
		Throws MfNotSupportedException
*/
	HasAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:HasAttribute() ;}
; End:MfObject Attribute Overrides ;}
; End:Internal Methods ;}
;{ Properties
;{	CharCode
	m_CharCodeSet := false
	/*!
		Property: CharCode [get/set]
			Gets or sets the CharCode associated with the this instance of [MfChar](MfChar.html)
		Value:
			Sets the value of the [MfChar](MfChar.html) instance
		Example: @file:md\MfCharCharCodeExample.scriptlet
	*/
	CharCode[]
	{
		get {
			if (this.m_CharCodeSet = false)
			{
				this.m_CharCodeSet := true
				;this.m_CharCode := "0x" . this._Text2Hex(this.m_Value)
				this.m_CharCode := Ord(this.m_Value)
			}
			return this.m_CharCode
		}
		set {
			this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
			_val := MfInteger.GetValue(value)
			if ((_val < MfChar.MinValue) || (_val > MfChar.MaxValue)) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_CharCode"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.m_Value := Chr(_val)
			;this.m_CharCode := "0x" . this._Text2Hex(this.m_Value)
			this.m_CharCode := _val
			this.m_CharCodeSet := true
			return this.m_CharCode
		}
	}
;	End:CharCode ;}
;{	IgnoreCase
/*
		Property: IgnoreCase [get/set]
			Gets or sets if the MfChar instance should Ignorecase or not.  
		Value:
			Sets the value of the derived MfEnum class
		Remarks:
			IgnoreCase is not affected by the state of ReturnAsObject and 
			always returns a var containing a boolean.
*/
	IgnoreCase[]
	{
		get {
			return this.m_IgnoreCase
		}
		set {
			_val := Null
			try
			{
				_val := MfBool.GetValue(value)
				this.m_IgnoreCase := _val
			} catch e {
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBoolean"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			return this.m_IgnoreCase
		}
	}
;	End:IgnoreCase ;}
;{	Value
	/*!
		Property: Value [get/set]
			Gets or sets the value associated with the this instance of [MfChar](MfChar.html)
		Value:
			The return value is always a single Unicode character. To set the value many formats may be used. See example below.
		Example: @file:md\MfCharValueExample.scriptlet
	*/
	Value[]
	{
		get {
			return Base.Value
		}
		set {
			this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
			try {
				_val := MfChar._GetCharValue(value) ; can be hex, integer, MfChar instance, String var
				base.Value := _val
			} catch e {
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_PropertySet", A_ThisFunc), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			retval := base.Value
			;this.m_CharCode := "0x" . this._Text2Hex(retval)
			this.m_CharCodeSet := false
			return retval
		}
	}
;	End:Value ;}


; End:Properties;}
	__Delete() {
		;MfUnicodeCategory.DestroyInstance()
		; release MfUnicodeCategory memory in case we are finished with it.
	}
}
/*!
	End of class
*/
; End:MfChar Class ;}

