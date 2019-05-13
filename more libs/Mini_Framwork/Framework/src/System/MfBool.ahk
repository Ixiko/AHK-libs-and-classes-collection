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
	Class: MfBool
		Represents MfBool object for handling true and false values.
	Inherits: MfPrimitive
*/
; End:Class Comments ;}
Class MfBool extends MfPrimitive
{
;{ Static Members
;{ 	True
	Static m_True 	:= 1
	/*!
		Property: True [get]
			Gets a value representing True
		Remarks:
			Static Readonly value
	*/
	True[]
	{
		get {
			return MfBool.m_True
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; 	End:True ;}
;{ 	False
	Static m_False 	:= 0
	/*!
		Property: False [get]
			Gets a value representing False
		Remarks:
			Static Readonly value
	*/
	False[]
	{
		get {
			return MfBool.m_False
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; 	End:False ;}
;{ 	TypeCode
	;m_TypeCode		:= Null
	TypeCode[]
	{
		get {
			return 17
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; 	End:TypeCode ;}
;{ 	TrueString
	static m_TrueString := "True"
	/*!
		Property: TrueString [get]
			Represents the Boolean value true as a string. This field is static and read-only.
	*/
	TrueString[]
	{
		get {
			return MfBool.m_TrueString
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; 	End:TrueString ;}
;{ 	FalseString
	Static m_FalseString := "False"
	/*!
		Property: FalseString [get]
			Represents the Boolean value false as a string. This field is static and read-only
	*/
	FalseString[]
	{
		get {
			return MfBool.m_FalseString
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; 	End:FalseString ;}
;{ 	TrueObj
	/*!
		Property: TrueObj [get]
			Gets a new instance MfBool set to True State
		Value:
			Instance of MfBool.
		Remarks:
			Readonly Property
			ReturnAsObject is Set to False
			Readonly is Set to False
	*/
	TrueObj[]
	{
		get {
			return new MfBool(MfBool.True)
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:TrueObj ;}
;{ 	FalseObj
/*
		Property: TrueObj [get]
			Gets a new instance MfBool set to False State
		Value:
			Instance of MfBool.
		Remarks:
			Readonly Property
			ReturnAsObject is Set to False
			Readonly is Set to False
*/
	FalseObj[]
	{
		get {
			return new MfBool(MfBool.False)
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; 	End:FalseObj ;}
; End:Static Members ;}
;{ Constructor
/*
	Constructor()
	Initializes a new instance of the MfBool class.

	OutputVar := new MfBool([val, returnAsObj, readonly])

	Constructor([val, retunAsObj, readonly])
		Initializes a new instance of the MfBool class optionally setting the Value property, ReturnAsObject property and Readonly Property.
	Parameters
		val
			The booolean value to create a new instance with. Represents true or false.
			If omitted value is false.
		returnAsObj
			Determines if the current instance of MfBool class will return MfBool instances from functions or vars containing boolean.
			If omitted value is false.
		readonly
			Determines if the current instance of mfbool class will allow its Value to be altered after it is constructed.
			The Readonly propery will reflect this value after the classe is constructed.
			If omitted value is false
	Remarks
		Sealed Class
		This constructor initializes the MfBool.
		Value property to the value of val parameter.
		ReturnAsObject property will have a value of returnAsObj
		Readonly property will have a value of readonly
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
		; boolean = false, returnAsObj = false, readonly
		; Throws MfNotSupportedException if MfBool Sealed class is extended
		if (this.__Class != "MfBool") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfBool"))
		}
		_b := false
		_returnAsObject := false
		_readonly := false

		pArgs := this._ConstructorParams(A_ThisFunc, args*)

		pList := pArgs.ToStringList()
		s := Null
		if (pList.Count > 0)
		{
			s := pList.Item[0].Value
			if ((s = "MfBool") || (s = "MfInteger") || (s = "MfInt64"))
			{
				_b := (pArgs.Item[0].Value > 0)
			}

		}
		if (pList.Count > 1)
		{
			s := pList.Item[1].Value
			if (s = "MfBool")
			{
				_returnAsObject := pArgs.Item[1].Value
			}
		}
		if (pList.Count > 2)
		{
			s := pList.Item[2].Value
			if (s = "MfBool")
			{
				_readonly := pArgs.Item[2].Value
			}
		}
		
		base.__New(_b, _returnAsObject, _readonly)
		this.m_isInherited := this.__Class != "MfBool"
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
						p.Add(arg)
					} 
					else
					{
						if (MfNull.IsNull(arg))
						{
							pIndex := p.Add(arg)
						}
						else ; all params past 1 are boolean
						{
							; do not create an instance of MfBool here with parameters
							; this will cause recursion. Instead create an instance and
							; set its properties
							bObj := new MfBool()
							bObj.Value := (arg > 0)
							pIndex := p.Add(bObj)
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
;{ Method
;{ 	CompareTo()			- Overrides	- MfObject
/*
		Method: CompareTo(obj)
			Compares this instance to a specified MfBool object.
			Overrides MfObject.CompareTo
		Parameters:
			obj
				A MfBool object to compare.
		Returns:
			Returns A number indicating the position of this instance in the sort order in relation to the value parameter.
			Return Value Description Less than zero This instance precedes obj value. Zero This instance has the same
			position in the sort order as value. Greater than zero This instance follows
		Remarks:
			Compares this instance to a specified MfBool object and indicates whether this instance precedes, follows,
			or appears in the same position in the sort order as the specified MfBool object.
		Throws
			Throws MfNullReferenceException if called as a static method.
			Throws MfArgumentException if obj is not instance of MfBool.
*/
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!MfObject.IsObjInstance(obj, MfBool)) {
			err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_TypeInstanceDoesNotMatch"
			, "obj","MfBool"),"obj")
			err.Source := A_ThisFunc
			throw err
		}
		if(this.Equals(obj)) {
			return 0
		}
		if (this.Value = obj.Value) {
			return 0
		}
		if (this.Value = true) {
			return 1
		}
		return -1
	}
; End:CompareTo(obj) ;}	
;{ 	Equals()			- Overrides	- MfPrimitive
	/*
	Method:Equals()
		Overrides MfObject.Equals()
	
	OutputVar := instance.Equals(value)
	
	Equals(value)
		Gets if this instance Value is the same as the value
	Parameters
		value
			The Object or var containing, boolean
			Can be any object of the matches type IsNumber, MfString or MfChar.
	Returns
		Returns Boolean value of true if this Value and value are equal; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method
	Remarks
		If value is unable to be converted to a boolean then false will be returned.

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
			_value :=  MfBool.GetValue(value)
			retval := this.Value = _value
		}
		catch 
		{
			retval := false
		}
		return retval
	}
; End:Equals(c) ;}	
;{	GetHashCode()		- Inhertis	- MfObject
/*!
	Method:GetHashCode()
		Overrides MfObject.GetHashCode()
	
	OutputVar := instance.GetHashCode()
	
	GetHashCode()
		Gets A hash code for the current MfBool.
	Returns
		Returns A hash code for the current MfBool.
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
		if (this.Value >= MfBool.True) {
			return MfBool.True
		}
		return MfBool.False
	}
; End:GetHashCode() ;}
;{ 	GetTypeCode()
/*
	Method: GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfBool Type Code.
	Returns
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfBool.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.Boolean
	}
; End:GetTypeCode() ;}
;{ 	GetValue()			- Overrides - MfPrimitive
/*!
	Method: GetValue()
		Overrides MfPrimitive.GetValue()

	OutputVar := MfBool.GetValue(obj)
	OutputVar := MfBool.GetValue(obj, Default)
	OutputVar := MfBool.GetValue(Obj, Default, AllowAny)

	MfBool.GetValue(Obj)
		Gets the boolean number from Object or var containing boolean.
	Parameters
		Obj
		The Object or var containing, boolean
		Can be any object of the matches type IsNumber, MfString or MfChar.
	Returns
		Returns a var containing a boolean True or False.
	Remarks
		Static Method
		Throws an error if unable to convert Obj to boolean.
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentException if argument Obj is can not be converted to byte value.
		Throws MfException for all other errors.

	MfByte.GetValue(Obj, Default)
		Gets a boolean number from Obj or returns Default value if Obj is unable to be converted to boolean. Default must be a value that can be converted to boolean or it will be ignored if Obj can not be converted to boolean and an error will be thrown.
	Parameters
		Obj
			The Object or var containing, boolean
			Can be any object of the matches type IsNumber, MfString or MfChar.
		Default
			The boolean value to return if Obj is Cannot be converted to boolean.
	Returns
		Returns a var containing a boolean or Default value if Obj is unable to be converted to boolean.
	Remarks
		Static Method
		If Default is not a valid boolean or MfBool instance then GetValue will throw an error if Obj can not be converted to boolean. 
		If Default can not be converted to a boolean then this would method will yield the same results as calling MfBool.GetValue(Obj).
	Throws
		Throws MfInvalidOperationException if not called as a static method.

	MfByte.GetValue(Obj, Default, AllowAny)
		Gets a boolean value from Obj or returns Default value if Obj is unable to be converted to boolean.
	Parameters
		Obj
			The Object or var containing, boolean
			Can be any object of the matches type IsNumber, MfString or MfChar.
		Default
			The boolean value to return if Obj is Cannot be converted to boolean.
		AlowAny
			Determines if Default can be a value other then boolean. If true Default can be any var, Object or null;
			Otherwise Default must be a boolean value.
	Remarks
		Static Method.
		If AllowAny is true then Default can be any value including var, object or null. However if AllowAny is false
		then this method will yield the same result as calling MfBool.GetValue(Obj, Default).
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfArgumentException if AllowAny is not a valid boolean.

	General Remarks
		Method is case in-sensitive, "t" and "T" are treated the same.
		Passing in a string value of "true" or "false" is accepted. String values of "t" and "f" are also acceptable.
		Any number can be passed in, all numbers greater then zero result in true. All other numbers result in false.
		Acceptable values for string or MfString instance are "T", "TRUE", "F" and "FALSE". If a string Value is numeric
		then it will be treated as a number. That is if the value is greater than zero the true is returned otherwise false.
		All other string values will cause an error to be thrown.
		Acceptable values for MfChar are 0-9, "T", "t", "F" and  "f". All other char values will cause an error to be thrown.
		If MfChar is a number then true is returned if the numeric value is greater than zero; Otherwise false is returned.
		Throws MfNotSupportedException if incorrect number of parameters are passed in.
*/
	GetValue(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		;obj, default=false, AllowAny=false
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
		_default := false
		obj := args[1]
		if (i = 1)
		{
			CanThrow := True
		}
		else if (i = 2)
		{
			try
			{
				_default := MfBool._GetValue(args[2])
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
					_default := MfBool._GetValue(args[2])
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
				retval := MfBool._GetValue(obj)
			}
			catch e
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBoolean"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		else
		{
			try
			{
				retval := MfBool._GetValue(obj)
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
		
		try
		{
			retval := false
			retval .= "" ; necessary for integer fast

			if (IsObject(obj))
			{
				if (MfObject.IsObjInstance(obj, MfBool))
				{
					return obj.Value
				}
				T := new MfType(obj)
				if (T.IsNumber)
				{
					retval := obj.Value
				}
				else if (T.IsString) 
				{
					if (obj.Length > 0 && obj.Length < 6)
					{
						str := obj.Value
						if (str = "t")
						{
							retval := 1
						}
						else if (str = "true")
						{
							retval := 1
						}
						else if (Mfunc.IsNumeric(obj.Value))
						{
							i := obj.Value + 0
							if (i > 0)
							{
								retval := 1
							}
						}
						else
						{
							ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBoolean"))
							ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
							Throw ex
						}
					}
					else if ((obj.Length > 0) && (obj.Length < 21) && (Mfunc.IsNumeric(obj.Value)))
					{
						i := obj.Value + 0
						if (i > 0)
						{
							retval := 1
						}
					}
					else
					{
						ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBoolean"))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						Throw ex
					}
				}
				else if (t.IsChar)
				{
					; if char is numberic we will accept it as boolean conversion
					; if char is T or t or F or f it will be converted to boolean
					; otherwise an error will be thrown
					if ((obj.CharCode = 84) || (obj.CharCode = 116)) ; T or t
					{
						retval := 1
					}
					else if (MfChar.IsNumber(obj))
					{
						if ((obj.Value + 0) > 0 )
						{
							retval := 1
						}
					}
					else if ((obj.CharCode <> 70) && (obj.CharCode <> 102)) ; F or f
					{
						ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBoolean"))
						ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
						Throw ex
					}
				}
			}
			else
			{
				; if obj is number will convert to boolean
				; if string then must match t or true or f or false (case insensitive)
				; othwrwise an error will be thown
				if (Mfunc.IsNumeric(obj))
				{
					i := obj + 0
					if (i > 0)
					{
						retval := 1
					}
				}
				else if (obj = "true")
				{
					retval := 1
				}
				else if (obj = "t")
				{
					retval := 1
				}
				else if ((!(obj = "f")) && (!(obj = "false")))
				{
					ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBoolean"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					Throw ex
				}
			}
		}
		Catch e
		{
			throw e
		}
		
		return retval > 0? MfBool.True:MfBool.False
	}
; 	End:_GetValue ;}
;{ 	Is()				- Overrides - MfPrimitive
/*
	Method: Is()
	Overrides MfObject.Is()
	
		OutputVar := instance.Is(ObjType)

	Is(ObjType)
		Gets if current instance of MfBool is of the same type as ObjType or derived from ObjType.
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
		if (typeName = MfType.TypeCodes[MfBool.TypeCode]) {
			return true
		}
		if ((typeName = "Boolean") || (typeName = "MfBool")) {
			return true
		}
		return base.Is(typeName)
	}
; End:Is() ;}	
;{ 	Parse
/*
	Method: Parse()
		OutputVar := MfBool.Parse(obj)
	
	MfBool.Parse(obj)
		Converts the specified string representation of a logical value to its Boolean equivalent, or throws an exception if the string is not equal to the value of TrueString or FalseString.
	Parameters
		obj
			An instance of MfString or var containing a boolean representation to convert.
			Can also be instance of MfParams.
	Returns
		Returns var containing integer equivalent to the number contained in obj or throws an error if unable to parse obj param.
		Variadic Method; This method is Variadic so you may construct an instance of MfParams containing any of the overload method parameters listed above and pass in the MfParams instance to the method instead of using the overloads described above. See MfParams for more information.
	Remarks
		Converts the obj specified string representation of a boolean to its MfBool equivalent.
		If obj parameter is an *Objects then it must be instance from MfObject or be an instance of MfParams.
		If MfParams is passed in with Data added ReturnAsObject set to true then parsed result will be returned as an instance of MfInteger; Otherwise a var integer will be returned. See example below.
	Throws
		Throws MfInvalidOperationException if not called as a static method.
		Throws MfFormatException if unable to parse obj.
		Throws MfArgumentNullException if no parameters are passe in.
		Throws MfNotSupportedException if incorrect number of parameters are passed in.
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
		if (objParams.Count = 0) {
			ex := new MfArgumentNullException("obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		result := new MfBool()
		if (!MfBool.TryParse(result, objParams)) {
			ex := new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_BadBoolean"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (objParams.Data.Contains("ReturnAsObject") && (objParams.Data.Item["ReturnAsObject"] = true)) {
				return result
			} else {
				return result.Value
			}
	}
; 	End:Parse ;}
;{ 	ToString()			- Overrides	- MfPrimitive
/*
	Method: ToString()
		Overrides MfPrimitive.ToString()
	
		OutputVar := instance.ToString()
	
	ToString()
		Gets a string representation of the object.
	Returns
		Returns string var representing current instance. Returns true or false depending on state of instance
	Throws
		Throws MfNullReferenceException if MfBool is not an instance.
*/
	ToString() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.Value >= MfBool.True) {
			return MfBool.TrueString
		}
		return MfBool.FalseString
	}
;  End:ToString() ;}
;{ 	TryParse
/*
	Method: TryParse()
	
	OutputVar := MfBool.TryParse(bool, obj)
	
	MfBool.TryParse(byref bool, obj)
		Tries to convert the specified string representation of a logical value to its Boolean equivalent.
		A return value indicates whether the conversion succeeded or failed.
		The conversion fails if the obj parameter is null, or is not equal to the value of either the TrueString or FalseString field.
	Parameters
		bool
			Contains the value equivalent to the boolean contained in obj, if the conversion succeeded.
		obj
			An instance of MfString or var containing a boolean representation to convert.
			Can also be instance of MfParams.
	Returns
		Returns true if value was converted successfully; otherwise, false.
	Remarks
		If parameter bool is passed in as an object it must in initialized as an instance of MfBool first. Eg: myBool := new MfBool()
		If parameter bool is passed in as var it must in initialized as boolean first. Eg: myBool := false
		The TryParse method is like the Parse method, except the TryParse method does not throw an exception if the conversion fails.
		The obj parameter can be preceded or followed by white space. The comparison is case-insensitive.
	Throws
		Throws MfInvalidOperationException if not called as a static method.

*/
	TryParse(byref bool, args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_isObj := false
		if (IsObject(bool)) {
			if (MfObject.IsObjInstance(bool, "MfBool")) {
				_isObj := true
			} else {
				; Int is an object but not an MfBool instance
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

		_scs := A_StringCaseSense
		StringCaseSense, Off

		strP := objParams.ToString()
		if (strP = "MfString") {
			strV := objParams.Item[0].Value
			if (strV = "true") {
				if (_isObj = true) {
					bool.Value := MfBool.True
				} else {
					bool := MfBool.True
				}
				StringCaseSense, %_scs%
				return true
			}
			if (strV = "false") {
				if (_isObj = true) {
					bool.Value := MfBool.False
				} else {
					bool := MfBool.False
				}
				StringCaseSense, %_scs%
				return true
			}
			if (MfInt64.TryParse(intValue, strV)) {
				if (intValue > 0) {
					if (_isObj = true) {
						bool.Value := MfBool.True
					} else {
						bool := MfBool.True
					}
					StringCaseSense, %_scs%
					return true
				}
				StringCaseSense, %_scs%
				return false
			}
			st := ""
			if (_isObj = true) {
				st := MfBool._TrimWhiteSpaceAndNull(objParams.Item[0])
			}  else {
				st := MfBool._TrimWhiteSpaceAndNull(new MfString(strV))
			}
			strV := st.Value
			st := ""
			if (strV = "true") {
				if (_isObj = true) {
					bool.Value := MfBool.True
				} else {
					bool := MfBool.True
				}
				StringCaseSense, %_scs%
				return true
			}
			if (strV = "false") {
				if (_isObj = true) {
					bool.Value := MfBool.False
				} else {
					bool := MfBool.False
				}
				StringCaseSense, %_scs%
				return true
			}
		} else if (strP = "MfBool") {
			if (_isObj = true) {
				bool.Value := objParams.Item[0].Value
			} else {
				bool := objParams.Item[0].Value
			}
			StringCaseSense, %_scs%
			return true
		}
		StringCaseSense, %_scs%
		return false
	}
; 	End:TryParse ;}
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
;{ Internal Methods
;{ 	TrimWhiteSpaceAndNull
	_TrimWhiteSpaceAndNull(value) {
		retval := MfBool._TrimWhiteSpaceAndNullRight(value)
		retval := MfBool._TrimWhiteSpaceAndNullLeft(retval)
		return retval
	}
	_TrimWhiteSpaceAndNullRight(value) {
		i := 0
		num := value.Length - 1
		NullChar := new MfChar(0)
		_value := new MfString(value, true)
		done := false
		retval := ""
		
		while ((i < _value.Length))
		{
			_cValue := _value.Index[i]
			if (!MfChar.IsWhiteSpace(_cValue) && _cValue.CharCode != NullChar.CharCode)
			{
				subLen := value.Length - i
				if (subLen > 0) {
					retval := _value.Substring(i, subLen)
				} else {
					retval := new MfString(MfString.Empty)
				}
				break
			}
			i++
		}
		retval.ReturnAsObject := value.ReturnAsObject
		return retval
	}
	_TrimWhiteSpaceAndNullLeft(value) {
		num := value.Length - 1
		NullChar := new MfChar(0)
		_value := new MfString(value, true)
		done := false
		retval := new MfString()
		_cValue := _value.Index[num]
		while (num > 0 && (MfChar.IsWhiteSpace(_cValue) || _cValue.CharCode = NullChar.CharCode))
		{
			num--
			_cValue := _value.Index[num]
			
		}
		subLen := num + 1
		if (subLen > 0) {
			retval := _value.Substring(0, subLen)
		} else {
			retval := new MfString(MfString.Empty)
		}
		
		retval.ReturnAsObject := value.ReturnAsObject
		return retval
	}
; 	End:TrimWhiteSpaceAndNull ;}
; End:Internal Methods ;}
;{ Properties
;{ IsTrue
	/*!
		Property: IsTrue [get]
			Gets the IsTrue associated with the this instance
		Value:
			Var representing the IsTrue property of the instance
		Remarks:
			Readonly Property
	*/
	IsTrue[]
	{
		get {
			return this.Value = true
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "IsTrue")
			Throw ex
		}
	}
; End:IsTrue ;}
;{ IsFalse
	/*!
		Property: IsFalse [get]
			Gets the IsFalse associated with the this instance
		Value:
			Var representing the IsFalse property of the instance
		Remarks:
			Readonly Property
	*/
	IsFalse[]
	{
		get {
			return this.Value = false
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "IsFalse")
			Throw ex
		}
	}
; End:IsFalse ;}
;{	Value
;{ 	Start:Value Property Comment
/*
	Property: Value [get/set]
		Gets or sets the value associated with the this instance of MfBool.
		Overrides MfPrimitive.Value.
	Value:
		Value is a boolean value and can be var
		Can be any object of the matches type IsNumber, MfString or MfChar
	Get:
		Gets boolean Value as 
	Set:
		Set the Value of the instance. Can be MfBool instance or var containing boolean.
	Remarks:
		When setting the property if the value used to set is numeric then then Value will be true if the number is
		greater then zero; Otherwise false.
		Value is Set using the GetValue() method and therefore can be set to any Object or var that is accepted by GetValue().
	Throws
		Throws MfNotSupportedException when trying to set if Readonly is true.
*/
; 	End:Value Property Ccomment ;}
	Value[]
	{
		get {
			return Base.Value
		}
		set {
			this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
			try
			{
				Base.Value := MfBool._GetValue(value)
			}
			Catch e
			{
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_PropertySet", A_ThisFunc), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			return Base.Value
		}
	}
;	End:Value ;}
; End:Properties;}
}
/*!
	End of class
*/