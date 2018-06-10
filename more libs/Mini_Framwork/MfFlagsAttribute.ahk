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
;{ Class Comments
/*
	Class:
		MfFlagsAttribute
			Indicates that an enumeration can be treated as a bit field; that is, a set of flags.
			This attribute is usually added to MfEnum derived classes that require the ability to set flags such as MfNumberStyles.
			To add this attribute to derived class override the AddAttributes() of MfEnum.
	Inherits
		MfAttribute
*/
; End:Class Comments ;}
class MfFlagsAttribute extends MfAttribute
{
	static _instance := "" ; Static var to contain the singleton instance
;{ Constructor: ()
/*!
	Constructor: ()
		Initializes a new instance of the MfFlagsAttribute class.
	Remarks
		MfFlagsAttribute is Singleton, Use Instance property to access instead of Constructing a new instance.
*/
	__New() {
		base.__New()
		this.m_isInherited := this.__Class != "MfFlagsAttribute"
	}
; End:Constructor: () ;}
;{ Method
/*
	Method: DestroyInstance()
		Overrides MfSingletonBase.DestroyInstance()
	instance.DestroyInstance()
	
	DestroyInstance()
		Set current Instance to null.
	Remarks
		Call to Property Instance will create a new instance automatically if DestroyInstance() is called.
*/
	DestroyInstance() {
	   MfFlagsAttribute._instance := Null ; Clears current instance and releases memory
	}
/*
	Method: GetInstance()
		Overrides MfSingletonBase.GetInstance()
		Gets the instance of the Singleton MfFlagsAttribute.
	Returns
		Returns Singleton instance for the derived class.
	Throws
		Throws MfNotImplementedException if method is not overridden in derived classes
	Remarks
		Protected static method.
		This method must be overridden in derived classes.
*/
	GetInstance() { ; Overrides base
		if (MfNull.IsNull(MfFlagsAttribute._instance)) {
		   MfFlagsAttribute._instance := new MfFlagsAttribute()
		}
		return MfFlagsAttribute._instance
	}
; End:Method ;}
	
}
/*!
	End of class
*/