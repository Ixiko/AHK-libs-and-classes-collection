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
	Class: MfEqualsOptions Class
		(Inherits from MfEnum)

		Determines the options for Methods that allow Options as a parameter.
		MfEqualsOptions is an MfEnum sytle class.
		This enumeration has a MfFlagsAttribute MfAttribute that allows a bitwise combination of its member values.
		MfEqualsOptions is a Sealed Class and cannot be inherited.

*/
class MfEqualsOptions extends MfEnum
{
	static m_Instance	:= ""
;{ Constructor: ()
/*!
	Constructor:
	
	OutputVar := new MfEqualsOptions()
	OutputVar := new MfEqualsOptions(num)
	OutputVar := new MfEqualsOptions(instanceEnum)
	OutputVar := new MfEqualsOptions(enumItem1, enumItem2, enumItem3, ...)
	
	Constructor ()
		Creates a new instance of MfEqualsOptions class and set initial value to the value of None.
	
	Constructor (num)
		Creates a new instance of MfEqualsOptions class and sets initial value to value of num.
	
		Parameters
			num
				An integer value representing an Enumeration Value of MfEqualsOptions.

	Constructor (instanceEnum)
		Creates a new instance of MfEqualsOptions class an set the intial value to the value of instanceEnum.
	
		Parameters
			instanceEnum
				an instance of MfEqualsOptions whose Value is used to construct this instance.

	Constructor (enumItem*)
		Creates a new instance of MfEqualsOptions and set its value enumItem value(s).
	
	Parameters
		enumItem
			MfEnum.EnumItem value(s) must Enumeration(s) of MfEqualsOptions

	Throws
		Throws MfNotSupportedException if this sealed class is extended or inherited.
		Throws MfArgumentException if arguments are not correct.
*/
	__New(args*) {
		if (this.base.__Class != "MfEqualsOptions") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class"
				,"MfEqualsOptions"))
		}
		
		base.__New(args*)
		this.m_isInherited := this.base.__Class != "MfEqualsOptions" ; Do not override this property in derrived classes
	}
; End:Constructor: () ;}

;{ Method
;{	AddAttribute()
/*
	Method: AddAttribute()
	AddAttribute(attrib)
		Overrides MfObject.AddAttribute Sealed Class will not have any other attributes added
	Parameters:
		attrib
			The object instance derived from MfAttribute to add.
	Throws:
		Throws MfNotSupportedException
*/
	AddAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex		
	}
;	End:AddAttribute() ;}
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
		; add attribute using base as we are overridding AddAttributes due to sealed class
		Base.AddAttribute(MfFlagsAttribute.Instance)
	}
; 	End:AddAttributes() ;}
;{ 	AddEnums()
/*
		Method: AddEnums()
			Overrides MfEnum.AddEnums.

		AddEnums()
			Processes adding of new Enum values to derived class.
		Remarks
			Protected Method
			This method is call by base class and does not need to be call manually.

	*/
	AddEnums() {
		this.AddEnumValue("None", 0)
		this.AddEnumValue("CompareNumber", 1)
	}
; End:AddEnums() ;}

;{ 	GetInstance()
	/*!
		Method: GetInstance()
			Overrides MfEnum.GetInstance.

		GetInstance()
			Gets the instance for the MfEqualsOptions class.

		Returns
			Returns Singleton instance for MfEqualsOptions class.

		Remarks
			Protected Method.
			DestroyInstance() can be called to destroy instance.
			Use Instance to access the singleton instance.

	*/
	GetInstance() {
		if (MfNull.IsNull(MfEqualsOptions.m_Instance)) {
			MfEqualsOptions.m_Instance := new MfEqualsOptions(0)
		}
		return MfEqualsOptions.m_Instance
	}
; End:GetInstance() ;}

;{	DestroyInstance()
/*
	Method:DestroyInstance()
		Overrides MfEnum.DestroyInstance()
	
	MfEqualsOptions.DestroyInstance()
	
	DestroyInstance()
		Set current Instance of class to Null.
	Remarks
		Static Method
		The next time Instance property is accessed a new instance of MfEqualsOptions will be created as the current Instance.
		This method is not needed in the large majority of cases but is available for rare cases.
	Throws
		Throws MfInvalidOperationException if not called as a static method.
*/
	DestroyInstance() {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		MfEqualsOptions.m_Instance := Null
	}
; End:DestroyInstance() ;}
; End:Method ;}
}
/*!
	End of class
*/