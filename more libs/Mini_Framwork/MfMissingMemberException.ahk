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
	Class: MfMissingMemberException
		The exception that is thrown when there is an attempt to dynamically access a class member that does not exist.
	Inherits:
		MfMemberAccessException
*/
;	End:Class comments ;}
class MfMissingMemberException extends MfMemberAccessException
{

	m_ClassName := ""
	m_MemberName := ""
;{ Constructor()
/*
	Constructor()

	OutputVar := new MfMissingMemberException()
	OutputVar := new MfMissingMemberException(message)
	OutputVar := new MfMissingMemberException(message, innerException)
	OutputVar := new MfMissingMemberException(className, memberName)
	
	Constructor()
		Initializes a new instance of the MfMissingMemberException class.
	Remarks
		This constructor initializes the Message property of the new instance to a system-supplied message that
		describes the error, such as "As error has occurred."
	
	Constructor(message)
		Initializes a new instance of MfMissingMemberException class with a specified error message
	Remarks
		The content of the message parameter should be understandable to the user. The caller of this constructor
		is required to ensure that this string has been localized for the current system culture.
	
	Constructor(message, innerException)
		Initializes a new instance of MfMissingMemberException class with a specified error message and a reference
		to the inner exception that is the cause of this exception.
	Remarks
		
		An exception that is thrown as a direct result of a previous exception can include a reference to the previous
		exception in the InnerException property.
		The InnerException property returns the same value that is passed into the constructor, or a null reference
		if the InnerException property does not supply the inner exception value to the constructor.
	Constructor(className, memberName)
		Initializes a new instance of MfMissingMemberException class with the specified class name and member name.
	
	Parameters
		message
			The error message that explains the reason for the exception.
			Can be instance of MfString or var containing string.
		innerException
			The exception that is the cause of the current exception, or a null reference if no inner exception is specified.
			Can be AutoHotkey Exception or any MfException instance or derived class instance.
		className
			The name of the class in which access to a nonexistent member was attempted.
			Can be instance of MfString or var containing string.
		fieldName 
			The name of the field that cannot be accessed.
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
			base.__New(MfEnvironment.Instance.GetResourceString("Arg_MissingMemberException"))
		} else if (pCount = 1) { ; message
			; 1 is base message
			base.__New(args[1])
		} else if (pCount = 2) { ; message, inner exception or message, param name
			p2 := args[2]
			if ((IsObject(p2)) && (!MfObject.IsObjInstance(p2, "MfString"))) {
				base.__New(args[1],p2) ; Message , inner exception
			} else { ; className, memberName
				base.__New()
				this.m_ClassName := MfString.GetValue(args[1])
				this.m_MemberName := MfString.GetValue(args[2])
			}	
		} else if (pCount = 3) { ; message inner exception, param
			base.__New(args[1],args[2]) ; Message , inner exception
			this.m_paramName := MfString.GetValue(args[3])
			base.SetErrorCode(-2147024809)
		} else if (pCount > 3) {
			msg := MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload")
			ex := new MfNotSupportedException(MfString.Format(msg, A_ThisFunc))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			throw ex
		}
		this.m_isInherited := this.__Class != "MfMissingMemberException"
		base.SetErrorCode(-2146233070)
	}
; End:Constructor() ;}

;{ Properties
;{	ClassName
/*
	Property: ClassName [get\set]
		Gets or sets the class name.
	Value:
		Can be MfString or var containing string.
	Gets:
		Gets the value of the ClassName as string var
	Sets:
		Sets the value of the ClassName.
	Remarks:
		Returns the class name of the missing member as a var containing string.
*/
	ClassName[]
	{
		get {
			return this.m_ClassName
		}
		set {
			this.m_ClassName := MfString.GetValue(value)
			return this.m_ClassName
		}
	}
;	End:ClassName ;}
;{	MemberName
/*
	Property: MemberName [get\set]
		Gets or sets the name of the missing member.
	Value:
		Can be MfString or var containing string.
	Gets:
		Gets the value of the MemberName as string var
	Sets:
		Sets the value of the MemberName.
	Remarks:
		Returns the Member name of the missing member as a var containing string.
*/
	MemberName[]
	{
		get {
			return this.m_MemberName
		}
		set {
			this.m_MemberName := MfString.GetValue(value)
			return this.m_MemberName
		}
	}
;	End:MemberName ;}
;{	Message
/*
	Property: Message [get]
		Overrides MfException.Message
		Gets a message that describes the current exception.
	Value:
		Var containing string
	Gets:
		Gets the error message that explains the reason for the exception, or an empty string
	Remarks:
		Read-only property.
*/
	Message[]
	{
		get {
			if (String.IsNullOrEmpty(this.ClassName))
			{
				return base.Message
			}
			return MfString.Format("{0}.{1}", this.ClassName, this.MemberName)
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