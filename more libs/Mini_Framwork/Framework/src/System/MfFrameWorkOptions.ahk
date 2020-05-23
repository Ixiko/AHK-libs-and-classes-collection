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
	Class: MfNumberStyles
		Determines the styles permitted in numeric string arguments that are passed to the Parse and TryParse methods of the integral and floating-point numeric types.  
		MfNumberStyles is an MfEnum sytle class.  
		This enumeration has a MfFlagsAttribute MfAttribute that allows a bitwise combination of its member values.  
		MfNumberStyles is a Sealed Class and cannot be inherited.
	Inherits: MfEnum
*/
class MfFrameWorkOptions extends MfEnum
{
	static m_Instance	:= ""
;{ Constructor: ()
	/*!
		Constructor: () Creates a new instance of MfFrameWorkOptions class.
			`Constructor ()` Creates a new instance of MfFrameWorkOptions class and set inital value to zero.  
			`Constructor (num)` Creates a new instance of MfFrameWorkOptions class and sets inital value to value of *num*.  
			`Constructor (instanceEnum)` Creates a new instance of MfFrameWorkOptions class an set the intial value to the value of *instanceEnum*.  
			`Constructor (enumItem1, enumItem2, enumItem3, ...)` Creates a new instance of MfFrameWorkOptions class and set its value to the combined
			flags value of enumItem1, enumItem2, enumItem3, ... must be MfEnum values of MfFrameWorkOptions instances.
		Parameters:
			num - A value as integer representing the one or more Enum items of MfFrameWorkOptions.
				Can be [MfInteger](MfInteger.html) or var containing integer.
			instanceEnum - an instance of derived class whose value is used to construct this instance.
			enumItem(s) - [MfEnum.EnumItem](MfEnum.enumitem.html) values used to construct this instance.
		Remarks:
			This class implements MfFlagsAttribute that allows a bitwise combination of its member values.
		Throws:
			Throws [MfNotSupportedException](MfNotSupportedException.html) if this sealed class is extended or inherited.  
			Throws [MfArgumentException](MfArgumentException.html) if arguments are not correct.
	*/
	__New(args*) {
		if (this.base.__Class != "MfFrameWorkOptions") {
			throw new MfNotSupportedException("Sealed Class")
		}
		
		base.__New(args*)
		this.m_isInherited := false ; sealed class
	}
; End:Constructor: () ;}
;{ Method
	/*!
		Method: AddAtributes()
			AddAtributes() Overrides [MfEnum.AddAttributes](MfEnum.addattributes.html). Adds Attribures to current MfEnum.
		Remarks:
			This method is not to be called directly. Method should be treated as a protected method.
	*/
	AddAttributes() {
		this.AddAttribute(MfFlagsAttribute.Instance)
	}
;{ 	AddEnums()
	/*!
		Method: AddEnums()
			AddEnums() Processes adding of new MfEnum values to derived class.  
			Overrides [MfEnum.AddEnums](MfEnum.addenums.html).
		Remarks:
			This method is call by base class and does not need to be call manually.
	*/
	AddEnums() {
		this.AddEnumValue("None", 0)
		this.AddEnumValue("UndefinedIsNull", 1)
		this.AddEnumValue("MfEmptyStringIsNull", 2)
		this.AddEnumValue("MfCharZeroIsNull", 4)
		this.AddEnumValue("StringObeyCaseSense", 8)
		this.AddEnumValue("CharObeyCaseSense", 16)
	}
; End:AddEnums() ;}

;{ 	GetInstance()
	/*!
		Method: GetInstance()
			GetInstance() Gets the instance for the MfFrameWorkOptions class.  
			Overrides [MfEnum.GetInstance](MfEnum.getinstance.html).
		Remarks:
			[MfNumberStyles.DestroyInstance](MfNumberStyles.destroyinstance.html) can be called to destroy instance.
		Returns:
			Returns Singleton instance for MfFrameWorkOptions class.
	*/
	GetInstance() {
		; do not use MfNull.IsNull here because this class is a super global
		if (!IsObject(MfFrameWorkOptions.m_Instance)) {
			; 7 = UndefinedIsNull | MfEmptyStringIsNull | MfCharZeroIsNull
			MfFrameWorkOptions.m_Instance := new MfFrameWorkOptions(7)
		}
		return MfFrameWorkOptions.m_Instance
	}
; End:GetInstance() ;}
;{	DestroyInstance()
	/*
		Method: DestroyInstance()
			DestroyInstance() Destroys the singleton instance of MfFrameWorkOptions.  
			Overrides [MfEnum.DestroyInstance](MfEnum.destroyinstance.html).
	*/
	DestroyInstance() {
		MfFrameWorkOptions.m_Instance := Null
	}
; End:DestroyInstance() ;}

; End:Method ;}

}
/*!
	End of class
*/