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

Class MfInt extends MfInteger
{

}
Class MfInt32 extends MfInteger
{

}

;{ Class Comments
/*!
	Class: MfInteger
		Represents Integer 32 bit object
	Inherits:
		MfPrimitive
*/
; End:Class Comments ;}
Class MfInteger extends MfPrimitive
{
;{ Static Properties
	TypeCode[]
	{
		get {
			return 12
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}

; End:Static Methods ;}
;{ Constructor
/*
	Constructor()
		Initializes a new instance of the MfInteger class.
	
	OutputVar := new MfInteger([int, returnAsObj, readonly])
	
	Constructor([int, retunAsObj, readonly])
		Initializes a new instance of the MfInteger class optionally setting the Value property, ReturnAsObject property and the Readonly property.
	Parameters
		int
			The MfInteger object or var containing integer to create a new instance with.
		returnAsObj
			Determines if the current instance of MfInteger class will return MfInteger instances from functions or vars containing integer.
			If omitted value is false
		readonly
				Determines if the current instance of MfInteger class will allow its Value to be altered after it is constructed.
			The read-only propery will reflect this value after the classe is constructed.
			If omitted value is false
	Remarks
		Sealed Class.
		This constructor initializes the MfInteger with the integer value of int.
		Value property to the value of int.
		ReturnAsObject will have a value of returnAsObj
		Readonly will have a value of readonly.
		If Readonly is true then any attempt to change the underlying value will result in MfNotSupportedException being thrown.
		Variadic Method; This method is Variadic so you may construct an instance of MfParams containing any of the overload method
		parameters listed above and pass in the MfParams instance to the method instead of using the overloads described above.
		See MfParams for more information.
	Throws
		Throws MfNotSupportedException if class is extended.
		Throws MfArgumentException if error in parameter.
		Throws MfNotSupportedException if incorrect type of parameters or incorrect number of parameters.
*/
	__New(args*) {
		; int = 0, returnAsObj = false, ReadOnly = false
		; Throws MfNotSupportedException if MfInteger Sealed class is extended
		bThrowSealed := True
		if ((this.__Class = "MfInteger")
			|| (this.__Class = "MfInt")
			|| (this.__Class = "MfInt32")) {
			bThrowSealed := False
		}
		if (bThrowSealed)
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfInteger"))
		}
		_int := 0
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
				_int := pArgs.Item[pIndex].Value
				if ((_int < MfInteger.MinValue) || (_int > MfInteger.MaxValue))
				{
					ex := new MfArgumentOutOfRangeException("int"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfInteger.MinValue, MfInteger.MaxValue))
					ex.Source := A_ThisFunc
					ex.File := A_LineFile
					ex.Line := A_LineNumber
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
		
		base.__New(_int, _returnAsObject, _readonly)
		this.m_isInherited := this.__Class != "MfInteger"
	}

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
						else if (i = 1) ; int
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
								ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), e)
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
; End:Constructor ;}
;{ Methods
;{	Add()
/*
	Method: Add()
	
	instance.Add(value)
	
	Add(value)
		Adds MfInteger value to current instance of MfInteger.
	Parameters
		value
			The value to add to the current instance.
			Can be any type that matches IsNumber. or var integer.
	Returns
		If ReturnAsObject is true then returns current instance of MfInteger with an updated value; Otherwise returns var containing integer.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentException if value is not an instance of MfInteger and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if adding value is less then MinValue and greater than MaxValue
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
		if ((_newVal < MfInteger.MinValue) || (_newVal > MfInteger.MaxValue)) {
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, MfInteger.MinValue, MfInteger.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
		return this._ReturnInteger(this)
	}
; End:Add() ;}
;{ 	Divide
/*
	Method: Divide()
		OutputVar := instance.Divide(value)
	
	Divide(value)
		Divides the current instance of MfInteger by the divisor value.
	Parameters
		value
			The Divisor value to divide the current instance Value by.
			Can be any type that matches IsNumber. or var number.
	Returns
		If ReturnAsObject is true then returns current instance of MfInteger with an updated Value; Otherwise returns Value as var.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfDivideByZeroException if value is zero.
		Throws MfArithmeticException if the operation fails or value is not an instance of MfInteger and can not be converted into integer value.
		Throws MfArgumentOutOfRangeException if dividing result is less then MinValue and greater than MaxValue
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
			return this._ReturnInteger(this)
		}
		_value := 0
		try
		{
			_value :=  MfInt64.GetValue(value)
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
		if ((_newVal < MfInteger.MinValue) || (_newVal > MfInteger.MaxValue)) {
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, MfInteger.MinValue, MfInteger.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
		return this._ReturnInteger(this)

	}
; 	End:Divide ;}
;{ 	CompareTo()			- Overrides	- MfObject
/*
	Method: CompareTo()
		Overrides MfObject.CompareTo
	
	OutputVar := instance.CompareTo(obj)
	
	CompareTo(obj)
		Compares this instance to a specified MfInteger instance.
	Parameters
		obj
			A MfInteger object to compare to current instance.
	Returns
		Returns a var containing integer indicating the position of this instance in the sort order in relation to the value parameter.
		Return Value Description Less than zero This instance precedes obj value. Zero This instance has the same position in the sort order as value.
		Greater than zero This instance follows
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfInteger.
	Remarks
		Compares this instance to a specified MfInteger instance and indicates whether this instance precedes, follows, or appears in the same
		position in the sort order as the specified MfInteger instance.
*/
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value)) {
			return 1
		}
		if (!MfObject.IsObjInstance(obj, MfInteger)) {
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
;{ 	Equals()			- Overrides - MfObject
/*
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
			_value :=  MfInteger.GetValue(value)
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
		Gets A hash code for the MfInteger instance.
	Returns
		A 32-bit signed integer hash code as var.
	Throws
		Throws MfNullReferenceException if object is not an instance.
*/
	GetHashCode() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return this.Value
	}
; End:GetHashCode() ;}
;{ 	GetTypeCode()
/*
	Method: GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfInteger Type Code.
	Returns
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfInteger.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.Int32
	}
; End:GetTypeCode() ;}
;{ 	GetValue()			- Overrides	- MfPrimitive
/*
	Method: GetValue()
		Overrides MfPrimitive.GetValue().
	
	OutputVar := MfInteger.GetValue(Obj)
	OutputVar := MfInteger.GetValue(Obj, Default)
	OutputVar := MfInteger.GetValue(Obj, Default, AllowAny)
	
	MfInteger.GetValue(Obj)
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
	
	MfInteger.GetValue(Obj, Default)
		Gets a integer number from Obj or returns Default value if Obj is unable to be converted to integer.
		Default must be a value that can be converted to integer or it will be ignored if Obj can not be converted to integer and an error will be thrown.
	Parameters
		Obj
			The Object or var containing, integer or hex value
			Can be any type that matches IsIntegerNumber. 
		Default
			The value to return if Obj is Cannot be converted
			Can be any type that matches IsIntegerNumber or var of integer.
	Returns
		Returns a var containing a integer or Default value if Obj is unable to be converted to integer.
	Remarks
		Static Method
		If Default is not a valid integer or MfInteger instance then GetValue will throw an error if Obj can not be converted to integer. 
		If Default can not be converted to a integer then this would method will yield the same results as calling MfInteger.GetValue(Obj).
	Throws
		Throws MfInvalidOperationException if not called as a static method.
	
	MfInteger.GetValue(Obj, Default, AllowAny)
		Gets a integer number from Obj or returns Default value if Obj is unable to be converted to integer.
	Parameters
		Obj
			The Object or var containing, integer or hex value
			Can be any type that matches IsIntegerNumber. 
		Default
			The value to return if Obj is Cannot be converted
			Can be any type that matches IsIntegerNumber or var of integer.
		AlowAny
			Determines if Default can be a value other then integer. If true Default can be any var, Object or null;
			Otherwise Default must be a integer value.
	Remarks
		Static Method.
		If AllowAny is true then Default can be any value including var, object or null.
		However if AllowAny is false then this method will yield the same result as calling MfInteger.GetValue(Obj, Default).
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentException if AllowAny is not a valid boolean.
	
	General Remarks
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
			try
			{
				_default := MfInteger._GetValue(args[2])
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
				try
				{
					_default := MfInteger._GetValue(args[2])
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
				retval := MfInteger._GetValue(obj)
			}
			catch e
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else
		{
			try
			{
				retval := MfInteger._GetValue(obj)
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
					if ((retval < MfInteger.MinValue) || (retval > MfInteger.MaxValue))
					{
						ex := new MfArgumentOutOfRangeException("obj"
							, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
							,MfInteger.MinValue, MfInteger.MaxValue))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
				}
				else if (t.IsFloat)
				{
					if ((obj.LessThen(MfInteger.MinValue)) || (obj.GreaterThen(MfInteger.MaxValue))) {
						ex := new MfArgumentOutOfRangeException("obj"
							, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
							,MfInteger.MinValue, MfInteger.MaxValue))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					if (obj.LessThen(0.0))
					{
						retval := Ceil(obj.Value)
					} else {
						retval := Floor(obj.Value)
					}
					if ((retval < MfInteger.MinValue) || (retval > MfInteger.MaxValue))
					{
						ex := new MfArgumentOutOfRangeException("obj"
							, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
							,MfInteger.MinValue, MfInteger.MaxValue))
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
				retval := MfInteger._GetValueFromVar(obj)
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
				if ((retval < MfInteger.MinValue) || (retval > MfInteger.MaxValue)) {
					ex := new MfArgumentOutOfRangeException("varInt"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfInteger.MinValue, MfInteger.MaxValue))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			} else if (Mfunc.IsFloat(varInt)) {
				sf := new MfFloat(varInt)
				if ((sf.LessThen(MfInteger.MinValue)) || (sf.GreaterThen(MfInteger.MaxValue))) {
					ex := new MfArgumentOutOfRangeException("varInt"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfInteger.MinValue, MfInteger.MaxValue))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (sf.LessThen(0.0)) {
					retval := Ceil(sf.Value)
				} else {
					retval := Floor(sf.Value)
				}
				if ((retval < MfInteger.MinValue) || (retval > MfInteger.MaxValue)) {
					ex := new MfArgumentOutOfRangeException("varInt"
						, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
						,MfInteger.MinValue, MfInteger.MaxValue))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			} else {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IntegerVar", "varInt"), "varInt")
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
	
	GreaterThan(value)
		Compares the current MfInteger object to a specified MfInteger instance and returns an indication of their relative values.
	Parameters
		value
			The Object or var containing, integer to compare to current instance.
			Can be any type that matches MfType.IsNumber. 
	Returns
		Returns true if the current instance has greater value then the value instance; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfInteger and can not be converted into integer value.
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
		if (MfObject.IsObjInstance(value, MfInteger)) {
			return this.Value > value.Value
		}
		try
		{
			val := MfInteger.GetValue(value)
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
		Method: GreaterThenOrEqual(value)
			CompareTo() Compares the current [MfInteger](MfInteger.html) object to a specified 
				[MfInteger](MfInteger.html) object and returns an indication of their relative values.  
		Overrides [MfObject.CompareTo](MfObject.CompareTo.html)
		Parameters:
			value - A [MfInteger](MfInteger.html) object to compare.
		Returns:
			Returns **true** if the current instance has greater or equal value then the *value* instance; otherwise **false**.
		Throws:
			Throws [MfArgumentException](MfArgumentException.html) if *value* is not an instance of [MfInteger](MfInteger.html).
	*/
	GreaterThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfInteger)) {
			return this.Value >= value.Value
		}
		if (this.Value >= value.Value) {
			retval := true
		}
		try
		{
			val := MfInteger.GetValue(value)
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
/*!
	Method: Is()
		Overrides MfObject.Is()
	
	OutputVar := instance.Is(ObjType)

	Is(ObjType)
		Gets if current instance of MfInteger is of the same type as ObjType or derived from ObjType.
	Parameters
		ObjType
			The object or type to compare to this instance Type.
			ObjType can be an instance of MfType or an object derived from MfObject or an instance of or a string containing
			the name of the object type such as "MfObject"
	Returns
		Returns true if current object instance is of the same Type as the ObjType or if current instance is derived
		from ObjType or if ObjType = "boolean"; Otherwise false.
	Remarks
		If a string is used as the Type case is ignored so "MfObject" is the same as "mfobject"
*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = MfType.TypeCodes[MfInteger.TypeCode]) {
			return true
		}
		if ((typeName = "MfInteger") 
			|| (typeName = "MfInt32")
			|| (typeName = "MfInt")) {
			return true
		}
		return base.Is(typeName)
	}
; End:Is() ;}
;{ 	LessThen
/*
	Method: LessThen()

	OutputVar := instance.LessThen(value)

	LessThen(value)
		Compares the current MfInteger object to a specified MfInteger object and returns an indication of their relative values.
	Parameters
		value
			The Object or var containing, integer to compare to current instance.
			Can be any type that matches MfType.IsNumber. 
	Returns
		Returns true if the current instance has less value then the value instance; otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfInteger and can not be converted into integer value.
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
		if (MfObject.IsObjInstance(value, MfInteger)) {
			return this.Value < value.Value
		}
		if (this.Value < value.Value) {
			retval := true
		}
		try
		{
			val := MfInteger.GetValue(value)
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
/*!
	Method: LessThenOrEqual()
	
	OutputVar := instance.LessThenOrEqual(value)
	
	LessThenOrEqual(value)
		Compares the current MfInteger object to a specified MfInteger object and returns an indication of their relative values.
	Parameters
		value
		The Object or var containing, integer to compare to current instance.
		Can be any type that matches MfType.IsNumber. 
	Returns
		Returns true if the current instance has less or equal value then the value instance; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfInteger and can not be converted into integer value.
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
		if (MfObject.IsObjInstance(value, MfInteger)) {
			return this.Value <= value.Value
		}
		try
		{
			val := MfInteger.GetValue(value)
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
		Multiplies the current instance of MfInteger by the value.
	Parameters
		value
		The value to multiply the current instance Value by.
		Can be any type that matches MfType.IsNumber. or var number.
	Returns
		If ReturnAsObject is true then returns current instance of MfInteger with an updated Value; Otherwise returns Value as var.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfDivideByZeroException if value is zero.
		Throws MfArithmeticException if the operation fails or value is not an instance of MfInteger and can not be converted into integer value.
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
			return this._ReturnInteger(this)
		}
		_value := 0
		try
		{
			_value :=  MfInt64.GetValue(value)
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_value = 0)
		{
			return this._ReturnInteger(this)
		}
		_newVal := this.Value * _value
		_newVal := _newVal > 0?Floor(_newVal):Ceil(_newVal)
		if ((_newVal < MfInteger.MinValue) || (_newVal > MfInteger.MaxValue)) {
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, MfInteger.MinValue, MfInteger.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
		return this._ReturnInteger(this)

	}
; 	End:Multiply ;}
;{ 	Parse()
/*!
	Method: Parse()
	
	OutputVar := MfInteger.Parse()
	
	Parse(obj)
		Converts the obj representation of a number to its MfInteger equivalent
	Parameters
		obj
			An object to convert.
			Can be instance of MfChar, MfString
			Can be var containing string, integer
			Can also be instance of MfParams.
	Returns
		Converts the obj representation of a number to its MfInteger equivalent.
		If MfParams is passed in with Data key of ReturnAsObject and value set to true then parsed result will be returned as an instance of MfInteger;
		Otherwise a var integer will be returned.
	Remarks
		Static Method
		Converts the obj representation of a number to its MfInteger equivalent.
		If obj parameter is an Object then it must be instance from MfObject or be an instance of MfParams.
		If MfParams is passed in with Data key of ReturnAsObject and value set to true then parsed result will be returned as an instance of MfInteger;
		otherwise a var integer will be returned.
	Throws
		Throws MfInvalidOperationException if not called as static method.
		Throws MfFormatException unable to parse obj.
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
					retval := MfInteger.GetValue(MfCharUnicodeInfo.GetDecimalDigitValue(c))
				}
			} else if (strP = "MfString") {
				strV := objParams.Item[0].Value
				if (RegExMatch(strV, "^\s*([-+]?\d{1,10})\s*$", match)) {
					iVal := MfInteger.GetValue(match1)
					if ((iVal >= MfInteger.MinValue) && (iVal <= MfInteger.MaxValue)) {
						retval := iVal
					}
				} else if (RegExMatch(strV, "i)^\s*(-?0x[0-9A-F]{1,8})\s*$", match)) {
					iVal := MfInteger.GetValue(match1)
					if ((iVal >= MfInteger.MinValue) && (iVal <= MfInteger.MaxValue)) {
						retval := iVal
					}
				}
			} else if (strP = "MfInteger") {
				retval := objParams.Item[0].Value
			}
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		if (!MfNull.IsNull(retval)) {
			if (objParams.Data.Contains("ReturnAsObject") && (objParams.Data.Item["ReturnAsObject"] = true)) {
				return new MfInteger(retval, true)
			} else {
				return retval
			}
			
		}
		ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
		ex.Source := A_ThisFunc
		ex.File := A_LineFile
		ex.Line := A_LineNumber
		throw ex
	}
; End:Parse() ;}
;{	Subtract()
/*!
	Method: Subtract()
	
	OutputVar := instance.Subtract(value)
	
	Subtract(value)
		Subtracts MfInteger value to current instance of MfInteger.
	Parameters
		value
			The value to subtract from the current instance.
			Can be any type that matches IsIntegerNumber. or var integer.
	Returns
		If ReturnAsObject is true then returns current instance of MfInteger with an updated value; Otherwise returns var containing integer.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfArgumentException if value is not an instance of MfInteger and can not be converted into integer value.
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
		if ((_newVal < MfInteger.MinValue) || (_newVal > MfInteger.MaxValue)) {
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, MfInteger.MinValue, MfInteger.MaxValue))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.Value := _newVal
		return this._ReturnInteger(this)
	}
; End:Add() ;}
;{ 	ToString()			- Overrides	- MfPrimitive
/*
	Method: ToString()
	
	Overrides MfPrimitive.ToString()
	OutputVar := instance.ToString()
	
	ToString()
		Gets a string representation of the MfInteger instance.
	Returns
		Returns string var representing current instance Value.
	Throws
		Throws MfNullReferenceException if called as a static method
*/
	ToString() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		wasformat := A_FormatInteger
		SetFormat, IntegerFast, D
		retval := this.Value + 0
		SetFormat, IntegerFast, %wasformat%
		return retval . ""
	}
;  End:ToString() ;}
;{ 	TryParse()
/*
	Method: TryParse()
	
	OutputVar := MfInt64.TryParse(int, obj)
	
	TryParse(byref int, obj)
		Converts the obj representation of a number to its Integer equivalent. A return value indicates whether the conversion succeeded.
	Parameters
		int
		Contains the value equivalent to the number contained in obj, if the conversion succeeded.
		The conversion fails if the obj parameter is not of the correct format, or represents a number less than MinValue or greater than MaxValue.
		obj
			An object to convert.
			Can be instance of MfChar, MfString
			Can be var containing string, integer, hex value
			Obj can also be instance of MfParams.
	Returns
	Returns true if parse is a success; Otherwise false
	Remarks
		If parameter int is passed in as an object it must in initialized as an instance of MfInteger first. Eg: myInt := new MfInteger(0)
		If parameter int is passed in as var it must in initialized as integer first. Eg: myInt := 0
		White spaces are allowed at the beginning or end of the string to parse.
		When parsing a MfChar instance the MfChar instance must be Numeric to parse successfully.
		See MfChar.IsNumber.
	Throws
		Throws MfInvalidOperationException if not called as static method.
*/
	TryParse(byref int, args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		;~ if (MfNull.IsNull(Int)) {
			;~ return false
		;~ }
		_isObj := false
		if (IsObject(Int)) {
			if (MfObject.IsObjInstance(int, "MfInteger")) {
				_isObj := true
			} else {
				; Int is an object but not an MfInteger instance
				; only MfInteger is allowed as object
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
		
			if (strP = "MfChar") {
				c := objParams.Item[0]
				if (MfChar.IsDigit(c)) {
					if (_isObj = true) {
						int.Value := MfInteger.GetValue(MfCharUnicodeInfo.GetDecimalDigitValue(c))
					} else {
						int := MfInteger.GetValue(MfCharUnicodeInfo.GetDecimalDigitValue(c))
					}
					retval := true
				}
			} else if (strP = "MfString") {
				strV := objParams.Item[0].Value
				if (RegExMatch(strV, "^\s*([-+]?\d{1,10})\s*$", match)) {
					iVal := MfInteger.GetValue(match1)
					if ((iVal >= MfInteger.MinValue) && (iVal <= MfInteger.MaxValue)) {
						if (_isObj = true) {
							int.Value := iVal
						} else {
							int := iVal
						}
						retval := true
					}
				} else if (RegExMatch(strV, "i)^\s*(-?0x[0-9A-F]{1,8})\s*$", match)) {
					iVal := MfInteger.GetValue(match1)
					if ((iVal >= MfInteger.MinValue) && (iVal <= MfInteger.MaxValue)) {
						if (_isObj = true) {
							int.Value := iVal
						} else {
							int := iVal
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
/*
	Property: MaxValue [get]
		Represents the largest possible value of an MfInteger. This field is constant.
	Value:
		Var integer
	Gets:
		Gets the largest possible value of an MfInt64.
	Remarks:
		Constant Property
		Can be accessed using MfInt64.MaxValue
		Value = 2147483647 (0x7FFFFFFF) hex
*/
	MaxValue[]
	{
		get {
			return 2147483647 ;  0x7FFFFFFF
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; 	End:MaxValue ;}
;{ 	MinValue
/*
	Property: MinValue [get]
		Represents the smallest possible value of an MfInteger. This field is constant.
	Value:
		Var integer
	Gets:
		Gets the smallest possible value of an MfInteger.
	Remarks:
		Can be accessed using MfInteger.MinValue
		Value =  -2147483648 (-0x80000000) hex
*/
	MinValue[]
	{
		get {
			return -2147483648 ;-0x80000000
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; 	End:MinValue ;}
;{	Value
/*
	Property: Value [get/set]
		Overrides MfPrimitive.Value
		Gets or sets the value associated with the this instance of MfInteger
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
			Base.Value := MfInteger._GetValue(value)
			return Base.Value
		}
	}
;	End:Value ;}
; End:Properties;}
}
/*!
	End of class
*/
