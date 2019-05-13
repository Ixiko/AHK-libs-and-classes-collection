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
	Class: MfArgumentOutOfRangeException
		The exception that is thrown when the value of an argument is outside the allowable range of values as defined by the invoked method.
	Inherits: MfArgumentException
*/
;	End:Class comments ;}
class MfArgumentOutOfRangeException extends MfArgumentException
{
	m_ParamName := MfString.Empty
	m_ActualValue := null
/*!
	Constructor()

	OutputVar := new MfArgumentOutOfRangeException()
	OutputVar := new MfArgumentOutOfRangeException(paramName)
	OutputVar := new MfArgumentOutOfRangeException(paramName, message)
	OutputVar := new MfArgumentOutOfRangeException(message, innerException)

	Constructor()
		Initializes a new instance of the MfArgumentOutOfRangeException class.
	Remarks
		This constructor initializes the Message property of the new instance to a system-supplied message that describes the error, such as "Nonnegative number required."

	Constructor(paramName)
		Initializes a new instance of MfArgumentOutOfRangeException class with the name of the parameter that causes this exception.
	Remarks
		This constructor initializes the ParamName property of the new instance using the paramName parameter. The content of paramName is intended to be understood by humans.

	Constructor(message, innerException)
		Initializes a new instance of MfArgumentOutOfRangeException class with a specified error message and a reference to the inner exception that is the cause of this exception.
	Remarks
		An exception that is thrown as a direct result of a previous exception can include a reference to the previous exception in the InnerException property. The InnerException property returns the same value that is passed into the constructor, or a null reference if the InnerException property does not supply the inner exception value to the constructor.

	Constructor(paramName, message)
		Initializes a new instance of MfArgumentOutOfRangeException class with the name of the parameter that causes this exception and a specified error message.
	Remarks
		This constructor initializes the Message property of the new instance using the value of the message parameter. The content of the message parameter is intended to be understood by humans. The caller of this constructor is required to ensure that this string has been localized for the current system culture.
		This constructor initializes the ParamName property of the new instance using the paramName parameter. The content of paramName is intended to be understood by humans.

	Constructor(message, innerException)
		Initializes a new instance of MfArgumentOutOfRangeException class with a specified error message and a reference to the inner exception that is the cause of this exception.
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
			The name of the parameter that causes this exception.
*/
	__New(args*) {
		; this.__Set := this.__Get
		pCount := 0
		for i, param in args
		{
			pCount ++
		}
		if (pCount = 0) {
			base.__New(MfArgumentOutOfRangeException._RangeMessage)
			
		} else if (pCount = 1) { ; paramName
			; 1 is base message
			base.__New(MfArgumentOutOfRangeException._RangeMessage, args[1])
		} else if (pCount = 2) { ; message, inner exception or  paramName, message,
			p2 := args[2]
			if ((IsObject(p2)) && (!MfObject.IsObjInstance(p2, "MfString"))) {
				base.__New(args[1], p2) ; Message , inner exception
			} else {
				;p2 = message
				; args[1] is paramname
				base.__New(p2, args[1]) ; base: message, parmName
			}	
		} else if(pCount = 3) { ;paramName, actualValue, message
			base.__New(args[3],args[1]) ; base: message, parmName
			this.m_ActualValue := args[2] ; can be Object
		} else if (pCount > 3) {
			msg := MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload")
			ex := new MfNotSupportedException(MfString.Format(msg, A_ThisFunc))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			throw ex
		}
		this.m_isInherited := this.__Class != "MfArgumentOutOfRangeException"
		base.SetErrorCode(-2146233086)
	}
; End:Constructor(args*) ;}
;{ Properties

;{	Message
	/*!
		Property: Message [get]
			Gets the error message and the string representation of the invalid argument value,
			or only the error message if the argument value is null.
			Overrides MfArgumentException.Message
		Remarks:
			The error message should describe the expected values of the parameter that causes this exception.
			The error message should be localized. 
			This property is read-only.
	*/
	Message[]
	{
		get {
			_message := base.Message
			if (!this.m_actualValue)
			{
				return _message
			}
			_objMsg := null
			if (IsObject(this.m_actualValue)) {
				if (((IsFunc(this.m_actualValue.Is)) || (IsFunc(this.m_actualValue.base.Is))) && (this.m_actualValue.Is(MfObject))) {
					if (this.m_actualValue.IsInstance()) {
						_objMsg := this.m_actualValue.ToString()
					} else {
						_RS := MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param")
						_objMsg := MfString.Format(_RS, new MfType(this.m_actualValue))
					}
					
				} else {
					_objMsg := MfEnvironment.Instance.GetResourceString("Format_Object") ; Object
				}
			} else {
				_objMsg := this.m_actualValue
			}
			_RS := MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_ActualValue")
			_objMsg := MfString.Format(_RS, _objMsg)
			if (MfString.IsNullOrEmpty(_message))
			{
				return _objMsg
			}
			return MfString.Format("{0}{1}{2}", _message, MfEnvironment.Instance.NewLine, _objMsg)
		}
		set {
			throw Exception(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property", A_ThisFunc))
		}
	}
;	End:Message ;}
;{ 	_RangeMessage
	/*
		Property: _RangeMessage [get]
			Private Shared Property 
		Value:
			Returns value from Resource
		Remarks:
			This property is read-only.
	*/
	m_RangeMessage		:= Null
	_RangeMessage[]
	{
		get {
			if (MfString.IsNullOrEmpty(MfArgumentOutOfRangeException.m_RangeMessage)) {
				MfArgumentOutOfRangeException.m_RangeMessage := MfEnvironment.Instance.GetResourceString("Arg_ArgumentOutOfRangeException")
			}
			return MfArgumentOutOfRangeException.m_RangeMessage
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; 	End:_RangeMessage ;}
; End:Properties;}
}
/*!
	End of class
*/