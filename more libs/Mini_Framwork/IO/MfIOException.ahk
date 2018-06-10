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
	Method: Constructor()

	OutputVar := new MfIOException()
	OutputVar := new MfIOException(message)
	OutputVar := new MfIOException(message, innerException)
	OutputVar := new MfIOException(message, hresult)

	Constructor()
		Initializes a new instance of the MfIOException class with its message string set to the empty
		string (""), its HRESULT set to COR_E_IO, and its inner exception set to a null reference.
	Remarks:
		The constructor initializes the Message property of the new instance to a system-supplied message
		that describes the error, such as "An I/O error occurred while performing the requested operation."

	Constructor(message)
		Initializes a new instance of the Message class with its message string set to message, its HRESULT
		set to COR_E_IO, and its inner exception set to null.
	Remarks:
		The constructor initializes the Message property of the new instance using message.

	Constructor(message, innerException)
		Initializes a new instance of the MfIOException class with a specified error message and a reference
		to the inner exception that is the cause of this exception.
	Remarks:
		An exception that is thrown as a direct result of a previous exception should include a reference to
		the previous exception in the InnerException property. The InnerException property returns the same
		value that is passed into the constructor, or Nothing if the InnerException property does not supply
		the inner exception value to the constructor.

	Constructor(message, hresult)

	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception
			is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
		hresult
			An integer identifying the error that has occurred.
			Can be MfInteger instance or var containing integer.
	Remarks:
		Initializes a new instance of the MfIOException class with its Message string set to message and its
		HRESULT user-defined.
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
}
/*!
	End of class
*/