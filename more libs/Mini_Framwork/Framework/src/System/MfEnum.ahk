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

;{ Class MfEnum
/* ToDo
	Add Example to AddEnums and AddEnumValues
*/
/*!
	Class: MfEnum
		Abstract class.  
		Provides implementation methods and properties for MfEnum type classes
	Inherits:
		MfValueType
*/
class MfEnum extends MfValueType
{

;{ Static members
;{ 	TypeCode - static
	; static method
	; unique id for MfEnum
	; matchs MfType.TypeCodes
	TypeCode[]
	{
		get {
			return 19
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:TypeCode ;}
;{ 	enumSeperator - static
	static m_enumSeperator := ", "
	enumSeperator[]
	{
		get {
			return MfEnum.m_enumSeperator
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:enumSeperator ;}
;{ 	enumSeperatorChar - static
	static m_enumSeperatorChar		:= ","
	enumSeperatorChar[]
	{
		get {
			return MfEnum.m_enumSeperatorChar
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:enumSeperatorChar ;}
; End:Static members ;}
	m_Value 					:= Null
	m_MaxValue 					:= Null
	m_Type						:= Null
	m_HasFlags					:= false
;{ Constructor
/*
	Constructor()
	
	OutputVar := new MfEnum()
	OutputVar := new MfEnum(num)
	OutputVar := new MfEnum(instanceEnum)
	OutputVar := new MfEnum(enumItem1, enumItem2, enumItem3, ...)
	
	Constructor ()
		Creates a new instance derived from MfEnum class and set initial value to zero.
	
	Constructor (num)
		Creates a new instance derived from MfEnum class and sets initial value to value of num.
	
	Constructor (instanceEnum)
		Creates a new instance derived from MfEnum class an set the intial value to the value of instanceEnum.
	
	Constructor (enumItem)
		Creates a new instance of derived class and set its value to the MfEnum.EnumItem instance value.
	
	Parameters
		num
			A value representing the current selected MfEnum.EnumItem value(s) of the derived class.
		instanceEnum
			An instance of derived class whose value is used to construct this instance.
		enumItem
			MfEnum.EnumItem value must element of this instance
	
	General Remarks
		All Constructors are abstract as MfEnum is a abstract class and must be extended.
	Throws
		Throws MfNotSupportedException if this sealed class is extended or inherited.
		Throws MfArgumentException if arguments are not correct.
*/
	__New(args*) {
		if (this.__Class = "MfEnum") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass",this.__Class))
		}
		base.__New()
		this.AddAttributes()
		;this.Validate(value)
		this.m_Value := 0
		this.AddEnums()
		
		if (this.HasAttribute(MfFlagsAttribute)) {
			this.m_HasFlags := true
		}
		
		_value := args[1]
		bArgs := true
		if (MfNull.IsNull(_value)) {
			bArgs := false
		}
		if (bArgs = true) {
			if (!IsObject(_value)) {
				this.m_Value := MfInteger.GetValue(_value)
				bArgs := false
			} else {
				;t := this.GetType()
				if (MfObject.IsObjInstance(_value, MfEnum)) {
					this.m_Value := _value.Value
					bArgs := false
				}
			}
		}
		
		if (bArgs = true) {
			t := this.GetType()
			pCount := 0
			for index, arg in args
			{
				pCount++
			}
			if ((this.m_HasFlags = false) && (pCount > 1)) {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_EnumNotSingleFlag"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			for index, arg in args
			{
				if (MfNull.IsNull(arg)) {
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_MustBeEnum"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				if (MfObject.IsObjInstance(arg, "MfEnum.EnumItem")) {
					if (!arg.Type.Equals(t)) {
						ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_EnumFormatUnderlyingTypeAndObjectMustBeSameType", arg.ToString(),this.GetType().ClassName))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						throw ex
					}
					this.m_Value := this.m_value | arg.Value
				} else {
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_MustBeEnum"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			bArgs := false
		}
		this.m_isInherited := false
	}
; End:Constructor ;}
;{ Methods
;{ 	AddAttributes()
/*
	Method: AddAttributes()

	AddAttributes()
		Overridable method. In derived classes when overridden this method adds any attributes to the MfEnum such as MfFlagsAttribute.
	Remarks
		Protected Method
		Override this method in derived classes to add attributes such as MfFlagsAttribute.
		It is recommended this method be treated as a protected method.
*/
	AddAttributes() {
	}
; 	End:AddAttributes() ;}
;{ 	AddEnums()
/*
	Method: AddEnums()

	AddEnums()
		Abstract method. Call to process adding of new MfEnum values to derived class.
	Throws
		Throws MfNotImplementedException if not overridden in derived classes.
	Remarks
		This method is intended to be treated as a Protected method and must be overriden in derived classes.
*/
	AddEnums() {
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", "AddEnum"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:AddEnums() ;}
;{ 	AddEnumValues()
/*
	Method: AddEnumValue()
	
	AddEnumValue(name, value)
		Adds new Enum Name to MfEnum derived class that represents an instance of MfEnum.EnumItem.
	Parameters
		name
			the name of the new MfEnum to add to derived class. Can be MfString or var containing string value.
		value
			the numeric value for to for the instance of MfEnum.EnumItem. Can be MfInteger or var containing integer value.
	Remarks
		Each name represents an object instance of MfEnum.EnumItem.
		Each name adds a new Property of name that is an instance of MfEnum.EnumItem.
		This method is intended to  be used as a Protected method in derived classes.
		Howerver if called directly on a class derived from  MfEnum then it would add new enum to the instance.
		This method is usually called inside of the AddEnums method of derived classes.
	Throws
		Throws MfArgumentNullException if name is null.
		Throws MfArgumentException if name is not a string var.
		Throws MfException with innerException if any other errors occur.		
*/
	AddEnumValue(name, value) {
		if (MfString.IsNullOrEmpty(name)) {
			ex := new MfArgumentNullException("name",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","name"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_name := MfString.GetValue(name)
		if (!(_name ~= "^[a-zA-Z0-9_]+$")) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_StringVar","name"),"name")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(this.m_Type)) {
			this.m_Type := this.GetType()
		}
		if (!ObjHasKey(this, _name)) {
			try {
				_value := MfInteger.GetValue(value)
				itm := new MfEnum.EnumItem(_name, _value, this.m_Type, this)
				ObjRawSet(this, _name, itm)
			} catch e {
				err := new MfException(MfEnvironment.Instance.GetResourceString("Exception_EnumAdd"), e)
				err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw err
			}
		}
		; just in case the AddEnumValue is called after construction of enum then will reset MaxValue
		this.m_MaxValue := Null
	}
; End:AddEnumValues() ;}
;{ 	AddFlag()
/*!
	Method: ddFlag()

	instance.AddFlag(flag)

	AddFlag(flag)
		Adds a flag value to the current Value of MfEnum instance.
	Parameters
		flag
			The flag to add represented as an instance of MfEnum or MfEnum.EnumItem.
	Throws
		Throws MfNullReferenceException if derived MfEnum is not an instance.
		Throws MfNotSupportedException if derived MfEnum does not Implement MfFlagsAttribute class.
		Throws MfArgumentException if flag is incorrect type.
		Throws MfArgumentException if flag is null.
*/
	AddFlag(flag) {
		if (!this.IsInstance())
		{
			ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param",this.__Class))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.__HasFlagsAttribute = false)
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FlagsAttrib_Missing_Remove"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (IsObject(flag)) 
		{
			if (MfObject.IsObjInstance(flag, this.GetType())) {
				_flag := flag.Value
			} else if (MfObject.IsObjInstance(flag, MfEnum.EnumItem)) {
				if (!flag.Type.Equals(this.GetType())) {
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_EnumTypeDoesNotMatch",this.GetType(),flag.Type))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				_flag := flag.Value
			} else {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_EnumTypeDoesNotMatch",this.GetType(),flag.GetType()))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName","flag"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_Flags := this.Value
		_Flags := _Flags & ~_flag ; Remove Flag
		_Flags := _Flags | _flag ; Add Flag
		this.Value := _Flags

		;~ if (!this._HasFlag(_flag)) {
			;~ _Flags := this.Value
			;~ _Flags := _Flags | _flag ; Add Flag
			;~ this.Value := _Flags
		;~ }
		return Null
	}
; End:AddFlag() ;}
;{ 	DestroyInstance()
/*
	Method: DestroyInstance()
	
	MfEnum.DestroyInstance()
	
	DestroyInstance()
		Set current instance of MfEnum derived class to null.
		Abstract Method.
	Throws
		Throws MfNotImplementedException if not implemented in derived class.
	Remarks
		DestroyInstance() is an abstract method and must be implemeted in derived class.
*/
	DestroyInstance() {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", "DestroyInstance"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:DestroyInstance() ;}
;{ 	Equals()						- Overrides	- MfObject
/*
	Method: Equals()
		Overrides MfObject.Equals
	
	OutputVar := MfEnum.Equals(objA, ObjB)
	OutputVar := instance.Equals(objA)
	
	Equals(objA)
		Compares objA against current MfEnum instance to see if they have the same Value.
	
	Equals(objA, objB)
		Compares objA against objB to see if they have the same value.
		Static Method
	
	Parameters
		objA
			The first MfEnum.EnumItem or MfEnum derived instance to compare.
		objB
			The second MfEnum.EnumItem or MfEnum derived instance to compare.
	Returns
		Returns var containing Boolean value of true if the MfEnum.EnumItem.Value or MfEnum.
		Value instances have the samve Value otherwise false.
	Throws
		Throws MfArgumentNullException if objA is null.
		Throws MfNullReferenceException if Non-Static [Equals(objA)] method is called when insance as not be created
		Throws MfArgumentException if objA or objB are not type of MfEnum.EnumItem or MfEnum.
*/
	Equals(objA, objB="") {
		
		if (MfNull.IsNull(objA)) {
			ex := new MfArgumentNullException("objA",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","objA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if ((!MfObject.IsObjInstance(objA, "MfEnum")) && (!MfObject.IsObjInstance(objA, "MfEnum.EnumItem"))) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Object_Equals"),"objA")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(objB)) {
			
			if ((!MfObject.IsObjInstance(objA, "MfEnum")) && (!MfObject.IsObjInstance(objA, "MfEnum.EnumItem"))) {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_TypeInstanceDoesNotMatch",objA.GetType(),this.GetType()),"objA")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
				
			}
			if (!this.IsInstance()) { ; this class must be an instance if objB is absent.
				ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param",this.GetType().ClassName))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			x := this
			y := ObjA
		} else {
			if ((!MfObject.IsObjInstance(objB, "MfEnum")) && (!MfObject.IsObjInstance(objB, "MfEnum.EnumItem"))) {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Object_Equals"),"objB")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			x := objA
			y := objB
		}
		return x.Value = y.Value
	}
; End:Equals() ;}
;{ 	CompareTo()						- Overrides	- MfObject
/*!
	Method: CompareTo()
		Overrides MfObject.CompareTo
	
	OutputVar := instance.CompareTo(obj)
	
	CompareTo(obj)
		Compares the current instance with another object derived from MfEnum or MfEnum.
		EnumItem Instance and returns an integer that indicates whether the current instance Value precedes,
		follows, or occurs in the same position in the sort order as the other object.
		This method can be overridden in extended classes.
	Parameters
		obj
			Can be  MfEnum or MfEnum.EnumItem Instance
	Returns
		Returns A value that indicates the relative order of the objects being compared.
		The return value has these meanings: Value Meaning Less than zero This instance precedes obj in the sort order.
		Zero This instance occurs in the same position in the sort order as obj Greater than zero This instance follows
		obj in the sort order.
	Throws
		Throws MfNullReferenceException if instance enum is not an instance.
		Throws MfArgumentNullException if obj is null.
		Throws MfArgumentException if obj is not an  derived from MfEnum or MfEnum.EnumItem Instance.
*/
	CompareTo(obj) {
		if (!this.IsInstance()) {
				ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param",this.__Class))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (MfNull.IsNull(obj)) {
				ex := new MfArgumentNullException("obj",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!MfObject.IsObjInstance(obj)) {
				ex := new MfArgumentNullException("obj",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if ((!MfObject.IsObjInstance(obj, "MfEnum")) && (!MfObject.IsObjInstance(obj, "MfEnum.EnumItem"))) {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_TypeInstanceDoesNotMatch",obj.GetType(),this.GetType()),"obj")
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
; End:CompareTo() ;}

;{ 	GetHashCode()					- Inhertis	- MfObject
/*
	Method: GetHashCode()
		Overrides MfObject.GetHashCode()

	OutputVar := instance.GetHashCode()
	
	GetHashCode()
		Gets A hash code for the current MfEnum.
	Returns
		A 32-bit signed integer hash code as var.
*/
	GetHashCode() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		i64 := new MfInt64(MfInt64.GetValue(this.Value))
		return i64.GetHashCode()
	}
; End:GetHashCode() ;}
;{ 	GetInstance()
/*
	Method: GetInstance()
	
	OutputVar := GetInstance()
	
	GetInstance()
		Abstract method. Gets the instance of the Singleton
	Returns
		Returns Singleton instance for the derived class.
	Throws
		Throws MfNotImplementedException if method is not overridden in derived classes
	Remarks
		This method must be overridden in derived classes. The Instance Property will call
		GetInstance() if not instance is currently set.
		This method should be used as a Protectected method
*/
	GetInstance() {
		throw new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_GetInstance"))
	}
; 	End:GetInstance() ;}
;{	GetNames()
/*
	Method: GetNames()
	
	OutputVar := instance.GetNames()
	
	GetNames()
		Gets a of MfGenericList of MfString containing all enumeration names of derived MfEnum class.
	Returns
		Returns a MfGenericList of MfString containing enumeration names of derived MfEnum class.
	Remarks
		Each MfString instance in MfGenericList has it MfString.ReturnAsObject value set to false.
*/
	GetNames() {
		Names := new MfGenericList(MfString)
		for k, v in this
		{
			if (MfObject.IsObjInstance(v, MfEnum.EnumItem)) {
				Names.Add(new MfString(v.Name))
			}
		}
		
		return Names
	}
;	End:GetNames() ;}
;{ 	GetTypeCode()
/*
	Method: GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfEnum Type Code.
	Returns
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfEnum.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.Emum
	}
; End:GetTypeCode() ;}
;{	GetValue()
	GetValue(eInstance, EnumType = "") {
		if (MfNull.IsNull(eInstance)) {
			ex := new MfArgumentNullException("eInstance")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bIsEnumInstance		:= MfObject.IsObjInstance(eInstance, "MfEnum")
		bisEnumItemInstance	:= MfObject.IsObjInstance(eInstance,"MfEnum.EnumItem")
		bIsEnum 			:= true
		bIsEnum := ((bisEnumItemInstance = true) || (bIsEnumInstance = true))
		
		
		if (bIsEnum = false) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_MustBeEnum"),"eInstance")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		strType := MfType.TypeOfName(EnumType)
		if (!MfString.IsNullOrEmpty(strType) && (strType != Undefined)) {
			if (bIsEnumInstance) {
				if (!MfObject.IsObjInstance(eInstance,strType)) {
					eMsg := MfEnvironment.Instance.GetResourceString("Arg_EnumFormatUnderlyingTypeAndObjectMustBeSameType", strType, MfType.TypeOfName(eInstance))
					ex := new MfArgumentException(eMsg,"eInstance")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			if (bisEnumItemInstance) {
				if (strType != MfType.TypeOfName(eInstance.Type)) {
					eMsg := MfEnvironment.Instance.GetResourceString("Arg_EnumFormatUnderlyingTypeAndObjectMustBeSameType", strType, MfType.TypeOfName(eInstance.Type))
					ex := new MfArgumentException(eMsg,"eInstance")
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			
		}
		return eInstance.Value
	}
;	End:GetValue() ;}
;{	GetValues()
/*
	Methd: GetValues()
	
	OutputVar := instance.GetValues()
	
	GetValues()
		Gets a MfGenericList of MfInteger containing values of derived MfEnum class.
	Returns
		Returns a MfGenericList of MfInteger containing values of derived MfEnum class.
	Remarks
		Each MfInteger instance in MfGenericList has it MfInteger.ReturnAsObject value set to false.
*/
	GetValues() {
		Values := new  MfGenericList(MfInteger)
		for k, v in this
		{
			if (MfObject.IsObjInstance(v, MfEnum.EnumItem)) {
				Values.Add(new MfInteger(v.Value))
			}
		}
		return Values
	}
;	End:GetValues() ;}
;{	HasFlag
/*!
	Method: HasFlag()

	OutputVar := instance.HasFlag(flag)

	HasFlag(flag)
		Gets if the MfEnum extended class has a flag set
	
	Parameters
		flag
			A var containing integer or an instance extended from MfEnum.EnumItem
	Returns
		Returns true value if flag is set; Otherwise false.
	Throws
		Throws MfNullReferenceException if method is called on a non-instance.
		Throws MfArgumentNullException if flag is null.
		Throws MfNotSupportedException if MfFlagsAttribute is not implement on the extended MfEnum instance.
		Throws MfArgumentException if flag is not correct for this MfEnum instance
*/
	HasFlag(flag) {
		if (!this.IsInstance()) {
			ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param",this.__Class))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(flag)) {
			ex := new MfArgumentNullException("flag",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","flag"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (this.__HasFlagsAttribute = false)
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FlagsAttrib_Missing_Remove"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
				
		if (IsObject(flag)) {
			if (MfObject.IsObjInstance(flag, this.GetType())) {
				_flag := flag.Value
			} else if (MfObject.IsObjInstance(flag, MfEnum.EnumItem)) {
				if (!flag.Type.Equals(this.GetType())) {
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_EnumTypeDoesNotMatch",this.GetType(),flag.Type))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				_flag := flag.Value
			} else {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_EnumTypeDoesNotMatch",this.GetType(),flag.GetType()))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else {
			if (Mfunc.IsInteger(flag))
			{
				_flag := flag
			}
			else
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName","flag"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		return this._HasFlag(_flag)		
	}
	
	_HasFlag(flag) {
		WasFormat := A_FormatInteger
		SetFormat, IntegerFast, D
		if (!Mfunc.IsInteger(flag)) {
			SetFormat, IntegerFast, %WasFormat%
			return false
		}
		retval := false
		SetFormat, IntegerFast, H
		if ((this.Value & flag) > 0x00)
		{
			retval := true
		}
		SetFormat, IntegerFast, %WasFormat%
		return retval
	}
;	End:HasFlag ;}
;{ 	Is()				- Overrides - MfObject
/*
	Method: Is()
	Overrides MfObject.Is()
	
		OutputVar := instance.Is(ObjType)

	Is(ObjType)
		Gets if current instance of MfEnum.EnumItem is of the same type as ObjType or derived from ObjType.
	Parameters
		ObjType
			The object or type to compare to this instance Type.
			ObjType can be an instance of MfType or an object derived from MfObject or an instance of or a string containing
			the name of the object type such as "MfObject"
		IncludeEnumItem
			Optional Boolean, Default it false.
			If true and ObjType is MfEnum.EnumItem, type, instance, string name or non-instance class then true will be returned;
			Otherwise MfEnum.EnumItem is ignored as a possible valid ObjType
	Returns
		Returns true if current object instance is of the same Type as the ObjType or if current instance is derived
		from ObjType or if ObjType = "MfEnum.EnumItem" or ObjType = "EnumItem"; Otherwise false.
	Remarks
		If a string is used as the Type case is ignored so "MfObject" is the same as "mfobject"
*/
	Is(ObjType, IncludeEnumItem:=false) {
		_IncludeEnumItem := MfBool.GetValue(IncludeEnumItem, true)
		if (_IncludeEnumItem)
		{
			typeName := MfType.TypeOfName(ObjType)
			if ((typeName = "MfEnum.EnumItem") || (typeName = "EnumItem")) {
				return true
			}
		}
		return base.Is(ObjType)
	}
; End:Is() ;}
;{ Parse()
/*
	Method: Parse()
	
	OutputVar := MfEnum.Parse(enumType, value)
	OutputVar := MfEnum.Parse(enumType, value, ignoreCase)
	
	Parse(enumType, value)
		Converts the string representation of the name or numeric value of one or more enumerated constants to an equivalent enumerated object. Case is ignored for the value.
	
	Parse(enumType, value, ignoreCase)
		Converts the string representation of the name or numeric value of one or more enumerated constants to an equivalent enumerated object.
		The ignoreCase parameter specifies whether the operation is case-insensitive
	Parameters
		enumType
			An enumeration objects type as instance of MfType.
		value
			A string containing the name or value to convert. Can be var containing string or instance of MfString class.
		ignoreCase
			true to ignore case; false to regard case. Can be var containing boolean or instance of MfBool class.
	Returns
		Returns an object of type enumType whose value is represented by Value.
	Throws
		Throws MfArgumentNullException if enumType or value is null.
		Throws MfArgumentException if enumType is not type of MfEnum. -or- value is either an empty string ("") or
		only contains white space.-or- value is a name, but not one of the named constants defined for the enumeration.
	Remarks
		Static Method
*/
	Parse(enumType, value, ignoreCase = true) {
		enumResult := new MfEnum.EnumResult(true)
		if (MfEnum.TryParseEnum(enumType, value, ignoreCase, enumResult))
		{
			return enumResult.parsedEnum
		}
		throw enumResult.GetEnumParseException()
	}
; End:Parse() ;}
;{	ParseItem()
/*
	Method: ParseItem()
	
	OutputVar := MfEnum.ParseItem(enumType, value)
	OutputVar := MfEnum.ParseItem(enumType, value, ignoreCase)
	
	ParseItem(enumType, value)
		Converts the string representation of the name or numeric value of one enumerated constants to an equivalent MfEnum.EnumItem for
		the enumeration represented by enumType. Case is ignored for the value.
	
	ParseItem(enumType, value, ignoreCase)
		Converts the string representation of the name or numeric value of one enumerated constants to an equivalent MfEnum.EnumItem
		for the enumeration represented by enumType. ignoreCase parameter specifies if the operation is case-insensitive
	
	Parameters
		enumType
			An enumeration objects type as instance of MfType.
		value
			A string containing the name or value to convert. Can be var containing string or instance of MfString class.
		ignoreCase
			true to ignore case; false to regard case. Can be var containing boolean or instance of MfBool class.
	Returns
		Returns an MfEnum.EnumItem instance whose value is represented by value.
	Throws
		Throws MfArgumentNullException
		Throws MfArgumentException
*/
	ParseItem(enumType, value, ignoreCase = true) {
		enumResult := new MfEnum.EnumResult(true)
		_ignoreCase := MfBool.GetValue(ignoreCase, true)
		if (MfEnum._TryParseEnumItem(enumType, value, _ignoreCase, enumResult))
		{
			return enumResult.parsedEnum
		}
		throw enumResult.GetEnumParseException()
	
	}
; End:ParseItem() ;}
;{	RemoveFlag()
/*
	Method: RemoveFlag()

	RemoveFlag(flag)
		Removes a flag value from the current Value of MfEnum instance.
	Parameters
		flag
			The flag to add represented as var containing integer or an instance of MfEnum or MfEnum.EnumItem.
	Throws
		Throws MfNullReferenceException if derived MfEnum is not an instance.
		Throws MfNotSupportedException if derived MfEnum does not Implement MfFlagsAttribute class.
		Throws MfArgumentException if flag is incorrect type.
		Throws MfArgumentException if flag is null.
*/
	RemoveFlag(flag) {
		if (!this.IsInstance()) 
		{
			ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param",this.__Class))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!this.HasAttribute(MfFlagsAttribute)) 
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FlagsAttrib_Missing_Remove"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (IsObject(flag)) 
		{
			if (MfObject.IsObjInstance(flag, this.GetType())) 
			{
				_flag := flag.Value
			} else if (MfObject.IsObjInstance(flag, MfEnum.EnumItem)) {
				if (!flag.Type.Equals(this.GetType())) 
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_EnumTypeDoesNotMatch",this.GetType(),flag.Type))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				_flag := flag.Value
			} else {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_EnumTypeDoesNotMatch",this.GetType(),flag.GetType()))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else {
			if (Mfunc.IsInteger(flag))
			{
				_flag := flag
			}
			else
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName","flag"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			
		}
		
		if (this._HasFlag(_flag)) 
		{
			_Flags := this.Value
			_Flags := _Flags & ~_flag ; Remove Flag
			this.Value := _Flags
		}
		return Null
	}
;	End:RemoveFlag() ;}

;{ TryParse()
/*
	Method: TryParse()
	
	OutputVar := MfEnum.TryParse(value, outEnum)
	OutputVar := MfEnum.TryParse(value, outEnum, ignoreCase)
	
	TryParse(value, outEnum)
		Converts the string representation of the name or numeric value of one or more enumerated constants to an equivalent enumerated object.
		The return value indicates whether the conversion succeeded. This method is case-insensitive.
	
	TryParse(value, outEnum, ignoreCase)
		Converts the string representation of the name or numeric value of one or more enumerated constants to an equivalent enumerated object.
		A parameter specifies whether the operation is case-sensitive. The return value indicates whether the conversion succeeded.
	
	Parameters
		value
			The string representation of the enumeration name or underlying value to convert.
		outEnum
			When this method returns true, outEnum value contains the representation of value parameter.
			outEnum must be an instance of the derived MfEnum that is beign parsed.
		ignoreCase
			true to ignore case; false to consider case.
	Returns
		Returns true if the value parameter was converted successfully; otherwise, false.
	Remarks
		Static Method
*/
	TryParse(value, ByRef outEnum, ignoreCase = true) {
		
		if (MfNull.IsNull(outEnum)) {
			return false
		}
		if (!MfObject.IsObjInstance(outEnum, "MfEnum")) {
			return false
		}
		enumType := outEnum.GetType()
		enumResult := new MfEnum.EnumResult(false)
		outEnum.Value := 0
		retval := false
		if (MfEnum.TryParseEnum(enumType, value, ignoreCase, enumResult))
		{
			outEnum.Value := enumResult.parsedEnum.Value
			retval := true
		}
	return retval
	}
; End:TryParse() ;}
;{ 	TryParseItem
/*
	Method: TryParseItem()
	
	OutputVar := MfEnum.TryParseItem(enumType, value, outEnumItem)
	OutputVar := MfEnum.TryParseItem(enumType, value, outEnumItem, ignoreCase)
	
	MfEnum.TryParseItem(enumType, value, outEnumItem)
		Converts the string representation of the name or numeric value of one enumerated constants to an equivalent MfEnum.EnumItem
		for the enumeration represented by enumType. and assigne the value to outEnumItem. Case is ignored for the value.
	
	MfEnum.TryParseItem(enumType, value, outEnumItem, ignoreCase)
		Converts the string representation of the name or numeric value of one enumerated constants to an equivalent MfEnum.EnumItem
		for the enumeration represented by enumType. and assigne the value to outEnumItem. ignoreCase parameter specifies if the operation is case-insensitive.
	
	Parameters
		enumType
			An enumeration objects type as instance of MfType.
		value
			A string containing the name or value to convert. Can be var containing string or instance of MfString class.
		outEnumItem
			When this method returns true, outEnumItem contains the representation of value parameter as instance of MfEnum.EnumItem.
			outEnumItem is not required to be an instance of the MfEnum.EnumItem being parsed.
		ignoreCase
			true to ignore case; false to regard case. Can be var containing boolean or instance of MfBool class.
	Returns
	Returns an MfEnum.EnumItem instance whose value is represented by value.
	Throws
		Throws MfArgumentNullException
		Throws MfArgumentException
*/
	TryParseItem(enumType, value, ByRef outEnumItem, ignoreCase = true) {
		enumResult := new MfEnum.EnumResult(false)
		_ignoreCase := MfBool.GetValue(ignoreCase, true)
		retval := false
		if (MfEnum._TryParseEnumItem(enumType, value, _ignoreCase, enumResult))
		{
			outEnumItem := enumResult.parsedEnum
			retval := true
		}
		return retval
	}
; 	End:TryParseItem ;}
;{ _GetEnumItemByValue()
	; Gets the MfEnum.EnumItem matching the iValue integer
	_GetEnumItemByValue(EnumType, iValue)	{
		retval := Null
		try
		{
			inst := MfEnum._GetEnumInstance(EnumType)
			_iValue := MfInteger.GetValue(iValue)
			for k, v in inst
			{
				if (MfObject.IsObjInstance(v, MfEnum.EnumItem) = true && v.Value = _iValue)
				{
					retval := v
					break
				}
			}
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
			
		return retval
	}
; End:_GetEnumItemByValue() ;}
;{ _GetEnumItemCI()
	; Gets the MfEnum.EnumItem matching the string key. Case InSensetive
	_GetEnumItemCI(EnumType, strKey) {
		retval := Null
		try
		{
			_key := MfString.GetValue(strKey)
			inst := MfEnum._GetEnumInstance(EnumType)
			for k, v in inst
			{
				if (k = _key && MfObject.IsObjInstance(v, MfEnum.EnumItem) = true)
				{
					retval := v
					break
				}
			}
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
			
		return retval
	}
; End:_GetEnumItemCI() ;}
;{ _GetEnumItemCS()
	; Gets the MfEnum.EnumItem matching the string key. Case Sensetive
	_GetEnumItemCS(EnumType, strKey) {
		retval := Null
		try
		{
			inst := MfEnum._GetEnumInstance(EnumType)
			for k, v in inst
			{
				if (k == _key && MfObject.IsObjInstance(v, MfEnum.EnumItem) = true)
				{
					retval := v
					break
				}
			}
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
			_key := MfString.GetValue(strKey)
			
		return retval
	}
;{ _GetEnumItemCS()
;{ TryParseEnum()
/*
	Method: TryParseItem()
	
	OutputVar := MfEnum.TryParseItem(enumType, value, outEnumItem)
	OutputVar := MfEnum.TryParseItem(enumType, value, outEnumItem, ignoreCase)
	
	MfEnum.TryParseItem(enumType, value, outEnumItem)
		Converts the string representation of the name or numeric value of one enumerated constants to an equivalent
		MfEnum.EnumItem for the enumeration represented by enumType. and assigne the value to outEnumItem.
		Case is ignored for the value.
	
	MfEnum.TryParseItem(enumType, value, outEnumItem, ignoreCase)
		Converts the string representation of the name or numeric value of one enumerated constants to an equivalent
		MfEnum.EnumItem for the enumeration represented by enumType. and assigne the value to outEnumItem.
		ignoreCase parameter specifies if the operation is case-insensitive.
	
	Parameters
		enumType
			An enumeration objects type as instance of MfType.
		value
			A string containing the name or value to convert. Can be var containing string or instance of MfString class.
		outEnumItem
			When this method returns true, outEnumItem contains the representation of value parameter as instance of
			MfEnum.EnumItem. outEnumItem is not required to be an instance of the MfEnum.EnumItem being parsed.
		ignoreCase
			true to ignore case; false to regard case. Can be var containing boolean or instance of MfBool class.
	Returns
		Returns an MfEnum.EnumItem instance whose value is represented by value.
	Throws
		Throws MfArgumentNullException
		Throws MfArgumentException
*/
	TryParseEnum(enumType, value, ignoreCase, ByRef parseResult) { ; Type, String, Boolean, byRef MfEnum.EnumResult
		result := false
		if (MfNull.IsNull(enumType)) {
			ex := new MfArgumentNullException("enumType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			if (parseResult.canThrow)
			{
				throw ex
			}
			parseResult.SetFailure(ex)
			result := false
			return result
		}
		if (!MfObject.IsObjInstance(enumType, "MfType")) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_MustBeType"), "enumType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			if (parseResult.canThrow)
			{
				throw ex
			}
			parseResult.SetFailure(ex)
			result := false
			return result
		}
		if (!enumType.IsEnum) {
			;"Argument_IncorrectMfType", "EnumType"
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectMfType", "EnumType"), "enumType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			if (parseResult.canThrow)
			{
				throw ex
			}
			parseResult.SetFailure(ex)
			result := false
			return result
		}
		if (MfNull.IsNull(value))
		{
			parseResult.SetFailure(new MfEnum.ParseFailureKind(MfEnum.ParseFailureKind.Instance.ArgumentNull), "value")
			return false
		}
		_value := new MfString(value, true).Trim()
		;_value.ReturnAsObject := false
		
		if (_value.Length = 0)
		{
			parseResult.SetFailure(new MfEnum.ParseFailureKind(MfEnum.ParseFailureKind.Instance.Argument), "Arg_MustContainEnumInfo", Null)
			return false
		}
		c := _value.Index[0]
		iFlags := new MfInteger(0)
		
		; Value is expected to be a string but if is number parse and send back
		if (MfChar.IsDigit(c) || (c.CharCode = 45) ||  (c.CharCode = 43)) ; 45= '-' 43 = '+'
		{
			try
			{
				parseResult.parsedEnum := MfEnum.ToObject(enumType, _value.Value)
				result := true
				return result
			}
			catch e
			{
				if (parseResult.canThrow)
				{
					throw e
				}
				parseResult.SetFailure(e)
				result := false
				return result
			}
		}
		eInstance := Null
		try
		{
			eInstance := MfEnum._GetEnumInstance(enumType)
		}
		catch e
		{
			if (parseResult.canThrow)
			{
				throw e
			}
			parseResult.SetFailure(e)
			result := false
			return result
		}

		; flags are an issue with multiple instances.
		; I am thinking that if more than one item it being parsed then create a new instance of
		; the derived enum but in a special way. only add the keys requested by the enum;

		;HasFlags := eInstance.m_HasFlags


		varSplits := _value.Split(MfEnum.enumSeperatorChar)
		
		i := 0
		iSplits := varSplits.Count
		
		_ignoreCase := MfBool.GetValue(ignoreCase)
		if(_ignoreCase)
		{
			while i < iSplits
			{
				itmSplit := varSplits.Item[i].Trim()
				itm := eInstance._GetEnumItemCI(itmSplit.Value)
				if (!itm)
				{
					parseResult.SetFailureC(MfEnum.ParseFailureKind.Instance.ArgumentWithParameter, "Arg_EnumValueNotFound", itmSplit.Value)
					return false
				}
				iFlags.Value := iFlags.Value | itm.Value
				i++
			}
		}
		else
		{
			while i < iSplits
			{
				itmSplit := varSplits.Item[i].Trim()
				itm := eInstance._GetEnumItemCS(itmSplit.Value)
				if (!itm)
				{
					parseResult.SetFailureC(MfEnum.ParseFailureKind.Instance.ArgumentWithParameter, "Arg_EnumValueNotFound", itmSplit.Value)
					return false
				}
				iFlags.Value := iFlags.Value | itm.Value
				i++
			}
		}
		try
		{
			parseResult.parsedEnum := MfEnum.ToObject(enumType, iFlags)
			result := true
		}
		catch e
		{
			if (parseResult.canThrow)
			{
				throw e
			}
			parseResult.SetFailure(e)
			result := false
		}
		return result

		
	}
; End:TryParseEnum() ;}
;{ _TryParseEnumItem()
	_TryParseEnumItem(EnumType, value, ignoreCase, ByRef parseResult) { ; Type, String, Boolean, byRef MfEnum.EnumResult
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		result := false
		if (!MfObject.IsObjInstance(EnumType, MfType)) {
			parseResult.SetFailure(new MfEnum.ParseFailureKind(MfEnum.ParseFailureKind.Instance.ArgumentNull), "EnumType")
			return false
		}
		if (EnumType.IsEnum = False)
		{
			; msg := MfEnvironment.Instance.GetResourceString("Argument_IncorrectMfType", "EnumType")
			parseResult.SetFailure(new MfEnum.ParseFailureKind(MfEnum.ParseFailureKind.Instance.ArgumentWithParameter), "Argument_IncorrectMfType", "EnumType")
			return false
		}
		
		if (MfNull.IsNull(value))
		{
			parseResult.SetFailure(new MfEnum.ParseFailureKind(MfEnum.ParseFailureKind.Instance.ArgumentNull), "value")
			return false
		}

		_value := new MfString(value, true).Trim()
		;_value.ReturnAsObject := false
		
		if (_value.Length = 0)
		{
			parseResult.SetFailure(new MfEnum.ParseFailureKind(MfEnum.ParseFailureKind.Instance.Argument), "Arg_MustContainEnumInfo", Null)
			return false
		}
		

		; Value is expected to be a string but if is number parse and send back
		if (Mfunc.IsInteger(_value.Value))
		{
			try
			{

				parseResult.parsedEnum := MfEnum._GetEnumItemByValue(EnumType, _value.Value + 0)
				if(MfNull.IsNull(parseResult.parsedEnum))
				{
					parseResult.SetFailureC(MfEnum.ParseFailureKind.Instance.ArgumentWithParameter, "Arg_EnumValueNotFound", _value.Value)
					return false
				}
				result := true
				return result
			}
			catch e
			{
				if (parseResult.canThrow)
				{
					throw e
				}
				parseResult.SetFailure(e)
				result := false
				return result
			}
		}

		_ignoreCase := MfBool.GetValue(ignoreCase)
		retval := Null
		if(_ignoreCase)
		{
			parseResult.parsedEnum := MfEnum._GetEnumItemCI(EnumType, _value)
			if(MfNull.IsNull(parseResult.parsedEnum))
			{
				parseResult.SetFailureC(MfEnum.ParseFailureKind.Instance.ArgumentWithParameter, "Arg_EnumValueNotFound", _value.Value)
				return false
			}
			result := true
			return result
		}
		else
		{
			parseResult.parsedEnum := MfEnum._GetEnumItemCS(EnumType, _value)
			if(MfNull.IsNull(parseResult.parsedEnum))
			{
				parseResult.SetFailureC(MfEnum.ParseFailureKind.Instance.ArgumentWithParameter, "Arg_EnumValueNotFound", _value.Value)
				return false
			}
			result := true
			return result
		}
	}
; End:_TryParseEnumItem() ;}
;{ _GetEnumInstance()
	/*
		Method: _GetEnumInstance(enumType)
			_GetEnumInstance(enumType) Gets Enum Instance From the enumType
		Parameters:
			enumType - The MfType representation of the enumeration type
		Returns:
			Returns The Instance of the derived enum
		Throws:
			Throws MfArgumentNullException  
			Throws MfArgumentException enumType is not a valid MfType  
			Throws MfInvalidCastException Conversion of the type did not succeed 
	*/
	_GetEnumInstance(enumType) {
		if (MfNull.IsNull(enumType))
		{
			ex := new MfArgumentNullException("enumType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfObject.IsObjInstance(enumType,"MfType")) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_TypeInstanceExpected", "enumType"), "enumType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (EnumType.IsEnum = False)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectMfType", "enumType"), "enumType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		strClass := enumType.ClassName
		parentObj := Null
		if(strClass ~= "[.]+")
		{
			; looks like we have nested classes
			StringSplit, outArray, strClass, .
			if(outArray0)
			{
				parentObj := %outArray1%
			}
			Loop, %outArray0%
			{
				if(a_index > 1)
				{
					partname :=  outArray%a_index%
					if(parentObj.HasKey(partname))
					{
						parentObj := parentObj[partname]
					}
					else
					{
						break
					}
				}
			}
		}
		else
		{
			parentObj := %strClass%
		}
		inst := parentObj.Instance
		if (MfNull.IsNull(inst) = true || inst.GetType().IsEnum = false)
		{
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_Enum_Parse", strClass))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return inst
	}
; End:_GetEnumInstance() ;}
;{ GetEnumValuesAndNames()
	; internal method
	GetEnumValuesAndNames(enumType, ByRef Values, ByRef Names, getValues = true, getNames = true) {
		bValues := MfBool.GetValue(getValues)
		bNames := MfBool.GetValue(getNames)
		bResult := true
		bResult := bResult & bValues
		bResult := bResult & bNames
		if (!bResult) {
			return
		}
		if (MfNull.IsNull(enumType))
		{
			ex := new MfArgumentNullException("enumType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfObject.IsObjInstance(enumType,"MfType")) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_TypeInstanceExpected", "enumType"), "enumType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!enumType.IsEnum) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_MustBeEnum"), "enumType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (bValues) {
			if (!MfObject.IsObjInstance(Values, MfGenericList)) {
				eMsg := MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "Values","MfGenericList")
				ex := new MfArgumentException(eMsg, "Values")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!Values.ListType.IsInteger) {
				eMsg := MfEnvironment.Instance.GetResourceString("Argument_GenericListType", "MfInteger")
				ex := new MfArgumentException(eMsg,"Values")
				throw ex
			}
		}
		if (bNames) {
			if (!MfObject.IsObjInstance(Names, MfGenericList)) {
				eMsg := MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "Names","MfGenericList")
				ex := new MfArgumentException(eMsg, "Names")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!Names.ListType.IsString) {
				eMsg := MfEnvironment.Instance.GetResourceString("Argument_GenericListType", "MfString")
				ex := new MfArgumentException(eMsg,"Names")
				throw ex
			}
		}

		vEnum := MfEnum._GetEnumInstance(enumType)
		
		if (bValues) {
			varValues := vEnum.GetValues()
			iCount := varValues.Count
			i := 0
			Loop, %iCount%
			{
				Values.Add(varValues.Item[i])
				i++
			}
		}
		if (bNames) {
			varNames := vEnum.GetNames()
			iCount := varNames.Count
			i := 0
			Loop, %iCount%
			{
				Names.Add(varNames.Item[i])
				i++
			}
		}
	}
; End:GetEnumValuesAndNames() ;}
;{ ToObject()
/*
	Method: ToObject()
	
	OutputVar := MfEnum.ToObject()
	
	ToObject(enumType, value)
		Converts the specified Integer to an enumeration member.
		Static Method
	Parameters
		enumType
			The enumeration type to return. Must be instance of MfType class.
		value
			The value to convert to an enumeration member. Can be var containing integer or instance of MfInteger class.
	Returns
		Returns an instance of the enumeration set to value
	Remarks
		If enumType does not Have Attribute of MfFlagsAttribute then value must match the value an Enumeration or MfArgumentException will be thrown
	Throws
		Throws MfArgumentNullException if enumType or value is null.
		Throws MfArgumentException if enumType is not type of MfEnum.
*/
	ToObject(enumType, value) {
		if (MfNull.IsNull(enumType))
		{
			ex := new MfArgumentNullException("enumType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(value))
		{
			ex := new MfArgumentNullException("value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfObject.IsObjInstance(enumType,"MfType"))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_TypeInstanceExpected", "enumType"), "enumType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!enumType.IsEnum)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_MustBeEnum"), "enumType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		intValue := MfInteger.GetValue(value)
		parentObj := MfEnum._GetEnumInstance(enumType)
				
		obj := parentObj.MemberwiseClone()
		
		; set up flags to check and see if the emum allows flags
		; if flags are not allowed then intValue must match one of the
		; EnumItem values.
		bFlagged := false
		FoundValue := false
		if (parentObj.HasAttribute(MfFlagsAttribute.Instance))
		{
			bFlagged := true
			FoundValue := true
		}
		

		; set the parent object of the enum items
		for k, v in obj
		{
			if (MfObject.IsObjInstance(v, MfEnum.EnumItem) = true)
			{
				v.m_Parent := obj
				if ((FoundValue = false) && (v.Value = intValue))
				{
					FoundValue := true
				}
			}
		}
		if ((bflagged = false) && (FoundValue = false))
		{
			err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_EnumIllegalVal", intValue))
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		obj.Value := intValue
		return obj
	}
; End:ToObject() ;}
;{ 	ToString()						- Overrides	- MfObject
/*
	Method: ToString()
	
	Overrides MfObject.ToString
	OutputVar := instance.ToString()

	ToString()
		Gets a string representation of the object.
	Returns
		Returns var string value representing name(s) of the corresponding the name of the the current Value.
	Throws
		Throws MfNullReferenceException if method is called on a non-instance.
	Remarks
		If MfEnum has MfFlagsAttribute as one of it attributes then ToString() will return one or more names separated by comma.
		One for each flag that is set. Otherwise there will always be only one name in the return string.
*/
	ToString() {
		if (!this.IsInstance()) {
			ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param",this.__Class))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		HasFlags := this.__HasFlagsAttribute
		Names := new MfList()
		for k, v in this
		{
			if (MfObject.IsObjInstance(v, MfEnum.EnumItem)) {
				if (HasFlags = true)
				{
					if (this.HasFlag(v))
					{
						if(v.Value >= 0)
						{
							Names.Add(new MfString(v.Name))
						}
						else
						{
							Names.Add(new MfString("-" . v.Name))
						}
					}
				}
				else
				{
					if(v.Value = this.Value)
					{
						if(v.Value >= 0)
						{
							Names.Add(new MfString(v.Name))
						}
						else
						{
							Names.Add(new MfString("-" . v.Name))
						}
						break
					}
				}
				
			}
		}
		retval := ""
		if (Names.Count = 1)
		{
			retval := Names.Item[0].Value
		}
		else 
		{
			for i, n in Names
			{
				
				retval .= n.Value
				if ((i + 1) < Names.Count)
				{
					retval .= MfEnum.enumSeperatorChar
				}
			}
		}
		
		return retval
	}
;  End:ToString() ;}
; End:Methods ;}
;{ Nested Classes

;{ Class EnumItem
	/*!
		Class: EnumItem
			Provides MfEnum items for [MfEnum](MfEnum.html) classes
			This class is sealed and can not be extended.
		Inherits: MfObject
	*/
	class EnumItem extends MfObject
	{
;{ Internal members
		m_Name	:= Null
		m_Value	:= Null
		m_Type	:= Null
		m_Parent := Null
; End:Internal members ;}
	;{ Constructor: ()
		/*!
			Constructor: ()
				Constructor for class MfEnum.EnumItem Class
				MfEnum.EnumItem is intended to be an internally constructed class and therefore is not intended
				to be a public constructor
			Throws:
				Throws MfNotSupportedException if class is inherited or extended.  
				Throws MfArgumentNullException any parameter argument is null.  
				Throws MfArgumentException if parameter arguments are not correct type.
			Remarks
				Private Constructor
		*/
		__New(name, value, byref type, byref pEnum) {
			if (this.__Class != "MfEnum.EnumItem") {
				throw new MfNotSupportedException(MfString.Format(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class"), "MfEnum.EnumItem"))
			}
			base.__New()
			if (MfString.IsNullOrEmpty(name)) {
				ex := new MfArgumentNullException("name",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","name"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (MfString.IsNullOrEmpty(value)) {
				ex := new MfArgumentNullException("value",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","value"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!MfObject.IsObjInstance(type,"MfType")) {
				ex := new MfArgumentNullException("type",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","type"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!(name ~= "^[a-zA-Z0-9_]+$")) {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_StringVar","name"),"name")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!Mfunc.IsInteger(value)) {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IntegerVar","value"),"value")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.m_Name := name
			this.m_Value := value
			this.m_Type := type
			if !IsObject(pEnum)
				return
			this.m_Parent := pEnum
			; ObjAddRef(this.m_Parent)
		}
	; End:Constructor: () ;}
	;{ Method
	;{ 	CompareTo()						- Overrides	- MfObject
/*!
		Method: CompareTo()
			Overrides MfObject.CompareTo.
		
		OutputVar := MfEnum.Instance.EnumItem.CompareTo(obj)
		
		CompareTo(obj)
			Compares the current instance with another object of the same type and returns an Integer that indicates whether
			the current instance precedes, follows, or occurs in the same position in the sort order as the other object.
			This method can be overriden in derived classes.
		Parameters
			obj
				An MfEnum or MfEnum.EnumItem object to compare with this instance.
		Returns
			Returns A value that indicates the relative order of the objects being compared.
			The return value has these meanings: Value Meaning Less than zero This instance precedes obj in the sort order.
			Zero This instance occurs in the same position in the sort order as obj Greater than zero This instance follows
			obj in the sort order.
		Throws
			Throws MfArgumentException is not the same type as this instance.
			Throws MfArgumentNullException if obj is null.
			Throws MfNullReferenceException if instance is null.
*/
		CompareTo(obj) {
			if (!this.IsInstance()) {
				ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param",this.__Class))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (MfNull.IsNull(obj)) {
				ex := new MfArgumentNullException("obj",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!MfObject.IsObjInstance(obj)) {
				ex := new MfArgumentNullException("obj",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if ((!MfObject.IsObjInstance(obj, "MfEnum")) && (!MfObject.IsObjInstance(obj, "MfEnum.EnumItem"))) {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_TypeInstanceDoesNotMatch",obj.GetType(),this.GetType()),"obj")
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
	; End:CompareTo() ;}
	;{ 	Equals()						- Overrides	- MfObject
/*
		Method: Equals()
			Compares MfEnum.EnumItem or MfEnum objects to see if they are the same value.
			Overrides MfObject.Equals.
		
		OutputVar := MfEnum.EnumItem.Equals(objA, ObjB)
		OutputVar := MfEnum.Instance.EnumItem.Equals(objA)
		
		Equals(objA)
			Compares objA against current MfEnum.EnumItem instance to see if they have the same value.
		Returns
			Returns var containing Boolean value of true if the MfEnum.EnumItem.Value or MfEnum.Value are the same as this
			instance Value otherwise false.
		
		Equals(objA, ObjB)
			Compares objA against objB to see if they have the same value.
			Static method
		Returns
			Returns var containing Boolean value of true if the MfEnum.EnumItem.Value or MfEnum.Value instances
			have the samve Value otherwise false.
		
		Parameters
			objA
				The first MfEnum.EnumItem or MfEnum derived instance to compare.
			objB
				The second MfEnum.EnumItem or MfEnum derived instance to compare.
		Throws
			Throws MfArgumentNullException if objA is null.
			Throws MfNullReferenceException if Non-Static [Equals(objA)] method is called when insance as not be created
			Throws MfArgumentException if objA or objB are not type of MfEnum.EnumItem or MfEnum.
		Remarks
			In most cases it would likely be more practical to use MfEnum.Equals() than this method.
*/
		Equals(objA, objB = "")	{
			if (MfNull.IsNull(objA)) {
				ex := new MfArgumentNullException("objA",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","objA"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			; Allow combaring of MfEnum to MfEnum.EnumItem as well
			; throw an error if objA is not enum or enumitem
			if ((!MfObject.IsObjInstance(objA, "MfEnum")) && (!MfObject.IsObjInstance(objA, "MfEnum.EnumItem"))) {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_TypeInstanceDoesNotMatch",objA.GetType(),this.GetType()),"objA")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}

			if (MfNull.IsNull(ObjB)) {
				if (!this.IsInstance()) { ; this class must be an instance if objB is absent.
					ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param",this.__Class))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				x := this
				y := ObjA
			} else {
				; objA must be MfEnum or MfEnum.EnumItem at this point.
				; Lets make certain that objB is MfEnum or MfEnum.EnumItem
				if ((!MfObject.IsObjInstance(objB, "MfEnum")) && (!MfObject.IsObjInstance(objB, "MfEnum.EnumItem")))
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_TypeInstanceEitherOr","MfEnum", "MfEnum.EnumItem"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				x := ObjA
				y := ObjB
			}
			return x.Value = y.Value
		}
	; End:Equals() ;}
	;{	GetHashCode()					- Overrides	- MfObject
/*
		Method:GetHashCode()
			Overrides MfObject.GetHashCode()
		
		OutputVar := instance.GetHashCode()
		
		GetHashCode()
			Gets A hash code for the current MfEnum.EnumItem.
		Returns
			Returns A hash code for the current MfEnum.EnumItem.
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
			if (!this.IsInstance()) {
				ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param",this.__Class))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			mfStr := new MfString(this.Name)
			mfStr.Append(this.Value)
			return mfStr.GetHashCode()
		}
	; End:GetHashCode() ;}
	;{ 	GetTypeCode()
/*
	Method: GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfEnum.EmumItem Type Code.
	Returns
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfEnum.EmumItem.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.EmumItem
	}
; End:GetTypeCode() ;}
;{ 	Is()				- Overrides - MfPrimitive
/*
	Method: Is()
	Overrides MfObject.Is()
	
		OutputVar := instance.Is(ObjType)

	Is(ObjType)
		Gets if current instance of MfEnum.EnumItem is of the same type as ObjType or derived from ObjType.
	Parameters
		ObjType
			The object or type to compare to this instance Type.
			ObjType can be an instance of MfType or an object derived from MfObject or an instance of or a string containing
			the name of the object type such as "MfObject"
	Returns
		Returns true if current object instance is of the same Type as the ObjType or if current instance is derived
		from ObjType or if ObjType = "MfEnum.EnumItem" or ObjType = "EnumItem"; Otherwise false.
	Remarks
		If a string is used as the Type case is ignored so "MfObject" is the same as "mfobject"
*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if ((typeName = "MfEnum.EnumItem") || (typeName = "EnumItem")) {
			return true
		}
		return base.Is(typeName)
	}
; End:Is() ;}
	;{ 	ToString()						- Overrides	- MfObject
/*!
		Method: ToString()
			Overrides MfObject.ToString.

		OutputVar := MfEnum.Instance.EnumItem.ToString()

		ToString()
			Gets a string representing the Name of the enum item.
		Returns
			Returns string value representing current instance
*/
		ToString() {
			return this.Name
		}
	;	End:ToString() ;}
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
;{		ParentEnum
		/*!
			Property: Name [get]
				Gets MfEnum derived enumeration that is the parent of MfEnum.EnumItem instance.
			Remarks:
				Read-only Property.  
				When a Class extends MfEnum this property will be a reference to that extended class when it is an instance.  
				ParentEnum is a reference to the Parent. Any changes to ParentEnum will be reflected to all instances of
				ParentEnum as well to the actual MfEnum derived enumeration that is the parent of this instance.				
		*/
		ParentEnum[]
		{
			get {
				return this.m_Parent
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				Throw ex
			}
		}
;		End:ParentEnum ;}
;{		Name
		/*!
			Property: Name [get]
				Gets the Name associated with the instance of MfEnum.EnumItem in Enumerations derived from MfEnum.
			Remarks:
				Readonly Property.
		*/
		Name[]
		{
			get {
				return this.m_Name
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				Throw ex
			}
		}
;		End:Name ;}
;{		Type
		/*!
			Property: Type [get]
				Gets the MfType for the MfEnum class instance associated with the MfEnum.EnumItem class.
			Remarks:
				Readonly Property.
		*/
		Type[]
		{
			get {
				return this.m_Type
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				Throw ex
			}
		}
;		End:Type ;}
;{		Value
		/*!
			Property: Value [get]
				Gets the value associated with the MfEnum.EnumItem class.
			Remarks:
				Readonly Property.
		*/
		Value[]
		{
			get {
				return this.m_Value
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				Throw ex
			}
		}
;		End:Value ;}
	; End:Properties ;}	
	}
	/*!
		End of class
	*/
; End:Class EnumItem ;}
;{ Class ParseFailureKind
	;{ Class comments
	/*
		Class: ParseFailureKind
			Class Description
			ParseFailureKind is an [MfEnum](MfEnum.html) sytle class.  
			ParseFailureKind is a Sealed Class and cannot be inherited.
		Inherits
			MfEnum
		Remarks
			Internal Class
	*/
	; End:Class comments ;}
	class ParseFailureKind extends MfEnum
	{
		static m_Instance := ""
	;{ Constructor
		/*
			Constructor: (value)
				Constructs new instance of ParseFailureKind object.
			Throws:
				Throws MfNotSupportedException if this Sealed class is inherited.
		*/
		__New(value = 0) {
			if (this.__Class != "MfEnum.ParseFailureKind") {
				throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfEnum.ParseFailureKind"))
			}
			base.__New(value)
		}
	; End:Constructor ;}
	;{ MfEnum members
		/*
			Property: None [get]
				Name Description
			Remarks:
				Read-only Property.
		*/
	; End:MfEnum members ;}
	;{ Methods
	;{ 	AddEnums()
		/*
			Method: AddEnums()
				AddEnums() Processes adding of new MfEnum values to derived class.  
				Overrides MfEnum.AddEnums.
			Remarks:
				This method is call by base class and does not need to be call manually.
		*/
		AddEnums() {
			this.AddEnumValue("None", 0)
			this.AddEnumValue("Argument", 1)
			this.AddEnumValue("ArgumentNull", 2)
			this.AddEnumValue("ArgumentWithParameter", 3)
			this.AddEnumValue("UnhandledException", 4)
			
			
		}
	; 	End:AddEnums() ;}
	;{	DestroyInstance()
		/*
			Method: DestroyInstance()
				DestroyInstance() Destroys the singleton instance of ParseFailureKind.  
				Overrides [MfEnum.DestroyInstance](MfEnum.destroyinstance.html).
		*/
		DestroyInstance() {
			ParseFailureKind.m_Instance := Null
		}
	; End:DestroyInstance() ;}

	;{ 	GetInstance()
		/*
			Method: GetInstance()
				GetInstance() Gets the instance for the ParseFailureKind class.  
				Overrides MfEnum.GetInstance.
			Remarks:
				ParseFailureKind.DestroyInstance can be called to destroy instance.
			Returns:
				Returns Singleton instance for ParseFailureKind class.
		*/
		GetInstance() {
			if (MfEnum.ParseFailureKind.m_Instance = Null) {
				MfEnum.ParseFailureKind.m_Instance := new MfEnum.ParseFailureKind()
			}
			return MfEnum.ParseFailureKind.m_Instance
		}
	; End:GetInstance() ;}
	; End:Methods ;}
	}
	/*
		End of class
	*/
; End:Class ParseFailureKind ;}
;{ class EnumResult
	/*
		Class: EnumResult
			Provides Property implementation for derived classes.
			This class in intended as a base class only an is **not** to be
			used on it own.  
			Abstract Class		
		Inherits:
			MfObject
		Remarks
			Internal Class
	*/
	class EnumResult extends MfObject
	{
		parsedEnum			:= Null		; Object
		canThrow			:= false	; boolean
		m_failure			:= Null		; MfEnum.ParseFailureKind
		m_failureMessageID	:= Null		; String
		m_innerException	:= Null		; Exception
		
	;{ Constructor: ()
		/*
			Constructor: ()
				Constructor for class MfEnum.EnumResult Class
			Throws:
				Throws MfNotSupportedException if this Sealed class is inherited.
		*/
		__New(canMethodThrow) {
			if (this.__Class != "MfEnum.EnumResult") {
					throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfEnum.EnumResult"))
				}
			base.__New()
			m_failure := new MfEnum.ParseFailureKind(0)
			this.parsedEnum := 0
			this.canThrow := canMethodThrow
		}
	; End:Constructor: () ;}
	;{ Method
	;{ GetEnumParseException()
	GetEnumParseException()	{
		if (this.m_failure.Value = MfEnum.ParseFailureKind.Instance.Argument.Value) {
			return new MfArgumentException(MfEnvironment.Instance.GetResourceString(this.m_failureMessageID))
		} else if (this.m_failure.Value = MfEnum.ParseFailureKind.Instance.ArgumentNull.Value) {
			return new MfArgumentNullException(this.m_failureParameter)
		} else if (this.m_failure.Value = MfEnum.ParseFailureKind.Instance.ArgumentWithParameter.Value) {
			return new MfArgumentException(MfEnvironment.Instance.GetResourceString(this.m_failureMessageID, this.m_failureMessageFormatArgument))
		} else if (this.m_failure.Value = MfEnum.ParseFailureKind.Instance.UnhandledException.Value) {
			return this.m_innerException
		} else {
			return new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_EnumValueNotFound"))
		}
		
	}
; 	End:GetEnumParseException() ;}
		SetFailure(argA, argB = "_empty", argC = "_empty") {
		i := 1
		if (argB != "_empty") {
			i++
		}
		if (argC != "_empty") {
			i++
		}

		if (i = 1) {
			this.SetFailureA(argA)
		} else if (i = 2) {
			this.SetFailureB(argA, argB)
		} else if (i = 3) {
			this.SetFailureC(argA, argB, argC)
		}
	}
	SetFailureA(unhandledException) {
		this.m_failure := new  MfEnum.ParseFailureKind(MfEnum.ParseFailureKind.Instance.UnhandledException)
		this.m_innerException := unhandledException
	}
	SetFailureB(failure, failureParameter) {
		this.m_failure := failure
		this.m_failureParameter := failureParameter
		if (this.canThrow)
		{
			throw this.GetEnumParseException()
		}
	}
	SetFailureC(failure, failureMessageID, failureMessageFormatArgument) { ; MfEnum.ParseFailureKind , string, object
		this.m_failure := failure
		this.m_failureMessageID := failureMessageID
		this.m_failureMessageFormatArgument := failureMessageFormatArgument
		if (this.canThrow)
		{
			throw this.GetEnumParseException()
		}
	}
; End:Method ;}
	}
	/*
		End of class
	*/
; End:class EnumResult ;}

; End:Nested Classes ;}
;{ Properties
;{	Instance
;{ 	Start:Instance Property Comment
/*
	Property: Instance [get]
		Gets the Singleton instance of the class.
	Remarks:
		Readonly property.
		MfEnum derived class such as MfDigitShapes are base on a singleton pattern.
		MfEnum is an abstract class and Instance can only be called on derived classes.
		Derived classes must override the GetInstance method.
*/
; 	End:Instance Property Comment ;}
	Instance[]
	{
		get {
			return this.GetInstance()
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:Instance ;}
;{	MaxValue
;{ 	Start:MaxValue Property Comment
/*
	Property: MaxValue [get]
		Gets a var value representing the Maximum value of all the EnumItem instances
		in an MfEnum instance as a var containing integer
	Remarks:
		Readonly property.
*/
; 	End:MaxValue Property Comment ;}
	MaxValue[]
	{
		get {
			if (MfNull.IsNull(this.m_MaxValue)) {
				_max := MfInteger.MinValue
				for k, v in this
				{
					if (MfObject.IsObjInstance(v, MfEnum.EnumItem)) {
						if (v.Value > _max) {
							_max := v.Value
						}
					}
				}
				this.m_MaxValue := _max
			}
			return this.m_MaxValue
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:MaxValue ;}
;{	Value
	/*!
		Property: Value [get/set]
			Gets or sets the value associated with the derived MfEnum class.
		Value:
			Integer var or object representing integer.
			Can be any object that matches type MfType.IsIntegerNumber.
		Gets:
			Gets an Integer var that represents then current Value.
		Sets:
			Sets the Value of the derived MfEnum class
			Can be var containing intege or any object that matches type MfType.IsIntegerNumber
		Returns:
			When property is set the new Value is returned.
		Remarks:
			In derived classes this propery gets the value associated with the instance.
	*/
	Value[]
	{
		get {
			return this.m_Value
		}
		set {
			try
			{
				this.m_Value := MfInt64.GetValue(value)
			}
			catch e
			{
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				Throw ex
			}
			return  this.m_Value
		}
	}
;	End:Value ;}
;{ __HasFlagsAttribute
	_hasFlagsAttributeValue := -1
	; gets if the current MfEnum has a MfFlagsAttribute
	__HasFlagsAttribute[]
	{
		get 
		{
			if(this._hasFlagsAttributeValue = -1)
			{
				classAttrib := this.GetAttributes()
				this._hasFlagsAttributeValue := 0
				for i, attrib in classAttrib
				{
					if (attrib.Is(MfFlagsAttribute))
					{
						this._hasFlagsAttributeValue := 1
						break
					}
				}
			}
			return (this._hasFlagsAttributeValue = 1)
		}
		set
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:__HasFlagsAttribute ;}
; End:Properties ;}
}
/*!
	End of class
*/
; End:Class MfEnum ;}