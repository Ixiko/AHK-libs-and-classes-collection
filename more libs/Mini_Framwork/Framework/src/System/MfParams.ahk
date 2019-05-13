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

/*!
	Class: MfParams
		Represents MfParams object.
		Sealed Class.
		AutoHotkey does not have any type checking built in at the time of this writing. AutoHotkey_L Version v1.1.24.03
		AutoHotkey does not allow overrides of methods such as
	Inherits:
		MfCollectionBase
*/
Class MfParams extends MfCollectionBase
{
	m_Data			:= ""
	m_OnlyAhkObj	:= ""
	;{ Constructor
/*
	Method: Constructor()
			Initializes a new instance of the MfParams class.
		
	OutputVar := new Mfparams(tList*)

	Constructor(tList*)
		Initializes a new instance of the MfParams class and optionally adds a range of objects to MfParams.
	Parameters
		tList
			Various objects to add to MfParams. See MfParams section below.
	Throws
		Throws MfException if unable to add tList item to MfParams with an inner Exception.


	MfParams (tList)
		MfParams can contain several different types.
		Such as but not limited to, MfString, MfInteger, MfFloat , MfChar and any object derived from MfObject.
		Only Object derived from MfObject or any var is valid as a parameter other objects are not accepted in the Constructor.
		Vars can be added but are Always converted to MfString if they do not contain Key Value Pairs and then added to MfParams.
		AddRange method and Constructor accept the same types of parameters.
		AddRange and Constructor can accept mixed paramaters.

			intA := new MfInteger(10) ; Create a new MfInteger object
			intB = new MfInteger(13) ; Create a new MfInteger object

			; create a new instance of MfParams and add MfInteger, MfInteger, MfChar, MfString
			p := new MfParams(intA,intB,"c=%","s=Hello World")
		is the same as
			p := new MfParams() ; create a new instance of MfParams

			; add MfInteger, MfInteger, MfChar, MfString
			p.AddRange(intA,intB,"c=%","s=Hello World")
*/
	__New(tList*) {
		; Throws MfNotSupportedException if MfParams Sealed class is extended
		if (this.__Class != "MfParams") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfParams"))
		}
		base.__New()
		this.m_isInherited := this.__Class != "MfParams"
		this.m_OnlyAhkObj := true
		try {
			this._ParseParams(tList*)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_ClassConstructor", MfType.TypeOfName(this)), e)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		
		
	}
;	End:Constructor ;}
;{ Methods
;{ 	AddRange()
/*!
	Method: AddRange()
		instance.AddRange(tList*)
	
	AddRange(tList*)
		Adds a range of MfObject instances to MfParams.
	Parameters
		tList
			Various objects to add to MfParams. See MfParams section below.
	
	Throws
		Throws MfNullReferenceException if MfParams is not set to an instance.
		Throws MfException if unable to add tList item to MfParams with an inner Exception.
	

	MfParams (tList)
		MfParams can contain several different types.
		Such as but not limited to, MfString, MfInteger, MfFloat , MfChar and any object derived from MfObject.
		Only Object derived from MfObject or any var is valid as a parameter other objects are not accepted in the Constructor.
		Vars can be added but are Always converted to MfString if they do not contain Key Value Pairs and then added to MfParams.
		AddRange method and Constructor accept the same types of parameters.
		AddRange and Constructor can accept mixed paramaters.

			intA := new MfInteger(10) ; Create a new MfInteger object
			intB = new MfInteger(13) ; Create a new MfInteger object

			; create a new instance of MfParams and add MfInteger, MfInteger, MfChar, MfString
			p := new MfParams(intA,intB,"c=%","s=Hello World")
		is the same as
			p := new MfParams() ; create a new instance of MfParams

			; add MfInteger, MfInteger, MfChar, MfString
			p.AddRange(intA,intB,"c=%","s=Hello World")
*/
	AddRange(tList*) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this._ParseParams(tList*)
		return this
	}
; End:AddRange() ;}
;{ 	Add Primitives
;{	AddBool()
/*
	Method: AddBool()

	OutputVar := instance.AddBool(value)

	AddBool(value)
		Adds MfBool to the current instance of MfParams
	Parameters:
		value
			the MfBool object or var containing Char to add to the MfParams
	Returns:
		The value zero-based index within the collection as integer.
	Throws:
		Throws MfNullReferenceException if MfParams is not set to an instance.
		Throws MfException if there is a error adding value to MfParams
		Throws MfArgumentException if value is Object but is not a valid instance of MfChar class.
		Throws MfInvalidCastException if value cannot be cast to MfChar.
*/
	AddBool(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_Val := Null
		try {
			_Val := MfBool.GetValue(value)
		} catch e {
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBoolean"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try {
			; better to construct MfBool without parameters here
			; because we use MfParams in MfBool constructor.
			b := new MfBool()
			b.Value := _Val
			return this.Add(b)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_AddToListWithParams","MfBool","MfParams"), e)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
	}
;	End:AddBoolean() ;}	
;{	AddByte()
/*
	Method: AddByte()

	OutputVar := instance.AddByte(value)

	AddByte(value)
		Adds MfByte to the current instance of MfParams
	Parameters:
		value
			the MfByte object or var containing Char to add to the MfParams
	Returns:
		The value zero-based index within the collection as integer.
	Throws:
		Throws MfNullReferenceException if MfParams is not set to an instance.
		Throws MfException if there is a error adding value to MfParams
		Throws MfArgumentException if value is Object but is not a valid instance of MfChar class.
		Throws MfInvalidCastException if value cannot be cast to MfChar.
	Remarks:
		RetrunAsObject property for MfByte instance to MfParams instance using this method is always false.
*/
	AddByte(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if ((IsObject(value) = false) && (Mfunc.IsInteger(value) = false))
		{
			; MfInteger.GetValue will parse 5.5
			; Here we will throw an error if not var is strict integer.
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToByte"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_Val := Null
		try {
			_Val := MfByte.GetValue(value)
		} catch e {
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToByte"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try {
			; better to construct MfInt64 without parameters here
			; because we use MfParams in MfInt64 constructor.
			b := new MfByte()
			b.Value := _Val
			return this.Add(b)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_AddToListWithParams","MfByte","MfParams"), e)
			er.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		
	}
;	End:AddByte() ;}
;{	AddChar()
/*
	Method: AddChar()

	OutputVar := instance.AddChar(value)

	AddChar(value)
		Adds MfChar to the current instance of MfParams
	Parameters:
		value
			the MfChar object or var containing Char to add to the MfParams
	Returns:
		The value zero-based index within the collection as integer.
	Throws:
		Throws MfNullReferenceException if MfParams is not set to an instance.
		Throws MfException if there is a error adding value to MfParams
		Throws MfArgumentException if value is Object but is not a valid instance of MfChar class.
		Throws MfInvalidCastException if value cannot be cast to MfChar.
	Remarks:
		RetrunAsObject property for MfChar instance to MfParams instance using this method is always false.
*/
	AddChar(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_Val := Null
		try {
			_Val := MfChar.GetValue(value)
		} catch e {
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToChar"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try {
			; better to construct MfChar without parameters here
			; because we use MfParams in MfChar constructor.
			ch := new MfChar()
			ch.Value := _Val
			return this.Add(ch)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_AddToListWithParams","MfChar", MfType.TypeOfName(this)), e)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
	}
;	End:AddChar(value) ;}
;{	AddFloat()
/*
	Method: AddFloat()

	OutputVar := instance.AddFloat(value)

	AddFloat(value)
		Add MfFloat to the current MfParams
	Parameters:
		value
			the MfFloat object or var containing Float to add to the MfParams
	Returns:
		The value zero-based index within the collection as integer.
	Throws:
		Throws MfNullReferenceException if MfParams is not set to an instance.
		Throws MfException if there is a error adding value to MfParams
		Throws MfArgumentException if value is Object but is not a valid instance of MfFloat class.
		Throws MfInvalidCastException if value cannot be cast to MfFloat.
	Remarks:
		RetrunAsObject property for MfFloat instance to MfParams instance using this method is always false.
*/
	AddFloat(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_Val := Null
		try {
			_Val := MfFloat.GetValue(value)
		} catch e {
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToFloat"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try {
			; better to construct MfFloat without parameters here
			; because we use MfParams in MfFloat constructor.
			flt := new MfFloat()
			flt.Value := _Val
			return this.Add(flt)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_AddToListWithParams", "MfFloat", MfType.TypeOfName(this)), e)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
	}
;	End:AddFloat() ;}
;{	AddInt64()
/*
	Method: AddInt64()

	OutpubVar := instance.AddInt64(value)

	AddInt64(value)
		Add MfInt64 to the current MfParams
	Parameters:
		value
			the MfInt64 object or var containing Integer to add to the MfParams
	Returns:
		The value zero-based index within the collection as integer.
	Throws:
		Throws MfNullReferenceException if MfParams is not set to an instance.
		Throws MfException if there is a error adding value to MfParams
		Throws MfArgumentException if value is Object but is not a valid instance of MfInt64 class.
		Throws MfInvalidCastException if value cannot be cast to MfInt64.
	Remarks:
		RetrunAsObject property for MfInt64 instance to MfParams instance using this method is always false.
*/
	AddInt64(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if ((IsObject(value) = false) && (Mfunc.IsInteger(value) = false))
		{
			; MfInteger.GetValue will parse 5.5
			; Here we will throw an error if not var is strict integer.
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt64"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_Val := Null
		try {
			_Val := MfInt64.GetValue(value)
		} catch e {
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInt64"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try {
			; better to construct MfInt64 without parameters here
			; because we use MfParams in MfInt64 constructor.
			int := new MfInt64()
			int.Value := _Val
			return this.Add(int)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_AddToListWithParams","MfInt64","MfParams"), e)
			er.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		
	}
;	End:AddInt64() ;}
;{	AddInteger()
/*
	Method: AddInteger()

	OutpubVar := instance.AddInteger(value)

	AddInteger(value)
		Add MfInteger to the current MfParams
	Parameters:
		value
			the MfInteger object or var containing Integer to add to the MfParams
	Returns:
		The value zero-based index within the collection as integer.
	Throws:
		Throws MfNullReferenceException if MfParams is not set to an instance.
		Throws MfException if there is a error adding value to MfParams
		Throws MfArgumentException if value is Object but is not a valid instance of MfInteger class.
		Throws MfInvalidCastException if value cannot be cast to MfInteger.
	Remarks:
		RetrunAsObject property for MfInteger instance to MfParams instance using this method is always false.
*/
	AddInteger(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if ((IsObject(value) = false) && (Mfunc.IsInteger(value) = false))
		{
			; MfInteger.GetValue will parse 5.5
			; Here we will throw an error if not var is strict integer.
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_Val := Null
		try {
			_Val := MfInteger.GetValue(value)
		} catch e {
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try {
			; better to construct MfInteger without parameters here
			; because we use MfParams in MfInteger constructor.
			int := new MfInteger()
			int.Value := _Val
			return this.Add(int)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_AddToListWithParams","MfInteger", MfType.TypeOfName(this)), e)
			er.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		
	}
;	End:AddInteger() ;}
;{ 	AddString()
/*
	Method: AddString()

	OutputVar := instance.AddString(value)

	AddString()
		Add MfString to the current MfParams
	Parameters:
		value
			the MfString object or var containing string to add to the MfParams
	Returns:
		The value zero-based index within the collection as integer.
	Throws:
		Throws MfNullReferenceException if MfParams is not set to an instance.
		Throws MfException if there is a error adding value to MfParams
		Throws MfArgumentException if argument value is Object but is not a valid instance of MfString class.
		Throws MfInvalidCastException if value cannot be cast to MfString.
	Remarks:
		RetrunAsObject property for MfString instance to MfParams instance using this method is always false.
*/
	AddString(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_Val := Null
		try {
			_Val := MfString.GetValue(value)
		} catch e {
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToString"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try {
			; better to construct MfString without parameters here
			; because we use MfParams in MfString constructor.
			str := new MfString()
			str.Value := _Val
			return this.Add(str)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_AddToListWithParams","MfString", MfType.TypeOfName(this)), e)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
	}
;	End:AddString() ;}
; End:Add Primitives ;}
;{ 	Add() 			- Inherits 	- MfCollectionBase
/*
	Method: Add()
		Overrides MfCollectionBase.Add().

	OutputVar := instance.Add(obj)

	Add(obj)
		Adds an object to the end of the MfCollectionBase.
	Parameters:
		obj
			Object to be added to the end of the MfCollectionBase.
			If obj is is not a Object then obj is converted to MfString instance and added to the collection.
			If AllowOnlyAhkObj is set to true then obj must be var or instance of MfObject derived class.
	Returns:
		The obj zero-based index within the collection as integer
	Throws:
		Throws MfNotSupportedException if AllowOnlyAhkObj is set to true and obj is an object and does not derive from MfObject.
		Throws MfNullReferenceException if MfParams is not set to an instance.
	Remarks:
		If obj is var and not an object then it will be added to the collection as an instance of MfString.
*/
	Add(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		try
		{
			if (IsObject(value))
			{
				; validating will take place in OnValidate()
				return base.Add(value)
			}
			if ((this.AllowEmptyValue = true) && (MfNull.IsNull(value) = true))
			{
				; non instances of MfObject are considered null by MfNull.IsNull()
				; but at this stage non-instances of MfObject will already be added
				; OnValidate will take care of the rest
				return base.Add(Undefined)
			}
			else
			{
				str := new MfString()
				str.Value := value
				return base.Add(str)
			}
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Error", "value"), e)
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
	}
; End:Add() 			- Inherits 	- MfCollectionBase ;}
;{ 	B()
/*
	Method: B()

	OutputVar := MfParams.B(value)

	B(value)
		Creates a new MfBool object containing value
	Parameters:
		value
			The var with the new boolean value.
	Returns:
		Returns an MfBool instance containing value
	Throws:
		Throws MfArgumentException if value is object but not a valid instance of MfBool.
		Throws MfException with inner exception if unable to create new instanc of MfBool.
	Remarks:
		If value argument is instance of MfBool then that creats and returns a new MfBool containing the same value.
		This method is a static primitave generator.
*/
	B(value) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		v := MfBool.GetValue(value)
		retval := null
		try {
			retval := new MfBool(v)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_CreateInstance" "MfBool"), e)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		return retval
	}
; End:B() ;}
;{ 	C()
/*
	Method: C()

	OutputVar := MfParams.C(value)

	C(value)
		Creates a new MfChar object containing value
	Parameters:
		value
			The var with the new MfChar value.
	Returns:
		Returns an MfChar instance containing value
	Throws:
		Throws MfArgumentException if value is object but not a valid instance of MfChar.
		Throws MfException with inner exception if unable to create new instanc of MfChar.
	Remarks:
		If value argument is instance of MfChar then that creats and returns a new MfChar containing the same value.
		This method is a static primitave generator.
*/
	C(value) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		v := MfChar.GetValue(value)
		retval := null
		try {
			retval := new MfChar(v)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_CreateInstance" "MfChar"), e)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		return retval
	}
; End:C() ;}
;{ 	D()
/*

*/
	D(value) {
		err := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodWithName", "MfParams.D()"))
		err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw err
	}
; End:D() ;}
;{ 	F(value)
/*
	Method: F()

	OutputVar := MfParams.F(value)

	F(value)
		Creates a new MfFloat object containing value
	Parameters:
		value
			The var with the new MfFloat value.
	Returns:
		Returns an MfFloat instance containing value
	Throws:
		Throws MfArgumentException if value is object but not a valid instance of MfFloat.
		Throws MfException with inner exception if unable to create new instanc of MfFloat.
	Remarks:
		If value argument is instance of MfFloat then that creats and returns a new MfFloat containing the same value.
		This method is a static primitave generator.
*/
	F(value) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		v := MfFloat.GetValue(value)
		retval := null
		try {
			retval := new MfFloat(v)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_CreateInstance" "MfFloat"), e)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		return retval
	}
; End:F(value) ;}
;{ GetArgCount()
/*
	Method: GetArgCount()

	OutputVar := MfParams.GetArgCount(args*)

	GetArgsCount(args*)
		Get the count of arguments in vardic parameter args*.
	Parameters:
			args*
			The vardic args object to  get the count for
	Returns:
		Returns the count of the args* as integer. If args are empty then 0 is returned.
*/
	GetArgCount(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		cnt := args.MaxIndex()
		if (MfNull.IsNull(cnt))
		{
			cnt := 0
		}
		return cnt
	}
; End:GetArgCount() ;}
;{ 	GetValue()
/*
	Method: GetValue()

	OutputVar := instance.GetValue(index)

	GetValue(index)
		Gets the value of a item in the class for given index.
	Parameters:
		index
			The zero-Based index to get the element value from
	Returns:
		If index item is non-object then retruns item for the current index value.
		If index item is Derived from MfPrimitive then returns Value property for the MfPrimitive derived class.
		if index item is Derived from MfObject then returns objects ToString() method value.
		Non-MfObject objects are returned as is.
		Return value is always a var and never an object.
	Throws:
		Throws MfNullReferenceException if MfParams is not an instance.
		Throws MfArgumentOutOfRangeException if index is less than zero or index is equal to or greater than Count
		Throws MfArgumentException if index is not a valid MfInteger instance or valid var containing Integer
*/
	GetValue(index) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		itm := this.Item[index]
		if (IsObject(itm)) {
			if (MfObject.IsObjInstance(itm, MfPrimitive)) {
				value := itm.Value			
			} else if (MfObject.IsObjInstance(itm)) {
				value := itm.ToString()
			} else {
				value := itm
			}
		} else {
			value := itm
		}
		return value
	}
; End:GetValue() ;}
;{ 	I()
/*
	Method: I()

	OutputVar := MfParams.I(value)

	I(value)
		Creates a new MfInteger object containing value
	Parameters:
		value
			The var with the new MfInteger value.
	Returns:
		Returns an MfInteger instance containing value
	Throws:
		Throws MfArgumentException if value is object but not a valid instance of MfInteger.
		Throws MfException with inner exception if unable to create new instanc of MfInteger.
	Remarks:
		If value argument is instance of MfInteger then that creats and returns a new MfInteger containing the same value.
		This method is a static primitave generator.
*/
	I(value) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		v := MfInteger.GetValue(value)
		retval := null
		try {
			retval := new MfInteger(v)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_CreateInstance" "MfInteger"), e)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		return retval
	}
; End:I() ;}
;{ 	OnValidate()		- Overrides	- MfCollectionBase	
/*
	Method: OnValidate()
		Overrides MfCollectionBase.OnValidate().
	OnValidate(ByRef value)
		Performs additional custom processes when validating a value.
	Parameters:
		value
			The object to validate.
	Throws:
		Throws MfArgumentNullException if value is null and AllowEmptyString is false.
		Throws MfNullReferenceException if MfCollectionBase is not set to an instance.
	Remarks:
		Protected Method
		If AllowEmptyString is set to true then null values can be added using the Add() method.
*/
	OnValidate(ByRef value) {
		if ((this.AllowEmptyString = false) 
			&& (MfObject.IsObjInstance(value, "MfString") = true)
			&& value.Length = 0)
		{
			;Argument_Empty_String
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Empty_String"), "value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		; OnlyAhkObj will take Priority over AllowEmpty Values
		if ((this.m_OnlyAhkObj) && (!MfObject.IsObjInstance(value))) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "value"), "value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		; thorw an error if AllowEmptyValue is false and value is null
		if ((this.AllowEmptyValue = false) && (MfNull.IsNull(value) = true))
		{

			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; End:OnValidate()		- Overrides	- MfCollectionBase ;}
;{ 	S(value)
/*
	Method: S()

	OutputVar := MfParams.S(value)

	S(value)
		Creates a new MfString object containing value
	Parameters:
		value
			The var with the new string value.
	Returns:
		Returns an MfString instance containing value
	Throws:
		Throws MfArgumentException if value is object but not a valid instance of MfString.
		Throws MfException with inner exception if unable to create new instanc of MfString.
	Remarks:
		If value argument is instance of MfString then that creats and returns a new MfString containing the same value.
		This method is a static primitave generator.
*/
	S(value) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		v := MfString.GetValue(value)
		retval := null
		try {
			retval := new MfString(v)
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_CreateInstance" "MfString"), e)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		return retval
	}
; End:S(value) ;}
;{ 	ToString()			- Overrides	- MfObject
/*
	Method: ToString()
		Overrides MfObject.ToString

	OutputVar := instance.ToString()

	ToString()
		Gets a string representation of the Types contained in the instance of MfParams.
	Returns:
		Returns var containing string value representing the types of the MfParams as comma seperated values.
	Throws:
		Throws MfNullReferenceException if MfParams is not set to an instance.
	Remarks:
		The Order in is always the order out for the MfParams ToString Method.
		If you add MfString, MfString, MfChar, MfInteger in that order then ToString will return them in the
		same order "MfString,MfString,MfChar,MfInteger".
*/
	ToString() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		tCount := this.Count
		retval := ""
		index := -1
		loop, %tCount%
		{
			index ++
			currentItem := this.Item[index]
			_t := new MfType(currentItem)
			if ((_t.IsEnumItem = true) && (this.ConvertEnumItemType = true))
			{
				; currentItem.Type.ClassName will be the EnumItem's parent Enums ClassName
				retval := retval . currentItem.Type.ClassName
			}
			else if (_t.IsMfObject = false)
			{
				retval := retval . MfType.TypeOfName(currentItem)
			}
			else
			{
				retval := retval . _t.ClassName ; for EnumItem this will be MfEnum.EnumItem
			}
			
			if (A_Index < tCount) {
				retval .= ","
			}
			
		}
		return retval
	}


; End:ToString()		- Inhertis	- MfObject ;}
;{ ToStringList()
/*
	Method: ToStringList()

	OutputVar := instance.ToStringList()

	ToStringList()
		Gets a MfGenericList of MfString of the different types in the collection.
	Returns:
		Returns a MfGenericList of MfString
*/
	ToStringList() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := new MfGenericList(MfString)
		tCount := this.Count

		index := -1
		loop, %tCount%
		{
			index ++
			currentItem := this.Item[index]
			_t := new MfType(currentItem)
			if ((_t.IsEnumItem = true) && (this.ConvertEnumItemType = true))
			{
				; currentItem.Type.ClassName will be the EnumItem's parent Enums ClassName
				mfs := new MfString()
				mfs.Value := currentItem.Type.ClassName
				retval.Add(mfs)
			}
			else if (_t.IsMfObject = false)
			{
				if ((this.AllowEmptyValue = true) && (currentItem = Undefined))
				{
					mfs := new MfString()
					mfs.Value := Undefined
				}
				else
				{
					mfs := new MfString()
					mfs.Value := MfType.TypeOfName(currentItem)
				}
				retval.Add(mfs)
			}
			else
			{
				mfs := new MfString()
				mfs.Value := _t.ClassName
				retval.Add(mfs)
			}
		}
		return retval
	}
; End:ToStringList() ;}
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
;{ Internal Method
;{	_LoadKeyValueParam(value)
	/*
		Method: _LoadKeyValueParam(value)
			_LoadKeyValueParam() Internal method: parses string of keyvalue pairs and adds to MfParams as MfPrimitive types
		Parameters:
			value - string value representing key values sucha as "i=10,s=Hello world"
		Remarks:
			To add MfString to MfParams prefix with s eg: s=my value
			To add MfChar to MfParams prefix with c eg: c=%
			To add MfInteger to MfParams prefix with i eg: i=10
			To add MfFloat to MfParams prefix with f eg: f=20.9		
		Returns:
			Returns null
		Throws:
			Throws MfArgumentException if value is object
			Throws MfException if error parsing regular expression
	*/
	_LoadKeyValueParam(value) {
		if (!Value) {
			; assume empty string and add
			this.AddString(MfString.Empty)
			return null
		}
		if (IsObject(value)) {
			err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_StringVar", "object"),"value")
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		strToParse := Mfunc.StringReplace(value,"\,","\~","A")
		; pattern parse key value pairs with seperator being '=' or ':' or '|'
		; Key is captured in Keyword and value is captured in Value
		; pattern requires option Object at start of pattern 'O)' to match via object eg: Match["Keyword"]
		Pattern := "O)(?<Keyword>\w+)\s*[=:|]\s*(?<Value>.*[^\s])((?=\W*$)|\z)"
		iCount := 0
		Loop, Parse, strToParse,`,
		{
			iCount ++
			FoundPos := RegExMatch(A_LoopField, Pattern, Match)
			if (ErrorLevel <> 0) {
				msg := MfEnvironment.Instance.GetResourceString("Exception_Unknown")
				if (Mfunc.IsNumeric(ErrorLevel)) {
					if (ErrorLevel = -22) {
						msg := MfEnvironment.Instance.GetResourceString("Regex_ToManyEmptyMatch")
					} else if (ErrorLevel = -21) {						
						msg := MfEnvironment.Instance.GetResourceString("Regex_Recursion")
					} else if (ErrorLevel = -8) {
						msg := MfEnvironment.Instance.GetResourceString("Regex_MatchLimit")
					}
				} else {
					msg := ErrorLevel
				}
				msg := MfEnvironment.Instance.GetResourceString("Regex_ErrorWithMsg",msg)
				err := new MfException(msg)
				throw err
			}
			if (FoundPos) {
				k := Match["Keyword"]
				v := Match["Value"]
				obj := null
				if ((MfString.IsNullOrEmpty(k)) || (MfString.IsNullOrEmpty(v))) {
					continue
				}
				
				if (k = "i") {
					obj := new MfInteger(v)					
				} else if (k = "f") {
					obj := new MfFloat(v)
				} else if (k = "s") {
					v := Mfunc.StringReplace(v, "\~", ",", "A")
					obj := new MfString(v)
				} else if (k = "c") {
					v := Mfunc.StringReplace(v, "\~", ",", "A")
					obj := new MfChar(v)
				}
				if(IsObject(obj)) {
					try {
						this.Add(obj)
					} catch e {
						err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_AddToListWithParams","item", MfType.TypeOfName(this)), e)
						err.Source := A_ThisFunc
						throw err
					}
				}
			} else {
				; no match was found
				; assume that value is a string and add it
				v := Mfunc.StringReplace(strToParse, "\~", ",", "A") ; unescape any commas
				this.AddString(v)
			}
		}
		return null
	}
;	End:_LoadKeyValueParam(value) ;}
;{  _ParseParams(MfParams*)
	; Parases the MfParams and adds the value to MfParams MfList depending on the key
	_ParseParams(args*) {
		if (!this.IsInstance()) {
			err := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", MfType.TypeOfName(this)))
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		for i, arg in args
		{
			try {
				if (IsObject(arg)) {
					this.Add(arg)
				} else {
					this._LoadKeyValueParam(arg)
				}
			} catch e {
				err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_AddToListWithParams","item", MfType.TypeOfName(this)), e)
				err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw err
			}
		}
	}
;	End:_ParseParams(args*) ;}
; End:Internal Method ;}
;{ Properties
;{ AllowOnlyAhkObj
/*
	Property: AllowOnlyAhkObj [get\set]
		Gets or sets a value indicating whether the MfParams instance accepts only objects derived from MfObject.
	Value:
		MfBool instance or var boolean
	Gets:
		Gets a var boolean value indicating whether the MfParams instance accepts only objects derived from MfObject.
	Sets:
		Sets whether the MfParams instance accepts only objects derived from MfObject.
	Remarks:
		Default value is true.
		Returns true if the MfParams instance only accepts MfObject or derived instances; Otherwise, false.
*/
	AllowOnlyAhkObj[]
	{
		get {
			return this.m_OnlyAhkObj
		}
		set {
		try
			{
				this.m_OnlyAhkObj := MfBool.GetValue(value)
			}
			catch e
			{
				;Exception_PropertySet
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_PropertySet", "AllowEmptyString"), e)
				ex.SetProp(A_LineFile, A_LineNumber, "AllowOnlyAhkObj")
				throw ex
			}
			
			return this.m_OnlyAhkObj
		}
	}
; End:AllowOnlyAhkObj ;}
;{ AllowEmptyString
	m_AllowEmptyString := false
/*
	Property: AllowEmptyString [get\set]
		Gets or sets a value indicating whether the MfParams instance accepts empty MfString instances.
	Value:
		MfBool instance or var boolean
	Gets:
		Gets a value var boolean indicating whether the MfParams instance accepts empty MfString instances.
	Sets:
		Sets a value indicating whether the MfParams instance accepts empty MfString instances.
	Remarks:
		Default Value is false.
		If set to true then you may add "" values into the Add() method.
		The default value is false so adding null value in using the constructor is not possible.
		You must first create an instance of MfParams, set AllowEmptyString to true and then you can use the Add() method to add null values.
		
		If an attempt to set a null value using Add() is made with first setting AllowEmptyString to true then an MfException will be thrown by Add().
		If AllowEmptyValue is true and AllowEmptyString is true then the Add() method will add "" values as Undefined to the underlying list.

		AllowOnlyAhkObj takes priority over AllowEmptyValue and if AllowOnlyAhkObj is true Empty values such as null or
		Undefined cannot be added to the underlying list.
*/
	AllowEmptyString[]
	{
		get {
			return this.m_AllowEmptyString
		}
		set {
			try
			{
				this.m_AllowEmptyString := MfBool.GetValue(value)
			}
			catch e
			{
				;Exception_PropertySet
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_PropertySet", "AllowEmptyString"), e)
				ex.SetProp(A_LineFile, A_LineNumber, "AllowEmptyString")
				throw ex
			}
			return this.m_OnlyAhkObj
		}
	}
; End:AllowEmptyString ;}
;{ AllowEmptyString
	m_AllowEmptyValue := false
/*
	Property: AllowEmptyValue [get\set]
		Gets or sets a value indicating whether the MfParams instance accepts empty values such as null or ""
	Value:
		MfBool instance or var boolean
	Gets:
		Gets a var boolean value indicating whether the MfParams instance accepts empty values such as null or ""
	Sets:
		Sets whether the MfParams instance accepts empty values such as null or ""
	Remarks:
		Default Value is false.
		If set to true then you may add null values into the Add() method.
		The default value is false so adding null value in usin the constructor is not possible.
		You must first create an instance of MfParams, set AllowEmptyValue to true and then you can use the Add() method to add null values.
		If an attempt to set a null value using Add() is made with first setting AllowEmptyValue to true then an MfException will be thrown by Add().
		When AllowEmptyValue is set t true and the value being added is Null then Undefined is added as a var in place to the underlying list.
*/
	AllowEmptyValue[]
	{
		get {
			return this.m_AllowEmptyValue
		}
		set {
			try
			{
				this.m_AllowEmptyValue := MfBool.GetValue(value)
			}
			catch e
			{
				;Exception_PropertySet
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_PropertySet", "AllowEmptyString"), e)
				ex.SetProp(A_LineFile, A_LineNumber, "AllowEmptyString")
				throw ex
			}
			return this.m_OnlyAhkObj
		}
	}
; End:AllowEmptyString ;}
;{ Count				- Inherits	- MfCollectionBase
/*
	Property: Count [get]
		Gets a value indicating count of objects in the current MfParams.
		Inherited from MfCollectionBase.
	Value:
		Var integer
	Gets:
		Get the count as integer
	Remarks:
		Read-only Property
*/
	Count[]
	{
		get {
			return base.Count
		}
		set {
			err := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			err.SetProp(A_LineFile, A_LineNumber, "Count")
			throw err
		}
	}
; End:Count				- Inherits	- MfCollectionBase ;}
;{ Data[Key]
/*
	Property: Data [get]
		Gets the Data Dictionary Value for extra MfParams Options
	Value:
		MfDictionary instance
	Gets:
		Data Dictionary as MfDictionary
	Remarks:
		Data Property can be use to store extra information to pass to methods. Data is also used but method such as MfInteger.Parse().
*/
	Data[]
	{
		get {
			if (MfNull.IsNull(this.m_Data)) {
				this.m_Data := new MfDictionary()
			}
			return this.m_Data
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "Data")
			Throw ex
		}
	}
; End:Data[Key] ;}
;{ ConvertEnumItemType
	m_ConvertEnumItemType := true
/*
	Property: ConvertEnumItemType [get\set]
		Gets or sets a value indicating whether the MfParams instance uses ParentEnum Type for output.
	Value:
		Value can be var containing boolean such as true or false.
		Value can be MfBool instance.
	Gets:
		Gets the value of ConvertEnumItemType as boolean var of true or false.
	Sets:
		Sets the Value of the ConvertEnumItemType to true or false.
	Remarks:
		Defalult value is true.
		If ConvertEnumItemType is true then ToString() method will output ClassName for the Containing MfEnum instance;
		Otherwise "MfEnum.EnumItme" is outputted
*/
	ConvertEnumItemType[]
	{
		get {
			return this.m_ConvertEnumItemType
		}
		set {
			try
			{
				this.m_ConvertEnumItemType := MfBool.GetValue(value)
			}
			catch e
			{
				;Exception_PropertySet
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_PropertySet", "ConvertEnumItemType"), e)
				ex.SetProp(A_LineFile, A_LineNumber, "ConvertEnumItemType")
				throw ex
			}
			return this.m_OnlyAhkObj
		}
	}
; End:ConvertEnumItemType ;}
; End:Properties;}
}
/*!
	End of class
*/
