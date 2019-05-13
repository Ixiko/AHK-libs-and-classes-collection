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
		Provides the **abstract** base class for a strongly typed collection of key/value pairs.
	Inherits: MfEnumerableBase
*/
class MfDictionaryBase extends MfEnumerableBase
{
	m_Hashtable		:= ""
	m_count			:= 0
	m_IsReadOnly	:= false
	m_IsFixedSize	:= false
	m_capacity := 0
;{ Constructor
	/*
		Constructor: ()
			Constructor for Abstract MfDictionaryBase Class
		Remarks:
			Derived classes must call `base.__New()` in their constructors.  
			Abstract Class
		Throws:
			Throws MfNotSupportedException if this Abstract class constructor is called directly.
	*/
	__New(capacity = 0) {
		; Throws MfNotSupportedException if MfDictionaryBase Abstract class constructor is called directly.
		if (this.__Class = "MfDictionaryBase") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass", "MfDictionaryBase"))
		}
		base.__New()
		this.m_isInherited := false
		this.m_capacity := MfInteger.GetValue(capacity)
		;this.m_Hashtable := {}
	}
; End:Constructor ;}	
;{ Methods
;{ 	Add()
/*
	Method: Add()
	
	instance.Add(key, value)
	
	Add(key, value)
		Adds an element with the specified key and value into the MfDictionaryBase instance.
	Parameters
		key
			The key of the element to add.
		value
			The value of the element to add.
	Throws
		Throws MfNullReferenceException if MfDictionaryBase is not set to an instance.
		Throws MfNotSupportedException if the MfDictionaryBase is read-only or The MfDictionaryBase has a fixed size.
		Throws MfNotSupportedException if key is an object and does not derive from MfObject
		Throws MfArgumentNullException if key is null.
	Remarks
		An object that has no correlation between its state and its hash code value should typically not be used as the key.
		You can also use the Item property to add new elements by setting the value of a key that does not exist in the MfDictionaryBase;
		for example, myCollection.Item["myNonexistentKey"] = myValue
		However, if the specified key already exists in the MfDictionaryBase, setting the Item property overwrites the old value.
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
		if (this.Contains(key)) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("ArgumentException_KeyExist", this.__Class))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		this.OnValidate(key, value)
		this.OnInsert(key, value)
		this.InnerHashtable.Item[key] := value
		this.m_count ++
		try
		{
			this.OnInsertComplete(key, value)
		}
		catch e
		{
			this.InnerHashtable.Remove(key)
			this.m_count --
			throw e
		}
	}
;	End:Add(value) ;}
;{	Clear()
/*
	Method: Clear()
	
	instance.Clear()

	Clear()
		Clears the contents of the MfDictionaryBase instance.
		Count is set to zero, and references to other objects from elements of the collection are also released.
	Throws
		Throws MfNullReferenceException if MfDictionaryBase is not set to an instance.
*/
	Clear() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.OnClear()
		this.m_Hashtable := ""
		this.OnClearComplete()
	}
;		End:Clear() ;}
;{ 	Contains()
/*
	Method: Contains()
	
	OutputVar := instance.Contains(key)
	
	Contains(key)
		Determines whether the MfDictionaryBase contains a specific element.
	Parameters
		key
			The Key to locate in the MfDictionaryBase
	Returns
		Returns true if the MfDictionaryBase contains the specified key otherwise, false.
	Throws
		Throws MfNotSupportedException if key is an object and does not derive from MfObject
*/
	Contains(key) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.InnerHashtable.Contains(key)) {
			return true
		}
		return false
	}
;	End:Contains(value) ;}
;{ 	Enumerator
;{ 		_NewEnum
	_NewEnum() {
        return new MfDictionaryBase.Enumerator(this)
    }
; 		End:_NewEnum ;}
;{ 		class Enumerator
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
;{	OnClear()
/*
	Method: OnClear()

	OnClear()
		Performs additional custom processes when clearing the contents of the MfDictionaryBase instance.
	Remarks
		Protected method.
		The default implementation of this method is intended to be overridden by a derived class to perform some action before the collection is cleared.
		The On* methods are invoked only on the instance returned by the Dictionary property, but not on the instance returned by the InnerHashtable property.
		OnClear is invoked before the standard Clear behavior, whereas OnClearComplete is invoked after the standard Clear behavior.
*/
	OnClear() {
		
	}
;	End:OnClear() ;}
;{	OnClearComplete()
/*
	Method: OnClearComplete()

	OnClearComplete()
		Performs additional custom processes after clearing the contents of the MfDictionaryBase instance.
	Remarks
		Protected method.
		The default implementation of this method is intended to be overridden by a derived class to perform some action after the collection is cleared.
		The On* methods are invoked only on the instance returned by the Dictionary property, but not on the instance returned by the InnerHashtable property.
*/
	OnClearComplete() {
		
	}
;	End:OnClearComplete() ;}	
;{ 	OnInsert()
/*
	Method: OnInsert()

	OnInsert(key, value)
		Performs additional custom processes before inserting a new element into the MfDictionaryBase instance.
	Parameters
		key
			The key of the element to insert.
		value
			The value of the element to insert
	Remarks
		Protected method.
		The default implementation of this method is intended to be overridden by a derived class to perform some action before the specified element is inserted.
		The On* methods are invoked only on the instance returned by the Dictionary property, but not on the instance returned by the InnerHashtable property.
		Notes to Implementers
		This method allows implementers to define processes that must be performed before inserting the element into the underlying Hashtable.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnInsert is invoked before the standard Insert behavior, whereas OnInsertComplete is invoked after the standard Insert behavior.
*/
	OnInsert(key, ByRef value) {
		
	}
;	End:OnInsert(index, value) ;}	
;{ 	OnInsertComplete()
/*
	Method: OnInsertComplete()

	OnInsertComplete(key, value)
		Performs additional custom processes after inserting a new element into the MfDictionaryBase instance.
	Parameters
		key
			The key of the element to insert.
		value
			The value of the element to insert.
	Remarks
		Protected method.
		The default implementation of this method is intended to be overridden by a derived class to perform some action after the specified element is inserted.
		The On* methods are invoked only on the instance returned by the Dictionary property, but not on the instance returned by the InnerHashtable property.
		Notes to Implementers
		This method allows implementers to define processes that must be performed before setting the specified element in the underlying Hashtable.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnInsert is invoked before the standard Insert behavior, whereas OnInsertComplete is invoked after the standard Insert behavior.
*/
	OnInsertComplete(key, ByRef value) {
		
	}
;	End:OnInsertComplete(index, value) ;}	
;{ 	OnRemove
/*
	Method: OnRemove()

	OnRemove(key, value)
		Performs additional custom processes before removing an element from the current instance
	Parameters
		key
			The key of the element to remove.
		value
			The value of the element to remove.
	Remarks
		Protected method.
		The default implementation of this method is intended to be overridden by a derived class to perform some action when the specified element is validated.
		The On* methods are invoked only on the instance returned by the Dictionary property, but not on the instance returned by the InnerHashtable property.
		Notes to Implementers
		This method allows implementers to define processes that must be performed before setting the specified element in the underlying Hashtable.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnRemove is invoked before the standard Remove behavior, whereas OnRemoveComplete is invoked after the standard Remove behavior.
*/
	OnRemove(key, ByRef value) {
		
	}
; 	End:OnRemove ;}
;{ 	OnRemoveComplete
/*
	Method: OnRemoveComplete()

	OnRemoveComplete(key, value)
		Performs additional custom processes after removing an element from the MfDictionaryBase instance.
	Parameters
		key
			The key of the element to remove.
		value
			The value of the element to remove.
	Remarks
		Protected method.
		The default implementation of this method is intended to be overridden by a derived class to perform some action after the specified element is removed.
		The On* methods are invoked only on the instance returned by the Dictionary property, but not on the instance returned by the InnerHashtable property.
		Notes to Implementers
		This method allows implementers to define processes that must be performed before setting the specified element in the underlying Hashtable.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnRemove is invoked before the standard Remove behavior, whereas OnRemoveComplete is invoked after the standard Remove behavior.
*/
	OnRemoveComplete(key, ByRef value) {
		
	}
; 	End:OnRemoveComplete ;}
;{ 	OnSet
/*
	OnSet()

	OnSet(key, oldValue, newValue)
		Performs additional custom processes before setting a value in the MfDictionaryBase instance.
	Parameters
		key
			The key of the element to locate.
		oldValue
			The old value of the element associated with key.
		newValue
			The new value of the element associated with key.
	Remarks
		Protected method.
		The default implementation of this method is intended to be overridden by a derived class to perform some action before the specified element is set.
		The On* methods are invoked only on the instance returned by the Dictionary property, but not on the instance returned by the InnerHashtable property.
		Notes to Implementers
		This method allows implementers to define processes that must be performed before setting the specified element in the underlying Hashtable.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnSet is invoked before the standard Set behavior, whereas OnSetComplete is invoked after the standard Set behavior.
*/
	OnSet(key, ByRef oldValue, ByRef newValue) {
		
	}
; 	End:OnSet ;}
;{ 	OnSetComplete
/*
	Method: OnSetComplete()

	OnSetComplete(key, oldValue, newValue)
		Performs additional custom processes before setting a value in the MfDictionaryBase instance.
	Parameters
		key
			The key of the element to locate.
		oldValue
			The old value of the element associated with key.
		newValue
			The new value of the element associated with key.
	Remarks
		Protected method.
		The default implementation of this method is intended to be overridden by a derived class to perform some action before the specified element is set.
		The On* methods are invoked only on the instance returned by the Dictionary property, but not on the instance returned by the InnerHashtable property.
		Notes to Implementers
		This method allows implementers to define processes that must be performed before setting the specified element in the underlying Hashtable.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnSet is invoked before the standard Set behavior, whereas OnSetComplete is invoked after the standard Set behavior.
*/
	OnSetComplete(key, ByRef oldValue, ByRef newValue) {
		
	}
; 	End:OnSetComplete ;}
;{ 	OnValidate()
/*
	Method: OnValidate()

	OnValidate(key, value)
		Performs additional custom processes when validating the element with the specified key and value.
	Parameters
		key
			The key of the element to validate.
		value
			The value of the element to validate.
	Remarks
		Protected method.
		The default implementation of this method is intended to be overridden by a derived class to perform some action when the specified element is validated.
		The On* methods are invoked only on the instance returned by the Dictionary property, but not on the instance returned by the InnerHashtable property.
		Notes to Implementers
		This method allows implementers to define processes that must be performed before setting the specified element in the underlying Hashtable.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnValidate can be used to impose restrictions on the type of objects that are accepted into the collection.
		The default implementation prevents Nothing from being added to or removed from the underlying Hashtable.
	*/
	OnValidate(key, ByRef value) {
		
	}
;	End:OnValidate(obj) ;}	
;{ 	Remove()
/*
	Method: Remove()
	
	instance.Remove(key)

	Remove(key)
		Removes the first occurrence of a specific object from the MfDictionaryBase.

	Parameters
		key
			The key of the element to remove.
	Throws
		Throws MfNullReferenceException if MfDictionaryBase is not set to an instance.
		Throws MfNotSupportedException if the MfDictionaryBase is read-only or The MfDictionaryBase has a fixed size.
		Throws MfNotSupportedException if key is an object and does not derive from MfObject
	Remarks
		If the MfDictionaryBase does not contain an element with the specified key, the MfDictionaryBase remains unchanged. No exception is thrown.
*/
	Remove(key)	{
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
		if (!this.InnerHashtable.Contains(key)) {
			return
		}
		value := this.InnerHashtable.Item[key]
		this.OnValidate(key, value)	
		this.OnRemove(key, value)
		this.InnerHashtable.Remove(key)
		try
		{
			this.OnRemoveComplete(key, value)
		}
		catch e
		{
			this.InnerHashtable.Item[_key] := value
			throw e
		}
	}
;	End:Remove(value) ;}

; End:Methods ;}	

;{ Properties
;{ InnerHashtable
	/*
	Property: InnerHashtable [get]
		Gets the list of elements contained in the MfDictionaryBase instance.
	Remarks:
		This Property is readonly.
		The On* methods are invoked only on the instance returned by the Dictionary property, but not on the instance returned by the InnerHashtable property.
	*/
	InnerHashtable
	{
		get {
			if (!this.m_Hashtable) {
				this.m_Hashtable := new MfHashTable(this.m_capacity)
			}
			return this.m_Hashtable
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; End:InnerHashtable ;}
;{ 	Count[]
	/*
	Property: Count [get]
		Gets the number of elements contained in the MfDictionaryBase instance.
	Value:
		var containing an Integer representing the current count
	Remarks:
		This property is readonly
	*/
	Count[]
	{
		get {
			Return this.InnerHashtable.Count
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Count[] ;}
;{ 	Dictionary
	/*
	Property: Dictionary [get]
		Gets the list of elements contained in the MfDictionaryBase instance
	Value:
		MfDictionaryBase instance representing the current MfDictionaryBase instance.
	Remarks:
		This property is read-only and is intended to be a protected property.
		The On* methods are invoked only on the instance returned by the Dictionary property,
		but not on the instance returned by the InnerHashtable property.
	*/
	Dictionary[]
	{
		get {
			return this
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Dictionary ;}
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
			return this.m_IsFixedSize
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
			return this.m_IsReadOnly
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
			Return this.InnerHashtable.Keys
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
			Return this.InnerHashtable.Values
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
			obj := this.InnerHashtable.Item[key] ; value could be 0
			if (MfNull.IsNull(obj)) {
				obj := MfNull.Null
			}
			this.OnGet(key, obj)
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
			this.OnValidate(key, value)

			_HasKey := this.InnerHashtable.Contains(key)
			obj := MfNull.Null
			if (_HasKey)
			{
				try
				{
					obj := this.InnerHashtable.Item[key]
				}
				catch err
				{
					if (MfObject.IsObjInstance(err, MfNotSupportedException))
					{
						obj := MfNull.Null
					}
					else
					{
						Throw err
					}
				}
			}
			this.OnSet(key, obj, value)
			this.InnerHashtable.Item[key] := value
			try {
				this.OnSetComplete(key, obj, value)
			} catch e {
				if (_HasKey) {
					this.InnerHashtable.Item[key] := obj
				} else {
					this.InnerHashtable.Delete(key)
				}
				throw e
			}
		}
	}
;	End:Item[index] ;}
; End:Properties ;}

}
/*
	End of class
*/