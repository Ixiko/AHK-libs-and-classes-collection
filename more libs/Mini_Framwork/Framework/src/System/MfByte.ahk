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
/*!
	Class: MfByte
		Represents MfByte object
	Inherits: MfPrimitive
*/
; End:Class Comments ;}
Class MfByte extends MfPrimitive
{
;{ Static Properties
	; type code uniqueq to mfbyte
	TypeCode[]
	{
		get {
			return 21
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
		Initializes a new instance of the MfByte class.
	
	OutputVar := new MfByte([byte, returnAsObj, readonly])
	
	Constructor([byte, retunAsObj, readonly])
		Initializes a new instance of the MfByte class optionally setting the Value property, ReturnAsObject property and the Readonly property.
	Parameters
		byte
			The MfByte object or var containing Byte value to create a new instance with.
		returnAsObj
			Determines if the current instance of MfByte class will return MfByte instances from functions or vars containing integer.
			If omitted value is false.
		readonly
			Determines if the current instance of MfBool class will allow its Value to be altered after it is constructed.
			The Readonly propery will reflect this value after the classe is constructed.
			If omitted value is false
	Remarks
		Sealed class.
		This constructor initializes the MfByte with the integer value of byte.
		Value property to the value of byte.
		ReturnAsObject will have a value of returnAsObj
		Readonly property will have a value of readonly
		If Readonly is true then any attempt to change the underlying value will result in MfNotSupportedException being thrown.
		Variadic Method; This method is Variadic so you may construct an instance of MfParams containing any of the overload
		method parameters listed above and pass in the MfParams instance to the method instead of using the overloads described above.
		See MfParams for more information.
	Throws
		Throws MfNotSupportedException if class is extended.
		Throws MfArgumentException if error in parameter.
		Throws MfNotSupportedException if incorrect type of parameters or incorrect number of parameters.
*/
	__New(int:=0, retunAsObj:=false, readonly:=false) {
		; int = 0, returnAsObj = false, ReadOnly = false
		; Throws MfNotSupportedException if MfSByte Sealed class is extended
		if (this.__Class != "MfByte")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfByte"))
		}

		_intResult := MfByte.GetValue(int,"NaN", true)
		if (_intResult == "NaN")
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToByte"))
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
/*
	Method: Add()
	
	OutputVar := instance.Add(value)
	
	Add(value)
		Adds MfByte value to current instance of MfByte.
	Parameters
		value
			The value to add to the current instance.
			Can be any type that matches IsNumber or var integer.
	Returns
		Returns current instance of MfByte with an update value.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfNotSupportedException if Readonly is true.
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentException if value is not an instance of MfByte and can not be converted into integer value.
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
			_value :=  MfInteger.GetValue(value) ; may want to add negative value
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_newVal := this.Value + _value
		if ((_newVal < MfByte.MinValue) || (_newVal > MfByte.MaxValue)) {
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, MfByte.MinValue, MfByte.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
		return this._ReturnByte(this)
	}
; End:Add() ;}
;{ 	CompareTo()			- Overrides	- MfObject
/*
	Method: CompareTo()
	
		Overrides MfObject.CompareTo
		OutputVar := instance.CompareTo(obj)
	
	CompareTo(obj)
		Compares this instance to a specified MfByte object.
	Parameters
		obj
			A MfByte object to compare.
	Returns
		Returns A number indicating the position of this instance in the sort order in relation to the value parameter.
		Return obj  Less than zero This instance precedes obj value. Zero This instance has the same position in the sort order as obj.
		Greater than zero This instance follows obj.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfByte.
	Remarks
		Compares this instance to a specified MfByte object and indicates whether this instance precedes, follows, or appears in the
		same position in the sort order as the specified MfByte object.
*/
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value)) {
			return 1
		}
		if (!MfObject.IsObjInstance(obj, MfByte)) {
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
		Divides the current instance of MfByte by the divisor value.
	Parameters
		value
		The Divisor value to divide the current instance Value by.
		Can be any type that matches IsNumber. or var number.
	Returns
		If ReturnAsObject is true then returns current instance of MfByte with an updated Value; Otherwise returns Value as var.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfDivideByZeroException if value is zero.
		Throws MfArithmeticException if the operation fails or value is not an instance of MfByte and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if dividing result is less then Minvalue and greater than MaxValue
	Remarks
		If the result of the operation is not a whole number such as 4/2 but rather a float number such as 8/3 (8/3 = 2.6666...) then the
		result will always be the whole number portion of the operation.
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
			return this._ReturnByte(this)
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
		if ((_newVal < MfByte.MinValue) || (_newVal > MfByte.MaxValue)) {
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, MfByte.MinValue, MfByte.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
		return this._ReturnByte(this)

	}
; 	End:Divide ;}
;{ 	Equals()			- Overrides - MfObject
/*
	Method: Equals()
		Overrides MfObject.Equals()
	
	OutputVar := instance.Equals(value)
	
	Equals(value)
		Gets if this instance Value is the same as the value
	Parameters
		value
			The Object or var containing, byte to compare to current instance.
			Can be any type that matches IsNumber. 
	Returns
		Returns Boolean value of true if this Value and value are equal; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
	Remarks
		If value is unable to be converted to a byte then false will be returned.
		If value is a float or MfFloat instance then method will alway round down for positive number and round up for negative numbers.
		For instance 2.8 is converted to 2 and -2.8 is converted to -2.
*/
	Equals(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value))
		{
			return false
		}
		retval := false
		_value := 0
		try
		{
			_value :=  MfByte.GetValue(value)
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
/*!
	Method:GetHashCode()
		Overrides MfObject.GetHashCode()
	
	OutputVar := instance.GetHashCode()
	
	GetHashCode()
		Gets A hash code for the current MfByte.
	Returns
		Returns A hash code for the current MfByte.
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
		return this.Value
	}
; End:GetHashCode() ;}
;{ 	GetTypeCode()
/*
	Method: GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfByte Type Code.
	Returns
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfByte.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.Byte
	}
; End:GetTypeCode() ;}
;{ 	GetValue()			- Overrides	- MfPrimitive
	/*!
		Method: GetValue(obj, [, default])
			GetValue() Gets the MfByte number from [MfByte](MfByte.html) object or
			[MfEnumBase](MfEnumBase.html) derived objects or var containing MfByte  
			Overrides [MfPrimitive.GetValue()](MfPrimitive.getvalue.html)
		Parameters:
			obj - The [MfByte](MfByte.html) object or var containing Integer
			default - The value to return if *obj* is null, Default is **0**
		Returns:
			Returns a var containing a MfByte or 0 if *obj* is null or empty
		Throws:
			Throws [MfArgumentException](MfArgumentException.html) if argument *obj* is Object but is not 
			derived from [MfObject](MfObject.html) or a valid instance of [MfByte](MfByte.html) class.
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
			_default := MfByte._GetValue(args[2], false)
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
				_default := MfByte._GetValue(args[2], false)
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
				retval := MfByte._GetValue(obj)
			}
			catch e
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt64"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else
		{
			retval := MfByte._GetValue(obj, false)
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
			T := new MfType(obj)
			if (T.IsIntegerNumber)
			{
				retval := obj.Value
				if ((retval < MfByte.MinValue) || (retval > MfByte.MaxValue))
				{
					if (!CanThrow)
					{
						return "NaN"
					}
					ex := new MfArgumentOutOfRangeException("obj"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfByte.MinValue, MfByte.MaxValue))
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
				if ((retval < MfByte.MinValue) || (retval > MfByte.MaxValue)) {
				if (!CanThrow)
				{
					return "NaN"
				}
					ex := new MfArgumentOutOfRangeException("varInt"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfByte.MinValue, MfByte.MaxValue))
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
			retval := MfByte._GetValueFromVar(obj, CanThrow)
		}
		return retval
	}
; 	End:_GetValue ;}
;{ 	_GetValueFromVar
	_GetValueFromVar(varInt, CanThrow=true) {
		strVarInt := varInt . ""
		if (Mfunc.IsInteger(varInt)) {
			retval := varInt
			if ((retval < MfByte.MinValue) || (retval > MfByte.MaxValue)) {
				if (!CanThrow)
				{
					return "NaN"
				}
				ex := new MfArgumentOutOfRangeException("varInt"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
					,MfByte.MinValue, MfByte.MaxValue))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else if (Mfunc.IsFloat(varInt)) {
			retval := Floor(varInt)
			if ((retval < MfByte.MinValue) || (retval > MfByte.MaxValue)) {
				if (!CanThrow)
				{
					return "NaN"
				}
				ex := new MfArgumentOutOfRangeException("varInt"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
					,MfByte.MinValue, MfByte.MaxValue))
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
	
	GreaterThen(value)
		Compares the current MfByte object to a specified MfByte object and returns an indication of their relative values.
	Parameters
		value
			The Object or var containing, byte to compare to current instance.
			Can be any type that matches IsNumber. 
	Returns
		Returns true if the current instance has greater value then the value instance; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfByte and can not be converted into byte value.
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
		if (MfObject.IsObjInstance(value, MfByte)) {
			return this.Value > value.Value
		}
		try
		{
			val := MfByte.GetValue(value)
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
/*
	Method: GreaterThenOrEqual()
	
	OutputVar := instance.GreaterThenOrEqual(value)
	
	GreaterThenOrEqual(value)
		Compares the current MfByte object to a specified MfByte object and returns an indication of their relative values.
	Parameters
		value
			The Object or var containing, byte to compare to current instance.
			Can be any type that matches IsNumber. 
	Returns
		Returns true if the current instance has greater or equal value then the value instance; otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfByte and can not be converted into byte value.
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
		if (MfObject.IsObjInstance(value, MfByte)) {
			return this.Value >= value.Value
		}
		try
		{
			val := MfByte.GetValue(value)
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
/*
	Method: LessThen()
	
	OutputVar := instance.LessThen(value)
	
	LessThen(value)
		Compares the current MfByte object to a specified MfByte object and returns an indication of their relative values.
	Parameters
		value
			The Object or var containing, byte to compare to current instance.
			Can be any type that matches IsNumber. 
	Returns
		Returns true if the current instance has less value then the value instance; otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfByte and can not be converted into byte value.
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
		if (MfObject.IsObjInstance(value, MfByte)) {
			return this.Value < value.Value
		}
		try
		{
			val := MfByte.GetValue(value)
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
		Compares the current MfByte object to a specified MfByte object and returns an indication of their relative values.
	Parameters
		value
			The Object or var containing, byte to compare to current instance.
			Can be any type that matches IsNumber. 
	Returns
		Returns true if the current instance has less or equal value then the value instance; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfByte and can not be converted into byte value.
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
		if (MfObject.IsObjInstance(value, MfByte)) {
			return this.Value <= value.Value
		}
		try
		{
			val := MfByte.GetValue(value)
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
		Multiplies the current instance of MfByte by the value.
	Parameters
		value
			The value to multiply the current instance Value by.
			Can be any type that matches IsNumber. or var number.
	Returns
		If ReturnAsObject is true then returns current instance of MfByte with an updated Value; Otherwise returns Value as var.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfDivideByZeroException if value is zero.
		Throws MfArithmeticException if the operation fails or value is not an instance of MfByte and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if dividing result is less then Minvalue and greater than MaxValue
	Remarks
		If the result of the operation is not a whole number such as 4*3 but rather a float number such as 4*3.3 (4 * 3.2 = 13.2) then the result
		will always be the whole number portion of the operation.
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
			return this._ReturnByte(this)
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
			return this._ReturnByte(this)
		}
		_newVal := this.Value * _value
		_newVal := _newVal > 0?Floor(_newVal):Ceil(_newVal)
		if ((_newVal < MfByte.MinValue) || (_newVal > MfByte.MaxValue)) {
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, MfByte.MinValue, MfByte.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
		return this._ReturnByte(this)

	}
; 	End:Multiply ;}
;{ 	Parse()
/*
	Method: Parse()
	
	OutputVar := MfByte.Parse(obj)
	Parse(obj)
		Converts the obj representation of a number to its MfByte equivalent
	Parameters
		obj
			An object convert.
			Can be instance of MfChar, MfString
			Can be var containing string, integer, hex value
			Obj can also be instance of MfParams.
	Returns
		Returns var containing integer equivalent to the number contained in obj or throws an error if unable to parse obj param.
		Variadic Method; This method is Variadic so you may construct an instance of MfParams containing any of the overload method
		parameters listed above and pass in the MfParams instance to the method instead of using the overloads described above.
		See MfParams for more information.
	Remarks
		Static Method
		Converts the obj representation of a number to its MfByte equivalent.
		If MfParams is passed in with Data key of ReturnAsObject and value set to true then parsed result will be returned as an instance
		of MfByte; Otherwise a var integer will be returned. See example below.

		When parsing a MfChar instance the MfChar instance must be Numeric to parse successfully.
		See MfChar.IsNumber.
		
		Variadic Method; This method is Variadic so you may construct an instance of MfParams containing any of the overload method parameters listed above and pass in the MfParams instance to the method instead of using the overloads described above. See MfParams for more information.
	Throws
		Throws MfException if parse fails.
		Throws MfFormatException if unable to read obj.
		Throws MfInvalidOperationException if not called as static method.
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
				retval := MfByte._Parse(strV, ns, MfNumberFormatInfo.CurrentInfo, A_ThisFunc)
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
					retval := MfByte._Parse(str.Value, ns, MfNumberFormatInfo.GetInstance(obj), A_ThisFunc)
				}
				else if (MfObject.IsObjInstance(obj, MfNumberStyles))
				{
					retval := MfByte._Parse(str.Value, obj.Value, MfNumberFormatInfo.CurrentInfo, A_ThisFunc)
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
				retval := MfByte._Parse(str.Value, ns.Value, MfNumberFormatInfo.GetInstance(fInfo), A_ThisFunc)
			}
			else if (strP = "MfByte")
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
			return new MfByte(retval, true)
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
		Subtracts Byte value to current instance of MfByte.
	Parameters
		value
			The value to subtract from the current instance.
			Can be any type that matches IsNumber or var integer.
	Returns
		Returns current instance of MfByte with an update value.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfNotSupportedException if Readonly is true.
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentException if value is not an instance of MfByte and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if subtracting value is Less then Minvalue and greater than MaxValue
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
			_value :=  MfInteger.GetValue(value) ; may want to subtract negative value
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_newVal := this.Value - _value
		if ((_newVal < MfByte.MinValue) || (_newVal > MfByte.MaxValue)) {
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, MfByte.MinValue, MfByte.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
		return this._ReturnByte(this)
	}
; End:Add() ;}
;{ 	ToString()			- Overrides	- MfPrimitive
/*
	Method: ToString()
		Overrides MfPrimitive.ToString()

	OutputVar := instance.ToString()

	ToString()
		Gets a string representation of the MfByte instance.
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
	
	OutputVar := MfByte.TryParse(byte, obj)
	
	TryParse(byref byte, obj)
		Converts the obj representation of a number to its Integer equivalent. A return value indicates whether the conversion succeeded.
	Parameters
		byte
			Contains the value equivalent to the number contained in obj, if the conversion succeeded.
			The conversion fails if the obj parameter is not of the correct format, or represents a number less than
			MinValue or greater than MaxValue.
		obj
			An object convert.
			Can be instance of MfChar, MfString
			Can be var containing string, integer, hex value
			Obj can also be instance of MfParams.
	Returns
		Returns true if parse is a success; Otherwise false
	Throws
		Throws MfInvalidOperationException if not called as static method.
	Remarks
		If parameter int is passed in as an object it must in initialized as an instance of MfByte first. Eg: myByte := new MfByte(0)
		If parameter int is passed in as var it must in initialized as integer first. Eg: myByte := 0
		White spaces are allowed at the beginning or end of the string to parse.
		When parsing a MfChar instance the MfChar instance must be Numeric to parse successfully.
		See MfChar.IsNumber.
*/
	TryParse(byref Byte, args*) {
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
			retval := MfByte._TryParse(strV, ns, MfNumberFormatInfo.CurrentInfo, num)
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
				retval := MfByte._TryParse(str.Value, obj.Value, MfNumberFormatInfo.CurrentInfo, num)
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
			retval := MfByte._TryParse(str.Value, ns.Value, MfNumberFormatInfo.GetInstance(fInfo), num)
		}
		else if (strP = "MfByte")
		{
			num := objParams.Item[0].Value
			retval := true
		}
		if (retval)
		{
			if (IsObject(byte))
			{
				if (!MfObject.IsObjInstance(byte, MfByte))
				{
					byte := new MfByte()
				}
				byte.Value := num
			}
			else
			{
				byte := num
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
; End:Methods ;}
;{ Internal Methods
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
			num := MfNumber.ParseInt32(s, style, info)
		}
		catch e
		{
			if (MfObject.IsObjInstance(e, MfOverflowException))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Byte"), e)
				ex.SetProp(A_LineFile, A_LineNumber, methodName)
				throw ex
			}
			throw e
		}
		if ((style & 512) != 0) {
			; MfNumberStyles.Instance.AllowHexSpecifier = 512
			if (num < MfByte.MinValue || num > MfByte.MaxValue)
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Byte"), e)
				ex.SetProp(A_LineFile, A_LineNumber, methodName)
				throw ex
			}
			return num
		}
		else
		{
			if (num < MfByte.MinValue || num > MfByte.MaxValue)
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Byte"))
				ex.SetProp(A_LineFile, A_LineNumber, methodName)
				throw ex
			}
			return num
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
		result := MfNumber.TryParseInt32(s, style, info, num)
		if (result = false)
		{
			return false
		}
		if ((style & 512) != 0) {
			; MfNumberStyles.Instance.AllowHexSpecifier = 512
			if (num < MfByte.MinValue || num > MfByte.MaxValue)
			{
				return false
			}
			Out := num
			return true
		}
		else
		{
			if (num < MfByte.MinValue || num > MfByte.MaxValue)
			{
				return false
			}
			Out := num
			return true
		}
	}
; 	End:_TryParse ;}
; End:Internal Methods ;}
;{ Properties
;{ 	MaxValue
	
	;
	/*!
		Property: MaxValue [get]
			Represents the largest possible value of an [MfByte](MfByte.html). This field is constant.
		Remarks:
			Can be accessed using 'MfByte.MaxValue'  
			Value = 255
	*/
	MaxValue[]
	{
		get {
			return 255 ;  0xFF
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MaxValue ;}
;{ 	MinValue
	/*!
		Property: MinValue [get]
			Represents the smallest possible value of an MfByte. This field is constant.
		Remarks:
			Can be accessed using 'MfByte.MinValue'  
			Value = 0
	*/
	MinValue[]
	{
		get {
			return 0 ;-0x0
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MinValue ;}
;{	Value
	/*!
		Property: Value [get/set]
			Gets or sets the value associated with the this instance of MfByte.
			Overrides MfPrimitive.Value.
		Value:
			Value is a byte and can be var or any type that matches MfType.IsIntegerNumber.
		Get:
			Gets integer value as var with a value no less then MinValue and no greater than MaxValue
		Set:
			Set the value of the instance. Can  be var or any type that matches MfType.IsIntegerNumber. 
		Throws:
			Throws MfNotSupportedException on set if Readonly is true.
			Throws MfArgumentOutOfRangeException if value is less then MinValue or greater then MaxValue
			Throws MfArgumentException for other errors.
*/
	Value[]
	{
		get {
			return this.m_Value
		}
		set {
			this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
			this.m_Value := MfByte._GetValue(value)
			return this.m_Value
		}
	}
;	End:Value ;}
; End:Properties;}
}
/*!
	End of class
*/