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

;{ class Type
/*!
	Class: MfType
	Provides type information for Object and classes
	Inherits: MfObject
*/
class MfType extends MfObject
{
	Static TypeCodes := Array("Empty"
					,"Object"
					,"Integer"
					,"Float"
					,"Number"
					,"String"
					,"Boolean"
					,"Date"
					,"Char"
					,"MfObject"
					,"MfString"
					,"MfInteger"
					,"MfFloat"
					,"MfChar"
					,"MfDateTime"
					,"MfType"
					,"MfBool"
					,"MfNull"
					,"MfEnum"
					,"MfAttribute"
					,"MfByte"
					,"MfInt64"
					,"MfTimeSpan"
					,"MfEnum.EnumItem"
					,"MfInt16"
					,"MfUInt64"
					,"MfBigInt"
					,"MfUInt16"
					,"MfUInt32"
					,"MfSByte")
;{ internal members	
	m_TypeName	:= Null
	m_TypeCode	:= Null
	m_IsAhkObj	:= false
	m_ClassName	:= Null
	
; End:internal members ;}
;{ Constructor: ()
/*
	Constructor()
	
	OutputVar := new MfType(obj)
	OutputVar := new MfType(obj, TypeName)
	
	Constructor(obj)
	Creates a MfType instance with type information for obj.

	Constructor(obj, TypeName)
	Creates a MfType instance with type information for obj  and assigns TypeName to TypeName Property.
	
	Parameters
		obj
			The Object to get the type info from.
		TypeName
			A string representing the TypeName of the object. Can be string var or MfString instance.
	Remarks
		Sealed Class
	Throws
		Throws MfNotSupportedException if class is extended/inherited.
*/
	__New(obj, TypeName = "") {
		; Throws [MfNotSupportedException](mfnotsupportedException.html) if this Sealed class is inherited.
		if (this.__Class != "MfType") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfType"))
		}
		base.__New()
		if (MfNull.IsNull(TypeName)) {
			this.m_TypeName := ""
		} else {
			this.m_TypeName := MfString.GetValue(TypeName)
		}
		
		this._Init(obj)
		this.m_isInherited := this.__Class != "MfType"
	}
; End:Constructor: () ;}	
;{ Methods
;{ 	_Init(T)			- Internal
	_Init(T) {
		if (IsObject(T)) {
			this.m_TypeName := MfType.TypeCodes[2] ; objcet
			this.m_TypeCode := this.m_TypeName ; object
			if ((IsFunc(T.Is)) && (T.Is(MfObject))) {
				if (T.__Class) {
					this.m_ClassName := T.__Class
				} else if (T.base.__Class) {
					this.m_ClassName := T.base.__Class
				}
				this.SetMfObject(T)
				this.m_IsAhkObj := true
				return
			}
			if(T.__Class) { ; non instance objects that do not inherit form MfObject
				this.m_TypeName := T.__Class
				this.m_TypeCode := this.m_TypeName
			} else if (T.base._Class) { ; for instance objects that do not inherit form MfObject
				this.m_TypeName := T.__Class
				this.m_TypeCode := this.m_TypeName
			this.m_TypeCode := this.m_TypeName
			} else {
				this.m_TypeName := MfType.TypeCodes[2] ; Typecode 2 is Object
				this.m_TypeCode := MfType.TypeCodes[2] ; Typecode 2 is Object
			}
			return
		}
		if (!T) {
			this.m_TypeName := MfType.TypeCodes[1] ; Typecode 1 is Object Empty
			this.m_TypeCode := MfType.TypeCodes[1] ; Typecode 1 is Object Empty
			return
		}
		if ((T = "MfType") || (T = MfType.TypeCodes[16])) {
			this.m_TypeName := "MfType"
			this.m_TypeCode := MfType.TypeCodes[16] 
			return
		}
		; Because there is not real type chceking that can be
		; done for ahk primitives we will not be supportig them
		; at this time. Even though we took a stab at it below
		; for the time being forget about it.
		return
		if (this.IsStr(T)) {
			; IsStr will return true even if input is ""
			if (MfNull.IsNull(T)) {
				this.m_TypeName := MfType.TypeCodes[1] ; Typecode 1 is Object Empty
				this.m_TypeCode := MfType.TypeCodes[1] ; Typecode 1 is Object Empty
			} else {
				this.m_TypeName := MfType.TypeCodes[6]
				this.m_TypeCode := MfType.TypeCodes[6] ; MfString
			}
			; string containing number
			
			return
		}
		if ((!T) && (T = "")) {
			this.m_TypeName := ""
			this.m_TypeCode := MfType.TypeCodes[1]
			return
		}
		
		
		if T is Float
		{
			this.m_TypeName := MfType.TypeCodes[5] ; number
			this.m_TypeCode := MfType.TypeCodes[4] ; MfFloat
			return
		}
		if T is Integer
		{
			this.m_TypeName := MfType.TypeCodes[5] ; number
			this.m_TypeCode := MfType.TypeCodes[3] ; MfInteger
			return
		}
		if (this.MatchDate(T)) {
			this.m_TypeName := MfType.TypeCodes[8] ; MfDateTime
			this.m_TypeCode := MfType.TypeCodes[8] ; MfDateTime
			return
		}
		;~ if T is time
		;~ {
			;~ this.m_TypeName := MfType.TypeCodes[8] ; MfDateTime
			;~ this.m_TypeCode := MfType.TypeCodes[8] ; MfDateTime
			;~ return
		;~ }
		if T is alpha
		{	
			iLen := StrLen(T)
			if (iLen = 1) {
				this.m_TypeName := MfType.TypeCodes[9] ; MfChar
				this.m_TypeCode := MfType.TypeCodes[9] ; MfChar
				return
			}
		}
		;Default to text
		this.m_TypeName := MfType.TypeCodes[6]
		this.m_TypeCode := MfType.TypeCodes[6] ; String
		return
	}
; End:_Init(T) ;}
;{ 	CompareTo()			- Overrides MfObject.CompareTo()
/*
	CompareTo()
	Overrides MfObject.CompareTo()

	OutputVar := instance.CompareTo(obj)
	
	CompareTo(obj)
		Compares the current instance of MfType with another instance of MfType and returns an integer that indicates whether the
		current instance precedes, follows, or occurs in the same position in the sort order as the other object.
	Parameters
		obj
			An instance of MfType to compare with this instance.
	Returns
		Returns a value that indicates the relative order of the objects being compared. The return value has these meanings:
			Value Meaning Less than zero This instance precedes obj in the sort order.
			Zero This instance occurs in the same position in the sort order as obj Greater than zero This instance follows obj in the sort order.
	Remarks
		If current instance and obj instance have their ClassName property set then compare is done on the ClassName property;
		Otherwise the compare is done on the TypeCode property.
	Throws
		Throws MfNullReferenceException if MfType is not set to an instance.
		Throws MfArgumentException is not the same type as this instance.
*/
	CompareTo(obj) {
		if (!this.IsInstance()) {
			ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", this.__Class))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfObject.IsObjInstance(obj, MfType)) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentException_ObjectCompareTo"),"obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		x := this
		y := obj
		ThisStr := Null
		ThatStr := Null
		
		if ((x.ClassName != "") && (y.ClassName != "")) {
			ThisStr := x.ClassName
			ThatStr := y.ClassName
		} else {
			ThisStr := x.TypeCode
			ThatStr := y.TypeCode
		}
		if (ThisStr = ThatStr) {
			return 0
		}
		if (ThisStr > ThatStr) {
			return -1
		} else {
			return 1
		}
	}
; End:CompareTo(obj) ;}	
;{ 	Equals()			- Overrides MfObject.Equals()
	/*
		Equals(objA)
			Compares MfType instance to current instance to see if they are the same.
		Parameters
			objA
				The MfType object to compare
		Returns
			Returns var containing Boolean value of true if the MfType objects are the same; Otherwise false.
		Remarks
			If current instance and objA instance have their ClassName property set then compare is done on the ClassName property;
			Otherwise the compare is done on the TypeCode property.

		MfType.Equals(objA, objB)
			Static Method
			Compares MfType objA and objB to see if they are the same.
		Parameters
		objA
			The first MfType object to compare
		objB
			The second MfType object to compare to objA.
		Returns
			Returns var containing Boolean value of true if the MfType objects are the same TypeName otherwise false.
		Remarks
			If objB is null then objA is compared to this current instance.
			If Objects have the same memory address then they are considered to be equal.
			Any objects can be compared. It is not necessary the objects inherit from MfObject.
	*/
	Equals(objA, objB = "")	{
		if (!MfObject.IsObjInstance(ObjA, MfType)) {
			return false
		}
		
		if ((MfNull.IsNull(objB) = false) && (MfObject.IsObjInstance(ObjA, MfType))) {
			x := objA
			y := objB
		} else {
			x := this
			y := objA
		}
		if ((x.ClassName != "") && (y.ClassName != "")) {
			return x.ClassName = y.ClassName
		}
		return x.TypeCode = y.TypeCode
	}
; End:Equals() ;}
;{	GetHashCode()		- Overrides	- MfObject.GetHashCode()
	/*
		GetHashCode()
			Gets A hash code for the current MfType.
		Returns
			Returns A hash code for the current MfType instance.
		Remarks
			A hash code is a numeric value that is used to insert and identify an MfType in a hash-based collection such as a Hash table.
			The GetHashCode() method provides this hash code for hashing algorithms and data structures such as a hash table.

			Two objects that are equal return hash codes that are equal. However, the reverse is not true:
			equal hash codes do not imply object equality, because different (unequal) objects can have identical hash codes.
			Furthermore, the this Framework does not guarantee the default implementation of the GetHashCode() method,
			and the value this method returns may differ between Framework versions such as 32-bit and 64-bit platforms.
			For these reasons, do not use the default implementation of this method as a unique object identifier for hashing purposes.
	Caution
		A hash code is intended for efficient insertion and lookup in collections that are based on a hash table.
		A hash code is not a permanent value. For this reason:
		* Do not serialize hash code values or store them in databases.
		* Do not use the hash code as the key to retrieve an object from a keyed collection.
		* Do not test for equality of hash codes to determine whether two objects are equal. (Unequal objects can have identical hash codes.) To test for equality, call the MfObject.ReferenceEquals() or MfObject.Equals() method.
	Throws
		Throws MfNullReferenceException if not an instance. See: IsInstance()
	*/
	GetHashCode() {
		if (!this.IsInstance()) {
			ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param",this.__Class))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		strObj := new MfString(this.TypeCode)
		strObj.Append(this.ClassName)
		return strObj.GetHashCode()
		
	}
; End:GetHashCode() ;}
;{ 	InheritancePath
	/*!
		Method: InheritancePath(obj)
			InheritancePath() formats a string var that contains the Inheritance Path for an
				object or an object **instance**.
		Parameters:
			obj - The object instance to get the Inheritance Path for.
		Returns:
			Returns a formatted a string var that contains the Inheritance Path of *obj*
		Example: @file:md\MfObjectInheritancePathExample.scriptlet
	*/
	InheritancePath( obj := "" ) {
		if (obj) {
			if (MfObject.IsObjInstance(obj)) {
				_obj := obj.base
			} else {
				_obj := obj
			}
			
		}  else {
			_obj := this.base
		}
		itree := []
		if(IsObject(_obj)){
			
			ipath := MfEnvironment.Instance.GetResourceString("Format_Inheritance_Tree", MfEnvironment.Instance.NewLine)
			
			while(IsObject(_obj )){
				itree[A_index] := (Trim(_obj.__Class) != "") ? _obj.__Class : "{}"
				_obj := _obj.base
			}
			cnt := itree.MaxIndex()
			for i,cls in itree
			{
				j := cnt - (i - 1)
				ipath .= itree[j]	
				
				if(i < cnt)
				{
					ipath .= "`n"
					loop % i
						ipath .= "   " 
					ipath .= ">"
				}
			}
		}else
			ipath := MfEnvironment.Instance.GetResourceString("Format_NonObject")
			
		return ipath
	}
; 	End:InheritancePath ;}
;{ 	IsObject()
	/*
		IsObject()
			Gets if the type for the MfType Instance is an Object or MfObject.
		Returns
			Returns true if type is Object or MfObject; Otherwise false.
		Remarks
			All Project Title Objects ( all extend/inherit MfObject ) will return true for IsObject().
		Throws
			Throws MfNullReferenceException if not an instance.
	*/
	IsObject() {
		if (!this.IsInstance()) {
			ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param",this.__Class))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.m_IsAhkObj) {
			return true
		}
		if ((this.m_TypeCode = MfType.TypeCodes[2])
			||(this.m_TypeCode = MfType.TypeCodes[10]))
		{
			return true
		}
		return false
	}
; 	End:IsObject() ;}
;{	SetMfObject(obj)	- Internal
	/*
		Method: SetMfObject(obj)
			SetMfObject() Set thte type for all MfObject based objects
		Parameters:
			obj - The object to get type info for
	*/
	SetMfObject(obj) {
		if (obj.Is(MfType.TypeCodes[11])) {
			this.m_TypeName := "MfString" ; 
			this.m_TypeCode := MfType.TypeCodes[11] ; MfString
			return
		}
		if (obj.Is(MfType.TypeCodes[12])) {
			this.m_TypeName := "MfInteger" ;
			this.m_TypeCode := MfType.TypeCodes[12] ; MfInteger
			return
		}
		if (obj.Is(MfType.TypeCodes[22])) {
			this.m_TypeName := "MfInt64" ;
			this.m_TypeCode := MfType.TypeCodes[22] 
			return
		}
		if (obj.Is(MfType.TypeCodes[25])) {
			this.m_TypeName := "MfInt16" ;
			this.m_TypeCode := MfType.TypeCodes[25] 
			return
		}
		if (obj.Is(MfType.TypeCodes[13])) {
			this.m_TypeName := "MfFloat"
			this.m_TypeCode := MfType.TypeCodes[13] ; MfFloat
			return
		}
		if (obj.Is(MfType.TypeCodes[14])) {
			this.m_TypeName := "MfChar" 
			this.m_TypeCode := MfType.TypeCodes[14] ; CharObj
			return
		}
		if (obj.Is(MfType.TypeCodes[17])) {
			this.m_TypeName := "MfBool" ;
			this.m_TypeCode := MfType.TypeCodes[17] ; MfBool
			return
		}
		if (obj.Is(MfType.TypeCodes[21])) {
			this.m_TypeName := "MfByte" ;
			this.m_TypeCode := MfType.TypeCodes[21] ; MfByte
			return
		}
		if (obj.Is(MfType.TypeCodes[30])) {
			this.m_TypeName := "MfSByte" ;
			this.m_TypeCode := MfType.TypeCodes[30] ; MfSByte
			return
		}
		if (obj.Is(MfType.TypeCodes[23])) {
			this.m_TypeName := "MfTimeSpan"
			this.m_TypeCode := MfType.TypeCodes[23]
			return
		}
		if (obj.Is(MfType.TypeCodes[26])) {
			this.m_TypeName := "MfUInt64"
			this.m_TypeCode := MfType.TypeCodes[26]
			return
		}
		if (obj.Is(MfType.TypeCodes[27])) {
			this.m_TypeName := "MfBigInt"
			this.m_TypeCode := MfType.TypeCodes[27]
			return
		}
		if (obj.Is(MfType.TypeCodes[28])) {
			this.m_TypeName := "MfUInt16"
			this.m_TypeCode := MfType.TypeCodes[28]
			return
		}
		if (obj.Is(MfType.TypeCodes[29])) {
			this.m_TypeName := "MfUInt32"
			this.m_TypeCode := MfType.TypeCodes[29]
			return
		}
		; check for EnumItem before MfEnum
		; EnumItem will repurt true to Is MfEnum
		; However MfEnum will not report true to EnumItem
		if (obj.Is(MfType.TypeCodes[24])) {
			this.m_TypeName := "EnumItem"
			this.m_TypeCode := MfType.TypeCodes[24] ; MfEnum
			return
		}
		if (obj.Is("MfEnum")) {
			this.m_TypeName := "MfEnum"
			this.m_TypeCode := MfType.TypeCodes[19] ; MfEnum
			return
		}
		
		if (obj.Is("MfAttribute")) {
			this.m_TypeName := "MfAttribute"
			this.m_TypeCode := MfType.TypeCodes[20] ; MfAttribute
			return
		}

		strTypeName := MfType.TypeOfName(obj)
		if (strTypeName != Undefined) {
			this.m_TypeName := strTypeName
			this.m_TypeCode := this.m_TypeName
			return
		}
		if (!this.m_TypeName) {
			this.m_TypeName := obj.__Class ; MfObject
		}
		this.m_TypeCode := MfType.TypeCodes[10] ; MfObject
		return
	}
; End:SetMfObject(obj) ;}
;{ ToString()			- Overrides	- MfObject
	/*
		ToString()
			Gets a string containing the TypeName of the current type.
		Returns
			Returns string value representing current instance of MfType
		Throws
			Throws MfNullReferenceException if called on a non instance of class.
	*/
	ToString() {
		if (!this.IsInstance()) {
			ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param",this.__Class))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return this.m_TypeName
	}
;	End:ToString() ;}	
;{ 	TypeOf
	/*
		TypeOf(obj)
			Returns the type of the given Object
		Parameters
			obj
				The object to get the type of
		Returns
			Returns string var containing info about the object.
		Remarks
			Static method
			
			Attempts to return class name of objects that are of type class.
			Non-MfObject are supported with this method. Non-Object are returned as a formated string such as NonObject value(4).
			Objects are are not classes return as value of Object or other culture aware string.
			Objects that are nested inside other class will return full path.
	*/
	TypeOf(obj){
		if(IsObject(obj)){
			cls := obj.__Class
			
			if(cls != "")
				return cls
			
			while(IsObject(obj)){
				if(obj.__Class != ""){
					return obj.__Class
				}
				obj := obj.base
			}
			return MfEnvironment.Instance.GetResourceString("Format_Object") ; Object
		}
		return MfString.Format(MfEnvironment.Instance.GetResourceString("Format_NonObject_Value", obj)) ; NonObject value({0})
	}
; 	End:TypeOf ;}
;{ 	TypeOf
	/*
		Method: TypeOfName(obj)
			TypeOfName() Returns the type of the given Object  
			Static Method
		Parameters:
			obj - the object to get the type of
		Returns:
			Returns string var containing info about the object.
	*/
	TypeOfName(obj) {
		typeName := Undefined
		if (IsObject(obj)) {
			if (MfObject.IsObjInstance(obj, "MfType")) {
				; we have a type class so lets use its TypeName
				typeName := obj.TypeName
			} else if (obj.__Class) {
				typeName := obj.__Class
			} else if (obj.base.__Class) {
				typeName := obj.base.__Class
			} else {
				return MfType.TypeCodes[2] ; TypeCode 2 is Object
			}
		}
		else if (obj ~= "^[^.](?!.*([.])\1{1})[a-zA-Z0-9._]+(?<!\.)$")
			&& (!(obj ~= "^[0-9.]+$")) ; do not match if only number(s) and .
		{
			; match if obj contains a-z, 0-9 and underscore, can contain . but cannot start or end with . (dot)
			; does not match string containing 2 . in a row. myclass..subclass will fail
			; number only or number with . only will fail; 45 is not valid .45 is not valid 4.5 is not valid
			typeName := obj
		}
		return typeName
	}
; 	End:TypeOf ;}
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
;{ 	GetType MfObject override
	GetType() {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:GetType ;}
; End:Methods ;}
;{ Properties
;{	ClassName
	/*
		Property: ClassName [get]
			Gets the Class name as a string var for the current type.
		Remarks
			Read-only Property
			ClassName is null if IsMfObject is false.
	*/
	ClassName[]
	{
		get {
			return this.m_ClassName
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:ClassName ;}
;{	IsString
	/*
		Property: IsBoolean [get]
			Gets if the type is MfBool.
		Remarks:
			Read-only Property
			Returns true if object is MfBool; Otherwise false.
	*/
	IsBoolean[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[17])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsString ;}
;{	IsByte
	/*
		Property: IsByte [get]
			 Gets if the type is MfByte.
		Remarks:
			Read-only Property
			Returns true if Type is MfByte ; Otherwise false.
	*/
	IsByte[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[21])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsByte ;}
;{	IsChar
	/*
		Property: IsChar [get]
			Gets if the type is MfChar.
		Remarks:
			Read-only Property
			Returns true if object is MfChar; Otherwise false.
	*/
	IsChar[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[14])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsChar ;}
;{	IsMfObject
	/*
		Property: IsMfObject [get]
			Gets if the type is MfObject.
		Remarks:
			Read-only Property
			Returns true if Type is MfObject; or derived from MfObject; Otherwise false.
	*/
	IsMfObject[]
	{
		get {
			return return this.m_IsAhkObj
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsMfObject ;}
;{		IsDate()
	/*
		Property: IsDate [get]
			IsDate Gets if type is MfDateTime
		Remarks:
			Read-only Property
			Returns true if object is MfDateTime otherwise false
	*/
	IsDate[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[15])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsDate() ;}	
;{	IsEmpty
	/*
		Property: IsEmpty [get]
			IsEmpty Gets if the current MfType is Empty or null
		Returns:
			Read-only Property
			Returns true if MfType is null or empty; Otherwise false.
	*/
	IsEmpty[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[1])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsEmpty() ;}
;{	IsEnum
	/*
		Property: IsEnum [get]
			IsEnum Gets if the type is MfEnum.
		Remarks:
			Read-only Property
			Returns true if Type is MfEnum; Otherwise false.
	*/
	IsEnum[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[19])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsEnum ;}
;{	IsEnumItem
	/*
		Property: IsEnumItem [get]
			IsEnumItem Gets if the type is EnumItem.
		Remarks:
			Read-only Property
			Returns true if Type is MfEnum.EnumItem; Otherwise false.
	*/
	IsEnumItem[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[24])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsEnumItem ;}
;{	IsFloat
	/*
		Property: IsFloat [get]
			Gets if the type is MfFloat
		Remarks:
			Read-only Property
			Returns true if Type is MfFloat; Otherwise false.
	*/
	IsFloat[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[13])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsFloat ;}
;{	IsInt16
	/*
		Property: IsInt16 [get]
			 Gets if the type is IsInt16.
		Remarks:
			Read-only Property
			Returns true if Type is IsInt16; Otherwise false.
	*/
	IsInt16[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[25])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsInt16 ;}
;{	IsInt32
	/*
		Property: IsInt32 [get]
			Gets if the type is IsInt32.
		Remarks:
			Read-only Property
			Returns true if Type is IsInt32; Otherwise false.
			Same as property MfType.IsInteger
	*/
	IsInt32[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[12])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsInt32 ;}

;{	IsInt64
	/*
		Property: IsInt64 [get]
			 Gets if the type is MfInt64.
		Remarks:
			Read-only Property
			Returns true if Type is MfInt64; Otherwise false.
	*/
	IsInt64[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[22])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsInt64 ;}
;{	IsInteger
	/*
		Property: IsInteger [get]
			Gets if the type is MfInteger.
		Remarks:
			Read-only Property
			Returns true if Type is MfInteger; Otherwise false.
			Same as property MfType.IsInt32
	*/
	IsInteger[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[12])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsInteger ;}
;{	IsUInt16
	/*
		Property: IsUInt16 [get]
			 Gets if the type is IsUInt16.
		Remarks:
			Read-only Property
			Returns true if Type is IsUInt16; Otherwise false.
	*/
	IsUInt16[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[28])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsUInt16 ;}
;{	IsUInt32
	/*
		Property: IsUInt32 [get]
			Gets if the type is IsUInt32.
		Remarks:
			Read-only Property
			Returns true if Type is IsUInt32; Otherwise false.
	*/
	IsUInt32[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[29])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsInt32 ;}
;{	IsUInt64
	/*
		Property: IsUInt64 [get]
			Gets if the type is MfUint64.
		Remarks:
			Read-only Property
			Returns true if object is IsUInt64; Otherwise false.
	*/
	IsUInt64[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[26])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsUInt64 ;}
;{	IsSByte
	/*
		Property: IsSByte [get]
			 Gets if the type is MfSByte.
		Remarks:
			Read-only Property
			Returns true if Type is IsSByte ; Otherwise false.
	*/
	IsSByte[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[30])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsInteger ;}
;{	IsBigInt
	/*
		Property: IsBigInt [get]
			Gets if the type is IsBigInt.
		Remarks:
			Read-only Property
			Returns true if object is IsBigInt; Otherwise false.
	*/
	IsBigInt[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[27])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsBigInt ;}
;{	IsIntegerNumber
	/*
		Property: IsIntegerNumber [get]
			Gets if the current Type is integer
		Remarks:
			Read-only Property
			Returns true if Type MfByte, MfInt16, MfInt64, MfInteger, MfSByte, MfUInt16, MfUInt32, MfEnum, MfEnum.EnumItem or MfFloat;  Otherwise false.
	*/
	m_IsIntegerNumber := ""
	IsIntegerNumber[]
	{
		get {
			if (this.m_IsIntegerNumber = "")
			{
				if ((this.m_TypeCode = MfType.TypeCodes[12])  ; MfInteger
					|| (this.m_TypeCode = MfType.TypeCodes[21]) ; MfByte
					|| (this.m_TypeCode = MfType.TypeCodes[30]) ; MfSByte
					|| (this.m_TypeCode = MfType.TypeCodes[25]) ; MfInt16
					|| (this.m_TypeCode = MfType.TypeCodes[22]) ; MfInt64
					|| (this.m_TypeCode = MfType.TypeCodes[19]) ; MfEnum
					|| (this.m_TypeCode = MfType.TypeCodes[28]) ; MfUInt16
					|| (this.m_TypeCode = MfType.TypeCodes[29]) ; MfUInt32
					|| (this.m_TypeCode = MfType.TypeCodes[24])) ; EnumItem
				{
					this.m_IsIntegerNumber := true
				} else {
					this.m_IsIntegerNumber := false
				}
			}
			return this.m_IsIntegerNumber
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsIntegerNumber ;}
;{	IsNumber
	/*
		Property: IsNumber [get]
			Gets if the current Type is numeric
		Remarks:
			Read-only Property
			Returns true if Type MfByte, MfInt16, MfInt64, MfInteger, MfSByte, MfUInt16, MfUInt32, MfEnum, MfEnum.EnumItem or MfFloat;  Otherwise false.
	*/
	m_isNumber := ""
	IsNumber[]
	{
		get {
			if (this.m_IsNumber = "")
			{
				if ((this.m_TypeCode = MfType.TypeCodes[13])  ; MfFloat
					|| (this.IsIntegerNumber = true))
				{
					this.m_IsNumber := true
				} else {
					this.m_IsNumber := false
				}
			}
			return this.m_IsNumber
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsNumber ;}
;{	IsString
	/*
		Property: IsString [get]
			Gets if the type is MfString.
		Remarks:
			Read-only Property
			Returns true if object is MfString; Otherwise false.
	*/
	IsString[]
	{
		get {
			return (this.m_TypeCode = MfType.TypeCodes[11])
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsString ;}
;{	TypeName
	/*
		Property: TypeName [get]
			Gets the TypeName as a string var for the current type.
		Remarks
			Read-only Property
	*/
	TypeName[]
	{
		get {
			return this.m_TypeName
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:TypeName ;}
;{	TypeCode
	/*
		Property: TypeCode [get]
			Gets the TypeCode as a string var for the current type.
		Remarks:
			Read-only Property
	*/
	TypeCode[]
	{
		get {
			return this.m_TypeCode
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:TypeCode ;}
; End:Properties ;}	
}
/*!
	End of class
*/
; End:class MfType ;}