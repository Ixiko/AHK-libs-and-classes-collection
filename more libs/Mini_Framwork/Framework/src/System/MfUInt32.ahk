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

;{ Class Comments
/*
	Class: MfUInt32
		Represents MfUInt32 object
	Inherits: MfPrimitive
*/
; End:Class Comments ;}
Class MfUInt32 extends MfPrimitive
{
;{ Static Properties
	TypeCode[]
	{
		get {
			return 29
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}

; End:Static Methods ;}
;{ Constructor
/*
	Constructor()
		Initializes a new instance of the MfUInt32 class.
	
	OutputVar := new MfUInt32([int, returnAsObj, readonly])
	
	Constructor([int, retunAsObj, readonly])
		Initializes a new instance of the MfUInt32 class optionally setting the Value property, ReturnAsObject property and the Readonly property.
	Parameters
		int
			The MfUInt32 object or var containing integer to create a new instance with.
		returnAsObj
			Determines if the current instance of MfUInt32 class will return MfUInt32 instances from functions or vars containing integer.
			If omitted value is false
		readonly
			Determines if the current instance of MfUInt32 class will allow its Value to be altered after it is constructed.
			The Readonly propery will reflect this value after the classe is constructed.
			If omitted value is false
	Remarks
		Sealed Class.
		This constructor initializes the MfUInt32 with the integer value of int.
		Value property to the value of int.
		ReturnAsObject will have a value of returnAsObj
		Readonly will have a value of readonly.
		If Readonly is true then any attempt to change the underlying value will result in MfNotSupportedException being thrown.
		Variadic Method; This method is Variadic so you may construct an instance of MfParams containing any of the overload method parameters
		listed above and pass in the MfParams instance to the method instead of using the overloads described above. See MfParams for more information.
	Throws
		Throws MfNotSupportedException if class is extended.
		Throws MfArgumentException if error in parameter.
		Throws MfNotSupportedException if incorrect type of parameters or incorrect number of parameters.
*/
	__New(int:=0, retunAsObj:=false, readonly:=false) {
		; int = 0, returnAsObj = false, ReadOnly = false
		; Throws MfNotSupportedException if MfUInt32 Sealed class is extended
		if (this.__Class != "MfUInt32")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfUInt32"))
		}

		_intResult := MfUInt32.GetValue(int,"NaN", true)
		if (_intResult == "NaN")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToUInt32"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_int := _intResult
			
		_returnAsObject := MfBool.GetValue(retunAsObj,false)
		_readonly :=  MfBool.GetValue(readonly,false)
		
		base.__New(_int, _returnAsObject, _readonly)
		this.m_isInherited := false
	}
; End:Constructor ;}
;{ Methods
;{	Add()
/*!
	Method: Add()
	
	OutputVar := instance.Add(value)
	
	Add(value)
		Adds MfUInt32 value to current instance of MfUInt32.
	Parameters
		value
			The value to add to the current instance.
			Can be any type that matches IsNumber or var integer.
	Returns
		If ReturnAsObject is true then returns current instance of MfUInt32 with an updated value; Otherwise returns var containing integer.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentException if value is not an instance of MfUInt32 and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if adding value is less then Minvalue and greater than MaxValue
	Remarks
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
*/
	Add(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)

		if (MfNull.IsNull(value)) {
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
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_newVal := this.Value + _value
		if ((_newVal < MfUInt32.MinValue) || (_newVal > MfUInt32.MaxValue)) {
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, MfUInt32.MinValue, MfUInt32.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
		return this._ReturnUInt32(this)
	}
; End:Add() ;}
;{ 	CompareTo()			- Overrides	- MfObject
/*!
	Method: CompareTo()
		Overrides MfObject.CompareTo
	
	instance.CompareTo()
	
	CompareTo(obj)
		Compares this instance to a specified MfUInt32 instance.
	Parameters
		obj
		A MfUInt32 object to compare to current instance.
	Returns
		Returns a var containing integer indicating the position of this instance in the sort order in relation to the value parameter. 
		eturn Value Description Less than zero This instance precedes obj value.
		Zero This instance has the same position in the sort order as value. Greater than zero This instance follows
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfUInt32.
	Remarks
		Compares this instance to a specified MfUInt32 instance and indicates whether this instance precedes, follows,
		or appears in the same position in the sort order as the specified MfUInt32 instance.
*/
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value)) {
			return 1
		}
		if (!MfObject.IsObjInstance(obj, MfUInt32)) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Object_Equals"),"obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.Value = obj.Value) {
			return 0
		}
		if (this.Value > obj.Value) {
			return 1
		}
		return -1
	}
; End:CompareTo(c) ;}
;{ 	Divide
/*
	Method: Divide()
	
	OutputVar := instance.Divide(value)
	
	Divide(value)
		Divides the current instance of MfUInt32 by the divisor value.
	Parameters
		value
			The Divisor value to divide the current instance Value by.
			Can be any type that matches IsNumber. or var number.
	Returns
		If ReturnAsObject is true then returns current instance of MfUInt32 with an updated Value; Otherwise returns Value as var.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfDivideByZeroException if value is zero.
		Throws MfArithmeticException if the operation fails or value is not an instance of MfUInt32 and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if dividing result is less then MinValue and greater than MaxValue
	Remarks
		If the result of the operation is not a whole number such as 4/2 but rather a float number such as 8/3 (8/3 = 2.6666...) then
		the result will always be the whole number portion of the operation.
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
		if (this.Equals(0))
		{
			return this._ReturnUInt32(this)
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
			ex := new MfDivideByZeroException()
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		; with floor divide  any result less then 1 will be zero
		_newVal := Round(this.Value // _value) + 0 ; floor divide and set back to integer
		if ((_newVal < MfUInt32.MinValue) || (_newVal > MfUInt32.MaxValue)) {
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, MfUInt32.MinValue, MfUInt32.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
		return this._ReturnUInt32(this)

	}
; 	End:Divide ;}
;{ 	Equals()			- Overrides - MfObject
/*!
	Method: Equals()
		Overrides MfObject.Equals()
	
	OutputVar := instance.Equals(value)
	
	Equals(value)
		Gets if this instance Value is the same as the obj instance.Value
	Parameters
		value
			The Object or var containing, integer to compare to current instance.
			Can be any type that matches IsNumber. 
	Returns
		Returns Boolean value of true if this Value and value are equal; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
	Remarks
		If value is unable to be converted to a integer then false will be returned.
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
*/
	Equals(value)	{
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			return false
		}
		retval := false
		_value := 0
		try
		{
			_value :=  MfUInt32.GetValue(value)
			retval := this.Value = _value
		}
		catch 
		{
			retval := false
		}
		return retval
	}
; End:Equals() ;}
;{ 	GetHashCode()		- Overrides	- MfObject
/*
	Method: GetHashCode()
		Overrides MfObject.GetHashCode()
	
	OutputVar := instance.GetHashCode()
	
	GetHashCode()
		Gets A hash code for the MfUInt32 instance.
	Returns
		A 32-bit signed integer hash code as var.
	Throws
		Throws MfNullReferenceException if object is not an instance.
*/
	GetHashCode() {
		i := this.Value
		u := this._cInt16ToUInt16(i)
		return u | i << 16
	}
; End:GetHashCode() ;}
;{ 	GetTypeCode()
/*
	Method: GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfUInt32 Type Code.
	Returns
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfUInt32.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.UInt32
	}
; End:GetTypeCode() ;}
;{ 	GetValue()			- Overrides	- MfPrimitive
/*
	Method: GetValue()
		Overrides MfPrimitive.GetValue().
	
	OutputVar := MfUInt32.GetValue(Obj)
	OutputVar := MfUInt32.GetValue(Obj, Default)
	OutputVar := MfUInt32.GetValue(Obj, Default, AllowAny)
	
	MfUInt32.GetValue(Obj)
		Gets the integer number from Object or var containing integer.
	Parameters
		Obj
		The Object or var containing, integer or hex value
		Can be any type that matches IsNumber. 
	Returns
		Returns a var containing a integer No less then MinValue and no greater then MaxValue.
	Remarks
		Static Method
		Throws an error if unable to convert Obj to integer.
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentOutOfRangeException if Obj is less then MinValue or Greater then MaxValue.
		Throws MfArgumentException if argument Obj is can not be converted to integer value.
	
	MfUInt32.GetValue(Obj, Default)
		Gets a integer number from Obj or returns Default value if Obj is unable to be converted to integer.
		Default must be a value that can be converted to integer or it will be ignored if Obj can not be converted to integer and an error will be thrown.
	Parameters
		Obj
			The Object or var containing, integer or hex value
			Can be any type that matches IsNumber. 
		Default
			The value to return if Obj is Cannot be converted
			Can be any type that matches IsNumber or var of integer.
	Returns
		Returns a var containing a integer or Default value if Obj is unable to be converted to integer.
	Remarks
		Static Method
		If Default is not a valid integer or MfUInt32 instance then GetValue will throw an error if Obj can not be converted to integer. 
		If Default can not be converted to a integer then this would method will yield the same results as calling MfUInt32.GetValue(Obj).
	Throws
		Throws MfInvalidOperationException if not called as a static method.
	
	MfUInt32.GetValue(Obj, Default, AllowAny)
		Gets a integer number from Obj or returns Default value if Obj is unable to be converted to integer.
	Parameters
		Obj
			The Object or var containing, integer or hex value
			Can be any type that matches IsNumber. 
		Default
			The value to return if Obj is Cannot be converted
			Can be any type that matches IsNumber or var of integer.
		AlowAny
			Determines if Default can be a value other then integer. If true Default can be any var, Object or null; Otherwise Default must be a integer value.
	Remarks
		Static Method.
		If AllowAny is true then Default can be any value including var, object or null.
		However if AllowAny is false then this method will yield the same result as calling MfUInt32.GetValue(Obj, Default).
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentException if AllowAny is not a valid boolean.
		
	General Remarks
		If Obj is a float or MfFloat instance then GetValue() will alway round down for positive number and round up for negative numbers.
		For instance MfUInt32.GetValue(2.8) will be 2 and MfUInt32.GetValue(-2.8) will be -2.
		Throws MfNotSupportedException if incorrect number of parameters are passed in.
*/
	GetValue(args*) {
		; _intA := MfInt64.GetValue("-0x123456789", "NaN", true) 1000 loops taks about 0.3 second
		;_intA := MfInt64.GetValue("x123456789", "NaN", true) 1000 loops taks about 0.4 second
		; measurements done on older dual core laptop		
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
			_default := MfUInt32._GetValue(args[2], false)
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
				_default := MfUInt32._GetValue(args[2], false)
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
				retval := MfUInt32._GetValue(obj)
			}
			catch e
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToUInt32"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else
		{
			retval := MfUInt32._GetValue(obj, false)
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
	; internal method
	_GetValue(obj, CanThrow=true) {
		retval := 0
		if (IsObject(obj)) {
			T := new MfType(obj)
			if (T.IsIntegerNumber)
			{
				retval := obj.Value
				if ((retval < MfUInt32.MinValue) || (retval > MfUInt32.MaxValue))
				{
					if (!CanThrow)
					{
						return "NaN"
					}
					ex := new MfArgumentOutOfRangeException("obj"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfUInt32.MinValue, MfUInt32.MaxValue))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			else if (t.IsFloat)
			{
				varInt := format("{:f}", obj.Value)
				dotIndex := InStr(varInt, ".") - 1
				if (dotIndex > 0)
				{
					varInt := SubStr(varInt, 1, dotIndex) ; drop decimal portion
				}
				retval := varInt + 0 ; force conversion from any hex values
				if ((retval < MfUInt32.MinValue) || (retval > MfUInt32.MaxValue)) {
				if (!CanThrow)
				{
					return "NaN"
				}
					ex := new MfArgumentOutOfRangeException("varInt"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfUInt32.MinValue, MfUInt32.MaxValue))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			else
			{
				if (!CanThrow)
				{
					return "NaN"
				}
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", "int"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else {
			retval := MfUInt32._GetValueFromVar(obj, CanThrow)
		}
		return retval
	}
; 	End:_GetValue ;}
;{ 	_GetValueFromVar
	; internal method
	_GetValueFromVar(varInt, CanThrow=true) {
		strVarInt := varInt . ""
		if (Mfunc.IsInteger(varInt)) {
			retval := varInt + 0 ; force conversion from any hex values
			if ((retval < MfUInt32.MinValue) || (retval > MfUInt32.MaxValue)) {
				if (!CanThrow)
				{
					return "NaN"
				}
				ex := new MfArgumentOutOfRangeException("varInt"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
					,MfUInt32.MinValue, MfUInt32.MaxValue))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else if (Mfunc.IsFloat(varInt)) {
			dotIndex := InStr(varInt, ".") - 1
			if (dotIndex > 0)
			{
				varInt := SubStr(varInt, 1, dotIndex) ; drop decimal portion
			}
			retval := varInt + 0 ; force conversion from any hex values
			if ((retval < MfUInt32.MinValue) || (retval > MfUInt32.MaxValue)) {
				if (!CanThrow)
				{
					return "NaN"
				}
				ex := new MfArgumentOutOfRangeException("varInt"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
					,MfUInt32.MinValue, MfUInt32.MaxValue))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			
		} else {
			if (!CanThrow)
			{
				return "NaN"
			}
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IntegerVar", "varInt"), "varInt")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; 	End:_GetValueFromVar ;}
;{ 	GreaterThen
/*
	Method: GreaterThen()
	
	OutputVar := instance.GreaterThen(value)
	
	GreaterThan(value)
		Compares the current MfUInt32 object to a specified MfUInt32 instance and returns an indication of their relative values.
	Parameters
		value
			The Object or var containing, integer to compare to current instance.
			Can be any type that matches IsNumber. 
	Returns
		Returns true if the current instance has greater value then the value instance; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfUInt32 and can not be converted into integer value.
	Remarks
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
*/
	GreaterThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfUInt32)) {
			return this.Value > value.Value
		}
		try
		{
			val := MfUInt32.GetValue(value)
			retval := this.Value > val
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
/*!
	Method: GreaterThenOrEqual()
	
	OutputVar := instance.GreaterThenOrEqual(value)
	
	GreaterThenOrEqual(value)
		Compares the current MfUInt32 object to a specified MfUInt32 object and returns an indication of their relative values.
	Parameters
		value
			The Object or var containing, integer to compare to current instance.
			Can be any type that matches IsNumber. 
	Returns
		Returns true if the current instance has greater or equal value then the value instance; otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfUInt32 and can not be converted into integer value.
	Remarks
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
*/
	GreaterThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfUInt32)) {
			return this.Value >= value.Value
		}
		try
		{
			val := MfUInt32.GetValue(value)
			retval := this.Value >= val
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; 	End:GreaterThenOrEqual ;}
;{ 	LessThen
/*!
	Method: LessThen()
	
	OutputVar := instance.LessThen(value)
	
	LessThen(value)
		Compares the current MfUInt32 object to a specified MfUInt32 object and returns an indication of their relative values.
	Parameters
		value
			The Object or var containing, integer to compare to current instance.
			Can be any type that matches IsNumber. 
	Returns
		Returns true if the current instance has less value then the value instance; otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfUInt32 and can not be converted into integer value.
	Remarks
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
*/
	LessThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfUInt32)) {
			return this.Value < value.Value
		}
		try
		{
			val := MfUInt32.GetValue(value)
			retval := this.Value < val
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; 	End:LessThen ;}
;{ 	LessThenOrEqual
/*
	Method: LessThenOrEqual()
	
	OutputVar := instance.LessThenOrEqual(value)
	
	LessThenOrEqual(value)
		Compares the current MfUInt32 object to a specified MfUInt32 object and returns an indication of their relative values.
	Parameters
		value
			The Object or var containing, integer to compare to current instance.
			Can be any type that matches IsNumber. 
	Returns
		Returns true if the current instance has less or equal value then the value instance; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfUInt32 and can not be converted into integer value.
	Remarks
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
*/
	LessThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfUInt32)) {
			return this.Value <= value.Value
		}
		try
		{
			val := MfUInt32.GetValue(value)
			retval := this.Value <= val
		}
		Catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; 	End:LessThenOrEqual ;}
;{ 	Multiply
/*
	Method: Multiply()
	
	OutputVar := instance.Multiply(value)
	
	Multiply(value)
		Multiplies the current instance of MfUInt32 by the value.
	Parameters
		value
			The value to multiply the current instance Value by.
			Can be any type that matches IsNumber. or var number.
	Returns
		If ReturnAsObject is true then returns current instance of MfUInt32 with an updated Value; Otherwise returns Value as var.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfDivideByZeroException if value is zero.
		Throws MfArithmeticException if the operation fails or value is not an instance of MfUInt32 and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if dividing result is less then MinValue and greater than MaxValue
	Remarks
		If the result of the operation is not a whole number such as 4*3 but rather a float number such as 4*3.3 (4 * 3.2 = 13.2) then the
		result will always be the whole number portion of the operation.

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
		if (this.Equals(0))
		{
			return this._ReturnUInt32(this)
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
			return this._ReturnUInt32(this)
		}
		_newVal := this.Value * _value
		_newVal := _newVal > 0?Floor(_newVal):Ceil(_newVal)
		if ((_newVal < MfUInt32.MinValue) || (_newVal > MfUInt32.MaxValue)) {
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, MfUInt32.MinValue, MfUInt32.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
		return this._ReturnUInt32(this)

	}
; 	End:Multiply ;}
;{ 	Parse()
/*
	Method: Parse()
	
	OutputVar := MfUInt32.Parse(obj)
	
	Parse(obj)
		Converts the obj representation of a number to its MfUInt32 equivalent
	Parameters
		obj
			An object convert.
			Can be instance of MfChar, MfString
			Can be var containing string, integer
			Can also be instance of MfParams.
	Returns
		Converts the obj representation of a number to its MfUInt32 equivalent.
		If MfParams is passed in with Data key of ReturnAsObject and value set to true then parsed result will be returned as an instance of MfUInt32;
		Otherwise a var integer will be returned.
	Remarks
		Static Method
		Converts the obj representation of a number to its MfUInt32 equivalent.
		If obj parameter is an Object then it must be instance from MfObject or be an instance of MfParams.
		If MfParams is passed in with Data key of ReturnAsObject and value set to true then parsed result will be returned as an instance of MfUInt32;
		otherwise a var integer will be returned.
	Throws
		Throws MfInvalidOperationException if not called as static method.
		Throws MfFormatException unable to parse obj.
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
				retval := MfUInt32._Parse(strV, ns, MfNumberFormatInfo.CurrentInfo, A_ThisFunc)
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
					retval := MfUInt32._Parse(str.Value, ns, MfNumberFormatInfo.GetInstance(obj), A_ThisFunc)
				}
				else if (MfObject.IsObjInstance(obj, MfNumberStyles))
				{
					retval := MfUInt32._Parse(str.Value, obj.Value, MfNumberFormatInfo.CurrentInfo, A_ThisFunc)
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
				retval := MfUInt32._Parse(str.Value, ns.Value, MfNumberFormatInfo.GetInstance(fInfo), A_ThisFunc)
			}
			else if (strP = "MfUInt32")
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
			return new MfUInt32(retval, true)
		}
		ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:Parse() ;}
;{	Subtract()
/*
	Method: Subtract()
	
	OutputVar := instance.Subtract(value)
	
	Subtract(value)
		Subtracts MfUInt32 value to current instance of MfUInt32.
	Parameters
		value
			The value to subtract from the current instance.
			Can be any type that matches IsNumber or var integer.
	Returns
		If ReturnAsObject is true then returns current instance of MfUInt32 with an updated value; Otherwise returns var containing integer.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentException if value is not an instance of MfUInt32 and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if adding value is less then Minvalue and greater than MaxValue
	Remarks
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
*/
	Subtract(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value)) {
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
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_newVal := this.Value - _value
		if ((_newVal < MfUInt32.MinValue) || (_newVal > MfUInt32.MaxValue)) {
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, MfUInt32.MinValue, MfUInt32.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
		return this._ReturnUInt32(this)
	}
; End:Add() ;}
;{ 	ToString()			- Overrides	- MfPrimitive
/*
	Method: ToString()
		Overrides MfPrimitive.ToString()

	OutputVar := instance.ToString()

	ToString()
		Gets a string representation of the MfUInt32 instance.
	Returns
		Returns string var representing current instance Value.
	Throws
		Throws MfNullReferenceException if called as a static method
*/
	ToString() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := Format("{:i}",this.Value)
		return retval
	}
;  End:ToString() ;}
;{ 	TryParse()
/*
	Method: TryParse()
	
	OutputVar := MfUInt32.TryParse(int, obj)
	
	TryParse(byref int, obj)
		Converts the obj representation of a number to its Integer equivalent. A return value indicates whether the conversion succeeded.
	Parameters
		int
			Contains the value equivalent to the number contained in obj, if the conversion succeeded.
			The conversion fails if the obj parameter is not of the correct format, or represents a number less than MinValue or greater than MaxValue.
		obj
			An object convert.
			Can be instance of MfChar, MfString
			Can be var containing string, integer, hex value
			Obj can also be instance of MfParams.
	Returns
		Returns true if parse is a success; Otherwise false
	Remarks
		If parameter int is passed in as an object it must in initialized as an instance of MfUInt32 first. Eg: myInt := new MfUInt32(0)
		If parameter int is passed in as var it must in initialized as integer first. Eg: myInt := 0
		White spaces are allowed at the beginning or end of the string to parse.
		When parsing a MfChar instance the MfChar instance must be Numeric to parse successfully.
		See MfChar.IsNumber.
	Throws
		Throws MfInvalidOperationException if not called as static method.
*/
	TryParse(byref int, args*) {
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
			retval := MfUInt32._TryParse(strV, ns, MfNumberFormatInfo.CurrentInfo, num)
		}
		else if (cnt = 2)
		{
			str := objParams.Item[0]
			if (!MfObject.IsObjInstance(str, MfString))
			{
				return false
			}
			obj := objParams.Item[1]
			if (MfObject.IsObjInstance(obj, MfFormatProvider))
			{
				ns := 7 ; integer
				retval := MfUInt32._TryParse(str.Value, ns, obj.GetInstance(Null), num)
			}
			else if (MfObject.IsObjInstance(obj, MfNumberStyles))
			{
				retval := MfUInt32._TryParse(str.Value, obj.Value, MfNumberFormatInfo.CurrentInfo, num)
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
			retval := MfUInt32._TryParse(str.Value, ns.Value, MfNumberFormatInfo.GetInstance(fInfo), num)
		}
		else if (strP = "MfUInt32")
		{
			num := objParams.Item[0].Value
			retval := true
		}
		if (retval)
		{
			if (IsObject(int))
			{
				if (!MfObject.IsObjInstance(int, MfUInt32))
				{
					int := new MfUInt32()
				}
				int.Value := num
			}
			else
			{
				int := num
			}
		}
		return retval
	}
; End:TryParse() ;}
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
			num := MfNumber.ParseUInt32(s, style, info)
			return num
		}
		catch e
		{
			if (MfObject.IsObjInstance(e, MfOverflowException))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt32"), e)
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
		result := MfNumber.TryParseUInt32(s, style, info, num)
		if (result)
		{
			out := num
			return true
		}
		return false
	}
; 	End:_TryParse ;}
;{ _cInt64ToInt()
/*
	Method: _cInt64ToInt()
		Converts int64 into Int32
	parameters
		input
			The int64 var to convert to int32 var
	Returns
		Int32 signed var
	Remarks
		Internal Method
		This method does a Circular shift or Wrap Around bit shift operation
		In c# this would be the same as int myInt = (int)myInt64
		In c# Convert.ToInt32() is different then (int)myInt64
		The difference is Convert.ToInt32(int64) thorw overflow if int64 is greater then int.MaxValue or 
		less then int.MinValue
		Convert.ToInt32(int64) does not do a circular shift.
*/
	_cInt64ToInt(input) {
		VarSetCapacity(Var, 32, 0)      ; Variable to hold integer
		NumPut(input, Var, 0, "Int64" ) ; Input as Integer 64
		retval := NumGet(Var, 0, "Int") ; Retrieve it as 'Signed Integer 32'
		VarSetCapacity(var, 0) ; release mem
		return retval
	}
; End:_cInt64ToInt() ;}
;{ _cInt16ToUInt16()
/*
	Method: _cInt64ToInt()
		Converts int16 into uInt16
	parameters
		input
			The int16 var to convert to uInt16 var
	Returns
		int16 signed var
	Remarks
		Internal Method
*/
	_cInt16ToUInt16(input) {
		VarSetCapacity(Var, 8, 0)       ; Variable to hold integer
		NumPut(input, Var, 0, "Short" ) ; Input as Integer 16
		retval := NumGet(Var, 0, "UShort") ; Retrieve it as 'Signed Integer 16'
		VarSetCapacity(var, 0) ; release mem
		return retval
	}
; End:_cInt16ToUInt16() ;}
;{ _uIntToInt(uInt)
/*
	Method:_uIntToInt()
		Converts unsigned integer to signed integer
	Parameters
		uInt
			The unsigned integer to convert to signed integer
	Returns
		Signed integer as var
	Remarks
		Internal Method
*/
	_uIntToInt(uInt) {
		VarSetCapacity( Var,16,0 ) 		; Variable to hold integer
		NumPut( uInt , Var, 0, "UInt" ) ; Input as 'Unsigned Integer'
		retval := NumGet( Var,0,"Int" )	; Retrieve it as 'Signed Integer'
		VarSetCapacity(var, 0)
		return retval
	}
; End:_uIntToInt(uInt) ;}
;{ _ReturnUInt32()
; return MfUInt32 intance if ReturnAsObject is true otherwise var containing Integer
	_ReturnUInt32(obj) {
		if (MfObject.IsObjInstance(obj, MfUInt32)) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfUInt32(obj, true):obj
		return retval
	}
; End:_ReturnUInt32() ;}
; End:Methods ;}
;{ Properties
;{ 	MaxValue
/*
	Property: MaxValue [get]
		Represents the largest possible value of an MfUInt32. This field is constant.
	Value:
		Var integer
	Gets:
		Gets the largest possible value of an MfUInt32.
	Remarks:
		Constant Property
		Can be accessed using MfUInt32.MaxValue
		Value = 4294967295 (0xFFFFFFFF) hex
*/
	MaxValue[]
	{
		get {
			return 4294967295   ;  0xFFFFFFFF
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
		Represents the smallest possible value of an MfUInt32. This field is constant.
	Value:
		Var integer
	Gets:
		Gets the smallest possible value of an MfUInt32.
	Remarks:
		Can be accessed using MfUInt32.MinValue
		Value = 0 (0x0) hex
*/
	MinValue[]
	{
		get {
			return 0 ; 0x0
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
	Property: Value [get/set]
		Overrides MfPrimitive.Value
		Gets or sets the value associated with the this instance of MfUInt32
	Value:
		Value is a integer and can be var or any type that matches MfType.IsIntegerNumber.
	Sets:
		Set the Value of the instance. Can  be var or any type that matches MfType.IsIntegerNumber. 
	Gets:
		Gets integer Value as var with a value no less then MinValue and no greater than MaxValue.
	Throws
		Throws MfNotSupportedException on set if Readonly is true.
		Throws MfArgumentOutOfRangeException if value is less then MinValue or greater then MaxValue
		Throws MfArgumentException for other errors.
*/
	Value[]
	{
		get {
			return Base.Value
		}
		set {
			this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
			Base.Value := MfUInt32._GetValue(value)
			return Base.Value
		}
	}
;	End:Value ;}
; End:Properties;}
}
/*!
	End of class
*/
