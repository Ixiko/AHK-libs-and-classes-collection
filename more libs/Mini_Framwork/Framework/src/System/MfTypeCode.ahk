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

/*
	Class: MfTypeCode
		Provides implementation methods and properties for MfEnum type classes.Defines the Typecode of objects in framework 
		MfTypeCode is a Sealed Class and cannot be inherited.
		Internal Class
	Inherits: MfValueType
*/
class MfTypeCode extends MfEnum
{
	static m_Instance := ""
;{ Constructor
/*
	Constructor()

	OutputVar := new MfTypeCode()
	OutputVar := new MfTypeCode(num)
	OutputVar := new MfTypeCode(instanceEnum)
	
	Constructor ()
		Creates a new instance of MfTypeCode class and set initial value to zero.
	
	Constructor (num)
		Creates a new instance of MfTypeCode class and sets initial value to value of num.
	
	Constructor (instanceEnum)
		Creates a new instance of MfTypeCode class an set the initial value to the value of instanceEnum.
	
	Constructor (enumItem)
		Creates a new instance of derived class and set its value to the MfEnum.EnumItem instance value.
	Parameters
		num
			A value representing the current selected MfEnum.EnumItem value(s) of the derived class.
		instanceEnum
			an instance of derived class whose value is used to construct this instance.
		enumItem
			MfEnum.EnumItem value must element of this instance
	Throws
		Throws MfNotSupportedException if this sealed class is extended or inherited.
		Throws MfArgumentException if arguments are not correct.
*/
	__New(args*) {
		; Throws MfNotSupportedException if MfTypeCode Sealed class is extended
		if (this.__Class != "MfTypeCode") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfTypeCode"))
		}
		base.__New(args*)
		this.m_isInherited := this.__Class != "MfTypeCode"
	}
; End:Constructor ;}

;{ Methods
;{ 	AddEnums()
	/*
		Method: AddEnums()
			AddEnums() Processes adding of new MfEnum values to derived class.  
			Overrides [MfEnum.AddEnums](MfEnum.addenums.html).
		Remarks:
			This method is call by base class and does not need to be call manually.
	*/
	AddEnums() {
		this.AddEnumValue("Empty", 1)
		this.AddEnumValue("Attribute", 20)
		this.AddEnumValue("Object", 10)
		this.AddEnumValue("Boolean", 17)
		this.AddEnumValue("Char", 14)
		this.AddEnumValue("Byte", 21)
		this.AddEnumValue("DateTime", 15)
		this.AddEnumValue("Float", 13)
		this.AddEnumValue("Int32", 12)
		this.AddEnumValue("Int64", 22)
		this.AddEnumValue("String", 11)
		this.AddEnumValue("Null", 18)
		this.AddEnumValue("Enum", 19)
		this.AddEnumValue("EnumItem", 24)
		this.AddEnumValue("Int16", 25)
		this.AddEnumValue("UInt64", 26)
		this.AddEnumValue("MfBigInt", 27)
		this.AddEnumValue("UInt16", 28)
		this.AddEnumValue("UInt32", 29)
		this.AddEnumValue("SByte", 30)

	}
; 	End:AddEnums() ;}
;{	DestroyInstance()
	/*
		Method: DestroyInstance()
			DestroyInstance() Destroys the singleton instance of [MfTypeCode](MfTypeCode.html).  
			Overrides [MfEnum.DestroyInstance](MfEnum.destroyinstance.html).
	*/
	DestroyInstance() {
		MfTypeCode.m_Instance := Null
	}
; End:DestroyInstance() ;}
;{ 	GetInstance()
	/*
		Method: GetInstance()
			GetInstance() Gets the instance for the [MfTypeCode](MfTypeCode.html) class.  
			Overrides [MfEnum.GetInstance](MfEnum.getinstance.html).
		Remarks:
			[MfTypeCode.DestroyInstance](MfTypeCode.destroyinstance.html) can be called to destroy instance.
		Returns:
			Returns Singleton instance for [MfTypeCode](MfTypeCode.html) class.
	*/
	GetInstance() {
		if (MfNull.IsNull(MfTypeCode.m_Instance)) {
			MfTypeCode.m_Instance := new MfTypeCode(1)
		}
		return MfTypeCode.m_Instance
	}
; End:GetInstance() ;}
; End:Methods ;}
}
/*
	End of class
*/