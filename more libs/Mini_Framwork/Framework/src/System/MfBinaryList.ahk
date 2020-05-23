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
	Class: MfBinaryList
		MfBinaryList is a sealed class that exposes methods and properties used for list of binary values.
	Inherits:
		MfListBase
*/
class MfBinaryList extends MfListBase
{
	m_AutoIncrease := false
;{ Constructor
/*
	Method: Constructor()
		Initializes a new instance of the MfBinaryList class.

	OutputVar := new MfBinaryList([Size, Default])

	Constructor([Size, Default])
		Initializes a new instance of the MfBinaryList class.
		Size
			Optional. The initial number of elements to add to the instance.
			Default value is 0
		Default
			Optional, the default value of elements added by if size is greater then zero.
			Default value is 0
	Throws:
		Throws MfArgumentOutOfRangeException if Size is less then 0
		Throws MfArgumentOutOfRangeException if Default is less then 0 or greater then 1
	Remarks:
		Initializes a new instance of the MfBinaryList class.
*/
	__new(Size=0, default=0) {
		if (this.__Class != "MfBinaryList")
		{
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfBinaryList"))
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
		If (default < 0 || default > 1)
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
		Adds a binary element to the end of the current instance.
		Overrides MfListBase.Add()

	OutputVar := instance.Add(obj)

	Add(obj)
		Adds a binary element to the end of the current instance.
	Parameters:
		obj
			The integer binary value of 0 or 1 to add to the current instance.
			Can be any type that matches IsInteger or var integer.
	Returns:
		Var containing Integer of the zero-based index at which the obj has been added.
	Throws:
		Throws MfNullReferenceException if called as static method.
		Throws MfArgumentOutOfRangeException if obj is less then 0 or greater then 1
*/
	Add(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_value := MfByte.GetValue(obj)
		if (_value < 0 || _value > 1)
		{
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
				, "0", "1"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		this.m_Count++
		this.m_InnerList[this.m_Count] := _value
		
		return this.m_Count
	}
;	End:Add(value) ;}
;{ 	AddByte
/*
	Method: AddByte()
		Converts obj byte value to binary and adds a binary elements to the end of the current instance.

	OutputVar := instance.AddByte(obj)

	AddByte(obj)
		Converts obj byte value to binary and adds a binary elements to the end of the current instance
	Parameters:
		obj
			The integer byte value of 0 to 255 to add to the current instance.
			Can be any type that matches IsInteger or var integer.
	Returns:
		Var containing Integer of the zero-based index at which the obj has been added.
	Throws:
		Throws MfNullReferenceException if called as static method.
		Throws MfArgumentOutOfRangeException if obj is less then 0 or greater then 255
*/
	AddByte(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_value := MfByte.GetValue(obj)
		
		MSB := 0
		LSB := 0

		if (_value > 0) 
		{
			MSB := _Value // 16
			LSB := Mod(_Value, 16)
			LsbHex := MfNibConverter._GetHexValue(LSB)
			MsbHex := MfNibConverter._GetHexValue(MSB)
			LsbInfo := MfNibConverter.HexBitTable[LsbHex]
			MsbInfo := MfNibConverter.HexBitTable[MsbHex]
			strBin := MsbInfo.Bin
			Loop, Parse, strBin
			{
				this.m_Count++
				this.m_InnerList[this.m_Count] := A_LoopField
				
			}
			strBin := LsbInfo.Bin
			Loop, Parse, strBin
			{
				this.m_Count++
				this.m_InnerList[this.m_Count] := A_LoopField
			}
		}
		else
		{
			i := 0
			while i < 8
			{
				this.m_Count++
				this.m_InnerList[this.m_Count] := 0
				i++
			}
		}
		
	}
; 	End:AddByte ;}
;{ 	AddNibble
/*
	Method: AddNibble()
		Converts obj nibble value to binary and adds a binary elements to the end of the current instance

	OutputVar := instance.AddNibble(obj)

	AddNibble(obj)
		Converts obj nibble value to binary and adds a binary elements to the end of the current instance
	Parameters:
		obj
			The integer nibble value of 0 to 15 to add to the current instance.
			Can be any type that matches IsInteger or var integer.
	Returns:
		Var containing Integer of the zero-based index at which the obj has been added.
	Throws:
		Throws MfNullReferenceException if called as static method.
		Throws MfArgumentOutOfRangeException if obj is less then 0 or greater then 15
*/
	AddNibble(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_value := MfByte.GetValue(obj)
		if (_value < 0 || _value > 15)
		{
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
				, "0", "15"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MSB := 0
		LSB := 0

		if (_value > 0) 
		{
			Hex := MfNibConverter._GetHexValue(_value)
			Info := MfNibConverter.HexBitTable[Hex]
			strBin := Info.Bin
			Loop, Parse, strBin
			{
				this.m_Count++
				this.m_InnerList[this.m_Count] := A_LoopField
			}
		}
		else
		{
			i := 0
			while i < 4
			{
				this.m_Count++
				this.m_InnerList[this.m_Count] := 0
				i++
			}
		}
		
	}
; 	End:AddNibble ;}
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
		Related

	SubList()
*/
	Clone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		return this._clone(false)
	}
; 	End:Clone ;}
;{ 	FromString
/*
	Method: FromString()
		Create a new instance of MfBinaryList from a string.

	OutputVar := instance.FromString(s)

	FromString(s)
		Create a new instance of MfBinaryList from a string by reading all 0 and 1 characters in the string.
	Parameters:
		s
			String var or instance of MfString to generate the MfBinaryList instance from.
	Returns:
		Returns new instance of MfBinaryList containing elements representing s.
		Related

	ToString()

	Remarks:
		Static Method
		All characters in the string that are not 0 or 1 will be ignored.
*/
	FromString(s) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		mStr := MfMemoryString.FromAny(s)
		len := mStr.Length

		lst := new MfBinaryList()

		if (len = 0)
		{
			lst._Add(0)
			lst._Add(0)
			return lst
		}
		ll := lst.m_InnerList
		iCount := 0
		i := 0
		While (i < len)
		{
			ch := mStr.CharCode[i++]
			if (ch = 48)
			{
				iCount++
				ll[iCount] := 0
			}
			else if (ch = 49)
			{
				iCount++
				ll[iCount] := 1
			}
		}
		
		lst.m_Count := iCount
		return lst

	}
; 	End:FromString ;}
;{ 	Insert()			- Overrides - MfListBase
/*
	Method: Insert()
		Inserts an integer binary value element into the MfBinaryList instance at the specified index.
		Overrides MfListBase.Insert()
	Insert(index, value)
		Inserts an integer binary value element into the MfBinaryList instance at the specified index.
	Parameters:
		index
			The zero-based index at which value should be inserted.
			Can be var integer or any type that matches IsIntegerNumber.
		value
			An integer value or 0 or 1.
			Can be var integer or any type that matches IsIntegerNumber.
	Throws:
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentOutOfRangeException if index is less than zero.-or index is greater then Count.
		However if AutoIncrease Size is set to true not error is thrown if index is greater then Count.
		Throws MfArgumentException if index is not a valid Integer object or valid var Integer.
		Throws MfArgumentOutOfRangeException if value is less then 0 or greater then 1
	Remarks:
		If index is equal to Count, value is added to the end of the instance.
		If index is greater then Count and AutoIncrease is true then extra elements with a value of 0 will be added
		to the instance that will fill in any extra indices absent before the index value.
		In collections of contiguous elements, such as MfBinaryList, the elements that follow the insertion point
		move down to accommodate the new element and Count is increased by one.
		This method is an O(n) operation, where n is Count.
*/
	Insert(index, value) {
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
		_value := MfByte.GetValue(value)
		if (_value < 0 || _value > 1)
		{
			ex := new MfArgumentOutOfRangeException("value"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
				, "0", "1"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		base.Insert(i, _value)
		
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
			Optional, the default value is 0. Can be 0 or 1.
			If format is 0 then no special formating is done to the return string.
			If format is 1 then return string is grouped into groups of 4 with a hyphen between each group.
	Returns:
		Returns string var or MfString instance representing object elements
*/
	ToString(returnAsObj = false, startIndex = 0, count="", Format=0) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_returnAsObj := MfBool.GetValue(returnAsObj, false)
		_Format := MfInteger.GetValue(Format, false)
		_startIndex := MfInteger.GetValue(startIndex, 0)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_length := MfInteger.GetValue(count, this.Count - _startIndex)
		
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
		if (_Format = 1)
		{
			return this._ToByteArrayString(_returnAsObj, _startIndex, _length)
		}
		mStr := new MfMemoryString(_length,,"UTF-8")
		i := _startIndex
		iMaxIndex := _length - 1
		ll := this.m_InnerList
		while i <= iMaxIndex
		{
			n := ll[i + 1]
			if (n = 1)
			{
				mStr.AppendCharCode(49)
			}
			else
			{
				mStr.AppendCharCode(48)
			}
			
			i++
		}
		
		return _returnAsObj = true?new MfString(mStr.ToString()):mStr.ToString()
	}
; 	End:ToString ;}
;{ 		SubList
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
			Optional. Default value is null which includes all elements from startIndex to end of list.
			The zero-based endIndex index to start reading elements from.
			Can be var integer or any type that matches IsIntegerNumber.
		leftToRight
			Optional, Default value is true.
			If true sublist elements are selected from start of list towards end of list; Otherwise elements are selected
			from end of list towards start of list.
			Can be boolean var or instance of MfBool.
	Returns:
		Returns a new instance of MfBinaryList the is a SubList of elements
	Remarks:
		If startIndex is greater than endIndex, this method will swap the two arguments, meaning lst.SubList(1, 4) == lst.SubList(4, 1).
		If either startIndex or endIndex is less than 0, it is treated as if it were 0.
*/
	SubList(startIndex=0, endIndex="", leftToRight=true) {
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
		rLst := new MfBinaryList()
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
	_ToByteArrayString(returnAsObj, startIndex, length) {
		i := startIndex
		iMaxIndex := length -1
		len := iMaxIndex - startIndex
		mStr := new MfMemoryString(len * 2,, "UTF-8")
		iChunk := 0
		rem := Mod(this.Count, 4)
		iCount := 0
		if (rem > 0)
		{
			offset := (4 - rem)
			k := 0
			While k <= offset
			{
				mStr.Append("0")
				k++
			}
			iCount := offset
			;i += offset
		}
		ll := this.m_InnerList
		iLoopCount := 0
		while i <= iMaxIndex
		{
			if (iLoopCount > 0)
			{
				mStr.Append("-")
			}
			while iCount < 4
			{
				if (i > iMaxIndex)
				{
					break
				}
				n := ll[i + 1]
				if (n = 1)
				{
					mStr.AppendCharCode(49)
				}
				else
				{
					mStr.AppendCharCode(48)
				}
				;mStr.Append(ll[i + 1])
				iCount++
				i++
			}
			iLoopCount++
			iCount := 0
		}
		return returnAsObj = true?new MfString(mStr.ToString()):mStr.ToString()
	}
	_AutoIncrease() {
		If (this.m_Count < 1)
		{
			this.m_Count++
			this.m_InnerList[this.m_Count] := 0
			
			return
		}
		NewCount := this.Count * 2
		while (this.m_Count < NewCount)
		{
			this.m_Count++
			this.m_InnerList[this.m_Count] := 0
		}
	}
;{ 	_clone
	; clones existing list
	; if reverse is true then returned list is in the reverse order.
	_clone(reverse:=false) {
		cLst := new MfBinaryList()
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
; End:Methods ;}
;{ Properties
;{	AutoIncrease[]
/*
	Property: AutoIncrease [get\set]
		Gets or set a value indicating the list should Auto-Increase in size when Limit is reached
	Parameters:
		Value:
			boolean value or instance of MfBool.
	Gets:
		Gets value indicating the list should Auto-Increase in size when Limit is reached
	Sets:
		Sets value indicating the list should Auto-Increase in size when Limit is reached
	Remarks:
		If AutoIncrease is true then Method Insert() and property Item will automatically increase  if needed when adding new values.
		All values added by AutoIncrease will have an initial value of 0
		Default value is false.
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
		Gets or sets the element as char code integer at the specified index.
		Overrides MfListBase.Item
	Parameters:
		Index:
			The zero-based index of the element to get or set.
			Can be var integer or any type that matches IsIntegerNumber.
		Value:
			the value of the item at the specified index, this can be any var or object.
	Gets:
		Gets element as char code integer at the specified index.
	Sets:
		Sets the element as char code integer at the specified index
	Throws:
		Throws MfArgumentOutOfRangeException if index is less then zero.
		Throws MfArgumentOutOfRangeException if index is out of range of the number of elements in the list and AutoIncrease is false.
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
			_index ++ ; increase value for one based array
			return this.m_InnerList[_index]
		}
		set {
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
			_value := MfByte.GetValue(value)
			if (_value < 0 || _value > 1)
			{
				ex := new MfArgumentOutOfRangeException("value"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
					, "0", "1"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_index ++ ; increase value for one based array
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