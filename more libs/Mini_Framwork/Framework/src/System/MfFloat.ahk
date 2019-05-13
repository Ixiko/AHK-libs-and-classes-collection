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
	Class: MfFloat
		Represents MfFloat object
	Inherits: MfPrimitive
*/
; End:Class Comments ;}
Class MfFloat extends MfPrimitive
{
;{ 	Static Properties
	TypeCode[]
	{
		get {
			return 13
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; 	End:Static Properties ;}
	static m_NegativeInfinity := "-Infinity"
	static m_PositiveInfinity := "Infinity"
	static m_NaN := "NaN"

;{ Constructor
/*!
	Constructor()
		Initializes a new instance of the MfFloat class.
	
	OutputVar := new MfFloat([flt, returnAsObj, readonly, format])
	
	Constructor([flt, retunAsObj, readonly, format])
		Initializes a new instance of the MfFloat class optionally setting the Value property, ReturnAsObject property, Format property and the Readonly property.
	Parameters
		flt
			The object or var containing Float to create a new instance with.
			Can be any type that matches IsNumber.
		returnAsObj
			Determines if the current instance of MfFloat class will return MfFloat instances from functions or vars containing float. If omitted value is false
		readonly
			Determines if the current instance of MfFloat class will allow its Value to be altered after it is constructed.
			The Readonly property will reflect this value after the classes is constructed.
			If omitted value is false
		format
			The value to set the Format property to.
	Remarks
		Sealed Class.
		This constructor initializes the MfFloat with Value property set to the value of flt.
		ReturnAsObject will have a value of returnAsObj
		Format property will have a value of format.
		Readonly property will have a value of readonly.
		If Readonly is true then any attempt to change the underlying value will result in MfNotSupportedException being thrown.
		Variadic Method; This method is Variadic so you may construct an instance of MfParams containing any of the overload method parameters
		listed above and pass in the MfParams instance to the method instead of using the overloads described above. See MfParams for more information.
	Throws
		Throws MfNotSupportedException if class is extended.
		Throws MfArgumentException if error in parameter.
		Throws MfNotSupportedException if incorrect type of parameters or incorrect number of parameters.

*/
	__New(flt:=0.0, retunAsObj:=false, readonly:=false, format:="") {
		; f = 0.0, returnAsObj = false, readonly = fasle, format = "0.6"
		; Throws MfNotSupportedException if MfFloat Sealed class is extended
		if (this.__Class != "MfFloat") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfFloat"))
		}
		if (IsObject(flt))
		{
			if (!MfObject.IsObjInstance(flt, MfFloat))
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "flt", "MfFloat"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_f := flt.Value
			; if there is no format is assigned then use MfFloat parameter instance format
			; ignore format passed as MfString here. This will leave the option open for and
			; empty MfString instance  to be passsed to force autoformat
			if (format = "")
			{
				format := flt.Format
			}
		}
		else
		{
			if (flt = "")
			{
				ex := new MfArgumentNullException(flt)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_f := flt
		}
		
		_returnAsObject := MfBool.GetValue(retunAsObj, false)
		if (MfString.IsNullOrEmpty(format))
		{
			_format := ""
		}
		else
		{
			_format := MfString.GetValue(format)	
		}
		
		_readonly := MfBool.GetValue(readonly, false)
	
		;wasformat := A_FormatFloat
		try {
			;Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, _format)
			;_f += 0.0
			base.__New(0.0, _returnAsObject)
			if (_format = "")
			{
				MfFloat._SetFormatFromNmber(this, _f)
			}
			else
			{
				this.Format := _format
			}
			this.Value := _f
			;this._SetFormat(_format)
			; value is already set in base.__New()
			;this.m_Value := _f ; set the value to apply the formating
			; set the base readonly property late instead of in base constructor.
			; this allows the value to be reset first to apply formating
			this.m_ReadOnly := _readonly
		} catch e {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_ClassConstructor", this.__Class), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		; finally
		; {
		; 	Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		; }
		this.m_isInherited := this.__Class != "MfFloat"
	}
; End:Constructor ;}
;{ Methods
;{	Add()
/*!
	Method: Add()
	
	OutputVar := instance.Add(value)
	
	Add(value)
		Adds Float value to current instance of MfFloat.
	
	Parameters
		value
		The value to add to current instance.
		Can be var containing float or any object that MfType.IsNumber.
	Returns
		If ReturnAsObject is true then returns current instance of MfFloat with an updated value; Otherwise returns var containing float.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentNullException if value is null.
		Throws MfArithmeticException is unable to add value.
*/
	Add(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (MfFloat._isValidNumber(this) = false)
		{
			return this._ReturnFloat(this)
		}
		if (MfObject.IsObjInstance(value, MfFloat) && (MfFloat._isValidNumber(value) = false))
		{
			; this value becomes the state of the added value if not valid
			this.m_Value := value.m_Value
			return this._ReturnFloat(this)
		}
		wasformat := A_FormatFloat
		try
		{
			fmt := this.Format
			wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, fmt)
			_val := MfFloat.GetValue(value)
			_newVal := this.m_Value + _val
			this.Value := _newVal
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		finally
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		}
		
		return this._ReturnFloat(this)
	}
; End:Add() ;}
;{ 	CompareTo()			- Inhertis	- MfObject
/*
	Method: CompareTo()
		Overrides MfObject.CompareTo
	
	OutputVar := instance.CompareTo(obj)
	
	CompareTo(obj)
		Compares this instance to a specified MfFloat object.
	Parameters
		obj
			A MfFloat object to compare.
	Returns
		Returns A number indicating the position of this instance in the sort order in relation to the value parameter.
		Return Value Description Less than zero This instance precedes obj value. Zero This instance has the same position in the sort order as value.
		Greater than zero This instance follows
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentException if value is not an instance of MfFloat.
	Remarks
		Compares this instance to a specified MfFloat object and indicates whether this instance precedes, follows, or
		appears in the same position in the sort order as the specified MfFloat object.
*/
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value)) {
			return 1
		}
		if (!MfObject.IsObjInstance(obj, MfFloat)) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Object_Equals"),"obj")
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		If (MfFloat._isValidNumber(this) = false)
		{
			return -1
		}
		if (MfFloat._isValidNumber(obj) = false)
		{
			; this value becomes the state of the added value if not valid
			return 1
		}
		retval := -1
		fmt := this.Format
		wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, fmt)
		if (this.Value = obj.Value) {
			retval := 0
		} else if (this.Value > obj.Value) {
			retval := 1
		}
		Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		return retval
	}
; End:CompareTo() ;}
;{ 	Equals()			- Overrides - MfObject
/*
	Methd: Equals()
		Overrides MfObject.Equals()
	
	OutputVar := instance.Equals(value)
	
	Equals(value)
		Gets if this instance Value is the same as the value instance.Value
	Parameters
	value
		The Object or var containing, float to compare to current instance.
		Can be any type that matches MfType.IsNumber. 
	Returns
		Returns Boolean var of true if this Value and value are equal; Otherwise false.
	Remarks
		If value is unable to be converted to a float then false will be returned.
*/
	Equals(value)	{
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfFloat) && (MfFloat._isValidNumber(value) = false))
		{
			return this.m_Value == this.m_Value
		}
		wasformat := A_FormatFloat
		try
		{
			
			fmt := this.Format
			wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, fmt)
			_val := MfFloat._GetValue(value)
			if (this.Value = _val) {
				retval := true
			}
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Finally 
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		}
		return retval
	}
; End:Equals() ;}
;{ 	Divide
/*
	Method: Divide()
	
	OutputVar := instance.Divide(value)
	
	Divide(value)
		Divides the current instance of MfFloat by the divisor value.
	Parameters
		value
			The Divisor value to divide the current instance Value by.
			Can be var containing float or any object that MfType.IsNumber.
	Returns
		If ReturnAsObject is true then returns current instance of MfFloat with an updated Value; Otherwise returns Value as var.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfDivideByZeroException if value is zero.
		Throws MfArithmeticException if the operation fails or value is not an instance of MfFloat and can not be converted into float value.
	Remarks
		The result of the operation will based upon the Format options of the current instance.
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
		If (MfFloat._isValidNumber(this) = false)
		{
			return this._ReturnFloat(this)
		}
		if (MfObject.IsObjInstance(value, MfFloat) && (MfFloat._isValidNumber(value) = false))
		{
			; this value becomes the state of the added value if not valid
			this.m_Value := value.m_Value
			return this._ReturnFloat(this)
		}
		; if (this.Equals(0.0))
		; {
		; 	return this._ReturnFloat(this)
		; }
	
		wasformat := A_FormatFloat
		try
		{
			fmt := this.Format
			wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, fmt)
			_value := 0.0
			try
			{
				_value :=  MfFloat.GetValue(value)
				if (this.Equals(0.0) && _value = 0.0)
				{
					this.m_Value := MfFloat.m_NaN
					return this._ReturnFloat(this)
				}
			}
			catch e
			{
				ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_value = 0.0)
			{
				if (this.Value < 0.0)
				{
					this.m_Value := MfFloat.m_NegativeInfinity
					return this._ReturnFloat(this)
				}
				this.m_Value := MfFloat.m_PositiveInfinity
				return this._ReturnFloat(this)
			}
			; with floor divide  any result less then 1 will be zero
			_newVal := (this.Value / _value) + 0.0

			this.Value := _newVal
		}
		catch e
		{
			throw e
		}
		Finally
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		}
				
		return this._ReturnFloat(this)

	}
; 	End:Divide ;}
;{ 	GetHashCode()		- Overrides	- MfObject
/*
	Method: GetHashCode()
		Overrides MfObject.GetHashCode()
	
	OutputVar := instance.GetHashCode()
	
	GetHashCode()
		Gets A hash code for the MfFloat instance.
	Returns
		A 32-bit signed integer hash code as var.
	Throws
		Throws MfNullReferenceException if object is not an instance.
	Remarks
		A hash code is a numeric value that is used to insert and identify an object in a hash-based collection such as a Hash table.
		The GetHashCode() method provides this hash code for hashing algorithms and data structures such as a hash table.
		Two objects that are equal return hash codes that are equal. However, the reverse is not true: equal hash codes do not imply object equality,
		because different (unequal) objects can have identical hash codes. Furthermore, the this Framework does not guarantee the default
		implementation of the GetHashCode() method, and the value this method returns may differ between Framework versions such as 32-bit and 64-bit platforms.
		For these reasons, do not use the default implementation of this method as a unique object identifier for hashing purposes.
	Caution
		A hash code is intended for efficient insertion and lookup in collections that are based on a hash table. A hash code is not a permanent value. For this reason:
		* Do not serialize hash code values or store them in databases. 
		* Do not use the hash code as the key to retrieve an object from a keyed collection. 
		* Do not test for equality of hash codes to determine whether two objects are equal.
		  (Unequal objects can have identical hash codes.) To test for equality, call the MfObject.ReferenceEquals() or MfObject.Equals() method. 
*/
	GetHashCode() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfFloat._IsNaN(this))
		{
			return -524288
		}
		if (MfFloat._IsPositiveInfinity(this))
		{
			return 2146435072
		}
		if (MfFloat._IsNegativeInfinity(this))
		{
			return -1048576
		}
		
		wf := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, this.Format)
		try
		{
			flt := this.Value
			if (flt = 0.0)
			{
				return 0
			}
			i64 := MfConvert._DoubleToInt64(flt)
			i32 := MfConvert._Int64ToInt32(i64)
			iShift := i64 >> 32
			iShift := MfConvert._Int64ToInt32(iShift)
			return i32 ^ iShift
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
; 	End:GetHashCode ;}
;{ 	GetTypeCode()
/*
	Method: GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfFloat Type Code.
	Returns
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfFloat.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.Float
	}
; End:GetTypeCode() ;}
;{ 	GetValue()			- Overrides	- MfPrimitive
/*!
	Method: GetValue()
		Overrides MfPrimitive.GetValue().
	
	OutputVar := MfFloat.GetValue(Obj)
	OutputVar := MfFloat.GetValue(Obj, Default)
	OutputVar := MfFloat.GetValue(Obj, Default, AllowAny)
	
	MfFloat.GetValue(Obj)
		Gets the Float number from Object or var containing float.
	Parameters
		Obj
			The Object or var containing, float, integer or hex value
			Can be any type that matches MfType.IsNumber. 
	Returns
		Returns a var containing a float.
	Remarks
		Static Method
		Throws an error if unable to convert Obj to float.
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentException if argument Obj is can not be converted to float value.
	
	MfFloat.GetValue(Obj, Default)
		Gets a Float number from Obj or returns Default value if Obj is unable to be converted to flaot.
		Default must be a value that can be converted to float or it will be ignored if Obj can not be converted to float an error will be thrown.
	Parameters
		Obj
			The Object or var containing, float, integer or hex value
			Can be any type that matches MfType.IsNumber. 
		Default
			The value to return if Obj is Cannot be converted
			Can be any type that matches IsNumber or var of float.
	Returns
		Returns a var containing a integer or Default value if Obj is unable to be converted to float.
	Remarks
		Static Method
		If Default is not a valid float or MfFloat instance then GetValue will throw an error if Obj can not be converted to float. 
		If Default can not be converted to a float then this would method will yield the same results as calling MfFloat.GetValue(Obj).
	Throws
		Throws MfInvalidOperationException if not called as a static method.
	
	MfFloat.GetValue(Obj, Default, AllowAny)
		Gets a float number from Obj or returns Default value if Obj is unable to be converted to float.
	Parameters
		Obj
			The Object or var containing, float, integer or hex value
			Can be any type that matches MfType.IsNumber. 
		Default
			The value to return if Obj is Cannot be converted
			Can be any type that matches IsNumber or var of float.
		AlowAny
			Determines if Default can be a value other then float. If true Default can be any var, Object or null; Otherwise Default must be a float value.
	Remarks
		Static Method.
		If AllowAny is true then Default can be any value including var, object or null.
		However if AllowAny is false then this method will yield the same result as calling MfFloat.GetValue(Obj, Default).
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentException if AllowAny is not a valid boolean.
	
	General Remarks
		Throws MfNotSupportedException if incorrect number of parameters are passed in.
*/
	GetValue(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		;obj, default=0.0, AllowAny=false
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
		_default := 0.0
		obj := args[1]
		if (i = 1)
		{
			CanThrow := True
		}
		else if (i = 2)
		{
			try
			{
				_default := MfFloat._GetValue(args[2])
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
					_default := MfFloat._GetValue(args[2])
				}
				catch e
				{
					CanThrow := true
				}
			}
		}
		retval := CanThrow = true? 0.0:_default
		if (CanThrow = true)
		{
			try
			{
				retval := MfFloat._GetValue(obj)
			}
			catch e
			{
				if (MfObject.IsObjInstance(e, MfArgumentException))
				{
					e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw e
				}
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else
		{
			try
			{
				retval := MfFloat._GetValue(obj)
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
	; internal method _GetValue
	_GetValue(obj) {
		if (MfNull.IsNull(obj) || obj = Undefined) {
			ex := new MfArgumentNullException("obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := 0.0
		if (IsObject(obj))
		{
			fType := new MfType(obj)
			if (fType.IsFloat)
			{
				retval := obj.Value
			}
			else if (fType.IsIntegerNumber)
			{
				retval := obj.Value + 0.0
			}
			else
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Error", "obj"), "obj")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else
		{
			if ((!Mfunc.IsFloat(obj)) && (!Mfunc.IsInteger(obj)))
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_TypeNotExpected"
					, "obj","Float"), "obj")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			retval := obj
			if (!Mfunc.IsFloat(retval))
			{
				retval := retval + 0.0
			}
			
		}
		return retval
	}
; 	End:_GetValue ;}
;{ 	GreaterThen
/*
	Method: GreaterThen()
	
	OutputVar := instance.GreaterThen(value)
	
	GreaterThen(value)
		Compares the current MfFloat object to a specified MfFloat object and returns an indication of their relative values.
	
	Parameters
		value
			The Object or var containing, float to compare to current instance.
			Can be any type that matches MfType.IsNumber. 
	Returns
		Returns true if the current instance has greater value then the value instance; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfFloat and can not be converted into float value.
*/
	GreaterThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}

		if (MfObject.IsObjInstance(value, MfFloat) && (MfFloat._isValidNumber(value) = false))
		{
			return false
		}
		If (MfFloat._isValidNumber(this) = false)
		{
			return true
		}
		wasformat := A_FormatFloat
		try
		{
			
			fmt := this.Format
			wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, fmt)
			_val := MfFloat._GetValue(value)
			if (this.Value > _val) {
				retval := true
			}
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Finally 
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		}
		return retval
	}
; 	End:GreaterThen ;}
;{ 	GreaterThenOrEqual
/*
	Method: GreaterThenOrEqual()
	
	OutputVar := instance.GreaterThenOrEqual(value)
	
	GreaterThenOrEqual(value)
		Compares the current MfFloat object to a specified MfFloat object and returns an indication of their relative values.
	Parameters
		value
			The Object or var containing, float to compare to current instance.
			Can be any type that matches MfType.IsNumber. 
	Returns
		Returns true if the current instance has greater or equal value then the value instance; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfFloat and can not be converted into float value.
*/
	GreaterThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfFloat))
		{
			if ((MfFloat._isValidNumber(value) = false) && MfFloat._isValidNumber(this) = false)
			{
				return value.Value == this.Value
			}
		}
		If (MfFloat._isValidNumber(this) = false)
		{
			return true
		}
		wasformat := A_FormatFloat
		try
		{
			
			fmt := this.Format
			wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, fmt)
			_val := MfFloat._GetValue(value)
			if (this.Value >= _val) {
				retval := true
			}
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Finally 
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		}
		return retval
	}
; 	End:GreaterThenOrEqual ;}
;{ 	GetTrimmed
/*
	Method: GetTrimmed()
	
	OutputVar := instance.GetTrimmed()
	
	GetTrimmed()
		Gets a float that has all leading and trailing 0's and spaces removed removed.
	Returns
		If ReturnAsObject Property for this instance is true then returns MfFloat instance; otherwise returns float var containing value.
	Remarks
		If Value is a whole number then a value will be returned without a decimal.
		If ReturnAsObject Property for this instance is true then a new MfFloat instance will be returned with its Format set to display a trimmed value.
	Throws
		Throws MfNullReferenceException if called as a static method.
*/
	GetTrimmed() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		ReturnAsObject := this.ReturnAsObject
		If (MfFloat._isValidNumber(this) = false)
		{
			if (ReturnAsObject)
			{
				return this
			}
			return this.Value
		}
		ns := 167 ; Float
		num := 0.0
		retval := MfFloat._TryParse(this.Value, ns, MfNumberFormatInfo.GetInstance(Null), num)
		if (retval)
		{
			if (ReturnAsObject)
			{
				fmt := MfFloat._GetFormatFromNumber(num)
				flt := new MfFloat(num, true,,fmt)
				return flt
			}
			mStr := MfMemoryString.FromAny(num)
			mStr.TrimEnd(".0")
			return mStr.ToString()
		}
		else
		{
			; failed to parse
			if (ReturnAsObject)
			{
				flt := new MfFloat(0.0, true,,"0.0")
				return flt
			}
			return 0

		}
	}
; 	End:GetTrimmed ;}
	IsInfinity(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ex := MfObject.IsNotObjInstance(obj, MfFloat,,A_ThisFunc)
		if(ex)
		{
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfFloat._IsPositiveInfinity(obj) || MfFloat._IsNegativeInfinity(obj))
		{
			return true
		}
		return false
	}
;{ 	IsNegativeInfinity
	IsNegativeInfinity(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ex := MfObject.IsNotObjInstance(obj, MfFloat,,A_ThisFunc)
		if(ex)
		{
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return MfFloat._IsNegativeInfinity(obj)
	}
	_IsNegativeInfinity(obj) {
		return obj.m_value == MfFloat.m_NegativeInfinity
	}
; 	End:IsNegativeInfinity ;}
;{ IsPositiveInfinity
	IsPositiveInfinity(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ex := MfObject.IsNotObjInstance(obj, MfFloat,,A_ThisFunc)
		if(ex)
		{
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return MfFloat._IsPositiveInfinity(obj)
	}
	_IsPositiveInfinity(obj) {
		return obj.m_value == MfFloat.m_PositiveInfinity
	}
; End:IsPositiveInfinity ;}
; End:IsNaN ;}
	IsNaN(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ex := MfObject.IsNotObjInstance(obj, MfFloat,,A_ThisFunc)
		if(ex)
		{
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return MfFloat._IsNaN(obj)
	}
	_IsNaN(obj) {
		return obj.m_value == MfFloat.m_NaN
	}
; End:IsNaN ;}
;{ 	LessThen
/*!
	Method: LessThen()
	
	OutputVar := instance.LessThen(value)
	
	LessThen(value)
		Compares the current MfFloat object to a specified MfFloat object and returns an indication of their relative values.
	Parameters
		value
		The Object or var containing, float to compare to current instance.
		Can be any type that matches MfType.IsNumber. 
	Returns
		Returns true if the current instance has less value then the value instance; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfFloat and can not be converted into float value.
*/
	LessThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfFloat) && (MfFloat._isValidNumber(value) = false))
		{
			return false
		}
		If (MfFloat._isValidNumber(this) = false)
		{
			return true
		}
		wasformat := A_FormatFloat
		try
		{
			
			wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, this.Format)
			_val := MfFloat._GetValue(value)
			if (this.Value < _val) {
				retval := true
			}
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Finally 
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		}
		return retval
	}
; 	End:LessThen ;}
;{ 	LessThenOrEqual
/*
	Method: LessThenOrEqual()
	
	OutputVar := instance.LessThenOrEqual(value)
	
	LessThenOrEqual(value)
		Compares the current MfFloat object to a specified MfFloat object and returns an indication of their relative values.
	Parameters
		value
		The Object or var containing, float to compare to current instance.
		Can be any type that matches MfType.IsNumber. 
	Returns
		Returns true if the current instance has less or equal value then the value instance; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfFloat and can not be converted into float value.
*/
	LessThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (MfNull.IsNull(value)) {
			return retval
		}
		if (MfObject.IsObjInstance(value, MfFloat))
		{
			if ((MfFloat._isValidNumber(value) = false) && MfFloat._isValidNumber(this) = false)
			{
				return value.Value == this.Value
			}
		}
		If (MfFloat._isValidNumber(this) = false)
		{
			return false
		}
		wasformat := A_FormatFloat
		try
		{
			
			wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, this.Format)
			_val := MfFloat._GetValue(value)
			if (this.Value <= _val) {
				retval := true
			}
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), "value", e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Finally 
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		}
		return retval
	}
; 	End:LessThenOrEqual ;}
;{ 	Multiply
/*
	Method: Multiply()
	
	OutputVar := instance.Multiply(value)
	
	Multiply(value)
		Multiplies the current instance of MfFloat by the value.
	Parameters
		value
			The value to multiply the current instance Value by.
			Can be var containing float or any object that MfType.IsNumber.
	Returns
		If ReturnAsObject is true then returns current instance of MfFloat with an updated Value; Otherwise returns Value as var.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentNullException if value is null.
		Throws MfDivideByZeroException if value is zero.
		Throws MfArithmeticException if the operation fails or value is not an instance of MfFloat and can not be converted into float Value.
	Remarks
		The result of the operation will based upon the Format options of the current instance.
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
		If (MfFloat._isValidNumber(this) = false)
		{
			return this._ReturnFloat(this)
		}
		if (MfObject.IsObjInstance(value, MfFloat) && (MfFloat._isValidNumber(value) = false))
		{
			; this value becomes the state of the added value if not valid
			this.m_Value := value.m_Value
			return this._ReturnFloat(this)
		}

		if (this.Equals(0.0))
		{
			return this._ReturnFloat(this)
		}
		_value := 0.0
		wasformat := A_FormatFloat
		try
		{
			try
			{
				wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, this.Format)
				if (MfObject.IsObjInstance(value, MfFloat))
				{
					_value := value.Value
				}
				else
				{
					_value :=  MfFloat.GetValue(value)
				}
				_newVal := (this.Value * _value) + 0.0
				this.Value := _newVal
			}
			catch e
			{
				ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		Catch e
		{
			throw e
		}
		finally
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		}
		return this._ReturnFloat(this)
	}
; 	End:Multiply ;}
;{ 	Parse()
/*!
	Method: Parse()
	
	MfFloat.Parse(obj)
		Converts the obj representation of a number to its MfFloat equivalent
	Parameters
		obj
			An object convert.
			Can be instance of MfChar, MfString
			Can be var containing string, integer
			Can also be instance of MfParams.
	Returns
		Converts the obj representation of a number to its MfFloat equivalent.
		If MfParams is passed in with Data key of ReturnAsObject and value set to true then parsed result will be returned as an instance of MfFloat;
		Otherwise a var float will be returned.
	Remarks
		Static Method
		Converts the obj representation of a number to its MfFloat equivalent.
		If obj parameter is an Objects then it must be instance from MfObject or be an instance of MfParams.
		If MfParams is passed in with Data key of ReturnAsObject and value set to true then parsed result will be returned as an instance of MfFloat;
		otherwise a var float will be returned.
		If MfParams is passed in with Data key of ReturnAsObject and value set to true then and Data key of Format added with a valid Format value then
		result will be returned as an instance of MfFloat with the Format set; otherwise a var float will be returned.
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
				ns := 231 ; AllowThousands, Float
				retval := MfFloat._Parse(strV, ns, MfNumberFormatInfo.CurrentInfo, A_ThisFunc)
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
					ns := 231 ; AllowThousands, Float
					retval := MfFloat._Parse(str.Value, ns, MfNumberFormatInfo.GetInstance(obj), A_ThisFunc)
				}
				else if (MfObject.IsObjInstance(obj, MfNumberStyles))
				{
					retval := MfFloat._Parse(str.Value, obj.Value, MfNumberFormatInfo.CurrentInfo, A_ThisFunc)
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
				retval := MfFloat._Parse(str.Value, ns.Value, MfNumberFormatInfo.GetInstance(fInfo), A_ThisFunc)
			}
			else if (strP = "MfFloat")
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
			flt := new MfFloat(0.0, true)
			MfFloat._SetFormatFromNmber(flt, retval)
			flt.m_Value := retval
			flt.Add(0.0)
			return flt

		}
		ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:Parse() ;}
;{	Subtract()
/*!
	Method: Subtract()
	
	OutputVar := instance.Subtract(value)
	
	Subtract(value)
		Subtract Float value from current instance of MfFloat.
	Parameters
		value
			The value to Subtract from current instance.
			Can be var containing float or any object that MfType.IsNumber.
	Returns
		If ReturnAsObject is true then returns current instance of MfFloat with an updated value; Otherwise returns var containing float.
	Throws
		Throws MfNotSupportedException if Readonly is true.
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentNullException if value is null.
		Throws MfArithmeticException is unable to subtract value.
*/
	Subtract(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value)) {
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (MfFloat._isValidNumber(this) = false)
		{
			return this._ReturnFloat(this)
		}
		if (MfObject.IsObjInstance(value, MfFloat) && (MfFloat._isValidNumber(value) = false))
		{
			; this value becomes the state of the added value if not valid
			this.m_Value := value.m_Value
			return this._ReturnFloat(this)
		}
		wasformat := A_FormatFloat
		try
		{
			wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, this.Format)
			_val := MfFloat.GetValue(value)
			_newVal := this.m_Value - _val
			this.Value := _newVal
		}
		catch e
		{
			ex := new MfArithmeticException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		finally
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		}
		return this._ReturnFloat(this)
	}
; End:Add() ;}
;{ 	ToInteger()
/*!
	Method: ToInteger()
	
	OutputVar := MfFloat.ToInteger()
	
	MfFloat.ToInteger(flt)
		Converts the value of the specified MfFloat to the equivalent MfInteger
	Parameters
		flt
		The MfFloat object or var containing Float value
	Returns
		Returns a MfInteger equivalent to the value of MfFloat
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentNullException if flt is Null.
		Throws MfArgumentException if flt is not a value that can be converted.
	Remarks
		Static Method
		The returned MfInteger has its MfInteger.ReturnAsObject property set to false.
*/
	ToInteger(flt) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(flt)) {
			ex := new MfArgumentNullException("flt", MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName", "flt"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (MfFloat._isValidNumber(this) = false)
		{
			return new new MfInteger()
		}
		
		wasformat := A_FormatFloat
		try
		{
			if (MfObject.IsObjInstance(flt, "MfFloat")) {
				fmt := flt.Format
				wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, fmt)
				_int := new MfInteger(MfInteger.GetValue(flt))
				return _int
			} else if (Mfunc.IsFloat(flt)) {
				_int := new MfInteger(MfInteger.GetValue(flt))
				return _int
			} else if (Mfunc.IsInteger(flt)) {
				_int := new MfInteger(flt)
				return _int
			} else {
				; may fail but lets give it a go
				return new MfInteger(MfInteger.GetValue(flt))
			}
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Finally
		{
			Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		}
			
		ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjTypeOr"
			, "flt","Float","MfFloat"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
		
	}
; End:ToInteger() ;}
;{ 	ToString()			- Overrides	- MfPrimitive
/*!
	Method: ToString()
		ToString() Gets a string representation of the object.  
		Overrides [MfPrimitive.ToString()](Primative.tostring.html)
	Returns:
		Returns string value representing current *instance*
	Throws:
		Throws MfNullReferenceException if called as a static method
*/
	ToString() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		If (MfFloat._isValidNumber(this) = false)
		{
			return this.Value
		}
		retval := MfFloat._GetFmtObjValue(this)
		return retval . ""
	}
;  End:ToString() ;}
;{ 	TryParse()
/*
	Method: TryParse()
	
	MfFloat.TryParse(byRef flt, obj)
		Converts the obj representation of a number to its MfFloat equivalent. A return boolean value indicates whether the conversion succeeded.
	Parameters
		flt
			flt contains the value equivalent to the number contained in obj, if the conversion succeeded.
			The conversion fails if the obj parameter is null, is not of the correct format. This parameter is passed uninitialized.
			flt can be instance of MfFloat or var containing float.
		obj
			An object convert.
			Can be instance of MfChar, MfString
			Can be var containing string, integer
			Can also be instance of MfParams.
	Returns
		Returns true if parse is a success; Otherwise false
	Remarks
		If parameter flt is passed in as an object it must in initialized as an instance of MfFloat first. Eg: myFlt := new MfFloat(0.0)
		If parameter flt is passed in as var it must in initialized as float first. Eg: myFlt := 0.0
		Whitespaces are allowed at the beginning or end of the string to parse.
	Throws
		Throws MfInvalidOperationException if not called as static method.
*/
	TryParse(byref flt, args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		objParams := MfInt16._intParseParams(A_ThisFunc, args*)
		cnt := objParams.Count
		retval := false
		
		strP := objParams.ToString()
		num := 0.0
		if (strP = "MfString" || strP = "MfChar")
		{
			strV := objParams.Item[0].Value
			ns := 231 ; AllowThousands, Float
			retval := MfFloat._TryParse(strV, ns, MfNumberFormatInfo.CurrentInfo, num)
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
				retval := MfFloat._TryParse(str.Value, obj.Value, MfNumberFormatInfo.CurrentInfo, num)
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
			retval := MfFloat._TryParse(str.Value, ns.Value, MfNumberFormatInfo.GetInstance(fInfo), num)
		}
		else if (strP = "MfFloat")
		{
			num := objParams.Item[0].Value
			retval := true
		}
		if (retval)
		{
			if (IsObject(flt))
			{
				if (!MfObject.IsObjInstance(flt, MfFloat))
				{
					flt := new MfFloat(0.0, true)
				}
				flt.Value := num
				flt.Add(0.0)
			}
			else
			{
				flt := num
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
;{ 	_isValidNumber
	; returns true if number if float represented by obj is valie; Otherwise false
	_isValidNumber(obj) {
		if (MfFloat._IsNaN(obj) || MfFloat._IsPositiveInfinity(obj) || MfFloat._IsNegativeInfinity(obj))
		{
			return false
		}
		return true
	}
; 	End:_isValidNumber ;}
;{ 	_GetFormatFromNumber
	; gets the min format for a float number based upon the input double num
	; return fromat in the for of 0.0 or 0.0e
	; total places is ignore and alwyas returned as 0 for not padding
	; Static Method
	; Internal method
	_GetFormatFromNumber(num) {
		mStr := MfMemoryString.FromAny(num)
		if (mStr.Length = 0)
		{
			return "0.0"
		}
		mStr.TrimEnd(".0")
		dotIndex := mStr.IndexOf(".")
		if (dotIndex = -1)
		{
			return "0.0"
		}
		eIndex := mStr.LastIndexOf("e",,,false)
		if (eIndex = -1)
		{
			DecCount := mStr.Length - (dotIndex + 1)
			return format("0.{:i}", DecCount)
		}
		DecCount := (eIndex - dotIndex) - 1
		return format("0.{:i}e", DecCount)
	}
; 	End:_GetFormatFromNumber ;}
;{ 	_ForceFormat()
	; sets the underlying value to match the current Format
	; this can be destrucive. If for format was 0.9 and
	; it is changed to 0.5 for instance then the last 4 decimal
	; places will be lost can not be recovered.
	_ForceFormat() {
		this.Add(0.0)
	}
; 	End:_ForceFormat() ;}
;{ 	_GetFmtObjValue
	; static method
	; returns a var float formated to fObj format property
	; fObj - MfFloat instance.
	_GetFmtObjValue(fObj) {
		fmt := fObj.Format
		wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, fmt)
		retval := fObj.Value
		fObj.m_Value := fObj.Value + 0.0
		
		; if (Mfunc.IsFloat(fObj.Value) = false)
		; {
		; 	fObj.Value := fObj.Value + 0.0
		; }
		wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		return retval
	}
; 	End:_GetFmtObjValue ;}
;{ _GetFmtValue
	; Static method
	; Returns var containing float formated to the fmt
	; f - the var float to format
	; fmt - the format to use
	_GetFmtValue(f, fmt) {
		wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, fmt)
		retval := f
		if (Mfunc.IsFloat(f) = false)
		{
			retval := retval + 0.0
		}
		
		Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)
		return retval
	}
; End:_GetFmtValue ;}
;{ 	_ConfirmValue
	; note that AutoHotkey will return "" for divide by zero of float
	_ConfirmValue(val) {
		sLen := StrLen(val)
		if (sLen = 0)
		{
			return MfFloat.m_NaN
		}
		mStr := new MfMemoryString(sLen,,,&val)
		if (mStr.IndexOf("-inf",,,false) >= 0)
		{
			return MfFloat.m_NegativeInfinity
		}
		if (mStr.IndexOf("inf",,,false) >= 0)
		{
			if (mStr.CharCode[0] = 45) ; - symbol
			{
				return MfFloat.m_NegativeInfinity
			}
			return MfFloat.m_PositiveInfinity
		}
		
		if (mStr.IndexOf("nan",,,false) >= 0)
		{
			return MfFloat.m_NaN
		}
		return val
	}
; 	End:_ConfirmValue ;}
;{ 	_SetFormat
	; sets the values for TotalWidth and DecimalPlaces
	_SetFormat(Value) {
		_Value := MfString.GetValue(Value)
		if (RegExMatch(_Value, "^\s*(-?\d{1,15})\.(\d{1,15})\s*$", match))
		{
				this.m_TotalWidth := match1
				this.m_DecimalPlaces := match2
		}
		else if (RegExMatch(_Value, "^\s*(-?\d{1,15})\.(\d{1,10}[eE])\s*$", match))
		{
				this.m_TotalWidth := match1
				this.m_DecimalPlaces := match2
		}
		else
		{
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_NotExpected"
				, "#.# or #.#e or #.#E or -#.# Eg: 0.6 or 0.2e or -04.3E"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
	}
; 	End:_SetFormat ;}
;{ _GetFormatFromArg
	; Gets the string value from an arg if it is var or instance of MfString
	; static method
	_GetFormatFromArg(arg) {
		if (MfNull.IsNull(arg))
		{
			return Null
		}
		if (IsObject(arg))
		{
			if(MfObject.IsObjInstance(arg, MfString))
			{
				return arg.Value
			}
			else
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Error", "arg"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		return arg
	}
; End:_GetFormatFromArg ;}
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
			MfNumberFormatInfo.ValidateParseStyleFloatingPoint(style)	
		}
		catch e
		{
			e.SetProp(A_LineFile, A_LineNumber, methodName)
			throw e
		}
		num := 0
		try
		{
			num := MfNumber.ParseDouble(s, style, info)
			return num
		}
		catch e
		{
			if (MfObject.IsObjInstance(e, MfOverflowException))
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"), e)
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
			MfNumberFormatInfo.ValidateParseStyleFloatingPoint(style)	
		}
		catch e
		{
			e.SetProp(A_LineFile, A_LineNumber, methodName)
			throw e
		}
		num := 0
		result := MfNumber.TryParseDouble(s, style, info, num)
		if (result)
		{
			out := num
			return true
		}
		return false
	}
; 	End:_TryParse ;}
;{ 	_SetFormatFromNmber
	; sets the TotalWidth and DecimalPlaces of instance of MfFloat
	; fltObj is instance of MfFloat
	; num is the float number in format of 0.0023e+12
	; Helper method for Parse
	_SetFormatFromNmber(fltObj, num) {
		mStr := MfMemoryString.FromAny(num)
		fltObj.TotalWidth := 0
		if (mStr.Length = 0)
		{
			fltObj.DecimalPlaces := "6"
			return
		}
		dotIndex := mStr.IndexOf(".")
		if (dotIndex = -1)
		{
			fltObj.DecimalPlaces := "6"
			return
		}
		eIndex := mStr.LastIndexOf("e",,,false)
		if (eIndex = -1)
		{
			; not e section to float but we do have a decimal portion
			; Figure out the decimal portation and set the flost object
			decimalPlaces := mStr.Length - (dotIndex + 1)
			if (decimalPlaces > 6)
			{
				fltObj.DecimalPlaces := format("{:i}", decimalPlaces > 16 ? 16 : decimalPlaces)
			}
			else
			{
				fltObj.DecimalPlaces := "6" ; ensure hex format does not invalidate
			}
			return
		}
		; at this point there is a decimal place and an exponent amount
		decimalPlaces := eIndex - (dotIndex + 1)
		; get the exp amount
		if (mStr.Length <= eIndex + 1)
		{
			fltObj.DecimalPlaces := format("{:i}", decimalPlaces)
			return
		}
		fltObj.DecimalPlaces := format("{:i}e", decimalPlaces)
	}
; 	End:_SetFormatFromNmber ;}
; End:Internal Methods ;}
;{ Properties
;{ 	DecimalPlaces
	m_DecimalPlaces		:= "6" ; ensure hex format does not invalidate
/*
	Property: DecimalPlaces [gets/sets]
		Gets or sets the value associated with the DecimalPlaces part of the Format
	Value:
		Value is a string. Can be instance of MfString or var containing string.
	Gets:
		Gets the DecimalPlaces as string var
	Sets:
		Sets the DecimalPlaces for the instance
	Remarks:
		DecimalPlaces is the number of decimal places to display (rounding will occur).
		If blank or zero, neither a decimal portion nor a decimal point will be displayed, that is,
		floating point results are displayed as integers rather than a floating point number. The starting default is 6.
		Get returns a var containing integer.
	Throws:
		Throws MfNotSupportedException if Readonly is true.
		Throws MfFormatException if Value is a bad format.
*/
	DecimalPlaces[]
	{
		get {
			return this.m_DecimalPlaces
		}
		set {
			this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
			_value := MfString.GetValue(value)
			if (_value ~= "^\d+$|^\d+[eE]$") {
				this.m_DecimalPlaces := _value
				this._ForceFormat() ; reset the format for the value
			} else {
				ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_NotExpected"
					, "# or #e or #E Eg: 2 or 2e or 3E"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			return this.m_DecimalPlaces
		}
	}
; 	End:DecimalPlaces ;}
;{ 	Format
/*!
	Property: Format [get/set]
		Gets the format associated with the format of the float value
	Value:
		To set value must be in the format of #.# or #.#e# or #.#E# or -#.# Eg: 0.6 or 0.2e3 or -04.1E1
		Can be MfString instance or var containing string
	Gets:
		Gets the current fromat as var containing string.
	Sets:
		Sets the format for the instance
	Remarks:
		Format contains TotalWidth and DecimalPlaces
		Alternativly you may set TotalWidth and DecimalPlaces instead of Format
		See Also: SetFormat()
	Throws:
		Throws MfNotSupportedException on set if Readonly is true.
		Throws MfFormatException if Value is a bad format.
*/
	Format[]
	{
		get {
			return Format("{1:i}.{2}",this.m_TotalWidth, this.m_DecimalPlaces) 
		}
		set {
			this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
			try {
				this._SetFormat(Value)
				this._ForceFormat() ; reset the format for the value
			} catch e {
				ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_NotExpected"
					, "#.# or #.#e# or #.#E# or -#.# Eg: 0.6 or 0.2e3 or -04.1E1"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			
		}
	}
; 	End:Format ;}
;{ 	TotalWidth
	m_TotalWidth := 0
/*
	Property: TotalWidth [get\set]
		Gets or sets the value associated with TotalWidth Format of Value.
	Value:
		Value is an string. Can be instance of MfString or var containing string.
	Gets:
		Gets the current state of TotalWidth as string var.
	Sets:
		Sets the current state of TotalWidth to Value.
	Remarks:
		TotalWidth is typically 0 to indicate that number should not have any blank or zero padding.
		If a higher value is used, numbers will be padded with spaces or zeros to make them that wide.
		Get returns a var containing integer.
		If TotalWidth is high enough to cause padding, spaces will be added on the left side; that is, each number will be right-justified.
		To use left-justification instead, precede TotalWidth with a minus sign. To pad with zeros instead of spaces, precede TotalWidth with a zero (e.g. 06).
		See Also: Format Property
	Throws:
		Throws MfFormatException if Value is bad format.
		Throws MfNotSupportedException on set if Readonly is true.
*/
	TotalWidth[]
	{
		get {
			return this.m_TotalWidth
		}
		set {
			this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
			_value := MfString.GetValue(value)
			if (_value ~= "^-?\d+$") {
				this.m_TotalWidth := _value
				this._ForceFormat() ; reset the format for the value
			} else {
				ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_NotExpected"
					, "# or -# Eg: 2 or -3 or 0"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			return this.m_TotalWidth
		}
	}
; 	End:TotalWidth ;}
;{ 	MaxValue
/*
	Property: MaxValue [get]
		Represents the largest possible value of an MfInt64. This field is constant.
	Value:
		Var integer
	Gets:
		Gets the largest possible value of an MfInt64.
	Remarks:
		Constant Property
		Can be accessed using MfInt64.MaxValue
		Value = 1.7976931348623157E+308
*/
	MaxValue[]
	{
		get {
			return "1.7976931348623157E+308"
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
		Represents the smallest possible value of an MfInt64. This field is constant.
	Value:
		Var integer
	Gets:
		Gets the smallest possible value of an MfInt64.
	Remarks:
		Can be accessed using MfInt64.MinValue
		Value = -1.7976931348623157E+308
*/
	MinValue[]
	{
		get {
			return "-1.7976931348623157E+308"
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MinValue ;}
;{ NaN
/*!
	Property: NaN [get]
		Gets the NaN value associated with the this instance
	Value:
		Var representing the NaN property of the instance
	Remarks:
		Readonly Property
*/
	NaN[]
	{
		get {
			return MfFloat.m_NaN
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "NaN")
			Throw ex
		}
	}
; End:NaN ;}
	;{ NegativeInfinity
/*!
	Property: NegativeInfinity [get]
		Gets the NegativeInfinity value associated with the this instance
	Value:
		Var representing the NegativeInfinity property of the instance
	Remarks:
		Readonly Property
*/
	NegativeInfinity[]
	{
		get {
			return MfFloat.m_NegativeInfinity
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "NegativeInfinity")
			Throw ex
		}
	}
; End:NegativeInfinity ;}
;{ PositiveInfinity
/*!
	Property: PositiveInfinity [get]
		Gets the PositiveInfinity value associated with the this instance
	Value:
		Var representing the PositiveInfinity property of the instance
	Remarks:
		Readonly Property
*/
	PositiveInfinity[]
	{
		get {
			return MfFloat.m_PositiveInfinity
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "PositiveInfinity")
			Throw ex
		}
	}
; End:PositiveInfinity ;}
;{	Value
/*
	Property Value [get\set]
		Overrides MfPrimitive.Value
		Gets or sets the value associated with the this instance of MfFloat
	value:
		Value is a float value and can be var or object
	Sets:
		Set the Value of the instance. Can be var or any object that matches IsNumber.
	Gets:
		Setting float Value as var
	Throws:
		Throws MfNotSupportedException if when trying to set if Readonly is true.
		Throws MfInvalidCastException if unable to set property to value.
		Throws MfNotSupportedException on set if Readonly is true.
	Remarks
		The Value property can be set to any valid number without first setting the SetFormat values of AutoHotkey.
		Also getting the Value property does not require setting the SetFormat values of AutoHotkey.
		However setting the Value property using the +=,-=, ++, --, *=, /= operators requires setting the SetFormat values of AutoHotkey before using these operators.
		To avoid issues with having to SetFormat ust the Add(), Subtract(), Divide() and Multiply() methods.
*/
	Value[]
	{
		get {
			return this.m_Value
		}
		set {
			this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
			wasformat := ""
			try
			{
				mStr := ""
				if (IsObject(value))
				{
					; will throw an error if not instance of MfFloat and is Object
					ex := MfObject.IsNotObjInstance(value, MfFloat,,A_ThisFunc)
					if(ex)
					{
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					if (MfFloat._IsNaN(value))
					{
						this.m_value := value.m_value
						return
					}
					if (MfFloat._IsNegativeInfinity(value))
					{
						this.m_value := value.m_value
						return
					}
					if (MfFloat._IsPositiveInfinity(value))
					{
						this.m_value := value.m_value
						return
					}
					else
					{
						wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, this.Format)
						this.m_value := value.Value
					}
				}
				else
				{
					_value := value ; MfFloat._DoubleToDouble(value) ; round trip to system to validated
					if (_Value == MfFloat.m_NaN)
					{
						this.m_value := MfFloat.m_NaN
						return
					}
					if (_Value == MfFloat.m_NegativeInfinity)
					{
						this.m_value := MfFloat.m_NegativeInfinity
						return
					}
					if (_Value == MfFloat.m_PositiveInfinity)
					{
						this.m_value := MfFloat.m_PositiveInfinity
						return
					}
					else
					{
						fmt := this.Format
						wasformat := Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, fmt)
						;_value += 0.0
						this.m_Value := this._ConfirmValue(_value)
					}
				}
			}
			catch e
			{
				if (MfObject.IsObjInstance(e, MfException))
				{
					if (e.Source == A_ThisFunc)
					{
						throw e
					}
				}
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToFloat"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			Finally
			{
				if (wasformat != "")
				{
					Mfunc.SetFormat(MfSetFormatNumberType.Instance.FloatFast, wasformat)	
				}
			}
		}
	}
;	End:Value ;}
; End:Properties;}
}

/*!
	End of class
*/