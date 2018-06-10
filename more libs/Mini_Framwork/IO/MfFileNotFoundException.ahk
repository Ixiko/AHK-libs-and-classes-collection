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
	Class: MfFileNotFoundException
		The exception that is thrown when an attempt to access a file that does not exist on disk fails.
	Inherits:
		MfIOException
*/
;	End:Class comments ;}
class MfFileNotFoundException extends MfIOException
{
	m_FileName := Null
;{ Constructor
/*
	Method: Constructor()

	OutputVar := new MfFileNotFoundException()
	OutputVar := new MfFileNotFoundException(message)
	OutputVar := new MfFileNotFoundException(message, innerException)
	OutputVar := new MfFileNotFoundException(message, fileName)
	OutputVar := new MfFileNotFoundException(message, fileName, innerException)

	Constructor()
		Initializes a new instance of the MfFileNotFoundException class with its message string set to a
		system-supplied message and its HRESULT set to COR_E_FILENOTFOUND.
	Remarks:
		This constructor initializes the Message property of the new instance to a system-supplied message
		that describes the error, such as "Could not find the specified file."

	Constructor(message)
		Initializes a new instance of the MfFileNotFoundException class with its Message string set to
		message and its HRESULT set to COR_E_FILENOTFOUND.
	Remarks:
		This constructor initializes the Message property of the new instance using message.

	Constructor(message, innerException)
		Initializes a new instance of the MfFileNotFoundException class with a specified error message and a
		reference to the inner exception that is the cause of this exception.
	Remarks:
		An exception that is thrown as a direct result of a previous exception should include a reference to
		the previous exception in the InnerException property. The InnerException property returns the same
		value that is passed into the constructor, or Null if the InnerException property does not supply
		the inner exception value to the constructor.

	Constructor(message, fileName)
		Initializes a new instance of the MfFileNotFoundException class with its Message string set to
		message, specifying the file name that cannot be found, and its HRESULT set to COR_E_FILENOTFOUND.
	Remarks:
		The constructor initializes the Message property of the new instance using message and the FileName
		property using fileName.

	Constructor(message, fileName, innerException)
		Initializes a new instance of the MfFileNotFoundException class with a specified error message and a
		reference to the inner exception that is the cause of this exception.
	Parameters:
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception
			is specified.
		fileName
			The full name of the file for the exception.
			Can be instance of MfString or var containing string.
	Remarks:
		An exception that is thrown as a direct result of a previous exception should include a reference to
		the previous exception in the InnerException property. The InnerException property returns the same
		value that is passed into the constructor, or Null if the InnerException property does not supply
		the inner exception value to the constructor.
*/
	__New(args*) {
		
		pCount := 0
		for i, param in args
		{
			pCount ++
		}
		if (pCount = 0) {
			base.__New(MfEnvironment.Instance.GetResourceString("IO.FileNotFound"))
			base.SetErrorCode(-2147024894)
		} else if (pCount = 1) { ; message
			; 1 is base message
			base.__New(args[1])
			base.SetErrorCode(-2147024894)
		} else if (pCount = 2) { ; message, inner exception or message, filename
			p2 := args[2]
			if ((IsObject(p2)) && (!MfObject.IsObjInstance(p2, "MfString"))) {
				base.__New(args[1], p2) ; Message , innerException
				base.SetErrorCode(-2147024894)
			} else {
				base.__New(args[1]) ; Message, errorCode
				base.SetErrorCode(-2147024894)
				this.m_FileName := MfString.GetValue(p2)
			}	
		} else if (pCount = 3) { ; message, fileName, innerException
			base.__New(args[1], args[3])
			base.SetErrorCode(-2147024894)
			this.m_FileName := MfString.GetValue(args[2])
		} else {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		this.m_isInherited := this.__Class != "MfFileNotFoundException"
	}
;	End:Constructor ;}
;{ overrides
;{	ToString()
/*
	Method: ToString()
		Overrides MfIOException.ToString()
	ToString()
		Creates and returns a string representation of the current exception.
	Returns:
		Returns var containing string representation of the current exception.
	Throws:
		Throws MfNullReferenceException is called on a non instance of class
*/
	ToString() {	
		str := this.__Class . ": " . this.Message
		if (!MfString.IsNullOrEmpty(this.m_FileName)) {
			str .= MfEnvironment.Instance.NewLine
			str .= MfEnvironment.Instance.GetResourceString("IO.FileName_Name", this.m_FileName)
		}
		if (base.InnerException) {
			str .= " ---> " . base.InnerException.ToString()
		}
		return str
	}
;	End:ToString() ;}

; End:overrides ;}
;{ Properties
;{ 	FileName
/*
	Property: FileName [get]
		Gets the name of the file that cannot be found.
	Value:
		Var string
	Gets:
		Gets the name of the file, or Null if no file name was passed to the constructor for this instance.
	Remarks:
		This property is read-only and can only be set in the Constructor for the MfFileNotFoundException.
*/
	FileName[]
	{
		get {
			return this.m_FileName
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; 	End:FileName ;}
;{	Message
/*
	Property: Message [get]
		Gets a message that describes the current exception.
		Overrides MfException.Message
	Value:
		Var string
	Gets:
		Gets the Message Value related to the exception as string var.
	Remarks:
		Read-only Property
		Returns the error message that explains the reason for the exception, or an empty string.
*/
	Message[]
	{
		get {
			
			if (MfString.IsNullOrEmpty(this.m_Message) || (this.m_Message = Undefined)) {
				SetFormat, Integer, D
				if ((MfString.IsNullOrEmpty(this.m_FileName)) && (this.HResult = -2146233088)) {
					this.m_Message := MfEnvironment.Instance.GetResourceString("IO.FileNotFound")
				}
					if (!MfString.IsNullOrEmpty(this.m_FileName)) {
					this.m_Message := MfEnvironment.Instance.GetResourceString("IO.FileName_Name", this.m_FileName)
				}
			}
			return this.m_Message
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property", A_ThisFunc))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
	}
;	End:Message ;}
; End:Properties;}
}
/*!
	End of class
*/