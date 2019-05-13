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
	Class: MfFormatProvider
		Provides a mechanism for retrieving an object to control formatting.  
		This class in intended as a base class only an is not to be used on it own.  
		Abstract Class.
	Inherits: MfObject
*/
class MfFormatProvider extends MfObject
{
;{ Constructor: ()
	/*!
		Constructor: ()
			Constructor for class MfFormatProvider Class
		Throws:
			Throws MfNotSupportedException if this Abstract class constructor is called directly.
	*/
	__New() {
		if (this.base.__Class = "MfFormatProvider") {
			throw new MfNotSupportedException(MfString.Format(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass"), base.__Class))
		}
		base.__New()
		this.m_isInherited := this.__Class != "MfFormatProvider"
	}
; End:Constructor: () ;}
;{ Method

;{	GetFormat()
/*
	Method: GetFormat()
	
	OutputVar := MfFormatProvider.GetFormat(formatType)
	
	GetFormat()
		Returns an object that provides formatting services for the specified type.
	Parameters
		formatType
			An object that specifies the type of format object to return.
	Returns
		Returns an instance of the object specified by formatType, if the MfFormatProvider implementation can supply that type of object; otherwise, null.
	Throws
		Throws MfNotImplementedException if not implemented in derived class.
	Remarks
		Abstract method.
		Must be overriden in derived classes
*/
	GetFormat(formatType) {
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName"
			, "GetFormat"))
		ex.Source := A_ThisFunc
		throw ex
	}
;	End:GetFormat() ;}

; End:Method ;}
}
/*!
	End of class
*/