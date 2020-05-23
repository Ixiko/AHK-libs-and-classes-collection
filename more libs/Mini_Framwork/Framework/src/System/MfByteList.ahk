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
	Class: MfByteList
		MfByteList is a sealed class that exposes methods and properties used for list of byte values (0 - 255).
	Inherits:
		MfListBase
*/
class MfByteList extends MfListBase
{
	
;{ Constructor
/*
	Method: Constructor()
		Initializes a new instance of the MfByteList class.

	OutputVar := new MfBinaryList([Size, Default])

	Constructor([Size, Default])
		Initializes a new instance of the MfByteList class.
		Size
			Optional. The initial number of elements to add to the instance.
			Default value is 0
		Default
			Optional, the default value of elements added by if size is greater then zero.
			Default value is 0
	Throws:
		Throws MfArgumentOutOfRangeException if Size is less then 0
		Throws MfArgumentOutOfRangeException if Default is less then 0 or greater then 255
	Remarks:
		Initializes a new instance of the MfByteList class.
*/
	__new(Size=0, default=0) {
		if (this.__Class != "MfByteList")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfByteList"))
		}
		base.__new()
		size := MfInteger.GetValue(size, 0)
		default := MfInteger.GetValue(default, 0)
		If (size < 0)
		{
			ex := new MfArgumentOutOfRangeException("Size")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (default < 0 || default > 255)
		{
			ex := new MfArgumentOutOfRangeException("default")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (Size > 0)
		{
			i := 1
			while (i <= size)
			{
				this.m_InnerList[i] := default
				i++
			}
			this.m_Count := i - 1
		}
	}
; End:Constructor ;}
;{ Methods
;{ 	Add()				- Overrides - MfListBase
/*
	Method: Add()
		Adds a byte element to the end of the current instance.
		Overrides MfListBase.Add()

	OutputVar := instance.Add(obj)

	Add(obj)
		Adds a byte element to the end of the current instance.
	Parameters:
		obj
			The integer byte value from 0 to 255 to add to the current instance.
			Can be any type that matches IsInteger or var integer.
	Returns:
		Var containing Integer of the zero-based index at which the obj has been added.
	Throws:
		Throws MfNullReferenceException if called as static method.
		Throws MfArgumentOutOfRangeException if obj is less then 0 or greater then 255
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
		_value := MfByte.GetValue(obj)
		base._Add(_value)
		return this.m_Count
	}
;	End:Add(value) ;}
;{ 	Clone
/*
	Method: Clone()
		Clones all the elements of the current instance an return  a new instance.
		Overrides MfListBase.Clone().

	OutputVar := instance.Clone()

	Clone()
		Clones all the elements of the current instance an return  a new instance with all the elements copied.
	Returns:
		Returns a new instance that is a copy of the current instance.
	Throws:
		Throws MfNullReferenceException if called as static method.
	Remarks:
		This method is an O(n) operation, where n is Count.
*/
	Clone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return this._clone(false)
	}
; 	End:Clone ;}
;{ 	Contains()			- Overrides - MfListBase
/*
	Method: Contains()
		Determines whether the MfByteList contains a specific element.
		Overrides MfListBase.Contains()

	OutputVar := instance.Contains(obj)

	Contains(obj)
		Determines whether the MfByteList contains a specific object or var.
	Parameters:
		obj
			The object or var to locate in the MfByteList
			Can be any type that matches IsInteger or var integer.
	Returns:
		Returns true if the MfByteList contains the specified value otherwise, false.
	Throws:
		Throws MfNullReferenceException if called as a static method.
	Remarks:
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
*/
	Contains(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := false
		if (this.Count <= 0) {
			return retval
		}
		try
		{
			_value := MfInteger.GetValue(obj)
		}
		catch
		{
			return false
		}
		
		if (_value < 0 || _value > 255)
		{
			return false
		}

		for i, b in this
		{
			if (b = _value)
			{
				retval := true
				break
			}
		}
		return retval
	}
;	End:Contains(obj) ;}
;{ 	IndexOf()			- Overrides - MfListBase
/*
	Method: IndexOf()
		Searches for the specified var or object and returns the index of the first occurrence within the entire instance.
		Overrides MfListBase.IndexOf()

	OutputVar := instance.IndexOf(obj)

	IndexOf(obj)
		Searches for the specified var or object and returns the index of the first occurrence within the entire instance.
	Parameters:
		obj
			The object or var to locate in the MfByteList
			Can be any type that matches IsInteger or var integer.
	Returns:
		Returns  index of the first occurrence of value within the entire instance.
	Throws:
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentOutOfRangeException if obj is less then 0 or greater then 255
	Remarks:
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
*/
	IndexOf(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		i := 0
		bFound := false
		int := -1
		if (this.Count <= 0) {
			return int
		}
		_value := MfInteger.GetValue(obj)
		if (_value < 0 || _value > 15)
		{
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
				, "0", "255"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		for index, b in this
		{
			if (b = _value)
			{
				bFound := true
				break
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
/*
	Method: Insert()
		Inserts an integer byte value into the MfByteList instance at the specified index.
		Overrides MfListBase.Insert()
	Insert(index, value)
		Inserts an integer byte value into the MfByteList instance at the specified index.
	Parameters:
		index
			The zero-based index at which value should be inserted.
			Can be var integer or any type that matches IsIntegerNumber.
		value
			An integer value from 0 to 255
			Can be var integer or any type that matches IsIntegerNumber.
	Throws:
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentOutOfRangeException if index is less than zero.-or index is greater then Count.
		However if AutoIncrease Size is set to true not error is thrown if index is greater then Count.
		Throws MfArgumentException if index is not a valid Integer object or valid var Integer.
		Throws MfArgumentOutOfRangeException if value is less then 0 or greater then 255
	Remarks:
		If index is equal to Count, value is added to the end of the instance.
		If index is greater then Count and AutoIncrease is true then extra elements with a value
		of 0 will be added to the instance that will fill in any extra indices absent before the index value.
		In collections of contiguous elements, such as MfByteList, the elements that follow the insertion
		point move down to accommodate the new element and Count is increased by one.
		This method is an O(n) operation, where n is Count.
*/
	Insert(index, obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		_index := MfInteger.GetValue(index)
		if (this.AutoIncrease = true)
		{
			While _index >= this.Count
			{
				this._AutoIncrease()
			}
		}
		if ((_index < 0) || (_index > this.Count))
		{
			ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_value := MfByte.GetValue(obj)
		If (_index = this.Count)
		{
			this._Add(_value)
			return
		}
		i := _index + 1 ; step up to one based index for AutoHotkey array
		this.m_InnerList.InsertAt(i, _value)
		this.m_Count++
	}
;	End:Insert(index, obj) ;}

;{ 	ToString
/*
	Method: ToString()
		Gets a string representation of the object elements.
		Overrides MfListBase.ToString()

	OutPutVar := instance.ToString([returnAsObj, startIndex, count, format])

	ToString([returnAsObj, startIndex, count, format])
		Gets a string representation of the object elements
	Parameters:
		returnAsObj
			Optional boolean value. Default is false.
			If true result is returned as instance of MfString; Otherwise result is returned as a var string.
			Can be boolean var or instance of MfBool.
		startIndex
			Optional. Default value is 0. The zero-based starting index to start reading elements from.
			Can be var integer or any type that matches IsIntegerNumber.
		count
			Optional, the number of elements from StartIndex to include in the output string.
			If omitted then starts at StartIndex and includes all elements to the end current instance.
		format
			Optional, the default value is 1.
			Format is a Bitwise flag number, see example below
			0 is Little-Endian format
			1 is add hypen and format grouped into groups of two.
			2 is Big-Endian fomat
			4 is Append 0x to start of output, 4 is only applied if 1 is absent.
	Returns:
		Returns string var or MfString instance representing object elements
	Example:
		s := "23FE4A5CBA4C"
		lst := MfByteConverter.FromHex(s)
		MsgBox % lst.ToString()       ; 4C-BA-5C-4A-FE-23
		MsgBox % lst.ToString(,,,1)   ; 4C-BA-5C-4A-FE-23
		MsgBox % lst.ToString(,,,0)   ; 4CBA5C4AFE23
		MsgBox % lst.ToString(,,,2)   ; 23FE4A5CBA4C
		MsgBox % lst.ToString(,,,3)   ; 23-FE-4A-5C-BA-4C
		MsgBox % lst.ToString(,,,4)   ; 0x4CBA5C4AFE23
		MsgBox % lst.ToString(,,,5)   ; 0x4C-BA-5C-4A-FE-23
		MsgBox % lst.ToString(,,,6)   ; 0x23FE4A5CBA4C
		MsgBox % lst.ToString(,,,7)   ; 0x23-FE-4A-5C-BA-4C
		MsgBox % lst.ToString(,2,4)   ; 5C-4A-FE-23
		MsgBox % lst.ToString(,2,4,3) ; 4A-5C-BA-4C
*/
	ToString(returnAsObj = false, startIndex = 0, length="", Format=1) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		Format := MfInteger.GetValue(Format, 1)
		_returnAsObj := MfBool.GetValue(returnAsObj, false)
		_startIndex := MfInt64.GetValue(startIndex, 0)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_length := MfInteger.GetValue(length, this.Count - _startIndex)
		
		if (_length < 0)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_GenericPositive"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (_startIndex > (this.Count - _length))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Reverse := (Format & 2) != 0
		if (Reverse)
		{
			return this._ToStringRev(_returnAsObj, _startIndex, _length, Format)
		}
		IncludeHyphen := (Format & 1) != 0
		FormatAHk := (Format & 4) != 0 & !IncludeHyphen
		sb := new MfText.StringBuilder(_length * 3)
		if (FormatAHk)
		{
			sb.AppendString("0x")
		}
		i := _startIndex
		i++ ; move to one based index
		;iMaxIndex := _length - 1
		iCount := 0
		ll := this.m_InnerList
		while (iCount < _length)
		{
			if (iCount > 0 && IncludeHyphen)
			{
				sb.AppendString("-")
			}
			b := ll[i]
			if (b = 0)
			{
				sb._AppendCharCode(48, 2) ; append 00
			}
			else if (b = 255)
			{
				sb._AppendCharCode(70, 2) ; append FF
			}
			Else
			{
				bit1 := b // 16
				bit2 := Mod(b, 16)
				bitChar1 := MfByteConverter._GetHexValue(bit1)
				bitChar2 := MfByteConverter._GetHexValue(bit2)
				sb.AppendString(bitChar1)
				sb.AppendString(bitChar2)
			}
			i++
			iCount++
		}
		
		return _returnAsObj = true?new MfString(sb.ToString(), true):sb.ToString()
	}
; 	End:ToString ;}
;{ 	SubList
/*
	Method: Sublist()
		Method extracts the elements from list, between two specified indices, and returns the a new list.

	OutputVar := instance.SubList([startIndex, endIndex, leftToRight])

	SubList([startIndex, endIndex, leftToRight])
		Method extracts the elements from list, between two specified indices, and returns the a new list.
	Parameters:
		startIndex
			Optional. Default value is 0. The zero-based starting index to start reading elements from.
			Can be var integer or any type that matches IsIntegerNumber.
		endIndex
			Optional. Default value is null which includes all elements from startIndex to end of list. The zero-based endIndex index to start reading elements from.
			Can be var integer or any type that matches IsIntegerNumber.
		leftToRight
			Optional, Default value is false.
			If true sublist elements are selected from start of list towards end of list; Otherwise elements are selected from end of list towards start of list.
			Can be boolean var or instance of MfBool.
	Returns:
		Returns a new instance of MfByteList the is a SubList of elements
	Remarks:
		If startIndex is greater than endIndex, this method will swap the two arguments, meaning lst.SubList(1, 4) == lst.SubList(4, 1).
		If either startIndex or endIndex is less than 0, it is treated as if it were 0.

	Example:
		s := "23FE4A5C93FE9D35BC"
		lst := MfNibConverter.FromHex(s)
		sl := lst.SubList(4, 12)
		MsgBox % sl.ToString() ; 4A5C93FE
		sl := lst.SubList(4, 12, false)
		MsgBox % sl.ToString() ; D9EF39C5
*/
	SubList(startIndex=0, endIndex="", leftToRight=false) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		startIndex := MfInteger.GetValue(startIndex, 0)
		endIndex := MfInteger.GetValue(endIndex, "NaN", true)
		leftToRight := MfBool.GetValue(leftToRight, true)
		maxIndex := this.Count - 1
		
		IsEndIndex := true
		if (endIndex == "NaN")
		{
			IsEndIndex := False
		}
		If (IsEndIndex = true && endIndex < 0)
		{
			endIndex := 0
		}
		if (startIndex < 0)
		{
			startIndex := 0
		}
		if ((IsEndIndex = false) && (startIndex = 0))
		{
			Return this._clone(!leftToRight)
		}
		if ((IsEndIndex = false) && (startIndex > maxIndex))
		{
			Return this._clone(!leftToRight)
		}
		if ((IsEndIndex = true) && (startIndex > endIndex))
		{
			; swap values
			tmp := startIndex
			startIndex := endIndex
			endIndex := tmp
		}
		if ((IsEndIndex = true) && (endIndex = startIndex))
		{
			return this._clone(!leftToRight)
		}
		if (startIndex > maxIndex)
		{
			return this._clone(!leftToRight)
		}
		if (IsEndIndex = true)
		{
			len :=  endIndex - startIndex
			if ((len + 1) >= this.Count)
			{
				return this._clone(!leftToRight)
			}
		}
		else
		{
			len := maxIndex
		}
		rLst := new MfByteList()
		rl := rLst.m_InnerList
		ll := this.m_InnerList
		if (leftToRight)
		{
			i := startIndex + 1 ; Move to one base index
			j := 1
			;len++ ; move for one based index
			while (j <= len)
			{
				rl[j] := ll[i]
				i++
				j++
			}
			rLst.m_Count := len
			return rLst
		}
		else
		{
			i := this.m_Count - (startIndex + len)
			i++ ; Move to one base index
			j := len
			;len++ ; move for one based index
			while (j >= 1)
			{
				rl[j] := ll[i]
				i++
				j--
			}
			rLst.m_Count := len
			return rLst
		}
	}
; 	End:SubList ;}
;{ _AutoIncrease
	_AutoIncrease()	{
		If (this.m_Count < 1)
		{
			this.m_Count++
			this.m_InnerList[this.m_Count] := 0
			
			return
		}
		NewCount := this.Count * 2
		while this.m_Count < NewCount
		{
			this.m_Count++
			this.m_InnerList[this.m_Count] := 0
		}
	}
; End:_AutoIncrease ;}
;{ 	_clone
	; clones existing list
	; if reverse is true then returned list is in the reverse order.
	_clone(reverse:=false) {
		cLst := new MfByteList()
		cLst.Clear()
		if (this.m_Count = 0)
		{
			return cLst
		}
		bl := cLst.m_InnerList
		ll := this.m_InnerList
		if (reverse = false)
		{
			i := 1
			while (i <= this.m_Count)
			{
				bl[i] := ll[i]
				i++
			}
		}
		else
		{
			i := this.m_Count
			j := 1
			while (i >= 1)
			{
				bl[j] := ll[i]
				i--
				j++
			}
		}
		cLst.m_Count := this.m_Count
		return cLst
	}
; 	End:_clone ;}
;{ 	_ToStringRev
	_ToStringRev(returnAsObj, startIndex, length, Format) {
		IncludeHyphen := (Format & 1) != 0
		FormatAHk := (Format & 4) != 0 & !IncludeHyphen
		sb := new MfText.StringBuilder(length * 3)
		if (FormatAHk)
		{
			sb.AppendString("0x")
		}
		i := length
		iCount := 0
		ll := this.m_InnerList
		while (iCount < length)
		{
			if (iCount > 0 && IncludeHyphen)
			{
				sb.AppendString("-")
			}
			b := ll[i]
			if (b = 0)
			{
				sb._AppendCharCode(48, 2) ; append 00
			}
			else if (b = 255)
			{
				sb._AppendCharCode(70, 2) ; append FF
			}
			Else
			{
				bit1 := b // 16
				bit2 := Mod(b, 16)
				bitChar1 := MfByteConverter._GetHexValue(bit1)
				bitChar2 := MfByteConverter._GetHexValue(bit2)
				sb.AppendString(bitChar1)
				sb.AppendString(bitChar2)
			}
				
			i--
			iCount++
		}
		
		return returnAsObj = true?new MfString(sb.ToString(), true):sb.ToString()
	}
; 	End:_ToStringRev ;}
; End:Methods ;}
;{ Properties
	m_AutoIncrease := false
;{	AutoIncrease[]
/*
	Property: AutoIncrease [get]
		Gets a value indicating the list should Auto-Increase in size when Limit is reached
	Value:
		Var Bool
	Remarks"
		Gets/Sets if the List will auto increase when limit is reached.
*/
	AutoIncrease[]
	{
		get {
			return this.m_AutoIncrease
		}
		set {
			this.m_AutoIncrease := MfBool.GetValue(Value)
		}
	}
;	End:AutoIncrease[] ;}

;{	Item[index]
/*
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
			if (_index < 0) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_index >= this.Count)
			{
				if (this.AutoIncrease = true)
				{
					While _index >= this.Count
					{
						this._AutoIncrease()
					}
				}
				else
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			_index++ ; increase value for one based array
			return this.m_InnerList[_index]
		}
		set {
			_index := MfInteger.GetValue(Index)
			_value := MfByte.GetValue(value)
			if (_index < 0) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_index >= this.Count)
			{
				if (this.AutoIncrease = true)
				{
					While _index >= this.Count
					{
						this._AutoIncrease()
					}
				}
				else
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			_index++ ; increase value for one based array
			this.m_InnerList[_index] := _value
			return this.m_InnerList[_index]
		}
	}
;	End:Item[index] ;}
; End:Properties ;}
}
/*!
	End of class
*/