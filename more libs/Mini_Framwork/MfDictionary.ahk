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
	Class: MfDictionary
		Provides class for a strongly typed collection of key/value pairs.
	Inherits: MfDictionaryBase
*/
class MfDictionary extends MfDictionaryBase
{
	m_Enum := Null
;{ Constructor
	/*
		Constructor: ()
			Constructor for MfDictionary Class
	*/
	__New() {
		base.__New()
		this.m_isInherited := this.__Class != "MfDictionary"
	}
; End:Constructor ;}	
;{ Methods

; End:Methods ;}	

;{ Properties

;{	IsFixedSize		- Overrides	- MfDictionaryBase
	/*
		Property: IsFixedSize [get]
			Gets a value indicating whether the MfDictionary has a fixed size.  
			Overrides MfDictionaryBase.IsFixedSize
		Remarks:
			Returns false. 
			This property is readonly
	*/
	IsFixedSize[]
	{
		get {
			return false
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			Throw ex
		}
	}
;	End:IsFixedSize[] ;}
;{	IsReadOnly		- Overrides	- MfDictionaryBase
	/*
		Property: IsReadOnly [get]
			Gets a value indicating whether the MfDictionary is read-only.  
			Overrides MfDictionaryBase.IsReadOnly
		Remarks:
			Returns false.
			This property is readonly
	*/
	IsReadOnly[]
	{
		get {
			return false
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			Throw ex
		}
	}
;	End:IsReadOnly[] ;}
; End:Properties ;}

}
/*
	End of class
*/
