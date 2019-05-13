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
	Class: MfVersion
		Represents the version number of an assembly, operating system, or the common language runtime. This class cannot be extended.
	Inherits:
		MfObject
*/
class MfVersion extends MfObject
{
;{ Internal members
	m_Build 		:= -1
	m_Major			:= Null
	m_Minor			:= Null
	m_Revision		:= -1
; End:Internal members ;}
;{ Constructor
/*
	Method: Constructor()
		Creates a new instance of MfVersion Class

	OutputVar := new MfVersion()
	OutputVar := new MfVersion(version)
	OutputVar := new MfVersion(major, minor)
	OutputVar := new MfVersion(major, minor, build)
	OutputVar := new MfVersion(major, minor, build, revision)

	Parameters:
		version
			A string containing the major, minor, build, and revision numbers, where each number is delimited
			with a period character ('.').
		major
			The major version number.
		minor
			The minor version number.
		build
			The build number.
		revision
			The revision number.

	Constructor()
		Initializes a new instance of the MfVersion class.

	Constructor(version)
		Initializes a new instance of the MfVersion class using the specified version.
	Throws:
		Throws MfArgumentException version has fewer than two components or more than four components.
		Throws MfArgumentNullException version is null.
		Throws MfArgumentOutOfRangeException A major, minor, build, or revision component is less than zero.
		Throws MfFormatException At least one component of version does not parse to an integer.
		Throws MfOverflowException At least one component of version represents a number greater than
		MfInteger.MaxValue.
	Remarks:
		The version parameter can contain only the components major, minor, build, and revision, in that
		order, and all separated by periods. There must be at least two components, and at most four. The
		first two components are assumed to be major and minor. The value of unspecified components is
		undefined.
		The format of the version number is as follows. Optional components are shown in square brackets
		('[' and ']'):
		major.minor[.build[.revision]]
		All defined components must be integers greater than or equal to 0. For example, if the major number
		is 3, the minor number is 4, the build number is 2, and the revision number is 5, then version
		should be "3.4.2.5".

	Constructor(major, minor)
		Initializes a new instance of the MfVersion class using the specified major and minor values.
	Throws:
		Throws MfArgumentOutOfRangeException A major or minor is less than zero.

	Constructor(major, minor, build)
		Initializes a new instance of the MfVersion class using the specified major, minor, and build
		values.
	Throws:
		Throws MfArgumentOutOfRangeException A major, minor or build is less than zero.

	Constructor(major, minor, build, revision)
		Initializes a new instance of the MfVersion class with the specified major, minor, build, and
		revision numbers.
	Throws:
		Throws MfArgumentOutOfRangeException A major, minor, build or revision is less than zero.
*/
	__New(arg1="",arg2="",arg3="",arg4="") {
		; Throws MfNotSupportedException if MfVersion Sealed class is extended
		if (this.__Class != "MfVersion") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfVersion"))
		}
		base.__New()
		if (MfNull.IsNull(arg1)) {
			this._Major := 0
			this._Minor := 0
		} else if (MfNull.IsNull(arg2)) { ; considered string passed into arg1 as version
			version2 := MfVersion.Parse(arg1)
			this.m_Major	:= version2.Major
			this.m_Minor	:= version2.Minor
			this.m_Build	:= version2.Build
			this.m_Revision	:= version2.Revision
		} else if (MfNull.IsNull(arg3)) { ; considered arg1 is Major and arg2 is minor, int, int
			major := MfInteger.GetValue(arg1)
			minor := MfInteger.GetValue(arg2)
			if (major < 0)
			{
				throw new MfArgumentOutOfRangeException("major", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Version"))
			}
			if (minor < 0)
			{
				throw new MfArgumentOutOfRangeException("minor", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Version"))
			}
			this.m_Major := major
			this.m_Minor := minor
		} else if (MfNull.IsNull(arg4)) { ;consider arg1 is major, arg2 is minor and arg 3 is build, int, int, int
			major := MfInteger.GetValue(arg1)
			minor := MfInteger.GetValue(arg2)
			build := MfInteger.GetValue(arg3)
			if (major < 0)
			{
				throw new MfArgumentOutOfRangeException("major", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Version"))
			}
			if (minor < 0)
			{
				throw new MfArgumentOutOfRangeException("minor", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Version"))
			}
			if (build < 0)
			{
				throw new MfArgumentOutOfRangeException("build", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Version"))
			}
			this.m_Major	:= major
			this.m_Minor	:= minor
			this.m_Build	:= build
		} else {
				major 		:= MfInteger.GetValue(arg1)
				minor 		:= MfInteger.GetValue(arg2)
				build 		:= MfInteger.GetValue(arg3)
				revision	:= MfInteger.GetValue(arg4)
				if (major < 0)
				{
					throw new MfArgumentOutOfRangeException("major", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Version"))
				}
				if (minor < 0)
				{
					throw new MfArgumentOutOfRangeException("minor", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Version"))
				}
				if (build < 0)
				{
					throw new MfArgumentOutOfRangeException("build", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Version"))
				}
				if (revision < 0)
				{
					throw new MfArgumentOutOfRangeException("revision", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Version"))
				}
				this.m_Major	:= major
				this.m_Minor	:= minor
				this.m_Build 	:= build
				this.m_Revision	:= revision
		}
		this.m_isInherited := this.__Class != "MfVersion"
	}
; End:Constructor ;}
;{ Methods
;{ 	Equals
/*
	Method: Equals()
		Overrides MfObject.Equals()

	OutputVar := instance.Equals(objA)
	OutputVar := MfVersion.Equals(objA, objB)

	Equals(objA)
		Gets if current MfVersion instance is equal to objA instance.

	MfVersion.Equals(objA, ObjB)
		Gets if objA instance of MfVersion is equal to objB instance.
	Parameters:
		objA
			The instance of MfVersion to compare.
		objB
			The instance of MfVersion to compare to obj
	Returns:
		Returns var Boolean value of true if the objects are the same; otherwise false.
	Throws:
		Throws MfNullReferenceException if objB is omitted and current object is not an instance of MfVersion.
		Throws MfNotSupportedException if a parameter is not an intance of MfVersion.
		Throws MfArgumentException if there is an error get a value from a parameter.
		Throws MfException on any general exceptions are caught.
	Remarks:
		Objects must be instance of MfVersion for true to be returned.
*/
	Equals(args*) {
		isInst := this.IsInstance()

		objParams := Null
		if (isInst)
		{
			objParams := this._EqualsParams(A_ThisFunc, args*)
		}
		else
		{
			objParams := MfObject._EqualsParams(A_ThisFunc, args*)
		}

		retval := false
		try {
			strP := objParams.ToString()
			if (strP = "MfVersion") {
				result := this.CompareTo(objParams.Item[0])
				return result = 0
			}
			else if (strP = "MfVersion,MfVersion") {
					result := objParams.Item[0].CompareTo(objParams.Item[1])
				return result = 0
			}
			else
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} catch e {
			if (MfObject.IsObjInstance(e, MfNotSupportedException))
			{
				throw e
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval

	}
; 	End:Equals ;}
;{ 	CompareTo
/*
	Method: CompareTo()

	OutputVar := instance.CompareTo(value)

	CompareTo(value)
		Compares the current MfVersion object to a specified MfVersion object and returns an indication of their relative values.
	Parameters:
		value
			A MfVersion object to compare.
	Returns:
		Returns integer var that indicates the relative values of the two MfVersion objects.
		* Less than zero - The current MfVersion object is a version before value.
		* Zero - The current MfVersion object is the same version as value.
		* Greater than zero - The current MfVersion object is a version subsequent to value. or value is null
	Throws:
		Throws MfNullReferenceException if called as a static method
		Throws MfArgumentException if value is not an instance of MfVersion.
*/
	CompareTo(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(value)) {
			return 1
		}
		if (!MfObject.IsObjInstance(value, "MfVersion")) {
			err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Object_Equals"),"value")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (this.Major != value.Major)
		{
			if (this.Major > value.Major)
			{
				return 1
			}
			return -1
		}
		else if (this.Minor != value.Minor)
		{
			if (this.Minor > value.Minor)
			{
				return 1
			}
			return -1
		}
		else if (this.Build != value.Build)
		{
			if (this.Build > value.Build)
			{
				return 1
			}
			return -1
		}
		else if (this.Revision = value.Revision)
		{
			return 0
		}
		else if (this.Revision > value.Revision)
		{
			return 1
		}
		return -1
	}
; 	End:CompareTo ;}
;{ 	GetHashCode
/*
	Method: GetHashCode()
		Overrides MfObject.GetHashCode().

	OutputVar := instance.GetHashCode()

	GetHashCode()
		Returns a hash code for this instance.
	Returns:
		Returns a signed integer hash code as var.
	Throws:
		Throws MfNullReferenceException if called as a static method.
	Remarks:
		A hash code is a numeric value that is used to insert and identify an object in a hash-based collection such as a Hash table.
		The GetHashCode() method provides this hash code for hashing algorithms and data structures such as a hash table.
		Two MfVersion objects might have the same hash code even though they represent different time values.
*/
	GetHashCode() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		int := 0
		int := int | (this.m_Major & 15) << 28
		int := int | (this.m_Minor & 255) << 20
		int := int | (this.m_Build & 255) << 12
		return int | (this.m_Revision & 4095)
	}
; 	End:GetHashCode ;}
;{ 	GreaterThen
/*
	Method: GreaterThen()

	OutputVar := instance.GreaterThen(value)

	GreaterThen(value)
		Compares the current MfVersion object to a specified MfVersion object and returns a boolean indication of their relative values.
	Parameters:
		value
			A MfVersion object to compare.
	Returns:
		Returns true if the current instance has greater value then the value instance; otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method.
*/
	GreaterThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		try {
			iver := this.CompareTo(value)
			if (iver > 0 ) {
				retval := true
			}
		} catch e {
			if (MfObject.IsObjInstance(e, "MfArgumentException")) {
				err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Object_Equals"),"value")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			} else {
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		return retval
	}
; 	End:GreaterThen ;}
;{ 	GreaterThenOrEqual
/*
	Method: GreaterThenOrEqual()

	OutputVar := instance.GreaterThenOrEqual(value)

	GreaterThenOrEqual(value)
		Compares the current MfVersion object to a specified MfVersion object and returns an indication of their relative values.
	Parameters:
		value
			A MfVersion object to compare.
	Returns:
		Returns true if the current instance has greater or equal value then the value instance; otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method.
*/
	GreaterThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		try {
			iver := this.CompareTo(value)
			if (iver >= 0 ) {
				retval := true
			}
		} catch e {
			if (MfObject.IsObjInstance(e, "MfArgumentException")) {
				err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Object_Equals"),"value")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			} else {
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		return retval
	}
; 	End:GreaterThenOrEqual ;}
;{ 	LessThen
/*
	Method: LessThen()

	OutputVar := instance.LessThen(value)

	LessThen(value)
		Compares the current MfVersion object to a specified MfVersion object and returns an indication of their relative values.
	Parameters:
		value
			A MfVersion object to compare.
	Returns:
		Returns true if the current instance has less value then the value instance; otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method.
*/
	LessThen(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		try {
			iver := this.CompareTo(value)
			if (iver < 0 ) {
				retval := true
			}
		} catch e {
			if (MfObject.IsObjInstance(e, "MfArgumentException")) {
				err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Object_Equals"),"value")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			} else {
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		return retval
	}
; 	End:LessThen ;}
;{ 	LessThenOrEqual
/*
	Method: LessThenOrEqual()

	OutputVar := instance.LessThenOrEqual(value)

	LessThenOrEqual(value)
		Compares the current MfVersion object to a specified MfVersion object and returns an indication of their relative values.
	Parameters:
		value
			A MfVersion object to compare.
	Returns:
		Returns true if the current instance has less or equal value then the value instance; otherwise false.
	Throws:
		Throws MfNullReferenceException if called as a static method.
*/
	LessThenOrEqual(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		try {
			iver := this.CompareTo(value)
			if (iver <= 0 ) {
				retval := true
			}
		} catch e {
			if (MfObject.IsObjInstance(e, "MfArgumentException")) {
				err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Object_Equals"),"value")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			} else {
				ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		return retval
	}
; 	End:LessThenOrEqual ;}
;{	Parse
/*
	Method: Parse()

	OutputVar := MfVersion.Parse(input)

	MfVersion.Parse(input)
		Converts the string representation of a version number to an equivalent MfVersion object.
	Parameters:
		input
			A string that contains a version number to convert. can be MfString instance or var containing string.
	Returns:
		Returns An object that is equivalent to the version number specified in the input parameter
	Throws:
		Throws MfArgumentNullException if input is null or empty or has fewer than two or more than four version components.
		Throws MfArgumentOutOfRangeException if at least one component in input is less than zero.
		Throws MfFormatException if at least one component in input is not an MfInteger.
		Throws MfOverflowException if at least one component in input represents a number that is greater than MfInteger.MaxValue.
*/
	Parse(input) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfString.IsNullOrEmpty(input))
		{
			ex := new MfArgumentNullException("input")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_input := MfString.GetValue(input)
		versionResult := new MfVersion.VersionResult()
		versionResult.Init("input", true)
		if (!MfVersion._TryParseVersion(_input, versionResult))
		{
			throw versionResult.GetVersionParseException()
		}
		return versionResult.m_parsedVersion
		
	}
;	End:Parse ;}
;{ 	ToString
/*
	Method: ToString()

	OutputVar := instance.ToString()
	OutputVar := instance.ToString(fieldCount)

	ToString()
		Converts the value of the current Version object to its equivalent String representation.

	ToString(fieldCount)
		Converts the value of the current Version object to its equivalent String representation.
		A specified count indicates the number of components to return.
	Parameters:
		fieldCount
			The number of components to return. The fieldCount ranges from 0 to 4.
	Returns:
		Returns The String representation of the values of the major, minor, build, and revision components
		of the current MfVersion object, each separated by a period character ('.'). The fieldCount parameter
		determines how many components are returned.
	Throws:
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentException if fieldCount is greater than 4 or fieldCount is more than the number of
		components defined in the current MfVersion object.
*/
	ToString(fieldCount = -1) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_fieldCount := MfInteger.GetValue(fieldCount)
		if (_fieldCount > 0) {
			return this._Tostring(_fieldCount)
		}
		if (this.m_Build = -1)
		{
			return this._ToString(2)
		}
		if (this.m_Revision = -1)
		{
			return this._ToString(3)
		}
		return this._Tostring(4)
	}
	_ToString(fieldCount) {
		if (!fieldCount) {
			return MfString.Empty
		} else if (fieldCount = 1) {
			return format("{:i}", this.Major)
		} else if (fieldCount = 2) {
			return format("{:i}.{:i}", this.Major, this.Minor)
		} 
		if (this.m_Build = -1) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
				, "0","2"), "fieldCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (fieldCount = 3) {
			return format("{:i}.{:i}.{:i}", this.Major, this.Minor, this.Build)
		}
		if (this.m_Revision = -1)
		{
			ex := new MfArgumentException(Environment.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
			, "0","3"), "fieldCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (fieldCount = 4)
		{
			return format("{:i}.{:i}.{:i}.{:i}",this.Major, this.Minor, this.Build, this.Revision)
		}
		ex := new MfArgumentException(Environment.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper"
			, "0","3"), "fieldCount")
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:ToString ;}
; End:Methods ;}
;{ Internal Methods
;{ 	_TryParseVersion
	_TryParseVersion(version, ByRef result) ; String Version, Version.VersionResult result
	{
		if (MfString.IsNullOrEmpty(version)) {
			result.SetFailure(MfVersion.ParseFailureKind.Instance.ArgumentNullException)
			return false
		}
		_ver := new MfString(version)
		_Array := _ver.Split(".")
		
		SplitCount := _Array.Count
		if ((SplitCount < 2) || (SplitCount > 4)) {
			result.SetFailure(MfVersion.ParseFailureKind.Instance.ArgumentException)
			return false
		}
		major := new MfInteger(0)
		if (!MfVersion._TryParseComponent(_Array.Item[0], "MfVersion", result, major)) {
			return false
		}
		minor := new MfInteger(0)
		if (!MfVersion._TryParseComponent(_Array.Item[1], "MfVersion", result, minor)) {
			return false
		}
		SplitCount -= 2
		if (SplitCount > 0) {
			build := new MfInteger(0)
			if (!MfVersion._TryParseComponent(_Array.Item[2], "build", result, build))
			{
				return false
			}
			SplitCount--
			if (SplitCount > 0) {
				revision := new MfInteger(0)
				if (!MfVersion._TryParseComponent(_Array.Item[3], "revision", result, revision))
				{
					return false
				}
				result.m_parsedVersion := new MfVersion(major, minor, build, revision)
			}
			else
			{
				result.m_parsedVersion := new MfVersion(major, minor, build)
			} 
		} else {
			result.m_parsedVersion := new MfVersion(major, minor)
		}
		return true
	}
; 	End:_TryParseVersion ;}
;{ 	_TryParseComponent
	_TryParseComponent(component, componentName, ByRef result, ByRef parsedComponent) ;String, String, MfVersion.VersionResult, MfInteger
	{
		if (!MfInteger.TryParse(parsedComponent, component))
		{
			result.SetFailure(MfVersion.ParseFailureKind.Instance.FormatException, component)
			return false
		}
		if (parsedComponent.Value < 0)
		{
			result.SetFailure(MfVersion.ParseFailureKind.Instance.ArgumentOutOfRangeException, componentName)
			return false
		}
		return true
	}
; 	End:_TryParseComponent ;}
; End:Internal Methods ;}
;{ Internal Class ParseFailureKind
	class ParseFailureKind extends MfEnum
	{
		static m_Instance := ""
;{ 	Constructor
	/*
		Constructor: () or (num) or (instanceEnum) or (enumItem)
			Constructor for class MfVersion.ParseFailureKind  
			Constructor () Creates a new instance of MfVersion.ParseFailureKind class and set inital value to zero.  
			Constructor (num) Creates a new instance of MfVersion.ParseFailureKind class and sets inital value to value of *num*.  
			Constructor (instanceEnum) Creates a new instance of MfVersion.ParseFailureKind class an set the intial value to the value of *instanceEnum*.  
			Constructor (enumItem) Creates a new instance of derived class and set its value to the MfVersion.ParseFailureKind instance value.
		Parameters:
			num - A value representing the current selected [MfEnum.EnumItem](MfEnum.enumitem.html) value(s) of the derived class.
			instanceEnum - an instance of derived class whose value is used to construct this instance.
			enumItem - [MfEnum.EnumItem](MfEnum.enumitem.html) value must element of this instance
		Throws:
			Throws [MfNotSupportedException](MfNotSupportedException.html) if this Abstract class constructor is called directly.  
			Throw [MfArgumentException](MfArgumentException.html) if arguments are not correct.  
			Throws [MfNotSupportedException](MfNotSupportedException.html) if this Sealed class is inherited.
		*/
		__New(args*) {
		; Throws MfNotSupportedException if MfUnicodeCategory Sealed class is extended
		if (this.__Class != "MfVersion.ParseFailureKind") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfVersion.ParseFailureKind"))
		}
		base.__New(args*)
		this.m_isInherited := this.__Class != "MfVersion.ParseFailureKind."
	}
; 	End:Constructor ;}
;{ Methods
;{ 	AddEnums()
	/*
		Method: AddEnums()
			AddEnums() Processes adding of new MfEnum values to derived class.  
			Overrides [MfEnum.AddEnums](MfEnum.addenums.html).
		Remarks:
			This method is call by base class and does not need to be call manually.
	*/
	AddEnums() {
		this.AddEnumValue("ArgumentNullException", 0)
		this.AddEnumValue("ArgumentException", 1)
		this.AddEnumValue("ArgumentOutOfRangeException", 2)
		this.AddEnumValue("FormatException", 3)
	}
; 	End:AddEnums() ;}
;{ 	GetInstance
	/*
		Method: GetInstance()
			GetInstance() Gets the instance for the [MfUnicodeCategory](MfUnicodeCategory.html) class.  
			Overrides [MfEnum.GetInstance](MfEnum.getinstance.html).
		Remarks:
			[MfUnicodeCategory.DestroyInstance](MfUnicodeCategory.destroyinstance.html) can be called to destroy instance.
		Returns:
			Returns Singleton instance for [MfUnicodeCategory](MfUnicodeCategory.html) class.
	*/
	GetInstance() {
		if (MfNull.IsNull(MfVersion.ParseFailureKind.m_Instance)) {
			MfVersion.ParseFailureKind.m_Instance := new MfVersion.ParseFailureKind(0)
		}
		return MfVersion.ParseFailureKind.m_Instance
	}
; 	End:GetInstance ;}
;{ 	Is()				- Overrides - MfEnum
		/*
			Method: Is(ObjType)
				Is() Gets if current *instance* of *object* is of the same type.  
				Overrides [MfEnum.Is()](MfEnum.is.html)
			Parameters:
				ObjType - The object to compare this *instance* type with
					Type can be an *instance* of [MfType](MfType.html) or an object derived from
					[MfObject](MfObject.html) or an *instance* of 
					or a string containing the name of the object
					type such as "MfObject"
			Remarks:
				If a string is used as the Type case is ignored so "MfObject" is the same as "MfObject"
			Returns:
				Returns **true** if current *object* *instance* is of the same type as the Type Paramater
				otherwise **false**
		*/
		Is(ObjType) {
			typeName := MfType.TypeOfName(ObjType)
			if (typeName = "ParseFailureKind") { 
				return true
			}
			if (typeName = "MfVersion.ParseFailureKind") { 
				return true
			}
			return base.Is(typeName)
		}
; End:Is() ;}	
;{ 	DestroyInstance
		/*
			Method: DestroyInstance()
				DestroyInstance() Destroys the singleton instance of [MfUnicodeCategory](MfUnicodeCategory.html).  
				Overrides [MfEnum.DestroyInstance](MfEnum.destroyinstance.html).
		*/
		DestroyInstance() {
			MfVersion.ParseFailureKind.m_Instance := ""
		}
; 	End:DestroyInstance ;}
; End:Methods ;}
	}
; End:ParseFailureKind ;}
;{ Internal Class VersionResult
	class VersionResult extends MfValueType
	{
		m_parsedVersion		:= Null ; Version
		m_failure			:= Null ; MfVersion.ParseFailureKind
		m_exceptionArgument	:= Null ; String
		m_argumentName		:= Null ; String
		m_canThrow			:= Null ; MfBool
		
		__New() {
			base.__New()
		}
		Init(argumentName, canThrow) {
			this.m_canThrow := MfBool.GetValue(canThrow)
			this.m_argumentName := MfString.GetValue(argumentName)
		}

		SetFailure(failure, argument = "") {
			this.m_failure := failure
			this.m_exceptionArgument := MfString.GetValue(argument)
			if (this.m_canThrow = true)
			{
				throw this.GetVersionParseException()
			}
		}
		
		GetVersionParseException() {
			if (this.m_failure.Value = MfVersion.ParseFailureKind.Instance.ArgumentNullException.Value) {
				return new MfArgumentNullException(this.m_argumentName)
			} else if (this.m_failure.Value = MfVersion.ParseFailureKind.Instance.ArgumentException.Value) {
				return new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_VersionString"))
			} else if (this.m_failure.Value = MfVersion.ParseFailureKind.Instance.ArgumentOutOfRangeException.Value) {
				return new MfArgumentOutOfRangeException(this.m_exceptionArgument, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Version"))
			} if (this.m_failure.Value = MfVersion.ParseFailureKind.Instance.FormatException.Value) {
				try {
					MfInteger.Parse(this.m_exceptionArgument)
				} catch ex {
					result := ex
					return result
				}
				return new MfFormatException(MfEnvironment.Instance.GetResourceString("Format_InvalidString"))
			} 
			return new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_VersionString"))
		}
		; Override base class Is type method to return accurate type checking
		Is(ObjType) {
			typeName := MfType.TypeOfName(ObjType)
			if (typeName = "VersionResult") { ; reflect this Class name for type checking
				return true
			}
			if (typeName = "MfVersion.VersionResult") { ; reflect this Class name for type checking
				return true
			}
			return base.Is(typeName)
		}
	}
; End:Class VersionResult ;}
;{ Properties
;{ 	Build
/*
	Property: Build [get]
	Value:
		The build component as var containing integer.
	Gets:
		Gets the value of the build component of the version number for the current MfVersion object.
	Remarks:
		Read-only Property
*/
	Build[]
	{
		get {
			return this.m_Build
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Build ;}
;{ 	Major
/*
	Property: Major [get]
	Value:
		The major component as var containing integer.
	Gets:
		Gets the value of the major component of the version number for the current MfVersion object.
	Remarks:
		Read-only Property
*/
	Major[]
	{
		get {
			return this.m_Major
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Major ;}
;{ 	MajorRevision
/*
	Property: MajorRevision [get]
		Gets the high 16 bits of the revision number.
	Value:
		The MajorRevision component as var containing integer.
	Remarks:
		Read-only property
		Suppose you release an interim version of your application to temporarily correct a problem until you
		can release a permanent solution. The temporary version does not warrant a new revision number,
		but it does need to be identified as a different version. In this case, encode the identification
		information in the high and low 16-bit portions of the 32-bit revision number. Use the Revision
		property to obtain the entire revision number, use the MajorRevision property to obtain the high 16 bits,
		and use the MinorRevision property to obtain the low 16 bits.
*/
	MajorRevision[]
	{
		get {
			
			Hiword := this.m_Revision >> 16
			return Hiword
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MajorRevision ;}
;{ 	Minor
/*
	Property: Minor [get]
		Gets the value of the minor component of the version number for the current [MfVersion](MfVersion.html) object.
	Value:
		The minor component as var containing integer.
	Remarks:
		For example, if the version number is 6.2, the minor version is 2.
*/
	Minor[]
	{
		get {
			return this.m_Minor
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Minor ;}
;{ 	MinorRevision
/*
	Property: MinorRevision [get]
		Gets the low 16 bits of the revision number.
	Value:
		The MinorRevision component as var containing integer.
	Remarks:
		Suppose you release an interim version of your application to temporarily correct a problem until you can
		release a permanent solution. The temporary version does not warrant a new revision number, but it does
		need to be identified as a different version. In this case, encode the identification information in the
		high and low 16-bit portions of the 32-bit revision number. Use the Revision property to obtain the entire
		revision number, use the MajorRevision property to obtain the high 16 bits, and use the MinorRevision
		property to obtain the low 16 bits.
*/
	MinorRevision[]
	{
		get {
			Loword := this.m_Revision & 0xFFFF
			return Loword
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:MinorRevision ;}
;{ 	Revision
/*
	Property: Revision [get]
		Gets the value of the revision component of the version number for the current [MfVersion](MfVersion.html) object.
	Value:
		The revision component as var containing integer.
	Remarks:
		For example, if the version number is 6.2.1.3, the revision number is 3. If the version number
		is 6.2, the revision number is undefined.
*/
	Revision[]
	{
		get {
			return this.m_Revision
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Revision ;}
; End:Properties ;}
}
/*!
	End of class
*/