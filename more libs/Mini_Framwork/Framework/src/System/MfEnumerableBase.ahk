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
/*
	Class: MfEnumerableBase
		Abstract Class  
		MfEnumerableBase exposes the enumerator, which supports a simple iteration over a collection.
		MfEnumerableBase is an abstract class and must be inherited by other classes such as MfList.
	Inherits: MfObject
		
*/
;	End:Class comments ;}
class MfEnumerableBase extends MfObject
{
;{ Constructor()
/*
		Constructor: ()
			Constructor for Abstract MfEnumerableBase Class
		Remarks:
			Derived classes must call base.__New() in their constructors.
		Throws:
			Throws MfNotSupportedException if this Abstract class constructor is called directly.
*/
	__New() {
		; Throws MfNotSupportedException if MfEnumerableBase Abstract class constructor is called directly.
		if (this.__Class = "MfEnumerableBase") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass", "MfEnumerableBase"))
		}
		base.__New()
		this.m_isInherited := true ; abstract class can only be inherited
	}
; End:Constructor() ;}
;{ Methods
;{ 	GetEnumerator()
/*
		Method: GetEnumerator()
			GetEnumerator() Gets an enumerator
		Remarks:
			Returns an enumerator that iterates through a collection.  
		Returns:
			Returns an enumerator that iterates through a collection.
		Throws:
			Throws MfNotImplementedException if _NewEnum() Method has not been overridden in derived class.
*/
	GetEnumerator() {
		return this._NewEnum()
	}
; End:GetEnumerator() ;}
/*!
	Method: _NewEnum()
		This abstract method must be overridden in derived classes.
	_NewEnum()
		Returns a new enumerator to enumerate this object's key-value pairs. This method is usually not called directly, but by the for-loop or by GetEnumerator()
	Remarks
		Protected Abstract Method.
		Must be overridden in derived classes.
	Throws
		Throws MfNotImplementedException if _NewEnum Method has not been overridden in derived class
*/
	_NewEnum() {
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;{ 	GetHashCode - Overrides MfObject.GetHashCode()
	; derived classes should not need GetHashCode() but can override if needed.
	GetHashCode() {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:GetHashCode ;}

; End:Methods ;}
}
/*!
	End of class
*/