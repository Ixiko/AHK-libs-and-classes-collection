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
	Class: MfOverflowException
		The exception that is thrown when an arithmetic, casting, or conversion operation in a checked context results in an overflow.
	Inherits:
		MfArithmeticException		
*/
class MfOverflowException extends MfArithmeticException
{
;{ Constructor: ()
/*
	Method: Constructor()
		Constructs new instance of MfOverflowException

	OutputVar := new MfOverflowException()
	OutputVar := new MfOverflowException(message)
	OutputVar := new MfOverflowException(message, innerException)

	Constructor()
		Initializes a new instance of the MfOverflowException class.
	Remarks:
		This constructor initializes the Message property of the new instance to a system-supplied message that describes the error,
		such as "Arithmetic operation resulted in an overflow."

	Constructor(message)
		Initializes a new instance of MfOverflowException class with a specified error message
	Remarks:
		The content of the message parameter should be understandable to the user.
		The caller of this constructor is required to ensure that this string has been localized for the current system culture.

	Constructor(message, innerException)
		Initializes a new instance of MfOverflowException class with a specified error message and a reference to the inner exception
		that is the cause of this exception.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
	Remarks:
		An exception that is thrown as a direct result of a previous exception can include a reference to the previous exception
		in the InnerException property. The InnerException property returns the same value that is passed into the constructor,
		or a null reference if the InnerException property does not supply the inner exception value to the constructor.
*/
	__New(message = "", innerException = "") {
		base.__New()
		_msg := message
		if (MfString.IsNullOrEmpty(_msg)) {
			_msg := MfEnvironment.Instance.GetResourceString("Arg_OverflowException")
		}
		base.__New(_msg, innerException)
		this.m_isInherited := this.__Class != "MfOverflowException"
		base.SetErrorCode(-2146233066)
	}
; End:Constructor: () ;}
}
/*!
	End of class
*/