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
	Class: MfCollectionBase
		Provides the abstract base class for a strongly typed collection.
	Inherits: MfEnumerableBase
*/
class MfCollectionBase extends MfEnumerableBase
{
	m_list := ""
;{ Constructor
	/*!
		Constructor: ()
			Constructor for Abstract MfCollectionBase Class
		Remarks:
			Derived classes must call `base.__New()` in their constructors.  
			Abstract Class
		Throws:
			Throws MfNotSupportedException if this Abstract class constructor is called directly.
	*/
	__New() {
		; Throws MfNotSupportedException if MfCollectionBase Abstract class constructor is called directly.
		if (this.__Class = "MfCollectionBase") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass", "MfCollectionBase"))
		}
		base.__New()
		this.m_isInherited := this.__Class != "MfCollectionBase"
	}
; End:Constructor ;}	
;{ Methods
;{ 	Add()
/*
	Method: Add()
	
	OutputVar := instance.Add(obj)

	Add(obj)
		Adds an object to the end of the MfCollectionBase.
	Parameters
		obj
			Object to be added to the end of the MfCollectionBase.
	Returns
		The MfCollectionBase index as var containing an Integer
	Throws
		Throws MfNotSupportedException if the MfCollectionBase is read-only or the MfCollectionBase has a fixed size.
		Throws MfNullReferenceException if MfCollectionBase is not set to an instance.
*/
	Add(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.OnValidate(obj)
		this.OnInsert(this.InnerList.Count, obj)
		index := this.InnerList.Add(obj)
		try
		{
			this.OnInsertComplete(index, obj)
		}
		catch e
		{
			this.InnerList.RemoveAt(index)
			err := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_AddingItem"), e)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		return index
	}
;	End:Add(value) ;}
;{ 	Clear Methods
;{		Clear()
/*
	Clear()
	
	instance.Clear()

	Clear()
		Removes all objects from the MfCollectionBase instance. This method in not to be overridden.
	Throws
		Throws MfNullReferenceException if MfCollectionBase is not set to an instance.

*/
	Clear() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.OnClear()
		this.InnerList.Clear()
		this.OnClearComplete()
	}
;		End:Clear() ;}

; 	End:Clear Methods ;}	
;{ 	Contains()
/*
	Methd: Contains()
	
	OutputVar := instance.Contains(obj)

	Contains(obj)
		Determines whether the MfCollectionBase contains a specific element.
	Parameters
		obj
			The Object to locate in the MfCollectionBase
	Returns
		Returns true if the MfCollectionBase contains the specified obj; Otherwise false.
	Throws
		Throws MfNullReferenceException if called as a static method.
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	Contains(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return this.InnerList.Contains(obj)
	}
;	End:Contains(value) ;}


;{ Enumerator
; insert this snipit inside the body of a list based class
;{ 		_NewEnum
	_NewEnum() {
        return new MfCollectionBase.Enumerator(this)
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
			this.m_count := this.m_Parent.Count
        }
        
       Next(ByRef key, ByRef value)
	   {
		
			if (this.m_index < this.m_count) {
				key := this.m_index
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
; End:Enumerator ;}

;{ 	IndexOf()
/*
	Method: IndexOf()

	OutputVar := instance.IndexOf(obj)
	
	IndexOf(obj)
		Searches for the specified Object and returns the zero-based index of the first occurrence within the entire MfCollectionBase.
	Parameters
		obj
			The object to locate in the MfCollectionBase
	Returns
		Returns var containing an Integer that is a zero-based index of the first occurrence of obj within the entire MfCollectionBase,
		if found; Oherwise Integer with a value of -1.
	Throws
		Throws MfNullReferenceException if called as a static method.
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	IndexOf(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return this.InnerList.IndexOf(obj)
	}
;	End:IndexOf() ;}
;{ 	Insert()
/*
	Method: Insert()

	instance.Insert(index, obj)
	
	Insert(index, obj)
		Inserts an element into the MfCollectionBase at the specified index.
	Parameters
		index
			The zero-based index at which value should be inserted.
		obj
			The object to insert.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentOutOfRangeException if index is less than one or index is greater than Count.
	Remarks
		If index is equal to Count, value is added to the end of MfCollectionBase.
		In collections of contiguous elements, such as MfList, the elements that follow the insertion point move down to accommodate the new element.
		This method is an O(n) operation, where n is Count.
	Notes to Implementers
		This method calls OnValidate(), OnInsert(), and OnInsertComplete().
*/
	Insert(index, obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_index := MfInteger.GetValue(index)
		if ((_index < 0) || (_index >= this.Count))
		{
			msg := MfString.Format(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_ActualValue"), index)
			err := new MfArgumentOutOfRangeException("index", msg)
			err.Source := A_ThisFunc
			throw err
		}
		this.OnValidate(obj)
		this.OnInsert(index, obj)
		this.InnerList.Insert(_index, obj)
		try
		{
			this.OnInsertComplete(index, obj)
		}
		catch
		{
			this.InnerList.RemoveAt(index)
			throw
		}
	}
;	End:Insert() ;}
;{		OnClear()
/*
	Method: OnClear()
		Performs additional custom processes when clearing the contents of the MfCollectionBase instance.
	Remarks
		Protected Method
		The default implementation of this method is intended to be overridden by a derived class to perform some action before the collection is cleared.
		If the process fails, the collection reverts back to its previous state.
		The default implementation of this method is an O(1) operation.
	Notes to Implementers
		This method allows implementers to define processes that must be performed before deleting all the elements from the underlying MfList.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnClear() is invoked before the standard Clear behavior, whereas OnClearComplete() is invoked after the standard Clear behavior.

*/
	OnClear() {
		
	}
;		End:OnClear() ;}
;{		OnClearComplete()
/*
	Method: OnClearComplete()
		Performs additional custom processes after clearing the contents of the MfCollectionBase instance.
	Remarks
		Protected Method
		The default implementation of this method is intended to be overridden by a derived class to perform some action after the collection is cleared.
		The default implementation of this method is an O(1) operation.
	Notes to Implementers
		This method allows implementers to define processes that must be performed after deleting all the elements from the underlying MfList.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnClear() is invoked before the standard Clear behavior, whereas OnClearComplete() is invoked after the standard Clear behavior.
*/
	OnClearComplete() {
		
	}
;		End:OnClearComplete() ;}	
;{ 	OnInsert()
/*
	Method: OnInsert()
	
	OnInsert(index, ByRef value)
		Performs additional custom processes before inserting a new element into the MfCollectionBase instance.
	Parameters
		index
			The zero-based index at which to insert value.
		value
			The new value of the element at index.
	Remarks
		Protected Method
		The default implementation of this method is intended to be overridden by a derived class to perform some action before the specified element is inserted.
		If the process fails, the collection reverts back to its previous state.
		The default implementation of this method is an O(1) operation.
	Notes to Implementers
		This method allows implementers to define processes that must be performed before inserting the element into the underlying MfList.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnInsert() is invoked before the standard Insert behavior, whereas OnInsertComplete() is invoked after the standard Insert behavior.
		For example, implementers can restrict which types of objects can be inserted into the System.Collections.ArrayList.
		OnValidate() is called prior to this method.
*/
	OnInsert(index, ByRef value) {
	}
;	End:OnInsert(index, value) ;}	
;{ 	OnInsertComplete()
/*!
	Method: OnInsertComplete()
	
	OnInsertComplete(index, ByRef value)
		Performs additional custom processes after inserting a new element into the MfCollectionBase instance.
	Parameters
		index
			The zero-based index at which to insert value.
		value
			The new value of the element at index.
	Remarks
		Protected Method
		The default implementation of this method is intended to be overridden by a derived class to perform some action after the specified element is inserted.
		The collection reverts back to its previous state if one of the following occurs:
			* The process fails.
			* This method is overridden to throw an exception.
		The default implementation of this method is an O(1) operation.
	Notes to Implementers
		This method allows implementers to define processes that must be performed after inserting the element into the underlying MfList.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnInsert() is invoked before the standard Insert behavior, whereas OnInsertComplete() is invoked after the standard Insert behavior.
*/
	OnInsertComplete(index, ByRef value) {

	}
;	End:OnInsertComplete(index, value) ;}
;{ 	OnSet()
/*
	Method: OnSet()

	OnSet(index, ByRef oldValue, ByRef newValue)
		Performs additional custom processes before setting a value in the MfCollectionBase instance.
	Parameters
		index
			The zero-based index at which oldValue can be found.
			Can be MfInteger instance or var integer.
		oldValue
			The value to replace with newValue.
		newValue
			The new value of the element at index.
	Remarks
		Protected Method.
		The default implementation of this method is intended to be overridden by a derived class to perform some action before the specified element is set.
		If the process fails, the collection reverts back to its previous state.
		The default implementation of this method is an O(1) operation.
	Notes to Implementers
		This method allows implementers to define processes that must be performed before setting the specified element in the underlying MfList.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnSet() is invoked before the standard Set behavior, whereas OnSetComplete() is invoked after the standard Set behavior.
		For example, implementers can restrict which values can be overwritten by performing a check inside OnSet().
		OnValidate() is called prior to this method.
*/
	OnSet(index, ByRef oldValue, ByRef newValue) {

	}
; 	End:OnSet() ;}
;{ 	OnSetComplete()
/*
	Method: OnSetComplete()

	OnSetComplete(index, ByRef oldValue, ByRef newValue)
		Performs additional custom processes after setting a value in the MfCollectionBase instance.
	Parameters
		index
			The zero-based index at which oldValue can be found.
			Can be MfInteger instance or var integer.
		oldValue
			The value to replace with newValue.
		newValue
			The new value of the element at index.
	Remarks
		Protected Method.
		The default implementation of this method is intended to be overridden by a derived class to perform some action after the specified element is set.
		The collection reverts back to its previous state if one of the following occurs:
			* The process fails.
			* This method is overridden to throw an exception.
		The default implementation of this method is an O(1) operation.
	Notes to Implementers
		This method allows implementers to define processes that must be performed after setting the specified element in the underlying MfList.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnSet() is invoked before the standard Set behavior, whereas OnSetComplete() is invoked after the standard Set behavior.
*/
	OnSetComplete(index, ByRef oldValue, ByRef newValue) {

	}
; 	End:OnSetComplete() ;}
;{ 	OnRemove()
/*
	Method: OnRemove()
	
	OnRemove(index, ByRef value)
		Performs additional custom processes when removing an element from the MfCollectionBase instance.
	Parameters
	index
		The zero-based index at which value can be found.
		Can be MfInteger instance or var integer.
	value
		The value of the element to remove from index.
	Remarks
		Protected Method
		The default implementation of this method is intended to be overridden by a derived class to perform some action before the specified element is removed.
		If the process fails, the collection reverts back to its previous state.
		The default implementation of this method is an O(1) operation.
	Notes to Implementers
		This method allows implementers to define processes that must be performed before removing the element from the underlying MfList.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnRemove() is invoked before the standard Remove behavior, whereas OnRemoveComplete() is invoked after the standard Remove behavior.
		For example, implementers can prevent removal of elements by always throwing an exception in OnRemove().
		OnValidate() is called prior to this method.
*/
	OnRemove(index, ByRef value) {

	}
; 	End:OnRemove() ;}
;{ 	OnRemoveComplete()
/*
	Method: OnRemoveComplete()
	
	OnRemoveComplete(index, ByRef value)
		Performs additional custom processes after removing an element from the MfCollectionBase instance.
	Parameters
		index
			The zero-based index at which value can be found.
			Can be MfInteger instance or var integer.
		value
			The value of the element to remove from index.
	Remarks
		Protected Method
		The default implementation of this method is intended to be overridden by a derived class to perform some action after the specified element is removed.
		The collection reverts back to its previous state if one of the following occurs:
			* The process fails.
			* This method is overridden to throw an exception.
		The default implementation of this method is an O(1) operation.
	Notes to Implementers
		This method allows implementers to define processes that must be performed after removing the element from the underlying MfList.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnRemove() is invoked before the standard Remove behavior, whereas OnRemoveComplete() is invoked after the standard Remove behavior.

*/
	OnRemoveComplete(index, ByRef value) {

	}
; 	End:OnRemoveComplete() ;}
;{ 	OnValidate()
/*
	Method: OnValidate()

	OnValidate(ByRef value)
		Performs additional custom processes when validating a value.
	Parameters
		value
			The object to validate.
	Throws
		Throws MfArgumentNullException if value is null.
	Remarks
		Protected Method
		The default implementation of this method determines whether value is null, and, if so, throws MfArgumentNullException.
		It is intended to be overridden by a derived class to perform additional action when the specified element is validated.
		The default implementation of this method is an O(1) operation.
	Notes to Implementers
		This method allows implementers to define processes that must be performed when executing the standard behavior of the underlying MfList.
		By defining this method, implementers can add functionality to inherited methods without having to override all other methods.
		OnValidate() can be used to impose restrictions on the type of objects that are accepted into the collection.
		The default implementation prevents null from being added to or removed from the underlying MfList.
		OnValidate() is called prior to OnInsert(), OnRemove(), and OnSet().
*/
	OnValidate(ByRef obj) {
		if (MfNull.IsNull(obj))
		{
			ex := new MfArgumentNullException("obj")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
;	End:OnValidate(obj) ;}	
;{ 	Remove()
/*
	Method: Remove()
	
	instance.Remove(obj)
	
	Remove(obj)
		Removes the first occurrence of a specific object from the MfCollectionBase.
	Parameters
		obj
			The object to remove from the MfCollectionBase.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentException if the obj parameter was not found in the MfCollectionBase
		Throws MfNotSupportedException if MfCollectionBase is read-only or Fixed size
	Remarks
		If the MfCollectionBase does not contain the specified object, the MfCollectionBase remains unchanged.
		This method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
		In collections of contiguous elements, such as lists, the elements that follow the removed element move up to occupy the vacated spot.
		If the collection is indexed, the indexes of the elements that are moved are also updated.
		This behavior does not apply to collections where elements are conceptually grouped into buckets, such as a hash table.
	Notes to Implementers
		This method calls OnValidate(), OnInsert(), and OnInsertComplete().
*/
	Remove(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.OnValidate(obj)
		indexObj := this.InnerList.IndexOf(obj)
		if (indexObj < 0)
		{
			msg := MfString.Format(MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName"), "obj")
			err := new MfArgumentException(msg)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		this.OnRemove(indexObj, obj)
		this.InnerList.RemoveAt(indexObj)
		try
		{
			this.OnRemoveComplete(indexObj, obj)
		}
		catch e
		{
			this.InnerList.Insert(indexObj, obj)
			throw e
		}
	}
;	End:Remove(value) ;}
;{ 	RemoveAt()
/*
	Method: RemoveAt()
	
	instance.RemoveAt(index)

	RemoveAt(index)
		Removes the element at the specified index of the MfCollectionBase instance.
	Parameters
		index
			The zero-based index of the element to remove.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfNotSupportedException if MfList is read-only or Fixed size.
		Throws MfArgumentOutOfRangeException if index is less than zero.-or index is equal to or greater than MfCollectionBase.Count.
	Remarks
		This method is not overridable.
		In collections of contiguous elements, such as lists, the elements that follow the removed element move up to occupy the vacated spot.
		This method is an O(n) operation, where n is Count.
	Notes to Implementers
		This method calls OnValidate(), OnInsert(), and OnInsertComplete().
*/
	RemoveAt(index)	{
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_index := MfInteger.GetValue(index)
		if (_index < 0 || _index >= this.Count)
		{
			err := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		value := this.InnerList.Item[_index]
		this.OnValidate(value)
		this.OnRemove(index, value)
		this.InnerList.RemoveAt(_index)
		try
		{
			this.OnRemoveComplete(_index, value)
		}
		catch e
		{
			this.InnerList.Insert(_index, value)
			throw e
		}
	}
;	End:RemoveAt(index) ;}
;{ 	ToString()			- Overrides	- MfObject
/*!
	Method: ToString()
		Overrides MfObject.ToString.

	OutputVar := instance.ToString()

	ToString()
		Gets a string representation of the object.
	Returns
		Returns string value representing current instance values in the collection.
	Throws
		Throws MfNullReferenceException if called as a static method.
*/
	ToString() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return this.InnerList.ToString()
	}
;	End:ToString() ;}
; End:Methods ;}	

;{ Properties
;{ 	Count[]
/*
		Property: Count [get]
			Gets a value indicating count of objects in the current MfCollectionBase
		Value:
			var containing an Integer representing the current count
		Remarks:
			This property is readonly
		Gets:
			Get the count as var containing an Integer
*/
	Count[]
	{
		get {
			if (this.InnerList) {
					return this.InnerList.Count
				}
				return 0
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; 	End:Count[] ;}
;{	IsFixedSize[]
/*
		Property: IsFixedSize [get]
			Gets a value indicating whether the MfCollectionBase has a fixed size.
		Remarks:
			Returns true if the MfCollectionBase has a fixed size; Otherwise, false.
			This property is readonly.
*/
	IsFixedSize[]
	{
		get {
			return this.InnerList.IsFixedSize
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
			Gets a value indicating whether the MfCollectionBase is readonly.
		Remarks:
			Returns true if the MfCollectionBase is read-only; Otherwise, false. 
			This property is read-only
*/
	IsReadOnly[]
	{
		get {
			return this.InnerList.IsReadOnly
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:IsReadOnly[] ;}
;{ InnerList
	/*!
		Property: InnerList [get]
			Gets the InnerList value associated with the this instance
		Value:
			Var representing the InnerList property of the instance
		Remarks:
			Readonly Property
	*/
	InnerList[]
	{
		get {
			if (MfNull.IsNull(this.m_list))
			{
				this.m_list := new MfList()
			}
			return this.m_list
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "InnerList")
			Throw ex
		}
	}
; End:InnerList ;}
;{	Item[index]
/*
		Property: Item[index] [get/set]
			Gets or sets the element at the specified index.
		Parameters:
			index 
				The zero-based index of the element to get or set.
				Can be MfInteger instance of var integer.
			value
				the value of the item at the specified index
		Value: 
			Item(index, Value)  
			index - The zero-based index of the element to get or set.  
			value - the value of the item at the specified index
		Gets:
			Gets element at the specified index.
		Sets:
			Sets the element at the specified index
		Throws:
			Throws MfArgumentOutOfRangeException if index is less than zero or index is equal to or greater than Count
			Throws MfArgumentException if index is not a valid MfInteger instance or valid var containing Integer
	*/
	Item[index]
	{
		get{
			_index := MfInteger.GetValue(index)
			if (_index < 0 || _index >= this.Count)
			{
				err := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw err
			}
			return this.InnerList.Item[_index]
		}
		set {
			_index := MfInteger.GetValue(index)

			if (_index < 0 || _index >= this.Count)
			{
				err := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw err
			}
			this.OnValidate(value)
			obj := this.InnerList.Item[_index]
			this.OnSet(index, obj, value)
			this.InnerList.Item[_index] := value

			try
			{
				this.OnSetComplete(_index, obj, value)
			} catch e {
				this.InnerList[_index] = obj
				throw e
			}
			return this.InnerList.Item[_index]
		}
	}
;	End:Item[index] ;}
; End:Properties ;}

}
/*!
	End of class
*/