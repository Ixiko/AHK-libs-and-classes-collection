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
	Class: MfOutOfMemoryException
		Defines the base class for predefined exceptions
	Inherits:
		MfException
*/
;	End:Class comments ;}
class MfOutOfMemoryException extends MfSystemException
{
;{ Constructor
/*
	Method: Constructor()

	OutputVar := new MfOutOfMemoryException()
	OutputVar := new MfOutOfMemoryException(message)
	OutputVar := new MfOutOfMemoryException(message, innerException)

	Constructor()
		Initializes a new instance of the MfOutOfMemoryException class.
	Remarks:
		This constructor initializes the Message property of the new instance to a system-supplied message that describes the error,
		such as "As error has occurred."

	Constructor(message)
		Initializes a new instance of MfOutOfMemoryException class with a specified error message

	Constructor(message, innerException)
		Initializes a new instance of MfOutOfMemoryException class with a specified error message and a reference to the inner exception
		that is the cause of this exception.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
	Remarks:
		The content of the message parameter should be understandable to the user.
		The caller of this constructor is required to ensure that this string has been localized for the current system culture.
*/
	__New(message = "", innerException = "") {
		_msg := message
		if (MfString.IsNullOrEmpty(_msg)) {
			_msg := MfEnvironment.Instance.GetResourceString("InsufficientMemory_MemFailPoint")
		}
		base.__New(_msg, innerException)
		this.m_isInherited := this.__Class != "MfOutOfMemoryException"
		base.SetErrorCode(-2147024882)
	}
;	End:Constructor ;}
}
/*!
	End of class
*/