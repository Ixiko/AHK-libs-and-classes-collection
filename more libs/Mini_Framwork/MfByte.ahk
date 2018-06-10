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
	__New(args*) {
		; byte = 0, returnAsObj = false, readonly = False
		; Throws MfNotSupportedException if MfByte Sealed class is extended
		if (this.__Class != "MfByte") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfByte"))
		}
		_byte := 0
		_returnAsObject := false
		_readonly := false

		pArgs := this._ConstructorParams(A_ThisFunc, args*)

		pList := pArgs.ToStringList()
		s := Null
		pIndex := 0
		if (pList.Count > 0)
		{
			s := pList.Item[pIndex].Value
			if ((s = "MfInteger")
				|| (s = "MfInt16")
				|| (s = "MfInt64")
				|| (s = "MfByte"))
			{
				_byte := pArgs.Item[pIndex].Value
				if ((_byte < MfByte.MinValue) || (_byte > MfByte.MaxValue))
				{
					ex := new MfArgumentOutOfRangeException("byte"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
						, MfByte.MinValue, MfByte.MaxValue))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
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
		
		base.__New(_byte, _returnAsObject, _readonly)
		this.m_isInherited := this.__Class != "MfByte"
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
						else if (i = 1) ; byte
						{

							; cannot construct an instacne of MfInt64 here with parameters
							; we are already calling from the constructor
							; create a new instance without parameters and set the properties
							if Mfunc.IsInteger(arg)
							{
								; add as MfInt64 validation will take place in constructor
								_val := new MfInt64()
								_val.ReturnAsObject := false
								_val.Value := arg
								pIndex := p.Add(_val)
							}
							Else
							{
								ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToByte"), e)
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
			try
			{
				_default := MfByte._GetValue(args[2])
			}
			catch e
			{
				CanThrow := true
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
				err := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToByte"), e)
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
				try
				{
					_default := MfByte._GetValue(args[2])
				}
				catch e
				{
					CanThrow := true
				}
			}
		}
		retval := CanThrow = true? 0:_default
		if (CanThrow = true)
		{
			try
			{
				retval := MfByte._GetValue(obj)
			}
			catch e
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToByte"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else
		{
			try
			{
				retval := MfByte._GetValue(obj)
			}
			catch e
			{
				retval := _default
			}
		}
		return retval
	}
; End:GetValue() ;}	
;{ 	_GetValue
	_GetValue(obj) {
		WasFormat := A_FormatInteger
		try
		{
			SetFormat, IntegerFast, D
			retval := 0
			retval .= "" ; necessary for integer fast

			if (IsObject(obj)) {
				T := new MfType(obj)
				if (T.IsIntegerNumber)
				{
					retval := obj.Value
					if ((retval < MfByte.MinValue) || (retval > MfByte.MaxValue))
					{
						ex := new MfArgumentOutOfRangeException("obj"
							, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
							,MfByte.MinValue, MfByte.MaxValue))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
				}
				else if (t.IsFloat)
				{
					
					if ((obj.LessThen(MfByte.MinValue)) || (obj.GreaterThen(MfByte.MaxValue))) {
						ex := new MfArgumentOutOfRangeException("obj"
							, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
							,MfByte.MinValue, MfByte.MaxValue))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					if (obj.LessThen(0.0))
					{
						retval := Ceil(obj.Value)
					} else {
						retval := Floor(obj.Value)
					}
					if ((retval < MfByte.MinValue) || (retval > MfByte.MaxValue))
					{
						ex := new MfArgumentOutOfRangeException("obj"
							, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
							,MfByte.MinValue, MfByte.MaxValue))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
				}
				else
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", "int"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			} else {
				retval := MfByte._GetValueFromVar(obj)
			}
		}
		Catch e
		{
			throw e
		}
		Finally
		{
			SetFormat, IntegerFast, %WasFormat%
		}
		return retval
	}
; 	End:_GetValue ;}
;{ 	_GetValueFromVar
	_GetValueFromVar(varInt) {
		WasFormat := A_FormatInteger
		retval := 0
		retval .= "" ; necessary for integer fast
		try
		{
			SetFormat, IntegerFast, D
			if (Mfunc.IsInteger(varInt)) {
				retval := varInt + 0 ; force conversion from any hex values
				if ((retval < MfByte.MinValue) || (retval > MfByte.MaxValue)) {
					ex := new MfArgumentOutOfRangeException("varInt"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfByte.MinValue, MfByte.MaxValue))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			} else if (Mfunc.IsFloat(varInt)) {
				sf := new MfFloat(varInt)
				if ((sf.LessThen(MfByte.MinValue)) || (sf.GreaterThen(MfByte.MaxValue))) {
					ex := new MfArgumentOutOfRangeException("varInt"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfByte.MinValue, MfByte.MaxValue))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (sf.LessThen(0.0)) {
					retval := Ceil(sf.Value)
				} else {
					retval := Floor(sf.Value)
				}
				if ((retval < MfByte.MinValue) || (retval > MfByte.MaxValue)) {
					ex := new MfArgumentOutOfRangeException("varInt"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfByte.MinValue, MfByte.MaxValue))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			} else {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_ByteVar", "varInt"), "varInt")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		catch e
		{
			if ((MfObject.IsObjInstance(e, MfException)) && (e.Source = A_ThisFunc))
			{
				throw e
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		finally
		{
			SetFormat, IntegerFast, %WasFormat%
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
		if (MfObject.IsObjInstance(args[1], MfParams)) {
			objParams := args[1] ; arg 1 is a MfParams object so we will use it
		} else {
			objParams := new MfParams()
			for index, arg in args
			{
				objParams.Add(arg)
			}
		}
		retval := MfNull.Null
		try {
			strP := objParams.ToString()
		
			if (strP = "MfChar") {
				c := objParams.Item[0]
				if (MfChar.IsDigit(c)) {
					iVal := MfByte._GetValue(MfCharUnicodeInfo.GetDecimalDigitValue(c))
					if ((iVal >= MfByte.MinValue) && (iVal <= MfByte.MaxValue)) {
						retval := iVal
					}
				}
			} else if (strP = "MfString") {
				strV := objParams.Item[0].Value
				if (RegExMatch(strV, "^\s*([-+]?\d{1,3})\s*$", match)) {
					iVal := MfByte._GetValue(match1)
					if ((iVal >= MfByte.MinValue) && (iVal <= MfByte.MaxValue)) {
						retval := iVal
					}
				} else if (RegExMatch(strV, "i)^\s*(-?0x[0-9A-F]{1,8})\s*$", match)) {
					iVal := MfByte._GetValue(match1)
					if ((iVal >= MfByte.MinValue) && (iVal <= MfByte.MaxValue)) {
						retval := iVal
					}
				}
			} else if (strP = "MfByte") {
				retval := objParams.Item[0].Value
			}
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfNull.IsNull(retval)) {
			if (objParams.Data.Contains("ReturnAsObject") && (objParams.Data.Item["ReturnAsObject"] = true)) {
				return new MfByte(retval, true)
			} else {
				return retval
			}
			
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
		wasformat := A_FormatInteger
		SetFormat, Integer, D
		retval := this.Value + 0
		SetFormat, Integer, %wasformat%
		return retval . ""
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
	TryParse(byref byte, args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		;~ if (MfNull.IsNull(Int)) {
			;~ return false
		;~ }
		_isObj := false
		if (IsObject(byte)) {
			if (MfObject.IsObjInstance(byte, "MfByte")) {
				_isObj := true
			} else {
				; Int is an object but not an MfByte instance
				; only MfByte is allowed as object
				return false
			}
			
		}
		if (MfObject.IsObjInstance(args[1], MfParams)) {
			objParams := args[1] ; arg 1 is a MfParams object so we will use it
		} else {
			objParams := new MfParams()
			for index, arg in args
			{
				objParams.Add(arg)
			}
		}
		retval := false
		try {
			strP := objParams.ToString()
		
			if (strP == "MfChar") {
				c := objParams.Item[0]
				if (MfChar.IsDigit(c)) {
					iVal := MfByte._GetValue(MfCharUnicodeInfo.GetDecimalDigitValue(c))
					if ((iVal >= MfByte.MinValue) && (iVal <= MfByte.MaxValue)) {
						if (_isObj = true) {
							byte.Value := iVal
						} else {
							byte := iVal
						}
						retval := true
					}
				}
			} else if (strP == "MfString") {
				strV := objParams.Item[0].Value
				; match values that are from -999 to +999
				if (RegExMatch(strV, "^\s*([-+]?\d{1,3})\s*$", match)) {
					iVal := MfByte._GetValue(match1)
					if ((iVal >= MfByte.MinValue) && (iVal <= MfByte.MaxValue)) {
						if (_isObj = true) {
							byte.Value := iVal
						} else {
							byte := iVal
						}
						retval := true
					}
				} else if (RegExMatch(strV, "i)^\s*(-?0x[0-9A-F]{1,8})\s*$", match)) {
					; matches hex value
					iVal := MfByte._GetValue(match1)
					if ((iVal >= MfByte.MinValue) && (iVal <= MfByte.MaxValue)) {
						if (_isObj = true) {
							byte.Value := iVal
						} else {
							byte := iVal
						}
						retval := true
					}
				} else {
					retval := false
				}
			} 
		} catch e {
			retval := false
		}
		return retval
	}
; End:TryParse() ;}
; End:Methods ;}
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