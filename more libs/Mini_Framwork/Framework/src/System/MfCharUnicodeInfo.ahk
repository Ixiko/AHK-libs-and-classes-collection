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
/*
Unicode Character Category
http://www.fileformat.info/info/unicode/category/index.htm
*/
/*!
	Class: MfCharUnicodeInfo 
		(Inherits from MfObject)
		Retrieves information about a Unicode character. This class cannot be inherited.
		All methods are static.
	Throws
		ThrowsMfNotSupportedException if instance is created.
	Members
		GetDecimalDigitValue() Method 
		GetDigitValue() Method 
		GetNumericValue() Method 
	Remarks
		The Unicode Standard defines a number of Unicode character categories. For example, a character might be categorized as an uppercase letter,
		a lowercase letter, a decimal digit number, a letter number, a paragraph separator, a math symbol, or a currency symbol.
		Your application can use the character category to govern string-based operations, such as parsing.
		The UnicodeCategory enumeration defines the possible character categories.
		You use the MfCharUnicodeInfo class to obtain the UnicodeCategory value for a specific character.
		The CharUnicodeInfo class defines methods that return the following Unicode character values:
		Numeric value. Applies only to numeric characters, including fractions, subscripts, superscripts, Roman numerals, currency numerators,
		encircled numbers, and script-specific digits. 
		Digit value. Applies to numeric characters that can be combined with other numeric characters to represent a whole number in a numbering system. 
		Decimal digit value. Applies only to characters that represent decimal digits in the decimal (base 10) system.
		A decimal digit can be one of ten digits, from zero through nine. These characters are members of the MfUnicodeCategory.DecimalDigitNumber category. 
		When using this class in your applications, keep in mind the following programming considerations for using the MfChar type.
		The type can be difficult to use, and strings are generally preferable for representing linguistic content.
		A MfChar object does not always correspond to a single character. Although the MfChar type represents a single 16-bit value,
		some characters (such as grapheme clusters and surrogate pairs) consist of two or more UTF-16 code units. 
		The notion of a "character" is also flexible. A character is often thought of as a glyph, but many glyphs require multiple code points.
		For example, ä can be represented either by two code points ("a" plus U+0308, which is the combining diaeresis),
		or by a single code point ("ä" or U+00A4). Some languages have many letters, characters, and glyphs that require multiple code points,
		which can cause confusion in linguistic content representation. For example, there is a ΰ (U+03B0, Greek small letter upsilon with dialytika and tonos),
		but there is no equivalent capital letter. Uppercasing such a value simply retrieves the original value. 
*/
class MfCharUnicodeInfo extends MfObject
{
	/*!
		Constructor: ()
			Initializes a new instance of the MfCharUnicodeInfo class.
		Remarks:
			It is not necessary to construct new instance of MfCharUnicodeInfo class
			as MfCharUnicodeInfo class contains static properties only
		Throws:
			Throws MfNotSupportedException if class instance is created
	*/
	__New() {
		throw new MfNotSupportedException(MfString.Format(MfEnvironment.Instance.GetResourceString("NotSupportedException_Static_Class"), "MfCharUnicodeInfo"))
	}
;{ 	BIDI_CATEGORY_OFFSET		= 1
	static m_BIDI_CATEGORY_OFFSET		:= 1
	BIDI_CATEGORY_OFFSET[]
	{
		get {
			return MfCharUnicodeInfo.m_BIDI_CATEGORY_OFFSET
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:BIDI_CATEGORY_OFFSET ;}
;{ 	HIGH_SURROGATE_END		= 0xdbff
	static m_HIGH_SURROGATE_END		:= 0xdbff
	HIGH_SURROGATE_END[]
	{
		get {
			return MfCharUnicodeInfo.m_HIGH_SURROGATE_END
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:HIGH_SURROGATE_END ;}
;{ 	HIGH_SURROGATE_START	= 0xd800
	static m_HIGH_SURROGATE_START		:= 0xd800
	HIGH_SURROGATE_START[]
	{
		get {
			return MfCharUnicodeInfo.m_HIGH_SURROGATE_START
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:HIGH_SURROGATE_START ;}
;{ 	LOW_SURROGATE_END		= 0xdfff
	static m_LOW_SURROGATE_END		:= 0xdfff
	LOW_SURROGATE_END[]
	{
		get {
			return MfCharUnicodeInfo.m_LOW_SURROGATE_END
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:LOW_SURROGATE_END ;}
;{ 	LOW_SURROGATE_START		= 0xdc00
	static m_LOW_SURROGATE_START		:= 0xdc00
	LOW_SURROGATE_START[]
	{
		get {
			return MfCharUnicodeInfo.m_LOW_SURROGATE_START
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:LOW_SURROGATE_START ;}
;{ 	UNICODE_CATEGORY_OFFSET	= 0
	static m_UNICODE_CATEGORY_OFFSET		:= 0
	UNICODE_CATEGORY_OFFSET[]
	{
		get {
			return MfCharUnicodeInfo.m_UNICODE_CATEGORY_OFFSET
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; 	End:UNICODE_CATEGORY_OFFSET ;}
;{ 	UNICODE_PLANE01_START	= 65536
	static m_UNICODE_PLANE01_START		:= 65536
	UNICODE_PLANE01_START[]
	{
		get {
			return MfCharUnicodeInfo.m_UNICODE_PLANE01_START
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:UNICODE_PLANE01_START ;}

;{ 	Methods
;{ 	GetDecimalDigitValue
/*
	Method: GetDecimalDigitValue()
	
	OutputVar := MfCharUnicodeInfo.GetDecimalDigitValue(ch)
	OutputVar := MfCharUnicodeInfo.GetDecimalDigitValue(s, index)
	
	GetDecimalDigitValue(ch)
		Gets the digit value of the specified numeric character.
	
	GetDecimalDigitValue(s, index)
		Gets the digit value of the specified numeric character for the character in string s  at the location of Zero-based index.
	
	Parameters
		ch
			The Unicode character for which to get the digit value. Can be instance of MfChar,
			A single char in a var or a string var containing hex value such as "0x00B2" (SUPERSCRIPT TWO) or MfInteger instance.
		s
			The String containing the Unicode character for which to get the decimal digit value. Can be MfString instance or string var.
		index
			The zero-based index of the Unicode character for which to get the decimal digit value. Can be MfInteger Instance or integer var.
	Returns
		Returns the decimal digit value of the specified numeric character or -1, if the specified character is not a decimal digit.
	Remarks
		Static Method
	Throws
		Throws MfArgumentOutOfRangeException if index is outside the range of valid indexes in s.
		Throws MfArgumentException if ch, s or index are object but not of the expected type.
*/
	GetDecimalDigitValue(args*) {
		
		retval := -1.0
		iChar := ""
		try
		{
			iChar := MfCharUnicodeInfo._GetCharCode(args*)
		}
		catch e
		{
			e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw e
		}
		try {
			
			if (iChar >= 48 && iChar <= 57)
			{
				return iChar - 48
			}
			if (iChar <= 255)
			{
				return -1
			}
			
			retval :=  MfUcd.UCDSqlite.Instance.GetDecimalDigitValue(iChar)
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		return retval
	}
; 	End:GetDecimalDigitValue ;}
;{ 	GetDigitValue
/*
	Method: GetDigitValue()
	
	OutputVar := MfCharUnicodeInfo.GetDigitValue(ch)
	OutputVar := MfCharUnicodeInfo.GetDigitValue(s, index)
	
	GetDigitValue(ch)
		Gets the digit value of the specified numeric character.
	
	GetDigitValue(s, index)
		Gets the digit value of the specified for the numeric character in string s  at the location of Zero-based index.
	
	Parameters
		ch
			The Unicode character for which to get the digit value.
			Can be instance of MfChar, A single char in a var or a string var containing hex value such as "0x00B2" (SUPERSCRIPT TWO) or MfInteger instance.
		s
			The String containing the Unicode character for which to get the decimal digit value. 
			Can be MfString instance or String var.
		index
			The zero-based index of the Unicode character for which to get the decimal digit value.
			Can be MfInteger Instance or Integer var.
	Returns
		Returns the digit value of the specified numeric character.-or- -1, if the specified character is not a digit.
	Throws
		Throws MfArgumentOutOfRangeException is outside the range of valid indexes in s.
		Throws MfArgumentException if ch, s or index are object but not of the expected type.
*/
	GetDigitValue(args*) {
		retval := -1.0
		iChar := ""
		try
		{
			iChar := MfCharUnicodeInfo._GetCharCode(args*)
		}
		catch e
		{
			e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw e
		}
		
		try {
			if (iChar >= 48 && iChar <= 57)
			{
				return iChar - 48
			}
			if (iChar <= 255)
			{
				return -1
			}
			retval := MfUcd.UCDSqlite.Instance.GetDigitValue(iChar)
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		return retval
	}
; 	End:GetDigitValue ;}

;{ 	GetNumericValue
/*
	Method: GetNumericValue()
	
	OutputVar := MfCharUnicodeInfo.GetNumericValue(ch)
	OutputVar := MfCharUnicodeInfo.GetNumericValue(s, index)
	
	GetNumericValue(ch)
		Converts the specified numeric Unicode character to a decimal number.
	
	GetNumericValue(s, index)
		Converts the specified numeric Unicode character to a decimal number for the character in string s at the location of Zero-based index.
	Parameters
		ch
			The Unicode character for which to get the digit value. Can be instance of MfChar, A single char in a var or a
			string var containing hex value such as "0x00B2" (SUPERSCRIPT TWO) or MfInteger instance.
		s
			The String containing the Unicode character for which to get the numeric value. Can be MfString instance or String var.
		index
			The index of the Unicode character for which to get the numeric value. Can be MfInteger Instance or Integer var.
	Returns
		Returns the numeric value associated with the specified character or -1, if the specified character is not a numeric character.
	Throws
		Throws MfNotSupportedException of incorrect overload.
		Throws MfArgumentOutOfRangeException is outside the range of valid indexes in s.
		Throws MfArgumentException if ch, s or index are object but not of the expected type.
	Remarks
		Static Method.
		The ch parameter must be the Char representation of a numeric value. For example, if ch is "5", the return value is 5.
		However, if ch is "z", the return value is -1.0.
		A character has an associated numeric value if and only if it is a member of one of the following UnicodeCategory categories:
		DecimalDigitNumber, LetterNumber, or OtherNumber.
		Method assumes that ch corresponds to a single linguistic character and checks whether that character can be converted to a decimal digit.
		However, some numbers in the Unicode standard are represented by two Char objects that form a surrogate pair. For example,
		the Aegean numbering system consists of code points U+10107 through U+10133.
*/
	GetNumericValue(args*) {
		retval := -1.0
		try
		{
			iChar := MfCharUnicodeInfo._GetCharCode(args*)
		}
		catch e
		{
			e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw e
		}
		
		try {
			if (iChar >= 48 && iChar <= 57)
			{
				return iChar - 48
			}
			if (iChar <= 255)
			{
				return -1
			}
			retval := MfUcd.UCDSqlite.Instance.GetNumericValue(iChar)
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		return retval
	}
; 	End:GetNumericValue ;}
;{ 		_IsWhiteSpace Static method
/*
	Method: _IsWhiteSpace(c) or (s, index)
		_IsWhiteSpace(c) Indicates whether the character is categorized as white space.
		_IsWhiteSpace(s, index) Indicates whether the character at the specified position in a specified string is categorized as white space.
	Parameters:
		s - A [MfString](MfString.html).
		index - The [MfInteger](MfInteger.html) position of the character to evaluate in *s*.
		c - a [MfChar](MfChar.html) to check to see if
	Remarks:
		internal Helper method for IsWhiteSpace()  
		Currently based on know utf-8 whitespace and may need more work to capture other whitespaces
		ToDo: Confirm all Whitespaces are included here.
	Returns:
		Returns true if the character at position *index* in *s* is white space; otherwise, false.
	Throws:
		Throws MfArgumentOutOfRangeException
		Throws MfNotSupportedException
*/
	_IsWhiteSpace(args*) {
		c := MfChar._GetCharFromInput(args*)
		cc := c.CharCode + 0
			
		; from unicode database
		retval := ((cc >= 9 && cc <= 13) || (cc = 32) || (cc = 133) || (cc = 160) || (cc = 5760) || (cc >= 8192 && cc <= 8202)
			|| (cc = 8232) || (cc = 8233) || (cc = 8239) || (cc = 8287) || (cc = 12288))
		return retval
	}
; 		End:IsWhiteSpace ;}

	_InternalConvertToUtf32Cl(s, index, ByRef charLength)
	{
		charLength := 1
		if (index < s.Length - 1 Then) {
			cStart := s.Index[index] ; get MfChar instanance
			iLow := cStart.CharCode - 55296
			if (iLow >= 0 && iLow <= 1023) {
				cEnd := s.Index[index + 1] ; get MfChar instanance
				iHigh := cEnd.CharCode - 56320
				if (iHigh >= 0 && iHigh <= 1023) {
					charLength += 1
					return iLow * 1024 + iHigh + 65536
				}
			}
			return cStart.CharCode
		}
		return -1
	}
	
	_InternalConvertToUtf32(s, index)
	{
		if (index < s.Length - 1 Then) {
			cStart := s.Index[index] ; get MfChar instanance
			iLow := cStart.CharCode - 55296
			if (iLow >= 0 && iLow <= 1023) {
				cEnd := s.Index[index + 1] ; get MfChar instanance
				iHigh := cEnd.CharCode - 56320
				if (iHigh >= 0 && iHigh <= 1023) {
					return iLow * 1024 + iHigh + 65536
				}
			}
			return cStart.CharCode
		}
		return -1
	}
;{ 	GetUnicodeCategory
	; Makes a call to the framework unicode database and get the category for a MfChar Instance
	; Returns an instance of MfEnum.EnumItem
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
		
		if (MfObject.IsObjInstance(args[1],MfParams)) {
			objParams := args[1] ; arg 1 is a MfParams object so we will use it
		} else {
			objParams := new MfParams()
			cnt := MfParams.GetArgCount(args*)
			if (cnt = 1)
			{
				arg := args[1]
				if (MfObject.IsObjInstance(arg, MfChar))
				{
					objParams.Add(arg)
				}
				else
				{
					c := new MfChar(MfString.GetValue(arg))
					objParams.Add(c)
				}
			}
			else if(cnt = 2)
			{
				arg1 := args[1]
				arg2 := args[2]
				objStr := ""
				objInt := ""
				if (MfObject.IsObjInstance(arg1, MfString))
				{
					objStr := arg1
				}
				else
				{
					objStr := new MfString(MfString.GetValue(arg1))
				}
				if (MfObject.IsObjInstance(arg2, MfInteger))
				{
					objInt := arg2
				}
				else
				{
					objInt := new MfInteger(MfInteger.GetValue(arg2))
				}
				objParams.Add(objStr)
				objParams.Add(objInt)

			}
		}
		if ((objParams.Count < 1) || (objParams.Count > 2)) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		strParms := objParams.ToString()
		if (strParms = "MfChar")
		{
			c := objParams.Item[0]
		}
		else if (strParms = "MfString,MfInteger")
		{
			s := objParams.Item[0]
			index := objParams.Item[1]
			c := new MfChar(s.Index[index])
		}
		else
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (MfChar.IsLatin1(c))
		{
			; Much faster then makeing call to database
			return MfChar.GetLatin1UnicodeCategory(c)
		}
		; make call to database to get info.
		try {
			str := MfUcd.UCDSqlite.Instance.GetUnicodeGeneralCategory(c.Charcode)
			if (str = "Lu") {
				return MfUnicodeCategory.Instance.UppercaseLetter
			} else if (str = "Ll") {
				return MfUnicodeCategory.Instance.LowercaseLetter
			} else if (str = "Lt") {
				return MfUnicodeCategory.Instance.TitlecaseLetter
			} else if (str = "Lm") {
				return MfUnicodeCategory.Instance.ModifierLetter
			} else if (str = "Lo") {
				return MfUnicodeCategory.Instance.OtherLetter
			} else if (str = "Mn") {
				return MfUnicodeCategory.Instance.NonSpacingMark
			} else if (str = "Mc") {
				return MfUnicodeCategory.Instance.SpacingCombiningMark
			} else if (str = "Me") {
				return MfUnicodeCategory.Instance.EnclosingMark
			} else if (str = "Nd") {
				return MfUnicodeCategory.Instance.DecimalDigitNumber
			} else if (str = "Nl") {
				return MfUnicodeCategory.Instance.LetterNumber
			} else if (str = "No") {
				return MfUnicodeCategory.Instance.OtherNumber
			} else if (str = "Zs") {
				return MfUnicodeCategory.Instance.SpaceSeparator
			} else if (str = "Zl") {
				return MfUnicodeCategory.Instance.LineSeparator
			} else if (str = "Zp") {
				return MfUnicodeCategory.Instance.ParagraphSeparator
			} else if (str = "Cc") {
				return MfUnicodeCategory.Instance.Control
			} else if (str = "Cf") {
				return MfUnicodeCategory.Instance.Format
			} else if (str = "Cs") {
				return MfUnicodeCategory.Instance.Surrogate
			} else if (str = "Co") {
				return MfUnicodeCategory.Instance.PrivateUse
			} else if (str = "Pc") {
				return MfUnicodeCategory.Instance.ConnectorPunctuation
			} else if (str = "Pd") {
				return MfUnicodeCategory.Instance.DashPunctuation
			} else if (str = "Ps") {
				return MfUnicodeCategory.Instance.OpenPunctuation
			} else if (str = "Pe") {
				return MfUnicodeCategory.Instance.ClosePunctuation
			} else if (str = "Pi") {
				return MfUnicodeCategory.Instance.InitialQuotePunctuation
			} else if (str = "Pf") {
				return MfUnicodeCategory.Instance.FinalQuotePunctuation
			} else if (str = "Po") {
				return MfUnicodeCategory.Instance.OtherPunctuation
			} else if (str = "Sm") {
				return MfUnicodeCategory.Instance.MathSymbol
			} else if (str = "Sc") {
				return MfUnicodeCategory.Instance.CurrencySymbol
			} else if (str = "Sk") {
				return MfUnicodeCategory.Instance.ModifierSymbol
			} else if (str = "So") {
				return MfUnicodeCategory.Instance.OtherSymbol
			}  else {
				return MfUnicodeCategory.Instance.OtherNotAssigned
			}
			
		} catch e {
			ex := new MfException(MfString.Format(MfEnvironment.Instance.GetResourceString("Exception_Error"), A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		} 
	}
; 	End:GetUnicodeCategory ;}
	_GetCharFromString(s, index) {
		s := new MfString(args[1], true) ; create string instance that returns objects

			if (index >= _s.Length)
			{
				ex := new MfArgumentOutOfRangeException("index")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			return _s.Index[args[2]] ; get MfChar instanance
	}
	;{ 	_GetCharCode
	; gets charcode for integer obj or var, char obj or string , string obj or var and index obj or var
	; uses to read constructor params for GetDecimalDigitValue, GetDigitValue and GetNumericValue
	; returns integer that represents the char code
	; Static Private method
	_GetCharCode(args*) {
		if (MfObject.IsObjInstance(args[1],MfParams))
		{
			objParams := args[1] ; arg 1 is a MfParams object so we will use it
		}
		else
		{
			objParams := new MfParams()
			for index, arg in args
			{
				objParams.Add(arg)
			}
		}
		if ((objParams.Count < 1) || (objParams.Count > 2))
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try
		{
			iChar := 0
			strParms := objParams.ToString()
			if (strParms = "MfChar")
			{
				return objParams.Item[0].CharCode
			}
			else if (strParms = "MfString")
			{
				strV := objParams.Item[0].Value
				if (RegExMatch(strV, "i)^0x[0-9A-F]{4}$"))
				{
					cc := new MfChar(new MfInteger(strV))
				}
				else
				{
					cc := new MfChar(strV)
				}
				return cc.CharCode
			}
			else if (strParms = "MfInteger")
			{
				val := objParams.Item[0].Value
				If (val < MfChar.MinValue || val > MfChar.MaxValue)
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_CharCode"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				return val
			}
			else if (strParms = "MfString,MfInteger")
			{
				sObj := objParams.Item[0]
				iObj := objParams.Item[1]
				if (sObj.Length = 0)
				{
					return -1
				}
				iChar := new MfChar(sObj.Index[iObj]).CharCode
			}
			else if (strParms = "MfString,MfString")
			{
				; MfString,MfString should be var passed as non objects. Assuming string and integer
				sObj := objParams.Item[0]
				if (sObj.Length = 0)
				{
					return -1
				}
				iObj := MfInteger.GetValue(objParams.Item[1].Value, -1)
				if (iObj = -1)
				{
					return -1
				}
				iChar := new MfChar(sObj.Index[iObj]).CharCode
			}
			return iChar
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:_GetCharCode ;}
; 	End:Methods ;}
}
/*!
	End of class
*/