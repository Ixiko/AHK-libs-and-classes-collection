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
		Determines the styles permitted in numeric string arguments that are passed to the Parse and
		TryParse methods of the integral and floating-point numeric types.
		This enumeration has a MfFlagsAttribute MfAttribute that allows a bitwise combination of its member values.
		MfNumberStyles is an MfEnum style class.
		MfNumberStyles is a Sealed Class and cannot be inherited.
	Inherits: MfEnum
*/
class MfNumberStyles extends MfEnum
{
	static m_Instance	:= ""
;{ Constructor: ()
/*
	Constructor()

	OutputVar := new MfNumberStyles()
	OutputVar := new MfNumberStyles(num)
	OutputVar := new MfNumberStyles(instanceEnum)
	OutputVar := new MfNumberStyles(enumItem1, enumItem2, enumItem3, ...)

	Method: Constructor()
		Creates a new instance of MfNumberStyles class and set initial value to the value of None.

	Constructor (num)
		Creates a new instance of MfNumberStyles class and sets initial value to value of num.
	Parameters:
		enumItem
			MfEnum.EnumItem value(s) must Enumeration(s) of MfNumberStyles

	Method: Constructor (instanceEnum)
		Creates a new instance of MfNumberStyles class an set the intial value to the value of instanceEnum.
		instanceEnum
		an instance of MfNumberStyles whose Value is used to construct this instance
	Parameters:
		instanceEnum
			an instance of MfNumberStyles whose Value is used to construct this instance.

	Constructor (enumItem*)
		Creates a new instance of MfNumberStyles and set its value enumItem value(s).
	Parameters:
		enumItem
			MfEnum.EnumItem value(s) must Enumeration(s) of MfNumberStyles

	Throws:
		Throws MfNotSupportedException if this sealed class is extended or inherited.
		Throws MfArgumentException if arguments are not correct.
*/
	__New(args*) {
		if (this.base.__Class != "MfNumberStyles") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfNumberStyles"))
		}
		
		base.__New(args*)
		this.m_isInherited := false ; sealed class
	}
; End:Constructor: () ;}
;{ Method
/*
	Method: AddAttributes()
		Overrides MfEnum.AddAttributes()
	AddAttributes()
		Adds MfFlagsAttribute to class.
	Remarks:
		Protected Method
*/
	AddAttributes() {
		; flags must be added before base is called
		this.AddAttribute(MfFlagsAttribute.Instance)
	}
;{ 	AddEnums()
/*
	Method: AddEnums()
		Overrides MfEnum.AddEnums.
	AddEnums()
		Processes adding of new Enum values to class.
	Remarks:
		Protected Method
		This method is call by base class and does not need to be call manually.
*/
	AddEnums() {
		this.AddEnumValue("None", 0)
		this.AddEnumValue("AllowLeadingWhite", 1)
		this.AddEnumValue("AllowTrailingWhite", 2)
		this.AddEnumValue("AllowLeadingSign", 4)
		this.AddEnumValue("AllowTrailingSign", 8)
		this.AddEnumValue("AllowParentheses", 16)
		this.AddEnumValue("AllowDecimalPoint", 32)
		this.AddEnumValue("AllowThousands", 64)
		this.AddEnumValue("AllowExponent", 128)
		this.AddEnumValue("AllowCurrencySymbol", 256)
		this.AddEnumValue("AllowHexSpecifier", 512)
		this.AddEnumValue("Integer", 7)
		this.AddEnumValue("HexNumber", 515)
		this.AddEnumValue("Number", 111)
		this.AddEnumValue("Float", 167)
		this.AddEnumValue("Currency", 383)
		this.AddEnumValue("Any", 515)
	}
; End:AddEnums() ;}

;{ 	GetInstance()
/*
	Method: GetInstance()
		Overrides MfEnum.GetInstance.

	OutputVar := MfNumberStyles.GetInstance()

	GetInstance()
		Gets the instance for the MfEqualsOptions class.
	Returns:
		Returns Singleton instance for MfEqualsOptions class.
	Remarks:
		Protected static Method.
		DestroyInstance() can be called to destroy instance.
		Use Instance to access the singleton instance.
*/
	GetInstance() {
		if (MfNull.IsNull(MfNumberStyles.m_Instance)) {
			MfNumberStyles.m_Instance := new MfNumberStyles(0)
		}
		return MfNumberStyles.m_Instance
	}
; End:GetInstance() ;}

;{	DestroyInstance()
/*
	Method: DestroyInstance()
		Overrides MfEnum.DestroyInstance()
	DestroyInstance()
		Set current Instance of class to Null.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
	Remarks:
		Static Method
		The next time Instance propery is accessed a new instance of MfEqualsOptions will be created as the current Instance.
		This method is not needed in the large majority of cases but is available for rare cases.
*/
	DestroyInstance() {
		MfNumberStyles.m_Instance := Null
	}
; End:DestroyInstance() ;}


; End:Method ;}
}
/*!
	End of class
*/