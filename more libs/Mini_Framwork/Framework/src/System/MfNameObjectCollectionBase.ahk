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
	Class: MfNameObjectCollectionBase
		Represents a first-in, first-out collection of objects.
	Inherits: MfCollectionBase
	Extra:
		## Includes
		* [MfObject](MfObject.html)
		* [MfCollectionBase](MfCollectionBase.html)
		* [MfNull](MfNull.html)
		* [MfEnumerableBase](MfEnumerableBase.html)
		* [MfInvalidOperationException](MfInvalidOperationException.html)
*/
class MfNameObjectCollectionBase extends MfCollectionBase
{
	m_entriesTable 				:= Null
	m_entriesList 				:= Null
	m_Keys 						:= Null
	m_IsReadOnly 				:= false
	m_version 					:= Null
	static ComparerName 		:= "Comparer"
	static CountName 			:= "Count"
	static KeyComparerName 		:= "KeyComparer"
	static KeysName 			:= "Keys"
	static ReadOnlyName 		:= "ReadOnly"
	static ValuesName 			:= "Values"
	static VersionName 			:= "Version"
	
	
	__New() {
		base.__New()
		this.m_entriesList := new MfList()
		this.m_entriesTable := {} ; associative array object
		this.m_version := -1
	}

;{ Properties
	Count[]
	{
		get {
			return this.m_entriesList.Count
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
	
	Comparer[]
	{
		get {
			return this.m_Comparer
		}
		set {
			this.m_Comparer := value
			return this.m_Comparer
		}
	}

	IsReadOnly[]
	{
		get {
			return this.m_IsReadOnly
		}
		set {
			this.m_IsReadOnly := value
			return this.m_IsReadOnly
		}
	}
	
	Keys[]
	{
		get {
			if (MfNull.IsNull(this.m_Keys)) {
				this.m_Keys := new MfNameObjectCollectionBase.KeysCollection(this)
			}
			return this.m_Keys
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			Throw ex
		}
	}
	
	Item[index]
	{
		get {
			return this.m_Coll.Item[index]
		}
		set {
			this.m_Coll.Item[index] := value
			return this.m_Coll.Item[index]
		}
	}
	
; End:Properties ;}
	
;{ Class KeysCollection
	class KeysCollection extends MfCollectionBase
	{
		m_Coll := Null
		__New(coll) {
			base.__New()
			this.m_Coll := coll
			this.m_Pos := -1
			this.m_version := col.m_version
		}
		Get(index)
		{
			return this.m_coll.BaseGetKey(index)
		}
;{	Properties
		Count[]
		{
			get {
				if (this.m_Coll) {
					return this.m_Coll.Count
				}
				return 0
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.Source := A_ThisFunc
				Throw ex
			}
		}
		
		Item[index]
		{
			get {
				return this.m_Coll.Item[index]
			}
			set {
				this.m_Coll.Item[index] := value
				return this.m_Coll.Item[index]
			}
		}
;	End:Properties ;}
	}
; End:Class KeysCollection ;}
;{ class NameObjectEntry
		; internal Class
		class NameObjectEntry extends MfObject
		{
			Key := ""
			Value := ""
			__New(name, obj) {
				base.__New()
				this.Key := name
				this.Value := obj
			}
		}
; End:class NameObjectEntry ;}
;{ class NameObjectKeysEnumerator
	class NameObjectKeysEnumerator extends MfEnumerableBase
	{
		m_Coll := Null
		m_Pos := -1
		m_version := 0
		__New(coll) {
			base.__New()
			this.m_Coll := coll
			this.m_Pos := -1
			this.m_version := col.m_version
		}
		
		MoveNext()
		{
			if (this.m_version != this.m_coll.m_version)
			{
				ex := new MfInvalidOperationException("Invalid version. Enumerator failed version:")
				ex.Source := A_ThisFunc
				throw ex
				
			}
			if (this.m_pos < this.m_coll.Count - 1)
			{
				this.m_pos++
				return true
			}
			this.m_pos := this.m_coll.Count
			return false
		}
		
		Reset() {
			if (this.m_version != this.m_coll.m_version)
			{
				ex := new MfInvalidOperationException("Invalid version. Enumerator failed version:")
				ex.Source := A_ThisFunc
				throw ex
				
			}
			this.m_pos := -1
		}
;{	Properties
		Current[]
		{
			get {
				if ((this.m_pos >= 0) && (this.m_pos < this.m_coll.Count))
				{
					return this.m_coll.BaseGetKey(this.m_pos)
				}
				ex := new MfInvalidOperationException(MfEnvironment.Instance.GetResourceString("ExInvalidOperationException_InvalidEnum"))
				ex.Source := A_ThisFunc
				throw ex
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.Source := A_ThisFunc
				Throw ex
			}
		}
;	End:Properties ;}
	}
; End:class NameObjectKeysEnumerator ;}

}
/*!
	End of class
*/