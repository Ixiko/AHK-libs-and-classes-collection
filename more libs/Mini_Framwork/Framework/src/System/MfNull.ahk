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

;{ class MfNullBase
/*!
	Class: MfNullBase
		Base Class for MfNull class.
		Abstract Class
	Inherits:
		MfObject
*/
class MfNullBase extends MfObject
{
;{ Constructor
/*
	Method: Constructor()
		Constructor for Abstract Class MfNullBase.

	OutputVar := new MfNullBase()
	
	Throw:
		Throws MfNotSupportedException if this Abstract class constructor is called directly.
*/
	__New() {
		if (this.__Class = "MfNullBase") {
			throw new MfNotSupportedException(MfString.Format(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass"), this.__Class))
		}
		base.__New()
		this.m_isInherited := this.__Class != "MfNullBase"
	}
; End:Constructor ;}
;{ 	GetInstance()
/*
	Method: GetInstance()

	OutputVar := this.GetInstance()

	GetInstance()
		Abstract method. Gets the instance of the Singleton
	Returns:
		Returns Singleton instance for the derived class.
	Throws:
		Throws MfNotImplementedException if method is not overridden in derived classes
	Remarks:
		Protected method.
		This method must be overridden in derived classes.
*/
	GetInstance() {
		throw new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_GetInstance"))
	}
; 	End:GetInstance() ;}
;{ Properties
/*
	Property: Null
		Gets a Singleton instance of MfNull.

	OutputVar := MfNullBase.Null

	Throws:
		Throws MfNotSupportedException if attempt to set value for null.
	Remarks:
		Null Property always returns the same instanace of the MfNull class.
*/
	Null[]
	{
		get {
			return this.GetInstance()
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			Throw ex
		}
	}
; End:Properties ;}
}
/*!
	End of class
*/
; End:class MfNullBase ;}


;{ class MfNull
/*
	Class: MfNull
		Represents MfNull object for handling Null values.
	Inherits:
		MfNullBase
*/
class MfNull extends MfNullBase
{
	Static TypeCode := 18
	static _instance := ""
	m_value := ""
;{ Constructor
/*
	Method: Constructor()
		Initializes a new instance of the MfNull class.

	OutputVar := new MfNull()
	
	Throws
		Throws MfNotSupportedException if class is inherited or extended.
	Remarks:
		It is not necessary to construct new instance of MfNull class as MfNull class is a singleton. Use MfNull.Null instead.
		Constructor should be treated as a protected method.
		Sealed Class.
*/
	__New() {
		if (this.__Class != "MfNull") {
			throw new MfNotSupportedException(MfString.Format(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class"), "MfNull"))
		}
		base.__New()
		this.m_value := ""
		this.m_isInherited := this.__Class != "MfNull"
	}
; End:Constructor ;}
;{ Method

;{ 	Equals()			- Overrides	- MfPrimitive
/*
	Method: Equals()
		Overrides MfObject.Equals()

	OutputVar := instance.Equals(value)

	Equals(value)
		Gets if this instance Value is the same as the value
	Parameters:
		value
			The Object or var to compare to current instance.
			Can be any type that matches IsNumber.
	Returns:
		Returns Boolean value of true if this Value and value are equal; Otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method
*/
	Equals(obj)	{
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (obj = MfNull.Null) {
			return true
		}
		return MfObject.ReferenceEquals(this, obj)
	}
; End:Equals(c) ;}
;{ 	GetInstance()
/*
	Method: GetInstance()
		GetInstance() Creates Singleton Instance of the MfNull class.
		Overrides MfNullBase.GetInstance.

	OutptVar := this.GetInstance()

		Returns Singleton instance for the MfNull class.
	Remarks:
		Protected Method.
		Not to be called directly. Use Null property.
*/
	GetInstance() { ; Overrides base
        if (MfNull._instance = "") {
            MfNull._instance := new MfNull()
        }
        return MfNull._instance
    }
; End:GetInstance() ;}
;{ 	GetObjOrNull
/*
	Method: GetObjOrNull()

	OutputVar := MfNull.GetObjOrNull(obj)

	GetObjOrNull()
		Checks to see if an object is null and returns a value
	Parameters:
		obj
			The Object or var to check to see if it is Null
	Returns:
		Returns if obj is null then MfNull.Null is returned. Otherwise the obj is returned.
	Remarks:
		Will always return an object
*/
	GetObjOrNull(obj) {
		if (MfNull.IsNull(obj) = true) {
			return MfNull.Null
		}
		return obj
	}
;{ GetObjOrNull
;{ 	GetValue()
/*
	Method: GetValue()
		Overrides MfPrimitive.GetValue()

	OutputVar := MfNull.GetValue()

	GetValue(obj)
		Gets the MfNull.Null.Value.
	Parameters:
		obj
			This parameter is ignored as MfNull.Null.Value is always returned.
	Returns:
		Returns a var containing MfNull.Null.Value in all cases.
	Remarks:
		Obsolete method.
*/
	GetValue(obj) {
		return MfNull.Null.Value
	}
; End:GetValue() ;}	
;{ 	Is()				- Overrides - MfPrimitive
/*
	Method: Is()
		Overrides MfObject.Is().

	OutputVar := instance.Is(ObjType)

	Is(ObjType)
		Gets if current instance of MfNull is of the same type as ObjType or derived from ObjType.
	Parameters:
		ObjType
			The object or type to compare to this instance Type.
			ObjType can be an instance of MfType or an object derived from MfObject or an instance of or a string containing
			the name of the object type such as "MfObject"
	Returns:
		Returns true if current object instance is of the same Type as the ObjType or if current instance is derived
		from ObjType or if ObjType = "Null"; Otherwise false.
	Remarks:
		If a string is used as the Type case is ignored so "MfObject" is the same as "mfobject"
*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if ((typeName = "Null") || (typeName = "MfNull")) {
			return true
		}
		return base.Is(typeName)
	}
; End:Is() ;}
;{ 	IsNull()
/*
	Method: IsNull()

	OutputVar := MfNull.IsNull(obj)

	IsNull(obj)
		Get if the obj parameter is null or MfNull.
	Parameters:
		obj
			The object to check or var to check
	Returns:
		Returns true if obj is null or is MfNull.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
	Remarks:
		Static Method:
		If obj is "" (null value) then true is returned.
		If parameter obj is instance of MfChar and has a MfChar.CharCode that equal zero then it will be considered as null.
		If parameter obj is instance of MfString and MfString.Length is equal to zero then it will be consider as null.
		It is import to call base New when creating new classes or MfNull.IsNull will return true even if your class creates an instance.
*/
	IsNull(obj = "") {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (IsObject(obj)) {
			if (MfObject.IsMfObject(obj) = false) {
				; not a mf object
				; all non-MfObjects will be considered NOT Null
				return false
			}
			if (MfObject.IsObjInstance(obj) = false) {
				; not and instance is considered Null
				return true
			}
			
			; Note: _HasFlag of MfEnum is used instead of HasFlag method.
			; this is necessary when checking flag options in IsNull()
			; If HasFlag is used will cause errors and recursion.
			; _HasFlag only takes an Integer var so send it a value
			;
			; This flag can be remved on the application level if the developer
			; desires Undefined to not be null
			; MfGlobalOptions.RemoveFlag(MfGlobalOptions.MfEmptyStringIsNull)
			; the above line should be placed in the top of the application
			; before other code is run to have MfString with value of ""  not equal null
			if ((MfGlobalOptions._HasFlag(MfGlobalOptions.MfEmptyStringIsNull.Value)) 
				&& (MfObject.IsObjInstance(obj, "MfString")))
			{
				if (obj.Length = 0) {
					return true
				}
				return false
			}

			; MfGlobalOptions.RemoveFlag(MfGlobalOptions.MfCharZeroIsNull)
			; the above line should be placed in the top of the application
			; before other code is run to have MfChar with CharCode of zero not equal null
			if ((MfGlobalOptions._HasFlag(MfGlobalOptions.MfCharZeroIsNull.Value)) 
				&& (MfObject.IsObjInstance(obj, "MfChar")))
			{
				if (obj.CharCode = 0) {
					return true
				}
				return false
			}
			
			return MfObject.IsObjInstance(obj, MfNull)
		}
		
		; MfGlobalOptions.RemoveFlag(MfGlobalOptions.UndefinedIsNull)
		; the above line should be placed in the top of the application
		; before other code is run to have undefined not equal null
		if ((MfGlobalOptions._HasFlag(MfGlobalOptions.UndefinedIsNull.Value)) 
			&& (obj = Undefined))
		{
			return true
		}
		; Null's Default Value is ""
		; just in case a global override is done on Null such as 'Global Null := 0'
		; we will do a check against Null hear as well
		if ((obj = "") || (obj = Null)) {
			
			return true
		}
		return false
		
		
	}
; 	End:IsNull() ;}
;{ 	ToString()			- Overrides	- MfPrimitive
/*
	Method: MfNull.ToString()
		Overrides MfPrimitive.ToString()

	OutputVar := MfNull.Null.ToString()

	ToString()
		Gets MfNull.Null.Value.
	Returns:
		Returns a var containing MfNull.Null.Value in all cases.
*/
	ToString() {
		return MfNull.Null.Value
	}
;  End:ToString() ;}
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
; End:Method ;}
;{ Properties
/*
	Property: Value [get]

	OutputVar := MfNull.Value

	Value:
		Null value as var
	Gets:
		Gets the Value representing a Null.
	Throws:
		Throws MfNotSupportedException if attempt to set Value.
*/
	Value[]
	{
		get {
			return this.m_value
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			Throw ex
		}
	}
; End:Properties;}
}
/*!
	End of class
*/
; End:class MfNull ;}