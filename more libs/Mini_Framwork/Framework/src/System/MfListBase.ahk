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

	m_InnerList			:= Null
	m_Enum				:= Null
	m_count				:= 0
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
		this.m_InnerList := []
		this.m_Count := 0
		this.m_isInherited := true
		this.m_Enum := Null
	}
; End:Constructor() ;}
;{ Methods
	;{ 		_NewEnum
/*
	Method: _NewEnum()
		Overrides MfEnumerableBase._NewEnum()
	_NewEnum()
		Returns a new enumerator to enumerate this object's key-value pairs.
		This method is usually not called directly, but by the for-loop or by GetEnumerator()
*/
	_NewEnum() {
		return new MFListBase.Enumerator(this)
	}
; 		End:_NewEnum ;}
;{ 	Add()				- Overrides - MfListBase
/*
	Method: Add()
		This method must be overridden in the derived class
	Add(obj)
		Adds an object to append at the end of the MfList
	Parameters
		obj
			The Object to locate in the MfList
	Returns
		Var containing Integer of the zero-based index at which the obj has been added.
	Throws
		Throws MfNullReferenceException if called as a static method.
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
		return this._Add(obj)
	}
;	End:Add(value) ;}
;{ 	_Add
	; internal method
	; this method is used through out the framework and therfore should not be replace or renamed.
	_Add(obj) {
		this.m_Count++
		this.m_InnerList[this.m_Count] := obj
		
		return this.m_Count - 1
	}
; 	End:_Add ;}
;{ 	Clear()				- Overrides - MfListBase
/*
	Method: Clear()

	Clear()
		Removes all objects from the MfList instance.
	Throws
		Throws MfNullReferenceException if called as a static method.
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
		this.m_Count := 0
		this.m_Enum := Null
	}
;	End:Clear() ;}
	Clone() {
		ex := new MfNotImplementedException(MfEnvironment.Instance.GetResourceString("NotImplementedException_MethodParentWithName", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;{ 	Copy
/*
	Method: Copy()

	Copy()
		Copies a range of elements from an MfListBase object starting at the first element and pastes them into another MfListBase object
		starting at the first element. The length is specified as a 32-bit integer
	Parameters:
		sourceList
			The source list. Must be List that inherits from MfListBase
		destinationList
			The destination list. Must be List that inherits from MfListBase
		length
			The number of elements to copy from Source list into destination list
	Throws:
		Throws MfArgumentNullException if sourceList or destinationList is null
		Throw MfArgumentException if sourceList or destinationList is are not inherited from MfListBase
		Throw MfArgumentException if Length is not a valid 32 bit number or Length is less then 0 or Length is greater then sourceList.Count

	Remarks:
		Static Method
		If destinationList.Count is less then Length then new elements will be added to destinationList to match Length
*/
	Copy(sourceList, destinationList, length) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(sourceList))
		{
			ex := new MfArgumentNullException("sourceList")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(destinationList))
		{
			ex := new MfArgumentNullException("sourceList")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
			
		if (!MfObject.IsObjInstance(sourceList, MfListBase))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List"), "sourceList")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfObject.IsObjInstance(destinationList, MfListBase))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List"), "destinationList")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		try
		{
			Length := MfInteger.GetValue(length)
		}
		catch e
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), "length")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length = 0)
		{
			return
		}
		if (length < 0)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_NegativeLength"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length > sourceList.Count)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall"), "sourceList")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		; if (Length > destinationList.Count)
		; {
		; 	ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall"), "destinationList")
		; 	ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		; 	throw ex
		; }
		sA := sourceList.m_InnerList
		dA := destinationList.m_InnerList
		i := 1
		While (i <= length)
		{
			da[i] := sA[i]
			i++
		}
		destinationList.m_count := da.Length()

	}
; 	End:Copy ;}
;{ 	Contains()			- Overrides - MfListBase
/*!
	Method: Contains()
		Overrides MfListBase.Contains()
	Contains(obj)
		Determines whether the MfList contains a specific element.
	Parameters
		obj
			The Object to locate in the MfList
		Returns
			Returns true if the MfList contains the specified value otherwise, false.
	Throws
		Throws MfNullReferenceException if called as a static method.
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	Contains(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		bObj := IsObject(obj)
		retval := false
		if (this.m_Count <= 0) {
			return retval
		}
		for k, v in this.m_InnerList
		{
			if (bObj) {
				try {
					if (v.CompareTo(obj) = 0) {
						retval := true
						break
					}
				} catch e {
					continue
				}
			} else {
				if (obj = v) {
					retval := true
					break
				}
			}
		}
		return retval
	}
;	End:Contains(obj) ;}
;{ 	IndexOf()			- Overrides - MfListBase
/*
	Method: IndexOf()

	IndexOf(obj)
		Searches for the specified Object and returns the zero-based index of the first occurrence within the entire MfList.
	Parameters
		obj
			The object to locate in the MfList
	Returns
		Returns  index of the first occurrence of value within the entire MfList,
	Throws
		Throws MfNullReferenceException if called as a static method.
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	IndexOf(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		i := 0
		bFound := false
		bObj := IsObject(obj)
		int := -1
		if (this.m_Count <= 0) {
			return int
		}
		for k, v in this.m_InnerList
		{
			
			if (bObj) {
				try {
					if (v.CompareTo(obj) = 0) {
						bFound := true
						break
					}
				} catch e {
					i++
					continue
				}
				
			} else {
				if (obj = v) {
					bFound := true
					break
				}
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
	Insert(index, obj)
		Inserts an element into the MfList at the specified index.
	Parameters
		index
			The zero-based index at which value should be inserted.
		obj
			The object to insert.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentOutOfRangeException if index is less than zero.-or index is greater than MfList.Count
		Throws MfArgumentException if index is not a valid Integer object or valid var Integer.
		Throws MfNotSupportedException if MfList is read-only or Fixed size.
	Remarks
		If index is equal to Count, value is added to the end of MfGenericList.
		In MfList the elements that follow the insertion point move down to accommodate the new element.
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
		_index := MfInteger.GetValue(index)
		if ((_index < 0) || (_index > this.m_Count))
		{
			ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (_index = this.m_Count)
		{
			this.Add(obj)
			return
		}
		i := _index + 1 ; step up to one based index for AutoHotkey array
		this.m_InnerList.InsertAt(i, obj)
		this.m_Count++
	}
;	End:Insert(index, obj) ;}
;{ 	LastIndexOf()
/*
	Method: LastIndexOf()

	LastIndexOf(obj)
		Searches for the specified Object and returns the zero-based index of the Lasst occurrence within the entire List.
	Parameters
		obj
			The object to locate in the List
	Returns
		Returns  index of the last occurrence of value within the entire List,
	Throws
		Throws MfNullReferenceException if called as a static method.
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	LastIndexOf(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		i := 0
		bFound := false
		bObj := IsObject(obj)
		int := -1
		if (this.m_Count <= 0) {
			return int
		}
		i := this.m_Count -1
		while (i >= 0)
		{
			v := ths.m_InnerList[i + 1]
			if (bObj) {
				try {
					if (v.CompareTo(obj) = 0) {
						bFound := true
						break
					}
				} catch e {
					i--
					continue
				}
				
			} else {
				if (obj = v) {
					bFound := true
					break
				}
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
;{ 	Remove()
/*!
	Method: Remove

	Remove(obj)
		Removes the first occurrence of a specific object from the MfList.
	Parameters
		obj
			The object to remove from the MfList.
	Returns
		On Success returns the Object or var that was removed; Otherwise returns null
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentException if obj the parameter was not found in the MfList
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
;{ 	RemoveAt()
/*!
	Method: RemoveAt()

	RemoveAt()
		Removes the MfList item at the specified index.
	Parameters
		index
			The zero-based index of the item to remove.
			Can be instance of MfInteger or var integer.
	Returns
		On Success returns the Object or var that was removed at index; Otherwise returns null.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfNotSupportedException if MfList is read-only or Fixed size
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
		if ((_index < 0) || (_index >= this.m_Count)) {
			ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		i := _index + 1 ; step up to one based index for AutoHotkey array
		vRemoved := this.m_InnerList.RemoveAt(i)
		iLen := this.m_InnerList.Length()
		; if vremoved is an empty string or vRemoved is 0 then, If (vRemoved ) would computed to false
		if (iLen != this.m_Count) {
			this.m_Count--
		} else {
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_FailedToRemove"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return vRemoved
	}
;	End:RemoveAt(int) ;}
;{ 	ToArray
	; to AutoHotkey one based Array
	ToArray() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := []
		ll := this.m_InnerList
		i := 1
		while (i <= this.m_Count)
		{
			retval[i] := ll[i]
			i++	
		}
		return retval
	}
; 	End:ToArray ;}
;{ 	ToString()			- Overrides	- MfObject	
	/*!
		Method: ToString()
			Overrides MfObject.ToString()
			Gets a string representation of the object.  
		Returns:
			Returns string value representing object elements
	*/
	ToString() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		str := new MfText.StringBuilder()
		maxIndex := this.m_Count - 1
		ll := this.m_InnerList
		i := 1
		nl := MfEnvironment.Instance.NewLine
		while (i <= this.m_Count)
		{
			valStr := ""
			
			if (IsObject(v))
			{
				valStr := "{" . MfType.TypeOfName(v) . "}"
				if(IsFunc(v.ToString)){
				   valStr .= " " .  v.ToString()
				}
			}
			else
			{
				valStr := "'" v "'"
			}
			str.AppendString(i)
			str.AppendString(": ")
			str.AppendString(valStr)
			;str .= i ": " . valStr
			If (i < this.m_Count)
			{
				str.AppendString(nl)
			}
			i++
		}
		
		return str.ToString()
	}
;	End:ToString() ;}
; End:Methods ;}
;{ 	Internal Methods
	_ToList() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		lst := new MfList()
		lst.m_InnerList := this.m_InnerList
		return lst
	}
	; intended to be used internally by framework only
	; set the this.m_InnerList to aray objArray
	_SetInnerList(objArray, SetCount=true) {
		try
		{
			if (IsObject(objArray))
			{
				this.Clear()
				this.m_InnerList := ""
				this.m_InnerList := objArray
				if(SetCount)
				{
					this.m_Count := objArray.Length()
				}
			
			}
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
	}
; 	End:Internal Methods ;}
;{ Properties
;{	Count[]
/*
	Property: Count [get]
		Gets a value indicating count of objects in the current MfList as an Integer
	Value:
		Var Integer
	Gets:
		Gets the count of elements in the MfList as var integer.
	Remarks"
		Read-only property.
*/
	Count[]
	{
		get {
			return this.m_Count
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:Count[] ;}
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
/*
	Property: Item [get\set]
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
		Throws MfNotSupportedException if MfList is read-only or Fixed size on Set
*/
	Item[index]
	{
		get {
			_index := MfInteger.GetValue(Index)
			if (_index < 0 || _index >= this.m_Count) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_index ++ ; increase value for one based array
			return this.m_InnerList[_index]
		}
		set {
			if (this.IsReadOnly) {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_List"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_index := MfInteger.GetValue(Index)
			if (_index < 0 || _index >= this.m_Count) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_index ++ ; increase value for one based array
			this.m_InnerList[_index] := value
			return this.m_InnerList[_index]
		}
	}
;	End:Item[index] ;}
; End:Properties ;}
;{ 		internal class Enumerator
	class Enumerator
	{
		m_Parent := ""
		m_KeyEnum := ""
		m_index := 0
		m_count := 0
		m_InnerList := ""
		__new(ByRef ParentClass) {
			this.m_Parent := ParentClass
			this.m_count := this.m_Parent.Count
			this.m_InnerList := this.m_Parent.m_InnerList
		}

		Next(ByRef key, ByRef value)
		{
		
			if (this.m_index < this.m_count) {
				key := this.m_index
				value := this.m_InnerList[key + 1]
			}
			this.m_index++
			if (this.m_index > (this.m_count)) {
				return false
			} else {
				return true
			}
		}
	}
; 		End:class Enumerator ;}
}
/*!
	End of class
*/