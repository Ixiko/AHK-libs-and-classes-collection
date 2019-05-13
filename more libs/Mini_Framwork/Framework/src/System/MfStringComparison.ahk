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
	MfStringComparison Class
		(Inherits from MfEnum)

		Specifies the case, and sort rules to be used by certain overloads of the MfString.Compare MfString.Equals methods.
		MfStringComparison is an MfEnum sytle class.
		MfStringComparison is a Sealed Class and cannot be inherited.

*/
; End:Class comments ;}
class MfStringComparison extends MfEnum
{
	static m_Instance := ""
;{ Constructor
	/*!
	Constructor()
	
	OutputVar := new MfStringComparison()
	OutputVar := new MfStringComparison(num)
	OutputVar := new MfStringComparison(instanceEnum)
	OutputVar := new MfStringComparison(enumItem)

	Constructor ()
		Creates a new instance of MfStringComparison class and set initial value to the value of Ordinal.

	Constructor (num)
		Creates a new instance of MfStringComparison class and sets initial value to value of num.

	Parameters
		num

		An integer value representing an Enumeration Value of MfStringComparison.

	Example
		MyEnum := new MfStringComparison(4) ; OrdinalIgnoreCase

	Constructor (instanceEnum)
		Creates a new instance of MfStringComparison class an set the intial value to the value of instanceEnum.

	Parameters
		instanceEnum
			an instance of MfStringComparison whose Value is used to construct this instance.

	Example
		MyEnum := new MfStringComparison() ; create instance with default value
		MyEnum.Value := MfStringComparison.Instance.OrdinalIgnoreCase.Value
		MfE := new MfStringComparison(MyEnum) ; create a new instance and sets it value to the value of MyEnum

	Constructor (enumItem)
		Creates a new instance of MfStringComparison and set its value enumItem value.

	Parameters
		enumItem
			MfEnum.EnumItem value must Enumeration of MfStringSplitOptions
	Example
		MyEnum := new MfStringComparison(MfStringComparison.Instance.OrdinalIgnoreCase)
	Throws
		Throws MfNotSupportedException if this sealed class is extended or inherited.
		Throws MfArgumentException if arguments are not correct.
	*/
	__New(value = 5) {
		; Throws MfNotSupportedException if MfStringComparison Sealed class is extended
		if (this.__Class != "MfStringComparison") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfStringComparison"))
		}
		base.__New(value)
		this.m_isInherited := this.__Class != "MfStringComparison"
	}
; End:Constructor ;}
;{ MfEnum members
	/*!
		Ordinal
			OutputVar := MfStringComparison.Instance.Ordinal

			Description
				Compare strings using ordinal sort rules.

			Value
				Value = 4

			Remarks
				Read-only.
				Ordinal is instance of MfEnum.EnumItem.


		OrdinalIgnoreCase
			OutputVar := MfStringComparison.Instance.OrdinalIgnoreCase

			Description
				Compare strings using ordinal sort rules and ignoring the case of the strings being compared.

			Value
				Value = 5

			Remarks
				Read-only.
				OrdinalIgnoreCase is instance of MfEnum.EnumItem.
	*/
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
		this.AddEnumValue("Ordinal", 4)
		this.AddEnumValue("OrdinalIgnoreCase", 5)
	}
; 	End:AddEnums() ;}
;{	DestroyInstance()
/*
	Method: DestroyInstance()
		Overrides MfEnum.DestroyInstance()
	
	MfStringComparison.DestroyInstance()
	
	DestroyInstance()
		Set current instance of class to null.
	Remarks
		Static Method
*/
	DestroyInstance() {
		MfStringComparison.m_Instance := Null
	}
; End:DestroyInstance() ;}
;{ 	GetInstance()
	/*!
		Method: GetInstance()
			Overrides MfEnum.GetInstance()

		OutputVar := MfStringComparison.GetInstance()
	
		GetInstance()
			Gets the instance for the MfStringComparison class.
		Returns
			Returns Singleton instance for MfStringComparison class.
		Remarks
			Protected Method.
			DestroyInstance() can be called to destroy instance.
			Use Instance to access the singleton instance.
	*/
	GetInstance() {
		if (MfNull.IsNull(MfStringComparison.m_Instance)) {
			MfStringComparison.m_Instance := new MfStringComparison()
		}
		return MfStringComparison.m_Instance
	}
; End:GetInstance() ;}

; End:Methods ;}
}
/*!
	End of class
*/