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
	Class: MfArgumentException
		The exception that is thrown when one of the arguments provided to a method is not valid.
	Inherits: MfSystemException
	Example:
*/
;	End:Class comments ;}
Class MfArgumentException extends MfSystemException
{
	m_ParamName := MfString.Empty
;{ Constructor()
/*!
	Constructor()
		Constructors new instance of MfArgumentException

	OutputVar := new MfArgumentException()
	OutputVar := new MfArgumentException(message)
	OutputVar := new MfArgumentException(message, innerException)
	OutputVar := new MfArgumentException(message, paramName)

	Constructor()
		Initializes a new instance of the MfArgumentException class.
	Remarks
		This constructor initializes the Message property of the new instance to a system-supplied message that describes the error, such as "An invalid argument was specified."

	
	Constructor(message)
		Initializes a new instance of MfArgumentException class with a specified error message
	Remarks
		The content of the message parameter should be understandable to the user. The caller of this constructor is required to ensure that this string has been localized for the current system culture.

	
	Constructor(message, innerException)
		Initializes a new instance of MfArgumentException class with a specified error message and a reference to the inner exception that is the cause of this exception.
	Remarks
		An exception that is thrown as a direct result of a previous exception can include a reference to the previous exception in the InnerException property. The InnerException property returns the same value that is passed into the constructor, or a null reference if the InnerException property does not supply the inner exception value to the constructor.

	
	Constructor(message, paramName)
		Initializes a new instance of the MfArgumentException class with a specified error message, the parameter name, and a reference to the inner exception that is the cause of this exception.
	Remarks
		This constructor initializes the Message property of the new instance using the value of the message parameter. The content of the message parameter is intended to be understood by humans. The caller of this constructor is required to ensure that this string has been localized for the current system culture.
		This constructor initializes the ParamName property of the new instance using paramName. The content of paramName is intended to be understood by humans.
		An exception that is thrown as a direct result of a previous exception can include a reference to the previous exception in the InnerException property. The InnerException property returns the same value that is passed into the constructor, or a null reference if the InnerException property does not supply the inner exception value to the constructor.

	Parameters
		message
			The error message that explains the reason for the exception. Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
	paramName
		The name of the parameter that caused the exception.
		Can be instance of MfString or var containing string.
*/
	__New(args*) {
		pCount := 0
		for i, param in args
		{
			pCount ++
		}
		if (pCount = 0) {
			base.__New(MfEnvironment.Instance.GetResourceString("Arg_ArgumentException"))
			
		} else if (pCount = 1) { ; message
			; 1 is base message
			base.__New(args[1])
		} else if (pCount = 2) { ; message, inner exception or message, param name
			p2 := args[2]
			if ((IsObject(p2)) && (!MfObject.IsObjInstance(p2, "MfString"))) {
				base.__New(args[1],p2) ; Message , innerException
			} else {
				base.__New(args[1]) ; Message, parmName
				this.m_paramName := MfString.GetValue(p2)
			}	
		} else if (pCount = 3) { ; message, paramName, innerException
			base.__New(args[1],args[3]) ; Message , innerException
			this.m_paramName := MfString.GetValue(args[2])
		}
		this.m_isInherited := this.__Class != "MfArgumentException"
		if (pCount > 3) {
			msg := MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload")
			ex := new MfNotSupportedException(MfString.Format(msg, A_ThisFunc))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			throw ex
		}
		base.SetErrorCode(-2147024809)
		;this.is    := Func("MfArgumentException.Default_is")
	}
; End:Constructor(args*) ;}
;{ Properties
;{	Message
;{ 	Start:Message Property Comment
/*
	Property: Message [get]
		Overrides MfException.Message
		Gets the error message and the parameter name, or only the error message if no parameter name is set.
	Remarks:
		A text string describing the details of the exception. 
		The value of this property takes one of two forms: Condition Value The paramName is null.
		The message string passed to the constructor. paramName is not null and it has a length greater than zero. The message string appended with the name of the invalid parameter.
		Property is read-only.
*/
; 	End:Message Property Ccomment ;}
	Message[]
	{
		get {
			_message := base.Message
			if (!MfString.IsNullOrEmpty(this.m_paramName))
			{
				_NL := MfEnvironment.Instance.NewLine
				_RS := MfEnvironment.Instance.GetResourceString("Format_ParmName")
				return MfString.Format(_RS, _message, _NL, this.m_paramName)
			}
			return _message
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
;{	ParamName
;{ 	Start:ParamName Property Comment
/*
	Property: ParamName [get]
		Gets the name of the parameter that causes this exception.
	Value:
		MfString or var containing string
	Get:
		Gets the  parameter name Value related to the exception as string var.
	Remarks:
		Readonly property
		The ParameterName is set in the constructor().
*/
; 	End:ParamName Property Ccomment ;}
	ParamName[]
	{
		get {
			return this.m_ParamName
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property", A_ThisFunc))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
	}
;	End:ParamName ;}
; End:Properties ;}
}
/*!
	End of class
*/