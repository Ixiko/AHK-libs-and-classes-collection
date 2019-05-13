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
	Class: MfArgumentNullException
		The exception that is thrown when a null reference is passed to a method that does not accept it as a valid argument.
	Inherits: MfArgumentException
*/
;	End:Class comments ;}
class MfArgumentNullException extends MfArgumentException
{
	m_ParamName := MfString.Empty
;{ Constructor()
/*!
	Constructor()
		Constructs new instance of MfArgumentNullException

	OutputVar := new MfArgumentNullException()
	OutputVar := new MfArgumentNullException(paramName)
	OutputVar := new MfArgumentNullException(paramName, message)
	OutputVar := new MfArgumentNullException(message, innerException)

	Constructor()
		Initializes a new instance of the MfArgumentNullException class.
	Remarks
		This constructor initializes the Message property of the new instance to a system-supplied message that describes the error, such as "Value cannot be null."

	Constructor(paramName)
		Initializes a new instance of the MfArgumentNullException class with the name of the parameter that causes this exception.
	Remarks
		This constructor initializes the Message property of the new instance to a system-supplied message that describes the error and includes the parameter name.
		This constructor initializes the Message property of the new instance using the paramName parameter. The content of paramName is intended to be understood by humans.

	Constructor(paramName, message)
		Initializes an instance of the MfArgumentNullException class with a specified error message and the name of the parameter that causes this exception.
	Remarks
		This constructor initializes the Message property of the new instance using the value of the message parameter. The content of the message parameter is intended to be understood by humans. The caller of this constructor is required to ensure that this string has been localized for the current system culture.
		This constructor initializes the ParamName property of the new instance using the paramName parameter. The content of paramName is intended to be understood by humans.

	Constructor(message, innerException)
		Initializes a new instance of MfArgumentNullException class with a specified error message and a reference to the inner exception that is the cause of this exception.
	Remarks
		An exception that is thrown as a direct result of a previous exception can include a reference to the previous exception in the InnerException property. The InnerException property returns the same value that is passed into the constructor, or a null reference if the InnerException property does not supply the inner exception value to the constructor.

	Parameters
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
		paramName
			The name of the parameter that caused the exception.
			Can be instance of MfString or var containing string.
*/
	__New(args*) {
		; this.__Set := this.__Get
		pCount := 0
		for i, param in args
		{
			pCount ++
		}
		if (pCount = 0) {
			base.__New(MfEnvironment.Instance.GetResourceString("ArgumentNull_Generic"))
			
		} else if (pCount = 1) { ; paramName
			; 1 is base message
			base.__New(MfEnvironment.Instance.GetResourceString("ArgumentNull_Generic"), args[1])
		} else if (pCount = 2) { ; message, inner exception or  paramName, message,
			p2 := args[2]
			if ((IsObject(p2)) && (!MfObject.IsObjInstance(p2, "MfString"))) {
				base.__New(args[1], p2) ; Message , inner exception
			} else {
				;p2 = message
				; args[1] is paramname
				base.__New(p2, args[1]) ; base: message, parmName
			}	
		} else if (pCount > 2) {
			msg := MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload")
			ex := new MfNotSupportedException(MfString.Format(msg, A_ThisFunc))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			throw ex
		}
		this.m_isInherited := this.__Class != "MfArgumentNullException"
		base.SetErrorCode(-2147467261)
	}
; End:Constructor(args*) ;}
}
/*!
	End of class
*/