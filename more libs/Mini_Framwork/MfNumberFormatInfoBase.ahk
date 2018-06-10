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

;{ Class MfNumberFormatInfoBase
;{ Class Comments
/*!
	Class: MfNumberFormatInfoBase
		Provides Property implementation for derived classes.
		This class in intended as a base class only an is **not** to be
		used on it own.  
		Abstract Class		
	Inherits: MfFormatProvider
*/
; End:Class Comments ;}
class MfNumberFormatInfoBase extends MfFormatProvider
{
;{ Constructor: ()
/*
	Method: Constructor()
		Constructor for class MfNumberFormatInfoBase Class
	Throws;
		Throws MfNotSupportedException if this Abstract class constructor is called directly.
*/
	__New() {
		; Throws MfNotSupportedException if MfNumberFormatInfoBase Abstract class constructor is called directly.
		if (this.__Class = "MfNumberFormatInfoBase") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass"
			, "MfNumberFormatInfoBase"))
		}
		base.__New()
		this.m_isInherited := true
	}
; End:Constructor: () ;}
;{ Properties
;{		CurrentInfo
/*
	Property: CurrentInfo [get]
		Gets a read-only MfNumberFormatInfo that formats values based on the current culture.
		Must be overridden in derived classes.
	Value:
		Instance of MfNumberFormatInfo
	Gets:
		Gets a read-only MfNumberFormatInfo
	Throws:
		Throws MfNotImplementedException Abstract property
*/
	CurrentInfo[]
	{
		get {
			ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName"
			, "CurrentInfo"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		set {
			ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName"
			, "CurrentInfo"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
;		End:CurrentInfo ;}
;{		InvariantInfo
/*
	Property: InvariantInfo [get]
		Gets the default read-only MfNumberFormatInfo that is culture-independent (invariant).
		Must be overridden in derived classes.
	Value:
		MfNumberFormatInfo instance.
	Gets:
		Gets the default read-only MfNumberFormatInfo that is culture-independent (invariant).
	Throws:
		Throws MfNotImplementedException Abstract property
*/
	InvariantInfo[]
	{
		get
		{
			ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName"
			, "InvariantInfo"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		set {
			ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName"
			, "InvariantInfo"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
;		End:InvariantInfo ;}
; End:Properties ;}	
}
/*!
	End of class
*/
; End:Class MfNumberFormatInfoBase ;}