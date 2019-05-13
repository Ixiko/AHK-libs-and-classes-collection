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
	Class: MfInvalidCastException
		The exception that is thrown for invalid casting or explicit conversion.
	Inherits:
		MfSystemException
*/
Class MfInvalidCastException extends MfSystemException
{

;{ Constructor()
/*
	Constructor()

	OutputVar := new MfInvalidCastException()
	OutputVar := new MfInvalidCastException(message)
	OutputVar := new MfInvalidCastException(message, innerException)
	OutputVar := new MfInvalidCastException(message, errorCode)
	
	Constructor()
		Initializes a new instance of the MfInvalidCastException class.
	Remarks
		This constructor initializes the Message property of the new instance to a system-supplied message that
		describes the error, such as "As error has occurred."
	
	Constructor(message)
		Initializes a new instance of MfInvalidCastException class with a specified error message
	Remarks
		The content of the message parameter should be understandable to the user.
		The caller of this constructor is required to ensure that this string has been localized for the current system culture.
	
	Constructor(message, innerException)
		Initializes a new instance of MfInvalidCastException class with a specified error message and a reference
		to the inner exception that is the cause of this exception.
	Remarks
		An exception that is thrown as a direct result of a previous exception can include a reference to the previous
		exception in the InnerException property.
		The InnerException property returns the same value that is passed into the constructor, or a null reference
		if the InnerException property does not supply the inner exception value to the constructor.
	
	Constructor(message, errorCode)
		Initializes a new instance of MfInvalidCastException class with a specified message and error code.
	Remarks
		This constructor initializes the Message property of the new MfInvalidCastException using the message parameter.
		The content of message is intended to be understood by humans. The caller of this constructor is required to
		ensure that this string has been localized for the current system culture.
		This constructor supplies an HRESULT value that is accessible to inheritors of the MfInvalidCastException class,
		via the protected HResult property of the MfInvalidCastException class.
	
	Parameters
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
		errorCode
			The error code (HRESULT) value associated with the exception.
			Can be instance of MfInteger or var containing integer.
*/
	__New(args*) {
		; this.__Set := this.__Get
		pCount := 0
		for i, param in args
		{
			pCount ++
		}
		if (pCount = 0) {
			base.__New(MfEnvironment.Instance.GetResourceString("Arg_InvalidCastException"))
			base.SetErrorCode(-2147467262)
		} else if (pCount = 1) { ; message
			; 1 is base message
			base.__New(args[1])
			base.SetErrorCode(-2147467262)
		} else if (pCount = 2) { ; message, inner exception or message, errorCode
			p2 := args[2]
			if ((IsObject(p2)) && (!MfObject.IsObjInstance(p2, "MfInteger"))) {
				base.__New(args[1], p2) ; Message , innerException
				base.SetErrorCode(-2147467262)
			} else {
				base.__New(args[1]) ; Message, errorCode
				base.SetErrorCode(args[2])
			}	
		}
		this.m_isInherited := this.__Class != "MfInvalidCastException"
	}
; End:Constructor(args*) ;}
}
/*!
	End of class
*/