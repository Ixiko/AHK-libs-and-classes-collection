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
	Class: MfOrdinalComparer
		Compares String
	Inherits: MfEqualityComparerBase
*/
class MfOrdinalComparer extends MfEqualityComparerBase
{
	m_IgnoreCase := Null
	
;{ Constructor
	/*
		Constructor: (a) or new MyClass(a, b)
			Constructor for abstract class [MfOrdinalComparer](MfOrdinalComparer.html)
	*/
	__New(ignoreCase) {
		base.__New()
		this.m_IgnoreCase := MfBool.GetValue(ignoreCase)
	}
; End:Constructor ;}
	Compare(x, y) {
		if (MfObject.ReferenceEquals(x,y)) {
			return 0
		}
		if (MfNull.IsNull(x)) {
			return - 1
		}
		if (MfNull.IsNull(y)) {
			return 1
		}
		
	}
;{ Equals()
/*!
	Method: Equals(x, y)
		Equals() Determines whether the specified objects are equal.
	Parameters:
		x - The first [MfObject](MfObject.html) to Compare.
		y - The second [MfObject](MfObject.html) to compare.
	Remarks:
		Implement this method to provide a customized equality comparison for objects.
	Returns:
		Returns **true** if the specified objects are equal; otherwise, **false**.
	Extra:
		### Notes to Implementers
		The Equals method is reflexive, symmetric, and transitive. That is, it returns true if used to compare an
		[MfObject](MfObject.html) with itself; true for two MfObjects **x** and **y** if it is true for **y** and **x**
		; and true for two MfObjects **x** and **z** if it is true for **x** and **y** and also true for **y** and **z**.
		
		Implementations are required to ensure that if the Equals method returns true for two objects **x** and **y**,
		then the value returned by the [GetHashCode](MfEqualityComparerBase.GetHashCode.html) method for **x** must
		equal the value returned for **y**.
	Throws:
		Throws [MfNotImplementedException](MfNotImplementedException.html) if not overriden in derived class.
*/
	Equals(x, y) {
		ex := new MfNotImplementedException("Equal method must be implemente in derived class")
		ex.Source := A_ThisFunc
		throw ex
	}
; End:Equals() ;}
;{ GetHashCode()
/*!
	Method: GetHashCode(obj)
		GetHashCode() Returns a hash code for the specified [MfObject](MfObject.html).
	Parameters:
		obj - The [MfObject](MfObject.html) for which a hash code is to be returned.
	Remarks:
		Implement this method to provide customized hash codes for objects,corresponding to the customized
		equality comparison provided by the [Equals](MfEqualityComparerBase.Equals.html) method.
	Returns:
		Returns var containing MfInteger representing a hash code for the specified object.
	Extra:
		### Notes to Implementers
		Implementations are required to ensure that if the [Equals](MfEqualityComparerBase.Equals.html)
		method returns true for two objects **x** and **y**, then the value returned by the
		GetHashCode method for **x** must equal the value returned for **y**.
	Throws:
		Throws MfArgumentException if 
*/
	GetHashCode(obj) {
		if (!MfObject.IsObjInstance(obj, MfString)) {
			ex := new MfArgumentException("Object must be of type MfString or be derived from MfString")
			ex.Source := A_ThisFunc
			throw ex
		}
	}
; End:GetHashCode() ;}

}
/*!
	End of class
*/