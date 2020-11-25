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
class MfMath extends MfObject
{
	static m_PI = 3.1415926535897931
	static m_E := 2.7182818284590451
	;{ PI
		/*!
			Property: PI [get]
				Represents the ratio of the circumference of a circle to its diameter, specified by the constant, π.
			Value:
				Var representing the PI property of the instance
			Remarks:
				Readonly Property
		*/
		PI[]
		{
			get {
				return MfMath.m_PI
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "PI")
				Throw ex
			}
		}
	; End:PI ;}
	;{ E
		/*!
			Property: E [get]
				Represents the natural logarithmic base, specified by the constant, e.
			Value:
				Var representing the E property of the instance
			Remarks:
				Readonly Property
		*/
		E[]
		{
			get {
				return MfMath.m_E
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "E")
				Throw ex
			}
		}
	; End:E ;}
;{ Methods
;{ 	Abs
	Abs(obj, ReturnAsObject = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		if (IsObject(obj) = false)
		{
			; assume int 64 if is integer obj
			if(Mfunc.IsInteger(obj))
			{
				long := new MfInt64(obj)
				return MfMath.Abs(long, _ReturnAsObject)
			}
			if (Mfunc.IsFloat(obj)) {
				flt := new MfFloat(obj)
				return MfMath.Abs(flt, _ReturnAsObject)
			}
		}
		
		if (MfObject.IsObjInstance(obj, MfSByte))
		{
			if (obj.Value > 0)
			{
				return _ReturnAsObject = true?obj:obj.Value
			}
			i := MfMath._AbsHelperSByte(obj.Value)
			return _ReturnAsObject = true?new MfSByte(i, obj.ReturnAsObject):i
		}
		if (MfObject.IsObjInstance(obj, MfInt16))
		{
			if (obj.Value > 0)
			{
				return _ReturnAsObject = true?obj:obj.Value
			}
			i := MfMath._AbsHelperInt16(obj.Value)
			return _ReturnAsObject = true?new MfInt16(i, obj.ReturnAsObject):i
		}
		else if (MfObject.IsObjInstance(obj, MfInteger))
		{
			if (obj.Value > 0)
			{
				return _ReturnAsObject = true?obj:obj.Value
			}
			i := MfMath._AbsHelperInt32(obj.Value)
			return _ReturnAsObject = true?new MfInteger(i, obj.ReturnAsObject):i
		}
		else if (MfObject.IsObjInstance(obj, MfInt64))
		{
			if (obj.Value > 0)
			{
				return _ReturnAsObject = true?obj:obj.Value
			}
			i := MfMath._AbsHelperInt64(obj.Value)
			return _ReturnAsObject = true?new MfInt64(i, obj.ReturnAsObject):i
		}
		else if (MfObject.IsObjInstance(obj, MfBigInt))
		{
			if (obj.IsNegative)
			{
				retval := obj.Clone()
				obj.IsNegative := False
				if (_ReturnAsObject)
				{
					return retval
				}
				return retval.Value
			}
			else
			{
				if (_ReturnAsObject)
				{
					retval := obj.Clone()
					return retval
				}
				return obj.Value
			}
		}
		else if (MfObject.IsObjInstance(obj, MfFloat))
		{
			wf := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, obj.Format)
			try
			{
				if (obj.GreaterThenOrEqual(0.0))
				{
					if (_ReturnAsObject)
					{
						retval := new MfFloat(obj.Value,obj.ReturnAsObject,,obj.Format)
						return retval
					}
					return obj.Value
				}
				f := Abs(obj.Value)
				if (_ReturnAsObject)
				{
					retval := new MfFloat(f,obj.ReturnAsObject,,obj.Format)
					return retval
				}
				return f
			}
			catch e
			{
				throw e
			}
			finally
			{
				 Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wf)
			}
		}
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:Abs ;}
	Acos(obj) {
		wf := A_FormatFloat
		frmt := ws
		IsObj := false
		value := obj
		if (IsObject(obj))
		{
			if (MfObject.IsObjInstance(obj, MfFloat))
			{
				frmt := obj.Format
				Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, frmt)
				isObj := true
				value := obj.Value
			}
			else
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_FloatVar", "obj"), "obj")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		try
		{
			
			result := ACos(value)
			if (IsObj)
			{
				retval := new MfFloat(result,,,frmt)
				return retval
			}
			return result
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Finally
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wf)
		}
	}
;{ 	Ceiling
	Ceiling(obj, ReturnAsObject = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		if (!IsObject(obj))
		{
			if (Mfunc.IsFloat(obj))
			{
				flt := new MfFloat(obj)
				return MfMath.Ceiling(flt, _ReturnAsObject)
			}
			if(Mfunc.IsInteger(obj))
			{
				if (_ReturnAsObject)
				{
					return new MfFloat(obj)
				}
				return obj
			}
			
		}
		if (MfObject.IsObjInstance(obj, MfFloat))
		{
			wf := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, obj.Format)
			try
			{
				i := Ceil(obj.Value)
				if (_ReturnAsObject)
				{
					retval := new MfFloat(0.0, obj.ReturnAsObject,,obj.Format)
					retval.Add(i)
					return retval
				}
				return i
			}
			catch e
			{
				throw e
			}
			finally
			{
				 Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wf)
			}
		}
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:Ceiling ;}
;{ 	DivRem
	; if a and b are big ints then returns big int
	; if a and b are of integer objects then result must be the same object type
	DivRem(a, b, byref result) {
		if (MfNull.IsNull(a))
		{
			ex := new MfArgumentNullException("a")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(b))
		{
			ex := new MfArgumentNullException("b")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		IsObj := IsObject(result)
		IsInAhkRange := false
		r := ""
		q := ""
		if (MfObject.IsObjInstance(a, MfInt64) && MfObject.IsObjInstance(b, MfInt64))
		{
			IsInAhkRange := true
			if (IsObj)
			{
				if (MfObject.IsObjInstance(result, MfInt64) = False)
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "result", "MfInt64"), "result")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			r := new MfInt64()
			q := new MfInt64()
		}
		else if (MfObject.IsObjInstance(a, MfInteger) && MfObject.IsObjInstance(b, MfInteger))
		{
			IsInAhkRange := true
			if (IsObj)
			{
				if (MfObject.IsObjInstance(result, MfInteger) = False)
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "result", "MfInteger"), "result")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			r := new MfInteger()
			q := new MfInteger()
		}
		else if (MfObject.IsObjInstance(a, MfUInt32) && MfObject.IsObjInstance(b, MfUInt32))
		{
			IsInAhkRange := true
			if (IsObj)
			{
				if (MfObject.IsObjInstance(result, MfUInt32) = False)
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "result", "MfUInt32"), "result")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			r := new MfUInt32()
			q := new MfUInt32()
		}
		else if (MfObject.IsObjInstance(a, MfInt16) && MfObject.IsObjInstance(b, MfInt16))
		{
			IsInAhkRange := true
			if (IsObj)
			{
				if (MfObject.IsObjInstance(result, MfInt16) = False)
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "result", "MfInteger"), "MfInt16")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			r := new MfInt16()
			q := new MfInt16()
		}
		else if (MfObject.IsObjInstance(a, MfUInt16) && MfObject.IsObjInstance(b, MfUInt16))
		{
			IsInAhkRange := true
			if (IsObj)
			{
				if (MfObject.IsObjInstance(result, MfUInt16) = False)
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "result", "MfUInt16"), "result")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			r := new MfUInt16()
			q := new MfUInt16()
		}
		else if (MfObject.IsObjInstance(a, MfBigInt) && MfObject.IsObjInstance(b, MfBigInt))
		{
			return MfBigInt.DivRem(a, b, result)
		}
		else if (MfObject.IsObjInstance(a, MfUInt64) && MfObject.IsObjInstance(b, MfUInt64))
		{
			if (IsObj)
			{
				if (MfObject.IsObjInstance(result, MfUInt64) = False)
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "result", "MfUInt64"), "result")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			BigIntA := a.m_bigx
			bigIntB := b.m_bigx
			q := new MfBigInt()
			r := new MfBigInt()
			q := MfBigInt.DivRem(BigIntA, bigIntB , r)
			uQ := new MfUInt64()
			uQ.m_bigx := q
			if (IsObj)
			{
				result.m_bigx := r
			}
			else
			{
				result := r.Value
			}
			return uQ
			
		}
		Dividend := MfInt64.GetValue(a, "NaN", true)
		Divisor := MfInt64.GetValue(b, "NaN", true)
		
		wf := Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, "D")
		try
		{
			If (Dividend == "NaN" || Divisor == "NaN")
			{
				; attempt to do math as long string math
				NegDividend := false
				NegDivisor := false
				If (Dividend == "NaN")
				{
					If (MfObject.IsObjInstance(a, MfPrimitive) = true) ; for MfUInt64 and such
					{
						a := a.Value
					}
					Dividend := MfBigInt._FromAny(a)
				}
				If (Divisor == "NaN")
				{
					If (MfObject.IsObjInstance(b, MfPrimitive) = true) ; for MfUInt64 and such
					{
						b := b.Value
					}
					Divisor := MfBigInt._FromAny(a)
				}

				return MfBigInt.DivRem(a, b, result)
			}
			; proceed as normal math ( not string math )
			if (Divisor = 0)
			{
				ex := new MfDivideByZeroException(MfEnvironment.Instance.GetResourceString("Arg_DivideByZero"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			divResult := Dividend // Divisor
			if (IsInAhkRange)
			{
				r.Value := divResult
				q.Value := Mod(Dividend, Divisor)
			}
			else
			{
				r := divResult
				q := Mod(Dividend, Divisor)
			}
			if (IsObj)
			{
				try
				{
					result.Value := q.Value
				}
				catch e
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("Arg_ArgumentOutOfRangeException"), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			else
			{
				result := q
			}
			return r
		}
		catch e
		{
			if (MfObject.IsObjInstance(e, MfDivideByZeroException))
			{
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)

			}
			throw e
		}
		finally
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.IntegerFast, wf)
		}
	}
; 	End:DivRem ;}
;{ 	_GetPrimesFromCache
	; Gets Prime Numbers from internal cache for values up to 30,010
	_GetPrimesFromCache(value) {
		; next prime past 30,000 is 30,011
		; MfBigMathInt caches all prime numbers
		; up to 30,000 on some methods so lets
		; take advantage of it
		if (value > 30010)
		{
			return false
		}
		; If Prime numbers are not yet cached then find and cache
		if (MfBigMathInt.primes.Count = 0)
		{
			MfBigMathInt.primes := MfBigMathInt.FindPrimes(30000)
		}
		
		ll := MfBigMathInt.primes.m_InnerList
		ans := new MfListvar()
		al := ans.m_InnerList
		i := 1
		iCount := MfBigMathInt.primes.Count
		while (i <= iCount)
		{
			x := ll[i]
			if (x <= value)
			{
				al[i] := x
			}
			else
			{
				break
			}
			i++
		}
		ans.m_Count := i - 1
		return ans

	}
; 	End:_GetPrimesFromCache ;}
;{ 	FindPrimes
	; return  MfListVar of all primes less than integer max
	FindPrimes(max) {
		max := MfInteger.GetValue(max)
		pCache := MfMath._GetPrimesFromCache(max)
		if (pCache)
		{
			return pCache
		}
		return MfBigMathInt.findPrimes(max)
	}
; 	End:FindPrimes ;}

;{ 	Floor
	Floor(obj, ReturnAsObject = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		if (IsObject(obj) = false)
		{
			if(Mfunc.IsInteger(obj))
			{
				if (_ReturnAsObject)
				{
					return new MfFloat(obj)
				}
				return obj
			}
			if (Mfunc.IsFloat(obj)) {
				flt := new MfFloat(obj)
				return MfMath.Floor(flt, _ReturnAsObject)
			}
		}
		if (MfObject.IsObjInstance(obj, MfFloat))
		{
			wf := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, obj.Format)
			try
			{
				i := Floor(obj.Value)
				if (_ReturnAsObject)
				{
					retval := new MfFloat(0.0, obj.ReturnAsObject,,obj.Format)
					retval.Add(i)
					return retval
				}
				return i
			}
			catch e
			{
				throw e
			}
			finally
			{
				 Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wf)
			}
		}
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:Floor ;}
;{ 	IntCompare
	; Less then one second to compare MfMath.IntCompare("12345634343","12345634343") 1000 times
	IntCompare(intA, intB) {
		if (MfNull.IsNull(intA))
		{
			ex := new MfArgumentNullException("intA")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(intb))
		{
			ex := new MfArgumentNullException("intB")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_intA := MfInt64.GetValue(intA, "NaN", true)
		_intB := MfInt64.GetValue(intB, "NaN", true)

		If (_intA == "NaN" || _intB == "NaN")
		{
			If (MfObject.IsObjInstance(intA, MfPrimitive) = true) ; for MfUInt64 and such
			{
				strA := intA.Value
			}
			else
			{
				strA :=  intA
			}
			If (MfObject.IsObjInstance(intB, MfPrimitive) = true) ; for MfUInt64 and such
			{
				strB := intB.Value
			}
			else
			{
				strB := intB
			}
			return MfMath._CompareLongIntStrings(strA, strB)
		}
		if (_IntA > _IntB)
		{
			return 1
		}
		if (_IntA < _IntB)
		{
			return -1
		}
		return 0
	}
; 	End:IntCompare ;}
;{ 	IntGreaterThen
	IntGreaterThen(intA, intB) {
		result := MfMath.IntCompare(intA, IntB)
		if (result > 0)
		{
			return true
		}
		return false
	}
; 	End:IntGreaterThen ;}
;{ 	IntGreaterThenOrEqualTo
	IntGreaterThenOrEqualTo(intA, intB) {
		result := MfMath.IntCompare(intA, IntB)
		if (result >= 0)
		{
			return true
		}
		return false
	}
; 	End:IntGreaterThenOrEqualTo ;}
;{ 	IntLessThen
	IntLessThen(intA, intB) {
		result := MfMath.IntCompare(intA, IntB)
		if (result < 0)
		{
			return true
		}
		return false
	}
; 	End:IntLessThen ;}
;{ 	IntLessThenOrEqualTo
	IntLessThenOrEqualTo(intA, intB) {
		result := MfMath.IntCompare(intA, IntB)
		if (result <= 0)
		{
			return true
		}
		return false
	}
; 	End:IntLessThenOrEqualTo ;}
;{ 	Max
	Max(obj1, obj2) {
		IsObj1 := IsObject(obj1)
		IsObj2 := IsObject(obj2)
		if (IsObj1 = false && IsObj2 = false)
		{
			result := MfMath.IntCompare(obj1, obj2)
			if (result > 0)
			{
				return obj1
			}
			return obj2
		}
		if((IsObj1 = true && IsObj2 = false) || (IsObj1 = false && IsObj2 = true))
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("Arg_VarOrObj"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ex := MfObject.IsNotObjInstance(obj1,,,A_ThisFunc)
		if (ex)
		{
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ex := MfObject.IsNotObjInstance(obj2,,,A_ThisFunc)
		if (ex)
		{
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfObject.IsObjInstance(obj1, MfFloat) && MfObject.IsObjInstance(obj2, MfFloat))
		{
			If (obj1.GreaterThen(obj2))
			{
				return obj1
			}
			return obj2
		}
		if (MfObject.IsObjInstance(obj1, MfUInt64) && MfObject.IsObjInstance(obj2, MfUInt64))
		{
			If (obj1.GreaterThen(obj2))
			{
				return obj1
			}
			return obj2
		}
		if (MfObject.IsObjInstance(obj1, MfBigInt) && MfObject.IsObjInstance(obj2, MfBigInt))
		{
			If (obj1.GreaterThen(obj2))
			{
				return obj1
			}
			return obj2
		}

		result1 := MfInt64.GetValue(obj1, "NaN", true)
		if (result1 == "NaN")
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		result2 := MfInt64.GetValue(obj2, "NaN", true)
		if (result2 == "NaN")
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (result1 > result2)
		{
			return obj1
		}
		return obj2
	}
; 	End:Max ;}
;{ 	Min
	Min(obj1, obj2) {
		IsObj1 := IsObject(obj1)
		IsObj2 := IsObject(obj2)
		if (IsObj1 = false && IsObj2 = false)
		{
			result := MfMath.IntCompare(obj1, obj2)
			if (result > 0)
			{
				return obj2
			}
			return obj1
		}
		if((IsObj1 = true && IsObj2 = false) || (IsObj1 = false && IsObj2 = true))
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("Arg_VarOrObj"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ex := MfObject.IsNotObjInstance(obj1,,,A_ThisFunc)
		if (ex)
		{
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		ex := MfObject.IsNotObjInstance(obj2,,,A_ThisFunc)
		if (ex)
		{
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (MfObject.IsObjInstance(obj1, MfFloat) && MfObject.IsObjInstance(obj2, MfFloat))
		{
			If (obj1.GreaterThen(obj2))
			{
				return obj2
			}
			return obj1
		}
		if (MfObject.IsObjInstance(obj1, MfUInt64) && MfObject.IsObjInstance(obj2, MfUInt64))
		{
			If (obj1.GreaterThen(obj2))
			{
				return obj2
			}
			return obj1
		}
		if (MfObject.IsObjInstance(obj1, MfBigInt) && MfObject.IsObjInstance(obj2, MfBigInt))
		{
			If (obj1.GreaterThen(obj2))
			{
				return obj2
			}
			return obj1
		}

		result1 := MfInt64.GetValue(obj1, "NaN", true)
		if (result1 == "NaN")
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		result2 := MfInt64.GetValue(obj2, "NaN", true)
		if (result2 == "NaN")
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (result1 > result2)
		{
			return obj2
		}
		return obj1
	}
; 	End:Min ;}
;{ 	Round
	; rounds a float value
	; Parrams
	;	Float
	;	Float, digits
	;	Float, digits, Mode
	;	Float, mode
	; mode is MfMidpointRounding
	; if Float is passed in as a var then a var is returned as the rounded result
	; if Float is passed in as a Mffloat then a MfFloat is returned as the rounded result
	Round(args*) {
		pArgs := MfMath._RoundParams(A_ThisFunc, args*)
		pList := pArgs.ToStringList()
		s := Null
		pIndex := 0
		flt := Null
		iDec := 0
		Mpr := MfMidpointRounding.Instance.AwayFromZero
		if (pList.Count > 0)
		{
			s := pList.Item[pIndex].Value
			if (s = "MfFloat") 
			{
				flt := pArgs.Item[pIndex]
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
			obj := pArgs.Item[pIndex]
			T := new MfType(obj)
			if (T.IsEnum || T.IsEnumItem)
			{
				; if Enum is in secondd position then there cannot be a third parameter
				if (pList.Count > 2)
				{
					e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
					e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw e
				}
				Mpr := obj
			}
			else if (T.IsIntegerNumber)
			{
				if (obj.Value < 0 || obj.Value > 15)
				{
					ex := new MfArgumentOutOfRangeException("digits", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_RoundingDigits"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				iDec := obj.Value
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
			obj := pArgs.Item[pIndex]
			T := new MfType(obj)
			if (T.IsEnum || T.IsEnumItem)
			{
				Mpr := obj
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
		if (iDec < 0 || iDec > 15)
		{
			ex := new MfArgumentOutOfRangeException("digits", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_RoundingDigits"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		AsVar := false
		if (pArgs.Data.Contains("AsVar") && (pArgs.Data.Item["AsVar"] = true))
		{
			AsVar := true
		}

		wf := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, flt.Format)
		try
		{
			tFloat := new MfFloat(flt,flt.ReturnAsObject,,flt.Format)

			if (Mpr.Equals(MfMidpointRounding.Instance.ToEven))
			{
				tFloat.Multiply(MfMath.roundPower10Double[iDec])
				if (tFloat.GreaterThenOrEqual(0.0))
				{
					i := Floor(tFloat.Value)
					tFloat.Subtract(i)
					if ((tFloat.GreaterThen(0.5)) || ((tFloat.Equals(0.5)) && (i & 1) != 0))
					{
						i++
					}
					tFloat.Value := 0.0
					tFloat.DecimalPlaces := iDec
					tFloat.Add(i)
					tFloat.Divide(MfMath.roundPower10Double[iDec])
					return AsVar = true?tFloat.Value:tFloat
				}
				else
				{
					i := Ceil(tFloat.Value)
					tFloat.Subtract(i)
					if ((tFloat.LessThen(-0.5)) || ((tFloat.Equals(-0.5)) && (i & 1) != 0))
					{
						i--
					}
					tFloat.Value := 0.0
					tFloat.DecimalPlaces := iDec
					tFloat.Add(i)
					tFloat.Divide(MfMath.roundPower10Double[iDec])
					return AsVar = true?tFloat.Value:tFloat
				}
			}
			else
			{
				; away from zero
				tFloat.Multiply(MfMath.roundPower10Double[iDec])
				if (tFloat.GreaterThenOrEqual(0.0))
				{
					i := Floor(tFloat.Value)
					tFloat.Subtract(i)

					if (tFloat.GreaterThenOrEqual(0.5))
					{
						i++
					}
					tFloat.Value := 0.0
					tFloat.DecimalPlaces := iDec
					tFloat.Add(i)
					tFloat.Divide(MfMath.roundPower10Double[iDec])
					return AsVar = true?tFloat.Value:tFloat
				}
				else
				{
					i := Ceil(tFloat.Value)
					tFloat.Subtract(i)
					if (tFloat.LessThenOrEqual(-0.5))
					{
						i--
					}
					tFloat.Value := 0.0
					tFloat.DecimalPlaces := iDec
					tFloat.Add(i)
					tFloat.Divide(MfMath.roundPower10Double[iDec])
					return AsVar = true?tFloat.Value:tFloat
				}
			}
		}
		catch e
		{
			throw e
		}
		Finally
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wf)
		}
	}
; 	End:Round ;}
	ShiftRightUnsigned(Value, ShiftCount) {

		bits := MfBinaryConverter.GetBits(value)
		result := MfBinaryConverter.ShiftRightUnsigned(bits, ShiftCount)
		throw new MfNotImplementedException()
		Return result
	}
; End:Methods ;}
;{ Internal Methods
;{ 	_RoundParams
	; read parameters for MfMath.Round()
	_RoundParams(MethodName, args*) {

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
			p.AllowEmptyValue := false ; all empty/null params will be added as undefined

			;p.AddInteger(0)
			;return p
			
			; can be up to five parameters
			; Two parameters is not a possibility
			if ((cnt = 0) || (cnt > 3))
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
						if (i = 1) ; float
						{
							p.Data.Add("AsVar", false)
						}
					} 
					else
					{
						if (i = 1) ; float
						{

							; cannot construct an instacne of MfUInt64 here with parameters
							; we are already calling from the constructor
							; create a new instance without parameters and set the properties
							try
							{
								_val := new MfFloat()
								_val.ReturnAsObject := false
								_val.Value := MfFloat.GetValue(arg)
								pIndex := p.Add(_val)
							}
							catch e
							{
								ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToFloat"), e)
								ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
								throw ex
							}
							; add key, value to args data to flag that this float was added from a var
							p.Data.Add("AsVar", true)
							
						}
						else if (i = 2) ; can be int Decimal Places or MfMidPointRounding, assume Decimal places
						{
							try
							{
								_val := new MfInteger()
								_val.ReturnAsObject := false
								_val.Value := MfInteger.GetValue(arg)
								pIndex := p.Add(_val)
							}
							catch e
							{
								ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), e)
								ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
								throw ex
							}
						}
						else ; can only be MfMidPointRounding
						{
							enum := MfEnum.ParseItem(MfMidpointRounding.GetType(), arg)
							pIndex := p.Add(enum)
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
; 	End:_RoundParams ;}
;{ 	_AbsHelperSByte
	_AbsHelperSByte(value) {
		if (value = MfSByte.MinValue)
		{
			ex := new  MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_NegateTwosCompNum"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return -value
	}
; 	End:_AbsHelperSByte ;}
;{ 	_AbsHelperInt16
	_AbsHelperInt16(value) {
		if (value = MfInt16.MinValue)
		{
			ex := new  MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_NegateTwosCompNum"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return -value
	}
; 	End:_AbsHelperInt16 ;}
;{ 	_AbsHelperInt32
	_AbsHelperInt32(value) {
		if (value = MfInteger.MinValue)
		{
			ex := new  MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_NegateTwosCompNum"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return -value
	}
; 	End:_AbsHelperInt32 ;}
;{ 	_AbsHelperInt64
	_AbsHelperInt64(value) {
		if (value = MfInt64.MinValue)
		{
			ex := new  MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_NegateTwosCompNum"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return -value
	}
; 	End:_AbsHelperInt64 ;}
;{ 	_IsNotMfObj
	_IsNotMfObj(obj) {
		if (MfObject.IsObjInstance(obj))
		{
			return false
		}
		
		ex := new MfException(MfEnvironment.Instance.GetResourceString("NonMfObjectException_General"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		return ex
	}
; 	End:_IsNotMfObj ;}
; End:Internal Methods ;}
	;{ roundPower10Double
		static m_roundPower10Double := ""
	/*!
		Property: roundPower10Double [get]
			Gets the roundPower10Double value associated with the this instance
		Value:
			Var representing the roundPower10Double property of the instance
		Remarks:
			Internal Readonly Property
	*/
		roundPower10Double[index]
		{
			get {
				if (MfMath.m_roundPower10Double = "")
				{
					MfMath.m_roundPower10Double := Array(1.0
						,10.0
						,100.0
						,1000.0
						,10000.0
						,100000.0
						,1000000.0
						,10000000.0
						,100000000.0
						,1000000000.0
						,10000000000.0
						,100000000000.0
						,1000000000000.0
						,10000000000000.0
						,100000000000000.0
						,1.0e15)
				}
				_Index := index + 1 ; make it zero based
				return MfMath.m_roundPower10Double[_Index]
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "roundPower10Double")
				Throw ex
			}
		}
	; End:roundPower10Double ;}
;{ 	_LongIntStringDivide
	_LongIntStringDivide(dividend, divisor, ByRef remainder) {
		; bigX := MfBigInt.Parse(dividend)
		; remainder := bigX.Divide(divisor)
		; return

		; string method is at least 100 time faster then MfBigInt method on 1000 loops
		q := ""
		sNum := ""
		iLength := StrLen(dividend)
		cMod := 0
		remainder := 0
		loop, parse, dividend
		{
			sNum .= A_LoopField
			cNum := sNum + 0 ; convert to int
			if ( (cNum = 0) && (A_Index > 1) && (A_Index < iLength))
			{
				q .= "0"
				sNum := ""
				continue
			}
			if ( (cNum < divisor) && (A_Index < iLength) )
			{
				if (A_Index > 1)
				{
					q .= "0"
				}
				continue
			}
			cQ := cNum // divisor
			q .= cQ . ""
			cMod := Mod(cNum, divisor)
			if (cMod = 0 )
			{
				sNum := ""
			}
			else
			{
				sNum := cMod . ""
			}
			
		}
		remainder := cMod
		MfMath._RemoveLeadingZeros(q)
		return q
	}
; 	End:_LongIntStringDivide ;}
;{ 	_RemoveLeadingZeros
	;//Is removing leading zeros from an LongInt String. If the String holds
	;//an leading Minus it is kept -0000123 => -123 and 00985 => 985
	_RemoveLeadingZeros(ByRef LongIntString) {
		local LCh, ZCh, WS
		WS = %LongIntString%
		StringLeft, LCh, WS, 1 
		if (LCh = "-")
		 StringTrimLeft, WS, WS, 1
		 loop
		 {
		 	StringLeft, ZCh, WS, 1 
		 	if (ZCh = "0")
		 	StringTrimLeft, WS, WS, 1
		 	 else
		 	 break  
		}
		If (WS = "")   ;//If it is empty now make it 0
		 	WS = 0
		if (LCh = "-") ;//Add minus again if there was one
			WS = -%WS%
		LongIntString = %WS% ;//returns result BYREF !!!!
	}
; 	End:_RemoveLeadingZeros ;}
;{ 	_IsStringInt
	_IsStringInt(varInt, byRef IsNeg) {
		if (IsObject(varInt))
		{
			return false
		}
		If (MfString.IsNullOrEmpty(varInt))
		{
			return false
		}
		if (varInt ~= "^[0-9]+$")
		{
			IsNeg := false
			return true
		}
		else if (varInt ~= "^\+[0-9]+$")
		{
			IsNeg := false
			return true
		}
		else if (varInt ~= "^-[0-9]+$")
		{
			IsNeg := true
			return true
		}
		return false
	}
; 	End:_IsStringInt ;}
;{ 	IsValidInt64Range
	; value must be passed in as a string
	; "9223372036854775808" will report false
	; 9223372036854775808 will report true as without
	; quotes AutoHotkey will convert to 9223372036854775807 (Integer Max)
	;
	; value can have leading sign of - or + but must be a string
	_IsValidInt64Range(value, AllowFloatValue = false) {
		
		strX := value . ""
		xLen := StrLen(strX)
		If (xLen > 20)
			return false
		strLead := SubStr(strX, 1, 4)
		;^(?:-)?0x[0-9a-fA-F]+$
		if (strLead ~= "^0x[0-9a-fA-F]+$")
		{
			if (strX ~= "^0x[0-9a-fA-F]{1,16}$")
			{
				Hex := format("Z{:X}", value) ; will remove leading zeros
				if (hex == "Z0")
				{
					; this is the case when value is 0x0
					return true
				}
				zValue := "Z" . LTrim(SubStr(value,3),"0")
				if (Hex = zValue)
				{
					return true
				}
			}
			return false
		}
		if (strLead ~= "^-0x[0-9a-fA-F]+$")
		{
			if (strX ~= "^-0x[0-9a-fA-F]{1,16}$")
			{				
				Hex := format("Z{:X}", SubStr(value, 2)) ; remove leading sign or format will flip bits
				zValue := "Z" . LTrim(SubStr(value,4),"0")
				if (Hex = zValue)
				{
					return true
				}
				if (zValue = "Z8000000000000000")
				{
					; special case for integer max min value of -0x8000000000000000
					return true
				}
			}
			return false
		}
		_AllowFloatValue := MfBool.GetValue(AllowFloatValue, false)
		if (_AllowFloatValue = true)
		{
			dotIndex := InStr(strX, ".") -1
			;dotIndex := MfString.IndexOf(strX, ".")
			if (dotIndex = 0)
			{
				return true ; zero value
			}
			if (dotIndex > 0)
			{
				strX := SubStr(strX, 1, dotIndex) ; way faster then current MfString.SubString
				;strX := MfString.Substring(strX, 0, dotIndex)
			}
		}
		; maximum length of Integer Max or Min with sign is 20 characters
		
		; positive sign will be dropped by format
		; negative sign will not be droped
		x1 := format("x{:i}", value)
			
		; check for a positive sign and remove it if exist
		if (strLead ~= "\+[0-9]+")
		{
			x2 := "x" . SubStr(strX, 2)
		}
		else
		{
			x2 := "x" . strX
		}
		if (x1 == x2)
			return true
		return false
	}
; 	End:IsValidInt64Range ;}

;{ 	_GreaterThenIntString
	_GreaterThenIntString(FirstLongString, SecondLongString) {
		If (MfString.IsNullOrEmpty(SecondLongString))
		{
			return false
		}
		If (MfString.IsNullOrEmpty(FirstLongString))
		{
			return false
		}

		result := MfMath._CompareLongIntStrings(FirstLongString, SecondLongString)
		return result > 0
	}
; 	End:_GreaterThenIntString ;}
;{ 	_GreaterThenOrEqualToIntString
	_GreaterThenOrEqualToIntString(FirstLongString, SecondLongString) {
		If (MfString.IsNullOrEmpty(SecondLongString))
		{
			return false
		}
		If (MfString.IsNullOrEmpty(FirstLongString))
		{
			return false
		}
		result := MfMath._CompareLongIntStrings(FirstLongString, SecondLongString)
		return result > -1
	}
; 	End:_GreaterThenOrEqualToIntString ;}
;{ 	_LessThenIntString
	_LessThenIntString(FirstLongString, SecondLongString) {
		If (MfString.IsNullOrEmpty(SecondLongString))
		{
			return false
		}
		If (MfString.IsNullOrEmpty(FirstLongString))
		{
			return false
		}
		result := MfMath._CompareLongIntStrings(FirstLongString, SecondLongString)
		return result < 0
	}
; 	End:_LessThenIntString ;}
;{ 	_LessThenOrEqualToIntString
	_LessThenOrEqualToIntString(FirstLongString, SecondLongString) {
		If (MfString.IsNullOrEmpty(SecondLongString))
		{
			return false
		}
		If (MfString.IsNullOrEmpty(FirstLongString))
		{
			return false
		}
		result := MfMath._CompareLongIntStrings(FirstLongString, SecondLongString)
		return result < 1
	}
; 	End:_LessThenOrEqualToIntString ;}
;{ 	_CompareLongIntStrings
	; Comparing IntegerStrings (also WITH leading Minus)
	; Leading Zeros are removed by default to make comparison possible
	; If First  is smaller than Second -1 is returned
	; If First and Second are equal 0 is returned
	; If First is  bigger than Second  1 is returned
	; If one of the Strings is empty it is assumed to be 0
	_CompareLongIntStrings(FirstLongString, SecondLongString) {
		; x := MfBigInt.Parse(FirstLongString)
		; return x.CompareTo(SecondLongString)

		; using string method is 65 time faster then MfBigIntCompare on 1000 loop

	  ;local FSize, FCh, SSize, SCh, Output, Ret_Val
	  MfMath._RemoveLeadingZeros(FirstLongString)
	  MfMath._RemoveLeadingZeros(SecondLongString)
	  StringLen, FSize, FirstLongString
	  StringLen, SSize, SecondLongString
	  StringLeft, FCh, FirstLongString, 1 
	  StringLeft, SCh, SecondLongString, 1 
	  if (FCh = "-") and (SCh <> "-")
	     Ret_Val = -1
	  else   
	  if (SCh = "-") and (FCh <> "-")
	     Ret_Val = 1
	  else   
	  {
	    if (FSize > SSize)
	    {
	      if (FCh = "-") and (SCh = "-") 
	         Ret_Val = -1
	      else
	         Ret_Val = 1
	    }
	    else
	    if (SSize > FSize)
	    {
	      if (FCh= "-" ) and (SCh = "-") 
	         Ret_Val = 1
	      else
	         Ret_Val = -1
	    }
	    else
	    if (SSize = FSize)
	    {
	      Ret_Val = 0 ;//assume we find no difference
	      loop, %SSize%
	      {
	        StringMid, Dig1, FirstLongString, %A_index%, 1 
	        StringMid, Dig2, SecondLongString, %A_index%, 1 
	        if (Dig1<>Dig2)  ;//Found a different digit
	        {
	          if (Dig1>Dig2)
	          {
	            If (FCh = "-") and (SCh = "-")
	               Ret_Val = -1
	            else
	               Ret_Val = 1
	            break   
	          }     
	          else
	          if (Dig2 > Dig1)
	          {
	            If (FCh = "-") and (SCh = "-")
	               Ret_Val = 1
	            else
	               Ret_Val = -1
	            break   
	          }     
	        }
	      } 
	    }
	  }
	  
	  return, Ret_Val 
	}
; 	End:_CompareLongIntStrings ;}
}