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

;{ Class MfDigitShapes
;{ Class Comments
/*!
	Class: MfDigitShapes
		Specifies the culture-specific display of digits.  
		MfDigitShapes is an [MfEnum](MfEnum.html) sytle class.  
		MfDigitShapes is a Sealed Class and cannot be inherited.
	Inherits: MfEnum
		
*/
; End:Class Comments ;}
class MfDigitShapes extends MfEnum
{
	static m_Instance	:= ""
;{ Constructor: ()
/*
	Constructor()
	
	OutputVar := new MfDigitShapes()
	OutputVar := new MfDigitShapes(num)
	OutputVar := new MfDigitShapes(instanceEnum)
	
	Constructor ()
		Creates a new instance of MfDigitShapes class and set initial value to zero.
	
	Constructor (num)
		Creates a new instance of MfDigitShapes class and sets initial value to value of num.
	
	Constructor (instanceEnum)
		Creates a new instance of MfDigitShapes class an set the initial value to the value of instanceEnum.
	
	Constructor (enumItem)
		Creates a new instance of MfDigitShapes class and set its value to the MfEnum.EnumItem instance value.
	
	Parameters
		num
			A value representing the current selected MfEnum.EnumItem value(s) of the MfDigitShapes class.
		instanceEnum
			An instance of MfDigitShapes class whose value is used to construct this instance.
		enumItem
			MfEnum.EnumItem value must element of this instance
	Throws
	Throws MfNotSupportedException if this sealed class is extended or inherited.
	Throws MfArgumentException if arguments are not correct.
*/
	__New(args*) {
		; Throws MfNotSupportedException if MfDigitShapes Sealed class is extended
		if (this.__Class != "MfDigitShapes") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfDigitShapes"))
		}
		base.__New(args*)
		this.m_isInherited := this.__Class != "MfDigitShapes"
	}
; End:Constructor: () ;}
;{ Method
;{ 	AddEnums()						- Overrides	- MfEnum
/*!
	Method: AddEnums()
		Overrides MfEnum.AddEnums.

	AddEnums()
		Processes adding of new Enum values to class.
	Remarks
		Protected Method
		This method is call by base class and does not need to be call manually.
*/
	AddEnums() {
		this.AddEnumValue("Context", 0)
		this.AddEnumValue("None", 1)
		this.AddEnumValue("NativeNational", 2)
	}
; End:AddEnums() ;}

;{ 	GetInstance()
/*
	Method: GetInstance()
		Overrides MfEnum.GetInstance.
	
	OutputVar := MfDigitShapes.GetInstance()
	
	GetInstance()
		Gets the instance for the MfDigitShapes class.
	Returns
		Returns Singleton instance for MfDigitShapes class.
	Remarks
		Protected Method.
		MfDigitShapes.DestroyInstance can be called to destroy instance.
		Use Instance to access the singleton instance
*/
	GetInstance() {
		if (MfDigitShapes.m_Instance = Null) {
			MfDigitShapes.m_Instance := new MfDigitShapes(0)
		}
		return MfDigitShapes.m_Instance
	}
; End:GetInstance() ;}
; End:Method ;}
;{ Properties
; End:Properties ;}	
}
/*!
	End of class
*/
; End:Class MfDigitShapes ;}