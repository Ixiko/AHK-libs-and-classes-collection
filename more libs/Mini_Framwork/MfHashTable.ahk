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
	Class: MfDictionaryBase
		Provides class for a strongly typed collection of key/value pairs.
	Inherits: MfEnumerableBase
*/
Class MfHashTable extends MfEnumerableBase
{
	m_innerHashTable := ""
	m_keycomparer := null
	m_version := 0
	m_capacity := 0
	m_isWriterInProgress := False
	Static KeysName := "Keys"
	Static LoadFactorName := "LoadFactor"

	__New(capacity = 0) {
		Base.__New()
		this.m_isInherited := this.__Class != "MfHashTable"
		this.m_capacity := MfInteger.GetValue(capacity)
		this.m_innerHashTable := {}
		this.m_innerHashTable.SetCapacity(this.m_capacity)
	}
;{ Methods
;{ 	Add()
/*
	Method: Add()
	Add(key, value)
		Adds an element with the specified key and value into the MfHashTable instance.
	Parameters:
		key
			The key of the element to add.
		value
			The value of the element to add.
	Throws:
		Throws MfNullReferenceException if called as a static method.
		Throws MfNotSupportedException if key is an object and does not derive from MfObject
		Throws MfArgumentNullException if key is null.
	Remarks:
		An object that has no correlation between its state and its hash code value should typically not be used as the key.
		You can also use the Item property to add new elements by setting the value of a key that does not exist in the MfHashTable; for example,
		MyHashTable.Item["myNonexistentKey"] := myValue.
		However, if the specified key already exists in the MfDictionary, setting the Item property overwrites the old value.
		In contrast, the Add method does not modify existing elements.
*/
	Add(key, value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.IsReadOnly) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Dictionary"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.IsFixedSize) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FixedSize"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_key := this.GetHash(key)
		if (this.Contains(_key)) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentException_KeyExist", this.__Class))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_isWriterInProgress := true
		this.m_innerHashTable[_key] := value
		this.m_count ++
		this._UpdateVersion()
		this.m_isWriterInProgress := false
	}
; 	End:Add() ;}
;{ 	Clear()
/*
	Method: Clear()
	Clear()
		Clears the contents of the MfHashTable instance.
		Count is set to zero, and references to other objects from elements of the collection are also released.
	Throws:
		Throws MfNullReferenceException if MfHashTable is not set to an instance.
*/
	Clear() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.m_isWriterInProgress := true
		this.m_innerHashTable := {}
		this.m_innerHashTable.SetCapacity(this.m_capacity)
		this.m_count := 0
		this.m_isWriterInProgress := false
	}
; 	End:Clear() ;}
;{ 	Contains()
/*
	Method: Contains()

	OutputVar := instance.Contains(key)

	Contains(key)
		Determines whether the MfHashTable contains a specific element.
	Parameters:
		key
			The Key to locate in the MfHashTable
	Returns:
		Returns true if the MfHashTable contains the specified key otherwise, false.
	Throws:
		Throws MfNotSupportedException if key is an object and does not derive from MfObject
	Remarks:
		Functionally identical to ContainsKey()
*/
	Contains(key) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return this.ContainsKey(key)
	}
; 	End:Contains() ;}
/*
	Method: ContainsKey()

	OutputVar := instance.ContainsKey(key)

	ContainsKey(key)
		Determines whether the MfHashTable contains a specific element.
	Parameters:
		key
			The Key to locate in the MfHashTable
	Returns:
		Returns true if the MfHashTable contains the specified key otherwise, false.
	Throws:
		Throws MfNotSupportedException if key is an object and does not derive from MfObject
	Remarks:
		Functionally identical to Contains()
*/
	ContainsKey(key) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_key := this.GetHash(key)
		if (this.m_innerHashTable.HasKey(_key)) {
			return true
		}
		return false
	}
;{ 	ContainsValue()
/*
	Method: ContainsValue()

	OutputVar := instance.ContainsKey(value)

	ContainsKey(Value)
		Determines whether the MfHashTable contains a specific element.
	Parameters:
		value
			The value to locate in the MfHashTable
	Returns:
		Returns true if the MfHashTable contains the specified value otherwise, false.
	Remarks:
		The values of the elements of the MfHashTable are compared to the specified value using the MfObject.Equals() method.
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
*/
	ContainsValue(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		bObj := IsObject(value)
		retval := false
		if (this.m_InnerList.Count <= 0) {
			return retval
		}
		for k, v in this.m_innerHashTable
		{
			if (bObj) {
				try {
					if (v.Equals(value)) {
						retval := true
						break
					}
				} catch e {
					continue
				}
			} else {
				if (value = v) {
					retval := true
					break
				}
			}
		}
		return retval
	}
; 	End:ContainsValue() ;}
;{ 	GetHash()
/*
	Method: GetHash()

	OutputVar := this.GetHash(key)

	GetHash(key)
		Returns the hash code for the specified key.
	Parameters:
		key
			The Object for which a hash code is to be returned.
			Can be var or any object that is derived from MfObject.
	Returns:
		Returns Var Integer
	Throws:
		Throws MfArgumentException if key is null.
		Throws MfNotSupportedException if key is an object and does not derive from MfObject
	Remarks:
		Protected method.
*/
	GetHash(key) {
		if (MfNull.IsNull(key)) {
			ex := new MfArgumentNullException("key", MfEnvironment.Instance.GetResourceString("ArgumentNull_Key"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (IsObject(key))
		{
			if (MfObject.IsObjInstance(key))
			{
				return key.GetHashCode()
			}
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NonMfObjectException_General"), "key")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return key
	}
; 	End:GetHash() ;}
;{ 	Remove()
/*
	Method: Remove()
	Remove(key)
		Removes the first occurrence of a specific object from the MfHashTable.
	Parameters:
		key
			The key of the element to remove.
	Throws:
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentException if key is null.
		Throws MfNotSupportedException if the MfHashTable is read-only or The MfHashTable has a fixed size.
		Throws MfNotSupportedException if key is an object and does not derive from MfObject
	Remarks:
		If the MfHashTable does not contain an element with the specified key, the MfHashTable remains unchanged.  No exception is thrown.
*/
	Remove(key) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.IsReadOnly) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Dictionary"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.IsFixedSize) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FixedSize"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_key := this.GetHash(key)
		if (!this.Contains(_key)) {
			return
		}
		this.m_isWriterInProgress := true
		; Delete() returns the object removed from that hash table
		if (this.m_innerHashTable.Delete(_key)) {
			this.m_count --
			this._UpdateVersion()
		}
		this.m_isWriterInProgress := false
	}
; 	End:Remove() ;}

	_UpdateVersion() {
		this.m_version ++
	}
	;{ 	Enumerator
;{ 		_NewEnum()
/*
	Method: _NewEnum()
		Overrides MfEnumerableBase._NewEnum()
		This abstract method must be overridden in derived classes.
	_NewEnum()
		Returns a new enumerator to enumerate this object's key-value pairs.
		This method is usually not called directly, but by the for-loop or by GetEnumerator()
	Remarks:
		Protected Method.
*/
	_NewEnum() {
        return new MfHashTable.Enumerator(this)
    }
; 		End:_NewEnum() ;}
;{ 		internal class Enumerator
    class Enumerator
	{
		m_Parent := Null
		m_KeyEnum := Null
		m_index := 0
		m_count := 0
        __new(ParentClass) {
            
            this.m_Parent := ParentClass
			this.m_KeyEnum := this.m_Parent.Keys
			if (this.m_KeyEnum) {
				this.m_count := this.m_KeyEnum.Count
			}
        }
        
       Next(ByRef key, ByRef value)
	   {
		
			if (this.m_index < this.m_count) {
				key := this.m_KeyEnum.Item[this.m_index]
				value := this.m_Parent.Item[key]
			}
			this.m_index++
			if (this.m_index > (this.m_count)) {
				return 0
			} else {
				return true
			}
        }
		
		
    }
; 		End:class Enumerator ;}
; 	End:Enumerator ;}
; End:Methods ;}
;{ Properties
;{ Count
		m_Count := 0
/*
	Property: Count [get]
		Gets the Count value associated with the this instance
	Value:
		Var representing the Count property of the instance
	Remarks:
		Readonly Property
*/
	Count[]
	{
		get {
			return this.m_Count
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "Count")
			Throw ex
		}
	}
; End:Count ;}
;{	IsFixedSize[]
/*
	Property: IsFixedSize [get]
		Gets a value indicating whether the MfDictionaryBase has a fixed size.
	Remarks:
		Returns true if the MfDictionaryBase has a fixed size; Otherwise false.
		This property is readonly
*/
	IsFixedSize[]
	{
		get {
			return False
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsFixedSize[] ;}
;{	IsReadOnly[]
/*
	Property: IsReadOnly [get]
		Gets a value indicating whether the MfDictionaryBase is read-only.
	Remarks:
		Returns true if the MfDictionaryBase has a read-only; Otherwise false.
		This property is readonly
*/
	IsReadOnly[]
	{
		get {
			return False
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsReadOnly[] ;}
;{ 	Keys
/*
	Property: Keys [get]
		Gets an MfCollection instance containing the keys in the MfDictionaryBase instance.
	Remarks:
		Readonly property.  
		The order of the keys in the MfCollection object is unspecified, but is the same order as the associated values in the
		MfCollection object returned by the Values property.
		If object derived from MfObject are used as keys then hashcode for those objects is stored as keys.
		If the keys are store from the Hashcodes then this Keys property will return a MfCollection containing the hashcodes as keys.
		The MfDictionaryBase will be able to use these keys for Item Property, Contains method and Remove method.
*/
	Keys[]
	{
		get {
			col := new MfCollection()
			for k, v in this.m_innerHashTable
			{
				col.Add(k)
			}
			return col
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Keys ;}

;{ 	Values
/*
	Property: Values [get]
		Gets an MfCollection instance containing the values in the MfDictionaryBase instance.
	Value:
		Sets the value of the derived enum class
	Remarks:
		Readonly property.  
		The order of the Keys in the MfCollection object is unspecified, but is the same order as the associated values
		in the MfCollection object returned by the Values property.
*/
	Values[]
	{
		get {
			col := new MfCollection()
			for k, v in this.m_innerHashTable
			{
				col.Add(v)
			}
			return col
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Values ;}
;{	Item[Key]
/*
	Property: Item[Key] [get/set]
		Gets or sets the value associated with the specified key.
	Parameters:
		key
			The key whose value to get or set.
	Value:
		The value to set for the key whose value to set.

	Throws:
		Throws MfArgumentNullException if key is null.
		Throws MfNotSupportedException if key is an object and does not derive from MfObject

	Get Throws:
		Throws MfNotSupportedException if key is not in Dictionary.

	Set Throws:
		Throws MfNotSupportedException if Dictionary is IsReadOnly.
		Throws MfNotSupportedException if Dictionary is IsFixedSize.

	Remarks:
		The value associated with the specified key. If the specified key is not found, attempting to get it returns MfNull,
		and attempting to set it creates a new element using the specified key.
		On Set if key element is not null then OnSet and OnSetComplete will contain MfNull for the obj parameter..  
*/
	Item[key]
	{
		get {
			_key := this.GetHash(key)
			if (!this.Contains(_key)) {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_KeyNotFound"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			obj := this.m_innerHashTable[_key] ; value could be 0
			if (MfNull.IsNull(obj)) {
				obj := MfNull.Null
			}
			return obj
		}
		set {
			if (this.IsReadOnly) {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Dictionary"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (this.IsFixedSize) {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FixedSize"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_key := this.GetHash(key)			
			_HasKey := true	
			obj := this.m_innerHashTable[_key]
			if (!obj) {
				_HasKey := this.Contains(_key)
				obj := MfNull.Null
			}
			this.m_innerHashTable[_key] := value
			if (!_HasKey) {
				this.m_count ++
			}
		}
	}
;	End:Item[index] ;}
; End:Properties ;}
}