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
	MfSetFormatNumberType Class
		(Inherits from MfEnum)

		Specifies the case, and sort rules to be used by certain overloads of the MfString.Compare MfString.Equals methods.
		MfSetFormatNumberType is an MfEnum sytle class.
		MfSetFormatNumberType is a Sealed Class and cannot be inherited.

*/
; End:Class comments ;}
class MfSetFormatNumberType extends MfEnum
{
	static m_Instance := ""
;{ Constructor
	/*!
	Constructor()
	
	OutputVar := new MfSetFormatNumberType()
	OutputVar := new MfSetFormatNumberType(num)
	OutputVar := new MfSetFormatNumberType(instanceEnum)
	OutputVar := new MfSetFormatNumberType(enumItem)

	Constructor ()
		Creates a new instance of MfSetFormatNumberType class and set initial value to the value of Ordinal.

	Constructor (num)
		Creates a new instance of MfSetFormatNumberType class and sets initial value to value of num.

	Parameters
		num

		An integer value representing an Enumeration Value of MfSetFormatNumberType.

	Constructor (instanceEnum)
		Creates a new instance of MfSetFormatNumberType class an set the intial value to the value of instanceEnum.

	Parameters
		instanceEnum
			an instance of MfSetFormatNumberType whose Value is used to construct this instance.

	Constructor (enumItem)
		Creates a new instance of MfSetFormatNumberType and set its value enumItem value.

	Parameters
		enumItem
			MfEnum.EnumItem value must Enumeration of MfStringSplitOptions
	Throws
		Throws MfNotSupportedException if this sealed class is extended or inherited.
		Throws MfArgumentException if arguments are not correct.
	*/
	__New(value = 2) {
		; Throws MfNotSupportedException if MfSetFormatNumberType Sealed class is extended
		if (this.__Class != "MfSetFormatNumberType") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfSetFormatNumberType"))
		}
		base.__New(value)
		this.m_isInherited := this.__Class != "MfSetFormatNumberType"
	}
; End:Constructor ;}
;{ MfEnum members
; End:MfEnum members ;}
;{ Methods
;{ 	AddEnums()
/*!
		Method: AddEnums()
			Overrides MfEnum.AddEnums.

		AddEnums()
			Processes adding of new Enum values to derived class.

		Remarks
			Protected Method
			This method is call by base class and does not need to be call manually.
*/
	AddEnums() {
		this.AddEnumValue("Integer", 1)
		this.AddEnumValue("IntegerFast", 2)
		this.AddEnumValue("Float", 3)
		this.AddEnumValue("FloatFast", 4)
	}
; 	End:AddEnums() ;}
;{	DestroyInstance()
/*
	Method: DestroyInstance()
		Overrides MfEnum.DestroyInstance()
	
	MfSetFormatNumberType.DestroyInstance()
	
	DestroyInstance()
		Set current instance of class to null.
	Remarks
		Static Method
*/
	DestroyInstance() {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		MfSetFormatNumberType.m_Instance := Null
	}
; End:DestroyInstance() ;}
;{ 	GetInstance()
	/*!
		Method: GetInstance()
			Overrides MfEnum.GetInstance()

		OutputVar := MfSetFormatNumberType.GetInstance()
	
		GetInstance()
			Gets the instance for the MfSetFormatNumberType class.
		Returns
			Returns Singleton instance for MfSetFormatNumberType class.
		Remarks
			Protected Method.
			DestroyInstance() can be called to destroy instance.
			Use Instance to access the singleton instance.
	*/
	GetInstance() {
		if (MfNull.IsNull(MfSetFormatNumberType.m_Instance)) {
			MfSetFormatNumberType.m_Instance := new MfSetFormatNumberType()
		}
		return MfSetFormatNumberType.m_Instance
	}
; End:GetInstance() ;}

; End:Methods ;}
}
/*!
	End of class
*/