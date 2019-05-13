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
class MfMidpointRounding extends MfEnum
{
	static m_Instance := ""
;{ Constructor
/*
	Constructor()

	OutputVar := new MfMidpointRounding()
	OutputVar := new MfMidpointRounding(num)
	OutputVar := new MfMidpointRounding(instanceEnum)
	
	Constructor ()
		Creates a new instance of MfMidpointRounding class and set initial value to zero.
	
	Constructor (num)
		Creates a new instance of MfMidpointRounding class and sets initial value to value of num.
	
	Constructor (instanceEnum)
		Creates a new instance of MfMidpointRounding class an set the initial value to the value of instanceEnum.
	
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
		; Throws MfNotSupportedException if MfMidpointRounding Sealed class is extended
		if (this.__Class != "MfMidpointRounding") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfMidpointRounding"))
		}
		base.__New(args*)
		this.m_isInherited := this.__Class != "MfMidpointRounding"
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
		this.AddEnumValue("ToEven", 0)
		this.AddEnumValue("AwayFromZero", 1)
	}
; 	End:AddEnums() ;}
;{	DestroyInstance()
	/*
		Method: DestroyInstance()
			DestroyInstance() Destroys the singleton instance of [MfMidpointRounding](MfMidpointRounding.html).  
			Overrides [MfEnum.DestroyInstance](MfEnum.destroyinstance.html).
	*/
	DestroyInstance() {
		MfMidpointRounding.m_Instance := Null
	}
; End:DestroyInstance() ;}
;{ 	GetInstance()
	/*
		Method: GetInstance()
			GetInstance() Gets the instance for the [MfMidpointRounding](MfMidpointRounding.html) class.  
			Overrides [MfEnum.GetInstance](MfEnum.getinstance.html).
		Remarks:
			[MfMidpointRounding.DestroyInstance](MfMidpointRounding.destroyinstance.html) can be called to destroy instance.
		Returns:
			Returns Singleton instance for [MfMidpointRounding](MfMidpointRounding.html) class.
	*/
	GetInstance() {
		if (MfNull.IsNull(MfMidpointRounding.m_Instance)) {
			MfMidpointRounding.m_Instance := new MfMidpointRounding(0)
		}
		return MfMidpointRounding.m_Instance
	}
; End:GetInstance() ;}
; End:Methods ;}
}
/*
	End of class
*/