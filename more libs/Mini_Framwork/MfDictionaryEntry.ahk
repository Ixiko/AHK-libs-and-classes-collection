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

;{ Class MfDictionaryEntry
;{ Class Comments
/*!
	Class: MfDictionaryEntry
		Defines a dictionary key/value pair that can be set or retrieved.
	Inherits: MfValueType
*/
; End:Class Comments ;}
class MfDictionaryEntry extends MfValueType
{
;{ Constructor: ()
/*
	Constructor()
		Initializes an instance of the MfDictionaryEntry type with the specified key and value.

	OutputVar := new MfDictionaryEntry(Key, value)

	Parameters
		key
			The key defined in each key/value pair. Sets the value of Key property.
		value
			The definition associated with key. Sets the value of the Value property.
*/
	__New(key, value) {
		base.__New()
		this.m_isInherited := this.__Class != "MfDictionaryEntry"
		;{ 	Internal Members
		if (!key) {
			msg := MfString.Format(MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName"), "key")
			ex := new MfArgumentException("key", msg)
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
		;~ if (!value) {
			;~ msg := MfString.Format(MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName"), "value")
			;~ ex := new MfArgumentException("value", msg)
			;~ ex.Source := A_ThisFunc
			;~ ex.File := A_LineFile
			;~ ex.Line := A_LineNumber
			;~ throw ex
		;~ }
		this.m_Key := key
		this.m_Value := value
; 	End:Internal Members ;}
	}
; End:Constructor: () ;}
;{ Method

; End:Method ;}
;{ Properties
;{ 	Key
/*
	Property: Key [get/set]
		Gets or sets the key in the key/value pair.
	Value:
		Sets the value of the derived enum class
	Remarks:
		In derived classes this propery gets the value associated with the instance.
	Throws:
		Throws MfArgumentException if key is set to null
*/
	Key[]
	{
		get {
			return this.m_Key
		}
		set {
			if (!value) {
			msg := MfString.Format(MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName"), "value")
			ex := new MfArgumentException("value", msg)
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			throw ex
		}
			this.m_Key := value
			return this.m_Key
		}
	}
; 	End:Key ;}
;{ 	Value
/*
	Property: Value [get/set]
		Gets or sets the value in the key/value pair.
	Value:
		Sets the value of the derived enum class
	Remarks:
		In derived classes this propery gets the value associated with the instance.
*/
	Value[]
	{
		get {
			return this.m_Value
		}
		set {
			this.m_Value := value
			return this.m_Value
		}
	}
; 	End:Value ;}
; End:Properties ;}	
}
/*!
	End of class
*/
; End:Class MfDictionaryEntry ;}