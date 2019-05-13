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

global Null := "" ; super global for null
global Undefined := "undefined" ; super global for Undefined
global MfGlobalOptions := MfFrameWorkOptions.Instance
/* Todo
		Implement into attrib that it can only add an attrib of any kind once.

*/
;{ Class MfObject
;{ Class Comments
/*!
	Class: MfObject
		Abstract Class.  
		Provides a base class for many other objects. All Objects working with this framework are required to inherit from MfObject.  
		All Object Classes derived from MfObject must call Base.__New() method if the are *not-static* classes. See Example Below.
*/
; End:Class Comments ;}
Class MfObject
{
;{ Class Members
	__m_isinstance 		:= false
    __m_GetType 		:= Null
	__m_Attributes		:= Null
	m_isInherited		:= false

; End:Class Members ;}
;{ Constructor: ()
/*
	Method: Constructor()
		Constructor for MfObject Class

	OutputVar := new MfObject()

	Remarks:
		Extended classes must call base.__New() in their constructors.
		MfObject class contains a field of m_isInherited This field should be set in your class as shown in the example below.
		Normally you would not construct an instance of MfObject but instead construct an instance of a class that extends MfObject.
*/
	__New() {
		; if (this.base.__Class = "MfObject") {
			; throw new MfNotSupportedException(MfString.Format(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass"),this.base.__Class))
		; }
		this.__m_isinstance := true
		this.m_isInherited := !(this.base.__Class = "MfObject")

	}

; End:Constructor: () ;}
;{ Methods
;{	AddAttribute()
/*
	Method: AddAttribute()
	AddAttribute(attrib)
		Adds MfAttribute extended items to extended classes
	Parameters:
		attrib
			The object instance derived from MfAttribute to add.
	Throws:
		Throws MfNullReferenceException if class is not an instance.
		Throws MfException containing innerException if unable to add MfAttribute to class instance.
	Remarks:
		This method is intended to be used by derived classes only and is to be treated as a protected method.
		MfNumberStyles class is an example of using this method to add MfFlagsAttribute to a class.
*/
	AddAttribute(attrib) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.__m_Attributes = Null) {
			this.__m_Attributes := new MfGenericList(MfAttribute)
		}
		try {
			if (!this.__m_Attributes.contains(attrib)) {
				this.__m_Attributes.Add(attrib)
			}
		} catch e {
			err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_AttribAdd"), e)
			err.Source := A_ThisFunc
			throw err
		}
		
	}
;	End:AddAttribute() ;}
;{ 	CompareTo()
/*
	Method: CompareTo()

	OutputVar := instance.CompareTo(obj)

	CompareTo(obj)
		Compares the current instance with another object of the same type and returns an integer that indicates
		whether the current instance precedes, follows, or occurs in the same position in the sort order as the other object.
		This method can be overridden in extended classes.
	Parameters:
		obj
			An object to compare with this instance.
	Returns:
		Returns a value that indicates the relative order of the objects being compared. The return value has these
		meanings: Value Meaning Less than zero This instance precedes obj in the sort order.
		Zero This instance occurs in the same position in the sort order as obj Greater than zero This instance follows obj in the sort order.
	Throws:
		Throws MfNullReferenceException if MfObject is not set to an instance.
		Throws MfArgumentException is not the same type as this instance.
*/
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!MfObject.IsObjInstance(obj)) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentException_ObjectCompareTo"),"obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(this.Equals(obj)) {
			return 0
		}
		return 1
	}
; End:CompareTo(obj) ;}	
;{ 	Equals(objA, ObjB = "")	
/*
	Method: Equals()

	OutputVar := instance.Equals(obj)
	OutputVar := MfObject.Equals(objA, ObjB)
	OutputVar := MfObject.Equals(objA, ObjB, CompareOpt)

	Equals(obj)
		Compares obj to current instance to see if they are the same
	Parameters:
		obj
			The object to compare with current instance

	MfObject.Equals(objA, ObjB)
		Static Method
		Compares objA and objB to see if they are the same. If objA and objB are vars (non-object) then ther are compared as strings
	Parameters:
		objA
			The first object or var to compare
		objB
			The second object orvar to compare.

	MfObject.Equals(objA, ObjB, CompareOpt)
		Static Method
		Compares objA and objB to see if they are the same. If objA and objB are vars (non-object) then ther are compared as strings or number
		depending on the value of CompareOpt.
	Parameters:
		objA
			The object to compare to objB.
			Can be object of any kind or var.
		objB
			The object to compare to objA.
			Can be object of any kind or var.
		CompareOpt
			The options used to compare objA to objB.
			Can be instance of MfEqualsOptions or MfEqualsOptions.Instance.EnumItem or integer matching one or more options of MfEqualsOptions.
	Returns:
		Returns var containing Boolean value of true if the objects are the same; Otherwise false.
	Remarks:
		If Objects have the same memory address then they are considered to be equal. However if vars are compared the will compare by value.
		That compare will be done as string or dynamicaly as set by MfEqualsOptions if CompareOpt has a flag CompareNumber set then
		compare will be done on vars dynamically. If both objA and objB are numrical then they will be compared as numbers.
		If objA or objB are string then they will be compared as string.

		If objA is a var but objB is an object then false will be returned.
		if objA is an object but objB is a var then false will be returned.
		
		if objA and objB are vars and StringCaseSense is on then they will be compare case sensitive; Otherwise compared case in-sensitive.
		This does not apply if CompareOpt has a flag CompareNumber set with both objA and objB numeric.
		
		If CompareOpt has a flag CompareNumber set and StringCaseSense is on then objA and objB will be compared as case sensitive string
		if they are not numeric.
		Any objects can be compared. It is not necessary the objects inherit from MfObject.
*/
	Equals(args*) {
		isInst := this.IsInstance()

		p := Null
		if (isInst)
		{
			p := this._EqualsParams(A_ThisFunc, args*)
			x := &p.Item[0]
			y := &this
		}
		else
		{
			p := MfObject._EqualsParams(A_ThisFunc, args*)
			x := &p.Item[0]
			y := &p.Item[1]
		}
		/*
		if (!IsObject(objA)) {
			return false
		}
		x := &objA ; An object's address can be retrieved by x := &obj
		if (IsObject(objB)) {
			y := &objB
		} else {
			y := &this
		}
		*/		
		return (x = y)
	}
; End:Equals(objA, ObjB = "") ;}
;{	GetAttribute()
/*
	Method: GetAttribute()

	OutputVar := instance.GetAttribute(index)

	GetAttribute(index)
		Gets an MfAttribute of the class.
	Parameters:
		index
			the zero-based index. Can be MfInteger or var containing Integer number.
	Returns:
		Returns the object derived from MfAttribute from this instance of the class.
	Throws:
		Throws MfIndexOutOfRangeException if index is outside valid range.
*/
	GetAttribute(index) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_index := MfInteger.GetValue(index)
		if (_index < 0 ) {
			ex := new MfArgumentOutOfRangeException("index",MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.Source := A_ThisFunc
			throw ex
		}
		if ((this.__m_Attributes = Null) || ( _index >= this.__m_Attributes.Count)) {
			ex := new MfArgumentOutOfRangeException("index",MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.Source := A_ThisFunc
			throw ex
		}
		return this.__m_Attributes.Item[index]
	}
;	End:GetAttribute() ;}
;	GetAttributes ;}
/*
	Method: GetAttributes()

	OutputVar := instance.GetAttributes()

	GetAttributes()
		Gets a MfGenericList of MfAttribute that Contains the attributes for the current class instance
	Returns:
		Returns MfGenericList of MfAttribute.
	Throws:
		Throws MfNullReferenceException if called as a static method.
	Remarks:
		Protected Method.
		This method is intended to be used by derived classes only and is to be treated as a protected method. MfNumberStyles class is an example of using this method to add MfFlagsAttribute to a class.
*/
	GetAttributes()	{
		if (!this.IsInstance()) {
			ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param","MfObject"))
			ex.Source := A_ThisFunc
			throw ex
		}
		if (this.__m_Attributes = Null) {
			this.__m_Attributes := new MfGenericList(MfAttribute)
		}
		return this.__m_Attributes
	}
;	End:GetAttributes ;}
;{ 	GetHashCode()
/*
	Method: GetHashCode()

	OutputVar := instance.GetHashCode()

	GetHashCode()
		Gets A hash code for the current MfObject.
	Returns:
		Returns A hash code for the current MfObject.
	Remarks:
		A hash code is a numeric value that is used to insert and identify an object in a hash-based collection such as a Hash table.
		The GetHashCode() method provides this hash code for hashing algorithms and data structures such as a hash table.
		Two objects that are equal return hash codes that are equal.
		However, the reverse is not true: equal hash codes do not imply object equality, because different (unequal) objects can have
		identical hash codes.
		Furthermore, the this Framework does not guarantee the default implementation of the GetHashCode() method, and the value this
		method returns may differ between Framework versions such as 32-bit and 64-bit platforms.
		For these reasons, do not use the default implementation of this method as a unique object identifier for hashing purposes.
		
	Caution
		A hash code is intended for efficient insertion and lookup in collections that are based on a hash table.
		A hash code is not a permanent value. For this reason:
		* Do not serialize hash code values or store them in databases.
		* Do not use the hash code as the key to retrieve an object from a keyed collection.
		* Do not test for equality of hash codes to determine whether two objects are equal.
		  (Unequal objects can have identical hash codes.)
		  To test for equality, call the MfObject.ReferenceEquals() or MfObject.Equals() method.
*/
	GetHashCode() {
		try
		{
			retval := &this
			retval := Format("{:i}", retval)
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}
; End:GetHashCode() ;}
;{	GetIndexOfAttribute()
/*
	Method: GetIndexOfAttribute()

	OutputVar := instance.GetIndexOfAttribute(attrib)

	GetIndexOfAttribute(attrib)
		Gets the zero-based index value of the position of MfAttribute within the instance of the class.
	Parameters:
		attrib
			The object instance derived from MfAttribute.
	Returns:
		Returns the zero-based index as var containing integer of the MfAttribute within this instance of the class if found; Otherwise -1 is returned.
*/
	GetIndexOfAttribute(attrib) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(this.__m_Attributes)) {
			return -1
		}
		if (MfObject.IsObjInstance(attrib, MfAttribute)) {
			return this.__m_Attributes.IndexOf(attrib)
		}
		strAttrib := Null
		if ((IsObject(attrib)) && (IsFunc(attrib.Is)) && (attrib.Is(MfAttribute))){
			strAttrib := attrib.__Class
		}
		if ((MfNull.IsNull(strAttrib)) && (!IsObject(attrib)) && (attrib ~= "^[a-zA-Z0-9]+$")) {
			strAttrib := attrib
		}
		if (MfNull.IsNull(strAttrib)) {
			return -1
		}
		index := -1
		Loop, % this.__m_Attributes.Count
		{
			index++
			att := this.__m_Attributes.Item[index]
			if (att.base.__Class = strAttrib) {
				break
			}
		}
		return index
	}
;	End:GetIndexOfAttribute() ;}
;{ 	GetType()
/*
	Method: GetType()

	OutputVar := instance.GetType()

	GetType()
		Gets the Type for the for the Class
	Returns:
		Returns Instance of MfType Class representing the type of this object
*/
    GetType() {
		if(!this.IsInstance()) {
			return new MfType(this)
		}
		if (!IsObject(this.__m_GetType)) {
			this.__m_GetType := new MfType(this)
        }
        return this.__m_GetType
	}
; End:GetType() ;}
;{	HasAttribute()
/*
	Method: HasAttribute()

	OuptupVar := instance.HasAttribute()

	HasAttribute(attrib)
		Gets if the current instance of class derived from MfSystemException has MfAttribute.
	Parameters:
		attrib
			The object instance derived from MfAttribute.
	Returns:
		Returns true if this instance of class has the MfAttribute; Otherwise false.
*/
	HasAttribute(attrib) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(this.__m_Attributes)) {
			return false
		}
		if (MfObject.IsObjInstance(attrib, MfAttribute)) {
			return this.__m_Attributes.contains(attrib)
		}
		strAttrib := Null
		if ((IsObject(attrib)) && (IsFunc(attrib.Is)) && (attrib.Is(MfAttribute))){
			strAttrib := attrib.__Class
		}
		if ((MfNull.IsNull(strAttrib)) && (!IsObject(attrib)) && (MfType.TypeOfName(attrib) != Undefined)) {
			strAttrib := attrib
		}
		if (MfNull.IsNull(strAttrib)) {
			return false
		}
		index := 0
		bHas := false
		Loop, % this.__m_Attributes.Count
		{
			att := this.__m_Attributes.Item[index]
			if (att.base.__Class = strAttrib) {
				bHas := true
				break
			}
			index++
		}
		return bHas
	}
;	End:HasAttribute() ;}

;{ 	Is(ObjType)
/*
	Method: Is()

	OutputVar := instance.Is(type)

	Is(type)
		Gets if current instance of object is of the same type
	Parameters:
		type
			The object to compare this instance type with Type can be an instance of MfType or an object derived from MfObject
			or an instance of or a string containing the name of the object type such as "MfObject"
	Returns:
		Returns true if current object instance is of the same type as the type Parameter otherwise false
	Remarks:
		If a string is used as the Type case is ignored so "MfObject" is the same as "mfobject"
*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = Undefined)
		{
			return false
		}
		
		cBase := this
		retval := false
		
		while cBase
		{
			if (typeName = cBase.__Class)
			{
				retval := true
				break
			}
			cBase := cBase.base
		}
		
		;if ((retval = false) && (typeName = "MfObject")) {
		;	retval := true
		;}

		return retval
	}
; End:Is(ObjType) ;}
;{ 	IsInstance()
/*
	Method: IsInstance()

	OutputVar := MfObject.IsInstance()

	IsInstance()
		Get if the current class is an instance
	Returns:
		Returns true if object is instance otherwise false.
*/
	IsInstance() {
		if (this.__m_isinstance) {
			return true
		}
		return false
	}
; End:IsInstance() ;}	
;{ 	IsMfObject()
/*
	Method: IsMfObject()

	OutputVar := MfObject.IsMfObject(obj)

	IsMfObject(obj)
		Gets if obj is a MfObject or derived class. All objects and/or classes that do not derive from MfObject will return false.
	Parameters:
		obj
			An Object to Check
	Returns:
		Returns true if object is derived from MfObject. Otherwise false.
	Remarks:
		Static Method.
		obj can be an instance or not.
*/
	IsMfObject(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if ((!obj) || (!IsObject(obj))) {
			return false
		}
		if ((!IsFunc(obj.Is)) && (!IsFunc(obj.base.Is))) {
			return false
		}
		if (obj.Is("MfObject")) {
			return true
		}
		return false
	}
; End:IsMfObject() ;}
;{ 	IsObjInstance()	
/*
	Method: IsObjInstance()

	OutputVar := MfObject.IsObjInstance(obj)
	OutputVar := MfObject.IsObjInstance(obj, objType)

	IsObjInstance(obj)
		Checks to see if obj is an instance of MfObject.
	Returns:
		Returns true if obj is instance of MfObject or class instance derived from MfObject; Otherwise false.

	IsObjInstance(obj, objType)
		Checks to see if obj is instance specified by objType.
	Parameters:
		obj
			an object derived from MfObject to check.
		objType
			String name of type; or MfObject or dervived classs; or instance of MfType class.
	Returns:
		Returns true if obj is instance of objType; Otherwise false.
	Remarks:
		Static functions.
		Only objects that inherit from MfObject are valid object to check. If objType param is ignored then object is checked as MfObject
		See Also: IsNotObjInstance()
*/
	IsObjInstance(obj, objType = "") {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ot := ""
		if (MfObject._IsNull(objType)) {
			ot := "MfObject"
		}
		if (MfObject._IsNull(ot)) {
			ot := objType
		}
		if ((!obj) || (!IsObject(obj))) {
			return false
		}
		if ((!IsFunc(obj.Is))
			&& (!IsFunc(obj.base.Is)))
		{
			return false
		}
		if (!obj.Is(ot)) {
			return false
		}
		return obj.IsInstance()
	}
; End:IsObjInstance(obj, objType = "") ;}
;{ 	IsNotObjInstance
/*
	Method: IsNotObjInstance()

	IsNotObjInstance()
		Gets if Obj Parameter is of the expenced type and instance
	Parameters:
		obj
			The Object to check
		objType
			String name of type; or MfObject or dervived classs; or instance of MfType class.
		returnErrors
			Optional, default is True, boolean var, If True then if Obj is not of the correct type and instance then an Excption derived from MfExcptions is returned;
			Otherwise true is returned if there is an error

	Returns:
		Returns false if there are no errors and obj is and instance of objType.
		Returns true if returnErrors is set to false and there is an error
		Return an MfException based exception if returnErrors is set to true and there is an error
		Returns MfArgumentNullException if obj parameter is null if returnErrors is true
		Returns MfNonMfObjectException if returnErrors is true and obj is not set to an instance
		Returns MfArgumentException if returnErrors is true and obj is not if type matching or deriving form objType

	Remarks:
		See Also: IsObjInstance()
*/
	IsNotObjInstance(obj, objType:="", returnErrors:=true, ParamName:="obj") {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(obj))
		{
			if (returnErrors = true)
			{
				ex := new MfArgumentNullException(ParamName)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				return ex
			}
			else
			{
				return true
			}
		}
		ot := ""
		if (MfObject._IsNull(objType)) {
			ot := "MfObject"
		}
		if (MfObject._IsNull(ot)) {
			ot := objType
		}
		if(IsObject(obj))
		{
			if(!MfObject.IsMfObject(obj))
			{
				if (returnErrors = true)
				{
					ex := new MfNonMfObjectException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", ParamName))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					return ex
				}
				return true
					
			}
			if (!obj.Is(ot))
			{
				if (returnErrors = true)
				{
					oType := IsObject(ot)?ot.GetType().ToString():ot
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_TypeNotExpected", obj.GetType().ToString(), oType), ParamName)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					return ex
				}
				return true
			}
			if (obj.IsInstance() = false)
			{
				if (returnErrors = true)
				{
					ex := new MfArgumentNullException(ParamName, MfEnvironment.Instance.GetResourceString("Arg_NullReferenceException"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					return ex
				}
				return true
			}
			return false
		}
		if (returnErrors = true)
		{
			ex := new MfArgumentNullException(ParamName, MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", ParamName))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			return ex
		}
		return true

	}
; 	End:IsNotObjInstance ;}
;{	MemberwiseClone()
/*
	Method: MemberwiseClone()

	OutputVar := instance.MemberwiseClone()

	MemberwiseClone()
		Creates a shallow copy of the current MfObject instance.
	Returns:
		Returns a shallow copy of the current MfObject instance.
	Throws:
		Throws MfNullReferenceException if MfObject is not an instance.
*/
	MemberwiseClone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return this.Clone()
	}
;	End:MemberwiseClone() ;}
;{ 	ReferenceEquals()
/*
	Method: ReferenceEquals()

	OutputVar := MfObject.ReferenceEquals(objA, objB)

	ReferenceEquals(objA, objB)
		Determines whether the specified Object instances are the same instance.
	Parameters:
		objA
			The first object to compare.
		objB
			The second object to compare.
	Returns:
		Returns true if objA is the same instance as objB or if both are null; Otherwise, false.
	Remarks:
		If you want to test two object references for equality and are unsure about the implementation of the Equals method,
		you can call the ReferenceEquals method. When calling this method call using MfObject.ReferenceEquals to ensure that
		ReferenceEquals has not been overridden on Derived classes.
		Static Function.
*/
	ReferenceEquals(objA, objB) {
		bObjA := IsObject(objA)
		bObjB := IsObject(objB)
		if ((!bObjA) || (!bObjB)) {
			return false
		}
		x := &objA ; An object's address can be retrieved by x := &obj
		y := &objB
		return (x = y)
	}
; End:ReferenceEquals() ;}
;{ 	ToString()
/*
	Method: ToString()

	OutputVar := instance.ToString()

	ToString()
		Gets a string representation of the MfObject.
	Returns:
		Returns string value representing MfObject.
*/
    ToString() {
		retval := ""
		if (this.__m_isinstance) {
			retval := this.GetType().ToString()
		} else {
			retval := this.__Class ;"MfObject"
		}
		return retval
	}
; End:ToString() ;}	
;{  VerifyIsInstance()
/*
	Method: VerifyIsInstance()

	OutputVar := this.VerifyIsInstance([ClassName, LineFile, LineNumber, Source])

	VerifyIsInstance([ClassName, LineFile, LineNumber, Source])
		Verifies the the current object is set to an instance.
	Parameters:
		ClassName
			The name of the class Calling this is calling this method that will be passed to the MfNullReferenceException error message if not an instance.
			Can be class object this or MfString instance or string var
		LineFile
			The LineFile to pass to the MfNullReferenceException if not an instance.
			Can MfString instance or string var
		LineNume
			The LineNumber to pass to the MfNullReferenceException if not an instance.
			Can MfString instance or string var
		Source
			The source to pass to the MfNullReferenceException if not an instance
			Can be var or any object.
	Returns:
		Returns true if object is an instance otherwise MfNullReferenceException instance is thrown.
	Throws:
		Throws MfNullReferenceException if class is not an instance
	Remarks:
		Protected method.
		This method is intended to make it easier for implementers to ensure class is being called correctly in derived classes.
		You can use this method to ensure instance methods are NOT called as static methods in derived classes.
*/
	VerifyIsInstance(args*) {
		; args: [ClassName, LineFile, LineNumber, Source]
		if (!this.IsInstance())
		{
			p := this._verifyIsInstanceParams(args*)
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
				msg := MfEnvironment.Instance.GetResourceString("NullReferenceException_Object")
			}
			Else
			{
				msg := MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param", ClassName)
			}

			ex := new MfNullReferenceException(msg)
			ex.SetProp(LineFile, LineNumber, Source)
			throw ex
		}
		return true
	}
; End: VerifyIsInstance() ;}
;{  VerifyIsNotInstance()
/*
	Method: VerifyIsNotInstance()

	OutputVar := this.VerifyIsNotInstance([MethodName, LineFile, LineNumber, Source])

	VerifyIsNotInstance([MethodName, LineFile, LineNumber, Source])
		Verifies the the current object is NOT set to an instance.
	Parameters:
		MethodName
			The name of the calling method or property. Will be passed to the MfInvalidOperationException error message if not an instance.
			Can MfString instance or string var
		LineFile
			The LineFile to pass to the MfInvalidOperationException if not an instance.
			Can MfString instance or string var
		LineNume
			The LineNumber to pass to the MfInvalidOperationException if not an instance.
			can be integer var
		Source
			The source to pass to the MfInvalidOperationException if not an instance
			Can be var or any object.
	Returns:
		Returns true if object is an instance otherwise MfInvalidOperationException instance is thrown.
	Throws:
		Throws MfInvalidOperationException if class is an instance.
	Remarks:
		Protected method.
		This method is intended to make it easier for implementers to ensure class is being called correctly in derived classes.
		You can use this method to ensure static methods are called as static method only in derived classes
*/
	VerifyIsNotInstance(args*) {
		; args: [MethodName, LineFile, LineNumber, Source]
		if (this.IsInstance())
		{
			p := this._verifyIsInstanceParams(args*)
			MethodName := ""
			LineFile := A_LineFile
			LineNumber := A_LineNumber
			Source := A_ThisFunc

			mfgP := p.ToStringList()
			for i, str in mfgP
			{
				if ((i = 0) && (str.Value = "MfString"))
				{
					MethodName := p.Item[i].Value
				}
				else if ((i = 1) && (str.Value = "MfString"))
				{
					LineFile := p.Item[i].Value
				}
				else if ((i = 2) && (str.Value = "MfInteger"))
				{
					LineNumber := p.Item[i].Value
				}
				else if (i = 3)
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

			if (MfString.IsNullOrEmpty(MethodName))
			{
				;NotSupportedException_Static_Method_General
				msg := MfEnvironment.Instance.GetResourceString("NotSupportedException_Static_Method_General")
			}
			Else
			{
				msg := MfEnvironment.Instance.GetResourceString("NotSupportedException_Static_Nethod", MethodName)
			}

			ex := new MfInvalidOperationException(msg)
			ex.SetProp(LineFile, LineNumber, Source)
			throw ex
		}
		return true
	}
; End: VerifyIsNotInstance() ;}

; End:Methods ;}
; Internal Methods
;{ 	_EqualsParams()
/*
	Function: _EqualsParams()
		Internal Function
		Gets a MfParams instance of the args
		If this is an instance then only one arg in args* is allowed
		If this is static then two args are required in args*
		Empty args* will throw an error
	Returns
		Instance of MfParams represnting the valuse contained in args
	Remarks
		All vars are added as string to MfParams instance and therefore when two vars are
		added that are string as numbers that have the same mathamatical value such as "022" an "22" they will
		be consider equal and MfObject.Equals("022", "22") would be considered equal.
		However MfObject.Equals(new MfInteger(22), 22) would not be considered equal
		
		If StringCaseSense is On then MfObject.Equals("aBc", "abc") would not be considered equal
		If StringCaseSense is Off then MfObject.Equals("aBc", "abc") would be considered equal
		
		MfObject.Equals(new MfString("abc"), "abc") would not be considered equal
		
		If non-instance and both args are vars then vars are compared following case rules
		set by StringCaseSense.
		For example if arg1 = "abc" and arg2 = "abc" then the MfParms instance Item[0] and Item[1]
		will be the same instance and have the same memory address.
		However if one of the args is a object and the other is a var then Item[0] and Item[1] will
		always have different memory address.
		
		If arg1 and arg2 have the same memory addres then Item[0] and Item[1] will also have the same memory address
		
		If is instance and arg1 has the same memory addres as current instance the Item[0] will have the same memory
		address as the current instance.
	Throws
		Throws MfNotSupportedException of no overloads match
		Throws MfArgumentException if error getting an argument value.
*/
	_EqualsParams(MethodName, args*) {
		p := Null
		isInst := this.IsInstance()
		cnt := MfParams.GetArgCount(args*)
		if (MfObject.IsObjInstance(args[1],MfParams)) {
			p := args[1] ; arg 1 is a MfParams object so we will use it
			if (isInst = true)
			{
				if (p.Count > 2)
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			else if (p.Count > 3)
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				ex.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw ex
			}
		}
		else
		{
			p := new MfParams()
			p.AllowEmptyString := true ; allow empty strings to be compared
			if (isInst = true)
			{
				if (cnt != 1)
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			else if ((cnt < 2) || (cnt > 3))
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				ex.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw ex
			}
			CompareVar := true

			if (isInst = true)
			{
				; can only be one obj or var
				p.Add(args[1])
			}
			Else ; non instance
			{
				; can be var or var and compare options
				if (cnt = 2)
				{
					; default to compare as string for vars
					var1 := args[1]
					var2 := args[2]
					if (IsObject(var1) || IsObject(var2))
					{
						p.Add(var1)
						p.Add(var2)
					}
					Else
					{
						MfObject._ParamAddStringCompVar(var1, var2, p)
					}
				}
				Else
				{
					; count must be 3, check compare options
					CompareAsNumber := false
					var1 := args[1]
					var2 := args[2]
					if (IsObject(args[3]))
					{
						CompareType := args[3]
						if ((!MfObject.IsObjInstance(CompareType, MfEqualsOptions)) && (!MfObject.IsObjInstance(CompareType, MfEnum.EnumItem)))
						{
							err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_EnumIllegal"))
							err.SetProp(A_LineFile, A_LineNumber, MethodName)
							throw err
						}

						if (CompareType.Is(MfEqualsOptions))
						{
							if (CompareType.HasFlag(MfEqualsOptions.Instance.CompareNumber))
							{
								CompareAsNumber := true
							}
						}
						else if (CompareType.Value = MfEqualsOptions.Instance.CompareNumber.Value)
						{
							CompareAsNumber := true
						}
					}
					Else
					{
						if (!Mfunc.IsInteger(args[3]))
						{
							err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_EnumIllegalVal", args[3]))
							err.SetProp(A_LineFile, A_LineNumber, MethodName)
							throw err
						}
						CompareType := MfEnum.ToObject(MfEqualsOptions.GetType(), args[3])
						if (CompareType.HasFlag(MfEqualsOptions.Instance.CompareNumber))
						{
							CompareAsNumber := true
						}
					}
					if (CompareAsNumber = true)
					{
						MfObject._ParamAddNumbCompVar(var1, var2, p)
					}
					Else
					{
						MfObject._ParamAddStringCompVar(var1, var2, p)
					}
					p.Add(CompareType)
				}
			}
		}
		return p
	}
; 	End:_EqualsParams() ;}
;{ 	_IsNull()
	_IsNull(obj) {
		; do not use MfNull.IsNull() here. It messing thing up a lot
		if (IsObject(obj)) {
			if (((obj.Is("MfObject") = false) 
				&& (obj.IsInstance() = false))
				|| (obj.base.__Class = "MfNull")) ; Just in case null instance was passed
			{
				return true
			}
			return false
		} 

		; Note: _HasFlag of MfEnum is used instead of HasFlag method.
		; this is necessary when checking flag options in IsNull()
		; If HasFlag is used will cause errors and recursion.
		; _HasFlag only takes an Integer var so send it a value
		;
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
; 	End:_IsNull() ;}
;{ 	_ParamAddStringCompVar()
	_ParamAddStringCompVar(var1, var2, byref p) {
		; compare as String
		if(A_StringCaseSense = "On")
		{
			if ((var1 . "") == (var2 . ""))
			{
				pIndex := p.Add(var1)
				p.Add(p.Item[pIndex]) ; add the same object with the same memory address
			}
			Else
			{
				p.AddString(var1)
				p.AddString(var2)
			}
		}
		Else
		{
			if ((var1 . "") = (var2 . ""))
			{
				pIndex := p.Add(var1)
				p.Add(p.Item[pIndex]) ; add the same object with the same memory address
			}
			Else
			{
				p.AddString(var1)
				p.AddString(var2)
			}
		}
	}
; 	End:_ParamAddStringCompVar() ;}
;{ 	_ParamAddNumbCompVar()
	_ParamAddNumbCompVar(var1, var2, byref p) {
		; compare as String
		if(A_StringCaseSense = "On")
		{
			if ((var1) == (var2))
			{
				pIndex := p.Add(var1)
				p.Add(p.Item[pIndex]) ; add the same object with the same memory address
			}
			Else
			{
				p.AddString(var1)
				p.AddString(var2)
			}
		}
		Else
		{
			if ((var1) = (var2))
			{
				pIndex := p.Add(var1)
				p.Add(p.Item[pIndex]) ; add the same object with the same memory address
			}
			Else
			{
				p.AddString(var1)
				p.AddString(var2)
			}
		}
	}
; 	End:_ParamAddNumbCompVar() ;}
;{ _verifyIsInstanceParams()
	_verifyIsInstanceParams(args*) {
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
; End:_verifyIsInstanceParams() ;}
; End: Internal Methods
}

/*!
	End of class
*/
; End:Class MfObject ;}
