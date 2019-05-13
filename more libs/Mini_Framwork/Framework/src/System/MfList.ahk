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
	Class: MfList
		MfList class exposes methods and properties used for common List and array type operations for strongly typed collections.
	Inherits:
		MfListBase
*/
class MfList extends MfListBase
{
;{ Constructor
	/*!
		Constructor: ()
			Initializes a new instance of the MfList class.
	*/
	__New() {
		base.__New()
		this.m_isInherited := this.__Class != "MfList"
	}
; End:Constructor ;}
;{ Methods
;{ 	Clone
	Clone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		cLst := new MfList()
		cLst.Clear()
		cl := cLst.m_InnerList
		ll := this.m_InnerList
		for i, v in ll
		{
			cl[i] := v
		}
		cLst.m_Count := this.m_Count
		return cLst
	}
; 	End:Clone ;}

; End:Methods ;}
}
/*!
	End of class
*/