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

;{ class comments
/*!
	Class: MfValueType
		Provides MfValueType implementation for derived classes such as MfInteger and MfString
			This class in intended as a base class only an is not to be used on it own.
			Abstract Class.
	Inherits:
		MfObject
*/
; End:class comments ;}
class MfValueType extends MfObject
{
;{ Constructor: ()
/*
		Constructor: ()
			Constructor for Abstract MfValueType Class
		Remarks:
			Derived classes must call base.__New() in their constructors.
		Throws:
			Throws MfNotSupportedException if this Abstract class constructor is called directly.
*/
	__New() {
		if (base.__Class = "MfValueType") {
			throw new MfNotSupportedException(MfString.Format(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass"), base.__Class))
		}
		base.__New()
		this.m_isInherited := this.__Class != "MfValueType"
	}
; End:Constructor: () ;}

}
/*!
	End of class
*/