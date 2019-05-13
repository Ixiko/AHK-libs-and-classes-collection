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
; Represents Unsigned Integer 64 bit object
Class MfUInt64 extends MfPrimitive
{
	m_bigx := ""
;{ Static Properties
	TypeCode[]
	{
		get {
			return 26
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}

; End:Static Properties ;}
;{ Constructor
/*
	Method: Constructor()
		Initializes a new instance of the MfUInt64 class.

	OutputVar := new MfUInt64([int, returnAsObj, readonly])

	Constructor([int, retunAsObj, readonly])
		Initializes a new instance of the MfUInt64 class optionally setting the Value property, ReturnAsObject property and the Readonly property.
	Parameters:
		int
			The MfUInt64 object, var containing integer or string of integer numbers to create a new instance with.
			Can be any type that matches IsNumber, var integer or var string of integer numbers.
		returnAsObj
			Determines if the current instance of MfUInt64 class will return MfUInt64 instances from functions or vars containing integer. If omitted value is false
		readonly
			Determines if the current instance of MfUInt64 class will allow its Value to be altered after it is constructed.
			The Readonly property will reflect this value after the class is constructed.
			If omitted value is false
	Throws:
		Throws MfNotSupportedException if class is extended.
		Throws MfArgumentException if error in parameter.
		Throws MfNotSupportedException if incorrect type of parameters or incorrect number of parameters.
	Remarks:
		Sealed Class.
		This constructor initializes the MfUInt64 with the integer value of int.
		Value property to the value of int.
		ReturnAsObject will have a value of returnAsObj
		Readonly will have a value of readonly.
		If Readonly is true then any attempt to change the underlying value will result in MfNotSupportedException being thrown.
		AutoHotkey has a integer upper limit of MfInt64.MaxValue. MfUInt64 can have greater values up to MfUInt.MaxValue. For this reason any integer greater then MfInt64.MaxValue need to be wrapped in double quotes "" eg i := new MfUInt64("9223372036854775900"). It is recommended to wrap all var value for int in double quotes as a precaution.
*/
	__New(args*) {
		if (this.__Class != "MfUInt64")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfUInt64"))
		}


		_returnAsObject := false
		_readonly := false

		pArgs := this._ConstructorParams(A_ThisFunc, args*)

		pList := pArgs.ToStringList()
		s := Null
		pIndex := 0
		if (pList.Count > 0)
		{
			varx := pArgs.Item[pIndex]
			if(MfNull.IsNull(varx) || varx == Undefined)
			{
				varx := 0
			}
			bigx := new MFBigInt(varx)
			if (bigx.IsNegative || MfUInt64._IsGreaterThenMax(bigx))
			{
				ex := new MfArgumentOutOfRangeException("varInt"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
					,MfUInt64.MinValue, MfUInt64.MaxValue))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.m_bigx := bigx
		}
		if (pList.Count > 1)
		{
			pIndex++
			s := pList.Item[pIndex].Value
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
	
		base.__New(_int, _returnAsObject, _readonly)
		this.m_isInherited := false
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
						else if (i = 1) ; uint64
						{
							pIndex := p.AddString(arg)							
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
/*
	Method: Add()
	Add(value)
		Adds MfUInt64 value to current instance of MfUInt64.
	Parameters:
		value
			The value to add to the current instance.
			Can be any type that matches IsNumber, var integer or var string of integer numbers.
	Returns:
		If ReturnAsObject is true then returns current instance of MfUInt64 with an updated value; Otherwise returns var
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentException if value is not an instance of MfUInt64 and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if adding value is less then MinValue and greater than MaxValue
	Remarks:
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
		When adding value greater then MfInt64.MaxValue the values must be enclosed in "" and passed as a string as shown in the last
		part of the example below. AutoHotkey has an integer upper limit of MfInt64.MaxValue. As a precaution all integer values passed
		into MfUInt64 methods can be wrapped in double quotes. eg: i := new MfUInt64("10", true)
	Example:
		i := new MfUInt64(10, true) ; create new MfUInt64 and set it RetrunAsObject to value to true
		i.Add(2)
		iNew := new MfUInt64(8)
		MsgBox % i.Add(iNew).Value                   ; displays 20
		MsgBox % i.Add(-10).Value                    ; displays 10
		MsgBox % i.Add(10).Add(10).Value             ; displays 30
		MsgBox % i.Add("18446744073709551515").Value ; displays 18446744073709551545

*/
	Add(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bigx := new MfBigInt(value)
		bigx.Add(this.m_bigx)
		if (bigx.IsNegative || MfUInt64._IsGreaterThenMax(bigx))
		{
			ex := new MfArgumentOutOfRangeException("varInt"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				,MfUInt64.MinValue, MfUInt64.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_bigx := bigx

		return this._ReturnUInt64(this)
	}
;{ 	CompareTo()			- Overrides	- MfObject
/*
	Method: CompareTo()
		Overrides MfObject.CompareTo

	OutputVar := instance.CompareTo(obj)

	CompareTo(obj)
		Compares this instance to a specified MfUInt64 instance.
	Parameters:
		obj
			A MfUInt64 object to compare to current instance.
	Returns:
		Returns a var containing integer indicating the position of this instance in the sort order in relation to the value parameter.
		Return Value Description Less than zero This instance precedes obj value. Zero This instance has the same position in the sort order as value.
		Greater than zero This instance follows
	Throws:
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfUInt64.
	Remarks:
		Compares this instance to a specified MfUInt64 instance and indicates whether this instance precedes, follows, or appears in the same
		position in the sort order as the specified MfUInt64 instance.
*/
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			return 1
		}
		bigx := new MfBigInt(obj)
		return this.m_bigx.CompareTo(bigx)
		
	}
; End:CompareTo(c) ;}
;{ 	Clone
	Clone() {
		uint := new MfUInt64(0)
		uint.m_bigx := this.m_bigx.Clone()
		return uint
	}
; 	End:Clone ;}
;{ 	Divide
/*
	Method: Divide()

	OutputVar := instance.Divide(value)

	Divide(value)
		Divides the current instance of MfUInt64 by the divisor value.
	Parameters:
		value
			The Divisor value to divide the current instance Value by.
			Can be any type that matches IsNumber, var integer or var string of integer numbers.
	Returns:
		If ReturnAsObject is true then returns current instance of MfUInt64 with an updated Value; Otherwise returns Value as var.
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfDivideByZeroException if value is zero.
		Throws MfArithmeticException if the operation fails or value is not an instance of MfUInt64 and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if dividing result is less then MinValue and greater than MaxValue
	Remarks:
		When value greater then MfInt64.MaxValue the values must be enclosed in "" and passed as a string as shown in the example below.
		AutoHotkey has an integer upper limit of MfInt64.MaxValue. As a precaution all integer values passed into MfUInt64 methods
		can be wrapped in double quotes. eg: i := new MfUInt64("10", true)
		If the result of the operation is not a whole number such as 4/2 but rather a float number such as 8/3 (8/3 = 2.6666...) then
		the result will always be the whole number portion of the operation.
		For example:
			mfInt := new MfUInt64(8)
			MsgBox % mfInt.Divide(3) ; displays 2

		If you need to work with decimal/float numbers see MfFloat
	Example:
		i := new MfUInt64(MfUInt64.MaxValue, true) ; create new MfUInt64 at max value and set it RetrunAsObject to value to true
		iNew := new MfUInt64("8")
		MsgBox % i.Divide(iNew).Value          ; displays 2305843009213693951
		MsgBox % i.Add(-5).Value               ; displays 2305843009213693946
		MsgBox % i.Add("10").Divide("2").Value ; displays 1152921504606846978

*/
	Divide(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this._IsZero())
		{
			return this
		}
		bigx := this.m_bigx.Clone()
		xValue := new MfBigInt(value)
		bigx.Divide(xValue)
		if (bigx.IsNegative)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this._IsGreaterThenMax(bigx))
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_bigx := bigx
		return this._ReturnUInt64(this)

	}
; 	End:Divide ;}
;{ 	Equals()			- Overrides - MfObject
/*
	Method: Equals()
		Overrides MfObject.Equals()

	OutputVar := instance.Equals(value)

	Equals(value)
		Gets if this instance Value is the same as the obj instance.Value
	Parameters:
		value
			The Object or var containing, integer to compare to current instance.
			Can be any type that matches IsNumber, var integer or var string of integer numbers.
	Returns:
		Returns Boolean value of true if this Value and value are equal; Otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method
	Remarks:
		If value is unable to be converted to a integer then false will be returned.
		AutoHotkey has an integer upper limit of MfInt64.MaxValue. As a precaution all integer values passed into
		MfUInt64 methods can be wrapped in double quotes. eg: i := new MfUInt64("10", true)
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
*/
	Equals(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			return false
		}
		bigx := new MfBigInt(value)
		return this.m_bigx.Equals(bigx)
	}
; 	End:Equals ;}
;{ 	GetHashCode()		- Overrides	- MfObject
/*
	Method: GetHashCode()
		Overrides MfObject.GetHashCode()

	OutputVar := instance.GetHashCode()

	GetHashCode()
		Gets A hash code for the MfUInt64 instance.
	Returns:
		A 32-bit signed integer hash code as var.
	Throws:
		Throws MfNullReferenceException if object is not an instance.
*/
	GetHashCode() {
		i := MfCast.ToInt32(this, false)
		uint := this.Clone()
		uint.BitShiftRight(32)
		iShift := MfCast.ToInt32(uint, false)
		return i ^ iShift
	}
; End:GetHashCode() ;}
;{ 	GetTypeCode()
/*
	Method: GetTypeCode()

	OutputVar := instance.GetTypeCode()

	GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfUInt64 Type Code.
	Returns:
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfUInt64.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.UInt64
	}
; End:GetTypeCode() ;}
;{ 	GetValue()			- Overrides	- MfPrimitive
/*
	Method: GetValue()
		Overrides MfPrimitive.GetValue().

	OutputVar := MfUInt64.GetValue(Obj)
	OutputVar := MfUInt64.GetValue(Obj, Default)
	OutputVar := MfUInt64.GetValue(Obj, Default, AllowAny)

	MfUInt64.GetValue(Obj)
		Gets the integer number from Object or var containing integer.
	Parameters:
		Obj
			The Object or var containing, integer or hex value
			Can be any type that matches IsNumber, var integer or var string of integer numbers.
	Returns:
		Returns a var containing a integer No less then MinValue and no greater then MaxValue.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentOutOfRangeException if Obj is less then MinValue or Greater then MaxValue.
		Throws MfArgumentException if argument Obj is can not be converted to integer value.
	Remarks:
		Static Method
		AutoHotkey has an integer upper limit of MfInt64.MaxValue. As a precaution all integer values passed into MfUInt64 methods can be wrapped
		in double quotes. eg: i := new MfUInt64("10", true)
		Throws an error if unable to convert Obj to integer.
		
	MfUInt64.GetValue(Obj, Default)
		Gets a integer number from Obj or returns Default value if Obj is unable to be converted to integer. Default must be a value that can be
		converted to integer or it will be ignored if Obj can not be converted to integer and an error will be thrown.
	Parameters:
		Obj
			The Object or var containing, integer or hex value
			Can be any type that matches IsNumber, var integer or var string of integer numbers.
		Default
			The value to return if Obj is Cannot be converted
			Can be any type that matches IsIntegerNumber or var of integer.
	Returns:
		Returns a var containing a integer or Default value if Obj is unable to be converted to integer.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
	Remarks:
		Static Method
		AutoHotkey has an integer upper limit of MfInt64.MaxValue. As a precaution all integer values passed into MfUInt64 methods can be wrapped
		in double quotes. eg: i := new MfUInt64("10", true)
		If Default is not a valid integer or MfUInt64 instance then GetValue will throw an error if Obj can not be converted to integer.
		If Default can not be converted to a integer then this would method will yield the same results as calling MfUInt64.GetValue(Obj).

	MfUInt64.GetValue(Obj, Default, AllowAny)
		Gets a integer number from Obj or returns Default value if Obj is unable to be converted to integer.
	Parameters:
		Obj
			The Object or var containing, integer or hex value
			Can be any type that matches IsNumber, var integer or var string of integer numbers.
		Default
			The value to return if Obj is Cannot be converted
			Can be any type that matches IsIntegerNumber or var of integer.
		AlowAny
			Determines if Default can be a value other then integer. If true Default can be any var, Object or null; Otherwise Default must be a integer value.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentException if AllowAny is not a valid boolean.
	Remarks:
		Static Method.
		AutoHotkey has an integer upper limit of MfInt64.MaxValue. As a precaution all integer values passed into MfUInt64 methods can be wrapped
		in double quotes. eg: i := new MfUInt64("10", true)
		If AllowAny is true then Default can be any value including var, object or null. However if AllowAny is false then this method will yield
		the same result as calling MfUInt64.GetValue(Obj, Default).
	General Remarks:
		If Obj is a float or MfFloat instance then GetValue() will alway round down for positive number and round up for negative numbers.
		For instance MfInteger.GetValue(2.8) will be 2 and MfInteger.GetValue(-2.8) will be -2.
		Throws MfNotSupportedException if incorrect number of parameters are passed in.
*/
	GetValue(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		;obj, default=0, AllowAny=false
		i := 0
		for index, arg in args
		{
			i++
		}
		if ((i = 0) || (i > 3))
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		CanThrow := False
		bAllow := False
		_default := 0
		obj := args[1]
		if (i = 1)
		{
			CanThrow := True
		}
		else if (i = 2)
		{
			_default := MfUint64._GetValue(args[2], false)
			If (_default == "NaN")
			{
				CanThrow := true
			}
			else
			{
				CanThrow := false
			}
		}
		else
		{
			; 3 params obj, default, AllowAny
			; if AllowAny is true then default can be anything, otherwise default must be a valid integer
			try
			{
				bAllow := MfBool._GetValue(args[3])
			}
			catch e
			{
				err := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBoolean"), e)
				err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "AllowAny", err)
				ex.SetProp(err.File, err.Line, A_ThisFunc)
				throw ex
			}
			
			if (bAllow = true)
			{
				_default := args[2]
			}
			else
			{
				_default := MfUint64._GetValue(args[2], false)
				if (_default == "NaN")
				{
					CanThrow := true
				}
				else
				{
					CanThrow := false
				}
			}
		}
		retval := 0
		if (CanThrow = true)
		{
			try
			{
				retval := MfUint64._GetValue(obj)
			}
			catch e
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToUInt64"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else
		{
			retval := MfUint64._GetValue(obj, false)
			if (retval == "NaN")
			{
				return _default
			}
			return retval
		}
		return retval
	}
; End:GetValue() ;}	
;{ 	_GetValue
	_GetValue(obj, CanThrow=true) {
		retval := 0
		if (IsObject(obj)) {
			if (MfObject.IsObjInstance(obj, MfUInt64))
			{
				return obj.Value
			}
			T := new MfType(obj)
			if (T.IsIntegerNumber)
			{
				if (obj.LessThen(0))
				{
					if (!CanThrow)
					{
						return "NaN"
					}
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", "obj"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				return obj.Value
			}
			else if (t.IsFloat)
			{
				return MfUint64._GetValueFromVar(obj.Value, CanThrow)
			}
			else
			{
				if (!CanThrow)
				{
					return "NaN"
				}
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", "obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else {
			retval := MfUint64._GetValueFromVar(obj, CanThrow)
		}
		return retval
	}
; 	End:_GetValue ;}
; 	End:_GetValue ;}
;{ 	_GetValueFromVar
	_GetValueFromVar(varInt, CanThrow=true) {
		; in most cases MfInt64 can likely handele the getvalue and it is faster
		result := MfInt64.GetValue(varInt, "NaN", true)
		if (result != "NaN")
		{
			if (result >= 0)
			{
				return result
			}
			if (!CanThrow)
			{
				return "NaN"
			}
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		dotIndex := InStr(varInt, ".") - 1
		if (dotIndex > 0)
		{
			varInt := SubStr(varInt, 1, dotIndex) ; drop decimal portion
		}

		bigx := MfBigInt.Parse(varInt)

		if (bigx.IsNegative)
		{
			if (!CanThrow)
			{
				return "NaN"
			}
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (bigx._IsZero())
		{
			; if zero then error must have occured
			; 0 values would have been handled already by MfInt64.GetValue above
			if (!CanThrow)
			{
				return "NaN"
			}
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticException"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (bigx.GreaterThen(MfUInt64.MaxValue))
		{
			if (!CanThrow)
			{
				return "NaN"
			}
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return bigx.Value
	}
; 	End:_GetValueFromVar ;}
;{ 	GreaterThen
/*
	Method: GreaterThen()

	OutputVar := instance.GreaterThen(value)

	GreaterThan(value)
		Compares the current MfUInt64 object to a specified MfUInt64 instance and returns an indication of their relative values.
	Parameters:
		value
			The Object or var containing, integer to compare to current instance.
			Can be any type that matches IsNumber, var integer or var string of integer numbers.
	Returns:
		Returns true if the current instance has greater value then the value instance; Otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfUInt64 and can not be converted into integer value.
	Remarks:
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
*/
	GreaterThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfUInt64)) {
			_value1 := this.Value
			_value2 := value.Value
			return this._CompareLongIntStrings(_value1, _value2) > 0
		}
		try
		{
			_value1 := this.Value
			_value2 :=  MfUInt64.GetValue(value)
			retval := this._CompareLongIntStrings(_value1, _value2) > 0
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; 	End:GreaterThen ;}
;{ 	GreaterThenOrEqual
/*
	Method: GreaterThenOrEqual()

	OutputVar := instance.GreaterThenOrEqual(value)

	GreaterThenOrEqual(value)
		Compares the current MfUInt64 object to a specified MfUInt64 object and returns an indication of their relative values.
	Parameters:
		value
			The Object or var containing, integer to compare to current instance.
			Can be any type that matches IsNumber, var integer or var string of integer numbers.
	Returns:
		Returns true if the current instance has greater or equal value then the value instance; otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfUInt64 and can not be converted into integer value.
	Remarks:
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
*/
	GreaterThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		
		try
		{
			bigx := new MfBigInt(value)
			return this.m_bigx.GreaterThenOrEqual(bigx)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:GreaterThenOrEqual ;}
;{ 	LessThen
	LessThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		
		try
		{
			bigx := new MfBigInt(value)
			return this.m_bigx.LessThen(bigx)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:LessThen ;}
;{ 	LessThenOrEqual
/*
	Method: LessThen()

	OutputVar := instance.LessThen(value)

	LessThen(value)
		Compares the current MfUInt64 object to a specified MfUInt64 object and returns an indication of their relative values.
	Parameters:
		value
			The Object or var containing, integer to compare to current instance.
			Can be any type that matches IsNumber, var integer or var string of integer numbers.
	Returns:
		Returns true if the current instance has less value then the value instance; otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfUInt64 and can not be converted into integer value.
	Remarks:
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
*/
	LessThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		
		try
		{
			bigx := new MfBigInt(value)
			return this.m_bigx.LessThenOrEqual(bigx)
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:LessThenOrEqual ;}
;{ 	Multiply
/*
	Method: Multiply()

	OutputVar := instance.Multiply(value)

	Multiply(value)
		Multiplies the current instance of MfUInt64 by the value.
	Parameters:
		value
			The value to multiply the current instance Value by.
			Can be any type that matches IsNumber, var integer or var string of integer numbers.
	Returns:
		If ReturnAsObject is true then returns current instance of MfUInt64 with an updated Value; Otherwise returns Value as var.
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfDivideByZeroException if value is zero.
		Throws MfArithmeticException if the operation fails or value is not an instance of MfUInt64 and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if dividing result is less then MinValue and greater than MaxValue
	Remarks:
		When multiplying value greater then MfInt64.MaxValue the values must be enclosed in "" and passed as a string.
		AutoHotkey has an integer upper limit of MfInt64.MaxValue. As a precaution all integer values passed into MfUInt64
		methods can be wrapped in double quotes. eg: i := new MfUInt64("10", true)
		If the result of the operation is not a whole number such as 4*3 but rather a float number such as 4*3.3 (4 * 3.2 = 13.2)
		then the result will always be the whole number portion of the operation.
		For example:
			mfInt := new MfUInt64(4)
			MsgBox % mfInt.Multiply(3.2) ; displays 12
		If you need to work with decimal/float numbers see MfFloat
*/
	Multiply(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this._IsZero())
		{
			return this
		}
		bigx := new MfBigInt(value)
		if(bigx._IsOne(false) = true)
		{
			return this
		}
		if (bigx._IsZero())
		{
			this.m_bigx := bigx
			return this
		}
		bigx.Multiply(this.m_bigx)
		if (bigx.IsNegative)
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionUnder"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this._IsGreaterThenMax(bigx))
		{
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Arg_ArithmeticExceptionOver"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_bigx := bigx
		return this._ReturnUInt64(this)

	}
; 	End:Multiply ;}
;{ 	Parse()
/*
	Method: Parse()

	OutputVar := MfUInt64.Parse(s)
	OutputVar := MfUInt64.Parse(s, style)
	OutputVar := MfUInt64.Parse(s, provider)
	OutputVar := MfUInt64.Parse(s, style, provider)

	MfUInt64.Parse(s)
		Converts the s representation of a number to its MfUInt64 equivalent
	Parameters:
		s
			An string var of object convert.
			Can be var or instance of MfChar, MfString
	Returns:
		Returns MfUInt64 instance equivalent to the number contained in s.
	Throws:
		Throws MfArgumentNullException if s is null.
		Throws MfFormatException if s is not of the correct format.
		Throws MfOverFlowExcpetion s represents a number less than MinValue or greater than MaxValue.
	Remarks:
		Static method
		The s parameter contains a number of the form:
		[ws][sign]digits[ws]
		Elements in square brackets ([ and ]) are optional. The following table describes each element.

		Element		Description
		ws			Optional white space.
		sign		An optional positive or negative sign.
		digits		A sequence of digits ranging from 0 to 9
		
		The s parameter is interpreted using the MfNumberStyles.Integer style. In addition to the byte value's decimal digits,
		only leading and trailing spaces together with a leading sign are allowed. (If the sign is present, it must be a positive sign or
		the method throws an MfOverFlowExcpetion.)
		To explicitly define the style elements that can be present in s, use either the MfUInt64.Parse(s, style) or
		the MfUInt64.Parse(s, style, provider) method.
		The s parameter is parsed using the formatting information in a MfNumberFormatInfo object.
		To parse a string using other formatting information, use the MfUInt64.Parse(s, style, provider) method.

	Method: MfUInt64.Parse(s, style)
		Converts the s representation of a number to its MfUInt64 equivalent
		s
		An string var of object convert.
		Can be var or instance of MfChar, MfString
		style
		MfNumberStyles Instance or Integer var representing instance.
		A bitwise combination of MfNumberStyles values that indicates the style elements that can be present in s.
		A typical value to specify is MfNumberStyles.Integer.
	Returns:
		Returns MfUInt32 instance equivalent to the number contained in s.
	Throws:
		Throws MfInvalidOperationException if not called as static method.
		Throws MfArgumentNullException if s is null.
		Throws MfFormatException if s is not of the correct format.
		Throws MfOverFlowExcpetion s represents a number less than MinValue or greater than MaxValue.
		Throws MfArgumentException style is not a MfNumberStyles value.
		-or-
		style is not a combination of MfNumberStyles.AllowHexSpecifier and MfNumberStyles.HexNumber values.
	Remarks:
		Static method
		The style parameter defines the style elements (such as white space or the positive sign) that are allowed in the s parameter
		for the parse operation to succeed. It must be a combination of bit flags from the MfNumberStyles enumeration. Depending on the value of style,
		the s parameter may include the following elements:
		
		[ws][$][sign]digits[.fractional_digits][e[sign]digits][ws]
		Elements in square brackets ([ and ]) are optional. The following table describes each element.
		Element				Description
		ws					Optional white space. White space can appear at the beginning of s if style includes the
							MfNumberStyles.AllowLeadingWhite flag, or at the end of s if style includes the MfNumberStyles.AllowTrailingWhite flag.
		$					A currency symbol. Its position in the string is defined by the MfNumberFormatInfo.CurrencyPositivePattern property.
							The current culture's currency symbol can appear in s if style includes the MfNumberStyles.AllowCurrencySymbol flag.
		sign				An optional positive or negative sign.
		digits				A sequence of digits ranging from 0 to 9
		.					A decimal point symbol. The default decimal point symbol can appear in s if style includes the MfNumberStyles.AllowDecimalPoint flag.
		fractional_digits	One or more occurrences of the digit 0. Fractional digits can appear in s only if style includes the MfNumberStyles.AllowDecimalPoint flag.
		e					The e or E character, which indicates that the value is represented in exponential notation.
							The s parameter can represent a number in exponential notation if style includes the MfNumberStyles.AllowExponent flag.
		hexdigits			A sequence of hexadecimal digits from 0 through f, or 0 through F.

		A string with decimal digits only (which corresponds to the MfNumberStyles.None style) always parses successfully.
		Most of the remaining MfNumberStyles enumerations control elements that may be but are not required to be present in this input string.
		The following table indicates how individual MfNumberStyles enumerations affect the elements that may be present in s.
		
		Non-composite NumberStyles values		Elements permitted in s in addition to digits
		MfNumberStyles.None						Decimal digits only.
		MfNumberStyles.AllowDecimalPoint		The . and fractional_digits elements. However, fractional_digits must consist of only one or more 0 digits or
												an MfOverflowException is thrown.
		MfNumberStyles.AllowExponent			The s parameter can also use exponential notation.
		MfNumberStyles.AllowLeadingWhite		The ws element at the beginning of s.
		MfNumberStyles.AllowTrailingWhite		The ws element at the end of s.
		MfNumberStyles.AllowLeadingSign			A positive sign can appear before digits.
		MfNumberStyles.AllowTrailingSign		A positive sign can appear after digits.
		MfNumberStyles.AllowParentheses			Although this flag is supported, the use of parentheses in s results in an MfOverflowException.
		MfNumberStyles.AllowThousands			Although the group separator symbol can appear in s, it can be preceded by only one or more 0 digits.
		MfNumberStyles.AllowCurrencySymbol		The $ element.

		If the MfNumberStyles.AllowHexSpecifier flag is used, s must be a hexadecimal value without a prefix. For example, "C9AF3" parses successfully,
		but "0xC9AF3" does not. The only other flags that can be combined with it are MfNumberStyles.AllowLeadingWhite and MfNumberStyles.AllowTrailingWhite.
		(The MfNumberStyles enumeration includes a composite number style, MfNumberStyles.HexNumber, that includes both white space flags.)
		The s parameter is parsed using the formatting information in a MfNumberFormatInfo object that is initialized.
		To use the formatting information of some other, call the MfInteger.Parse(s, style, provider) overload.

	Method: MfUInt64.Parse(s, provider)
		Converts the s representation of a number to its MfUInt64 equivalent
		s
		An string var of object convert.
		Can be var or instance of MfChar, MfString
		provider
		An object that supplies culture-specific parsing information about s. If provider is null, then MfNumberFormatInfo is used.
	Returns:
		Returns MfUInt64 instance equivalent to the number contained in s.
	Throws:
		Throws MfInvalidOperationException if not called as static method.
		Throws MfArgumentNullException if s is null.
		Throws MfFormatException if s is not of the correct format.
		Throws MfOverFlowExcpetion s represents a number less than MinValue or greater than MaxValue.
	Remarks:
		Static method
		The s parameter contains a number of the form:
		[ws][sign]digits[ws]
		Elements in square brackets ([ and ]) are optional. The following table describes each element.

		Element		Description
		ws			Optional white space.
		sign		An optional positive or negative sign.
		digits		A sequence of digits ranging from 0 to 9

		The s parameter is interpreted using the MfNumberStyles.Integer style. In addition to the byte value's decimal digits,
		only leading and trailing spaces together with a leading sign are allowed. (If the sign is present, it must be a positive sign or
		the method throws an MfOverFlowExcpetion.)
		To explicitly define the style elements that can be present in s, use either the MfUInt64.Parse(s, style) or the MfUInt64.Parse(s, style, provider) method.
		The s parameter is parsed using the formatting information in a MfNumberFormatInfo object. To parse a string using other formatting information,
		use the MfUInt64.Parse(s, style, provider) method.

	Method: MfUInt32.Parse(s, style, provider)
		Converts the s representation of a number to its MfUInt64 equivalent
		s
		An string var of object convert.
		Can be var or instance of MfChar, MfString
		style
		MfNumberStyles Instance or Integer var representing instance.
		A bitwise combination of MfNumberStyles values that indicates the style elements that can be present in s. A typical value to specify is MfNumberStyles.Integer.
		provider
		An object that supplies culture-specific parsing information about s. If provider is null, then MfNumberFormatInfo is used.
	Returns:
		Returns MfUInt64 instance equivalent to the number contained in s.
	Throws:
		Throws MfInvalidOperationException if not called as static method.
		Throws MfArgumentNullException if s is null.
		Throws MfFormatException if s is not of the correct format.
		Throws MfOverFlowExcpetion s represents a number less than MinValue or greater than MaxValue.
		Throws MfArgumentException style is not a MfNumberStyles value.
		-or-
		style is not a combination of MfNumberStyles.AllowHexSpecifier and MfNumberStyles.HexNumber values.
	Remarks:
		Static method
		The style parameter defines the style elements (such as white space or the positive sign) that are allowed in the s parameter for the parse operation to succeed.
		It must be a combination of bit flags from the MfNumberStyles enumeration. Depending on the value of style, the s parameter may include the following elements:
		
		[ws][$][sign]digits[.fractional_digits][e[sign]digits][ws]
		Elements in square brackets ([ and ]) are optional. The following table describes each element.
		Element				Description
		ws					Optional white space. White space can appear at the beginning of s if style includes the
							MfNumberStyles.AllowLeadingWhite flag, or at the end of s if style includes the MfNumberStyles.AllowTrailingWhite flag.
		$					A currency symbol. Its position in the string is defined by the MfNumberFormatInfo.CurrencyPositivePattern property.
							The current culture's currency symbol can appear in s if style includes the MfNumberStyles.AllowCurrencySymbol flag.
		sign				An optional positive or negative sign.
		digits				A sequence of digits ranging from 0 to 9
		.					A decimal point symbol. The default decimal point symbol can appear in s if style includes the MfNumberStyles.AllowDecimalPoint flag.
		fractional_digits	One or more occurrences of the digit 0. Fractional digits can appear in s only if style includes the MfNumberStyles.AllowDecimalPoint flag.
		e					The e or E character, which indicates that the value is represented in exponential notation.
							The s parameter can represent a number in exponential notation if style includes the MfNumberStyles.AllowExponent flag.
		hexdigits			A sequence of hexadecimal digits from 0 through f, or 0 through F.

		A string with decimal digits only (which corresponds to the MfNumberStyles.None style) always parses successfully.
		Most of the remaining MfNumberStyles enumerations control elements that may be but are not required to be present in this input string.
		The following table indicates how individual MfNumberStyles enumerations affect the elements that may be present in s.
		
		Non-composite NumberStyles values		Elements permitted in s in addition to digits
		MfNumberStyles.None						Decimal digits only.
		MfNumberStyles.AllowDecimalPoint		The . and fractional_digits elements. However, fractional_digits must consist of only one or more 0 digits or
												an MfOverflowException is thrown.
		MfNumberStyles.AllowExponent			The s parameter can also use exponential notation.
		MfNumberStyles.AllowLeadingWhite		The ws element at the beginning of s.
		MfNumberStyles.AllowTrailingWhite		The ws element at the end of s.
		MfNumberStyles.AllowLeadingSign			A positive sign can appear before digits.
		MfNumberStyles.AllowTrailingSign		A positive sign can appear after digits.
		MfNumberStyles.AllowParentheses			Although this flag is supported, the use of parentheses in s results in an MfOverflowException.
		MfNumberStyles.AllowThousands			Although the group separator symbol can appear in s, it can be preceded by only one or more 0 digits.
		MfNumberStyles.AllowCurrencySymbol		The $ element.

		Although this flag is supported, the use of parentheses in s results in an MfOverflowException.
		MfNumberStyles.AllowThousands
		Although the group separator symbol can appear in s, it can be preceded by only one or more 0 digits.
		MfNumberStyles.AllowCurrencySymbol
		The $ element.
		If the MfNumberStyles.AllowHexSpecifier flag is used, s must be a hexadecimal value without a prefix. For example, "C9AF3" parses successfully,
		but "0xC9AF3" does not. The only other flags that can be combined with it are MfNumberStyles.AllowLeadingWhite and MfNumberStyles.AllowTrailingWhite.
		(The MfNumberStyles enumeration includes a composite number style, MfNumberStyles.HexNumber, that includes both white space flags.)
*/
	Parse(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		objParams := MfInt16._intParseParams(A_ThisFunc, args*)
		cnt := objParams.Count
		retval := MfNull.Null
		try {
			strP := objParams.ToString()
		
			if (strP = "MfString" || strP = "MfChar")
			{
				strV := objParams.Item[0].Value
				ns := 7 ; integer
				retval := MfUInt64._Parse(strV, ns, MfNumberFormatInfo.CurrentInfo, A_ThisFunc)
			}
			else if (cnt = 2)
			{
				str := objParams.Item[0]
				if (!MfObject.IsObjInstance(str, MfString))
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				obj := objParams.Item[1]
				if (MfObject.IsObjInstance(obj, MfFormatProvider))
				{
					ns := 7 ; integer
					retval := MfUInt64._Parse(str.Value, ns, MfNumberFormatInfo.GetInstance(obj), A_ThisFunc)
				}
				else if (MfObject.IsObjInstance(obj, MfNumberStyles))
				{
					retval := MfUInt64._Parse(str.Value, obj.Value, MfNumberFormatInfo.CurrentInfo, A_ThisFunc)
				}
				else
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			else if (cnt = 3)
			{
				str := objParams.Item[0]
				ns := objParams.Item[1]
				fInfo := objParams.Item[2]
				if ((!MfObject.IsObjInstance(str, MfString))
					|| (!MfObject.IsObjInstance(ns, MfNumberStyles))
					|| (!MfObject.IsObjInstance(fInfo, MfFormatProvider)))
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				retval := MfUInt64._Parse(str.Value, ns.Value, MfNumberFormatInfo.GetInstance(fInfo), A_ThisFunc)
			}
			else if (strP = "MfUInt64")
			{
				retval := objParams.Item[0].Value
			}
		} catch e {
			if (MfObject.IsObjInstance(e, MFFormatException))
			{
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw e
			}
			else if (MfObject.IsObjInstance(e, MfOverflowException))
			{
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw e
			}
			else if (MfObject.IsObjInstance(e, MfException))
			{
				if (e.Source = A_ThisFunc)
				{
					throw e
				}
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (!MfNull.IsNull(retval))
		{
			x := MfBigInt.Parse(retval, 10)
			ui := new MfUInt64(0, true)
			ui.m_bigx := x
			return ui
		}
		ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:Parse() ;}
;{ BitAnd
/*
	Method: BitAnd()
		Namespace ›› System ›› MfUInt64 ›› Methods ›› Parent Previous Next
	BitAnd()
		OutputVar := instance.BitAnd(value)

	BitAnd(value)
		Performs logical AND operation current instance bits and value bits.
	Parameters:
		value
			The  value to logically AND bits with current instance.
			Can be any type that matches IsNumber ,instance of MfUInt64. or Instance of MfBigInt.
	Returns:
		If ReturnAsObject is true then returns current instance of MfUInt64 with an updated Value; Otherwise returns Value as var.
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentOutOfRangeException if value bit count is greater then 64 bits.
		Throws MfException for any other errors during the operation.
	Remarks:
		AutoHotkey has a integer upper limit of MfInt64.MaxValue. MfUInt64 can have greater values up to MfUInt.MaxValue.
		For this reason preforming bitwise operations in the standard AutoHotkey way by using <<, >>, &, ^, | operates will not work on on MfUInt64 values.
	Example:
		Int := new MfInt64(123456789)
		UInt := new MfUInt64("77444564454564646", true)
		UInt.BitAnd(Int)
		MsgBox % UInt.Value ; 35209476
*/
	BitAnd(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (this._IsZero())
		{
			return this
		}
		_bits := MfBinaryConverter.GetBits(Value)
		if (_bits.Count > 64)
		{
			_bits := MfBinaryConverter.Trim(_bits)
		}
		
		if (_bits.Count > 64)
		{
			ex := new MfArgumentOutOfRangeException("Value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try
		{
			localBits := MfBinaryConverter.GetBits(this)
			rBits := MfBinaryConverter.BitAnd(localBits, _bits)

			uint := MfBinaryConverter.ToUInt64(rBits)
			this.m_bigx := uint.m_bigx
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return this._ReturnUInt64(this)
	}
; End:BitAnd ;}
;{ BitNot
/*
	Method: BitNot()

	OutputVar := instance.BitNot()

	BitNot()
		Performs logical NOT operation current instance bits
	Returns:
		If ReturnAsObject is true then returns current instance of MfUInt64 with an updated Value; Otherwise returns Value as var.
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfException for any other errors during the operation.
	Remarks:
		AutoHotkey has a integer upper limit of MfInt64.MaxValue. MfUInt64 can have greater values up to MfUInt.MaxValue.
		For this reason preforming bitwise operations in the standard AutoHotkey way by using <<, >>, &, ^, | operates will not work on on MfUInt64 values.
	Example:
		UInt := new MfUInt64("77444564454564646", true)
		UInt.BitNot()
		MsgBox % UInt.Value ; 18369299509254986969
*/
	BitNot() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		if (this._IsZero())
		{
			return this
		}
		try
		{
			localBits := MfBinaryConverter.GetBits(this)
			rBits := MfBinaryConverter.BitNot(localBits)

			uint := MfBinaryConverter.ToUInt64(rBits)
			this.m_bigx := uint.m_bigx
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return this._ReturnUInt64(this)
	}
; End:BitNot ;}
;{ BitOr
/*
	Method: BitOr()

	OutputVar := instance.BitOr(value)

	BitOr(value)
		Performs logical OR operation current instance bits and value bits.
	Parameters:
		value
			The  value to logically OR bits with current instance.
			Can be any type that matches IsNumber ,instance of MfUInt64. or Instance of MfBigInt.
	Returns:
		If ReturnAsObject is true then returns current instance of MfUInt64 with an updated Value; Otherwise returns Value as var.
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentOutOfRangeException if value bit count is greater then 64 bits.
		Throws MfException for any other errors during the operation.
	Remarks:
		AutoHotkey has a integer upper limit of MfInt64.MaxValue. MfUInt64 can have greater values up to MfUInt.MaxValue.
		For this reason preforming bitwise operations in the standard AutoHotkey way by using <<, >>, &, ^, | operates will not work on on MfUInt64 values.
	Example:
		Int := new MfInt64(123456789)
		UInt := new MfUInt64("77444564454564646", true)
		UInt.BitOr(Int)
		MsgBox % UInt.Value ; 77444564542811959
*/
	BitOr(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (this._IsZero())
		{
			return this
		}
		_bits := MfBinaryConverter.GetBits(Value)
		if (_bits.Count > 64)
		{
			_bits := MfBinaryConverter.Trim(_bits)
		}
		
		if (_bits.Count > 64)
		{
			ex := new MfArgumentOutOfRangeException("Value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try
		{
			localBits := MfBinaryConverter.GetBits(this)
			rBits := MfBinaryConverter.BitOr(localBits, _bits)

			uint := MfBinaryConverter.ToUInt64(rBits)
			this.m_bigx := uint.m_bigx
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		return this._ReturnUInt64(this)
	}
; End:BitOr ;}
;{ BitXor
/*
	Method: BitXor()

	OutputVar := instance.BitXor(value)

	BitxXor(value)
		Performs logical Xor operation current instance bits and value bits.
	Parameters:
		value
			The  value to logically Xor bits with current instance.
			Can be any type that matches IsNumber ,instance of MfUInt64. or Instance of MfBigInt.
	Returns:
		If ReturnAsObject is true then returns current instance of MfUInt64 with an updated Value; Otherwise returns Value as var.
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentOutOfRangeException if value bit count is greater then 64 bits.
		Throws MfException for any other errors during the operation.
	Remarks:
		AutoHotkey has a integer upper limit of MfInt64.MaxValue. MfUInt64 can have greater values up to MfUInt.MaxValue.
		For this reason preforming bitwise operations in the standard AutoHotkey way by using <<, >>, &, ^, | operates will not work on on MfUInt64 values.
	Example:
		Int := new MfInt64(123456789)
		UInt := new MfUInt64("77444564454564646", true)
		UInt.BitXor(Int)
		MsgBox % UInt.Value ; 77444564507602483
*/
	BitXor(Value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (this._IsZero())
		{
			return this
		}
		_bits := MfBinaryConverter.GetBits(Value)
		if (_bits.Count > 64)
		{
			_bits := MfBinaryConverter.Trim(_bits)
		}
		
		if (_bits.Count > 64)
		{
			ex := new MfArgumentOutOfRangeException("Value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try
		{
			localBits := MfBinaryConverter.GetBits(this)
			rBits := MfBinaryConverter.BitXor(localBits, _bits)

			uint := MfBinaryConverter.ToUInt64(rBits)
			this.m_bigx := uint.m_bigx
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
			
		Return this
	}
; End:BitXor ;}
;{ BitShiftLeft
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
		If ReturnAsObject is true then returns current instance of MfUInt64 with an updated Value; Otherwise returns Value as var.
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfException for any other errors during the operation.
	Remarks:
		AutoHotkey has a integer upper limit of MfInt64.MaxValue. MfUInt64 can have greater values up to MfUInt.MaxValue.
		For this reason preforming bitwise operations in the standard AutoHotkey way by using <<, >>, &, ^, | operates will not work on on MfUInt64 values.
		Bits are wrapped when shifted. Shifting by multiples 64 would give you the same number
	Example:
		UInt := new MfUInt64("77444564454564646", true)
		UInt.BitShiftLeft(10)
		MsgBox % UInt.Value ; 5516257706635991040
		UInt := new MfUInt64("77444564454564646", true)
		UInt.BitShiftLeft(64)
		MsgBox % UInt.Value ; 77444564454564646
*/
	BitShiftLeft(value) {
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
			return this
		}
		
		if (this._IsZero())
		{
			return this
		}
		if (_value < 0)
		{
			_value := Abs(_value)
			r := mod(_value, 64)
			_value := 64 - r
		}

		if (_value >= 64)
		{
			_value := Mod(_value, 64)
		}
		if (_value < 0)
		{
			return this
		}
		try
		{
			localBits := MfBinaryConverter.GetBits(this)
			rBits := MfBinaryConverter.BitShiftLeftUnSigned(localBits, _value, true, true)

			uint := MfBinaryConverter.ToUInt64(rBits)
			this.m_bigx := uint.m_bigx
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return this._ReturnUInt64(this)
	}
; End:BitShiftLeft ;}
;{ BitShiftRight
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
		AutoHotkey has a integer upper limit of MfInt64.MaxValue. MfUInt64 can have greater values up to MfUInt.MaxValue.
		For this reason preforming bitwise operations in the standard AutoHotkey way by using <<, >>, &, ^, | operates will not work on on MfUInt64 values.
		Bits are wrapped when shifted. Shifting by multiples 64 would give you the same number
	Example:
		UInt := new MfUInt64("77444564454564646", true)
		UInt.BitShiftRight(10)
		MsgBox % UInt.Value ; 75629457475160
		UInt := new MfUInt64("77444564454564646", true)
		UInt.BitShiftRight(64)
		MsgBox % UInt.Value ; 77444564454564646
*/
	BitShiftRight(value) {
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
			return this
		}
		
		if (this._IsZero())
		{
			return this
		}
		if (_value < 0)
		{
			_value := Abs(_value)
			r := mod(_value, 64)
			_value := 64 - r
		}
		if (_value >= 64)
		{
			_value := Mod(_value, 64)
		}
		if (_value < 0)
		{
			return this
		}
		try
		{
			this.m_bigx.BitShiftRight(_value)
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return this._ReturnUInt64(this)
	}
; End:BitShiftRight ;}
;{	Subtract()
/*
	Method: Subtract()

	OutputVar := instance.Subtract(value)

	Subtract(value)
		Subtracts MfUInt64 value from current instance of MfUInt64.
	Parameters:
		value
			The value to subtract from the current instance.
			Can be any type that matches IsNumber, var integer or var string of integer numbers.
	Returns:
		If ReturnAsObject is true then returns current instance of MfUInt64 with an updated value; Otherwise returns var.
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentException if value is not an instance of MfUInt64 and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if adding value is less then MinValue and greater than MaxValue
	Remarks:
		When subtracting value greater then MfInt64.MaxValue the values must be enclosed in "" and passed as a string as shown in the last part of the example below.
		AutoHotkey has an integer upper limit of MfInt64.MaxValue. As a precaution all integer values passed into MfUInt64 methods can be wrapped in
		double quotes. eg: i := new MfUInt64("10", true)
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
	Exanple:
		i := new MfUInt64(MfUInt64.MaxValue, true) ; create new MfInt64 max value and set it RetrunAsObject to value to true
		i.Subtract(2) ; i.Value is now 18446744073709551613
		iNew := new MfUInt64(5)
		MsgBox % i.Subtract(iNew).Value ; displays 18446744073709551608
		MsgBox % i.Subtract(10).Value   ; displays 18446744073709551598
		MsgBox % i.Subtract(3).Subtract("18446744073709451613").Value ; displays 99982

*/
	Subtract(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bigx := new MfBigInt(value)
		tx := this.m_bigx.Clone()
		tx.Subtract(bigx)
		if (tx.IsNegative || MfUInt64._IsGreaterThenMax(tx))
		{
			ex := new MfArgumentOutOfRangeException("varInt"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				,MfUInt64.MinValue, MfUInt64.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_bigx := tx
		return this._ReturnUInt64(this)
	}
; End:Subtract() ;}
;{ 	ToString()			- Overrides	- MfPrimitive
/*
	Method: ToString()
		Overrides MfPrimitive.ToString()

	OutputVar := instance.ToString()

	ToString()
		Gets a string representation of the MfUInt64 instance.
	Returns:
		Returns string var representing current instance Value.
	Throws:
		Throws MfNullReferenceException if called as a static method
*/
	ToString() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return this.m_bigx.ToString(10)
	}
;  End:ToString() ;}
;{ 	TryParse()
/*
	Method: TryParse()

	OutputVar := MfUInt64.TryParse(result, s)
	OubputVar := MfUInt64.TryParse(byRef result, s, style[, provider])

	MfUInt64.TryParse(byRef result, s)
		Tries to converts the s representation of a number to its MfUInt64 equivalent. A return value indicates whether the conversion succeeded.
	Parameters:
		result
			Contains the value equivalent to the number contained in s, if the conversion succeeded.
			The conversion fails if the s parameter is not of the correct format, or represents a number less than MinValue or greater than MaxValue.
		s
			An object to convert.
			Can be var or instance of MfChar, MfString
	Returns:
		Returns true if parse is a success; Otherwise false
	Throws:
		Throws MfInvalidOperationException if not called as static method.
	Remarks:
		The conversion fails and the method returns false if the s parameter is not in the correct format, if it is null, or if it represents a number
		less than MinValue or greater than MaxValue.
		The MfUInt64.TryParse(result, s) method is similar to the MfUInt64.Parse(s) method, except that MfUInt64.TryParse(result, s)
		does not throw an exception if the conversion fails.
		The s parameter contains a number of the form:
		
		Element		Description
		ws			Optional white space.
		sign		An optional positive or negative sign.
		digits		A sequence of digits ranging from 0 to 9

		The s parameter is interpreted using the MfNumberStyles.Integer style. In addition to the byte value's decimal digits, only leading and trailing spaces together with a leading sign are allowed. (If the sign is present, it must be a positive sign or the method throws an MfOverFlowExcpetion.)
		Example

	Method: MfUInt64.TryParse(byRef result, s, style[, provider ])
		Tries to converts the s representation of a number to its MfUInt64 equivalent. A return value indicates whether the conversion succeeded.
		result
		Contains the value equivalent to the number contained in s, if the conversion succeeded.
		The conversion fails if the s parameter is not of the correct format, or represents a number less than MinValue or greater than MaxValue.
		s
		An string var of object convert.
		Can be var or instance of MfChar, MfString
		style
		MfNumberStyles Instance or Integer var representing instance.
		A bitwise combination of MfNumberStyles values that indicates the style elements that can be present in s. A typical value to specify is MfNumberStyles.Integer.
		provider
		An Optional object that supplies culture-specific parsing information about s. If provider is null, then MfNumberFormatInfo is used.
	Returns:
		Returns true if parse is a success; Otherwise false
	Throws:
		Throws MfInvalidOperationException if not called as static method.
		Throws MfArgumentException style is not a MfNumberStyles value.
		-or-
		style is not a combination of MfNumberStyles.AllowHexSpecifier and MfNumberStyles.HexNumber values.
	Remarks:
		The TryParse method is like the Parse method, except the TryParse method does not throw an exception if the conversion fails.
		It eliminates the need to use exception handling to test for a MfFormatException in the event that s is invalid and cannot be parsed successfully.
		The style parameter defines the style elements (such as white space or a positive or negative sign) that are allowed in the s parameter
		for the parse operation to succeed. It must be a combination of bit flags from the NumberStyles enumeration.
		The style parameter defines the style elements (such as white space or the positive sign) that are allowed in the s parameter for the parse
		operation to succeed. It must be a combination of bit flags from the MfNumberStyles enumeration. Depending on the value of style,
		the s parameter may include the following elements:

		[ws][$][sign]digits[.fractional_digits][e[sign]digits][ws]
		Elements in square brackets ([ and ]) are optional. The following table describes each element.
		Element				Description
		ws					Optional white space. White space can appear at the beginning of s if style includes the
							MfNumberStyles.AllowLeadingWhite flag, or at the end of s if style includes the MfNumberStyles.AllowTrailingWhite flag.
		$					A currency symbol. Its position in the string is defined by the MfNumberFormatInfo.CurrencyPositivePattern property.
							The current culture's currency symbol can appear in s if style includes the MfNumberStyles.AllowCurrencySymbol flag.
		sign				An optional positive or negative sign.
		digits				A sequence of digits ranging from 0 to 9
		.					A decimal point symbol. The default decimal point symbol can appear in s if style includes the MfNumberStyles.AllowDecimalPoint flag.
		fractional_digits	One or more occurrences of the digit 0. Fractional digits can appear in s only if style includes the MfNumberStyles.AllowDecimalPoint flag.
		e					The e or E character, which indicates that the value is represented in exponential notation.
							The s parameter can represent a number in exponential notation if style includes the MfNumberStyles.AllowExponent flag.
		hexdigits			A sequence of hexadecimal digits from 0 through f, or 0 through F.

		A string with decimal digits only (which corresponds to the MfNumberStyles.None style) always parses successfully.
		Most of the remaining MfNumberStyles enumerations control elements that may be but are not required to be present in this input string.
		The following table indicates how individual MfNumberStyles enumerations affect the elements that may be present in s.
		
		Non-composite NumberStyles values		Elements permitted in s in addition to digits
		MfNumberStyles.None						Decimal digits only.
		MfNumberStyles.AllowDecimalPoint		The . and fractional_digits elements. However, fractional_digits must consist of only one or more 0 digits or
												an MfOverflowException is thrown.
		MfNumberStyles.AllowExponent			The s parameter can also use exponential notation.
		MfNumberStyles.AllowLeadingWhite		The ws element at the beginning of s.
		MfNumberStyles.AllowTrailingWhite		The ws element at the end of s.
		MfNumberStyles.AllowLeadingSign			A positive sign can appear before digits.
		MfNumberStyles.AllowTrailingSign		A positive sign can appear after digits.
		MfNumberStyles.AllowParentheses			Although this flag is supported, the use of parentheses in s results in an MfOverflowException.
		MfNumberStyles.AllowThousands			Although the group separator symbol can appear in s, it can be preceded by only one or more 0 digits.
		MfNumberStyles.AllowCurrencySymbol		The $ element.

		If the MfNumberStyles.AllowHexSpecifier flag is used, s must be a hexadecimal value without a prefix. For example, "C9AF3" parses successfully,
		but "0xC9AF3" does not. The only other flags that can be combined with it are MfNumberStyles.AllowLeadingWhite and MfNumberStyles.AllowTrailingWhite.
		(The MfNumberStyles enumeration includes a composite number style, MfNumberStyles.HexNumber, that includes both white space flags.)
		The provider parameter is an MfFormatProvider implementation, such as a MFNumberFormatInfo object, whose GetFormat method returns a MFNumberFormatInfo object.
		The MFNumberFormatInfo object provides culture-specific information about the format of s.
*/
	TryParse(byref result, args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		objParams := MfInt16._intParseParams(A_ThisFunc, args*)
		cnt := objParams.Count
		retval := false
		
		strP := objParams.ToString()
		num := 0
		if (strP = "MfString" || strP = "MfChar")
		{
			strV := objParams.Item[0].Value
			ns := 7 ; integer
			retval := MfUInt64._TryParse(strV, ns, MfNumberFormatInfo.CurrentInfo, num)
		}
		else if (cnt = 2)
		{
			str := objParams.Item[0]
			if (!MfObject.IsObjInstance(str, MfString))
			{
				return false
			}
			obj := objParams.Item[1]
			if (MfObject.IsObjInstance(obj, MfNumberStyles))
			{
				retval := MfUInt64._TryParse(str.Value, obj.Value, MfNumberFormatInfo.CurrentInfo, num)
			}
			else
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else if (cnt = 3)
		{
			str := objParams.Item[0]
			ns := objParams.Item[1]
			fInfo := objParams.Item[2]
			if ((!MfObject.IsObjInstance(str, MfString))
				|| (!MfObject.IsObjInstance(ns, MfNumberStyles))
				|| (!MfObject.IsObjInstance(fInfo, MfFormatProvider)))
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			retval := MfUInt64._TryParse(str.Value, ns.Value, MfNumberFormatInfo.GetInstance(fInfo), num)
		}
		else if (strP = "MfUInt64")
		{
			num := objParams.Item[0].Value
			retval := true
		}
		if (retval)
		{
			if (IsObject(result))
			{
				x := MfBigInt.Parse(num, 10)
				if (!MfObject.IsObjInstance(result, MfUInt64))
				{
					result := new MfUInt64(0, true)
				}
				result.m_bigx := x
				;int.Value := num
			}
			else
			{
				result := num
			}
		}
		return retval
	}
; End:TryParse() ;}

; End:Methods ;}
;{ Internal Methods
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
;{ 	_Parse
/*
	Method: _Parse()

	_Parse()
		Parses s string into an integer
	Parameters:
		s
			String to parse
		style
			MfNumberStyles number
		info
			instance of MfFormatProvider
	Returns:
		Returns var integer
	Throws:
		Throws MfOverflowException if return value is out of range
	Remarks:
		Static method
		Private method
*/
	_Parse(s, style, info, methodName) {
		try
		{
			MfNumberFormatInfo.ValidateParseStyleInteger(style)	
		}
		catch e
		{
			e.SetProp(A_LineFile, A_LineNumber, methodName)
			throw e
		}
		num := 0
		try
		{
			num := MfNumber.ParseUInt64(s, style, info)
			return num
		}
		catch e
		{
			if (MfObject.IsObjInstance(e, MfOverflowException))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"), e)
				ex.SetProp(A_LineFile, A_LineNumber, methodName)
				throw ex
			}
			throw e
		}
	}
; 	End:_Parse ;}
;{ 	_TryParse
/*
	Method: _Parse()

	_TryParse()
		Parses string and read value into integer
	Parameters:
		s
			String to parse
		style
			MfNumberStyles number
		info
			instance of MfFormatProvider
		Out
			The result of the parse
	Returns:
		Returns boolean if true if number was parsed; Otherwise false
	Throws:
		Throws MfArgumentException style is not correct for integer
	Remarks:
		Static method
*/
	_TryParse(s, style, info, ByRef Out) {
		try
		{
			MfNumberFormatInfo.ValidateParseStyleInteger(style)	
		}
		catch e
		{
			e.SetProp(A_LineFile, A_LineNumber, methodName)
			throw e
		}
		num := 0
		result := MfNumber.TryParseUInt64(s, style, info, num)
		if (result)
		{
			out := num
			return true
		}
		return false
	}
; 	End:_TryParse ;}
;{ 	_GetValue
	_IsGreaterThenMax(value) {
		bigx := new MfBigInt(value)
		return bigx.GreaterThen(MfBigMathInt.Uint64Max)
	}
	_IsZero() {
		return MfBigMathInt.IsZero(this.m_bigx.m_bi)
	}
	; internal method
;{ _ReturnUInt64
	_ReturnUInt64(obj) {
		if (MfObject.IsObjInstance(obj, MfUInt64)) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfUInt64(obj, true):obj
		return retval
	}
; End:_ReturnUInt64 ;}

; End:Internal Methods ;}
;{ Properties
;{ 	MaxValue
/*
	Property: MaxValue [get]
		Represents the largest possible value of an MfUInt64. This field is constant.
	Value:
		Var integer
	Gets:
		Gets the largest possible value of an MfUInt64.
	Remarks:
		Constant Property
		Can be accessed using MfUInt64.MaxValue
		Value = "18446744073709551615" (0xFFFFFFFFFFFFFFFF) hex
*/
	MaxValue[]
	{
		get {
			return "18446744073709551615"   ;  0xFFFFFFFFFFFFFFFF
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MaxValue ;}
;{ 	MinValue
/*
	Property: MinValue [get]
		Represents the smallest possible value of an MfUInt64. This field is constant.
	Value:
		Var integer
	Gets:
		Gets the smallest possible value of an MfUInt64.
	Remarks:
		Can be accessed using MfUInt64.MinValue
		Value = "0"
*/
	MinValue[]
	{
		get {
			return "0" ; 
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MinValue ;}
;{	Value
/*
	Property: Value [get\set]
		Overrides MfPrimitive.Value
		Gets or sets the value associated with the this instance of MfUInt64
	Value:
		Value is a integer and can be var or any type that matches IsIntegerNumber.
	Gets:
		Gets integer Value as var with a value no less then MinValue and no greater than MaxValue.
	Sets:
		Set the Value of the instance. Can  be var or any type that matches IsIntegerNumber.
	Throws:
		Throws MfNotSupportedException on set if Readonly is true.
		Throws MfArgumentOutOfRangeException if value is less then MinValue or greater then MaxValue
		Throws MfArgumentException for other errors.
*/
	Value[]
	{
		get {
			return this.m_bigx.Value
		}
		set {
			this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
			x := MfUInt64.Parse(value, true)
			this.m_bigx := x.m_bigx
		}
	}
;	End:Value ;}
; End:Properties ;}
}