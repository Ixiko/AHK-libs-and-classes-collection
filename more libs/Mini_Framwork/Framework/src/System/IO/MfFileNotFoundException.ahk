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
	Class: MfFileNotFoundException
		The exception that is thrown when an attempt to access a file that does not exist on disk fails.
	Inherits:
		MfIOException
*/
;	End:Class comments ;}
class MfFileNotFoundException extends MfIOException
{
	m_FileName := Null
;{ Constructor
/*
	OutputVar := new MfIO.FileNotFoundException()
	OutputVar := new MfIO.FileNotFoundException(message)
	OutputVar := new MfIO.FileNotFoundException(message, innerException)
	OutputVar := new MfIO.FileNotFoundException(message, fileName)
	OutputVar := new MfIO.FileNotFoundException(message, fileName, innerException)
*/
/*
	Method: Constructor()
		Initializes a new instance of the FileNotFoundException class with its message string set to a system-supplied message and
		its HRESULT set to COR_E_FILENOTFOUND.
		This constructor initializes the Message property of the new instance to a system-supplied message that describes the error,
		such as "Could not find the specified file."
*/
/*
	Method: Constructor(message)
		Initializes a new instance of the FileNotFoundException class with its Message string set to message and its HRESULT set to COR_E_FILENOTFOUND.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
	Remarks:
		This constructor initializes the Message property of the new instance using message.
*/
/*
	Method: Constructor(message, innerException)
		Initializes a new instance of the FileNotFoundException class with a specified error message and a reference to the inner
		exception that is the cause of this exception.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
	Remarks:
		An exception that is thrown as a direct result of a previous exception should include a reference to the previous
		exception in the InnerException property. The InnerException property returns the same value that is passed into the constructor,
		or Null if the InnerException property does not supply the inner exception value to the constructor.
*/
/*
	Method: Constructor(message, fileName)
		Initializes a new instance of the FileNotFoundException class with its Message string set to message,
		specifying the file name that cannot be found, and its HRESULT set to COR_E_FILENOTFOUND.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		fileName
			The full name of the file for the exception.
			Can be instance of MfString or var containing string.
	Remarks:
		The constructor initializes the Message property of the new instance using message and the FileName property using fileName.
*/
/*
	Method: Constructor(message, fileName, innerException)
		Initializes a new instance of the FileNotFoundException class with a specified error message,
		file name and a reference to the inner exception that is the cause of this exception.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
		fileName
			The full name of the file for the exception.
			Can be instance of MfString or var containing string.
	Remarks:
		An exception that is thrown as a direct result of a previous exception should include a reference to the previous exception in the InnerException property.
		The InnerException property returns the same value that is passed into the constructor, or Null if the InnerException property does not supply the
		inner exception value to the constructor.
*/
	__New(args*) {
		
		pCount := 0
		for i, param in args
		{
			pCount ++
		}
		if (pCount = 0) {
			base.__New(MfEnvironment.Instance.GetResourceString("IO.FileNotFound"))
			base.SetErrorCode(-2147024894)
		} else if (pCount = 1) { ; message
			; 1 is base message
			base.__New(args[1])
			base.SetErrorCode(-2147024894)
		} else if (pCount = 2) { ; message, inner exception or message, filename
			p2 := args[2]
			if ((IsObject(p2)) && (!MfObject.IsObjInstance(p2, "MfString"))) {
				base.__New(args[1], p2) ; Message , innerException
				base.SetErrorCode(-2147024894)
			} else {
				base.__New(args[1]) ; Message, errorCode
				base.SetErrorCode(-2147024894)
				this.m_FileName := MfString.GetValue(p2)
			}	
		} else if (pCount = 3) { ; message, fileName, innerException
			base.__New(args[1], args[3])
			base.SetErrorCode(-2147024894)
			this.m_FileName := MfString.GetValue(args[2])
		} else {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_isInherited := this.__Class != "MfFileNotFoundException"
	}
;	End:Constructor ;}
;{ overrides
;{ 	Is - Overrides MfIOException
/*
	Method: Is()
		Overrides IOException.Is()

	OutputVar := instance.Is(ObjType)

	Is(ObjType)
		Gets if current instance of FileNotFoundException is of the same type as ObjType or derived from ObjType.
	Parameters:
		ObjType
			The object or type to compare to this instance Type.
			ObjType can be an instance of MfType or an object derived from MfObject or an instance of or a string containing
			the name of the object type such as "MfObject"
	Returns:
		Returns true if current object instance is of the same Type as the ObjType or if current instance is derived from ObjType or
		if ObjType = "MfIO.FileNotFoundException" or ObjType = "MfFileNotFoundException" or if ObjType = "FileNotFoundException"; Otherwise false.
	Remarks:
		If a string is used as the Type case is ignored so "MfObject" is the same as "mfobject"
		Example
		ex := new MfIO.FileNotFoundException()
		MsgBox % ex.Is(MfIO.FileNotFoundException)   ; display 1 for true
		MsgBox % ex.Is("MfIO.FileNotFoundException") ; display 1 for true
		MsgBox % ex.Is("MFFileNotFoundException")    ; display 1 for true
		MsgBox % ex.Is("FileNotFoundException")      ; display 1 for true
		MsgBox % ex.Is(MfIO.IOException)             ; display 1 for true
		MsgBox % ex.Is(MfException)                  ; display 1 for true
		MsgBox % ex.Is(MfObject)                     ; display 1 for true
		MsgBox % ex.Is(MfString)                     ; display 0 for false
*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = "MfIO.FileNotFoundException")
		{
			return true
		}
		if (typeName = "FileNotFoundException")
		{
			return true
		}
		return base.Is(ObjType)
	}
; 	End:Is ;}
;{	ToString()
/*
	Method: ToString()
		Overrides MfIOException.ToString()
	ToString()
		Creates and returns a string representation of the current exception.
	Returns:
		Returns var containing string representation of the current exception.
	Throws:
		Throws MfNullReferenceException is called on a non instance of class
	Example:
		try
		{
			file := GetFile("C:/tmp/myfile.txt")
		}
		catch e
		{
			MsgBox, 16, File Error, % e.ToString()
		}
		; display a message box with the following message
		; FileNotFoundException: Unable to Locate File
		; File name: 'C:/tmp/myfile.txt'

		GetFile(file)
		{
			; ... some code to try and locate file
			ex := new MfIO.FileNotFoundException("Unable to Locate File", file)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
*/
	ToString() {	
		str := "FileNotFoundException: " . this.Message
		if (!MfString.IsNullOrEmpty(this.m_FileName)) {
			str .= MfEnvironment.Instance.NewLine
			str .= MfEnvironment.Instance.GetResourceString("IO.FileName_Name", this.m_FileName)
		}
		if (base.InnerException) {
			str .= " ---> " . base.InnerException.ToString()
		}
		return str
	}
;	End:ToString() ;}

; End:overrides ;}
;{ Properties
;{ 	FileName
/*
	Property: FileName [get]
		Gets the name of the file that cannot be found.
	Value:
		Var string
	Gets:
		Gets the name of the file, or Null if no file name was passed to the constructor for this instance.
	Remarks:
		This property is read-only and can only be set in the Constructor for the FileNotFoundException.
*/
	FileName[]
	{
		get {
			return this.m_FileName
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:FileName ;}
;{	Message
/*
	Property: Message [get]
		Gets a message that describes the current exception.
		Overrides MfException.Message
	Value:
		Var string
	Gets:
		Gets the Message Value related to the exception as string var.
	Remarks:
		Read-only Property
		Returns the error message that explains the reason for the exception, or an empty string.
*/
	Message[]
	{
		get {
			
			if (MfString.IsNullOrEmpty(this.m_Message) || (this.m_Message = Undefined)) {
				if ((MfString.IsNullOrEmpty(this.m_FileName)) && (this.HResult = -2146233088)) {
					this.m_Message := MfEnvironment.Instance.GetResourceString("IO.FileNotFound")
				}
					if (!MfString.IsNullOrEmpty(this.m_FileName)) {
					this.m_Message := MfEnvironment.Instance.GetResourceString("IO.FileName_Name", this.m_FileName)
				}
			}
			return this.m_Message
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
;	End:Message ;}
; End:Properties;}
}
/*!
	End of class
*/