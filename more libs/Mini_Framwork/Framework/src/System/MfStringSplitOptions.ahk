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
	Class: MfStringSplitOptions
		Specifies whether applicable MfString.Split() method overloads include or omit empty substrings from the return value.
		This enumeration has a MfFlagsAttribute Attribute that allows a bitwise combination of its member values.
		MfStringSplitOptions is an MfEnum style class.
		MfStringSplitOptions is a Sealed Class and cannot be inherited.
	Inherits:
		MfEnum		
*/
class MfStringSplitOptions extends MfEnum
{
	static m_Instance := ""
;{ Constructor: ()
/*!
	Constructor:
	
	OutputVar := new MfStringSplitOptions()
	OutputVar := new MfStringSplitOptions(num)
	OutputVar := new MfStringSplitOptions(instanceEnum)
	OutputVar := new MfStringSplitOptions(enumItem1, enumItem2, enumItem3, ...)
	
	Constructor ()
		Creates a new instance of MfStringSplitOptions class and set initial value to the value of None.
	
	Constructor (num)
		Creates a new instance of MfStringSplitOptions class and sets initial value to value of num.
	
		Parameters
			num
				An integer value representing an Enumeration Value of MfStringSplitOptions.

	Constructor (instanceEnum)
		Creates a new instance of MfStringSplitOptions class an set the intial value to the value of instanceEnum.
	
		Parameters
			instanceEnum
				an instance of MfStringSplitOptions whose Value is used to construct this instance.

	Constructor (enumItem*)
		Creates a new instance of MfStringSplitOptions and set its value enumItem value(s).
	
	Parameters
		enumItem
			MfEnum.EnumItem value(s) must Enumeration(s) of MfStringSplitOptions

	Throws
		Throws MfNotSupportedException if this sealed class is extended or inherited.
		Throws MfArgumentException if arguments are not correct.
*/
	__New(args*) {
		; Throws MfNotSupportedException if MfStringSplitOptions Sealed class is extended
		if (this.__Class != "MfStringSplitOptions") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfStringSplitOptions"))
		}
		base.__New(args*)
		this.m_isInherited := this.__Class != "MfStringSplitOptions"
	}
; End:Constructor: () ;}
;{ Method
;{ 	AddAttributes()
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
; 	End:AddAttributes() ;}
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
		this.AddEnumValue("RemoveEmptyEntries", 1)
		this.AddEnumValue("Trim", 2)
		this.AddEnumValue("TrimStart", 4)
		this.AddEnumValue("TrimEnd", 8)
		this.AddEnumValue("TrimLineEndChars", 16)

	}
; 	End:AddEnums() ;}

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
		The next time Instance property is accessed a new instance of MfStringSplitOptions will be created as the current Instance.
		This method is not needed in the large majority of cases but is available for rare cases.
*/
	DestroyInstance() {
		MfStringSplitOptions.m_Instance := Null
	}
; End:DestroyInstance() ;}


;{ 	GetInstance()
/*
	Method: GetInstance()
		Overrides MfEnum.GetInstance.

	OutputVar := MfStringSplitOptionsGetInstance()

	GetInstance()
		Gets the instance for the MfStringSplitOptions class.
	Returns:
		Returns Singleton instance for MfStringSplitOptions class.
	Remarks:
		Protected static Method.
		DestroyInstance() can be called to destroy instance.
		Use Instance to access the singleton instance.
*/
	GetInstance() {
		if (MfStringSplitOptions.m_Instance = Null) {
			MfStringSplitOptions.m_Instance := new MfStringSplitOptions(0)
		}
		return MfStringSplitOptions.m_Instance
	}
; End:GetInstance() ;}


; End:Method ;}
;{ Properties

; End:Properties ;}	
}
/*!
	End of class
*/