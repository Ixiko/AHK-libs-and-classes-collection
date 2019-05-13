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
	Class: MfEqualityComparerBase
		Abstract class that defines methods to support the comparison of objects for equality.
	Inherits:
		MfObject
*/
class MfEqualityComparerBase extends MfObject
{
;{ Constructor
/*
	Constructor: ()
		Constructor for abstract class MfEqualityComparerBase
	Remarks:
		Derived classes must call base.__New() in their constructors
	Throws:
		Throws MfNotSupportedException if this Abstract class constructor is called directly
*/
	__New() {
		if (this.base.__Class = "MfEqualityComparerBase") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass", "MfEqualityComparerBase"))
		}
		base.__New()
		this.m_isInherited := true
	}
; End:Constructor ;}
;{ Methods

;{ Equals()
/*
	Method: Equals()
		Overrides MfObject.Equals
	
	OutputVar := MfEqualityComparerBase.Equals()
	
	Equals(x, y)
		Determines whether the specified objects are equal.
		Abstract Method
	Parameters
		x
			The first MfObject to Compare.
		y
			The second MfObject to compare.
	Returns
		Returns true if the specified objects are equal; otherwise, false.
	Throws
		Throws MfNotImplementedException if not overridden in derived class.
	Remarks
		Implement this method to provide a customized equality comparison for objects.
		Notes to Implementers
		The Equals method is reflexive, symmetric, and transitive. That is, it returns true if used to compare an MfObject with itself;
		true for two MfObject x and y if it is true for y and x ; and true for two MfObject x and z if it is true for x and y and also true for y and z.
		Implementations are required to ensure that if the Equals method returns true for two objects x and y,
		then the value returned by the GetHashCode method for x must equal the value returned for y.
*/
	Equals(x, y) {
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodWithName", "Equals"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:Equals() ;}
;{ GetHashCode()
/*
	Method: GetHashCode()
	
	Overrides MfObject.GetHasCode
	
	instance.GetHashCode()
	
	GetHashCode(obj)
		Returns a hash code for the specified MfObject.
	Parameters
		obj
			The MfObject for which a hash code is to be returned.
	Returns
		Returns A hash code for the current MfObject.
	Throws
		Throws MfNotImplementedException if not overridden in derived class.
	Remarks
		Implement this method to provide customized hash codes for objects,
		corresponding to the customized equality comparison provided by the Equals method.
		
		Notes to Implementers
		Implementations are required to ensure that if the Equals method returns true for two objects x and y,
		then the value returned by the GetHashCode method for x must equal the value returned for y.
*/
	GetHashCode(obj) {
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodWithName", "GetHashCode"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:GetHashCode() ;}
; End:Methods ;}
}
/*!
	End of class
*/