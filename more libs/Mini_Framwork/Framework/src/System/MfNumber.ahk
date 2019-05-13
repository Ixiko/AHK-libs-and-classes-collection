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

class MfNumber extends MfObject
{
	static Int32Precision := 10
	static Int64Precision := 19
	static NumberMaxDigits := 50
	static UInt32Precision := 10
	static UInt64Precision := 20

;{ 	MfNumber.NumberBuffer Class
	class NumberBuffer
	{
		static _NumberBufferBytes := ""
		;{ NumberBufferBytes
			/*!
				Property: NumberBufferBytes [get]
					Gets the NumberBufferBytes value associated with the this instance
				Value:
					Var representing the NumberBufferBytes property of the instance
				Remarks:
					Readonly Property
			*/
			NumberBufferBytes[]
			{
				get {
					if (MfNumber.NumberBuffer._NumberBufferBytes = "")
					{
						num1 := (51) * (A_IsUnicode ? 2 : 1)
						MfNumber.NumberBuffer._NumberBufferBytes := 12 + num1 + A_PtrSize
					}
					return MfNumber.NumberBuffer._NumberBufferBytes
				}
				set {
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
					ex.SetProp(A_LineFile, A_LineNumber, "NumberBufferBytes")
					Throw ex
				}
			}
		; End:NumberBufferBytes ;}
		
		digits := "" ; instance of MfMemoryString
		precision := 0
		scale := 0
		sign := false
		baseAddress := ""
		;m_mstr := ""

		__new(BufferLen) {
			; stackBuffer is the memory addres to array of bytes created via VarSetCapacity
			;this.m_mstr := new MfMemoryString(BufferLen)
			this.digits := new MfMemoryString(BufferLen)
			this.baseAddress := this.digits.BufferPtr
			this.precision := 0
			this.scale := 0
			this.sign := false
		}
		
	}
; 	End:MfNumber.NumberBuffer Class ;}
	class _CharIndex
	{
		m_class := ""
		;~ m_init := false
		__New(ByRef ObjClass) {
			this.m_Class := ObjClass
		}

		__Get(key:="", args*) {
			if (Mfunc.IsInteger(key))
			{	
				return this.m_Class.CharCode[key]
			}
					
		}
		__Set(key, Value) {
			
			if (Mfunc.IsInteger(key))
			{
				this.m_Class.CharCode[key] := Value
				If (this.m_Class.CharPos -1 < key)
				{
					this.m_Class.CharPos := key + 1
				}
			}
			
		}
	}

	IsWhite(ch) {
		return ch = 32 || (ch >= 9 && ch <= 13)
	}
;{ 	MatchChars
	; returns index of mached char +1 within mStr or ""
	MatchChars(mStr, StartIndex, byRef str) {
		len := StrLen(str)
		if (len = 0)
		{
			return ""
		}
		mLen := mStr.Length
		ms := new MfMemoryString(len,,,&str)
		
		ch2 := ms.CharCode[0]
		if (ch2 = 0)
		{
			return ""
		}
		if (len > mLen)
		{
			return ""
		}
		i := 0
		j := StartIndex
		; ptr := mStr.BufferPtr
		; ptrStr := ms.BufferPtr
		; mStrBpc := mStr.BytesPerChar
		; msBpc := ms.BytesPerChar
		While (i < len)
		{
			ch := mStr.CharCode[j]
			ch2 := ms.CharCode[i]
			if (ch != ch2)
			{
				if (ch2 = 160 && ch = 32)
				{
					; This fix is for French or Kazakh cultures
					i++
					Continue
				}
				return ""
			}
			i++
			j++
		}
		return j
	}
; 	End:MatchChars ;}
	ParseDouble(value, options, numfmt) {
		If (MfString.IsNullOrEmpty(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		numberBufferBytes := MfNumber.NumberBuffer.NumberBufferBytes
		;numberBufferBytes := NumberBuffer.NumberBufferBytes
		number := new MfNumber.NumberBuffer(numberBufferBytes)
		d := 0.0
		if (!MfNumber.TryStringToNumber(value, options, number, numfmt, false))
		{
			; If we failed TryStringToNumber, it may be from one of our special strings.
			; Check the three with which we're concerned and rethrow if it's not one of
			; those strings.
			sTrim := trim(value)
			if (sTrim = numfmt.PositiveInfinitySymbol)
			{
				return MfFloat.PositiveInfinity
			}
			if (sTrim = numfmt.NegativeInfinitySymbol)
			{
				return MfFloat.NegativeInfinity
			}
			If (sTrim = numfmt.NaNSymbol)
			{
				return MfFloat.NaN
			}
			

			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		;number.digits.CharPos := number.precision
		MfNumber.NumberToDouble(number, d)
		return d
	}
; 	End:ParseInt32 ;}
	ParseInt32(s, style, info) {
		numberBufferBytes := MfNumber.NumberBuffer.NumberBufferBytes
		;numberBufferBytes := NumberBuffer.NumberBufferBytes
		number := new MfNumber.NumberBuffer(numberBufferBytes)
		i := 0
		MfNumber.StringToNumber(s, style, number, info, false)
		if ((style & 512) != 0)
		{
			; style & MfNumberStyles.AllowHexSpecifier
			if (!MfNumber.HexNumberToInt32(number, i))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}	
		}
		else
		{
			if (!MfNumber.NumberToInt32(number, i))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		return i
	}
; 	End:ParseInt32 ;}
;{ 	ParseUInt32
	ParseUInt32(s, style, info) {
		numberBufferBytes := MfNumber.NumberBuffer.NumberBufferBytes
		;numberBufferBytes := NumberBuffer.NumberBufferBytes
		number := new MfNumber.NumberBuffer(numberBufferBytes)
		i := 0
		MfNumber.StringToNumber(s, style, number, info, false)
		if ((style & 512) != 0)
		{
			; style & MfNumberStyles.AllowHexSpecifier
			if (!MfNumber.HexNumberToUInt32(number, i))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt32"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}	
		}
		else
		{
			if (!MfNumber.NumberToUInt32(number, i))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt32"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		return i
	}
; 	End:ParseUInt32 ;}
;{ 	ParseInt64
	ParseInt64(s, style, info) {
		numberBufferBytes := MfNumber.NumberBuffer.NumberBufferBytes
		;numberBufferBytes := NumberBuffer.NumberBufferBytes
		number := new MfNumber.NumberBuffer(numberBufferBytes)
		i := 0
		MfNumber.StringToNumber(s, style, number, info, false)
		if ((style & 512) != 0)
		{
			; style & MfNumberStyles.AllowHexSpecifier
			if (!MfNumber.HexNumberToInt64(number, i))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}	
		}
		else
		{
			if (!MfNumber.NumberToInt64(number, i))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		return i
	}
; 	End:ParseInt64 ;}
;{ 	ParseUInt64
	; will return a string representing the number if parsed successfully
	ParseUInt64(s, style, info) {
		numberBufferBytes := MfNumber.NumberBuffer.NumberBufferBytes
		;numberBufferBytes := NumberBuffer.NumberBufferBytes
		number := new MfNumber.NumberBuffer(numberBufferBytes)
		i := ""
		MfNumber.StringToNumber(s, style, number, info, false)
		if ((style & 512) != 0)
		{
			; style & MfNumberStyles.AllowHexSpecifier
			if (!MfNumber.HexNumberToUInt64(number, i))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}	
		}
		else
		{
			if (!MfNumber.NumberToUInt64(number, i))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		return i
	}
; 	End:ParseUInt64 ;}
;{ 	HexNumberToInt32
	HexNumberToInt32(ByRef number, ByRef value) {
		passedValue := 0
		returnValue := MfNumber.HexNumberToUInt32(number, passedValue)
		; passedValue need to convert this value to int32. it is now Uint32
		VarSetCapacity( Var, 16, 0) ; Variable to hold integer
		NumPut(passedValue , Var, 0, "UInt") ; Input as 'Unsigned Integer'
		value := NumGet(Var, 0, "Int")	; Retrieve it as 'Signed Integer'
		VarSetCapacity( Var, 0) 
		return value
	}
; 	End:HexNumberToInt32 ;}
;{ 	HexNumberToUInt32
	HexNumberToUInt32(ByRef number, ByRef value) {
		i := number.scale
		if (i > MfNumber.UInt32Precision || i < number.precision)
		{
			 return false
		}
		p := 0
		ch := number.digits.CharCode[p]
		n := 0
		while (--i >= 0)
		{
			if (n > 268435455) ; (0xFFFFFFFF / 16)
			{
				return False
			}
			n *= 16
			if (ch != 0)
			{
				newN := n
				if (ch != 0)
				{
					if (ch >= 48 && ch <= 57)
					{
						newN += (ch - 48)
					}
					else
					{
						if (ch >= 65 && ch <= 70)
						{
							newN += ((ch - 65) + 10)
						}
						else if (ch >= 97 && ch <= 102)
						{
							newN += ((ch - 97) + 10)
						}
					}
					p++
					ch := number.digits.CharCode[p]
				}
				; Detect an overflow here...
				 if (newN < n)
				 {
				 	return false
				 }
				 n := newN
			}
		}
		 value := n
		 return true
	}
; 	End:HexNumberToUInt32 ;}
;{ 	HexNumberToInt64
	HexNumberToInt64(ByRef number, ByRef value) {
		i := number.scale
		if (i > MfNumber.UInt64Precision || i < number.precision)
		{
			 return false
		}
		p := 0
		ch := number.digits.CharCode[p]
		n := 0
		sb := new MfText.StringBuilder(MfNumber.UInt64Precision)
		sb.Append("0x")
		while (--i >= 0)
		{
			if (ch != 0)
			{
				if (ch != 0)
				{
					if (ch >= 48 && ch <= 57)
					{
						sb._AppendCharCode(ch)
					}
					else
					{
						if (ch >= 65 && ch <= 70)
						{
							sb._AppendCharCode(ch)
						}
						else if (ch >= 97 && ch <= 102)
						{
							sb._AppendCharCode(ch)
						}
					}
					ch := number.digits.CharCode[++p]
				}
			}
		}
		len := sb.Length
		if (len <= 16)
		{
			str := sb.ToString()
			Value := str + 0x0
			return true
		}
		if (len > 18)
		{
			return false ; max 0xFFFFFFFFFFFFFFFF
		}
		str := sb.ToString()
		lst := MfNibConverter.FromHex(str,16, 16)
		Value := MfNibConverter.ToInt64(lst)
		return true
		; result := MfInt64.GetValue(str,"NaN", true)
		; if (result == "NaN")
		; {
		; 	return false
		; }
		; AutoHotkey will automatically wrap into valid int64 if value is greater then
		; MfInt64.MaxValue then will wrap into neg
		; Value := str + 0x0
		; return true
	}
; 	End:HexNumberToInt64 ;}
;{ 	HexNumberToUInt64
	; value will be a hex string with no leading format if result is true
	HexNumberToUInt64(ByRef number, ByRef value) {
		i := number.scale
		if (i > MfNumber.UInt64Precision || i < number.precision)
		{
			 return false
		}
		p := 0
		ch := number.digits.CharCode[p]
		n := 0
		sb := new MfText.StringBuilder(MfNumber.UInt64Precision + 2)
		sb.Append("0x")
		while (--i >= 0)
		{
			if (ch != 0)
			{
				if (ch != 0)
				{
					if (ch >= 48 && ch <= 57)
					{
						sb._AppendCharCode(ch)
					}
					else
					{
						if (ch >= 65 && ch <= 70)
						{
							sb._AppendCharCode(ch)
						}
						else if (ch >= 97 && ch <= 102)
						{
							sb._AppendCharCode(ch)
						}
					}
					ch := number.digits.CharCode[++p]
				}
			}
		}
		len := sb.Length
		if (len <= 16)
		{
			str := sb.ToString()
			Value := str + 0x0
			return true
		}
		str := sb.ToString()
		sb := ""
		bigInt := MfBigInt.Parse(str, 16)
		If (bigInt.GreaterThen(MfUInt64.MaxValue))
		{
			return false
		}
		Value := bigInt.ToString()
		return true
	}
; 	End:HexNumberToUInt64 ;}
	NumberToDouble(byRef number, ByRef value) {
		mStr := new MfMemoryString(56,,"UTF-8")
		;mStr := new MfMemoryString(56)
		; precision will always be number count parsed ignore decimal and sign up to but not including e
		; if Percision is greater then or equal to 15 then anything after that Percision should be droped and exp added
; eg 1 "1177100000000001e8" 	will become 1.1771E+23 				percision of 16, Scale 24	Delta 8		chars "1177100000000001"
; eg 2 "1177100000000001e-8"	will become 11771000 				percision of 16, Scale 8 	Delta -8	chars "1177100000000001"
; eg 3 "1177100000000001e-3" 	will become 1177100000000 			percision of 16, Scale 13	Delta -3	chars "1177100000000001"
; eg 4 "123456789123456789e-3" 	will become 123456789123457 		percision of 18, Scale 15	Delta -3	chars "123456789123456789"
; eg 5 "123456789123456789" 	will become 1.23456789123457E+17 	percision of 18, Scale 18	Delta 0		chars "123456789123456789"
; eg 6 "123456789e-10" 			will become 0.0123456789 			percision of 9, Scale -1	Delta -10	chars "123456789"
; eg 7 "123456789e-43" 			will become 1.23456789E-35 			percision of 9, Scale -34	Delta -43	chars "123456789"

; eg 8 "0.1177100000000001e-25" 			will becomes 1.1771E-26 	percision of 16, Scale -25 Delta -41
; eg 9 "0.3177100000000001e-25" 			will becomes 3.1771E-26  	percision of 16, Scale -25 Delta -41	chars "3177100000000001"
; eg 10 "000000000.1177100000000001e-25" 	will becomes 1.1771E-26 	percision of 16, Scale -25 Delta -41 leading 0's are ignored same as eg 8
; eg 11 "000000000.11771000000000010000e-25"will becomes 1.1771E-26 	percision of 16, Scale -25,Delta -41 leading 0's are ignored same as eg 8
; 	chars "1177100000000001" same as eg 8

; eg 12 "0.00000000000000000000000000000000000000000000001177100000000001"
;	becomes 1.1771E-47 percision of 17, Scale -46
;	Delta -63, ; string 17 chars, "1177100000000001"
; eg 13 "1177100e-8"			will become 0.011771			precision of 5, scale of -1	chars "11771"
; eg 14	"123456789123456789e-4" will become 12345678912345.7	precision of 18, scale of 14				chars "123456789123456789"
; eg 15 "117.7100000001e8"		will become 11771000000.01		precision of 13, scale of 11 				chars "1177100000001"
; eg 16 "117.7100000001e-8"		will become 1.177100000001E-06	precision of 13, scale of -5 				chars "1177100000001"
; eg 17 "123456789e-9"			will become 0.123456789			precision of 9, scale of 0		delta -9	chars "123456789"
; eg 18 "123456789e-10"			will become 0.0123456789		precision of 9, scale of -1		delta -10	chars "123456789"
; eg 19 "123456789e-6"			will become 123.456789			precision of 9, scale of 3		delta -6	chars "123456789"

		; ONLY DIGTST UP TO A MAX OF 50 DIGITS WILL BE PARSED (after leading and trailing 0's are removed)
		; All leading 0's before and after decimal point are droped when parsed. This is a rule!
		; number.digits will include all 0-9 chars after dropping leading and trailing 0's no matter where the decimal point is
		; output will only have leading zero if percision + scale is less then 15
		; When precision > 15 then rounding will occur, Rounding occurs before Trimming of any zeros from end of number.digits
		; If percision is greater then 15 then drop anything after 15, if exp is positive then add droped as exp as in eg 1
		; 	if the exp is neg then drop futher removing drop from exp and then drop any remainding exp as in eg 2
		;	However if Drop + remaining exp exceeds length of output pad the left with zeros after the decimal point ( to a max of 15 then do exp see)
		; If there are trailing zeros then and exp is pos then drop them and add the number dropped to exp as show in eg 1
		; If Scale is Negative then add 0's to left of number after dec as shown in eg 6 up to 15 places
		; after 15 places see eg 7

		precision := number.precision 
		scale := number.scale
		sign := number.sign
		delta := scale - precision
		; str := number.digits.ToString()
		; Clipboard := str
		if (precision = 0 && scale = 0)
		{
			mStr.AppendCharCode(48) ; 0
			mstr.AppendCharCode(46) ; .
			mStr.AppendCharCode(48) ; 0
			value := mstr.ToString()
			return true
		}
		pMax := 15
		If (sign)
		{
			mStr.AppendCharCode(45)
		}

		if (precision > pMax) ; precision will be at least 16
		{
			exp := 0

			expSign := ""
			If (delta >= 0)
			{
				expSign := 43 ; +
				exp := scale - 1

				; using 16 digits, 15 to return but 16th to do rounding
				digits := number.digits.SubString(0, pMax + 1)
				LastDigit := digits.CharCode[pMax] - 48
				LastDigit += 0
				if (LastDigit >= 5)
				{
					i := digits.ToString(0, pMax)
					i++
					digits := ""
					digits := new MfMemoryString(StrLen(i),,,&i)
				}
				digits.CharPos := pMax ; need to set this to allow any trailing 0's to be trimmed
				;MfNumber.MStrCutAtCharPos(number.digits, pMax)
				mstr.AppendCharCode(digits.CharCode[0])
				mstr.AppendCharCode(46) ; .
				MfNumber.MStrTrimTrailingZero(digits)
				if (digits.Length > 0)
				{
					if (digits.Length > pMax - 1)
					{
						mstr.Append(digits.SubString(1, pMax - 1))
					}
					else
					{
						mstr.Append(digits)
					}
				}
				else
				{
					mstr.AppendCharCode(48) ; 0
					exp--
				}
			}
			else ; delta < 0 at this point
			{
				expSign := 45 ; -
				exp := 0
				if (scale >= 0)
				{
					digits := number.digits.SubString(0, scale + 1)
					LastDigit := digits.CharCode[scale] - 48
					LastDigit += 0
					if (LastDigit >= 5)
					{
						i := digits.ToString(0, pMax)
						i++
						digits := ""
						digits := new MfMemoryString(StrLen(i),,,&i)
					}
					if (digits.Length > scale)
					{
						if (scale > 0)
						{
							mstr.Append(digits.SubString(0, scale))	
						}
						else
						{
							mstr.AppendCharCode(48) ; 0
						}
					}
					else
					{
						mstr.Append(digits)
					}
					mstr.AppendCharCode(46) ; .
					if (scale = 0)
					{
						mstr.Append(number.digits)
					}
					else
					{
						mstr.AppendCharCode(48) ; 0
					}
					
				}
				else ; scale is < 0 at this point
				{
					exp := abs(scale) + 1
					; using 16 digits, 15 to return but 16th to do rounding
					digits := number.digits.SubString(0, pMax + 1)
					LastDigit := digits.CharCode[pMax] - 48
					LastDigit += 0
					if (LastDigit >= 5)
					{
						i := digits.ToString(0, pMax)
						i++
						digits := ""
						digits := new MfMemoryString(StrLen(i),,,&i)
					}
					digits.CharPos := pMax ; need to set this to allow any trailing 0's to be trimmed

					;MfNumber.MStrCutAtCharPos(number.digits, pMax)
					mstr.AppendCharCode(digits.CharCode[0])
					mstr.AppendCharCode(46) ; .
					MfNumber.MStrTrimTrailingZero(digits)

					if (digits.Length > 0)
					{
						if (digits.Length > pMax - 1)
						{
							mstr.Append(digits.SubString(1, pMax - 1))
						}
						else
						{
							mstr.Append(digits)
						}
					}
					else
					{
						mstr.AppendCharCode(48) ; 0
						exp++
					}
				}
			}
			
			if (exp != 0)
			{
				mstr.AppendCharCode(69) ; E
				mstr.AppendCharCode(expSign)
				mstr.Append(exp)
			}
				
			value := mstr.ToString()
			return true

		}
		else ; if (precision > pMax)
		{
			exp := 0

			expSign := ""
			If (delta >= 0)
			{
				if (scale < pMax -1)
				{
					exp := 0
					mstr.Append(number.digits)
					if (delta > 0)
					{
						mstr.AppendCharCode(48, delta) ; 0
					}
					else
					{
						mstr.AppendCharCode(46) ; .
						mstr.AppendCharCode(48) ; 0
					}
				}
				else
				{
					expSign := 43 ; +
					exp := scale - 1

					; using 16 digits, 15 to return but 16th to do rounding
					digits := number.digits
					;MfNumber.MStrCutAtCharPos(number.digits, pMax)
					mstr.AppendCharCode(digits.CharCode[0])
					mstr.AppendCharCode(46) ; .
					if (digits.Length > 0)
					{
						mstr.Append(digits.SubString(1))
					}
					else
					{
						mstr.AppendCharCode(48) ; 0
						exp--
					}
				}
					
			}
			else ; delta < 0 at this point
			{
				expSign := 45 ; -
				exp := 0
				if (scale > 0)
				{
					exp := 0
					digits := number.digits
					i := 0
					theta := Abs(delta)
					diff := precision - theta
					While (i < diff)
					{
						ch := digits.CharCode[i]
						mstr.AppendCharCode(ch)
						i++
					}
					mstr.AppendCharCode(46) ; .
					mstr.Append(digits.SubString(i))
				}
				else ; scale is < or = 0 at this point
				{
					exp := abs(scale) + 1
					; using 16 digits, 15 to return but 16th to do rounding
					digits := number.digits
					
					theta := Abs(delta)
					; theta is the number of positions to shift decimal from right to left
					; if theta is greater then precision then 0 must be added
					; creating a format such as 0.001234 from 1234e-6
					; However if theta exceeds 7 then format will change
					; creating a format such as 1.234E-5 from 1234e-8
					;MfNumber.MStrCutAtCharPos(number.digits, pMax)
					if (theta < pMax - 1)
					{
						
						diff := theta - precision
						if (diff >= 0)
						{
							exp := 0
							mstr.AppendCharCode(48) ; 0
							mstr.AppendCharCode(46) ; .
							if (diff > 0)
							{
								mstr.AppendCharCode(48, diff) ; 0	
							}
							mstr.Append(digits)
						}
						else
						{
							i := 0
							diff := precision - theta
							While (i < diff)
							{
								ch := digits.CharCode[i]
								mstr.AppendCharCode(ch)
								i++
							}
							mstr.AppendCharCode(46) ; .
							mstr.Append(digits.SubString(i))
						}


					}
					else
					{
						exp := Abs(scale - 1)

						; using 16 digits, 15 to return but 16th to do rounding
						digits := number.digits
						mstr.AppendCharCode(digits.CharCode[0])
						mstr.AppendCharCode(46) ; .
						MfNumber.MStrTrimTrailingZero(digits)
						if (digits.Length > 0)
						{
							mstr.Append(digits.SubString(1))
						}
						else
						{
							mstr.AppendCharCode(48) ; 0
							exp--
						}
					}
					
				}
			}
			
			if (exp != 0)
			{
				mstr.AppendCharCode(69) ; E
				mstr.AppendCharCode(expSign)
				mstr.Append(exp)
			}
				
			value := mstr.ToString()
			return true
		}
	}
;{ 	MStrTrimTrailingZero
	; Trims zeros from right side of number and returns then number of zeros trimmed
	; mStr instance of MfMemoryString
	MStrTrimTrailingZero(ByRef mStr) {
		If (mStr.Length = 0)
		{
			return 0
		}
		Oldlen := mStr.Length
		mStr.TrimEnd("0")
		NewLen := mStr.Length
		return OldLen - NewLen
	}
; 	End:MStrTrimTrailingZero ;}
;{ 	MStrCutAtCharPos
	; cuts the mStr MfMemoryInstance at Pos and returns the Number of Char cut from string
	; Pos is the new char Position or max Length of mStr in chars
	MStrCutAtCharPos(ByRef mStr, pos) {
		If (Pos < 1)
		{
			return 0
		}
		OldLen := mStr.Length
		if (OldLen <= Pos)
		{
			return 0
		}
		mStr.CharPos := pos
		NewLen := mStr.Length
		return OldLen - NewLen
	}
; 	End:MStrCutAtCharPos ;}
;{ 	NumberToInt32
	NumberToInt32(ByRef number, ByRef value) {
		i := number.scale
		if (i > MfNumber.Int32Precision || i < number.precision)
		{
			return false
		}
		p := 0
		ch := number.digits.CharCode[p]
		n := 0
		while (--i >= 0)
		{
			if (n > (214748364)) ; (0x7FFFFFFF / 10
			{
				return false
			}
			n *= 10
			if (ch != 0)
			{
				n += ch - 48
				ch := number.digits.CharCode[++p]
			}
		}
		if (number.sign)
		{
			n := -n
			if (n > 0)
			{
				return false
			}
		}
		else
		{
			if (n < 0)
			{
				return false
			}
		}
		value := n
		return true
	}
; 	End:NumberToInt32 ;}
;{ 	NumberUToInt32
	NumberToUInt32(ByRef number, ByRef value) {
		i := number.scale
		if (i > MfNumber.UInt32Precision || i < number.precision || number.sign)
		{
			return false
		}
		p := 0
		ch := number.digits.CharCode[p]
		n := 0
		while (--i >= 0)
		{
			if (n > 429496729) ; 0xFFFFFFFF / 10
			{
				return false
			}
			n *= 10
			if (ch != 0)
			{
				newN := n + ch - 48
				if (newN < n)
				{
					return false
				}
				n := newN
				ch := number.digits.CharCode[++p]
			}
		}
		value := n
		return true
	}
; 	End:NumberUToInt32 ;}
;{ 	NumberToInt64
	NumberToInt64(ByRef number, ByRef value) {
		i := number.scale
		if (i > MfNumber.Int64Precision || i < number.precision)
		{
			return false
		}
		p := 0
		ch := number.digits.CharCode[p]
		n := 0
		; when adding to int64 it will overflow automatically when it gets to
		; to max value so 9223372036854775807 + 1 becomes -9223372036854775808
		; this is not the desired result for NumberToInt64 so will do an extra
		; check using sign below
		while (--i >= 0)
		{
			; result := MfInt64.GetValue(n,"NaN", true)
			; if (result == "NaN")
			; {
			; 	return false
			; }
			if (n > (922337203685477580)) ; 0x7FFFFFFFFFFFFFFF / 10
			{
				return false
			}
			n *= 10
			if (ch != 0)
			{
				n += ch - 48
				ch := number.digits.CharCode[++p]
			}
		}
		if (number.sign)
		{
			n := -n
			; check at this point that the number is still positive
			; if not then overflow has occured and return false
			if (n > 0)
			{
				return false
			}
		}
		else
		{
			if (n < 0)
			{
				return false
			}
		}
		value := n
		return true
	}
; 	End:NumberToInt64 ;}
	NumberToUInt64(ByRef number, ByRef value) {
		i := number.scale
		if (i > MfNumber.UInt64Precision || i < number.precision || number.sign)
		{
			return false
		}
		p := 0
		ch := number.digits.CharCode[p]
		n := 0
		sb := new MfText.StringBuilder(MfNumber.UInt64Precision)
		;sb._AppendCharCode(ch)

		while (--i >= 0)
		{
			if (ch != 0)
			{
				sb._AppendCharCode(ch)
				ch := number.digits.CharCode[++p]
			}
		}
		str := sb.ToString()
		sb := ""
		bigInt := MfBigInt.Parse(str, 10)
		If (bigInt.GreaterThen(MfUInt64.MaxValue))
		{
			return false
		}
		Value := str
		return true
	}
;{ 	StringToNumber
	StringToNumber(str, options, ByRef number, info, parseDecimal) {
		; empty string should throw MfFormatException
		if (str == "")
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(str))
		{
			ex := new MfArgumentNullException("str")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		mStr := MfMemoryString.FromAny(str)
		len := mStr.Length
		ParsecChars := 0
		if (!MfNumber.ParseNumber(mStr, ParsecChars, options, number, "", info , parseDecimal) 
			|| (ParsecChars <len && !MfNumber.TrailingZeros(mStr, (len - ParsecChars))))
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:StringToNumber ;}
;{ 	TrailingZeros
	; return boolean
	TrailingZeros(mStr, index) {
		; For compatability, we need to allow trailing zeros at the end of a number string
		i := index
		len := mStr.Length
		while (i < len)
		{
			ch := mStr.CharCode[i]
			if (ch != 0)
			{
				return false
			}
			i++
		}
		return true
	}
; 	End:TrailingZeros ;}
;{ 	ParseNumber
	ParseNumber(mStr, ByRef ParsedChars, options, ByRef number, sb, numfmt, parseDecimal) {
		static StateSign := 0x0001
		static StateParens := 0x0002
		static StateDigits := 0x0004
		static StateNonZero := 0x0008
		static StateDecimal := 0x0010
		static StateCurrency := 0x0020

		
		number.scale := 0
		number.sign := false

		decSep := ""			; decimal separator from NumberFormatInfo.
		groupSep := "" 			; group separator from NumberFormatInfo.
		currSymbol := "" 		; currency symbol from NumberFormatInfo.

		; The alternative currency symbol used in ANSI codepage, that can not roundtrip between ANSI and Unicode.
		; Currently, only ja-JP and ko-KR has non-null values (which is U+005c, backslash)
		ansicurrSymbol := "" 	; currency symbol from NumberFormatInfo.
		altdecSep := "" 		; decimal separator from NumberFormatInfo as a decimal
		altgroupSep := ""	 	; group separator from NumberFormatInfo as a decimal

		parsingCurrency := false
		if ((options & 256) != 0)
		{
			; options & MfNumberStyles.Instance.AllowCurrencySymbol
			currSymbol := numfmt.CurrencySymbol
			if (numfmt.ansiCurrencySymbol != "")
			{
				ansicurrSymbol := numfmt.ansiCurrencySymbol
			}
			; The idea here is to match the currency separators and on failure match the number separators to keep the perf of VB's IsNumeric fast.
			; The values of decSep are setup to use the correct relevant separator (currency in the if part and decimal in the else part).
			altdecSep := numfmt.NumberDecimalSeparator
			altgroupSep := numfmt.NumberGroupSeparator
			decSep := numfmt.CurrencyDecimalSeparator
			groupSep := numfmt.CurrencyGroupSeparator
			parsingCurrency := true
		}
		else
		{
			decSep := numfmt.NumberDecimalSeparator
			groupSep := numfmt.NumberGroupSeparator
		}
		state := 0
		signflag := false
		bigNumber := !MfNull.IsNull(sb)
		bigNumberHex := (bigNumber && ((options & 512) != 0))
		maxParseDigits := bigNumber ? MfInteger.MaxValue : MfNumber.NumberMaxDigits

		p := 0
		ch := mStr.CharCode[0]
		next := ""
		len := mStr.Length + 1 ; add one to allow for null terminator
		i := 0
		While (i < len)
		{
			
			; Eat whitespace unless we've found a sign which isn't followed by a currency symbol.
			; "-Kr 1231.47" is legal but "- 1231.47" is not.
			if (MfNumber.IsWhite(ch) && ((options & 1) != 0) 
				&& (((state & StateSign) = 0) || (((state & StateSign) != 0) && (((state & StateCurrency) != 0)
					|| numfmt.numberNegativePattern = 2))))
			{
				; Do nothing here. We will increase i at the end of the loop.
			}
			else if ((signflag := (((options & 4) != 0) && ((state & StateSign) == 0))) && ((next := MfNumber.MatchChars(mStr, p, numfmt.positiveSign)) != ""))
			{
				state |= StateSign
				p := next - 1
			}
			else if (signflag && (next := MfNumber.MatchChars(mStr,p, numfmt.negativeSign)) != "")
			{
				state |= StateSign
				number.sign := true
				p := next - 1
			}
			else if (ch = 40 && ((options & 16) != 0) && ((state & StateSign) = 0))
			{
				; ascii 40 = (
				state |= StateSign | StateParens
				number.sign := true
			}
			else if ((currSymbol != "" && (next := MfNumber.MatchChars(mStr, p, currSymbol)) != "") || (ansicurrSymbol != "" 
				&& (next := MfNumber.MatchChars(mStr, p, ansicurrSymbol)) != ""))
			{
				state |= StateCurrency
				currSymbol := ""
				ansicurrSymbol := ""
				; We already found the currency symbol. There should not be more currency symbols. Set
				; currSymbol to NULL so that we won't search it again in the later code path.
				p := next - 1
			}
			else
			{
				break
			}
			i++
			p++
			ch := mStr.CharCode[p]
		}
		digCount := 0
		digEnd := 0
		While (i < len)
		{
			if ((ch >= 48 && ch <= 57) || (((options & 512) != 0) && ((ch >= 97 && ch <= 102) || (ch >= 65 && ch <= 70))))
			{
				; if char is 0 to 9 or ((option MfNumberStyles.Instance.AllowHexSpecifier ) and ((ch = a to f) or (ch = A to F))
				state |= StateDigits
				if (ch != 48 || (state & StateNonZero) != 0 || bigNumberHex)
				{
					if (digCount < maxParseDigits)
					{
						if (bigNumber)
						{
							 sb.Append(ch)
						}
						else
						{
							number.digits.CharCode[digCount++] := ch

						}
						if (ch != 48 || parseDecimal)
						{
							digEnd := digCount
						}
						if ((state & StateDecimal) = 0)
						{
							number.scale++
						}
						state |= StateNonZero
					}

				}
				else if ((state & StateDecimal) != 0)
				{
					number.scale--
				}
			}
			else if (((options & 32) != 0) && ((state & StateDecimal) = 0) && ((next := MfNumber.MatchChars(mStr, p, decSep)) != "" || ((parsingCurrency) && (state & StateCurrency) = 0) && (next := MfNumber.MatchChars(mStr, p, altdecSep)) != ""))
			{
				; options & NumberStyles.AllowDecimalPoint
				state |= StateDecimal
				p := next - 1
			}
			else if (((options & 64) != 0) && ((state & StateDigits) != 0) && ((state & StateDecimal) = 0) && ((next := MfNumber.MatchChars(mStr, p, groupSep)) != "" || ((parsingCurrency) && (state & StateCurrency) = 0) && (next := MfNumber.MatchChars(mStr, p, altgroupSep)) != ""))
			{
				; options & NumberStyles.AllowThousands
				p := next - 1
			}
			else
			{
				break
			}
			i++
			p++
			ch := mStr.CharCode[p]
		}
		negExp := false
		number.precision := digEnd
		if (bigNumber)
		{
			sb._AppendCharCode(0)
		}
		else
		{
			number.digits.CharCode[digEnd] := 0
		}
		if ((state & StateDigits) != 0)
		{
			if ((ch = 69 || ch = 101) && ((options & 128) != 0))
			{
				; ch = E or ch = e , options & NumberStyles.AllowExponent
				temp := p
				p++
				ch := mStr.CharCode[p]
				if ((next := MfNumber.MatchChars(mStr, p, numfmt.positiveSign)) != "")
				{
					p := next
					ch := mStr.CharCode[p]
				}
				else if ((next := MfNumber.MatchChars(mStr, p, numfmt.negativeSign)) != "")
				{
					p := next
					ch := mStr.CharCode[p]
					negExp := true
				}
				if (ch >= 48 && ch <= 57) ; ch 0 to 9
				{
					exp := 0
					while (ch >=48 && ch <= 57)
					{
						exp := (exp * 10) + (ch - 48) ; ch - 48 gets actual digit 0 to 9
						
						p++
						ch := mStr.CharCode[p]
						if (exp > 1000)
						{
							exp := 9999
							while (ch >= 48 && ch <= 57)
							{
								p++
								ch := mStr.CharCode[p]
							}
						}
					}
					if (negExp)
					{
						exp := -exp
					}
					number.scale += exp
				}
				else
				{
					p := temp
					ch := mStr.CharCode[p]
				}
			}
			loop
			{
				if (MfNumber.IsWhite(ch) && ((options & 2) != 0))
				{
					; options & NumberStyles.AllowTrailingWhite
				}
				else if ((signflag := (((options & 8) != 0) && ((state & StateSign) = 0))) && (next := MfNumber.MatchChars(MStr, p, numfmt.positiveSign)) != "")
				{
					; options & NumberStyles.AllowTrailingSign
					 state |= StateSign
					 p := next - 1
				}
				else if (signflag && (next := MfNumber.MatchChars(mStr, p, numfmt.negativeSign)) != "") 
				{
					state |= StateSign
					number.sign := true
					p := next - 1
				}
				else if (ch = 41 && ((state & StateParens) != 0))
				{
					; ch = ')'
					intSP := new MfInteger(StateParens)
					state &= MfBinaryConverter.NumberComplement(intSp).Value
				}
				else if ((currSymbol != "" && (next := MfNumber.MatchChars(mStr, p, currSymbol)) != "") || (ansicurrSymbol != "" && (next := MfNumber.MatchChars(mStr, p, ansicurrSymbol)) != ""))
				{
					currSymbol := ""
					ansicurrSymbol := ""
					p := next - 1
				}
				else
				{
					break
				}
				ch := mStr.CharCode[++p]
			}
			if ((state & StateParens) = 0)
			{
				if ((state & StateNonZero) = 0)
				{
					if (!parseDecimal)
					{
						number.scale := 0
					}
					if ((state & StateDecimal) = 0)
					{
						number.sign := false
					}
				}
				ParsedChars := p
				number.digits.CharPos := number.precision
				return true
			}
		}
		ParsedChars := p
		return false
	}
; 	End:ParseNumber ;}
;{ 	TryStringToNumber
	TryStringToNumber(str, options, ByRef number, args*) {
		aCnt := MfParams.GetArgCount(args*)
		; if acount = 2 MfNumberFormatInfo numfmt, Bool parseDecimal
		; if acount = 3 StringBuilder sb, MfNumberFormatInfo numfmt, Bool parseDecimal
		if (aCnt = 2)
		{
			return MfNumber._TryStringToNumber(str, options, number, "", args[1], args[2])
		}
		return MfNumber._TryStringToNumber(str, options, number, args[1], args[2], args[3])
	}
; 	End:TryStringToNumber ;}
	TryParseDouble(s, style, info, ByRef result) {
		numberBufferBytes := MfNumber.NumberBuffer.NumberBufferBytes
		;numberBufferBytes := NumberBuffer.NumberBufferBytes
		number := new MfNumber.NumberBuffer(numberBufferBytes)
		result := 0.0
		if(!MfNumber.TryStringToNumber(s, style, number, info, false))
		{
			return false
		}
		if (!MfNumber.NumberToDouble(number, result))
		{
			return false
		}
		return true
	}
;{ 	_TryStringToNumber
	_TryStringToNumber(str, options, ByRef number, sb, numfmt, parseDecimal) {
		len := StrLen(str)
		if (len = 0)
		{
			return false
		}
		mStr := new MfMemoryString(len,,,&str)
		ParsecChars := 0
		if (!MfNumber.ParseNumber(mStr, ParsecChars, options, number, sb, numfmt , parseDecimal) 
			|| (ParsecChars <len && !MfNumber.TrailingZeros(mStr, (len - ParsecChars))))
		{
			return false
		}
		return true
	}
; 	End:_TryStringToNumber ;}
;{ 	TryParseInt32
	TryParseInt32(s, style, info, ByRef result) {
		numberBufferBytes := MfNumber.NumberBuffer.NumberBufferBytes
		;numberBufferBytes := NumberBuffer.NumberBufferBytes
		number := new MfNumber.NumberBuffer(numberBufferBytes)
		result := 0
		if(!MfNumber.TryStringToNumber(s, style, number, info, false))
		{
			return false
		}
		if ((style & 512) != 0)
		{
			; style & MfNumberStyles.AllowHexSpecifier
			if (!MfNumber.HexNumberToInt32(number, result))
			{
				return false
			}	
		}
		else
		{
			if (!MfNumber.NumberToInt32(number, result))
			{
				return false
			}
		}
		return true
	}
; 	End:TryParseInt32 ;}
;{ 	TryParseUInt32
	TryParseUInt32(s, style, info, ByRef result) {
		numberBufferBytes := MfNumber.NumberBuffer.NumberBufferBytes
		;numberBufferBytes := NumberBuffer.NumberBufferBytes
		number := new MfNumber.NumberBuffer(numberBufferBytes)
		result := 0
		if(!MfNumber.TryStringToNumber(s, style, number, info, false))
		{
			return false
		}
		if ((style & 512) != 0)
		{
			; style & MfNumberStyles.AllowHexSpecifier
			if (!MfNumber.HexNumberToUInt32(number, result))
			{
				return false
			}	
		}
		else
		{
			if (!MfNumber.NumberToUInt32(number, result))
			{
				return false
			}
		}
		return true
	}
; 	End:TryParseUInt32 ;}
;{ 	TryParseInt64
	TryParseInt64(s, style, info, ByRef result) {
		numberBufferBytes := MfNumber.NumberBuffer.NumberBufferBytes
		;numberBufferBytes := NumberBuffer.NumberBufferBytes
		number := new MfNumber.NumberBuffer(numberBufferBytes)
		result := 0
		if(!MfNumber.TryStringToNumber(s, style, number, info, false))
		{
			return false
		}
		if ((style & 512) != 0)
		{
			; style & MfNumberStyles.AllowHexSpecifier
			if (!MfNumber.HexNumberToInt64(number, result))
			{
				return false
			}	
		}
		else
		{
			if (!MfNumber.NumberToInt64(number, result))
			{
				return false
			}
		}
		return true
	}
; 	End:TryParseInt64 ;}
;{ 	TryParseUInt64
	; result will be a string representing the number if parsed successfully
	TryParseUInt64(s, style, info, ByRef result) {
		numberBufferBytes := MfNumber.NumberBuffer.NumberBufferBytes
		;numberBufferBytes := NumberBuffer.NumberBufferBytes
		number := new MfNumber.NumberBuffer(numberBufferBytes)
		result := "0"
		if(!MfNumber.TryStringToNumber(s, style, number, info, false))
		{
			return false
		}
		if ((style & 512) != 0)
		{
			; style & MfNumberStyles.AllowHexSpecifier
			if (!MfNumber.HexNumberToUInt64(number, result))
			{
				return false
			}	
		}
		else
		{
			if (!MfNumber.NumberToUInt64(number, result))
			{
				return false
			}
		}
		return true
	}
; 	End:TryParseUInt64 ;}
}