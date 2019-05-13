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
	Class: MfDriveNotFoundException
		The exception that is thrown when trying to access a drive or share that is not available.
	Inherits:
		MfIOException
*/
;	End:Class comments ;}
class MfDriveNotFoundException extends MfIOException
{
;{ Constructor
/*
	OutputVar := new MfIO.DriveNotFoundException()
	OutputVar := new MfIO.DriveNotFoundException(message)
	OutputVar := new MfIO.DriveNotFoundException(message, innerException)
*/
/*
	Method: Constructor()
		Initializes a new instance of the DriveNotFoundException class with its message string set to a system-supplied message and
		its HRESULT set to COR_E_DIRECTORYNOTFOUND.
		This constructor initializes the Message property of the new instance to a system-supplied message that describes the error,
		such as "Could not find the specified directory."
*/
/*
	Method: Constructor(message)
		Initializes a new instance of the DriveNotFoundException class with the specified message string and the HRESULT set to COR_E_DIRECTORYNOTFOUND.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string. MfString
	Remarks:
		This constructor initializes the Message property of the new instance using the message parameter.
		The InnerException property of the new instance is initialized to Nothing.
*/
/*
	Method: Constructor(message)
		Initializes a new instance of the DriveNotFoundException class with the specified message string and the HRESULT set to COR_E_DIRECTORYNOTFOUND.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string. MfString
	Remarks:
		This constructor initializes the Message property of the new instance using the message parameter.
		The InnerException property of the new instance is initialized to Nothing.
*/
/*
	Method: Constructor(message, innerException)
		Initializes a new instance of the DriveNotFoundException class with the specified error message and
		a reference to the inner exception that is the cause of this exception.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string. MfString
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
	Remarks:
		An exception that is thrown as a direct result of a previous exception should include a reference to the previous exception
		in the InnerException property. The InnerException property returns the same value that is passed into the constructor,
		or Null if the InnerException property does not supply the inner exception value to the constructor.
*/
	__New(args*) {
		; this.__Set := this.__Get
		pCount := 0
		for i, param in args
		{
			pCount ++
		}
		if (pCount = 0) {
			base.__New(MfEnvironment.Instance.GetResourceString("Arg_DriveNotFoundException"))
			base.SetErrorCode(-2147024893)
		} else if (pCount = 1) { ; message
			; 1 is base message
			base.__New(args[1])
			base.SetErrorCode(-2147024893)
		} else if (pCount = 2) { ; message, inner exception or message, errorCode
			base.__New(args[1], args[2]) ; Message , innerException
			base.SetErrorCode(-2147024893)
		}
		this.m_isInherited := this.__Class != "MfDriveNotFoundException"
	}
;	End:Constructor ;}
;{ 	Is - Overrides MfIOException
/*
	Method: Is()
		Overrides IOException.Is()

	OutputVar := instance.Is(ObjType)

	Is(ObjType)
		Gets if current instance of DriveNotFoundException is of the same type as ObjType or derived from ObjType.
	Parameters:
		ObjType
			The object or type to compare to this instance Type.
			ObjType can be an instance of MfType or an object derived from MfObject or an instance of or a string containing the name of
			the object type such as "MfObject"
	Returns:
		Returns true if current object instance is of the same Type as the ObjType or if current instance is derived from
		ObjType or if ObjType = "MfIO.DriveNotFoundException" or ObjType = "MfDriveNotFoundException" or if ObjType = "DriveNotFoundException"; Otherwise false.
	Remarks:
		If a string is used as the Type case is ignored so "MfObject" is the same as "mfobject"
	Example:
		ex := new MfIO.DriveNotFoundException()
		MsgBox % ex.Is(MfIO.DriveNotFoundException)   ; display 1 for true
		MsgBox % ex.Is("MfIO.DriveNotFoundException") ; display 1 for true
		MsgBox % ex.Is("MfDriveNotFoundException")    ; display 1 for true
		MsgBox % ex.Is("DriveNotFoundException")      ; display 1 for true
		MsgBox % ex.Is(MfIO.IOException)              ; display 1 for true
		MsgBox % ex.Is(MfException)                   ; display 1 for true
		MsgBox % ex.Is(MfObject)                      ; display 1 for true
		MsgBox % ex.Is(MfString)                      ; display 0 for false
*/
	Is(ObjType) {
		typeName := MfType.TypeOfName(ObjType)
		if (typeName = "MfIO.DriveNotFoundException")
		{
			return true
		}
		if (typeName = "DriveNotFoundException")
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