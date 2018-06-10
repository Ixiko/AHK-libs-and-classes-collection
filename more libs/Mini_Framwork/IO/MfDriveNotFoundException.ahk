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
	Method: Constructor()

	OutputVar := new MfDriveNotFoundException()
	OutputVar := new MfDriveNotFoundException(message)
	OutputVar := new MfDriveNotFoundException(message, innerException)

	Constructor()
		Initializes a new instance of the MfDriveNotFoundException class with its message string set to a
		system-supplied message and its HRESULT set to COR_E_DIRECTORYNOTFOUND.
	Remarks:
		This constructor initializes the Message property of the new instance to a system-supplied message
		that describes the error, such as "Could not find the specified directory."

	Constructor(message)
		Initializes a new instance of the MfDriveNotFoundException class with the specified message string
		and the HRESULT set to COR_E_DIRECTORYNOTFOUND.
	Remarks:
		This constructor initializes the Message property of the new instance using the message parameter.
		The InnerException property of the new instance is initialized to Nothing.

	Constructor(message, innerException)
		Initializes a new instance of the MfDriveNotFoundException class with the specified error message
		and a reference to the inner exception that is the cause of this exception.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string. MfString
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception
			is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
	Remarks:
		An exception that is thrown as a direct result of a previous exception should include a reference to
		the previous exception in the InnerException property. The InnerException property returns the same
		value that is passed into the constructor, or Null if the InnerException property does not supply
		the inner exception value to the constructor.
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
}
/*!
	End of class
*/