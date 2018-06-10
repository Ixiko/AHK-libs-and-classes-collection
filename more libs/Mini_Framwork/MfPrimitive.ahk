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

; #Include <Mini_Framwork\1.0\MfValueType>
;{ class comments
/*!
	Class: MfPrimitive
		Abstract Class.
		Provides implementation for derived MfPrimitive classes such as MfBool, MfByte, MfInt64, MfInteger,
		MfString, MfChar and MfFloat This class in intended as a base class only an is not to be used on it own
	Inherits: MfValueType
*/
; End:class comments ;}
Class MfPrimitive extends MfValueType
{
	m_value 			:= Null
	m_ReturnAsObject	:= false
	m_ReadOnly			:= false
;{ Constructor: ()
/*
	Method: Constructor()

	OutputVar := new MfPrimitive(value [, returnAsObject, setReadOnly])

	Constructor(value [, returnAsObject, SetReadOnly])
		Constructor for Abstract MfPrimitive Class
	Parameters:
		value
			The value of from the derived class of the MfPrimitive type
		returnAsObject
			Boolean var that sets the state of ReturnAsObject property. Default Value is False
		setReadOnly
			Boolean var that sets the state of Readonly property. Default Value is False
	Throws:
		Throws MfNotSupportedException if this Abstract class constructor is called directly.
	Remarks:
		Derived classes must call base.__New(value) in their constructors.
*/
	__New(value, returnAsObject = false, SetReadOnly = false) {
		; Throws MfNotSupportedException if MfPrimitive Abstract class constructor is called directly.
		if (this.__Class = "MfPrimitive") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass", "MfPrimitive"))
		}
		base.__New()
		this.m_isInherited := this.__Class != "MfPrimitive"
		this.m_value := value
		this.m_ReturnAsObject := returnAsObject
		this.m_ReadOnly := SetReadOnly
		;MfPrimitive.TypeCode := TypeCode
		if ((!this.base.TypeCode) && (!this.TypeCode)) {
			e := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_Typecode"))
			e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw e
		}
	}
; End:Constructor: () ;}
;{ Methods
;{ 	GetValue()			- Abstract
/*
	Method: GetValue
		Abstract method must be overridden in derived classes.
	GetValue(args*)
		Gets the the value of the derived type or value of var containing value.
	Parameters:
		args*
			one or more args that may be implemented in derived classes
	Throws:
		Throws MfNotImplementedException if not implemented in derived class.
*/
	GetValue(args*) {
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_GetValue"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:GetValue() ;}
;{ 	ToString()			- Overrides	- MfObject
/*
	Method: ToString()
		Overrides MfObject.ToString()

	OutputVar := instance.ToString()

	ToString()
		Gets a string representation of the object.
	Returns:
		Returns var containing string object instance with a value representing current instance.
	Throws:
		Throws MfNullReferenceException is called as static method.
*/
	ToString() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		str := this.m_value . ""
		;strObj := new MfString(str)
		return str
	}
;  End:ToString() ;}
;{ 	Internal Methods
	; return MfBool intance if ReturnAsObject is true otherwise var containing boolean
	_ReturnBool(obj) {
		if (MfObject.IsObjInstance(obj, MfBool)) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfBool(obj,true):obj
		return retval
	}
	; return MfBool intance if ReturnAsObject is true otherwise var containing boolean
	_ReturnByte(obj) {
		if (MfObject.IsObjInstance(obj, MfByte)) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfByte(obj,true):obj
		return retval
	}
	; return MfChar intance if ReturnAsObject is true otherwise var containing string representing MfChar value
	_ReturnChar(obj) {
		if (MfObject.IsObjInstance(obj, MfChar)) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfChar(obj,true):obj
		return retval
	}
	; return MfDateTime intance if ReturnAsObject is true otherwise var DateTime
	_ReturnDate(obj) {
		if (MfObject.IsObjInstance(obj, "MfDateTime")) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfDateTime(obj,true):obj
		return retval
	}
	; return MfFloat intance if ReturnAsObject is true otherwise var containing Float
	_ReturnFloat(obj) {
		if (MfObject.IsObjInstance(obj, MfFloat)) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfFloat(obj,true):obj
		return retval
	}
	; return MfInteger intance if ReturnAsObject is true otherwise var containing Integer
	_ReturnInteger(obj) {
		if (MfObject.IsObjInstance(obj, MfInteger)) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfInteger(obj,true):obj
		return retval
	}
	; return MfInt64 intance if ReturnAsObject is true otherwise var containing Integer
	_ReturnInt64(obj) {
		if (MfObject.IsObjInstance(obj, MfInt64)) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfInt64(obj,true):obj
		return retval
	}
	; return MfString intance if ReturnAsObject is true otherwise var containing string
	_ReturnString(obj) {
		if (MfObject.IsObjInstance(obj, MfString)) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfString(obj,true):obj
		return retval
	}
	; return MfInt64 intance if ReturnAsObject is true otherwise var containing Integer
	_ReturnTimeSpan(obj) {
		if (MfObject.IsObjInstance(obj, MfTimeSpan)) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfTimeSpan(obj,true):obj
		return retval
	}
; 	End:Internal Methods ;}
	VerifyReadOnly(args*) {
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
; End:Methods ;}
;{ Properties	
;{	ReadOnly
/*
	Property: Readonly [get]
		Gets the if the derived class will allow the underlying value to be altered after the constructor has been called.
	Value:
		Boolean representing true or false.
	Gets:
		Gets a boolean value indicating if the derived class will allow the underlying value to be altered after the constructor has been called.
	Remarks:
		Read-only property
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
;{	ReturnAsObject
/*
	Property: ReturnAsObject [get\set]
		Gets or sets the if the derived class will return objects as their return value for various functions
	Value:
		Boolean representing true or false. Can be var or instance of MfBool.
	Gets:
		Gets if the derived instance will return object instances as their return value for various functions or vars.
		The default value is false.
	Sets:
		Sets if the if derived instance will return object instances as their return value for various functions or vars.
		The default value is false
		The set value is returned on successful value.
	Throws:
		Throws MfInvalidCastException if value is not a valid boolean var or object.
*/
	ReturnAsObject[]
	{
		get {
			return this.m_ReturnAsObject
		}
		set {
			try {
				this.m_ReturnAsObject := MfBool.GetValue(value)
				return this.m_ReturnAsObject
			} catch e {
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBoolean"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
	}
;	End:ReturnAsObject ;}
;{	Value
/*
	Property: Value [get\set]
		Gets or sets the value associated with the derived class.

	OutputVar := instance.Value
	instance.Value := Value

	Value:
		Sets the value of the MfPrimitive derived class
	Gets:
		Gets value assigned to the derived instance.
	Sets:
		Sets the value assigned to the derived instance.
	Throws:
		Throws MfNotSupportedException if on Set if Readonly is True.
	Remarks:
		In derived classes such as MfString this property gets the value associated with the instance.
*/
	Value[]
	{
		get {
			return this.m_Value
		}
		set {
			if (this.ReadOnly) {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				Throw ex
			}
			this.m_Value := value
			return this.m_Value
		}
	}
;	End:Value ;}
; End:Properties ;}
}
/*!
	End of class
*/