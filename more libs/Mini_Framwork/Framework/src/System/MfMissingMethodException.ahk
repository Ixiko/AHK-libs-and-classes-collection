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
	Class: MfMissingMethodException
		The exception that is thrown when there is an attempt to dynamically access a method that does not exist.
	Inherits:
		MfMissingMemberException
*/
;	End:Class comments ;}
class MfMissingMethodException extends MfMissingMemberException
{

;{ Constructor()
/*
	Constructor()
	
	OutputVar := new MfMissingMethodException()
	OutputVar := new MfMissingMethodException(message)
	OutputVar := new MfMissingMethodException(message, innerException)
	OutputVar := new MfMissingMethodException(className, memberName)
	
	Constructor()
		Initializes a new instance of the MfMissingMethodException class.
	Remarks
		This constructor initializes the Message property of the new instance to a system-supplied message that describes the error, such as "As error has occurred."
	
	Constructor(message)
		Initializes a new instance of MfMissingMethodException class with a specified error message
	Remarks
		The content of the message parameter should be understandable to the user. The caller of this constructor is required to ensure that this string has been localized for the current system culture.
	
	Constructor(message, innerException)
		Initializes a new instance of MfMissingMethodException class with a specified error message and a reference to the inner exception that is the cause of this exception.
	Remarks
		An exception that is thrown as a direct result of a previous exception can include a reference to the previous exception in the InnerException property. The InnerException property returns the same value that is passed into the constructor, or a null reference if the InnerException property does not supply the inner exception value to the constructor.
	
	Constructor(className, memberName)
		Initializes a new instance of MfMissingMethodException class with the specified class name and member name.
	
	Parameters
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
		className
			The name of the class in which access to a nonexistent member was attempted. Can be instance of MfString or var containing string.
		memberName
			The name of the member that cannot be accessed.
			Can be instance of MfString or var containing string.
*/
	__New(args*) {
		base.__New(args*)
		this.m_isInherited := this.__Class != "MfMissingMethodException"
		base.SetErrorCode(-2146233069)
	}
; End:Constructor() ;}	
}
/*!
	End of class
*/