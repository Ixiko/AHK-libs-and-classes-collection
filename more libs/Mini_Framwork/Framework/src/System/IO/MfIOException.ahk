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
	Class: MfIOException
		The exception that is thrown when an I/O error occurs.
	Inherits: MfSystemException
	Remarks:
		MfIOException is the base class for exceptions thrown while accessing information using streams, files and directories.
*/
;	End:Class comments ;}
class MfIOException extends MfSystemException
{
	m_maybeFullPath := Null
;{ Constructor
/*
	OutputVar := new MfIO.IOException()
	OutputVar := new MfIO.IOException(message)
	OutputVar := new MfIO.IOException(message, innerException)
	OutputVar := new MfIO.IOException(message, hresult)
*/
/*
	Method: Constructor()
		Initializes a new instance of the IOException class with its message string set to the empty string (""),
		its HRESULT set to COR_E_IO, and its inner exception set to a null reference.
		The constructor initializes the Message property of the new instance to a system-supplied message that describes the error,
		such as "An I/O error occurred while performing the requested operation."
*/
/*
	Method: Constructor(message)
		Initializes a new instance of the Message class with its message string set to message, its HRESULT set to COR_E_IO, and its inner exception set to null.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
	Remarks:
		The constructor initializes the Message property of the new instance using message.
*/
/*
	Method: Constructor(message, innerException)
		Initializes a new instance of the IOException class with a specified error message and a reference to the inner exception that is the cause of this exception.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
	Remarks:
		An exception that is thrown as a direct result of a previous exception should include a reference to the previous exception
		in the InnerException property. The InnerException property returns the same value that is passed into the constructor,
		or Nothing if the InnerException property does not supply the inner exception value to the constructor.
*/
/*
	Method: Constructor(message, hresult)
		Initializes a new instance of the IOException class with its Message string set to message and its HRESULT user-defined.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		hresult
			An integer identifying the error that has occurred.
			Can be MfInteger instance or var containing integer.
*/
	__New(args*) {
		; this.__Set := this.__Get
		pCount := 0
		for i, param in args
		{
			pCount ++
		}
		if (pCount = 0) {
			base.__New(MfEnvironment.Instance.GetResourceString("Arg_IOException"))
			base.SetErrorCode(-2146232800)
		} else if (pCount = 1) { ; message
			; 1 is base message
			base.__New(args[1])
			base.SetErrorCode(-2146232800)
		} else if (pCount = 2) { ; message, inner exception or message, errorCode
			p2 := args[2]
			if (IsObject(p2)) {
				base.__New(args[1], p2) ; Message , innerException
				base.SetErrorCode(-2146232800)
			} else {
				base.__New(args[1]) ; Message, hresult
				base.SetErrorCode(args[2])
			}	
		}  else if (pCount = 3) {
			; message As String, hresult As Integer, maybeFullPath As String
			base.__New(args[1])
			base.SetErrorCode(args[2])
			this.m_maybeFullPath := MfString.GetValue(args[3])
		}
		this.m_isInherited := this.__Class != "MfIOException"
	}
;	End:Constructor ;}
;{ 	Is - Overrides MfObject
/*
	Method: Is()
		Overrides MfObject.Is().

	OutputVar := instance.Is(ObjType)

	Is(ObjType)
		Gets if current instance of IOException is of the same type as ObjType or derived from ObjType.
	Parameters:
		ObjType
			The object or type to compare to this instance Type.
			ObjType can be an instance of MfType or an object derived from MfObject or an instance of or a string containing the
			name of the object type such as "MfObject"
	Returns:
		Returns true if current object instance is of the same Type as the ObjType or if current instance is derived from ObjType or
		if ObjType = "MfIO.IOException" or ObjType = "IOException" or if ObjType = "MfIOException"; Otherwise false.
	Remarks:
		If a string is used as the Type case is ignored so "MfObject" is the same as "mfobject"
	Example:
		ex := new MfIO.IOException()
		MsgBox % ex.Is(MfIO.IOException)   ; display 1 for true
		MsgBox % ex.Is("MfIO.IOException") ; display 1 for true
		MsgBox % ex.Is("IOException")      ; display 1 for true
		MsgBox % ex.Is("MfIOException")    ; display 1 for true
		MsgBox % ex.Is(MfException)        ; display 1 for true
		MsgBox % ex.Is(MfObject)           ; display 1 for true
		MsgBox % ex.Is(MfString)           ; display 0 for false
*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = "MfIO.IOException")
		{
			return true
		}
		if (typeName = "IOException")
		{
			return true
		}
		return base.Is(ObjType)
	}
; 	End:Is ;}
}
/*!
	End of class
*/