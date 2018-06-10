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
/*!
	Class: MfAttribute
		Represents the base class for custom attributes.  
		Abstract class
	Inherits: MfObject
*/
; End:Class Comments ;}
class MfAttribute extends MfSingletonBase
{
	static TypeCode := 20

;{ Constructor: ()
/*
	Constructor()
		Constructor for Abstract MfAttribute Class

	OututVar := new MfAttribute()

	Constructor()
		Constructor for Abstract MfAttribute Class
	Throws
		Throws MfNotSupportedException if this Abstract class constructor is called directly.
	Remarks
		Derived classes must call base.__New() in their constructors
*/
	__New() {
		if (this.base.__Class = "MfAttribute") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass", "MfAttribute"))
		}
		base.__New()
		this.m_isInherited := this.__Class != "MfAttribute"
	}
; End:Constructor: () ;}
;{ Method
;{ 	CompareTo()			- Overrides	- MfObject
/*
	CompareTo()
	Overrides MfObject.CompareTo()	

	OutputVar := instance.CompareTo(obj)

	CompareTo(obj)
		Compares the current instance with another object of the same type and returns an integer that
		indicates whether the current instance precedes, follows, or occurs in the same position in the
		sort order as the other object.
		This method can be overridden in extended classes.
	Parameters
		obj
			An object to compare with this instance.
	Returns
		Returns 0 if obj has the same class name as current instance; Otherwise 1
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentException is not MfAttribute or not derived from MfAttribute.
*/
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!MfObject.IsObjInstance(obj, MfAttribute)) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Object_Equals"),"obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfType.TypeOfName(this) = MfType.TypeOfName(obj))
		{
			return 0
		}
		return 1
	}
; End:CompareTo() ;}

; End:Method ;}
;{ Properties
	/*!
		Property: TypeID [get]
		Get:
			Get The TypeCode of the current instance as var string.
		Remarks:
			Readonly Property.
			This property can be overridden in derived Attribute classes to provide a unique id for the derived Attribute.
	*/
	m_TypeID := ""
	TypeID[]
	{
		get {
			if (this.m_TypeID = "")
			{
				this.m_TypeID := this.GetType().TypeCode
			}
			return this.m_TypeID
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; End:Properties;}
}
/*!
	End of class
*/