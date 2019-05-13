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

;{ Class comments
/*!
	Class: MfException
		Represents errors that occur during application execution.
	Inherits:
		MfObject
*/
; End:Class comments ;} 
Class MfException extends MfObject
{
;{ internal members	
	m_ClassName := Null
	m_Data := Null
	m_InnerException := Null
	m_Message := Undefined
	m_HelpLink := Null
	m_Line := 0
	m_File := Null
	m_HrResult := -2146233088

; End:internal members ;}
;Method: Constructor() or Constructor(message) or Constructor(message, innerException)
;Constructor() new instance of [MfException](MfException.html)
;{ Constructor
/*
	Constructor()
	
	OutputVar := new MfException()
	OutputVar := new MfException(message)
	OutputVar := new MfException(message, innerException)
	
	Constructor()
		Initializes a new instance of the MfException class.
	Remarks
		This constructor initializes the Message property of the new instance to a system-supplied message that describes the error,
		such as "As error has occurred."
	
	Constructor(message)
		Initializes a new instance of MfException class with a specified error message
	
	Constructor(message, innerException)
		Initializes a new instance of MfException class with a specified error message and a reference to the inner exception that is the cause of this exception.
	Remarks
		An exception that is thrown as a direct result of a previous exception can include a reference to the previous exception in the InnerException property.
		The InnerException property returns the same value that is passed into the constructor, or a null reference if the InnerException property does not supply
		the inner exception value to the constructor.
		If innerException is AutoHotkey Exception  then is converted into MfException.
	
	Parameters
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
	General Remarks
		The content of the message parameter should be understandable to the user.
		The caller of this constructor is required to ensure that this string has been localized for the current system culture.
*/
	__New(message = "", innerException = "") {
		base.__New()
		this.m_isInherited := this.__Class != "MfException"
		wf := A_FormatInteger
		SetFormat, IntegerFast, D
		try
		{
			if (MfString.IsNullOrEmpty(message)) {
				this.m_Message := MfEnvironment.Instance.GetResourceString("Exception_General_Error")
			} else {
				this.m_Message := MfString.GetValue(message)
			}
			if (IsObject(innerException)) {
				
				if (innerException.is(MfException)) {
					this.m_InnerException := innerException
				} else {
					if (MfException.IsValidException(innerException)) {
						this.m_InnerException := MfException.ConvertFromException(innerException)
					}
				}
				
			}
			this.m_File := A_ScriptFullPath
		}
		catch e
		{
			throw e
		}
		finally
		{
			SetFormat, IntegerFast, %wf%
		}
	}
; End:Constructor ;}
;{ Methods

;{	CompareTo(obj)					- Overrides	- MfObject
/*
	Method: CompareTo()
		Overrides MfObject.CompareTo().
	
	OutputVar := instance.CompareTo(obj)
	
	CompareTo(obj)
		Compares the current instance with another object of the same type and returns an integer that indicates whether the current instance
		precedes, follows, or occurs in the same position in the sort order as the other object.
		This method can be overridden in extended classes.
	Parameters
		obj
			An object to compare with this instance.
	Returns
		Returns var containing integer that indicates the relative order of the objects being compared.
		The return value has these meanings: Value Meaning Less than zero This instance precedes obj in the sort order.
		Zero This instance occurs in the same position in the sort order as obj Greater than zero This instance follows obj in the sort order.
	Throws
		Throws MfArgumentException is not the same type as this instance.
*/
	CompareTo(obj) {
		if (!MfObject.IsObjInstance(obj, this.GetType())) {
			err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentException_ObjectCompareTo"), "obj")
			err.Source := A_ThisFunc
			throw err
		}
		
		if(this.Equals(obj)) {
			return 0
		}
		strA := new MfString(this.Message)
		strB := new MfString(obj.Message)
		return strA.CompareTo(strB)
	}
; End:CompareTo(obj) ;}	
;{ 	ConvertFromException(e)
/*
	Method: ConvertFromException()
	
	OutputVar := MfException.ConvertFromException(e)
	
	ConvertFromException(e)
		Converts an AutoHotkey Exception object to MfException object
	Parameters
		e
			AutoHotkey Exception object to convert to MfException object
	Returns
		Returns MfException object representing the data values of the AutoHotkey Exception.
		If e in not a valid AutoHotkey Exception then a MfException object instance is returned containing null values.
	Remarks
		MfException automatically converts AutoHotkey Exceptions when passed in to the Constructor.
		Static method
*/
	ConvertFromException(e) {
		ex := null
		if (MfException.IsValidException(e)) {
			msg := null
			if (e.What) {
				msg := MfString.Format("{0}`r`nWhat:{1}", e.Message, e.What)
			} else {
				msg := e.Message
			}
			ex := new MfException(msg)
			if (MfException.IsNumeric(e.Line)) {
				ex.Line := e.Line
			}
			if (e.File) {
				ex.File := e.File
			}
			
		} else {
			ex := new MfException(null)
		}
		return ex
	}
; End:ConvertFromException(e) ;}
;{ 	GetBaseException()
/*
	Method: GetBaseException()
	
	Outputvar := instance.GetBaseException()
	
	GetBaseException()
		Gets the MfException that is the root cause of one or more subsequent exceptions.
	Returns
		The first exception thrown in a chain of exceptions. If the InnerException property of the current exception
		is a null reference this property returns the current MfException.
	Throws
		MfNullReferenceException if instance is null.
	Remarks
		When overridden in a derived class, returns the MfException that is the root cause of one or more subsequent exceptions.
*/
	GetBaseException() {
		if (!this.IsInstance()) {
			ex := new MfNullReferenceException(MfEnvironment.Instance.GetResourceString("NullReferenceException_Object"))
			ex.Source := A_ThisFunc
			throw ex
		}
		_innerException := this.m_InnerException
		result := this
		while (IsObject(_innerException))
		{
			result := _innerException
			_innerException := _innerException.InnerException
		}
		return result
	}
; End:GetBaseException() ;}	
;{ 	GetClassName()
	; internal method
	; gets the classname of the currrent MfException or derived exception
	GetClassName() {
		if (MfNull.IsNull(this.m_ClassName)) {
			this.m_ClassName := MfType.TypeOfName(this)
		}
		return this.m_ClassName
	}
; End:GetClassName() ;}	
;{	GetHashCode()					- Inhertis	- MfObject
/*
	Method: GetHashCode()
		GetHashCode() Gets A hash code for the current MfException or derivded class.  
		Overrides from MfObject.GetHashCode().
	Remarks:
		A hash code is a numeric value that is used to insert and identify an object in a
		hash-based collection such as a Hash table. The GetHashCode() method provides this hash
		code for hashing algorithms and data structures such as a hash table. 
	Returns:
		Returns A hash code for the current MfException or derivded class.
	Extra:
		Two objects that are equal return hash codes that are equal. However, the reverse is not true:
		equal hash codes do not imply object equality, because different (unequal) objects can have
		identical hash codes. Furthermore, the this Framework does not guarantee the default implementation
		of the `GetHashCode()` method, and the value this method returns may differ between Framework versions
		such as 32-bit and 64-bit platforms. For these reasons, do not use the default implementation of
		this method as a unique object identifier for hashing purposes.  
		
		Caution
		A hash code is intended for efficient insertion and lookup in collections that are
		based on a hash table. A hash code is not a permanent value. For this reason:
		* Do not serialize hash code values or store them in databases.
		* Do not use the hash code as the key to retrieve an object from a keyed collection.
		* Do not test for equality of hash codes to determine whether two objects are equal.
		  (Unequal objects can have identical hash codes.) To test for equality, 
		  call the MfObject.ReferenceEquals() or MfObject.Equals() method.
	Throws:
		Throws MfNullReferenceException if class is a not an instance.
*/
	GetHashCode() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		str := this.GetClassName()
		str .= ":" . this.Message
		strObj := new MfString(str)
		return strObj.GetHashcode()
		
	}
; End:GetHashCode() ;}
;{ 	ToString()
/*
	Method: ToString()
		Overrides MfObject.ToString()
	ToString()
		Creates and returns a string representation of the current MfException.
	Returns
		Returns A string representation of the current MfException.
	Throws
		Throws MfNullReferenceException is called on a non instance of class
*/
	ToString() {	
		;static strTab := "`t" 
		static TsCount := 0
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		msg := this.Message
		str := null
		Indent := ""
		HasInnerEx := false
		if (IsObject(this.m_InnerException) && (this.m_InnerException.is(MfException))) {
			HasInnerEx := true
		} 
		if (TsCount > 0) {
			padAmt := (TsCount * 3) + 1
			p := new MfParams(MfParams.S(">"),MfParams.I(padAmt),MfParams.C("-"))
			Indent := MfString.PadLeft(p)
			if (msg) {
				newMsg := ""
				nl := 
				loop, parse, msg,`n, `r
				{
					newMsg .= MfString.Format("{0}{1}{2}",MfEnvironment.Instance.NewLine, Indent, A_LoopField)
				}
				msg := newMsg
			}
		}
		
		
		if ((MfString.IsNulOrEmpty(msg))||(msg = Undefined)) {
			str := this.GetClassName()
		} else {
			str := MfString.Format("{0}: {1}",this.GetClassName(), msg)
		}
		;~ if (!MfString.IsNullOrEmpty(this.m_HelpLink)) {
			;~ str .= MfString.Format("`r`nHelpLink:{0}",this.m_HelpLink)
		;~ }
		
		;~ if (!MfString.IsNullOrEmpty(this.m_File)) {
			;~ str .= MfString.Format("`r`nFile:{0}",this.m_File)
		;~ }
		if (MfObject.IsObjInstance(this.m_Source, "MfString")) {
			if (!MfString.IsNullOrEmpty(this.m_Source.Value)) {
				str .= MfString.Format("{0}{1}Source:{2}", MfEnvironment.Instance.NewLine, InDent, this.m_Source.Value)
			}
		} else if (!IsObject(this.m_Source)) {
			if (!MfString.IsNullOrEmpty(this.m_Source)) {
				str .= MfString.Format("{0}{1}Source:{2}", MfEnvironment.Instance.NewLine, InDent, this.m_Source)
			}
		}
		
		
		if ((!A_IsCompiled) && (Mfunc.IsNumeric(this.m_Line)) && (this.m_Line > 0)) {
			str .= MfString.Format("{0}{1}Line:{2:i}",MfEnvironment.Instance.NewLine, InDent, this.m_Line)
		}
		if ((!A_IsCompiled) && (!MfString.IsNullOrEmpty(this.m_File))) {
			str .= MfString.Format("{0}{1}File:{2}", MfEnvironment.Instance.NewLine, InDent, this.m_File)
		}
		if (HasInnerEx) {
			TsCount ++
			padAmt := (TsCount * 3) + 1
			p := new MfParams(MfParams.S(">"),MfParams.I(padAmt),MfParams.C("-"))
			Indent := MfString.PadLeft(p)
			str := MfString.Format("{0}{1}{2}{3}", str, MfEnvironment.Instance.NewLine, Indent, this.m_InnerException.ToString())
			;str := StringReplace(str,"``r``n","``r``n" . Indent . str,"A")
			
		} else {
			TsCount := 0
		}
		return str
	}
; 	End:ToString() ;}
;{ 	SetProp
/*
	Method: SetProp()
		Helper method to set basic properties if MfException.
	
	instance.SetProp()
	instance.SetProp(file)
	instance.SetProp(file, line)
	instance.SetProp(file, line, source)
	
	SetProp()
		Sets File to MfString.Empty.
		Sets Line to 0.
		Sets Source to null.
	
	SetProp(file)
		Sets File to the value of file
		Line is unchanged.
		Source is unchanged.
	
	SetProp(file, line)
		Sets File to the value of file.
		Sets Line to the value of line.
		Source is unchanged.
	
	SetProp(file, line, source)
		Sets File to the value of file.
		Sets Line to the value of line.
		Sets Source to the value of source.
	
	Parameters
		file
			Sets the value of the File property. If Null value then File is set to MfString.Empty.
		line
			Sets the value of the Line property. If Null value then Line is set to 0;
		source
			Sets the value of the Source property. If Null Value then source is set to Null
	Throws
		Throws MfArgumentException if there is an error setting a Argument value to a Property
*/
	SetProp(args*) {
		p := this._SetPropParams(A_ThisFunc, args*)
		
		; if there are no parmas then set to default values
		if (p.count = 0)
		{
			this.m_File := MfString.Empty
			this.m_Line := 0
			this.Source := Null
			return
		}

		mfgP := p.ToStringList()
		if (mfgP.Item[0].Value = "MfString")
		{
			this.m_File := p.Item[0].Value
		}
		if (mfgP.Count > 1)
		{
			s := mfgP.Item[1].Value
		 	if (s = "MfInteger" || s = "MfInt64")
		 	{
		 		this.m_Line := p.Item[1].Value
		 	}
		}
		if (mfgP.Count > 2)
		{
			s := mfgP.Item[2].Value
		 	if (s = "MfString")
		 	{
		 		this.Source := p.Item[2].Value
		 	}
		 	else if (s != Undefined)
		 	{
		 		this.Source := p.Item[2]
		 	}
		}

	}
; 	End:SetProp ;}
; End:Methods ;}
;{ Internal methods
;{ 	_SetPropParams()
	; internal method.
	; gets parameters for SetProp()
	_SetPropParams(MethodName, args*) {
		; args: [MethodName, LineFile, LineNumber, Source]
		p := Null
		cnt := MfParams.GetArgCount(args*)
		if (MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			if (p.Count > 3)
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				ex.Source := MethodName
				ex.File := A_LineFile
				ex.Line := A_LineNumber
				throw ex
			}
		}
		else
		{
			p := new MfParams()
			p.AllowEmptyString := true ; allow empty strings to be compared
			p.AllowOnlyAhkObj := false
			p.AllowEmptyValue := true ; all empty/null params will be added as undefined
			
			if (cnt > 3)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.Source := MethodName
				e.File := A_LineFile
				e.Line := A_LineNumber
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
						if ((i = 2) && (MfNull.IsNull(arg) = false)) ; Integer A_LineNumber
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
					ex.Source := MethodName
					ex.File := A_LineFile
					ex.Line := A_LineNumber
					throw ex
				}

				i++
			}
			
		}
		return p
	}
; 	End:_SetPropParams() ;}
;{ 	IsValidException(e)
	; Internal Method
	; checks to see if given error is a valid exception
	IsValidException(e) {
		retval := false
		if (IsObject(e)) {
			if ((e.File) && (e.Line)) {
				retval := true
			}
		}
		return retval
	}
; End:IsValidException(e) ;}
;{ 	SetErrorCode(hr) - intended to be internal
	; sets internal HrResult
	SetErrorCode(hr) {
		try {
			this.m_HrResult := MfInteger.GetValue(hr)
		} catch e {
			this.m_HrResult := 0
		}
		
	}
; 	End:SetErrorCode(hr) ;}	
; End:Internal methods ;}
;{ Properties
;{ Data
/*
	Property: Data [get]
		Gets a collection of key/value pairs that provide additional user-defined information about the exception.
	Value:
		Instance of MfDictionary.
	Gets:
		Gets the Data value associated with the this instance as MfDictionary object.
	Remarks:
		Read-only Property
		Use the MfDictionary object returned by the Data property to store and retrieve supplementary information relevant to the exception.
		The information is in the form of an arbitrary number of user-defined key/value pairs.
		The key component of each key/value pair is typically an identifying string, whereas the value component of the pair can be any type of object. or var.
		
		Key/Value Pair Security
			The key/value pairs stored in the collection returned by the Data property are not secure.
			If your application calls a nested series of routines, and each routine contains exception handlers,
			the resulting call stack contains a hierarchy of those exception handlers.
			If a lower-level routine throws an exception, any upper-level exception handler in the call stack hierarchy can read and/or modify the
			key/value pairs stored in the collection by any other exception handler.
			This means you must guarantee that the information in the key/value pairs is not confidential and that your application will operate correctly
			if the information in the key/value pairs is corrupted.
		Key Conflicts
			A key conflict occurs when different exception handlers specify the same key to access a key/value pair.
			Use caution when developing your application because the consequence of a key conflict is that lower-level exception handlers can inadvertently
			communicate with higher-level exception handlers, and this communication might cause subtle program errors. However,
			if you are cautious you can use key conflicts to enhance your application.
		Avoiding Key Conflicts
			Avoid key conflicts by adopting a naming convention to generate unique keys for key/value pairs.
			For example, a naming convention might yield a key that consists of the period-delimited name of your application,
			the method that provides supplementary information for the pair, and a unique identifier.
			Suppose two applications, named Products and Suppliers, each has a method named Sales.
			The Sales method in the Products application provides the identification number (the stock keeping unit or SKU) of a product.
			The Sales method in the Suppliers application provides the identification number, or SID, of a supplier. Consequently,
			the naming convention for this example yields the keys, "Products.Sales.SKU" and "Suppliers.Sales.SID".
		Exploiting Key Conflicts
			Exploit key conflicts by using the presence of one or more special, prearranged keys to control processing.
			Suppose, in one scenario, the highest level exception handler in the call stack hierarchy catches all exceptions thrown by lower-level exception handlers.
			If a key/value pair with a special key exists, the high-level exception handler formats the remaining key/value pairs in the MfDictionary object in some
			nonstandard way; otherwise, the remaining key/value pairs are formatted in some normal manner.
			Now suppose, in another scenario, the exception handler at each level of the call stack hierarchy catches the exception thrown by the
			next lower-level exception handler.
			In addition, each exception handler knows the collection returned by the Data property contains a set of key/value pairs that can be accessed with a
			prearranged set of keys.
			Each exception handler uses the prearranged set of keys to update the value component of the corresponding key/value pair with information unique to
			that exception handler.
			After the update process is complete, the exception handler throws the exception to the next higher-level exception handler.
			Finally, the highest level exception handler accesses the key/value pairs and displays the consolidated update information
			from all the lower-level exception handlers.
*/
	Data[]
	{
		get {
			if (MfNull.IsNull(this.m_Data))
			{
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
; End:Data ;}
;{	File
/*
	Property: File [get/set]
		Gets or sets the File name the error occur in
	Value
		MfString or var containing string
	Gets
		Gets the File info related to the exception as string var.
	Sets
		Sets the File value of the exception.
*/
	File[]
	{
		get {
			return this.m_File
		}
		set {
			this.m_File := MfString.GetValue(value)
			return this.m_File
		}
	}
;	End:File ;}
;{	HelpLink
/*
	Property: HelpLink [get/set]
		Gets or sets a link to the help file associated with this exception.
	Value:
		MfString or var containing string
	Gets:
		Gets the help link info related to the exception as string var.
	Sets:
		Sets the help link value of the exception.
*/
	HelpLink[]
	{
		get {
			return this.m_HelpLink
		}
		set {
			this.m_HelpLink := MfString.GetValue(value)
			return this.m_HelpLink
		}
	}
;	End:HelpLink ;}
;{	HrResult
/*
	Property: HrResult [get/set]
		Gets or sets HRESULT, a coded numerical value that is assigned to a specific exception.
	Value:
		MfInteger or var containing integer.
	Gets:
		Gets the HRESULT Value related to the exception as integer var.
	Sets:
		Sets the HRESULT Value of the exception.
*/
	HrResult[]
	{
		get {
			return this.m_HrResult
		}
		set {
			this.m_HrResult := MfInteger.GetValue(value)
			return this.m_HrResult
		}
	}
;	End:HrResult ;}
;{	InnerException
/*
	Property: InnerException [get]
		Gets the MfException instance or derived exception that caused the current exception.
	Value:
		An MfException or derived exception
	Gets:
		A MfException based exception or null
	Remarks:
		Readonly Property
		Returns an instance of MfException based exception  that describes the error that caused the current exception.
		If a MfException or derived exception was passed into the constructor then that is what gets returned.
		However if an AutoHotkey Exception was passed into the constructor is converted into MfException.
		When it AutoHotkey Exception is passed in to the constructor InnerException will always return a MfException object.
		If no exception was passed into the constructor then InnerException will be null.
*/
	InnerException[]
	{
		get {
			return this.m_InnerException
		}
		set {
			ex := new Exception(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property", A_ThisFunc))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
	}
;	End:InnerException ;}
;{	Line
/*
	Property: Line [get/set]
		Gets or sets the Line the error occur on
	Value:
		MfInteger or var containing integer.
	Gets:
		Gets the Line Value related to the exception as integer var.
	Sets:
		Sets the Line Value of the exception.
	Remarks:
		The default value is 0
*/
	Line[]
	{
		get {
			return this.m_Line
		}
		set {
			this.m_Line := MfInteger.GetValue(value)
			return this.m_Line
		}
	}
;	End:Line ;}
;{	Message
/*!
	Property: Message [get]
		Gets a message that describes the current exception.
	Value:
		Var containing string
	Gets:
		Gets the error message that explains the reason for the exception, or an empty string
	Remarks:
		Read-only Property
	*/
	Message[]
	{
		get {
			if ((MfString.IsNullorEmpty(this.m_Message)) || (this.m_Message = "Undefined")) {
				if (MfString.IsNullorEmpty(this.m_ClassName)) {
					this.m_ClassName := this.GetClassName()
				}
				return MfString.Format(MfEnvironment.Instance.GetResourceString("Format_ExThrown"),this.m_ClassName)				
			}
			return this.m_Message
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
;	End:Message ;}
;{	Source
/*
	Property: Source [get/set]
		Gets or sets the name of the application or the object that causes the error.
	Value:
		Can be Object or Var
	Gets:
		Gets the name of the application or the object that causes the error.
	Sets:
		Sets the name of the application or the object that causes the error.
*/
	Source[]
	{
		get {
			return this.m_Source
		}
		set {
			if (MfObject.IsObjInstance(value, MfString)) {
				this.m_Source := value.Value
				return this.m_Source
			}
			this.m_Source := value
			return this.m_Source
		}
	}
;	End:Source ;}
; End:Properties;}
	; internal class
	class ExceptionMessageKind extends MfEnum
	{
		static m_Instance := ""

		__New(args*) {
			; Throws MfNotSupportedException if MfUnicodeCategory Sealed class is extended
			if (this.__Class != "MfException.ExceptionMessageKind") {
				throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfException.ExceptionMessageKind"))
			}
			base.__New(args*)
			this.m_isInherited := false
		}
	; End:Constructor ;}

		AddEnums() {
			this.AddEnumValue("ThreadAbort", 1)
			this.AddEnumValue("ThreadInterrupted", 2)
			this.AddEnumValue("OutOfMemory", 3)
		}

		DestroyInstance() {
			MfException.ExceptionMessageKind.m_Instance := Null
		}


		GetInstance() {
			if (MfNull.IsNull(MfException.ExceptionMessageKind.m_Instance)) {
				MfException.ExceptionMessageKind.m_Instance := new MfException.ExceptionMessageKind(1)
			}
			return MfException.ExceptionMessageKind.m_Instance
		}

		Is(ObjType) {
			typeName := MfType.TypeOfName(ObjType)
			if (typeName = "MfException.ExceptionMessageKind")
			{
				return true
			}
			return base.Is(ObjType)
		}

	; End:Methods ;}
	}
}
/*!
	End of class
*/