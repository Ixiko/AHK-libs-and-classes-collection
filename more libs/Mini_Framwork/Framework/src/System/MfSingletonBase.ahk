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

;{ class MfSingletonBase
/*!
	Class: MfSingletonBase
		Abstract class for singleton pattern Classes.
	Inherits:
		MfObject
*/
class MfSingletonBase extends MfObject
{
	
;{ Constructor
/*
	Method: Constructor()
		Abstract Method

	OututVar := new MfSingletonBase()

	MfSingletonBase()
		Constructor for Abstract Class MfSingletonBase.
	Throws:
		Throws MfNotSupportedException if this Abstract class constructor is called directly.
*/
	__New() {
		; Throws MfNotSupportedException if MfSingletonBase Abstract class constructor is called directly.
		if (this.__Class = "MfSingletonBase") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass", "MfSingletonBase"))
		}
		base.__New()
		this.m_isInherited := this.__Class != "MfSingletonBase"
	}
; End:Constructor ;}
;{ Methods
;{ 	DestroyInstance()
/*
	Method: DestroyInstance()
	DestroyInstance()
		Set current instance of singleton derived class to null.
		Abstract Method.
	Throws:
		Throws MfNotImplementedException if not implemented in derived class.
	Remarks:
		DestroyInstance() is an abstract method and must be implemented in derived class.
*/
	DestroyInstance() {
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", "DestroyInstance"))
		ex.Source := A_ThisFunc
		throw ex
	}
; End:DestroyInstance() ;}

;{ 	GetInstance()
/*
	Method: GetInstance()

	OutputVar := GetInstance()

	GetInstance()
		Protected Abstract method. Gets the instance of the Singleton
	Returns:
		Returns Singleton instance for the derived class.
	Throws:
		Throws MfNotImplementedException if method is not overridden in derived classes
	Remarks:
		This method must be overridden in derived classes.
*/
	GetInstance() {
		throw new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_GetInstance"))
	}
; 	End:GetInstance() ;}

; End:Methods ;}
;{ Properties
;{	Instance
/*
	Property: Instance [get]
		Gets a Singleton instance of derived class
	Value:
		instance of Derived Class
	Gets:
		Gets a Singleton instance of derived class
	Throws:
		Throws MfNotSupportedException if attempt to set value.
	Remarks:
		Read-only Property.
		Instance Property always returns the same instance of the derived class class.
*/
	Instance[]
	{
		get {
			return this.GetInstance()
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			Throw ex
		}
	}
;	End:Instance ;}
; End:Properties ;}
}
/*!
	End of class
*/
; End:class MfSingletonBase ;}