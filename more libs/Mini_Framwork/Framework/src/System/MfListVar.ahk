;{ 	class DList
; zero based index list that can contain var value of number or string
; adding of objects to this list is not supported
; List is case sensitive
; constructor parame Size determins the default number of element in the list
; constructor param default determinst the defalut value added to the list if Size is > 0
;	default can be null such as ""
class MfListVar extends MfListBase
{
	m_Default := ""
	m_CaseSensitive := true
;{ Constructor
/*
	Method: Constructor()
		Initializes a new instance of the MfListVar class.

	OutputVar := new MfListVar([Size, Default, IgnoreCase])

		Optional. The initial number of elements to add to the instance.
		Default value is 0
		Default
		Optional, the default value of elements added by if size is greater then zero.
		Default value is 0
		IgnoreCase
		Boolean Value. If True then instance observes case; Otherwise case is ignored.
	Remarks:
		Initializes a new instance of the MfListVar class.
*/
	__new(Size=0, default=0, IgnoreCase=true) {
		if (this.__Class != "MfListVar") {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfListVar"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		base.__new()
		this.m_Default := default ; set in case new default items are added via Item property
		IgnoreCase := MfBool.GetValue(IgnoreCase, false)
		this.m_CaseSensitive := !IgnoreCase
		; test show adding via index is about 26 times faster then using Push
		; test was don by adding 1,000,000 zeros to a list
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
		this.m_isInherited := false
	}
; End:Constructor ;}
;{ Methods
;{ 	Add()				- Overrides - MfListBase
/*
	Method: Add()
		Adds an element to the end of the current instance.
		Overrides MfListBase.Add()

	OutputVar := instance.Add(obj)

	Add(obj)
		Adds an element to the end of the current instance.
	Parameters:
		obj
			The var to add to the current instance.
	Returns:
		Var containing Integer of the zero-based index at which the obj has been added.
*/
	Add(obj) {
		this.m_Count++
		this.m_InnerList[this.m_Count] := obj
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
		Determines whether the MfListVar contains a specific element.
		Overrides MfListBase.Contains()

	OutputVar := instance.Contains(obj)

	Contains(obj)
		Determines whether the MfListVar contains a specific var.
	Parameters:
		obj
			The var to locate in the MfListVar
	Returns:
		Returns true if the MfListVar contains the specified value otherwise, false.
	Remarks:
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		If obj is a string var then contains will follow CaseSensitive.
*/
	Contains(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		If(IsObject(obj))
		{
			return false
		}
		retval := false
		if (this.Count <= 0)
		{
			return retval
		}
		retval := this.IndexOf(obj, 0) > -1
		return retval
	}
;	End:Contains(obj) ;}
;{ FromString
/*
	Method: FromString()
		Create a new instance of MfListVar from a string.

	OutputVar := instance.FromString(s[, includeWhiteSpace, ignoreCase])

	FromString(s[, includeWhiteSpace, ignoreCase])
		Create a new instance of MfListVar from a string by splitting the string into each char and adding char to inner list.
	Parameters:
		s
			String var or instance of MfString to generate the MfListVar instance from.
		includeWhiteSpace
			Boolean value. If true then whitespace chars will be included if they exist s;
			Otherwise all Unicode whitespace chars will be ignored.
			Can be boolean var or instance of MfBool.
		ignoreCase
			Boolean value. Sets the CaseSensitive property of the new instance.
			Can be boolean var or instance of MfBool.
	Returns:
		Returns new instance of MfListVar containing elements representing s.
	Remarks:
		Static Method
*/
	FromString(s, includeWhiteSpace=true, IgnoreCase=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		IgnoreCase := MfBool.GetValue(IgnoreCase, true)
		includeWhiteSpace := MfBool.GetValue(includeWhiteSpace, true)
		str := new MfString(MfString.GetValue(s), true)
		
		lst := new MfListVar()
		lstArray := []
		iCount := 0
		if (!includeWhiteSpace)
		{
			str := MfString.RemoveWhiteSpace(str, true)
		}
		
		if (str.Length = 0)
		{
			return lst
		}

		for i, c in str
		{
			lstArray[++iCount] := c
		}

		
		lst.m_InnerList := lstArray
		lst.m_Count := str.Length
		lst.CaseSensitive := !IgnoreCase
		return lst
	}
; End:FromString ;}
;{ 	IndexOf()			- Overrides - MfListBase
/*
	Method: IndexOf()
		Searches for the specified var and returns the index of the first occurrence within the entire instance.
		Overrides MfListBase.IndexOf()

	OutputVar := instance.IndexOf(obj)

	IndexOf(obj)
		Searches for the specified var and returns the index of the first occurrence within the entire instance.
	Parameters:
		obj
			The var to locate in the MfListVar
	Returns:
		Returns  index of the first occurrence of value within the entire instance.
	Remarks:
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		If obj is a string var then contains will follow CaseSensitive.
*/
	IndexOf(obj, startIndex=0) {
		startIndex := MfInteger.GetValue(startIndex)
		if (startIndex >= this.Count || startIndex < 0)
		{
			return -1
		}
		i := startIndex
		bFound := false
		If(IsObject(obj))
		{
			return -1
		}
		int := -1
		if (this.Count <= 0) {
			return int
		}
		i++ ; move for one based index
		if (this.m_CaseSensitive = true)
		{
			while (i <= this.Count)
			{
				v := this.m_InnerList[i] ; search inner list for faster searching
				if (obj == v) {
					bFound := true
					i-- ; reset for zero based index
					break
				}
				i++
			}
		}
		else
		{
			while (i <= this.Count)
			{
				v := this.m_InnerList[i] ; search inner list for faster searching
				if (obj = v) {
					bFound := true
					i-- ; reset for zero based index
					break
				}
				i++
			}
		}
		if (bFound = true) {
			int := i
			return int
		}
		return int
	}
;	End:IndexOf() ;}
;{ 	LastIndexOf()			- Overrides - MfListBase
/*
	Method: LastIndexOf()
		Searches for the specified var and returns the index of the last occurrence within the entire instance.
		Overrides MfListBase.IndexOf()

	OutputVar := instance.IndexOf(obj)

	LastIndexOf(obj)
		Searches for the specified var and returns the index of the last occurrence within the entire instance.
	Parameters:
		obj
			The var to locate in the MfListVar
	Returns:
		Returns  index of the last occurrence of value within the entire instance.
	Remarks:
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		If obj is a string var then contains will follow CaseSensitive.
*/
	LastIndexOf(obj, startIndex=0) {
		startIndex := MfInteger.GetValue(startIndex)
		if (startIndex >= this.Count || startIndex < 0)
		{
			return -1
		}
		i := startIndex
		bFound := false
		If(IsObject(obj))
		{
			return -1
		}
		int := -1
		if (this.Count <= 0) {
			return int
		}
		i := this.Count ; one based index
		startIndex++ ; move to one base index
		if (this.m_CaseSensitive = true)
		{
			while (i >= startIndex)
			{
				v := this.m_InnerList[i] ; search inner list for faster searching
				if (obj == v) {
					bFound := true
					i-- ; reset for zero based index
					break
				}
				i--
			}
		}
		else
		{
			while (i >= startIndex)
			{
				v := this.m_InnerList[i] ; search inner list for faster searching
				if (obj = v) {
					bFound := true
					i-- ; reset for zero based index
					break
				}
				i--
			}
		}
		if (bFound = true) {
			int := i
			return int
		}
		return int
	}
;	End:IndexOf() ;}
;{ ToList
/*
	Method: ToList()
		Gets a MfList instance of current instance of MfListVar

	OutputVar := instance.ToList()

	ToList()
		Gets a MfList instance of current instance of MfListVar
	Returns:
		Returns a new MfList with all the same element values as current instance of MfListVar.
	Remarks:
		Changing elements on returned MfList instance has no effect on current instance of MfListVar.
*/
	ToList() {
		return this._ToList().Clone()
	}
; End:ToList ;}
;{ 	ToString
/*
	Method: ToString()
		Gets a string representation of the object elements.
		Overrides MfListBase.ToString()

	OutPutVar := instance.ToString([separator, startIndex, endIndex])

	ToString([separator, startIndex, endIndex])
		Gets a string representation of the object elements
	Parameters:
		separator
			Optional separator that will be inserted between each element in the return string.
			Default value is comma ","
			Can be var string, empty string or instance of MfString.
		startIndex
			Optional. Default value is 0. The zero-based starting index to start reading elements from.
			Can be var integer or any type that matches IsIntegerNumber.
		endIndex
			Optional. Default value is null which includes all elements from startIndex to end of list.
			The zero-based endIndex index to start reading elements from.
			Can be var integer or any type that matches IsIntegerNumber.
	Returns:
		Returns string var representing object elements
*/
	ToString(separator:=",", startIndex:=0, endIndex:="") {
		
		maxIndex := this.Count - 1
		IsEndIndex := true
		if (MfString.IsNullOrEmpty(endIndex))
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
		if ((IsEndIndex = false) && (startIndex > maxIndex))
		{
			Return ""
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
			return ""
		}
		if (startIndex > maxIndex)
		{
			return ""
		}
		if (IsEndIndex = true)
		{
			len :=  endIndex - startIndex
		}
		else
		{
			len := maxIndex + 1
		}
		sep := MfString.GetValue(separator)
		sepLen := StrLen(sep)
		sb := new MfText.StringBuilder()
		i := startIndex
		iCount := 0
		ll := this.m_InnerList
		while (iCount < len)
		{
			v := ll[i + 1]
			if (i < maxIndex)
			{
				sb.AppendString(v)
				if (sepLen > 0)
				{
					sb.AppendString(sep)
				}
				
			}
			else
			{
				sb.AppendString(v)
			}
			i++
			iCount++
		}
		return sb.ToString()
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
			If true sublist elements are selected from start of list towards end of list;
			Otherwise elements are selected from end of list towards start of list.
			Can be boolean var or instance of MfBool.
	Returns:
		Returns a new instance of MfListVar the is a SubList of elements
	Remarks:
		If startIndex is greater than endIndex, this method will swap the two arguments, meaning lst.SubList(1, 4) == lst.SubList(4, 1).
		If either startIndex or endIndex is less than 0, it is treated as if it were 0.
*/
	SubList(startIndex=0, endIndex="", leftToRight=true) {
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
		rLst := new MfListVar()
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
; 		End:SubList ;}
;{ 	_clone
	; clones existing list
	; if reverse is true then returned list is in the reverse order.
	_clone(reverse:=false) {
		cLst := new MfListVar()
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
;{ 	Properties
	;{ CaseSensitive
/*
	Property: CaseSensitive [get\set]
		Gets or sets the instance observes case.
	Parameters:
		Value:
			boolean value or instance of MfBool.
	Gets:
		Gets current instance observes case.
	Sets:
		Sets current instance observes case.
*/
		CaseSensitive[]
		{
			get {
				return this.m_CaseSensitive
			}
			set {
				this.m_CaseSensitive := MfBool.GetValue(value, true)
				return this.m_CaseSensitive
			}
		}
	; End:CaseSensitive ;}
;{	Item[index]
/*
	Property: Item [get\set]
		Gets or sets the element at the specified index.
		Overrides MfListBase.Item
	Parameters:
		Index:
			The zero-based index of the element to get or set.
			Can be var integer or any type that matches IsIntegerNumber.
		Value:
			the value of the item at the specified index, this can be any var or object.
	Gets:
		Gets element at the specified index.
	Sets:
		Sets the element at the specified index
	Throws:
		Throws MfArgumentOutOfRangeException if index is out of range of the number of elements in the list.
	Remarks:
		This property can not be overridden in derived classes
*/
	Item[index]
	{
		get {
			_index := MfInteger.GetValue(Index)
			if (_index < 0 || _index >= this.Count) {
				return ""
			}
			_index ++ ; increase value for one based array
			return this.m_InnerList[_index]
		}
		set {
			_index :=  MfInteger.GetValue(Index)
			if (_index >= this.Count) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_index >= this.Count) {
				i := this.Count - 1
				while (i <= _index)
				{
					this.Add(this.m_Default)
					i++
				}
			}
			_index ++ ; increase value for one based array
			this.m_InnerList[_index] := value
			return this.m_InnerList[_index]
		}
	}
;	End:Item[index] ;}
;{ 	Properties
}

; 	End:class DList ;}