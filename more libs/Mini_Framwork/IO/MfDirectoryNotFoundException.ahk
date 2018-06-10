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
	Class: MfDirectoryNotFoundException
		The exception that is thrown when part of a file or directory cannot be found.
	Inherits:
		MfIOException
*/
;	End:Class comments ;}
class MfDirectoryNotFoundException extends MfIOException
{
;{ Constructor
/*
	Method: Constructor()

	OutputVar := new MfDirectoryNotFoundException()
	OutputVar := new MfDirectoryNotFoundException(message)
	OutputVar := new MfDirectoryNotFoundException(message, innerException)

	Constructor()
		Initializes a new instance of the MfDirectoryNotFoundException class with its message string set to
		a system-supplied message and its HRESULT set to COR_E_DIRECTORYNOTFOUND.
	Remarks:
		This constructor initializes the Message property of the new instance to a system-supplied message
		that describes the error, such as "Could not find the specified directory."
		The InnerException property of the new instance is initialized to Null.

	Constructor(message)
		Initializes a new instance of the MfDirectoryNotFoundException class with its message string set to
		message and its HRESULT set to COR_E_DIRECTORYNOTFOUND.
	Remarks:
		This constructor initializes the Message property of the new instance using message.
		The Exception.InnerException property of the new instance is initialized to Nothing.

	Constructor(message, innerException)
		Initializes a new instance of the MfDirectoryNotFoundException class with a specified error message
		and a reference to the inner exception that is the cause of this exception.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
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
			base.__New(MfEnvironment.Instance.GetResourceString("Arg_DirectoryNotFoundException"))
			base.SetErrorCode(-141220925)
		} else if (pCount = 1) { ; message
			; 1 is base message
			base.__New(args[1])
			base.SetErrorCode(-1412209252)
		} else if (pCount = 2) { ; message, inner exception or message, errorCode
			p2 := args[2]
			if ((IsObject(p2)) && (!MfObject.IsObjInstance(p2, "MfString"))) {
				base.__New(args[1],p2) ; Message , innerException
				base.SetErrorCode(-141220925)
			} else {
				base.__New(args[1]) ; Message, errorCode
				base.SetErrorCode(args[2])
			}	
		}
		this.m_isInherited := this.__Class != "MfDirectoryNotFoundException"
	}
;	End:Constructor ;}
}
/*!
	End of class
*/