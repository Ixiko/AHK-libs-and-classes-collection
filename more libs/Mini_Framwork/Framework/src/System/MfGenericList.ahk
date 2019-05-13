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
		if (!MfObject.IsObjInstance(obj, this.m_Type)) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType", this.m_Type.TypeName))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return base.Add(obj)
	}
;	End:Add(value) ;}
;{ 	Clone
	Clone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		cLst := new MfGenericList(this.m_Type)
		cLst.Clear()
		cl := cLst.m_InnerList
		ll := this.m_InnerList
		for i, v in ll
		{
			cl[i] := v
		}
		cLst.m_Count := this.Count
		return cLst
	}
; 	End:Clone ;}
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
		if (this.m_count <= 0) {
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
		Returns var of Integer of the zero-based index of the first occurrence of obj within the entire MfGenericList, if found;
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
		if (this.m_Count <= 0) {
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
		if (!MfObject.IsObjInstance(obj, this.m_Type)) {
			msg := MfString.Format(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType"), this.m_Type.TypeName)
			ex := new MfNotSupportedException(msg)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		base.Insert(index, obj)
	}
;	End:Insert(index, obj) ;}
;{ 	LastIndexOf()
/*
	Method: IndexOf()
		Overrides MfListBase.IndexOf()
	IndexOf(obj)
		Searches for the specified Object and returns the zero-based index of the last occurrence within the entire MfGenericList.
		This method must be overridden in the derived class.
	Parameters
		obj
			The object to locate in the MfGenericList
	Returns
		Returns var of Integer of the zero-based index of the last occurrence of obj within the entire MfGenericList, if found;
		Otherwise, Integer var with a Value of -1.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfNotSupportedException if obj is not correct type for this instance.
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	LastIndexOf(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!MfObject.IsObjInstance(obj, this.m_Type)) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType", this.m_Type.TypeName))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		i := 0
		bFound := false
		int := -1
		if (this.m_Count <= 0) {
			return int
		}
		i := this.m_Count -1
		while (i >= 0)
		{
			v := ths.m_InnerList[i + 1]
			try
			{
				if (v.CompareTo(obj) = 0) {
					bFound := true
					break
				}
			} catch e {
				i--
				continue
			}
			i--
		}
		
		if (bFound = true) {
			int := i
			return int
		}
		return int
	}
;	End:LastIndexOf() ;}
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

; End:Methods ;}
;{ Properties

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
			return base.Item[index]
		}
		set {
			if (!MfObject.IsObjInstance(value, this.m_Type)) {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_NonAhkType", this.m_Type.TypeName))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			base.Item[Index] := value
		}
	}
;	End:Item ;}
; End:Properties ;}
}
/*!
	End of class
*/