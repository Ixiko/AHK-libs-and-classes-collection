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

; Defines the Unicode category of a character.
/*
	Class: MfBidiCategory
		Provides implementation methods and properties for MfEnum type classes.Defines the Unicode category of a character.  
		MfBidiCategory is a Sealed Class and cannot be inherited.
		Internal Class
	Inherits: MfValueType
*/
class MfBidiCategory extends MfEnum
{
	static m_Instance := ""
;{ Constructor
/*
	Constructor()

	OutputVar := new MfBidiCategory()
	OutputVar := new MfBidiCategory(num)
	OutputVar := new MfBidiCategory(instanceEnum)
	
	Constructor ()
		Creates a new instance of MfBidiCategory class and set initial value to zero.
	
	Constructor (num)
		Creates a new instance of MfBidiCategory class and sets initial value to value of num.
	
	Constructor (instanceEnum)
		Creates a new instance of MfBidiCategory class an set the initial value to the value of instanceEnum.
	
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
		; Throws MfNotSupportedException if MfBidiCategory Sealed class is extended
		if (this.__Class != "MfBidiCategory") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfBidiCategory"))
		}
		base.__New(args*)
		this.m_isInherited := this.__Class != "MfBidiCategory"
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
		this.AddEnumValue("LeftToRight", 0)
		this.AddEnumValue("LeftToRightEmbedding", 1)
		this.AddEnumValue("LeftToRightOverride", 2)
		this.AddEnumValue("RightToLeft", 3)
		this.AddEnumValue("RightToLeftArabic", 4)
		this.AddEnumValue("RightToLeftEmbedding", 5)
		this.AddEnumValue("RightToLeftOverride", 6)
		this.AddEnumValue("PopDirectionalFormat", 7)
		this.AddEnumValue("EuropeanNumber", 8)
		this.AddEnumValue("EuropeanNumberSeparator", 9)
		this.AddEnumValue("EuropeanNumberTerminator", 10)
		this.AddEnumValue("ArabicNumber", 11)
		this.AddEnumValue("CommonNumberSeparator", 12)
		this.AddEnumValue("NonSpacingMark", 13)
		this.AddEnumValue("BoundaryNeutral", 14)
		this.AddEnumValue("ParagraphSeparator", 15)
		this.AddEnumValue("SegmentSeparator", 16)
		this.AddEnumValue("Whitespace", 17)
		this.AddEnumValue("OtherNeutrals", 18)
	}
; 	End:AddEnums() ;}
;{	DestroyInstance()
	/*
		Method: DestroyInstance()
			DestroyInstance() Destroys the singleton instance of [MfBidiCategory](MfBidiCategory.html).  
			Overrides [MfEnum.DestroyInstance](MfEnum.destroyinstance.html).
	*/
	DestroyInstance() {
		MfBidiCategory.m_Instance := Null
	}
; End:DestroyInstance() ;}
;{ 	GetInstance()
	/*
		Method: GetInstance()
			GetInstance() Gets the instance for the [MfBidiCategory](MfBidiCategory.html) class.  
			Overrides [MfEnum.GetInstance](MfEnum.getinstance.html).
		Remarks:
			[MfBidiCategory.DestroyInstance](MfBidiCategory.destroyinstance.html) can be called to destroy instance.
		Returns:
			Returns Singleton instance for [MfBidiCategory](MfBidiCategory.html) class.
	*/
	GetInstance() {
		if (MfNull.IsNull(MfBidiCategory.m_Instance)) {
			MfBidiCategory.m_Instance := new MfBidiCategory(0)
		}
		return MfBidiCategory.m_Instance
	}
; End:GetInstance() ;}
; End:Methods ;}
}
/*
	End of class
*/