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
	Class: MfGenericList
		MfGenericList class exposes methods and properties used for common List and array
		type operations for strongly typed collections that derive from specified type
	Inherits:
		MfListBase
*/
class MfGenericList extends MfListBase
{
;{ Class Members
	m_InnerList			:= Null
	m_Enum				:= Null
	m_Type				:= Null
; End:Class Members ;}
;{ Constructor
/*!
	Constructor()
	
	OutputVar := new MfGenericList(genericType)
	
	MfGenericList(genericType)
		Initializes a new instance of the MfGenericList class.
	Parameters
		genericType
			The Type of object derived from MfObject
	Throws
		Throws MfArgumentNullException if genericType is null.
		Throws MfArgumentException if genericType is not derived from MfObject.
*/
	__New(genericType) {
		if (!MfObject.IsMfObject(genericType)) {
			ex := new MfArgumentNullException("genericType")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfObject.IsMfObject(genericType))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_NonMfObjectWithParamName", "genericType"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
				
		base.__New()
		this.m_isInherited := this.__Class != "MfGenericList"
		if (genericType.Is("MfType")) {
			this.m_Type := genericType
		} else {
			this.m_Type := genericType.GetType()
		}
		
		this.m_InnerList := []
		this.m_InnerList.Count := 0
		this.m_Enum := Null
	}
; End:Constructor ;}
;{ Methods
;{ 	Add()				- Overrides - MfListBase
/*
	Method: Add()
		Overrides MfListBase.Add()

	OutputVar := instance.Add(obj)

	Add(obj)
		Adds an object to the end of the MfGenericList.
	Parameters
		obj
			The Object to add in the MfGenericList
	Returns
		Var containing Integer of the zero-based index at which the obj has been added.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfNotSupportedException if MfList is read-only or Fixed size
		Throws MfNotSupportedException if obj is not correct type for this instance.
*/
	Add(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.IsFixedSize) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FixedSize"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.IsReadOnly) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_List"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfObject.IsObjInstance(obj, this.m_Type)) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType", this.m_Type.TypeName))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_newCount := this.m_InnerList.Count + 1

		this.m_InnerList[_newCount] := obj
		this.m_InnerList.Count := _newCount
		retval := _newCount - 1
		return retval
	}
;	End:Add(value) ;}
;{ 	Clear()				- Overrides - MfListBase
/*!
	Method: Clear()
		Overrides MfListBase.Clear()
	Clear()
		Removes all objects from the MfGenericList instance.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfNotSupportedException if MfList is read-only or Fixed size
*/
	Clear() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.IsFixedSize) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FixedSize"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.IsReadOnly) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_List"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_InnerList := Null
		this.m_InnerList := []
		this.m_InnerList.Count := 0
		this.m_Enum := Null
	}
;	End:Clear() ;}
;{ 	Contains()			- Overrides - MfListBase
/*!
	Method: Contains()
		Overrides MfListBase.Contains
	Contains(obj)
		Determines whether the MfGenericList contains a specific element.
	Parameters
		obj
			The Object to locate in the MfGenericList
	Returns
		Returns var with value of true if the MfGenericList contains the specified value otherwise, false.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfNotSupportedException if obj is not correct type for this instance.
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	Contains(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!MfObject.IsObjInstance(obj, this.m_Type)) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType", this.m_Type.TypeName))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := false
		if (this.m_InnerList.Count <= 0) {
			return retval
		}
		for k, v in this.m_InnerList
		{
			try {
				if (v.CompareTo(obj) = 0) {
					retval := true
					break
				}
			} catch e {
				continue
			}
		}
		return retval
	}
;	End:Contains(obj) ;}
; insert this snipit inside the body of a list based class
;{ 		_NewEnum
/*
	Method: _NewEnum()
		Overrides MfEnumerableBase._NewEnum()
	_NewEnum()
		Returns a new enumerator to enumerate this object's key-value pairs.
		This method is usually not called directly, but by the for-loop or by GetEnumerator()
*/
	_NewEnum() {
        return new MfGenericList.Enumerator(this)
    }
; 		End:_NewEnum ;}
;{ 		class Enumerator
	; internal class
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
;{ 	IndexOf()			- Overrides - MfListBase
/*
	Method: IndexOf()
		Overrides MfListBase.IndexOf()
	IndexOf(obj)
		Searches for the specified Object and returns the zero-based index of the first occurrence within the entire MfGenericList.
		This method must be overridden in the derived class.
	Parameters
		obj
			The object to locate in the MfGenericList
	Returns
		Returns var of Integer of the zero-based index of the first occurrence of obj within the entire MfList, if found;
		Otherwise, Integer var with a Value of -1.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfNotSupportedException if obj is not correct type for this instance.
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	IndexOf(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!MfObject.IsObjInstance(obj, this.m_Type)) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType", this.m_Type.TypeName))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		i := 0
		bFound := false
		int := -1
		if (this.m_InnerList.Count <= 0) {
			return int
		}
		for k, v in this.m_InnerList
		{
			try {
				if (v.CompareTo(obj) = 0) {
					bFound := true
					break
				}
			} catch e {
				i++
				continue
			}
			i++
		}
		if (bFound = true) {
			int := i
			return int
		}
		return int
	}
;	End:IndexOf() ;}
;{ 	Insert()			- Overrides - MfListBase
/*!
	Method: Insert()
		Overrides MfListBase.Insert()
	Insert(index, obj)
		Inserts an element into the MfGenericList at the specified index.
	Parameters
		index
			The zero-based index at which value should be inserted.
		obj
			The object to insert. The object type must be of the same type as ListType
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfNotSupportedException if MfGenericList is read-only or Fixed size
		Throws MfArgumentOutOfRangeException if index is less than zero.-or index is greater than Count
		Throws MfArgumentException if index is not a valid MfInteger instance or valid var Integer.
		Throws MfNotSupportedException if obj is not correct type for this instance.
	Remarks
		If index is equal to Count, value is added to the end of MfGenericList.
		In MfGenericList, the elements that follow the insertion point move down to accommodate the new element.
		This method is an O(n) operation, where n is Count.
*/
	Insert(index, obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.IsFixedSize) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FixedSize"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.IsReadOnly) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_List"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfObject.IsObjInstance(obj, this.m_Type)) {
			msg := MfString.Format(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType"), this.m_Type.TypeName)
			ex := new MfNotSupportedException(msg)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_index := MfInteger.GetValue(index)
		if ((_index < 0) || (_index > this.m_InnerList.Count))
		{
			ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (_index = this.m_InnerList.Count)
		{
			this.Add(obj)
			return
		}
		i := _index + 1 ; step up to one based index for AutoHotkey array
		this.m_InnerList.InsertAt(i, obj)
		this.m_InnerList.Count ++
	}
;	End:Insert(index, obj) ;}
;{ 	Remove()			- Overrides - MfListBase
/*
	Method: Remove()
		Overrides MfListBase.Remove()
	Remove(obj)
		Removes the first occurrence of a specific object from the MfGenericList.
	Parameters
		obj
			The object to remove from the MfGenericList.
	Returns
		On Success returns the Object or var that was removed; Otherwise returns null
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentException if the obj parameter was not found in the MfCollectionBase
		Throws MfNotSupportedException if MfGenericList is read-only or Fixed size
		Throws MfNotSupportedException if obj is not correct type for this instance.
		Remarks
			If the MfGenericList does not contain the specified object, the MfGenericList remains unchanged.
			This method is an O(n) operation, where n is Count.
			This method determines equality by calling MfObject.CompareTo().
			In collections of contiguous elements, such as lists, the elements that follow the removed element move up to occupy the vacated spot.
			If the collection is indexed, the indexes of the elements that are moved are also updated.
			This behavior does not apply to collections where elements are conceptually grouped into buckets, such as a hash table.
*/
	Remove(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.IsFixedSize) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FixedSize"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.IsReadOnly) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_List"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfObject.IsObjInstance(obj, this.m_Type)) {
			msg := MfString.Format(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType"), this.m_Type.TypeName)
			ex := new MfNotSupportedException(msg)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		index := this.IndexOf(obj)
		if (index < 0 ) {
			msg := MfString.Format(MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName"), "obj")
			err := new MfArgumentException(msg)
			err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw err
		}
		return this.RemoveAt(index)
	}
; 	End:Remove(obj) ;}
;{ 	RemoveAt()			- Overrides - MfListBase
/*!
	Method: RemoveAt()
		Overrides MfListBase.RemoveAt()
	RemoveAt(index)
		Removes the MfGenericList item at the specified index.
	Parameters
		index
			The zero-based index of the item to remove.
			Can be instance of MfInteger or var integer.
	Returns
		On Success returns the Object or var that was removed at index; Otherwise returns null.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfNotSupportedException if MfGenericList is read-only or Fixed size
		Throws MfNotSupportedException if obj is not correct type for this instance.
		Throws MfArgumentOutOfRangeException if index is less than zero.-or index is equal to or greater than Count
		Throws MfArgumentException if index is not a valid MfInteger instance or valid var Integer
	Remarks
		This method is not overridable.
		In MfGenericList the elements that follow the removed element move up to occupy the vacated spot.
		This method is an O(n) operation, where n is Count.
*/
	RemoveAt(index) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.IsFixedSize) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FixedSize"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.IsReadOnly) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_List"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		_index := MfInteger.GetValue(index)
		if ((_index < 0) || (_index >= this.m_InnerList.Count)) {
			ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		i := _index + 1 ; step up to one based index for AutoHotkey array
		vRemoved := this.m_InnerList.RemoveAt(i)
		if (vRemoved) {
			this.m_InnerList.Count --
		} else {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_FailedToRemove"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return vRemoved
	}
;	End:RemoveAt(int) ;}
; End:Methods ;}
;{ Properties
;{	Count
/*
	Property: Count [get]
		Overrides MfListBase.Count
		Gets a value indicating count of objects in the current MfGenericList as an Integer
	Value:
		Var Integer
	Gets:
		Gets the count of elements in the MfGenericList as var integer.
	Remarks:
		Read-only property.
*/
	Count[]
	{
		get {
			return this.m_InnerList.Count
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:Count ;}

;{	ListType
/*
	Property: ListType [get]
	Value:
		Instance of MfType
	Gets:
		Gets a MfType instance representing the allowable types that can be added to this instance of MfGenericList.
	Remarks:
		Read-only Property.
*/
	ListType[]
	{
		get {
			return this.m_Type
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:ListType ;}
;{	Item
/*!
	Property: Item [get\set]
		Overrides MfListBase.Item
		Gets or sets the element at the specified index.
	Parameters:
		index
			The zero-based index of the element to get or set.
		value
			the value of the item at the specified index
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
		get {
			_index := MfInteger.GetValue(Index)
			if (_index < 0 || _index >= this.Count) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_index ++ ; increase value for one based array
			return this.m_InnerList[_index]
		}
		set {
			if (!MfObject.IsObjInstance(value, this.m_Type)) {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType", this.m_Type.TypeName))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_index := MfInteger.GetValue(Index)
			if (_index < 0 || _index >= this.Count) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_index ++ ; increase value for one based array
			this.m_InnerList[_index] := value
			return this.m_InnerList[_index]
		}
	}
;	End:Item ;}
; End:Properties ;}
}
/*!
	End of class
*/