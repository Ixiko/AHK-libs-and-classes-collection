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
	Class: MfNonMfObjectException
		Exception thrown when not MfObject when MfObject was expected
	Inherits: 
		MfArgumentNullException
*/
;	End:Class comments ;}
class MfNonMfObjectException extends MfArgumentNullException
{
;{ Constructor
/*
	Method: Constructor()
		Constructs new instance of MfNonMfObjectException

	OutputVar := new MfNonMfObjectException()
	OutputVar := new MfNonMfObjectException(paramName)
	OutputVar := new MfNonMfObjectException(paramName, message)
	OutputVar := new MfNonMfObjectException(message, innerException)

	Constructor()
		Initializes a new instance of the MfNonMfObjectException class.
	Remarks:
		This constructor initializes the Message property of the new instance to a system-supplied message that describes the error,
		such as "Value cannot be null."

	Constructor(paramName)
		Initializes a new instance of the MfNonMfObjectException class with the name of the parameter that causes this exception.
	Remarks:
		This constructor initializes the Message property of the new instance to a system-supplied message that describes the error
		and includes the parameter name.
		This constructor initializes the Message property of the new instance using the paramName parameter.
		The content of paramName is intended to be understood by humans.

	Constructor(paramName, message)
		Initializes an instance of the MfNonMfObjectException class with a specified error message and the name of the parameter that causes this exception.
	Remarks:
		This constructor initializes the Message property of the new instance using the value of the message parameter.
		The content of the message parameter is intended to be understood by humans. The caller of this constructor is
		required to ensure that this string has been localized for the current system culture.
		This constructor initializes the ParamName property of the new instance using the paramName parameter.
		The content of paramName is intended to be understood by humans.

	Constructor(message, innerException)
		Initializes a new instance of MfNonMfObjectException class with a specified error message and a reference to the inner exception
		that is the cause of this exception.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
		paramName
			The name of the parameter that caused the exception.
			Can be instance of MfString or var containing string.
	Remarks:
		An exception that is thrown as a direct result of a previous exception can include a reference to the previous exception in the InnerException property. The InnerException property returns the same value that is passed into the constructor, or a null reference if the InnerException property does not supply the inner exception value to the constructor.
*/
	__New(args*) {
		pCount := 0
		for i, param in args
		{
			pCount ++
		}
		if (pCount = 0) {
			base.__New(MfEnvironment.Instance.GetResourceString("NonMfObjectException_General"))
			base.SetErrorCode(-141223732)
		} else if (pCount = 1) { ; paramName
			; 1 is base paramName
			base.__New(args[1], MfEnvironment.Instance.GetResourceString("NonMfObjectException_General"))
			base.SetErrorCode(-141223732)
		} else if (pCount = 2) { ; (paramName, message) or (message, innerException)
			p2 := args[2]
			base.__New(args[1], args[2]) ; Message , innerException
			base.SetErrorCode(-141223732)
		} else {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		this.m_isInherited := this.base.__Class != "MfNonMfObjectException"
	}
;	End:Constructor ;}
}
/*!
	End of class
*/