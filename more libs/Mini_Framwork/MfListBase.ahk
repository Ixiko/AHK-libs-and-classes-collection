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
	Class: MfListBase
		MfListBase is an abstract class and must be inherited by other classes such as MfList.
		MfListBase class exposes methods and properties used for common List and array type operations.
	Inherits: MfEnumerableBase
*/
class MfListBase extends MfEnumerableBase
{
;{ Constructor()
/*
	Constructor()
		Constructor for Abstract Class MfListBase
	Throws
		Throws MfNotSupportedException if this Abstract class constructor is called directly.
	Remarks
		Derived classes must call base.__New() in their constructors.
*/
	__New() {
		; Throws MfNotSupportedException if MfListBase Abstract class constructor is called directly.
		if (this.__Class = "MfListBase") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_AbstractClass", "MfListBase"))
		}
		
		base.__New()
		this.m_isInherited := this.__Class != "MfListBase"
	}
; End:Constructor() ;}
;{ Methods
;{ 	Add()
/*!
	Method: Add()
		This abstract method must be overridden in the derived class
	Add(obj)
		Adds an object to append at the end of the MfListBase.
	Parameters
		obj
			The Object to locate in the MfListBase
	Returns
		The index at which the obj has been added.
	Remarks
		Abstract Method.
		Must be overridden in derived classes.
	Throws
		Throws MfNotImplementedException if the derived class does not override
*/
	Add(obj) {
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:Add(value) ;}
;{ 	Clear()
/*!
	Method: Clear()
		This abstract method must be overridden in the derived class
	Clear()
		Removes all objects from the MfListBase instance.
	Remarks
		Abstract Method.
		Must be overridden in derived classes.
	Throws
		Throws MfNotImplementedException if the derived class does not override
*/
	Clear()	{
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:Clear() ;}
;{ 	Contains()
/*!
	Method: Contains()
		This abstract method must be overridden in the derived class
	Contains(obj)
		Determines whether the MfListBase contains a specific element.
	Parameters
		value
			The Object to locate in the MfListBase
	Returns
		Returns true if the MfListBase contains the specified value otherwise, false.
	Throws
		Throws MfNotImplementedException if the derived class does not override
	Remarks
		Abstract Method.
		Must be overridden in derived classes.
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
*/
	Contains(obj) {
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:Contains(obj) ;}
;{ 	IndexOf()
/*
	Method: IndexOf()
	This abstract method must be overridden in the derived class
	IndexOf(obj)
		Searches for the specified Object and returns the index of the first occurrence within the entire MfListBase.
	Parameters
		obj
			The object to locate in the MfListBase
	Returns
		Returns  index of the first occurrence of value within the entire MfListBase,
	Throws
		Throws MfNotImplementedException if the derived class does not override
	Remarks
		Abstract Method.
		Must be overridden in derived classes.
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
*/
	IndexOf(obj) {
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:IndexOf(obj) ;}
;{ 	Insert()
/*!
	Method: Insert()
		This abstract method must be overridden in the derived class
	Insert(index, value)
		Inserts an element into the MfListBase at the specified index.
	Parameters
		index
			The zero-based index at which value should be inserted.
	value
		The object to insert.
	Throws
		Throws MfNotImplementedException if the derived class does not override
	Remarks
		Abstract Method.
		Must be overridden in derived classes.
		In collections of contiguous elements, such as MfList, the elements that follow the insertion point move down to accommodate the new element.
		This method is an O(n) operation, where n is Count.
*/
	Insert(index, obj) {
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:Insert(index, obj) ;}
;{ 	Remove()
/*
	Method: Remove()
		This abstract method must be overridden in the derived class
	Remove(obj)
		Removes the first occurrence of a specific object from the MfListBase.
	Parameters
		obj
			The object to remove from the MfListBase.
	Returns
		On Success returns the Object or var that was removed; Otherwise returns null
	Throws
		Throws MfNotImplementedException if the derived class does not override
		Throws MfArgumentException if the obj parameter was not found in the MfListBase
	Remarks
		Abstract Method.
		Must be overridden in derived classes.
	Remarks
		This method is an O(n) operation, where n is Count.
		In collections of contiguous elements, such as lists, the elements that follow the removed element move up to occupy the vacated spot.
		If the collection is indexed, the indexes of the elements that are moved are also updated.
		This behavior does not apply to collections where elements are conceptually grouped into buckets, such as a hash table.
*/
	Remove(obj)	{
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:Remove(obj) ;}
;{ 	RemoveAt()
/*
	Method: RemoveAt()
		This abstract method must be overridden in the derived class
	RemoveAt(index)
		Removes the MfList item at the specified index.
	Parameters
		index
			The zero-based index of the item to remove. Can be instance of MfInteger or var containing integer.
	Throws
		Throws MfNotImplementedException if the derived class does not override
	Remarks
		Abstract Method.
		Must be overridden in derived classes.
		This method is an O(n) operation, where n is Count.
*/
	RemoveAt(index)	{
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:RemoveAt(int) ;}
;{ 	ToString()			- Overrides	- MfObject	
	/*!
		Method: ToString()
			Overrides MfObject.ToString()
			Gets a string representation of the object.  
		Returns:
			Returns string value representing object elements
	*/
	ToString() {
		str := ""
		maxIndex := this.Count -1
		for i, v in this
		{
		 valStr := ""
			
		 if (IsObject(v))
		 {
			valStr := "{" . MfType.TypeOfName(v) . "}"
			if(IsFunc(v.ToString)){
			   valStr .= " " .  v.ToString()
			}
		 } else {
			valStr := "'" v "'"
		 }
		 str .= i ": " . valStr
		 If (i < maxIndex)
		 {
		 	str .= MfEnvironment.Instance.NewLine
		 }
		}
		return str
	}
;	End:ToString() ;}
; End:Methods ;}
;{ Properties
	;{	Count
/*
	Property: Count [get]
		Gets a value indicating if the MfListBase number of Elements.
		This property must be overridden in the derived class
	Value:
		Var Integer
	Gets:
		Gets the count of elements in the list as var integer.
	Throws:
		Throws MfNotImplementedException if the derived class does not override
	Remarks:
		Must be overridden in derived classes.
*/
	Count[]
	{
		get {
			ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_PropertyWithName","Count"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
		set {
			ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_PropertyWithName","Count"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:Count ;}
;{	IsFixedSize[]
/*!
	Property: IsFixedSize [get]
		Gets a value indicating if the MfListBase has a fixed size.
	Value:
		Boolean var
	Gets:
		Returns False
	Remarks:
		Read-only property.
		Can be overridden in derived classes.
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
		Gets a value indicating if the MfListBase is read-only.
	Value:
		Boolean var
	Gets:
		Returns False
	Remarks:
		Read-only property.
		Can be overridden in derived classes.
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
;{	Item[index]
/*!
	Property: Item [index] [get\set]
		Gets or sets the element at the specified index.
	Parameters:
		index
			The zero-based index of the element to get or set.
	value:
		the value of the item at the specified index
	Gets:
		Gets element at the specified index.
	Sets:
		Sets the element at the specified index
	Throws:
		Throws MfNotImplementedException if not overridden in derived class.
	Remarks:
		This property must be overridden in the derived class
*/
	Item[index]
	{
		get {
			ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_PropertyWithName","Item"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:Item[index] ;}
; End:Properties ;}
}
/*!
	End of class
*/