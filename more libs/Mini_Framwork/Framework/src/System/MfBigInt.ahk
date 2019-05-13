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
; Represents Big Integer object
Class MfBigInt extends MfObject
{
	m_bi := ""
	;{ Static Properties
	TypeCode[]
	{
		get {
			return 27
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}

; End:Static Properties ;}
;{ 	Constructor
/*
	Method: Constructor()
		Initializes a new instance of the MfBigInt class.

	OutputVar := new MfInt64([int, returnAsObj, readonly])

	Constructor([int, retunAsObj, readonly])
		Initializes a new instance of the MfBigInt class optionally setting the Value property, ReturnAsObject property and the ReadOnly property.
	Parameters:
		int
			The MfBigInt object or var containing integer to create a new instance with.
		returnAsObj
			Determines if the current instance of MfBigInt class will return MfBigInt instances from functions or vars containing integer. If omitted value is false
		readonly
			Determines if the current instance of MfBigInt class will allow its Value to be altered after it is constructed.
			The ReadOnly property will reflect this value after the class is constructed.
			If omitted value is false
	Throws:
		Throws MfNotSupportedException if class is extended.
		Throws MfArgumentException if error in parameter.
		Throws MfNotSupportedException if incorrect type of parameters or incorrect number of parameters.
	Remarks:
		Sealed Class.
		This constructor initializes the MfBigInt with the integer value of int.
		Value property to the value of int.
		ReturnAsObject will have a value of returnAsObj
		ReadOnly will have a value of readonly.
		If ReadOnly is true then any attempt to change the underlying value will result in MfNotSupportedException being thrown.
*/
	__new(args*) {
		; Parameters all optional, Value=0, ReturnAsObject=false, ReadOnly=false
		if (this.__Class != "MfBigInt")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfInt64"))
		}
		base.__new()
		
		_readonly := false
		pArgs := this._ConstructorParams(A_ThisFunc, args*)
		pList := pArgs.ToStringList()
		pIndex := 0
		if (pList.Count > 0)
		{
			this._FromAnyConstructor(pArgs.Item[pIndex])
		}
		else
		{
			this.m_bi := new MfListVar(3)
		}
		if (pList.Count > 1)
		{
			pIndex++
			s := pList.Item[pIndex].Value
			if (s = "MfBool")
			{
				this.m_ReturnAsObject := pArgs.Item[pIndex].Value
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
				this.m_ReadOnly := pArgs.Item[pIndex].Value
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
		
		
		this.m_isInherited := False
		
	}
; 	End:Constructor ;}
;{ 	_ConstructorParams
	_ConstructorParams(MethodName, args*) {

		p := Null
		cnt := MfParams.GetArgCount(args*)

	
		if ((cnt > 0) && MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
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

			
			; can be up to five parameters
			; Two parameters is not a possibility
			if (cnt > 3)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
			
			i := 1
			while (i <= cnt)
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
						else
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
						else if (i = 1) ; bigInt any kind, add as string
						{

							p.AddString(arg)
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
		return p
	}
; 	End:_ConstructorParams ;}
;{ 	Methods
;{ 	Add
/*
	Method: Add()

	OutputVar := instance.Add(value)

	Add(value)
		Adds value to current instance of MfBigInt.
	Parameters:
		value
			The value to add to the current instance.
			Can be var integer representation or any type that matches IsIntegerNumber or MfUInt64 or MfBigInt
	Returns:
		If ReturnAsObject is true then returns current instance of MfBigInt with an updated value; Otherwise returns var containing integer.
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentException if value is not able to be converted for usage by current instance.
*/
	Add(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this._ClearCache()
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (x.IsNegative = false && this.IsNegative = false)
		{
			this.m_bi := MfBigMathInt.add(this.m_bi, x.m_bi)
			return this._ReturnBigInt()
		}
		if (x.IsNegative = true && this.IsNegative = true)
		{
			this.m_bi := MfBigMathInt.add(this.m_bi, x.m_bi)
			return this._ReturnBigInt()
		}
		if (this.IsNegative != x.IsNegative)
		{
			If (MfBigMathInt.Equals(this.m_bi, x.m_bi))
			{
				tmp := new MfBigInt(new MfInteger(0))
				this.m_bi := tmp.m_bi
				this.IsNegative := False
				return this._ReturnBigInt()
			}
			If (MfBigMathInt.Greater(this.m_bi, x.m_bi))
			{
				this.m_bi := MfBigMathInt.Sub(this.m_bi, x.m_bi)
				this.IsNegative := !x.IsNegative
			}
			else
			{
				this.m_bi := MfBigMathInt.Sub(x.m_bi,this.m_bi)
				this.IsNegative := !this.IsNegative
			}
			return this._ReturnBigInt()
		}
		return this._ReturnBigInt()
	}
; 	End:Add ;}
;{ 	BitShiftLeft
/*
	Method: BitShiftLeft()

	OutputVar := instance.BitShiftLeft(value)

	BitShiftLeft(value)
		Performs left shift operation current instance bits by value amount.
	Parameters:
		value
			The number of places to shift bits left.
			Can var integer or any type that matches IsInteger.
	Returns:
		If ReturnAsObject is true then returns current instance of MfBigInt with an updated Value; Otherwise returns Value as var.
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfException for any other errors during the operation.
	Example:
		bigI := new MfBigInt("77444564454564646", true)

		bigI.BitShiftLeft(10)
		MsgBox % bigI.Value ; 79303234001474197504
		bigI := new MfBigInt(8, true)

		bigI.BitShiftLeft(4)
		MsgBox % bigI.Value ; 128
		bigI := MfBigInt.Parse("+10111111", 2) ; parse binary base 2

		bigI.BitShiftLeft(4)
		; Display as binary base 2
		MsgBox % bigI.ToString(2) ; 101111110000
*/
	BitShiftLeft(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_value := 0
		try
		{
			_value :=  MfInteger.GetValue(value)
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (_value = 0)
		{
			return
		}
		if(this._IsZero())
		{
			return
		}
		if (_value < 0)
		{
			this._SetZero()
			return
		}
		this._ClearCache()
		; Get how many positins may be needed for the shift
		n := (_value // MfBigMathInt.bpe) + 1
		; add new positions to the list
		this.m_bi := MfBigMathInt.Trim(this.m_bi, n)
		; do the shifting
		MfBigMathInt.leftShift_(this.m_bi, _value)
		; trim inner list back down
		this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
		if(this._IsZero())
		{
			this.IsNegitive := false
		}
	}
; 	End:BitShiftLeft ;}
;{ 	BitShiftRight
/*
	Method: BitShiftRight()

	OutputVar := instance.BitShiftRight(value)

	BitShiftRight(value)
		Performs right shift operation current instance bits by value amount.
	Parameters:
		value
			The number of places to shift bits right.
			Can var integer or any type that matches IsInteger.
	Returns:
		If ReturnAsObject is true then returns current instance of MfUInt64 with an updated Value; Otherwise returns Value as var.
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfException for any other errors during the operation.
	Remarks:
		When binary bits are shifted right the shifted bits are disposed of and can not be retrieved.
	Example:
		bigI := new MfBigInt("77444564454564646", true)

		bigI.BitShiftRight(10)
		MsgBox % bigI.Value ; 75629457475160
		bigI := new MfBigInt(8, true)

		bigI.BitShiftRight(4)
		MsgBox % bigI.Value ; 0
		bigI := MfBigInt.Parse("+10111111", 2) ; parse binary base 2

		bigI.BitShiftRight(4)
		; Display as binary base 2
		MsgBox % bigI.ToString(2) ; 1011
*/
	BitShiftRight(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_value := 0
		try
		{
			_value :=  MfInteger.GetValue(value)
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (_value = 0)
		{
			return
		}
		if(this._IsZero())
		{
			return
		}
		if (_value < 0)
		{
			this._SetZero()
			return
		}
		this._ClearCache()
		
		; If (_value >= this.BitSize)
		; {
		; 	this._SetZero()
		; 	return
		; }
		MfBigMathInt.rightShift_(this.m_bi, _value)
		; trim inner list back down
		this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
		if (this.IsNegative)
		{
			this.m_bi := MfBigMathInt.Add(this.m_bi, MfBigMathInt.one)
		}
		this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
		if(this._IsZero())
		{
			this.IsNegative := false
		}
	}
; 	End:BitShiftRight ;}
;{ 	_SetZero
	; set current Instance to 0 value
	_SetZero() {
		this._ClearCache()
		this.m_bi := new MfListVar(2, 0)
		this.IsNegative := false
	}
; 	End:_SetZero ;}
;{ 	_ClearCache
	_ClearCache() {
		this.strValue := ""
		this.m_BitSize := ""
	}
; 	End:_ClearCache ;}
;{ 	CompareTo
/*
	Method: CompareTo()
		Overrides MfObject.CompareTo
	CompareTo(obj)
		Compares this instance to a specified MfBigInt instance.
	Parameters:
		obj
			A MfBigInt object to compare to current instance.
	Returns:
		Returns a var containing integer indicating the position of this instance in the sort order in relation to the value parameter. Return Value Description Less than zero This instance precedes obj value. Zero This instance has the same position in the sort order as value. Greater than zero This instance follows
	Throws:
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfBigInt.
	Remarks:
		Compares this instance to a specified MfBigInt instance and indicates whether this instance precedes, follows, or appears in the same position in the sort order as the specified MfBigInt instance.
*/
	CompareTo(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Equals(x))
		{
			return 0
		}
		if (this.GreaterThen(x))
		{
			return 1
		}
		return -1
	}
; 	End:CompareTo ;}
;{ 	Clone
/*
	Method: Clone()
		Clones the current instance an return  a new instance with the same values.

	OutputVar := instance.Clone()

	Clone()
		Clones the current instance an return  a new instance with the same values.
	Returns:
		Returns a new instance that is a copy of the current instance.
	Throws:
		Throws MfNullReferenceException if called as static method.
*/
	Clone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := new MfBigInt(new MfInteger(0))
		retval.m_bi := this.m_bi.Clone()
		retval.m_IsNegative := this.m_IsNegative
		return retval
	}
; 	End:Clone ;}
;{ 	Divide
/*
	Method: Divide()

	OutputVar := instance.Divide(value)

	Divide(value)
		Divides the current instance of MfBigInt by the divisor value and returns remainder as instance of MfBigInt
	Parameters:
		value
			The Divisor value to divide the current instance Value by.
			Can be var integer representation or any type that matches IsIntegerNumber or MfUInt64 or MfBigInt
	Returns:
		Returns Remainder as instance of MfBigInt.
	Throws:
		Throws MfNotSupportedException if ReadOnly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfDivideByZeroException if value is zero.
		Throws MfArithmeticException if the operation fails or value is not an instance of MfBigInt and can not be converted into usable value.
	Remarks:
		If you need to work with decimal/float numbers see MfFloat
	Example:
		i := new MfBigInt("88839834534058347978797", true) ; create new MfBigInt and set it RetrunAsObject to value to true
		iNew := new MfBigInt("5345354")
		r := i.Divide(iNew)
		MsgBox % MfString.Format("Result:'{0}', Remainder:'{1}'", r.Value, i.Value) ; Result:'16620009551108934', Remainder:'3186161'
		i := new MfBigInt("88839834534058347978797", true) ; create new MfBigInt and set it RetrunAsObject to value to true
		r := i.Divide("6456564564566")
		MsgBox % MfString.Format("Result:'{0}', Remainder:'{1}'", r.Value, i.Value) ; Result:'13759613745', Remainder:'5976074419127'
*/
	Divide(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
				
		this._ClearCache()
		r := new MfBigInt()
		q := MfBigInt.DivRem(this, value, r)
		this.m_bi := q.m_bi
		this.IsNegative := q.IsNegative
		return r

	}
; 	End:Divide ;}
;{ 	DivRem
/*
	Method: DivRem()

	OutputVar := MfBigInt.DivRem(dividend, divisor, remainder)

	MfBigInt.DivRem(dividend, divisor, remainder)
		Calculates the quotient of two MfBigInt signed integers and also returns the remainder in an output parameter.
	Parameters:
		dividend
			The dividend.
			Can be var integer representation or any type that matches IsIntegerNumber or MfUInt64 or MfBigInt
		divisor
			The divisor.
			Can be var integer representation or any type that matches IsIntegerNumber or MfUInt64 or MfBigInt
		remainder
			The remainder.
	Returns:
		Returns instance of MfBigInt instance as the quotient of the specified numbers.
	Throws:
		Throws MfArgumentNullException if dividend or divisor is null.
		Throws MfArgumentException  if dividend or divisor is unable to be convert to a usable value.
	Example:
		remainder := new MfBigInt()
		bigI := MfBigInt.DivRem("7897798244398122076", "770980", remainder)
		str := MfString.Format("Result:'{0}', Remainder:'{1}'", bigI.Value, remainder.Value)
		MsgBox %str% ; Result:'10243843218239', Remainder:'217856'
		remainder := new MfBigInt()
		uint := new MfUInt32(348876)
		short := new MfInt16(-23567)
		bigI := MfBigInt.DivRem(uint, short, remainder)
		str := MfString.Format("Result:'{0}', Remainder:'{1}'", bigI.Value, remainder.Value)
		MsgBox %str% ; Result:'-14', Remainder:'18938'
*/
	DivRem(dividend, divisor, byref remainder) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(dividend))
		{
			ex := new MfArgumentNullException("dividend")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(divisor))
		{
			ex := new MfArgumentNullException("divisor")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		y := ""
		try
		{
			x := MfBigInt._FromAny(dividend)
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBigInt"), "dividend")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try
		{
			y := MfBigInt._FromAny(divisor)
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBigInt"), "divisor")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfBigMathInt.IsZero(y.m_bi))
		{
			ex := new MfDivideByZeroException()
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		IsObj := false
		If (IsObject(remainder))
		{
			If (MfObject.IsObjInstance(remainder, MfBigInt) = false)
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType_Generic"), "remainder")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			IsObj := true
		}
		
		q := new MfBigInt()
		r := new MfBigInt()


		if (MfBigMathInt.IsZero(x.m_bi))
		{
			; all return value will be zero
			if (IsObj)
			{
				remainder.m_bi := r.m_bi
				remainder.IsNegative := false
			}
			else
			{
				remiander := r.Value
			}
			return q ; return 0 value
		}

		; q and r must have arrays that are exactly the same Count as x. (Or q can have more).
		r.m_bi := new MfListVar(x.m_bi.Count, 0)
		q.m_bi := r.m_bi.Clone()
		; m_bi will always be positive so negative values have to be re-assigned
		MfBigMathInt.divide_(x.m_bi, y.m_bi, q.m_bi, r.m_bi)
		q.m_bi := MfBigMathInt.Trim(q.m_bi , 1)
		r.m_bi := MfBigMathInt.Trim(r.m_bi , 1)
		
		rNeg := false
		qNeg := false
		if (x.IsNegative && !y.IsNegative)
		{
			rNeg := true
			qNeg := true
		}
		else if (!x.IsNegative && y.IsNegative)
		{
			rNeg := false
			qNeg := true
		}
		else if (x.IsNegative || y.IsNegative)
		{
			rNeg := true
			qNeg := false
		}
		
		if (qNeg && MfBigMathInt.IsZero(q.m_bi))
		{
			qNeg := false
		}
		if (rNeg && MfBigMathInt.IsZero(r.m_bi))
		{
			rNeg := false
		}
				
		
		if (IsObj)
		{
			remainder.m_bi := r.m_bi.Clone()
			remainder.IsNegative := rNeg
		}
		else
		{
			r.IsNegative := rNeg
			remiander := r.Value
		}
		q.IsNegative := qNeg
		return q
	}
; 	End:DivRem ;}
;{ 	Equals
/*
	Method: Equals()
		Overrides MfObject.Equals()

	OutputVar := instance.Equals(value)

	Equals(value)
		Gets if this instance Value is the same as the obj instance.Value
	Parameters:
		value
			The Object or var containing, integer to compare to current instance.
			Can be var integer representation or any type that matches IsIntegerNumber or MfUInt64 or MfBigInt
	Returns:
		Returns Boolean value of true if this Value and value are equal; Otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method
	Remarks:
		If value is unable to be converted to a MfBigInt then false will be returned.
*/
	Equals(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (x.IsNegative = true && this.IsNegative = true)
		{
			return false
		}
		return MfBigMathInt.Equals(this.m_bi, x.m_bi)
	}
; 	End:Equals ;}
;{ 	GetHashCode - Overrides MfObject.GetHashCode()
/*
	Method: GetHashCode()
		Overrides MfObject.GetHashCode()

	OutputVar := instance.GetHashCode()

	GetHashCode()
		Gets A hash code for the MfBigInt instance.
	Returns:
		A  hash code as var.
	Throws:
		Throws MfNullReferenceException if object is not an instance.
*/
	GetHashCode() {
		str := new MfString(this.Value)
		return str.GetHashCode()
	}
; 	End:GetHashCode ;}
;{ 	GetTypeCode()
/*
	Method: GetTypeCode()

	OutputVar := instance.GetTypeCode()

	GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfBigInt Type Code.
	Returns:
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfBigInt.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.MfBigInt
	}
; End:GetTypeCode() ;}
;{ 	GreaterThen
/*
	Method: GreaterThen()

	OutputVar := instance.GreaterThen(value)

	GreaterThan(value)
		Compares the current MfBigInt object to value and returns an indication of their relative values.
	Parameters:
		value
			The Object or var containing, integer to compare to current instance.
			Can be var integer representation or any type that matches IsIntegerNumber or MfUInt64 or MfBigInt
	Returns:
		Returns true if the current instance has greater value then the value instance; Otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
*/
	GreaterThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (this.IsNegative = true && x.IsNegative = false)
		{
			return false
		}
		if (this.IsNegative = false && x.IsNegative = true)
		{
			return true
		}
		if (this.IsNegative = true && x.IsNegative = true)
		{
			return MfBigMathInt.Greater(x.m_bi, this.m_bi)
		}
		return MfBigMathInt.Greater(this.m_bi, x.m_bi)

	}
; 	End:GreaterThen ;}
/*
	Method: GreaterThenOrEqual()

	OutputVar := instance.GreaterThenOrEqual(value)

	GreaterThenOrEqual(value)
		Compares the current MfBigInt object to value and returns an indication of their relative values.
	Parameters:
		value
			The Object or var containing, integer to compare to current instance.
			Can be var integer representation or any type that matches IsIntegerNumber or MfUInt64 or MfBigInt
	Returns:
		Returns true if the current instance has greater or equal value then the value instance; otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
*/
	GreaterThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (this.IsNegative = true && x.IsNegative = false)
		{
			return false
		}
		if (this.IsNegative = false && x.IsNegative = true)
		{
			return true
		}
		if (MfBigMathInt.Equals(this.m_bi, x.m_bi))
		{
			return true
		}
		if (this.IsNegative = true && x.IsNegative = true)
		{
			return MfBigMathInt.Greater(x.m_bi, this.m_bi)
		}
		return MfBigMathInt.Greater(this.m_bi, x.m_bi)
	}
;{ 	LessThen
/*
	Method: LessThen()

	OutputVar := instance.LessThen(value)

	LessThen(value)
		Compares the current MfBigInt object to value and returns an indication of their relative values.
	Parameters:
		value
			The Object or var containing, integer to compare to current instance.
			Can be var integer representation or any type that matches IsIntegerNumber or MfUInt64 or MfBigInt
	Returns:
		Returns true if the current instance has less value then the value instance; otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
*/
	LessThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (this.IsNegative = true && x.IsNegative = false)
		{
			return true
		}
		if (this.IsNegative = false && x.IsNegative = true)
		{
			return false
		}
		if (this.IsNegative = true && x.IsNegative = true)
		{
			return MfBigMathInt.Greater(this.m_bi, x.m_bi)
		}
		return MfBigMathInt.Greater(x.m_bi, this.m_bi)

	}
; 	End:LessThen ;}
;{ 	LessThenOrEqual
/*
	Method: LessThenOrEqual()

	OutputVar := instance.LessThenOrEqual(value)

	LessThenOrEqual(value)
		Compares the current MfBigInt object to value and returns an indication of their relative values.
	Parameters:
		value
			The Object or var containing, integer to compare to current instance.
			Can be var integer representation or any type that matches IsIntegerNumber or MfUInt64 or MfBigInt
	Returns:
		Returns true if the current instance has less or equal value then the value instance; Otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
*/
	LessThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (this.IsNegative = true && x.IsNegative = false)
		{
			return true
		}
		if (this.IsNegative = false && x.IsNegative = true)
		{
			return false
		}
		if (MfBigMathInt.Equals(this.m_bi, x.m_bi))
		{
			return true
		}
		if (this.IsNegative = true && x.IsNegative = true)
		{
			return MfBigMathInt.Greater(this.m_bi, x.m_bi)
		}
		return MfBigMathInt.Greater(x.m_bi, this.m_bi)

	}
; 	End:LessThenOrEqual ;}
;{ 	Multiply
/*
	Method: Multiply()

	OutputVar := instance.Multiply(value)

	Multiply(value)
		Multiplies the current instance of MfBigInt by the value.
	Parameters:
		value
			The value to multiply the current instance Value by.
			Can be var integer representation or any type that matches IsIntegerNumber or MfUInt64 or MfBigInt
	Returns:
		If ReturnAsObject is true then returns current instance of MfBigInt with an updated Value; Otherwise returns Value as var.
	Throws:
		Throws MfNotSupportedException if ReadOnly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfDivideByZeroException if value is zero.
		Throws MfArithmeticException if the operation fails or value is not an instance of MfBigInt and can not be converted into usable value.
	Remarks:
		If you need to work with decimal/float numbers see MfFloat
	Example:
		i := new MfBigInt(80, true) ; create new MfInt64 and set it RetrunAsObject to value to true
		iNew := new MfBigInt(8)
		MsgBox % i.Multiply(iNew).Value ; displays 640
		MsgBox % i.Add(-5).Value ; displays 635
		MsgBox % i.Add(10).Multiply(2).Value ; displays 1290
		i := new MfBigInt(123, true) ; create new MfInt64 and set it RetrunAsObject to value to true
		MsgBox % i.Multiply("35734895734589734").Multiply("703583085305").Value
		; displays 3092523587861400923100208841010
*/
	Multiply(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(this._IsZero())
		{
			return this._ReturnBigInt()
		}
		
		this._ClearCache()
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(this._IsOne(true))
		{
			if (this.IsNegative)
			{
				x.IsNegative := !x.IsNegative
			}
			this.m_bi := x.m_bi.Clone()
			this.IsNegative := x.IsNegative
			return this._ReturnBigInt()
		}
		if(x._IsOne(true))
		{
			if (x.IsNegative)
			{
				this.IsNegative := !this.IsNegative
			}
			return this._ReturnBigInt()
		}

		if ((x.IsNegative = false && this.IsNegative = false)
			|| (x.IsNegative = true && this.IsNegative = true))
		{
			If (MfBigMathInt.Greater(this.m_bi, x.m_bi))
			{
				bigx := MfBigMathInt.Mult(this.m_bi, x.m_bi)
			}
			Else
			{
				bigx := MfBigMathInt.Mult(x.m_bi, this.m_bi)
			}
			this.m_bi := bigx
			this.IsNegative := False
			return this._ReturnBigInt()
		}
		If (MfBigMathInt.greater(this.m_bi, x.m_bi))
		{
			bigx := MfBigMathInt.Mult(this.m_bi, x.m_bi)
		}
		Else
		{
			bigx := MfBigMathInt.Mult(x.m_bi, this.m_bi)
		}
		this.m_bi := bigx
		this.IsNegative := true
		return this._ReturnBigInt()
	}
; 	End:Multiply ;}
;{ 	Power
	; Raise Value to the power of
	Power(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		
		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(this._IsZero())
		{
			return this._ReturnBigInt()
		}
		if(this._IsOne(true))
		{
			if (this.IsNegative)
			{
				this.IsNegative := False
			}
			return this._ReturnBigInt()
		}
		
		exp := MfInt64.GetValue(value)

		if (exp < 0)
		{
			exp := Abs(exp)
		}
		if (exp = 1)
		{
			return this._ReturnBigInt()
		}
		if (exp = 0)
		{
			this.Value := 1
			return this._ReturnBigInt()
		}
		this._ClearCache()	
		bigX := this.m_bi.Clone()

		i := 1
		while (i < exp)
		{
			this.Multiply(bigX)
			i++
		}
		return this._ReturnBigInt()
	}
; 	End:Power ;}
;{ Subtract
/*
	Method: Subtract()

	OutputVar := instance.Subtract(value)

	Subtract(value)
		Subtracts value from current instance of MfBigInt.
	Parameters:
		value
			The value to subtract from the current instance.
			Can be var integer representation or any type that matches IsIntegerNumber or MfUInt64 or MfBigInt
	Returns:
		If ReturnAsObject is true then returns current instance of MfBigInt with an updated value; Otherwise returns var containing integer.
	Throws:
		Throws MfNotSupportedException if ReadOnly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentException if value is not an instance of MfBigInt and can not be converted into integer value.
*/
	Subtract(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this._ClearCache()
		x := ""
		try
		{
			x := MfBigInt._FromAny(value)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (x.IsNegative = false && this.IsNegative = false)
		{
			If (MfBigMathInt.Equals(this.m_bi, x.m_bi))
			{
				tmp := new MfBigInt(new MfInteger(0))
				this.m_bi := tmp.m_bi
				this.IsNegative := False
				return this._ReturnBigInt()
			}
			If (MfBigMathInt.Greater(this.m_bi, x.m_bi))
			{
				this.m_bi := MfBigMathInt.Sub(this.m_bi, x.m_bi)
			}
			else
			{
				this.m_bi := MfBigMathInt.Sub(x.m_bi,this.m_bi)
				this.IsNegative := true
			}

			return this._ReturnBigInt()
		}
		if (x.IsNegative = true && this.IsNegative = true)
		{
			If (MfBigMathInt.equals(this.m_bi, x.m_bi))
			{
				tmp := new MfBigInt(new MfInteger(0))
				this.m_bi := tmp.m_bi
				this.IsNegative := False
				return this._ReturnBigInt()
			}
			If (MfBigMathInt.Greater(this.m_bi, x.m_bi))
			{
				this.m_bi := MfBigMathInt.Sub(this.m_bi, x.m_bi)
			}
			else
			{
				this.m_bi := MfBigMathInt.Sub(x.m_bi,this.m_bi)
				this.IsNegative := false
			}

			return this._ReturnBigInt()
		}
		if (this.IsNegative != x.IsNegative)
		{
			If (MfBigMathInt.Greater(this.m_bi, x.m_bi))
			{
				this.m_bi := MfBigMathInt.Add(this.m_bi, x.m_bi)
				this.IsNegative := !x.IsNegative
			}
			else
			{
				this.m_bi := MfBigMathInt.Add(x.m_bi,this.m_bi)
				this.IsNegative := !x.IsNegative
			}
			return this._ReturnBigInt()
		}
		return this._ReturnBigInt()
	}
; End:Subtract ;}

;{ 	Parse
/*
	Method: Parse()

	OutputVar := MfBigInt.Parse(s)
	OutputVar := MfBigInt.Parse(s, base)

	MfBigInt.Parse(s)
		Converts the s representation of a number to its MfBigInt equivalent
	Parameters:
		s
			An string var of object convert.
			Can be var or instance of any MfObject derived object that contains numeric value
	Returns:
		Returns MfBigInt instance equivalent to the number contained in s. ReturnAsObject property is set to true.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentNullException if s is null.
		Throws MfFormatException if s in incorrect format.
		Throws MfException for any other errors.
	Remarks:
		Static method
		Sign can be denoted with a leading + or -
		Parse(s) can parse different base string values.
		When s is a string var s can contain the following values after any leading sign to denote base
		0x to denote hex base 16 eg: 0xFC2B4A
		0b to denote binary base 2 eg: +0b1011100101011
		0 to denote octal base 8 eg: 01574364
		When binary value is being parsed and sign is omitted then the the first bit defines negative or positive. 1 denotes negative and 0 denotes positive.


	MfBigInt.Parse(s, base)
		Converts the s representation of a number to its MfBigInt equivalent. Uses base value to decode s.
	Parameters:
		s
			An string var of object convert.
			Can be var or instance of any MfObject derived object that contains numeric value
		base
			The Base that s is encoding in. Base values from 2 to 95 are accepted.
			Can be any type that matches IsInteger or var integer.
	Returns:
		Returns MfBigInt instance equivalent to the number contained in s. ReturnAsObject property is set to true.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentNullException if s is null.
		Throws MfArgumentOutOfRangeException if Base is less then 2 or greater then 95.
		Throws MfFormatException if s in incorrect format.
		Throws MfException for any other errors.
	Remarks:
		Static Method
		Sign can be denoted with a leading + or -
		When binary (base 2) value is being parsed and sign is omitted then the the first bit defines negative or positive. 1 denotes negative and 0 denotes positive.
*/
	Parse(s, base="") {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(s))
		{
			ex := new MfArgumentNullException("s")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(base))
		{
			base := -2
		}
		else
		{
			base := MfInt16.GetValue(base, -2)
		}
		if (base < -2)
		{
			base := -2
		}
		if (base != -2 && (Base < 1 || Base > 95))
		{
			ex := new MfArgumentOutOfRangeException("base", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper", "2", "95"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (MfObject.IsObjInstance(s,  MfListVar))
		{
			retval := new MfBigInt(new MfInteger(0))
			retval.ReturnAsObject := true
			retval.m_bi := s.Clone()
			retval.m_bi := MfBigMathInt.Trim(retval.m_bi, 1)
			return retval
		}
		; base values geater then base 90 the space can be used
		; base values greater then base 93 can use + and - as part of the encoding
		if (base > 90)
		{
			_str := new MfString(MfString.GetValue(s))
			_str.TrimStart()
			strLst := MfListVar.FromString(_str, true) ; include whitespace
		}
		else
		{
			strLst := MfListVar.FromString(s, false) ; ignore whitespace
		}
		
		ll := strLst.m_InnerList
		if (strLst.Count = 0)
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		sign := false
		IsNeg := false
		i := 0
		if (strLst.Item[0] = "-")
		{
			i++
			sign := true
			IsNeg := true
		}
		if (strLst.Item[0] = "+")
		{
			sign := true
			i++
		}
		if (i >= strLst.Count)
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try
		{
			if (base = -2)
			{
				cnt := (strLst.Count - (i + 2))
				if ((cnt >= 2) && strLst.Item[i] = "0")
				{
					c := strLst.Item[i + 1]
					if (c = "x")
					{
						base = 16
					}
					else if (c = "b")
					{
						base := 2
					}
					else
					{
						base = 8
					}
				}
				else
				{
					base := 10
				}
			}
			if (base = 8)
			{
				while (strLst.Item[i] = "0")
				{
					i++
				}
				len := 3 * ((strLst.Count + 1) - i)
			}
			else
			{
				if (base = 16 && strLst.Item[i] = "0" && strLst.Item[i+1] = "x")
				{
					i += 2
				}
				if (base = 2)
				{
					if (strLst.Count > 2 && strLst.Item[i] = "0" && strLst.Item[i+1] = "b")
					{
						i += 2
						if (sign = false)
						{
							sign := true
							if (strLst.Item[i] = "1")
							{
								IsNeg := true
							}
							else
							{
								IsNeg := false
							}
							i++
						}
					}
					else if (strLst.Count > 0)
					{
						if (sign = false)
						{
							sign := true
							if (strLst.Item[i] = "1")
							{
								IsNeg := true
							}
							else
							{
								IsNeg := false
							}
							i++
						}
					}
					else
					{
						ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					if (i >= strLst.Count)
					{
						ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
				}
				
				while (ll[i + 1] = "0")
				{
					i++
				}
				if (i = strLst.Count)
				{
					i--
				}
				len := 4 * ((strLst.Count + 1) - i)
			}
		}
		catch e
		{
			if (MfObject.IsObjInstance(e, MfFormatException))
			{
				throw e
			}
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try
		{
			len := (len >> 4) + 1
			;bigX := MfBigMathInt.Str2bigInt(strLst.ToString("", i), base, len, len)
			if (i > 0)
			{
				bigX := MfBigMathInt.Str2bigInt(strLst.SubList(i), base, len, len)
			}
			else
			{
				bigX := MfBigMathInt.Str2bigInt(strLst, base, len, len)
			}
			
			bigX := MfBigMathInt.Trim(bigX, 1)
			retval := new MfBigInt(new MfInteger(0))
			retval.ReturnAsObject := true
			retval.m_bi := bigX
			retval.m_IsNegative := IsNeg
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
			
		return retval
	}
; 	End:Parse ;}
;{ 	ToString
/*
	Method: ToString()

	OutputVar := instance.ToString()
	OutputVar := instance.ToString(base)

	ToString()
		Gets a string representation of the MfBigInt instance.
	Returns:
		Returns string var representing current instance Value as base 10.
	Throws:
		Throws MfNullReferenceException if called as a static method

	ToString(base)
		Gets a string representation of the MfBigInt instance encode by the value of base.
	Parameters:
		base
			The base value to encode return string as. Base values from 2 to 95 are accepted.
			Can be any type that matches IsInteger or var integer.
	Returns:
		Returns string var representing current instance Value encoded as base.
	Throws:
		Throws MfNullReferenceException if called as a static method.
	Remarks:
		If base equals 2 (binary) then a binary bit will be append to the start of the output. 0 if current instance IsNegative is false; Otherwise 1.
*/
	ToString(base:=10) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		base := MfByte.GetValue(base, 10)
		if (Base < 1 || Base > 95)
		{
			ex := new MfArgumentOutOfRangeException("base", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper", "2", "95"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		s := ""
		if (base = 2)
		{
			if (this.m_IsNegative)
			{
				s := "1"
			}
			else
			{
				s := "0"
			}
		}
		else
		{
			if (this.m_IsNegative)
			{
				s := "-"
			}
		}
			
		s .= MfBigMathInt.BigInt2str(this.m_bi, base)
		return s
	}
; 	End:ToString ;}
; 	End:Methods ;}
;{ 	Internal methods
;{ _ReturnUInt64
	_ReturnBigInt() {
		if (this.m_ReturnAsObject)
		{
			return this
		}
		return this.Value
	}
; End:_ReturnUInt64 ;}
;{ 	_IsZero
	; internal method. Get if the current instance is equal to zero as boolear var
	_IsZero() {
		return MfBigMathInt.IsZero(this.m_bi)
	}
; 	End:_IsZero ;}
;{ 	_IsOne
	; internal method. Get if the current instance is equal to one as boolear var
	_IsOne(IgnoreSign=false) {
		If (IgnoreSign = false && this.IsNegative = true)
		{
			return false
		}
		return MfBigMathInt.Equals(this.m_bi, MfBigMathInt.one)
	}
; 	End:_IsOne ;}
;{ 	_IsNegOne
	; internal method. Get if the current instance is equal to negitive one as boolear var
	_IsNegOne() {
		If (this.IsNegative = true)
		{
			return this._IsOne(true)
		}
		return false
	}
; 	End:_IsNegOne ;}
;{ 	_FromAny
	; static method
	; private method
	_FromAny(x) {
		if (IsObject(x))
		{
			if(MfObject.IsObjInstance(x, MfBigInt))
			{
				return x
			}

			else if (MfObject.IsObjInstance(x, MfListVar))
			{

				retval := new MfBigInt(new MfInteger(0))
				retval.m_bi := MfBigMathInt.Trim(x, 1)
				return retval
			}
			else if (MfObject.IsObjInstance(x, MfUInt64))
			{
				retval := new MfBigInt(x)
				return retval
			}
			else if (MfObject.IsObjInstance(x, MfObject))
			{
				x := MfBigInt.Parse(x)
			}
			else
			{
				return new MfBigInt(new MfInteger(0))
			}
		}
		num := MfInt64.GetValue(x,"NaN", true)
		if (num == "NaN")
		{
			return MfBigInt.Parse(x)
		}
		if((num >= -2147483647) && (num <= 2147483647))
		{
			return MfBigInt._fromInt(num)
		}
		num := format("{:i}", num)
		return MfBigInt.Parse(num)
	}
; 	End:_FromAny ;}
;{ 	_FromAnyConstructor
	; Internal Instance method used by constructor
	_FromAnyConstructor(x) {
		this._ClearCache()
		if (IsObject(x))
		{
			if(MfObject.IsObjInstance(x, MfBigInt))
			{
				this.m_bi := x.m_bi.Clone()
				this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
				this.m_IsNegative := x.IsNegative
			}
			else if (MfObject.IsObjInstance(x, MfListVar))
			{
				this.m_bi := x.Clone()
				this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
			}
			else if (MfObject.IsObjInstance(x, MfInteger))
			{
				; adding as MfInteger is necessary so methods like parse can create a new instance
				; of MfbigInt without going into a recursion loop using vars, as you can see below
				; unknow objects attempt to use parse to create a new instance
				varx := x.Value
				IsNeg := false
				if (varx < 0)
				{
					IsNeg := true
					varx := Abs(varx)
				}
				this.m_bi := MfBigMathInt.Str2bigInt(format("{:i}",varx), 10, 2, 2)
				this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
				this.m_IsNegative := IsNeg
			}
			else if (MfObject.IsObjInstance(x, MfUInt64))
			{
				xClone := x.m_bigx.Clone()
				this.m_bi := xClone.m_bi
				this.m_bi := MfBigMathInt.Trim(this.m_bi, 1)
				this.m_IsNegative := false
			}
			else if (MfObject.IsObjInstance(x, "StringBuilder"))
			{
				return this._FromAnyConstructor(x.ToString())
			}
			else if (MfObject.IsObjInstance(x, MfObject))
			{
				x := MfBigInt.Parse(x)
				this.m_bi := x.m_bi.Clone()
				this.m_IsNegative := x.IsNegative
			}
			else
			{
				this.m_bi := new MfListVar(3)
			}
			return
		}
		
		num := MfInt64.GetValue(x,"NaN", true)
		if (num == "NaN")
		{
			x := MfBigInt.Parse(x)
			this.m_bi := x.m_bi.Clone()
			this.m_IsNegative := x.IsNegative
			return
		}
		if (num = 0)
		{
			this.m_bi := new MfListVar(2)
			Return
		}
		if((num >= -2147483647) && (num <= 2147483647))
		{
			x := MfBigInt._fromInt(num)
			this.m_bi := x.m_bi.Clone()
			this.m_IsNegative := x.IsNegative
			return
		}
		num := format("{:i}", num)
		x := MfBigInt.Parse(num)
		this.m_bi := x.m_bi.Clone()
		this.m_IsNegative := x.IsNegative
		return
	}
; 	End:_FromAnyConstructor ;}
;{ 	_fromInt
	_fromInt(n) {
		retval := new MfBigInt(new MfInteger(0))
		if (n < 0)
		{
			retval.IsNegative := true
			n := -n
		}
		Else
		{
			retval.IsNegative := false
		}

		retval.m_bi := MfBigMathInt.Int2bigInt(n, 31, 4)
		retval.m_bi := MfBigMathInt.Trim(retval.m_bi, 1)
		return retval
	}
; 	End:_fromInt ;}
;{ 	_VerifyReadOnly
	_VerifyReadOnly(args*) {
		; args: [ClassName, LineFile, LineNumber, Source]
		if (this.ReadOnly)
		{
			p := this._VerifyReadOnlyParams(args*)
			ClassName := this.__Class
			LineFile := A_LineFile
			LineNumber := A_LineNumber
			Source := A_ThisFunc

			mfgP := p.ToStringList()
			for i, str in mfgP
			{
				if (i = 0) ; classname
				{
					if (str.Value = "MfString")
					{
						ClassName := p.Item[i].Value
					}
					else if (str.Value != Undefined)
					{
						ClassName := MfType.TypeOfName(p.Item[i])
					}
					
				}
				else if ((i = 1) && (str.Value = "MfString")) ; LineFile
				{
					LineFile := p.Item[i].Value
				}
				else if ((i = 2) && (str.Value = "MfInteger")) ; LineNumber
				{
					LineNumber := p.Item[i].Value
				}
				else if (i = 3) ; source
				{
					if (str.Value = "MfString")
					{
						Source := p.Item[i].Value
					}
					else if (str.Value != Undefined)
					{
						Source := p.Item[i]
					}
				}
			}

			if (MfString.IsNullOrEmpty(ClassName))
			{
				msg := MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Instance")
			}
			Else
			{
				msg := MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Instance_Class", ClassName)
			}

			ex := new MfNotSupportedException(msg)
			ex.SetProp(LineFile, LineNumber, Source)
			throw ex
		}
		return true
	}
; 	End:_VerifyReadOnly ;}
;{ _VerifyReadOnlyParams
	_VerifyReadOnlyParams(args*) {
		; args: [MethodName, LineFile, LineNumber, Source]
		p := Null
		cnt := MfParams.GetArgCount(args*)
		if (MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			if (p.Count > 4)
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else
		{
			p := new MfParams()
			p.AllowEmptyString := true ; allow empty strings to be compared
			p.AllowOnlyAhkObj := false
			p.AllowEmptyValue := true ; all empty/null params will be added as undefined
			
			if (cnt > 4)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
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
						if ((i = 3) && (MfNull.IsNull(arg) = false)) ; Integer A_LineNumber
						{
							p.AddInteger(arg)
						}
						else
						{
							pIndex := p.Add(arg)
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
		return p
	}
; End:_VerifyReadOnlyParams ;}
;{ _ErrorCheckParameter
/*
		Method: _ErrorCheckParameter(index, pArgs[, AllowUndefined = true])
			_ErrorCheckParameter() Chekes to see if the Item of pArgs at the given index is undefined or otherwise
		Parameters:
			index - The index with pArgs to use
			pArgs - The instance of MfParams that contains the Parameters
			AllowUndefined - If True then pArg Item at index can be undefined otherwse will an error will be thrown
		Returns:
			Returns MfArgumentException if item at index in pArgs does not pass set conditions. Otherwise False
		Remarks
			This method is intended to be use internally only and accessed in derived classes such as MfString,
			MfByte, MfInteger, MfInt64, MfChar
*/
	_ErrorCheckParameter(index, pArgs, AllowUndefined = true) {
		ThrowErr := False
		if((!IsObject(pArgs.Item[index]))
			&& (pArgs.Item[index] = Undefined))
		{
			if (AllowUndefined = true)
			{
				return ThrowErr
			}
			ThrowErr := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", (index + 1)))
			ThrowErr.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			return ThrowErr
		}
		
		ThrowErr := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", (index + 1)))
		ThrowErr.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		return ThrowErr
	}
; End:_ErrorCheckParameter ;}
; 	End:Internal methods ;}
;{ Properties
	;{ BitSize
		m_BitSize := ""
/*
	Property: BitSize [get]
		Gets the number of bytes associated with the current instance.
	Value:
		Var integer
	Gets:
		Gets the number of bytes associated with the current instance.
	Remarks:
		Readonly property
	Example:
		bigI := new MfBigInt("165798798456464561378674845676875311568784564")
		MsgBox % bigI.BitSize ; displays 147
		bigI.Multiply("123456")
		MsgBox % bigI.Value ; displays 20468856462241288889565681747884318465035867133184
		MsgBox % bigI.BitSize ; displays 164
*/
		BitSize[]
		{
			get {
				if (this.m_BitSize = "")
				{
					this.m_BitSize := MfBigMathInt.BitSize(this.m_bi)
				}
				return this.m_BitSize
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "BitSize")
				Throw ex
			}
		}
	; End:BitSize ;}
;{ InnerList
/*
	Property: InnerList [get]
		Gets the number of bytes associated with the current instance.
	Value:
		Instance of MfListVar.
	Gets:
		Gets the InnerList value associated with the this instance.
	Remarks:
		Readonly property.
		MfBigInt value is stored internally as a list of integer values that change as the underlying value changes.
		InnerList will always represent the value of the current instance of MfBigInt as a Positive number.
		IsNegative determines if the value of the current instance is positive or negative.
*/
	InnerList[]
	{
		get {
			return this.m_bi
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "InnerList")
			Throw ex
		}
	}
; End:InnerList ;}
;{ IsNegative
	m_IsNegative := false
/*
	Property: IsNegative [get\set]
		Gets or sets the if the MfBigInt instance is positive or negative.
	Value:
		Boolean true or false. Can be var or instance of MfBool.
	Gets:
		Gets a boolean var of True or False representing the state of IsNegative.
	Sets:
		Set the state of IsNegative to True or False.
	Remarks:
		If this property is set to true then the MfBigInt instance will be considerer a negative value; Otherwise instance will be considered positive.
	Example:
		bigI := new MfBigInt("165798798456464561378674845676875311568784564")
		MsgBox % bigI.Value ; displays 165798798456464561378674845676875311568784564
		bigI.IsNegative := true ; change value from Positive to Negative
		MsgBox % bigI.Value ; displays -165798798456464561378674845676875311568784564
*/
	IsNegative[]
	{
		get {
			return this.m_IsNegative
		}
		set {
			this.m_IsNegative := MfBool.GetValue(value, false)
			this._ClearCache()
			return this.m_IsNegative
		}
	}
; End:IsNegative ;}
;{	ReadOnly
	m_ReadOnly := false
/*
	Property: Readonly [get]
		Gets the if the instance will allow the underlying value to be altered after the constructor has been called.
	Value:
		Boolean representing true or false.
	Gets:
		Gets a boolean value indicating if the derived class will allow the underlying value to be altered after the constructor has been called.
	Remarks:
		Readonly property
		Default value is false. This property only be set in the constructor of the derive class.
*/
	ReadOnly[]
	{
		get {
			return this.m_ReadOnly
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:ReadOnly ;}
;{ ReturnAsObject
	m_ReturnAsObject := false
/*
	Property: ReturnAsObject [get\set]
		Gets or sets the if the MfBigInt class will return objects as their return value for various functions
	Value:
		Boolean representing true or false. Can be var or instance of MfBool.
	Gets:
		Gets a boolean var of True or False representing the state of ReturnAsObject.
	Sets:
		Set the state of ReturnAsObject to True or False.
	Remarks:
		If this property is set to true then the MfBigInt class will return an an MfBigInt instance on methods and
		Properties that are applicable. If false the MfBigInt class will return var (non objects) containing integer.
*/
	ReturnAsObject[]
	{
		get {
			return this.m_ReturnAsObject
		}
		set {
			this.m_ReturnAsObject := MfBool.GetValue(value)
			return this.m_ReturnAsObject
		}
	}
; End:ReturnAsObject ;}
	strValue := ""
;{ Value
/*
	Property: Value [get\set]
		Gets or sets the value associated with the this instance of MfBigInt
	Value:
		Value is a string and can be var or any type that matches IsIntegerNumber or MfUInt64 or MfBigInt
	Gets:
		Gets integer Value as var string.
	Sets:
		Set the Value of the instance
	Throws:
		Throws MfNotSupportedException on set if Readonly is true.
		Throws MfArgumentException for other errors.
	Example:
		bigI := new MfBigInt("165798798456464561378674845676875311568784564")
		MsgBox % bigI.Value ; displays 165798798456464561378674845676875311568784564
		bigI.Value := "-5903459034583453590"
		MsgBox % bigI.Value ; displays -5903459034583453590
*/
	Value[]
	{
		get {
			if (this.strValue = "")
			{
				this.strValue := this.ToString()
			}
			return this.strValue
		}
		set {
			this._FromAnyConstructor(value)
		}
	}
; End:Value ;}
; End:Properties ;}
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
}