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

;{ MfString Class
;{ Class comments
/*
	Class: MfString
		Represents string object
	Inherits: MfPrimitive
*/
; End:Class comments ;}
Class MfString extends MfPrimitive
{
;{ Internal Vars
	;m_value := ""
	m_length := 0
	m_IgnoreCase := true
	Static Empty := ""
	Static TypeCode := 11
	m_ptr := ""
	m_mStr := ""
	m_ptrChanged := true
; End:Internal Vars;}
;{ Constructor
/*
		Constructor()
			Initializes a new instance of the MfString class and set the Value property to MfString.Empty
			Remarks
				ReturnAsObject is initialized to false.
		Constructor(str)
			Initializes a new instance of the MfString class and set the Value property to the value of the str parameter.
				Remarks
					ReturnAsObject is initialized to false.
		Constructor(str, returnAsObj)
			Initializes a new instance of the MfString class and set the Value property to the value of the str parameter.
			ReturnAsObject is set to the value of the returnAsObj parameter.
			
			Parameters
				str
					The MfString object or var containing MfFloat to create a new instance with.
				returnAsObj
					Optional; Determines if the current instance of MfString class will return MfString instances from functions or vars contaning strings.
					If omitted value is false
				readonly
					Optional. Determins if the current instance of MfString class will allow it value to be change after the instance is created.
					If ommited value is false
		Throws
			Throws MfNullReferenceException if str is object but not set to an instance.
			Throws MfNotSupportedException if str is object but not derived from MfPrimitive.
			Throws MfNotSupportedException if class is extended
		Remarks
			MfString instance will contain a value of MfString.Empty if str is omitted.
			Sealed Class
*/
	__New(str:="", returnAsObj:=false, readonly:=false) {
		; str = "", returnAsObj = false, readonly = false
		; Throws MfNotSupportedException if MfString Sealed class is extended
		if (this.__Class != "MfString") {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		getLen := true
		if (IsObject(str))
		{
			if (MfObject.IsObjInstance(str, MfString))
			{
				val := str.Value
				this.m_length := str.m_length
				getLen := false
			}
			else If (!MfObject.IsMfObject(str))
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NonMfObjectException_Param", "str"), "str")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			else If (MfObject.IsObjInstance(str, "StringBuilder"))
			{
				val := str.ToString()
				this.m_length := str.Length
				getLen := false
			}
			else
			{
				val := str.ToString()	
			}
		}
		else
		{
			val := str
		}

		_returnAsObject := MfBool.GetValue(returnAsObj, false)
		_readonly := MfBool.GetValue(readonly, false)

		
		
		Base.__New(val, _returnAsObject, _readonly)
		if (getLen)
		{
			this.m_length := StrLen(this.m_value)	
		}
		; MfGlobalOptions.StringObeyCaseSense is truned off by default and thus IngnoreCase is true by default
		; no matter the state of A_StringCaseSense
		if ((MfGlobalOptions._HasFlag(MfGlobalOptions.StringObeyCaseSense.Value))
			&& (A_StringCaseSense = "On"))
		{
			this.m_IgnoreCase := false
		}
		this.m_isInherited := false
		this._ResetPtr() ; set the memory address of the string value
	}
; End:Constructor ;}
;{ Methods
;{ 	Append()
/*
		Parameters
			value
				The new value to add to current instance of MfString. Can be var containing string or any object derived from MfObject.
		Append(value)
			Appends value string to current MfString instance.
		Returns
			Returns string that that has value appended.
			If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.
		Throws
			Throws MfNullReferenceException if current instance of MfString is null.
			Throws MfInvalidCastException if value cannot be cast to string.
		Remarks
			If value is empty no error is thrown and nothing is added to the MfString instance.
*/
	Append(value) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfString.IsNullOrEmpty(value)) {
			return this._ReturnString(this)
		}
		try {
				this.Value .= MfString.GetValue(value)
				;this._ResetPtr() done in value
				return this._ReturnString(this)
		} catch e {
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToString"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
	}
; End:Append() ;}
;{ 	AppendLine()
/*
		Parameters
			value
				The new value to add to current instance of MfString. Can be var containing string or any object derived from MfObject.
		AppendLine()
			Appends a new line to current MfString instance.
		Returns
			Returns string that that has new line appended.
			If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string. See example 2.
		
		AppendLine(value)
			Append value followed by a new line to current MfString instance.
		Returns
			Returns string that that has value and new line appended.
			If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string. See example 2.
		Throws
			Throws MfNullReferenceException if current instance of MfString is null.
			Throws MfInvalidCastException if value cannot be cast to string.
		Remarks
			If value is empty no error is thrown and nothing is added to the MfString instance.
*/
	AppendLine(value="") {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfString.IsNullOrEmpty(value)) {
			this.Value .= MfEnvironment.Instance.NewLine
			; this._ResetPtr() done in Value
			return this._ReturnString(this)
		}
		try {
			this.Value .= MfString.GetValue(value) . MfEnvironment.Instance.NewLine
			;this.Value .= "`r`n" . MfString.GetValue(value)
			return this._ReturnString(this)
		} catch e {
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToString"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; End:AppendLine() ;}
;{ 	Compare()
/*
	Compare(objParams) 
		Compares two string base up the Parameters passed into the MfParams object.
	Parameters
		objParams
			as instance of MfParams can be a valid combination of the MfParams below.
	Remarks
		Static Method


	Compare(strA, strB)
		Compares two specified MfString objects and returns an Integer that indicates their relative position in the sort order.
	Parameters
		strA
			The first string to compare. Can be instance of MfString or var containing string
		strB
			The second string to compare. Can be instance of MfString or var containing string
		Remarks
			Static Method
			This Overload ignores case unless StringCaseSense has be turned On.


	Compare(strA, strB, ignoreCase)
		Compares two specified MfString objects, ignoring or honoring their case, and returns an Integer that indicates their relative position in the sort order.
	Parameters
		strA
			The first string to compare. Can be instance of MfString or var containing string
		strB
			The second string to compare. Can be instance of MfString or var containing string
		ignoreCase
			true to ignore case during the comparison; otherwise, false.
			Can be instance of MfBool or var containing boolean.
	Remarks
		Static Method


	Compare(strA, strB, comparisonType)
		Compares two specified MfString objects using the specified rules, and returns an Integer that indicates
		their relative position in the sort order.
	Parameters
		strA
			The first string to compare. Can be instance of MfString or var containing string
		strB
			The second string to compare. Can be instance of MfString or var containing string
		comparisonType
			One of the MfStringComparison enumeration values that specifies the rules to use in the comparison.
			Can be MfStringComparison instance or MfStringComparison.Instance.EnumItem
	Remarks
		Static Method


	Compare(strA, indexA, strB, indexB, length)
		Compares substrings of two specified MfString objects and returns an Integer that indicates their
		relative position in the sort order.
	Parameters
		strA
			The first string to compare. Can be instance of MfString or var containing string
		indexA
			The zero-based position of the substring within strA.
			Can be MfInteger instance or var containing integer.
		strB
			The second string to compare. Can be instance of MfString or var containing string
		indexB
			The zero-based position of the substring within strB.
			Can be MfInteger instance or var containing integer.
		length
			The maximum number of characters in the substrings to compare.
			Can be MfInteger instance or var containing integer.
	Remarks
		Static Method
		If length is greater then the availbale characters of strA or strB then the number of remaing characters is used.
		This prevents a error from being thrown if length is to high.
		This Overload ignores case unless StringCaseSense has be turned On.


	Compare(strA, indexA, strB, indexB, length, ignoreCase)
		Compares substrings of two specified MfString objects, ignoring or honoring their case, and returns an Integer
		that indicates their relative position in the sort order.
	Parameters
		strA
			The first string to compare. Can be instance of MfString or var containing string
		indexA
			The zero-based position of the substring within strA.
			Can be MfInteger instance or var containing integer.
		strB
			The second string to compare. Can be instance of MfString or var containing string
		indexB
			The zero-based position of the substring within strB.
			Can be MfInteger instance or var containing integer.
		length
			The maximum number of characters in the substrings to compare.
			Can be MfInteger instance or var containing integer.
		ignoreCase
			true to ignore case during the comparison; otherwise, false.
			Can be instance of MfBool or var containing boolean.
	Remarks
		Static Method
		If length is greater then the availbale characters of strA or strB then the number of remaing characters is used.
		This prevents a error from being thrown if length is to high.


	Returns
		Returns a var containing Integer that indicates the lexical relationship between the two comparands.
		Value Condition Less than zero strA is less than strB. Zero strA equals strB.
		Greater than zero strA is greater than strB.
		Method is not affected by the state of ReturnAsObject and always returns a var containing an Integer.
	Throws
		Throws MfArgumentException if the incorrect number or type of parameters are passed in.
		Throws MfNotSupportedException if Overloads can not match Parameters.
*/
	Compare(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfObject.IsObjInstance(args[1],MfParams)) {
			p := args[1] ; arg 1 is a MfParams object so we will use it
		} else {
			p := new MfParams()
			p.AllowEmptyString := true ; allow empty strings to be compared
			cnt := args.MaxIndex()
			for index, arg in args
			{
				try
				{
					if (IsObject(arg))
					{
						p.Add(arg)
					} 
					else
					{
						if (cnt > 2 && Mfunc.IsInteger(arg)) ; there are no integer or bool if less then 3 parameters
						{
							if ((cnt = 3) && (index = 3)) ; last item in index must be MfString,MfString,MfBool
							{
								p.AddBool(arg)
							}
							else if ((cnt = 6) && (index = 6)) ; last item in index must be MfString,MfInteger,MfString,MfInteger,MfInteger,MfBool
							{
								p.AddBool(arg)
							}
							else
							{
								p.AddInteger(arg)
							}
						}
						else
						{
							p.AddString(arg)
						}
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
		}
		if ((p.Count < 2) || (p.Count > 6)) {
			e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"))
			e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw e
		}
		strP := p.ToString()
		try
		{
			if (strP = "MfString,MfString") {
				strA := p.Item[0]
				strB := p.Item[1]
				mStrA := strA._GetMStr()
				mStrB := strB._GetMStr()
				;IgnoreCase := strA.m_IgnoreCase | strB.m_IgnoreCase 
				IgnoreCase := (!(A_StringCaseSense = "On"))
				return mStrA.CompareOrdinal(mStrB, IgnoreCase)
				;return MfString._CompareSS(p.Item[0], p.Item[1])
			} else if (strP = "MfString,MfString,MfStringComparison") {
				return MfString._CompareSSC(p.Item[0], p.Item[1],p.Item[2])
			} else if (strP = "MfString,MfString,MfBool") {
				return MfString._CompareSSB(p.Item[0], p.Item[1],p.Item[2])
			} else if (strP = "MfString,MfInteger,MfString,MfInteger,MfInteger") {
				; Compare(strA, indexA, strB, indexB, length)
				return MfString._CompareSISII(p.Item[0], p.Item[1],p.Item[2],p.Item[3],p.Item[4])
			} if (strP = "MfString,MfInteger,MfString,MfInteger,MfInteger,MfBool") {
				return MfString._CompareSISIIB(p.Item[0], p.Item[1],p.Item[2],p.Item[3],p.Item[4],p.Item[5])
			}
		}
		catch e
		{
			
			if (MfObject.IsObjInstance(e, MfArgumentOutOfRangeException))
			{
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw e
			}
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
			
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload",A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; End:Compare() ;}
;{ 	CompareTo()			- Overrides	- MfObject
/*
	CompareTo(obj)
		Compares this instance to a specified MfString object.
	Parameters
		obj
			A MfString object to compare.
	Returns
		Returns A value that indicates the relative order of the objects being compared. The return value has these meanings:
		Value Meaning Less than zero This instance precedes obj in the sort order.
		Zero This instance occurs in the same position in the sort order as obj Greater than zero This instance follows obj in the sort order.
		
		Method is not affected by the state of MfString.ReturnAsObject and will always return a var containing an
		Integer value if no errors are thrown.
	Throws
		Throws MfNullReferenceException is not set to an instance.
		Throws MfArgumentException obj is not instance of MfString.
	Remarks
		This Method obeys IgnoreCase.
*/
	CompareTo(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(obj)) {
			return -1
		}
		if (IsObject(obj))
		{
			if(MfObject.IsObjInstance(obj, MfString))
			{
				return MfString.Compare(this,obj)
			}
			mStr := MfMemoryString.FromAny(obj)
			cStr := new MfString(mStr.ToString())
			mStr := ""
			return return MfString.Compare(this, cStr)
		}
		cStr := new MfString(obj)
		cStr.IgnoreCase := (!(A_StringCaseSense = "On"))
		return return MfString.Compare(this, cStr)
	}
; End:CompareTo(obj) ;}	
;{ 	Concat - Static
/*
	Concat(args)
		Creates the string representation of a specified object.
	Parameters
		Args
			An object array that contains the elements to concatenate.
			Any var or object derived from MfObject can be an args
	Returns
		Returns The concatenated string var representations of the values of the elements args
	Remarks
		Static Method.
		Concatenates the string representations of the elements in a specified array.
*/
	Concat(args*) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		sb := new MfText.StringBuilder()
		for index, arg in args
		{
			if (IsObject(arg)) {
				if (MfObject.IsObjInstance(arg, "MfObject")) {
					sb.Append(arg.ToString())
				}
			} else {
				sb.Append(arg)
			}
		}
		return sb.ToString()
	}
; 	End:Concat ;}
;{ 	Contains
	Contains(args*) {
		objParams := Null
		if (this.IsInstance())
		{
			objParams := this._IndexOfParams(A_ThisFunc, args*)
		}
		else
		{
			objParams := MfString._IndexOfParams(A_ThisFunc, args*)
		}
	
		strParms := objParams.ToString()
		
		retval := -2 ; real return value can not be less than -1
		isInst := this.IsInstance()
		if (isInst) {
			if (strParms = "MfChar") { ; searchChar
				obj := objParams.Item[0]
				if (obj.CharCode = 0)
				{
					return true
				}
				idx := this._IndexOfC(obj)
				return idx >= 0
			}
			if (strParms = "MfString") { ; var searchChar or searchString
				str := objParams.Item[0]
				if (str.Length = 0)
				{
					return true
				}
				idx := this._IndexOfS(str)
				return idx >= 0
			}
			if (strParms = "MfChar,MfInteger") { ; searchChar, startIndex
				c := objParams.Item[0]
				if (c.CharCode = 0)
				{
					return true
				}
				idx := this._IndexOfCI(c, objParams.Item[1])
				return idx >= 0
			}
			if (strParms = "MfString,MfInteger") { ; searchString, startIndex
				str := objParams.Item[0]
				if (str.Length = 0)
				{
					return true
				}
				idx := this._IndexofSI(str, objParams.Item[1])
				return idx >= 0
			}
			if (strParms = "MfString,MfString") { ;  var searchChar or searchString, startIndex
				str := objParams.Item[0]
				if (str.Length = 0)
				{
					return true
				}
				_StartIndex := new MfInteger()
				if (!MfInteger.TryParse(_startIndex, objParams.Item[1])) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				idx := this._IndexofSI(str, _StartIndex)
				return idx >= 0
			}
			if (strParms = "MfChar,MfInteger,MfInteger") {  ; searchChar, startIndex, count
				c := objParams.Item[0]
				if (c.CharCode = 0)
				{
					return true
				}
				idx := this._IndexOfCII(c, objParams.Item[1], objParams.Item[2])
				return idx >= 0
			}
			if (strParms = "MfString,MfInteger,MfInteger") { ;searchString, startIndex, count
				str := objParams.Item[0]
				if (str.Length = 0)
				{
					return true
				}
				idx := this._IndexofSII(str, objParams.Item[1], objParams.Item[2])
				return idx >= 0
			}
			if (strParms = "MfString,MfString,MfString") { ;searchString, startIndex, count
				str := objParams.Item[0]
				if (str.Length = 0)
				{
					return true
				}
				_StartIndex := new MfInteger()
				_Count := new MfInteger()
				if (!MfInteger.TryParse(_StartIndex, objParams.Item[1]) 
					|| (!MfInteger.TryParse(_Count, objParams.Item[2]))) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				idx := this._IndexofSII(str, _StartIndex, _Count)
				return idx >= 0
			}
		}
		else
		{
			if (strParms = "MfString,MfChar") { ; searchChar
				c := objParams.Item[1]
				if (c.CharCode = 0)
				{
					return true
				}
				str := objParams.Item[0]
				return str.Contains(c)
			}
			if (strParms = "MfString,MfString") { ; var searchChar or searchString
				str := objParams.Item[0]
				strSearch := objParams.Item[1]
				if (strSearch.Length = 0)
				{
					return true
				}
				return str.Contains(strSearch)
			}
			if (strParms = "MfString,MfChar,MfInteger") { ; searchChar, startIndex
				str := objParams.Item[0]
				c := objParams.Item[1]
				if (c.CharCode = 0)
				{
					return true
				}
				return str.Contains(c, objParams.Item[2])
			}
			if (strParms = "MfString,MfString,MfInteger") { ; searchString, startIndex
				str := objParams.Item[0]
				strSearch := objParams.Item[1]
				if (strSearch.Length = 0)
				{
					return true
				}
				return str.Contains(strSearch, objParams.Item[2])
			}
			if (strParms = "MfString,MfString,MfString") { ;  var searchChar or searchString, startIndex
				str := objParams.Item[0]
				strSearch := objParams.Item[1]
				if (strSearch.Length = 0)
				{
					return true
				}
				return str.Contains(strSearch, objParams.Item[2])
			}
			if (strParms = "MfString,MfChar,MfInteger,MfInteger") {  ; searchChar, startIndex, count
				str := objParams.Item[0]
				c := objParams.Item[1]
				if (c.CharCode = 0)
				{
					return true
				}
				return str.Contains(c, objParams.Item[2], objParams.Item[3])
			}
			if (strParms = "MfString,MfString,MfInteger,MfInteger") { ;searchString, startIndex, count
				str := objParams.Item[0]
				strSearch := objParams.Item[1]
				if (strSearch.Length = 0)
				{
					return true
				}
				return str.Contains(strSearch, objParams.Item[2], objParams.Item[3])
			}
			if (strParms = "MfString,MfString,MfString,MfString") { ;searchString, startIndex, count
				str := objParams.Item[0]
				strSearch := objParams.Item[1]
				if (strSearch.Length = 0)
				{
					return true
				}
				return str.Contains(strSearch, objParams.Item[2], objParams.Item[3])
			}
		}
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:Contains ;}
;{ 	CutIfLong()
/*
	CutIfLong(maxLen)
		Cuts this instance of MfString if it is longer than a given length and returns the result as a copy.
	
	CutIfLong(maxLen, trailChars)
		Cuts this instance of MfString if it is longer than a given length, replaces cut with the value of
		trailChars and returns the result as a copy.
	
	Parameters
		maxLen
			The maximum length that the value of MfString is allowed to be before it is cut.
			Can be MfInteger or var containing Integer.
		TrailChars
			The string to append to the value of MfString. To omit any TrailChars pass ""  or
			Null in as the value. Can be MfString or var containing string.
	Returns
		Return string copy representing the MfString Instance cut with trailChars appended to the end if needed.
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.
	Throws
		Throws MfNullReferenceException is not set to an instance.
		Throws MfArgumentNullException if missing maxLen.
		Throws MfInvalidCastException if maxLen cannot be cast to MfInteger.
		Throws MfArgumentOutOfRangeException if maxLen is less than one.

	Remarks
		If the maxLen is less than the length of the trailChars then trailChars will not be included in the return value.
*/
	CutIfLong(maxLen, trailChars := "...") {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfString.IsNullOrEmpty(maxLen))
		{
			throw new MfArgumentNullException("maxLen"
				, MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName", "maxLen"))
		}
		_MaxLen := 0
		try {
			_MaxLen := MfInteger.GetValue(maxLen)
		} catch e {
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_MaxLen < 1) {
			ex := new MfArgumentOutOfRangeException("maxLen", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Value_LessThanOne"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.m_Length <= _MaxLen)
		{
			return this ; we are already shorter than our max lenght so we are fine
		}
		objTrail := new MfString(trailChars)
			
		AddTrail := false
		
		If ((objTrail.m_Length > 0) && (objTrail.m_Length < _MaxLen)) {
		
			_MaxLen := _MaxLen - objTrail.m_Length
			AddTrail := true
		}
		mStr := new MfMemoryString(this.m_Length)
		mStr.Append(this.Value)

		mStr.CharPos := _MaxLen + 1
		if (AddTrail)
		{
			mStr.Append(objTrail.Value)
		}
		retval := mStr.ToString()
		
		return this._ReturnString(retval)
	}
; End:CutIfLong();}
;{	Difference()
/*
	Difference(strFirst)
		Gets the Difference between MfString instance and the strFirst argument
	Remarks
		maxDistance of 5 if applied.
	
	
	Difference(strFirst, maxDistance)
		Gets the Difference between MfString instance and the strFirst argument with an included Max Distance.
	

	MfString.Difference(strFirst, strSecond)
		Gets the Difference between argument strFirst and argument strSecond
	Remarks
		maxDistance of 5 if applied.


	MfString.Difference(strFirst, strSecond, maxDistance)
		Gets the Difference between argument strFirst and argument strSecond argument with an included Max Distance.

	Parameters
		strFirst
			the second string to compare.
			Can be instance of MfString or var containing string.
		strSecond
			the second string to compare.
			Can be instance of MfString or var containing string.
		maxDistance
			Integer tells the algorithm to stop if the strings are already too different.
			Can be instance of MfInteger or var containing integer.
	Returns
		Returns returns the difference between the strings as a MfFloat between 0 and 1.
		0 means strings are identical. 1 means they have nothing in common.
		If ReturnAsObject Property for this instance is true then returns MfFloat otherwise returns var containing Float value.
	Throws
		Throws MfArgumentException if the incorrect number or type of parameters are passed in.
		Throws MfNotSupportedException if Overloads can not match Parameters.
*/
	Difference(args*) {
		if (MfObject.IsObjInstance(args[1], MfParams)) {
			objParams := args[1] ; arg 1 is a MfParams object so we will use it
		}
		else
		{
			objParams := new MfParams()
			objParams.AllowEmptyString := true
			
			cnt := args.MaxIndex()
			
			if (this.IsInstance())
			{
				if ((cnt < 1) || (cnt > 2)) {
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				try
				{
					for index, arg in args
					{
						if (IsObject(arg))
						{
							objParams.Add(arg)
						}
						else
						{
							if (index = 2) ; Instance must be maxDistance
							{
								objParams.AddInteger(arg)
							}
							else
							{
								objParams.AddString(arg)
							}
						}
						
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			else ; if (this.IsInstance())
			{
				if ((cnt < 1) || (cnt > 3)) {
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				try
				{
					for index, arg in args
					{
						if (IsObject(arg))
						{
							objParams.Add(arg)
						}
						else
						{
							if (index = 3) ; Non-Instance must be maxDistance
							{
								objParams.AddInteger(arg)
							}
							else
							{
								objParams.AddString(arg)
							}
						}
						
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			
		}		

		;possible MfParams
		;instance
		;	string ; str1
		;	string, int ; str1, maxOffset
		;static
		;	string, string; str1, str2
		;	string, string; str1, str2, maxOffset
		strParms := objParams.ToString()
		if (!this.IsInstance()) {
			if ((strParms = "MfString") || (strParms = "MfString,MfInteger")) {
				eMsg := MfEnvironment.Instance.GetResourceString("NullReferenceException_Object_Param","MfString")
				e := new MfNullReferenceException(eMsg)
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw e
			}
		}
		if (strParms = "MfString") {
			str2 := objParams.Item[0]
			mStrA := this._GetMStr()
			mStrB := str2._GetMStr()
			return mStrA.Difference(mStrB)
			;return this._StrDiff(this.m_value,str2)
		} else if (strParms = "MfString,MfInteger") {
			str2 := objParams.Item[0]
			maxOffset := objParams.Item[1].Value
			if (maxOffset < 1)
			{
				ex := new MfArgumentOutOfRangeException("maxDistance", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Value_LessThanOne"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			mStrA := this._GetMStr()
			mStrB := str2._GetMStr()
			return mStrA.Difference(mStrB, maxOffset)
			;result := this._StrDiff(this.m_value, str2, maxOffset)
			;retval := this.ReturnAsObject? new MfFloat(result,true):result
			;return retval
		} else if (strParms = "MfString,MfString") {
			str1 := objParams.Item[0]
			str2 := objParams.Item[1]
			mStrA := str1._GetMStr()
			mStrB := str2._GetMStr()
			return mStrA.Difference(mStrB)
			; result := this._StrDiff(str1, str2)
			; retval := this.ReturnAsObject? new MfFloat(result,true):result
			; return retval
		} else if (strParms = "MfString,MfString,MfInteger") {
			str1 := objParams.Item[0]
			str2 := objParams.Item[1]
			maxOffset := objParams.Item[2].Value
			if (maxOffset < 1)
			{
				ex := new MfArgumentOutOfRangeException("maxDistance", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Value_LessThanOne"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			mStrA := str1._GetMStr()
			mStrB := str2._GetMStr()
			return mStrA.Difference(mStrB, maxOffset)
			; result := this._StrDiff(str1, str2, maxOffset)
			; retval := this.ReturnAsObject? new MfFloat(result,true):result
			; return retval
		}  else {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
; End:Difference(objParams) ;}
;{	EndsWith()
/*
	EndsWith(str)
		Determines whether the end of MfString instance matches str. Case is Ignored
	

	EndsWith(str, comparisonType)
		Determines whether the end of MfString instance matches str and uses case rules set by comparisonType

	Parameters
		str
			MfString instance or a var containing string
		comparisonType
			One of the MfStringComparison enumeration values that specifies the rules to use in the comparison
			Can also be integer var matching an enurmation value of MfStringComparison.
		Returns
			True if value matches the end of this instance; otherwise, false.
		Throws
			Throws MfNullReferenceException if method is run on a non-instance of MfString
			Throws MfNotSupportedException if Overloads can not match Parameters.
			Throws MfArgumentException if there is an error get a value from a parameter.
		Remarks
			Overloads method supports using all vars or all objects. Mixing of vars and Objects is supported for this method.
*/
	EndsWith(args*) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		p := this._EndsWidthParams(A_ThisFunc, args*)
		strP := p.ToString()
		mfSc := MfStringComparison.Instance.OrdinalIgnoreCase
		mfsEnd := Null
		if (strP = "MfString")
		{
			mfsEnd := p.Item[0]
			if (mfsEnd.m_length > this.m_length)
			{
				return False
			}
			mStrA := this._GetMStr()
			mStrB := mfsEnd._GetMStr()
			return mStrA.EndsWith(mStrB)
		} 
		else if (strP = "MfString,MfStringComparison")
		{
			mfsEnd := p.Item[0]
			mfSc := p.Item[1]
			
		} 
		else if (strP = "MfString,MfEnum.EnumItem")
		{
			mfsEnd := p.Item[0]
			mfSc := p.Item[1]
			if(!(mfSc.ParentEnum.__Class == "MfStringComparison"))
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload",A_ThisFunc))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			
		}
		else
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload",A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		} 
		if(MfString.IsNullOrEmpty(mfsEnd))
		{
			return false
		}
		if(mfsEnd.Length > this.m_Length)	
		{
			return false
		}
		mStrA := this._GetMStr()
		mStrB := mfsEnd._GetMStr()
		if (mfSc.Equals(MfStringComparison.Instance.Ordinal))
		{
			return mStrA.EndsWith(mStrB, false)
		}
		return mStrA.EndsWith(mStrB, true)
	}

	_EndsWidthParams(MethodName, args*) {
		p := Null
		if (MfObject.IsObjInstance(args[1],MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			if (p.Count > 2)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}
		}
		else
		{
			p := new MfParams()
			p.AllowEmptyString := true ; allow empty strings to be compared
			cnt := args.MaxIndex()
			
			if (cnt > 2)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}

			for index, arg in args
			{
				try
				{
					if (IsObject(arg))
					{
						p.Add(arg)
					} 
					else
					{
						if (index = 2) ; MfStringComparison
						{
							if (!Mfunc.IsInteger(arg))
							{
								err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_EnumIllegalVal", arg))
								err.SetProp(A_LineFile, A_LineNumber, MethodName)
								throw err
							}
							p.add(MfEnum.ToObject(MfStringComparison.GetType(), arg))
						}
						else
						{
							p.AddString(arg)
						}
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
		}
		return p
	}
; End:EndsWith


;{ 	Equals()			- Overrides - MfObject
/*
	Equals(strA)
		Gets if an instance of MfString equals strA. See example 1.
	Parameters
		strA
			The string to compare to the current instance.
			Can instance of MfString or var of string.


	Equals(strA, strB)
		Static Method
		Gets if an strA equals strB. See example 2.

	Parameters
		strA
			The string to compare to strB.
			Can instance of MfString or var of string.
		strB
			The string to compare to objA.
			Can instance of MfString or var of string.
		Returns
			Returns var Boolean value of true if the objects are the same; otherwise false.
		Throws
			Throws MfArgumentNullException if objA is null.
			Throws MfArgumentException if parameters are not MfString instance.
			Throws MfNullReferenceException if objB is absent and current instance is null.
		Remarks
			Method is not affected by the state of ReturnAsObject and will always return a var containing a boolean value if no errors are thrown.
			Case sensitive method.
			This method obeys the IgnoreCase for Instances of MfString. If using Equals(strA, strB) static method then method will be
			case sensitive if StringCaseSense has be turned On.; Otherwise Equals(strA, strB) static method is NOT case sensitive.
*/
	Equals(args*) {	
		isInst := this.IsInstance()

		p := Null
		if (isInst)
		{
			p := this._EqualsParams(A_ThisFunc, args*)
		}
		else
		{
			p := MfString._EqualsParams(A_ThisFunc, args*)
		}
		
		
		strP := p.ToString()
		if (strP = "MfString")
		{
			x := this
			y := p.Item[0]
		}
		else if (strP = "MfString,MfString")
		{
			x := p.Item[0]
			y := p.Item[1]
		}
		else
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		ignoreCase := true
		if (this.IsInstance()) {
			ignoreCase := this.IgnoreCase
		} else if(A_StringCaseSense = "On") {
			ignoreCase := false
		}
		mStrA := x._GetMStr()
		mStrB := y._GetMStr()
		return mStrA.Equals(mStrB, ignoreCase)
	}

	_EqualsParams(MethodName, args*) {
		p := Null
		isInst := this.IsInstance()
		if (MfObject.IsObjInstance(args[1],MfParams)) {
			p := args[1] ; arg 1 is a MfParams object so we will use it
			if (isInst = true)
			{
				if (p.Count != 1)
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			else if (p.Count != 2)
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				ex.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw ex
			}
		}
		else
		{
			p := new MfParams()
			p.AllowEmptyString := true ; allow empty strings to be compared
			cnt := args.MaxIndex()
			if (isInst = true)
			{
				if (cnt != 1)
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			else if (cnt != 2)
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				ex.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw ex
			}
			for index, arg in args
			{
				try
				{
					if (IsObject(arg))
					{
						p.Add(arg)
					} 
					else
					{
						p.AddString(arg)
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
		}
		return p
	}
; End:Equals() ;}
;{ 	Escape()
/*
	Escape()
		Escapes current instance of MfString for use with AutoHotkey and returns a copy.
	Returns
		Returns string copy that has been escaped. All ,%`;  are proceeded by `
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.


	Escape(EscapeChar)
		Escapes current instance of MfString for use with AutoHotkey and returns a copy.
	Returns
		Returns string copy that has been escaped. All ,%`;  are proceeded by value of EscapeChar.
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.

	Parameters
		EscapeChar
			The Char or string to use to escape with.
			Defaults to ` also know as back-tick.
			Can be MfString or MfChar instance. Also can be var contaning string.
	Throws
		Throws MfInvalidCastException if EscapeChar cannot be cast to string.
		Throws MfArgumentNullException if EscapeChar is null.
	Remarks
		Escapes ,%`; and double quotes. If EscapeChar is not one of the preceding chars then it is added to the preceding chars
*/
	Escape(EscapeChar = "``") {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.m_length < 1) {
			return this._ReturnString(MfString.Empty)
		}
		if (MfString.IsNullOrEmpty(EscapeChar)) {
			ex := new MfArgumentNullException("EscapeChar",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","EscapeChar"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		strE := this.Value
		_Esc := Null
		try {
			_Esc := MfString.GetValue(EscapeChar)
		} catch e {
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToString"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		hs := ""
		if(_Esc ~= "[,%;``]")
		{
			hs := "([,%``;])"
		}
		else
		{
			hs := MfString.Format("([{0},%;``])", _Esc)
		}
		
		r := MfString.Format("{0}$1", _Esc)
		strE := RegExReplace(strE, hs, r, cFirst)
		hs := "([""])"
		r := """$1"
		strE := RegExReplace(strE, hs, r, cSecond)
		if (!Mfunc.IsNumeric(cFirst)) {
			cFirst := 0
		}
		if (!Mfunc.IsNumeric(cSecond)) {
			cSecond := 0
		}
		Count := cFirst + cSecond
		return this._ReturnString(strE)
	}
; 	End:Escape() ;}	
;{ 	EscapeSend()
/*
	EscapeSend() 
		Escape current instance of MfString for use with the send command and returns a copy.
	Returns
		Returns string copy that has been escaped.
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.
	Remarks
		Send command interprets some chars different such as # ! ^ + when sending strings.
		These characters are escaped to prepare them for use with the send command
*/
	EscapeSend() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.m_length < 1) {
			return this._ReturnString("")
		}
		strE := this.Value
		
		hs := "([{}#!^+])"
		r := "{$1}"
		strE := RegExReplace(strE, hs, r)
		return this._ReturnString(strE)
	}
	; 	End:EscapeSend() ;}
;{	Format()
/*
	MfString.Format(str, args*)
		Formats string replacing {#} with corresponding replacement arg
	Parameters
		str
			String to format. Can be MfString or var containing string.
		args*
			the args to format str with
	Returns
		Returns formated string.
		If str Parameter is an instance of MfString and that instance has ReturnAsObject set to true then a new MfString will
		be returned containing the formated version; otherwise a var will be returned containing the formated version.
		If str is null or empty then MfString.Empty value is returned.
	Remarks
		Objects Derived from MfObject will call their ToString() method if Passed in as arg.
		If arg is MfObject and not an Instance then its type name is used Objects passed in as args* must be of type MfObject.
		All MfObject derived classes will call instance.ToString().
*/
	Format(str, args*) {
		
		if (MfString.IsNullOrEmpty(str))
		{
			return ""
		}
		_returnAsObj := false
		if (MfObject.IsObjInstance(str, MfString))
		{
			retval := str.value
			_returnAsObj := str.ReturnAsObject
		} else {
			retval := str
		}
		
		Count := 0
		; bench marks show that StringReplace is more than twice as fast
		; on more complex string replacements than regex replace in AutoHotkey
		strR := ""
		aLst := new MfList()
		for index,arg in args
		{
			aLst.Add(MfString._GetObValue(arg))
		}

		searchStart := 1
		LastReplacemtIndex := -1
		searchNoIndex := "{:"
		NoIndexValue := false
		NoNonIndexValues := false
		; loop non index until hit a numbered index
		; parse the numbered index and go again
		loop
		{
			;~ if (searchStart >= strLen(retval))
			;~ {
				;~ break
			;~ }
			FoundPos := InStr(retval, "{", true, searchStart)
			if (FoundPos)
			{
				EndPos := InStr(retval, "}", true, FoundPos + 1)
				if (!EndPos)
				{
					break
				}
				ILen := StrLen(retval)
				if (FoundPos + 2 <= ILen)
				{
					NextChar := SubStr(retval, FoundPos + 1, 1)
					if (NextChar = ":")
					{
						; non indexed item
						LastReplacemtIndex++
						if (LastReplacemtIndex >= (aLst.Count))
						{
							searchStart := EndPos + 1
							; no more args to replace
							continue
						}
						len := (EndPos - FoundPos) + 1
						placeholder := SubStr(retval, FoundPos, len)
						formatter := SubStr(placeholder, 3, StrLen(placeholder) - 3)
						strF := "{:" . formatter . "}"
						replacement := format(strF, aLst.Item[LastReplacemtIndex])
						retval := Mfunc.StringReplace(retval, placeholder, replacement, 0)
						searchStart := FoundPos + StrLen(replacement)
					}
					else if (NextChar ~= "[0-9]")
					{
						; index replacement
						len := (EndPos - FoundPos) + 1
						placeholder := SubStr(retval, FoundPos, len)
						
						sIndex := ""
						iIndexCount := 0
						
						Loop, Parse, placeholder
						{
							if (A_Index = 1)
							{
								continue
							}
							if (A_LoopField ~= "[0-9]")
							{
								sIndex .= A_LoopField
								iIndexCount++
							}
							else
							{
								break
							}
						}
						If (iIndexCount = 0)
						{
							searchStart := EndPos + 1
							continue
						}
						sIndex += 0
						if (sIndex >= aLst.Count)
						{
							searchStart := EndPos + 1
							continue
						}
						if (iIndexCount = len - 2)
						{
							; simple find and replace in the format of {0}
							placeholder := "{" . format("{:i}", sIndex) . "}"
							replacement := aLst.Item[sIndex]
							retval := Mfunc.StringReplace(retval, placeholder, replacement, 1) ; replace all
							searchStart := FoundPos + StrLen(replacement)
							LastReplacemtIndex := sIndex
							continue
						}
						
						formatter := SubStr(placeholder, iIndexCount + 2, StrLen(placeholder) - (iIndexCount + 2))
						strF := "{" . formatter . "}"
						replacement := format(strF, aLst.Item[sIndex])
						retval := Mfunc.StringReplace(retval, placeholder, replacement, 1)
						searchStart := FoundPos + StrLen(replacement)
						LastReplacemtIndex := sIndex
						continue
					}
					else
					{
						searchStart := FoundPos + 1
						continue
					}
				}
					
			}
			else
			{
				break
			}
			continue
			
		}
		
		if (_returnAsObj) {
			return new MfString(retval, true)
		} else {
			return retval
		}
		
	}
	_GetObValue(obj) {
		retval := ""
		if (IsObject(obj))
		{
			if (MfObject.IsObjInstance(obj, MfObject))
			{
				retval := obj.ToString()
			}
			else
			{
				retval := "Object"
			}
		}
		else
		{
			retval := obj
		}
		return retval
	}
; End:Format(str, args*);}
;{ 	GetEnumerator()
/*
		Method: GetEnumerator()
			Gets and enumerator for string
		Parameters:
			AsCharCode
				Optional; Default is false.
				If True then string is enumerated as CharCodes; Otherwise string is enumerated as chars
		Remarks:
			Returns an enumerator that iterates through a string.  
		Returns:
			Returns an enumerator that iterates through a string.
*/
	GetEnumerator(AsCharCode:=false) {
		AsCharCode := MfBool.GetValue(AsCharCode, False)
		if (AsCharCode)
		{
			return this._NewEnumCharCode()
		}
		return this._NewEnum()
	}
; End:GetEnumerator() ;}
;{	GetHashCode()
/*
	GetHashCode()
		Gets A hash code for the current MfString.
	Returns
		Returns A hash code for the current MfString.
	Remarks
		Hash code is a alpha-numeric value that is used to insert and identify an MfString in a hash-based collection such as a Hash table.
		The GetHashCode() method provides this hash code for hashing algorithms and data structures such as a hash table.
		Two objects that are equal return hash codes that are equal. However, the reverse is not true: equal hash codes do not imply object
		equality, because different (unequal) objects can have identical hash codes. Furthermore, the this Framework does not guarantee the
		default implementation of the GetHashCode() method, and the value this method returns may differ between Framework versions such as
		32-bit and 64-bit platforms. For these reasons, do not use the default implementation of this method as a unique object identifier
		for hashing purposes.
	Caution
		A hash code is intended for efficient insertion and lookup in collections that are based on a hash table.
		A hash code is not a permanent value. For this reason:
		* Do not serialize hash code values or store them in databases.
		* Do not use the hash code as the key to retrieve an object from a keyed collection.
		* Do not test for equality of hash codes to determine whether two objects are equal. (Unequal objects can have identical hash codes.)
		  To test for equality, call the MfObject.ReferenceEquals() or MfString.Equals() method.
*/
	GetHashCode() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		str := this.Value
		
		hc := this.__MD5(str, This.Lenght)
		str := Null
		return hc
		; using String2Hex seems to be generating unreliable results
		; Empty stirng was reuturning the same results as abc
		; abcabc was generating the same result as aaaa
		;~ SetFormat, IntegerFast, D
		;~ if (this.IgnoreCase) {
			;~ strLc := MfString.GetValue(this.ToLower())
			;~ _Hex := this.String2Hex(strLc)
			;~ _Crc32 := this._GetCRC32(_Hex)
			;~ return _Crc32
		;~ }
		;~ _Hex := this.String2Hex(this.Value)
		;~ _Crc32 := this._GetCRC32(_Hex)
		
		;~ return _Crc32
	}
	__MD5( ByRef V, L=0 ) {
	 VarSetCapacity( MD5_CTX,104,0 ), DllCall( "advapi32\MD5Init", Str,MD5_CTX ) 
	 DllCall( "advapi32\MD5Update", Str,MD5_CTX, Str,V, UInt,L ? L : VarSetCapacity(V) ) 
	 DllCall( "advapi32\MD5Final", Str,MD5_CTX ) 
	 Loop % StrLen( Hex:="123456789ABCDEF0" ) 
	  N := NumGet( MD5_CTX,87+A_Index,"Char"), MD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1) 
	Return MD5 
}
; End:GetHashCode() ;}
;{ 	GetTypeCode()
/*
	Method: GetTypeCode()
		Get an enumeration value of MfTypeCode the represents MfString Type Code.
	Returns
		And instance of MfEnum.EnumItem with a constant value that represents the type of MfString.
*/
	GetTypeCode() {
		return MfTypeCode.Instance.String
	}
; End:GetTypeCode() ;}
;{	GetValue()			- Overrides	- MfPrimitive
/*
	GetValue(str)
		Gets the string value as var from MfString object or var containing a String
	Parameters
		obj
			The MfString object or var containing a string or object deriving from MfObject.
	Returns
		Returns a var containing a string or MfString.Empty if str is null or empty.
		This method is not affected by the ReturnAsObject and always returns a var.
	Throws
		Throws MfNotSupportedException if argument obj is Object but is not derived from MfObject.
	Remarks
		If obj is not a MfString instance but is derived from MfObject then the ToString() value is returned from the object.
		GetValue can be useful when your not sure if a string var or an instance of MfString or other object derived from
		MfObject is passed as a parameter.
*/
	GetValue(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (MfNull.IsNull(obj))
		{
			return ""
		}
		if (IsObject(obj))
		{
			if (MfObject.IsObjInstance(obj))
			{
				; for non String MfObject call ToString method
				return obj.ToString()
			}
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Object_Param_NonAhk", "obj"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		} 
		else
		{
			return obj
		}		
	}
; End:GetValue() ;}	
;{	IsStringObj() 
/*
		Method: IsStringObj(obj)
			IsStringObj() Gets if *obj* is instance of  [MfString](MfString.html).
		Parameters:
			obj - the *object* to check if instance of   [MfString](MfString.html).
		Remarks:
			Static function `MfString.IsString(obj)`.  
			This method is not affected by the [MfString.ReturnAsObject](MfString.ReturnAsObject.html) and always returns a var.
		Returns:
			Returns **true** if *obj* is instance of [MfString](MfString.html) elsewise returns **false**.  
			
*/
	IsStringObj(obj) {
		return MfObject.IsObjInstance(obj, MfString)
	}
	
; End:IsStringObj(obj) ;}
;{	IsNullOrEmpty()
/*
	IsNullOrEmpty(str)
		Gets if MfString instance or var is null or empty
	Parameters
		str
			the MfString instance or var it check to see if it is null or empty
	Returns
		Returns true if str is null or empty; Otherwise false
	Remarks
		Static Function
		This method is not affected by the ReturnAsObject and always returns a var.
*/
	IsNullOrEmpty(str = "") {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		isObj := IsObject(str)
		if ((isObj = True) && (MfObject.IsObjInstance(str, MfString)))
		{
			return str.m_Length < 1
		}
		if ((isObj = False) && (str = Undefined))
		{
			return False
		}
		if (MfNull.IsNull(str)) { ; handles "" and and MfNull.Null
			return True
		}
		if (isObj)
		{
			; MfString Instance is already handled
			; return true for all other objects
			return True
		}
		return StrLen(str) = 0
	}
; End:IsNullOrEmpty(str) ;}
;{	_Index(i)
/*
		Method: _Index(i)
			Index()  Gets a single character from the [MfString](MfString.html)
		Parameters:
			i - The zero-based index position to get character from [MfString](MfString.html) 
		Remarks:
			*i* can be an instance of [MfInteger](MfInteger.html) or numeric
			Internal method
		Returns:
			Returns var containing the MfChar value  at the postion of the argument *i*.  
			If [ReturnAsObject](MfString.ReturnAsObject.html) Property for this instance is **true** then returns [MfChar](MfChar.html)
			otherwise returns var containing single character value.
		Throws:
			Throws [MfNullReferenceException](MfNullReferenceException.html) if [MfString](MfString.html) in not an instace  
			Throws [MfArgumentException](MfArgumentException.html) if argument *i* is not a valid number
			or valid instance of [MfInteger](MfInteger.html) class  
			Throws [MfArgumentOutOfRangeException](MfArgumentOutOfRangeException.html) if argument *i* is out of range  
			Throws [MfException](MfException.html) if error retreiving results
*/
	_Index(i) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		
		try
		{
			int_i := MfInteger.GetValue(i) ; get the var or Integer instance value
		} catch e {
			ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBoolean"), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex

		}
		if ((int_i > (this.m_Length - 1)) || (int_i < 0))
		{
			ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_ActualValue", int_i))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		try
		{
			mStr := this._GetMStr()
			
			if (this.ReturnAsObject)
			{
				result := mStr.CharCode[int_i]
				int := new MfInteger(result)
				c := new Mfchar(int)
				c.ReturnAsObject := true
				return c
			}
			else
			{
				result := mStr.Char[int_i]
				return result
			}
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}

/*
	Property: Index
		Gets a single character from the MfString
	Parameters
		i
			The zero-based index position to get character from MfString
			i can be an instance of MfInteger or var containing integer.
	Get
		Returns var containing the MfChar value at the position of the argument i.
		If ReturnAsObject Property for this instance is true then returns MfChar; Otherwise returns var containing single character value.
	Remarks
		Read-only Property
	Throws
		Throws MfNullReferenceException if MfString in not an instance
		Throws MfInvalidCastException if argument i is not a valid integer or valid instance of MfInteger class
		Throws MfArgumentOutOfRangeException if argument i is out of range
		Throws MfException if error retrieving results
*/
	Index[i]
	{
		get {
			return this._index(i)
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
; End:Index(i) ;}	
;{	IndexOf()
/*
	IndexOf()
		Reports the zero-based index of the first occurrence of a specified Unicode character or string within this instance. The method returns -1 if the character or string is not found in this instance.
	OutputVar := instance.IndexOf(searchChar)
	OutputVar := instance.IndexOf(searchChar, startIndex)
	OutputVar := instance.IndexOf(searchChar, startIndex, count)
	OutputVar := instance.IndexOf(strSearch)
	OutputVar := instance.IndexOf(strSearch, startIndex)
	OutputVar := instance.IndexOf(strSearch, startIndex, count)
	OutputVar := MfString.IndexOf(strMain, searchChar)
	OutputVar := MfString.IndexOf(strMain, searchChar, startIndex)
	OutputVar := MfString.IndexOf(strMain, searchChar, startIndex, count)
	OutputVar := MfString.IndexOf(strMain, strSearch)
	OutputVar := MfString.IndexOf(strMain, strSearch, startIndex)
	OutputVar := MfString.IndexOf(strMain, strSearch, startIndex, count)

	IndexOf(searchChar)
		Reports the zero-based index position of the first occurrence of a character specified by searchChar within this instance.
	Parameters
		searchChar
			The Character to seek.
			Can be instance of MfChar or string var containing character.
	Returns
		Returns a zero-based index value as var containing Integer of the first position of the searchChar in current instance of MfString,
		If SearchChar is not found value of -1 is returned.


	IndexOf(searchChar, startIndex)
		Reports the zero-based index position of the first occurrence of a character specified by searchChar within this instance.
		The search starts at a character position specified by startIndex.
	Parameters
		searchChar
			The Character to seek.
			Can be instance of MfChar or string var containing character.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the first position of the searchChar in current instance of MfString,
		If SearchChar is not found value of -1 is returned.


	IndexOf(searchChar, startIndex, count)
		Reports the zero-based index position of the first occurrence of a character specified by searchChar within this instance.
		The search starts at a character position specified by startIndex and examines a  number of character positions specified by count.
	Parameters
		searchChar
			The Character to seek.
			Can be instance of MfChar or string var containing character.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
		count
			An integer representing the number of character positions to examine.
			Can be MfInteger instance or var containing integer.
		Returns
			Returns a zero-based index value as var containing Integer of the first position of the searchChar in current instance of MfString,
			If SearchChar is not found value of -1 is returned.
	

	IndexOf(strSearch)
		Reports the zero-based index position of the first occurrence of a string specified by strSearch within this instance.
	Parameters
		strSearch
			The string to seek.
			Can be MfString instance or var containing string.
		Returns
			Returns a zero-based index value as var containing Integer of the first position of the strSearch in current instance of MfString,
			If strSearch is not found value of -1 is returned.


	IndexOf(strSearch, startIndex)
		Reports the zero-based index position of the first occurrence of a string specified by strSearch within this instance.
		The search starts at a character specified by startIndex position.
	Parameters
		strSearch
			The string to seek.
			Can be MfString instance or var containing string.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the first position of the strSearch in current instance of MfString,
		If strSearch is not found value of -1 is returned.


	IndexOf(strSearch, startIndex, count)
		Reports the zero-based index position of the first occurrence of a string specified by strSearch within this instance.
		The search starts at a character specified by startIndex position and examines a  number of character positions specified by count.
	Parameters
		strSearch
			The string to seek.
			Can be MfString instance or var containing string.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
		count
			An integer representing the number of character positions to examine.
			Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the first position of the strSearch in current instance of MfString,
		If strSearch is not found value of -1 is returned.


	MfString.IndexOf(strMain, searchChar)
		Static Method
		Reports the zero-based index position of the first occurrence of a character specified by searchChar within strMain.
	Parameters
		strMain
			The main String to search for last index of specified parameters.
			Can be MfString instance or var containing string.
		searchChar
			The Character to seek.
			Can be instance of MfChar or string var containing character.
	Returns
		Returns a zero-based index value as var containing Integer of the first position of the searchChar in strMain.
		If searchChar is not found value of -1 is returned.


	MfString.IndexOf(strMain, searchChar, startIndex)
		Static Method
		Reports the zero-based index position of the first occurrence of a character specified by searchChar within strMain. The search starts at a character specified by startIndex position.
	Parameters
		strMain
			The main String to search for last index of specified parameters.
			Can be MfString instance or var containing string.
		searchChar
			The Character to seek.
			Can be instance of MfChar or string var containing character.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the first position of the searchChar in strMain.
		If searchChar is not found value of -1 is returned.


	MfString.IndexOf(strMain, searchChar, startIndex, count)
		Static Method
			Reports the zero-based index position of the first occurrence of a character specified by searchChar within strMain.
			The search starts at a character specified by startIndex position and examines a  number of character positions specified by count.
	Parameters
		strMain
			The main String to search for last index of specified parameters.
			Can be MfString instance or var containing string.
		searchChar
			The Character to seek.
			Can be instance of MfChar or string var containing character.
		startIndex
			an integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
		count
			An integer representing the number of character positions to examine.
			Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the first position of the searchChar in strMain.
		If searchChar is not found value of -1 is returned.


	MfString.IndexOf(strMain, strSearch)
		Static Method
		Reports the zero-based index position of the first occurrence strSearch within strMain.
	Parameters
		strMain
			The main String to search for last index of specified parameters.
			Can be MfString instance or var containing string.
		strSearch
			The string to seek.
			Can be MfString instance or var containing string.
		Returns
			Returns a zero-based index value as var containing Integer of the first position of the strSearch in strMain.
			If strSearch is not found value of -1 is returned.


	MfString.IndexOf(strMain, strSearch, startIndex)
		Static Method.
		Reports the zero-based index position of the first occurrence strSearch within this strMain.
		The search starts at character position specified by startIndex.
	Parameters
		strMain
			The main String to search for last index of specified parameters.
			Can be MfString instance or var containing string.
		strSearch
			The string to seek.
			Can be MfString instance or var containing string.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
		Returns
			Returns a zero-based index value as var containing Integer of the first position of the strSearch in strMain.
			If strSearch is not found value of -1 is returned.
	

	MfString.IndexOf(strMain, strSearch, startIndex, count)
		Static Method.
		Reports the zero-based index position of the first occurrence strSearch within this strMain.
		The search starts at character position specified by startIndex and examines a  number of character positions specified by count.
	Parameters
		strMain
			The main String to search for last index of specified parameters.
			Can be MfString instance or var containing string.
		strSearch
			The string to seek.
			Can be MfString instance or var containing string.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
		count
			An integer representing the number of character positions to examine.
			Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the first position of the strSearch in strMain.
		If strSearch is not found value of -1 is returned.

	General Remarks
		Index numbering starts from 0 (zero).
		Method is not affected ReturnAsObject Property.
		Overloads method supports using all vars or all objects. Mixing of vars and Objects is supported for this method.
	Throws
		Throws MfNotSupportedException if Overloads can not match Parameters.
		Throws MfNullReferenceException if MfString is not an instance.
		Throws MfArgumentException if there is an error get a value from a parameter.
		Throws MfArgumentOutOfRangeException if startIndex is out of range.	
*/
	IndexOf(args*) {
		
		objParams := Null
		if (this.IsInstance())
		{
			if (this.Length = 0)
			{
				return -1
			}
			objParams := this._IndexOfParams(A_ThisFunc, args*)
		}
		else
		{
			objParams := MfString._IndexOfParams(A_ThisFunc, args*)
		}
	
		strParms := objParams.ToString()
		
		retval := -2 ; real return value can not be less than -1
		isInst := this.IsInstance()
		if (isInst) {
			if (strParms = "MfChar") { ; searchChar
				retval := this._IndexOfC(objParams.Item[0])
			} else if (strParms = "MfString") { ; var searchChar or searchString
				str := objParams.Item[0]
				if (str.Length = 1) {
					retval := this._IndexOfC(new MfChar(str.Value))
				} else {
					retval := this._IndexOfS(str)
				}
				str := ""
			} else if (strParms = "MfChar,MfInteger") { ; searchChar, startIndex
				retval := this._IndexOfCI(objParams.Item[0],objParams.Item[1])
			} else if (strParms = "MfString,MfInteger") { ; searchString, startIndex
				retval := this._IndexofSI(objParams.Item[0],objParams.Item[1])
			} else if (strParms = "MfString,MfString") { ;  var searchChar or searchString, startIndex
				str := objParams.Item[0]
				_StartIndex := new MfInteger()
				if (!MfInteger.TryParse(_startIndex, objParams.Item[1])) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				retval := this._IndexofSI(str, _StartIndex)
				str := ""
			} else if (strParms = "MfChar,MfInteger,MfInteger") {  ; searchChar, startIndex, count
				retval := this._IndexOfCII(objParams.Item[0],objParams.Item[1],objParams.Item[2])
			} else if (strParms = "MfString,MfInteger,MfInteger") { ;searchString, startIndex, count
				retval := this._IndexofSII(objParams.Item[0],objParams.Item[1],objParams.Item[2])
			} else if (strParms = "MfString,MfString,MfString") { ;searchString, startIndex, count
				str := objParams.Item[0]
				_StartIndex := new MfInteger()
				_Count := new MfInteger()
				if (!MfInteger.TryParse(_StartIndex, objParams.Item[1]) 
					|| (!MfInteger.TryParse(_Count, objParams.Item[2]))) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				retval := this._IndexofSII(str, _StartIndex, _Count)
				str := ""
			}
		}
		else
		{
			if (strParms = "MfString,MfChar") { ; searchChar
				str := objParams.Item[0]
				retval := str.IndexOf(objParams.Item[1])
				str := ""
			} else if (strParms = "MfString,MfString") { ; var searchChar or searchString
				str := objParams.Item[0]
				retval := str.IndexOf(objParams.Item[1])
				str := ""
			} else if (strParms = "MfString,MfChar,MfInteger") { ; searchChar, startIndex
				str := objParams.Item[0]
				retval := str.IndexOf(objParams.Item[1], objParams.Item[2])
				str := ""
			} else if (strParms = "MfString,MfString,MfInteger") { ; searchString, startIndex
				str := objParams.Item[0]
				retval := str.IndexOf(objParams.Item[1], objParams.Item[2])
				str := ""
			} else if (strParms = "MfString,MfString,MfString") { ;  var searchChar or searchString, startIndex
				str := objParams.Item[0]
				retval := str.IndexOf(objParams.Item[1], objParams.Item[2])
				str := ""
			} else if (strParms = "MfString,MfChar,MfInteger,MfInteger") {  ; searchChar, startIndex, count
				str := objParams.Item[0]
				retval := str.IndexOf(objParams.Item[1], objParams.Item[2], objParams.Item[3])
				str := ""
			} else if (strParms = "MfString,MfString,MfInteger,MfInteger") { ;searchString, startIndex, count
				str := objParams.Item[0]
				retval := str.IndexOf(objParams.Item[1], objParams.Item[2], objParams.Item[3])
				str := ""
			} else if (strParms = "MfString,MfString,MfString,MfString") { ;searchString, startIndex, count
				str := objParams.Item[0]
				retval := str.IndexOf(objParams.Item[1], objParams.Item[2], objParams.Item[3])
				str := ""
			}
		}
		
		if (retval > -2) {
			return retval
		}
		; if retval is less than -1 then no value has been set an we have an error
		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}

	_IndexOfParams(MethodName, args*) {
		isInst := this.IsInstance()
		p := Null
		if (MfObject.IsObjInstance(args[1], MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			if (isInst)
			{
				if (p.Count > 3)
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			else
			{
				if ((p.Count < 2) || (p.Count > 4))
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			
		}
		else
		{
			p := new MfParams()
			p.AllowEmptyString := true
			p.AllowEmptyValue := true
			;p.AllowOnlyAhkObj := false
			
			cnt := args.MaxIndex()
			pIndex := -1
			if (isInst)
			{
				if ((cnt < 1) || (cnt > 3)) {
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
				try
				{
					for index, arg in args
					{
						if (IsObject(arg))
						{
							p.Add(arg)
						}
						else
						{
							if (index = 1) ; Instance must be string or char cannot be 0 in length
							{
								pIndex := p.AddString(arg)
								; if (p.Item[pIndex].Length = 0)
								; {
								; 	; throw error
								; 	sMsg := MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName", index)
								; 	sParam := MfEnvironment.Instance.GetResourceString("Argument_nth", index)
								; 	err := new MfArgumentNullException(sParam, sMsg)
								; 	err.SetProp(A_LineFile, A_LineNumber, MethodName)
								; 	throw err
								; }

							}
							else ; args 2 and 3 can only be integer
							{
								p.AddInteger(arg)
							}
						}
						
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			else ; if (this.IsInstance())
			{
				if ((cnt < 2) || (cnt > 4)) {
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
				try
				{
					for index, arg in args
					{
						if (IsObject(arg))
						{
							p.Add(arg)
						}
						else
						{
							if (index = 1) ; Non-Instance must be string
							{
								str := new MfString(arg)
								str.IgnoreCase := (!(A_StringCaseSense = "On"))
								p.Add(str)
							}
							else if (index = 2) ; Non-Instance must be string or char
							{
								; try for char First
								ArgChar := Null
								IsChar := MfChar.TryParse(ArgChar, arg)
								if (IsChar = true)
								{
									p.Add(ArgChar)
								}
								else
								{
									pIndex := p.AddString(arg)
									if (p.Item[pIndex].Length = 0)
									{
										; throw error
										sMsg := MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName", index)
										sParam := MfEnvironment.Instance.GetResourceString("Argument_nth", index)
										err := new MfArgumentNullException(sParam, sMsg)
										err.SetProp(A_LineFile, A_LineNumber, MethodName)
										throw err
									}
								}
							}
							else ; args 3 and 4 can only be integer
							{
								p.AddInteger(arg)
							}
						}
						
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			
		}
		return p
	}
; End:IndexOf();}
;{	LastIndexOf()
/*
	LastIndexOf()
		Reports the zero-based index position of the last occurrence of a specified Unicode character or string within this instance.
		The method returns -1 if the character or string is not found in this instance.

	OutputVar := instance.LastIndexOf(searchChar)
	OutputVar := instance.LastIndexOf(searchChar, startIndex)
	OutputVar := instance.LastIndexOf(searchChar, startIndex, count)
	OutputVar := instance.LastIndexOf(strSearch)
	OutputVar := instance.LastIndexOf(strSearch, startIndex)
	OutputVar := instance.LastIndexOf(strSearch, startIndex, count)
	OutputVar := MfString.LastIndexOf(strMain, searchChar)
	OutputVar := MfString.LastIndexOf(strMain, searchChar, startIndex)
	OutputVar := MfString.LastIndexOf(strMain, searchChar, startIndex, count)
	OutputVar := MfString.LastIndexOf(strMain, strSearch)
	OutputVar := MfString.LastIndexOf(strMain, strSearch, startIndex)
	OutputVar := MfString.LastIndexOf(strMain, strSearch, startIndex, count)


	LastIndexOf(searchChar)
		Reports the zero-based index position of the last occurrence of a character specified by searchChar within this instance.
	Parameters
		searchChar
			The Character to seek.
			Can be instance of MfChar or string var containing character.
	Returns
		Returns a zero-based index value as var containing Integer of the last position of the searchChar in current instance of MfString,
		If SearchChar is not found value of -1 is returned.


	LastIndexOf(searchChar, startIndex)
		Reports the zero-based index position of the last occurrence of a character specified by searchChar within this instance.
		The search starts at a character position specified by startIndex.
	Parameters
		searchChar
			The Character to seek.
			Can be instance of MfChar or string var containing character.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the last position of the searchChar in current instance of MfString,
		If SearchChar is not found value of -1 is returned.


	LastIndexOf(searchChar, startIndex, count)
		Reports the zero-based index position of the last occurrence of a character specified by searchChar within this instance.
		The search starts at a character position specified by startIndex and examines a  number of character positions specified by count.
	Parameters
		searchChar
			The Character to seek.
			Can be instance of MfChar or string var containing character.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
		count
			An integer representing the number of character positions to examine.
			Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the last position of the searchChar in current instance of MfString,
		If SearchChar is not found value of -1 is returned.


	LastIndexOf(strSearch)
		Reports the zero-based index position of the last occurrence of a string specified by strSearch within this instance.
	Parameters
		strSearch
			The string to seek.
			Can be MfString instance or var containing string.
	Returns
		Returns a zero-based index value as var containing Integer of the last position of the strSearch in current instance of MfString,
		If strSearch is not found value of -1 is returned.


	LastIndexOf(strSearch, startIndex)
		Reports the zero-based index position of the last occurrence of a string specified by strSearch within this instance.
		The search starts at a character specified by startIndex position.
	Parameters
		strSearch
			The string to seek.
			Can be MfString instance or var containing string.
		startIndex
			An integer representing the starting position of the search.
		Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the last position of the strSearch in current instance of MfString,
		If strSearch is not found value of -1 is returned.


	LastIndexOf(strSearch, startIndex, count)
		Reports the zero-based index position of the last occurrence of a string specified by strSearch within this instance.
		The search starts at a character specified by startIndex position and examines a  number of character positions specified by count.
	Parameters
		strSearch
			The string to seek.
			Can be MfString instance or var containing string.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
	count
		An integer representing the number of character positions to examine.
		Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the last position of the strSearch in current instance of MfString,
		If strSearch is not found value of -1 is returned.


	MfString.LastIndexOf(strMain, searchChar)
		Static Method
		Reports the zero-based index position of the last occurrence of a character specified by searchChar within strMain.
	Parameters
		strMain
			The main String to search for last index of specified parameters.
			Can be MfString instance or var containing string.
		searchChar
			The Character to seek.
			Can be instance of MfChar or string var containing character.
	Returns
		Returns a zero-based index value as var containing Integer of the last position of the searchChar in strMain.
		If searchChar is not found value of -1 is returned.


	MfString.LastIndexOf(strMain, searchChar, startIndex)
		Static Method
		Reports the zero-based index position of the last occurrence of a character specified by searchChar within strMain.
		The search starts at a character specified by startIndex position.
	Parameters
		strMain
			The main String to search for last index of specified parameters.
			Can be MfString instance or var containing string.
		searchChar
			The Character to seek.
			Can be instance of MfChar or string var containing character.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the last position of the searchChar in strMain.
		If searchChar is not found value of -1 is returned.


	MfString.LastIndexOf(strMain, searchChar, startIndex, count)
		Static Method
		Reports the zero-based index position of the last occurrence of a character specified by searchChar within strMain.
		The search starts at a character specified by startIndex position and examines a  number of character positions specified by count.
	Parameters
		strMain
			The main String to search for last index of specified parameters.
			Can be MfString instance or var containing string.
		searchChar
			The Character to seek.
			Can be instance of MfChar or string var containing character.
		startIndex
			an integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
	count
		An integer representing the number of character positions to examine.
		Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the last position of the searchChar in strMain.
		If searchChar is not found value of -1 is returned.


	MfString.LastIndexOf(strMain, strSearch)
		Static Method
		Reports the zero-based index position of the last occurrence strSearch within strMain.
	Parameters
		strMain
			The main String to search for last index of specified parameters.
			Can be MfString instance or var containing string.
		strSearch
			The string to seek.
			Can be MfString instance or var containing string.
		Returns
			Returns a zero-based index value as var containing Integer of the last position of the strSearch in strMain.
			If strSearch is not found value of -1 is returned.


	MfString.LastIndexOf(strMain, strSearch, startIndex)
		Static Method.
		Reports the zero-based index position of the last occurrence strSearch within this strMain.
		The search starts at character position specified by startIndex.
	Parameters
		strMain
			The main String to search for last index of specified parameters.
			Can be MfString instance or var containing string.
		strSearch
			The string to seek.
			Can be MfString instance or var containing string.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the last position of the strSearch in strMain.
		If strSearch is not found value of -1 is returned.


	MfString.LastIndexOf(strMain, strSearch, startIndex, count)
		Static Method.
		Reports the zero-based index position of the last occurrence strSearch within this strMain.
		The search starts at character position specified by startIndex and examines a  number of character positions specified by count.
	Parameters
		strMain
			The main String to search for last index of specified parameters.
			Can be MfString instance or var containing string.
		strSearch
			The string to seek.
			Can be MfString instance or var containing string.
		startIndex
			An integer representing the starting position of the search.
			Can be MfInteger instance or var containing integer.
		count
			An integer representing the number of character positions to examine.
			Can be MfInteger instance or var containing integer.
	Returns
		Returns a zero-based index value as var containing Integer of the last position of the strSearch in strMain.
		If strSearch is not found value of -1 is returned.
	
	General Remarks
		Index numbering starts from 0 (zero).
		Method is not affected ReturnAsObject Property.
		Overloads method supports using all vars or all objects. Mixing of vars and Objects is supported for this method.
*/
	LastIndexOf(args*) {
		objParams := Null
		if (this.IsInstance())
		{
			if (this.Length = 0)
			{
				return -1
			}
			objParams := this._IndexOfParams(A_ThisFunc, args*)
		}
		else
		{
			objParams := MfString._IndexOfParams(A_ThisFunc, args*)
		}
	
		strParms := objParams.ToString()
		
		retval := -2
		isInst := this.IsInstance()
		if (isInst) {
			if (strParms = "MfChar") { ; searchChar
				retval := this._LastIndexOfC(objParams.Item[0])
			} else if (strParms = "MfChar,MfInteger") { ; searchChar, startIndex
				retval := this._LastIndexOfCI(objParams.Item[0],objParams.Item[1])
			} else if (strParms = "MfString,MfString") { ; searchChar, startIndex
				str := objParams.Item[0]
				_StartIndex := new MfInteger()
				if (!MfInteger.TryParse(_startIndex, objParams.Item[1])) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				retval := this._LastIndexOfSI(str, _StartIndex)
				str := ""
			} else if (strParms = "MfChar,MfInteger,MfInteger") {  ; searchChar, startIndex, count
				retval := this._LastIndexOfCII(objParams.Item[0],objParams.Item[1],objParams.Item[2])
			} else if (strParms = "MfString,MfString,MfString") {  ; searchChar, startIndex, count
				str := objParams.Item[0]
				_StartIndex := new MfInteger()
				_Count := new MfInteger()
				if (!MfInteger.TryParse(_StartIndex, objParams.Item[1]) 
					|| (!MfInteger.TryParse(_Count, objParams.Item[2]))) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				retval := this._LastIndexOfSII(str, _StartIndex, _Count)
				str := ""
				
			} else if (strParms = "MfString") { ; searchString
				str := objParams.Item[0]
				if (str.Length = 1) {
					retval := this._LastIndexOfC(new MfChar(str.Value))
				} else {
					retval := this._LastIndexOfS(objParams.Item[0])
				}
				str := ""
			} else if (strParms = "MfString,MfInteger") { ; searchString, startIndex
				retval := this._LastIndexOfSI(objParams.Item[0],objParams.Item[1])
			}  else if (strParms = "MfString,MfInteger,MfInteger") { ;searchString, startIndex, count
				retval := this._LastIndexOfSII(objParams.Item[0],objParams.Item[1],objParams.Item[2])
			}
		} else {
			if (strParms = "MfString,MfChar") { ; searchChar
				str := objParams.Item[0]
				retval := str.LastIndexOf(objParams.Item[1])
				str := ""
			} else if (strParms = "MfString,MfChar,MfInteger") { ; searchChar, startIndex
				str := objParams.Item[0]
				retval := str.LastIndexOf(objParams.Item[1], objParams.Item[2])
				str := ""
			} else if (strParms = "MfString,MfString,MfString") { ; searchChar, startIndex
				str := objParams.Item[0]
				retval := str.LastIndexOf(objParams.Item[1], objParams.Item[2])
				str := ""
			} else if (strParms = "MfString,MfChar,MfInteger,MfInteger") {  ; searchChar, startIndex, count
				str := objParams.Item[0]
				retval := str.LastIndexOf(objParams.Item[1], objParams.Item[2], objParams.Item[3])
				str := ""
			} else if (strParms = "MfString,MfString,MfString,MfString") {  ; searchChar, startIndex, count
				str := objParams.Item[0]
				retval := str.LastIndexOf(objParams.Item[1], objParams.Item[2], objParams.Item[3])
				str := ""			
			} else if (strParms = "MfString,MfString") { ; searchString
				str := objParams.Item[0]
				retval := str.LastIndexOf(objParams.Item[1])
				str := ""		
			} else if (strParms = "MfString,MfString,MfInteger") { ; searchString, startIndex
				str := objParams.Item[0]
				retval := str.LastIndexOf(objParams.Item[1], objParams.Item[2])
				str := ""
			}  else if (strParms = "MfString,MfString,MfInteger,MfInteger") { ;searchString, startIndex, count
				str := objParams.Item[0]
				retval := str.LastIndexOf(objParams.Item[1], objParams.Item[2], objParams.Item[3])
				str := ""
			}
		}
		
		if (retval > -2) {
			return retval			
		}
		; if retval is less than -1 then no value has been set an we have an error
		e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", "MfString.LastIndexOf"))
		e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw e
	}
; End:LastIndexOf();}	
;{	PadLeft()
/*
	PadLeft()

	OutputVar := instance.PadLeft(totalWidth)
	OutputVar := instance.PadLeft(totalWidth, paddingChar)
	OutputVar := MfString.PadLeft(str, totalWidth)
	OutputVar := MfString.PadLeft(str, totalWidth, paddingChar)

	PadLeft(totalWidth) 
		Returns a new MfString that right-aligns the characters in this instance of MfString by padding them with spaces on the left,
		for a specified total length.


	PadLeft(totalWidth, paddingChar)
		Returns a new MfString that right-aligns the characters in this instance of MfString by padding them on the left with a
		specified character, for a specified total length.


	MfString.PadLeft(str, totalWidth)
		Static method.
		Returns new MfString that right-aligns the characters in the str of MfString by padding them with spaces on the left,
		for a specified total length. 


	MfString.PadLeft(str, totalWidth, paddingChar)
		Static method.
		Returns new MfString that right-aligns the characters in the str of MfString by padding them on the left with a specified character,
		for a specified total length.
	Parameters
		str
			A string to pad left.
			Can be MfString instance or var containing string.
		totalWidth
			An integer of the total characters in the resulting string, equal to the number of original characters plus any additional padding characters.
			Can be MfInteger instance or var containing integer.
		paddingChar
			A padding character.
			Can be MfChar instance or string var containing character.
	Returns
		A new string that is equivalent to this instance, but right-aligned and padded on the left with as many paddingChar characters
		as needed to create a length of totalWidth. However, if totalWidth is less than the length of this instance,
		the method returns a reference to the existing instance. If totalWidth is equal to the length of this instance or str value, 
		the method returns a var containing a string that is identical to this instance or str value.
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.
	Remarks
		Overloads method supports using all vars or all objects. Mixing of vars and Objects is supported for this method.
*/
	PadLeft(args*) {
		
		objParams := Null
		if (this.IsInstance())
		{
			objParams := this._PadParams(A_ThisFunc , args*)
		}
		else
		{
			objParams := MfString._PadParams(A_ThisFunc , args*)
		}

		strParms := objParams.ToString()
		padChar := " "
		retval := MfString.Empty
		_returnAsObj := false
		
		if (this.IsInstance()) {
			if (strParms = "MfInteger") {
				iLen := objParams.GetValue(0)
				newStr := MfString.__PadHelper(this, padChar, iLen)
				_returnAsObj := this.ReturnAsObject
			} else if (strParms = "MfString") {
				if (!MfInteger.TryParse(iLen, objParams.Item[0])) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				newStr := MfString.__PadHelper(this, padChar, iLen)
				_returnAsObj := this.ReturnAsObject
			} else if (strParms = "MfInteger,MfChar") {
				iLen := objParams.GetValue(0)
				padChar := objParams.GetValue(1)
				newStr := MfString.__PadHelper(this, padChar, iLen)
				_returnAsObj := this.ReturnAsObject
			} else if (strParms = "MfString,MfString") {
				; assume integer, char
				_padChar := new MfChar()
				if (!MfInteger.TryParse(iLen, objParams.Item[0]) 
					|| (!MfChar.TryParse(_padChar, objParams.Item[1]))) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				padChar := _padChar.Value
				_padChar := Null
				newStr := MfString.__PadHelper(this, padChar, iLen)
				_returnAsObj := this.ReturnAsObject
			} else {
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"
					,A_ThisFunc))
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		} else {
			if (strParms = "MfString,MfInteger") {
				objStr := objParams.Item[0]
				iLen := objParams.GetValue(1)
				_returnAsObj := objStr.ReturnAsObject
				newStr := MfString.__PadHelper(objStr, padChar, iLen)
			} else if (strParms = "MfString,MfString") {
				; assume string, integer
				if (!MfInteger.TryParse(iLen, objParams.Item[1])) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				objStr := objParams.Item[0]
				_returnAsObj := objStr.ReturnAsObject
				newStr := MfString.__PadHelper(objStr, padChar, iLen)
			} else if (strParms = "MfString,MfInteger,MfChar") {
				objStr := objParams.Item[0]
				iLen := objParams.GetValue(1)
				padChar := objParams.GetValue(2)
				_returnAsObj := objStr.ReturnAsObject
				newStr := MfString.__PadHelper(objStr, padChar, iLen)
			} else if (strParms = "MfString,MfString,MfString") {
				; assume string, integer, char
				_padChar := new MfChar()
				if (!MfInteger.TryParse(iLen, objParams.Item[1]) 
					|| (!MfChar.TryParse(_padChar, objParams.Item[2]))) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				objStr := objParams.Item[0]
				padChar := _padChar.Value
				_padChar := Null
				_returnAsObj := objStr.ReturnAsObject
				newStr := MfString.__PadHelper(objStr, padChar, iLen)
			} else {
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"
					,A_ThisFunc))
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		retval := _returnAsObj? new MfString(newStr, true):newStr
		return  retval
	}

	_PadParams(MethodName, args*) {
		isInst := this.IsInstance()
		p := Null
		if (MfObject.IsObjInstance(args[1], MfParams)) {
			p := args[1] ; arg 1 is a MfParams object so we will use it
			if (isInst)
			{
				if (p.Count > 2)
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			else
			{
				if ((p.Count < 2) || (p.Count > 3))
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
		}
		else
		{
			p := new MfParams()
			p.AllowEmptyString := True
			
			cnt := args.MaxIndex()
			pIndex := -1
			if (isInst)
			{
				if ((cnt < 1) || (cnt > 2)) {
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
				try
				{
					for index, arg in args
					{
						if (IsObject(arg))
						{
							p.Add(arg)
						}
						else
						{
							if (index = 1) ; Instance must be integer - totalwidth
							{
								p.AddInteger(arg)
							}
							else ; args 2 can only be mfchar
							{
								; try creating a char by using parse
								; let it throw an error if needed
								p.Add(MfChar.Parse(arg))
							}
						}
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			else ; if (this.IsInstance())
			{
				if ((cnt < 2) || (cnt > 3)) {
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
				try
				{
					for index, arg in args
					{
						if (IsObject(arg))
						{
							p.Add(arg)
						}
						else
						{
							if (index = 2) ; Non-Instance must integer - totalwidth
							{
								p.AddInteger(arg)
							}
							else if (index = 3) ; Non-Instance must char
							{
								; try creating a char by using parse
								; let it throw an error if needed
								p.Add(MfChar.Parse(arg))
							}
							else
							{
								p.AddString(arg)
							}
							
						}
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
		}
		return p
	}
;	End:PadLeft() ;}
;{	PadRight()
/*
	PadRight()

	OutputVar := instance.PadRight(totalWidth)
	OutputVar := instance.PadRight(totalWidth, paddingChar)
	OutputVar := MfString.PadRight(str, totalWidth)
	OutputVar := MfString.PadRight(str, totalWidth, paddingChar)

	PadRight(totalWidth)
		Returns a new MfString that left-aligns the characters in this instance of MfString by padding them with spaces on the right,
		for a specified total length.


	PadRight(totalWidth, paddingChar)
		Returns a new MfString that left-aligns the characters in this instance of MfString by padding them on the right with a
		specified character, for a specified total length.


	MfString.PadRight(str, totalWidth)
		Static Method.
		Returns a new MfString that left-aligns the characters in the str of MfString by padding them with spaces on the right,
		for a specified total length.


	MfString.PadRight(str, totalWidth, paddingChar)
		Static method.
		Returns a new MfString that left-aligns the characters in the str of MfString by padding them on the right with a specified character,
		for a specified total length.
	Parameters
		str
			A string to pad left.
			Can be MfString instance or var containing string.
		totalWidth
			An integer of the total characters in the resulting string, equal to the number of original characters plus any additional padding characters.
			Can be MfInteger instance or var containing integer.
		paddingChar
			A padding character.
			Can be MfChar instance or string var containing character.
	Returns
		A new MfString that is equivalent to this instance, but right-aligned and padded on the left with as many paddingChar
		characters as needed to create a length of totalWidth. However, if totalWidth is less than the length of this instance, the method returns a reference to the existing instance. If totalWidth is equal to the length of this instance or str value, the method returns a new MfString that is identical to this instance or str value.
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.
	Throws
		Throws MfNotSupportedException if the incorrect number or type of parameters are passed in.
		Throws MfArgumentOutOfRangeException if startIndex or length is out of range
		Throws MfArgumentException if there is an error get a value from a parameter.
	Remarks
		Overloads method supports using all vars or all objects. Mixing of vars and Objects is supported for this method.
*/
	PadRight(args*) {
		objParams := Null
		if (this.IsInstance())
		{
			objParams := this._PadParams(A_ThisFunc , args*)
		}
		else
		{
			objParams := MfString._PadParams(A_ThisFunc , args*)
		}

		strParms := objParams.ToString()
		padChar := " "
		retval := MfString.Empty
		_returnAsObj := false
		if (this.IsInstance()) {
			if (strParms = "MfInteger") {
				iLen := objParams.GetValue(0)
				_returnAsObj := this.ReturnAsObject
				newStr := MfString.__PadHelper(this, padChar, iLen, 0)
			} else if (strParms = "MfString") {
				if (!MfInteger.TryParse(iLen, objParams.Item[0])) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				newStr := MfString.__PadHelper(this, padChar, iLen, 0)
				_returnAsObj := this.ReturnAsObject
			} else if (strParms = "MfInteger,MfChar") {
				iLen := objParams.GetValue(0)
				padChar := objParams.GetValue(1)
				_returnAsObj := this.ReturnAsObject
				newStr := MfString.__PadHelper(this, padChar, iLen, 0)
			} else if (strParms = "MfString,MfString") {
				; assume integer, char
				_padChar := new MfChar()
				if (!MfInteger.TryParse(iLen, objParams.Item[0]) 
					|| (!MfChar.TryParse(_padChar, objParams.Item[1]))) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				padChar := _padChar.Value
				_padChar := Null
				newStr := MfString.__PadHelper(this, padChar, iLen, 0)
				_returnAsObj := this.ReturnAsObject
			} else {
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"
					,A_ThisFunc))
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}  else {
			if (strParms = "MfString,MfInteger") {
				objStr := objParams.Item[0]
				iLen := objParams.GetValue(1)
				_returnAsObj := objStr.ReturnAsObject
				newStr := MfString.__PadHelper(objStr, padChar, iLen, 0)
			} else if (strParms = "MfString,MfString") {
				; assume string, integer
				if (!MfInteger.TryParse(iLen, objParams.Item[1])) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				objStr := objParams.Item[0]
				_returnAsObj := objStr.ReturnAsObject
				newStr := MfString.__PadHelper(objStr, padChar, iLen, 0)
			} else if (strParms = "MfString,MfInteger,MfChar") {
				objStr := objParams.Item[0]
				iLen := objParams.GetValue(1)
				padChar := objParams.GetValue(2)
				_returnAsObj := objStr.ReturnAsObject
				newStr := MfString.__PadHelper(objStr,padChar,iLen, 0)
			} else if (strParms = "MfString,MfString,MfString") {
				; assume string, integer, char
				_padChar := new MfChar()
				if (!MfInteger.TryParse(iLen, objParams.Item[1]) 
					|| (!MfChar.TryParse(_padChar, objParams.Item[2]))) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				objStr := objParams.Item[0]
				padChar := _padChar.Value
				_padChar := Null
				_returnAsObj := objStr.ReturnAsObject
				newStr := MfString.__PadHelper(objStr, padChar, iLen, 0)
			} else {
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"
					,A_ThisFunc))
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		retval := _returnAsObj? new MfString(newStr, true):newStr
		return  retval
	}
;	End:PadRight() ;}
;{	Remove()
/*
	Remove()
	
	OutputVar := instance.Remove()

	Remove(startIndex, Count)
		Returns a new MfString in which all the characters in the current instance, beginning at a specified position and continuing through
		the last position, have been deleted.
	Parameters
		startIndex
			The zero-based position to begin deleting characters. Can be MfInteger or var containing Integer.
		count
			Optional, The number of char to remove from startIndex, forward
	Returns
		Returns A new MfString that is equivalent to this MfString except for the removed characters.
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.
	Throws
		Throws MfArgumentOutOfRangeException if startIndex is out of range
*/
	Remove(startIndex, count=-1) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		startIndex := MfInteger.GetValue(startIndex)
		count := MfInteger.GetValue(count, -1)
		if ((startIndex < 0) || (startIndex >= this.m_Length))
		{
			ex := new MfArgumentOutOfRangeException("startIndex"
				,MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Count = 0)
		{
			return this._ReturnString(this)
		}
		mStr := this._GetMStr()
		if (count < 0)
		{
			mStr.CharPos := startIndex
			retval := mStr.ToString()
			mStr.CharPos := this.m_length
			this.Value := retval
			return this._ReturnString(this)
		}
		len := count - startIndex
		if(len = this.m_length && startIndex = 0)
		{
			return this._ReturnString(this)
		}
		if (this.m_length < len)
		{
			ex := new MfArgumentOutOfRangeException("count", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexCount"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		retval := mStr.Remove(startIndex, count).ToString()
		this.Value := retval
		
		return this._ReturnString(this)
	}
; End:Remove() ;}
;{ 	RemoveWhiteSpace
/*
	Method: RemoveWhiteSpace()
		Gets a string with all Unicode whitespace chars removed

	OutputVar := MfString.RemoveWhiteSpace(str [, ReturnAsObject])

	RemoveWhiteSpace(str [, ReturnAsObject])
		Gets a string with all Unicode whitespace chars removed
	Parameters:
		str
			The string to remove all Unicode whitespace chars from.
			Can be Var or instance of MfString.
		ReturnAsObject
			Optional Boolean Value. Default is false.
			If true the return value will be an instance of MfString with ReturnAsObject set to true; Otherwise a string var is returned.
	Returns:
		If ReturnAsObject is true return MfString instance; Otherwise returns string var.
	Throws:
		Throws MfInvalidOperationException if not called as a static method.
	Since:
		Version 0.4
	Remarks:
		Static Method
*/
	RemoveWhiteSpace(str, ReturnAsObject:=false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		ReturnAsObject := MfBool.GetValue(ReturnAsObject, false)
		mStr := MfMemoryString.FromAny(str)
		mStrR := MfMemoryString.RemoveWhiteSpace(mStr)
		result := mStrR.ToString()
		mStrR := ""
		mStr := ""
		if (ReturnAsObject)
		{
			return new MfString(result, true)
		}
		return result
	}
; 	End:RemoveWhiteSpace ;}
;{	Reverse()
/*
	Reverse()
	
	OutputVar := instance.Reverse()
	OutputVar := MfString.Reverse(str)

	Reverse()
		Reverses the value of the MfString instance into a string.
	Returns
		Returns a string that has all its chars reversed.
		If ReturnAsObject Property for this instance is true then returns MfString; Otherwise returns var containing string.
	

	MfString.Reverse(str)
		Reverses the value of str into a string.
	Returns
		Returns a string that has all its chars reversed.
		If str is a MfString instance and ReturnAsObject Property is true for str then a MfString instance will be returned; Otherwise returns var containing string.
	Parameters
		str
			MfString to reverse. Can be a instance of MfString or var containing string.

	Throws
		Throws MfArgumentNullException if MfString in not an instace and str is null or empty.
*/
	Reverse(str:="") {
		retval := MfString.Empty
		_ist := this.IsInstance()
		if(_ist)
		{
			if (this.m_Length = 0)
			{
				if(this.ReturnAsObject)
				{
					retval := new MfString()
					retval.ReturnAsObject := true
					return retval
				}
				else
				{
					return MfString.Empty
				}
			} 
			mstr := this._GetMStr()
			rStr := mStr.Reverse()
			if(this.ReturnAsObject)
			{
				retval := new MfString(rStr.ToString())
				retval.ReturnAsObject := true
				return retval
			}
			return rStr.ToString()
		}
		else
		{
			if (MfString.IsNullOrEmpty(str))
			{
				ex := new MfArgumentNullException("str")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			mstr := MfMemoryString.FromAny(str)
			rStr := mStr.Reverse()
			mstr := ""
			if(this.ReturnAsObject)
			{
				retval := new MfString(rStr.ToString())
				retval.ReturnAsObject := true
				return retval
			}
			return rStr.ToString()
		}
	}
; End:Reverse() ;}
;{	Split()
/*
	Split()

	OutputVar := instance.Split()
	OutputVar := instance.Split(separator)
	OutputVar := instance.Split(separator, options)

	Split()
		Splits the current string into all it characters.


	Split(separator)
		Splits the string into part by characters in separator.


	Split(separator, options)
		Splits the string into parts by characters with options.

	Parameters
		separator
			A string of characters to split the current instance of MfString by.
			Can be string var or a MfString object instance.
		options
			MfStringSplitOptions options.
			Can be Integer, MfStringSplitOptions instance, or MfStringSplitOptions.Instance.EnumValue
	Returns
		Returns a MfGenericList of MfString containing all the instance of string found in the split.
	Throws
		Throws MfException on General erors.
		Throws MfArgumentException if there is an error get a value from a parameter.
	Remarks
		Method always returns a MfGenericList of MfString. The ReturnAsObject instance of each MfString instance in the
		MfGenericList is set to the save value of ReturnAsObject for the current instance of MfString.
		Overloads method supports using all vars or all objects. Mixing of vars and Objects is supported for this method.
*/
	Split(args*) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		;separator, options
		p := this._SplitParams(A_ThisFunc, args*)

		strP := p.ToString()
		
		separator := ""
		bRemoveEmpty := False
		bTrim := False
		bTrimStart := False
		bTrimEnd := False
		bTrimLineEndChars := False
		if (p.Count = 0)
		{
			; default no params passed in
		}
		else if (strP = "MfString")
		{
			separator := p.Item[0].Value
		}
		else if (strP = "MfString,MfStringSplitOptions")
		{
			separator := p.Item[0].Value
			options := p.Item[1]
			optVal := options.Value
			; options may be instance of MfEnum.EnumItem
			;bRemoveEmpty := options.HasFlag(MfStringSplitOptions.Instance.RemoveEmptyEntries)
			bRemoveEmpty := ((MfStringSplitOptions.Instance.RemoveEmptyEntries.Value) & optVal > 0)
			
			bTrim := ((MfStringSplitOptions.Instance.Trim.Value) & optVal > 0)
			If (bTrim = false)
			{
				bTrimStart := ((MfStringSplitOptions.Instance.TrimStart.Value) & optVal > 0)
				bTrimEnd := ((MfStringSplitOptions.Instance.TrimEnd.Value) & optVal > 0)
			}
			bTrimLineEndChars := ((MfStringSplitOptions.Instance.TrimLineEndChars.Value) & optVal > 0)
		}

		retval := new MfGenericList(MfString)

		if (this.Length = 0)
		{
			return retval
		}
		Try 
		{
			_str := this.Value

			if (MfString.IsNullOrEmpty(separator))
			{
				StringSplit, strArray, _str
			}
			else
			{
				_sepObj := new MfString(separator)
				_sep := _sepObj.Escape()
				StringSplit, strArray, _str, %_sep%
			}

			Loop, %strArray0%
			{
				i := format("{:i}",A_Index)
				SplitValue := new MfString(strArray%i%, true)
				if(bTrimLineEndChars)
				{
					SplitValue.TrimEnd(MfEnvironment.Instance.NewLine)
				}
				IsTrimmed := False
				if (bTrim)
				{
					SplitValue.Trim()
					IsTrimmed := True
				}
				If (IsTrimmed = false)
				{
					if (bTrimStart)
					{
						SplitValue.TrimStart()
					}
					if (bTrimEnd)
					{
						SplitValue.TrimEnd()
					}
				}
					
				if (bRemoveEmpty)
				{
					IsEmpty := false
					if (IsTrimmed)
					{
						IsEmpty := SplitValue.Length = 0
					}
					else
					{
						strTmp := new MfString(SplitValue.Value, true)
						IsEmpty := strTmp.Trim().Length = 0
					}
					if (IsEmpty = false)
					{
						SplitValue.ReturnAsObject := this.ReturnAsObject
						retval.Add(SplitValue)
					}
				}
				else
				{
					SplitValue.ReturnAsObject := this.ReturnAsObject
					retval.Add(SplitValue)
				}
			}
		}
		catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_General_Error"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return retval
	}

	_SplitParams(MethodName, args*) {
		p := Null
		cnt := MfParams.GetArgCount(args*)
		if (MfObject.IsObjInstance(args[1],MfParams))
		{
			p := args[1] ; arg 1 is a MfParams object so we will use it
			if (p.Count > 2)
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				ex.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw ex
			}
		}
		else
		{
			p := new MfParams()
			p.AllowEmptyString := true ; allow empty strings to be compared
			
			if (cnt > 2)
			{
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				e.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw e
			}

			for index, arg in args
			{
				try
				{
					if (IsObject(arg))
					{
						p.Add(arg)
					} 
					else
					{
						if (index = 2) ; MfStringComparison
						{
							if (!Mfunc.IsInteger(arg))
							{
								err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_EnumIllegalVal", arg))
								err.SetProp(A_LineFile, A_LineNumber, MethodName)
								throw err
							}
							p.add(MfEnum.ToObject(MfStringSplitOptions.GetType(), arg))
						}
						else
						{
							pIndex := p.AddString(arg)
						/*
							if (p.Item[pIndex].Length = 0)
							{
								; throw error
								sMsg := MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName", index)
								sParam := MfEnvironment.Instance.GetResourceString("Argument_nth", index)
								err := new MfArgumentNullException(sParam, sMsg)
								err.SetProp(A_LineFile, A_LineNumber, MethodName)
								throw err
							}
						*/
						}
					}
				}
				catch e
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
		}
		return p
	}
; End:Split() ;}
;{	StartsWith()
/*
	StartsWith()
		Determines whether the start of this string instance matches the specified string.

	OutputVar := instance.StartsWith(str)
	OutputVar := instance.(str, comparisonType)

	StartsWith(str)
		Determines whether the start of MfString instance matches str. Case is Ignored
	

	StartsWith(str, comparisonType)
		Determines whether the start of MfString instance matches str and uses case rules set by comparisonType

	Parameters
		str
			MfString instance or a var containing string
		comparisonType
			One of the MfStringComparison enumeration values that specifies the rules to use in the comparison
	Returns
		True if value matches the end of this instance; Otherwise, false.
	Throws
		Throws MfNullReferenceException if method is run on a non-instance of MfString
		Throws MfNotSupportedException if Overloads can not match Parameters.
		Throws MfArgumentException if there is an error get a value from a parameter.
	Remarks
		Overloads method supports using all vars or all objects. Mixing of vars and Objects is supported for this method.
*/
	StartsWith(args*) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		p := this._EndsWidthParams(A_ThisFunc, args*)
		strP := p.ToString()
		mfSc := MfStringComparison.Instance.OrdinalIgnoreCase
		mfsStart := Null
		if (strP = "MfString")
		{
			mfsStart := p.Item[0]
			if (mfsStart.m_length > this.m_length)
			{
				return False
			}
			mStrA := this._GetMStr()
			mStrB := mfsStart._GetMStr()
			return mStrA.StartsWith(mStrB)
			
		} 
		else if (strP = "MfString,MfStringComparison")
		{
			mfsStart := p.Item[0]
			mfSc := p.Item[1]
			
		} 
		else if (strP = "MfString,MfEnum.EnumItem")
		{
			mfsStart := p.Item[0]
			mfSc := p.Item[1]
			if(!(mfSc.ParentEnum.__Class == "MfStringComparison"))
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload",A_ThisFunc))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			
		}
		else
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload",A_ThisFunc))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		} 
		if(MfString.IsNullOrEmpty(mfsStart))
		{
			return false
		}
		if(mfsStart.Length > this.m_Length)	
		{
			return false
		}
		mStrA := this._GetMStr()
		mStrB := mfsStart._GetMStr()
		if (mfSc.Equals(MfStringComparison.Instance.Ordinal))
		{
			return mStrA.StartsWith(mStrB, false)
		}
		return mStrA.StartsWith(mStrB, true)
	}
; End:StartsWith
;{	Substring()
/*
	Substring()

	OutputVar := instance.Substring(startIndex)
	OutputVar := instance.Substring(startIndex, length)
	OutputVar := MfString.Substring(str, startIndex)
	OutputVar := MfString.Substring(str, startIndex, length)
	
	SubString(startIndex)
		Retrieves a substring from this instance. The substring starts at a specified character position.
	

	SubString(startIndex, length)
		Retrieves a substring from this instance. The substring starts at a specified character position and has a specified length.
	

	MfString.SubString(str, startIndex)
		Retrieves a substring from the str. The substring starts at a specified character position. 
		Static Method.
	

	MfString.SubString(str, startIndex, length)
		Retrieves a substring from the str. The substring starts at a specified character position and has a specified length.
		Static Method.
	Parameters
		str
			the MfString or var containing string to get the substring of. Can be MfString instance or var containing string.
		startIndex
			The zero-based MfInteger starting character position of a substring in this instance. Can be MfInteger instance or var containing integer.
		length
			MfInteger value containing the number of characters in the substring. Can be MfInteger instance or var containing integer.
	Returns
		A MfString that is equivalent to the substring of length length that begins at startIndex in this instance if str is omitted or
		MfString.Empty if startIndex is equal to the length of this instance and length is zero.
		If ReturnAsObject Property for this instance is true then returns MfString; Otherwise returns var containing string.
*/
	Substring(args*) {
		;possible MfParams
		;instance
		;	int ; start
		;	int, int ; Start, length
		;static
		;	string, int; string, start
		;	string, int, int; string,start,length
		isInst := this.IsInstance()

		objParams := Null
		if (isInst)
		{
			objParams := this._SubStringParams(A_ThisFunc, args*)
		}
		else
		{
			objParams := MfString._SubStringParams(A_ThisFunc, args*)
		}
	
		strParms := objParams.ToString()

		_returnAsObj := false
		internalString := ""
		iStart := 0
		iLen := ""
		if (isInst) {
			if (strParms = "MfInteger") {
				iStart := objParams.GetValue(0)
				internalString := this
			} else if (strParms = "MfString") {
				if (!MfInteger.TryParse(iStart, objParams.Item[0])) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				;~ iStart := _iStart.Value
				internalString := this
			} else if (strParms = "MfInteger,MfInteger") {
				iStart := objParams.GetValue(0)
				iLen := objParams.GetValue(1)
				internalString := this
			} else if (strParms = "MfString,MfString") {
				if (!MfInteger.TryParse(iStart, objParams.Item[0]) 
					|| (!MfInteger.TryParse(iLen, objParams.Item[1]))) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				;~ iStart := _iStart.Value
				;~ iLen := _iLen.Value
				internalString := this
			} else {
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"
					, A_ThisFunc))
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw e
			}
		} else {
			if (strParms = "MfString,MfInteger,MfInteger") {
				internalString := objParams.Item[0]
				iStart := objParams.GetValue(1)
				iLen := objParams.GetValue(2)
			} else if (strParms = "MfString,MfString,MfString") {
				; assume string, integer, integer - string, startindex, length
				if (!MfInteger.TryParse(iStart, objParams.Item[1]) 
					|| (!MfInteger.TryParse(iLen, objParams.Item[2]))) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				internalString := objParams.Item[0]
			} else if (strParms = "MfString,MfInteger") {
				internalString := objParams.Item[0]
				iStart := objParams.GetValue(1)
			} else if (strParms = "MfString,MfString") {
				; assume String obj start index
				if (!MfInteger.TryParse(iStart, objParams.Item[1])) {
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				internalString := objParams.Item[0]
			} else {
				e := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload"))
				e.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw e
			}
		}

		
		if (internalString.m_length = 0) {
			if (internalString.ReturnAsObject)
			{
				return new MfString()
			}
			return ""
		}
		if (iStart < 0 ) {
			ex := new MfArgumentOutOfRangeException("startIndex",MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.Source := A_ThisFunc
			throw ex
		}
		if (iStart > internalString.m_length) {
			ex := new MfArgumentOutOfRangeException("startIndex",MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.Source := A_ThisFunc
			throw ex
		}
		if (ilen = "")
		{
			ilen := internalString.m_length - iStart
		}
		if (iLen < 0) {
			ex := new MfArgumentOutOfRangeException("length",MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
			ex.Source := A_ThisFunc
			throw ex
		}
		if (iStart > (internalString.m_Length - iLen))
		{
			ex := new MfArgumentOutOfRangeException("length",MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_LengthString"))
			ex.Source := A_ThisFunc
			throw ex
		}
		
		if (iLen = 0) {
			if (internalString.ReturnAsObject)
			{
				return new MfString()
			}
			return ""
		}
		mstr := internalString._GetMStr()
		if (iStart = 0)
		{
			mstr.CharPos := ilen
			retval := mstr.ToString()
			mstr.CharPos := internalString.m_length
		}
		else
		{
			retval := mstr.ToString(iStart, ilen)
		}
		
		retval := internalString.ReturnAsObject? new MfString(retval, true):retval
		return  retval
	}

	_SubStringParams(MethodName, args*) {
		p := Null
		isInst := this.IsInstance()
		if (MfObject.IsObjInstance(args[1],MfParams)) {
			p := args[1] ; arg 1 is a MfParams object so we will use it
			if (isInst = true)
			{
				if (p.Count > 2)
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			else if (p.Count > 3)
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				ex.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw ex
			}
		}
		else
		{
			p := new MfParams()
			p.AllowEmptyString := true ; allow empty strings to be compared
			cnt := args.MaxIndex()
			if (isInst = true)
			{
				if (cnt > 2)
				{
					ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
					ex.SetProp(A_LineFile, A_LineNumber, MethodName)
					throw ex
				}
			}
			else if (cnt > 3)
			{
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", MethodName))
				ex.SetProp(A_LineFile, A_LineNumber, MethodName)
				throw ex
			}
			if (isInst = True)
			{
				for index, arg in args
				{
					try
					{
						if (IsObject(arg))
						{
							p.Add(arg)
						} 
						else
						{
							p.AddInteger(arg)
						}
					}
					catch e
					{
						ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
						ex.SetProp(A_LineFile, A_LineNumber, MethodName)
						throw ex
					}
				}
			}
			else
			{
				for index, arg in args
				{
					try
					{
						if (IsObject(arg))
						{
							p.Add(arg)
						} 
						else
						{
							if (index = 1)
							{
								p.AddString(arg)
							}
							else
							{
								p.AddInteger(arg)
							}
						}
					}
					catch e
					{
						ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Error_on_nth", index), e)
						ex.SetProp(A_LineFile, A_LineNumber, MethodName)
						throw ex
					}
				}
			}
		}
		return p
	}
; End:Substring();}
;{	ToCharArray()	
/*
	ToCharArray()

	OutputVar := instance.ToCharArray()
	OutputVar := instance.ToCharArray(startIndex)
	OutputVar := instance.ToCharArray(startIndex, length)

	ToCharArray()
		Copies the characters in a specified substring in this instance to a MfList of MfChar.


	ToCharArray(startIndex)
		Copies the characters in a specified substring in this instance to a MfList of MfChar starting at the positing of startIndex.


	ToCharArray(startIndex, length)
		Copies the characters in a specified substring in this instance to a MfList of MfChar starting at the positing of startIndex and
		stopping at length position.

	Parameters
		startIndex
			The zero-based index starting position of a substring in this instance.
			Can be MfInteger instance or var containing Integer.
		length
			The length of the substring in this instance.
			Can be MfInteger instance or var containing Integer.
	Returns
		Returns a MfGenericList of MfChar containing MfChar instances representing all the chars of this instance of MfString.
	Throws
		Throws MfNullReferenceException if method is called on a non-instance.
		Throws MfArgumentException if the arguments are of the incorrect type.
		Throws MfArgumentOutOfRangeException if startIndex or length are out of range.
		Throws MfException on General Errors.
	Remarks
		If ReturnAsObject is set to true then each MfChar in the results MfList of MfChar will have its MfChar.ReturnAsObject set to true;
		Otherwise each MfChar will have its MfChar.ReturnAsObject set to false.
*/
	ToCharArray(startIndex = 0, length = "") {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		startIndex := MfInteger.GetValue(startIndex, 0)
		length := MfInteger.GetValue(length, -1)
		if ((StartIndex < 0) || (StartIndex >= this.m_Length))
		{
			ex := new MfArgumentOutOfRangeException("StartIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (length > 0)
		{
			If (length - startIndex > this.m_Length)
			{
				ex := new MfArgumentOutOfRangeException("Length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		mStr := this._GetMStr()

		clst := mStr.ToCharList(startIndex, length)
		rlst := new MfList()
		inLst := rLst.m_InnerList
		j := 1
		for i, v in clst
		{
			int := new MfInteger(v)
			inLst[j++] := new MfChar(int)
		}
		rlst.m_Count := clst.Count
		return rlst
	}
; End:ToCharArray(StartIndex = 0, Length = "") ;}
;{ ToCharList
/*
	Method: ToCharList()

	OutputVar := instance.ToCharList([startIndex, length])

	ToCharList([startIndex, length])
		Convert current instance of MfString to instance of MfCharList.
	Parameters:
		startIndex
			Optional, the zero-based integer index starting character position of in this instance.
			Can be MfInteger instance or var containing integer.
		length
			Integer value containing the number of characters copy to the list.
			Can be MfInteger instance or var containing integer.
	Returns:
		Instance of MfCharList
	Remarks:
		MfCharList instance will contain a list of integer char code value that represent the string outputted.
*/
	ToCharList(startIndex:=0, length:=-1) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		startIndex := MfInteger.GetValue(startIndex, 0)
		length := MfInteger.GetValue(length, -1)
		if ((StartIndex < 0) || (StartIndex >= this.m_Length))
		{
			ex := new MfArgumentOutOfRangeException("StartIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (length > 0)
		{
			If (length - startIndex > this.m_Length)
			{
				ex := new MfArgumentOutOfRangeException("Length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
		mStr := this._GetMStr()

		return mStr.ToCharList(startIndex, length)
	}
; 	End:ToCharList ;}
;{ 	FromCharList
/*
	Method: FromCharList()
		Create a new instance of MfString from an instance of MfCharList.

	OutputVar := instance.FromCharList(chars [,startIndex, length])

	MfString.FromCharList(chars [,startIndex, length])
		Create a new instance of MfString from an instance of MfCharList.
	Parameters:
		chars
			Instance of MfCharList that contains chars values to convert MfString instance.
		startIndex
			Optional, the zero-based starting index in chars to start the conversion.
			If Omitted then chars are read from index 0 forward
			Can be MfInteger instance or var containing integer.
		length
			Integer value containing the number of char value copy from the list.
			Can be MfInteger instance or var containing integer.
	Returns:
		Returns new instance of MfString with RetunAsObject set to true, representing chars as a string.
	Remarks:
		Static Method
*/
	FromCharList(chars, startIndex:=0, length:=-1) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		startIndex := MfInteger.GetValue(startIndex, 0)
		length := MfInteger.GetValue(length, 0)
		if(MfObject.IsObjInstance(chars, MfCharList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "chars"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(chars.m_Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "chars"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (length = 0)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		mV := MfMemStrView.FromCharList(chars, startIndex, length)
		strObj := new MfString(mV.ToString(),true)
		return strObj
	}
;{	ToLower()
/*
	ToLower()

	OutputVar := instance.ToLower()

	ToLower()
		Returns a copy of MfString instance converted to lowercase.
	Returns
		Returns string copy containing Lower case value representing the current instance.
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.
*/
	ToLower() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := Mfunc.StringLower(this.Value)
		return this._ReturnString(retval)
	}
; End:ToLower() ;}
;{	ToTitle()
/*
	ToTitle()
	
	OutputVar := instance.ToTitle()

	ToTitle()
		Returns a copy of this MfString converted to Title-case.
	Returns
		Returns string copy containing Title case value representing the current instance.
		If ReturnAsObject Property for this instance is true then returns MfString;Otherwise returns var containing string.
*/
	ToTitle() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := Mfunc.StringLower(this.Value, "T")
		return this._ReturnString(retval)
	}
; End:ToTitle() ;}
;{	ToUpper()
/*
	ToUpper()

	OutputVar := instance.ToUpper()

	ToUpper()
		Returns a copy of this MfString converted to uppercase.
	Returns
		Returns string copy containing Lower case value representing the current instance.
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.
*/
	ToUpper() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		retval := Mfunc.StringUpper(this.Value)
		return this._ReturnString(retval)
	}
; End:UpperCase() ;}
;{	Trim()	
/*
	Trim()
	
	OutputVar := instance.Trim()
	OutputVar := instance.Trim(trimChars)
	
	Trim()
		Removes all leading and trailing white-space characters from the current MfString object.
	

	Trim(trimChars)
		Removes all leading and trailing occurrences of a set of characters specified in trimChars from the current MfString object.
	
	Parameters
		trimChars
			String value containing chars to remove as MfString instance or var containing string; or MfGenericList of MfChar; or null.
	Returns
		Returns a string with a value that remains after all occurrences of the characters in the trimChars parameter are removed from the end of the current string. If trimChars is null or empty, White-space characters are removed instead.
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.
	Throws
		Throws MfArgumentException if trimChars is incorrect type.
*/
	Trim(trimChars = "") {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.m_Length = 0)
		{
			return this._ReturnString(this)
		}
		if (MfNull.IsNull(trimChars)) {
			;this.Value := this._TrimHelperA(2)
			; considerable faster then previous line 10 x faster on some test
			mStr := this._GetMStr()
			mStr.Trim()
			this.Value := mStr.Tostring() ;Trim(this.Value)
			this._ResetPtr() ; set the memory address of the string value
			return this._ReturnString(this)
		}
		if (IsObject(trimChars)) {
			if (MfObject.IsObjInstance(trimChars, MfString)) {
				;this.Value := this._TrimHelperB(trimChars, 2)
				mStr := this._GetMStr()
				mStr.Trim(trimChars)
				this.Value := mStr.Tostring()
				this._ResetPtr() ; set the memory address of the string value
				return this._ReturnString(this)
			}
			if (MfObject.IsObjInstance(trimChars, "MfGenericList") && (trimChars.ListType.TypeName = "MfChar"))
			{
				;this.Value := this._TrimHelperC(trimChars, 2)
				tChars := new MfMemoryString(trimChars.Count)
				for i, c in trimChars
				{
					tChars.Append(c.Value)
				}
				mStr := this._GetMStr()
				mStr.Trim(tChars)
				tChars := ""
				this.Value := mStr.Tostring()
				this._ResetPtr() ; set the memory address of the string value
				return this._ReturnString(this)
			}
			if (MfObject.IsObjInstance(trimChars, MfCharList))
			{
				
				mStr := this._GetMStr()
				mStr.Trim(trimChars.ToString())
				this.Value := mStr.Tostring()
				this._ResetPtr() ; set the memory address of the string value
				return this._ReturnString(this)
			}
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType"
				, "trimChars", "MfString or MfGenericList of MfChar"),"trimChars")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		mStr := this._GetMStr()
		mStr.Trim(trimChars)
		this.Value := mStr.Tostring()
		this._ResetPtr() ; set the memory address of the string value
		return this._ReturnString(this)
	}
; End:Trim() ;}	
;{	TrimEnd()
/*
	TrimEnd()

	OutputVar := instance.TrimEnd()
	OutputVar := instance.TrimEnd(trimChars)
	
	TrimEnd()
		Removes all trailing occurrences of white-space from the current MfString.
	

	TrimEnd(trimChars)
		Removes all trailing occurrences of a set of characters specified in trimchars from the current MfString.
	
	Parameters
		trimChars
			String value containing chars to remove as MfString instance or var containing string; or MfGenericList of MfChar; or null.
	Returns
		Returns a string that remains after all occurrences of the characters in the trimChars parameter are removed from the end of the
		current MfString. If trimChars is null or an empty, White-space characters are removed instead.
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.
	Throws
		Throws MfArgumentException if trimChars is incorrect type.
*/
	TrimEnd(trimChars = "")	{
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.m_length = 0)
		{
			return this._ReturnString(this)
		}
		if (MfNull.IsNull(trimChars)) {
			;this.Value := this._TrimHelperA(2)
			; considerable faster then previous line 10 x faster on some test
			mStr := this._GetMStr()
			mStr.TrimEnd()
			this.Value := mStr.Tostring() ;Trim(this.Value)
			this._ResetPtr() ; set the memory address of the string value
			return this._ReturnString(this)
		}
		if (IsObject(trimChars)) {
			if (MfObject.IsObjInstance(trimChars, MfString)) {
				;this.Value := this._TrimHelperB(trimChars, 2)
				mStr := this._GetMStr()
				mStr.TrimEnd(trimChars)
				this.Value := mStr.Tostring()
				this._ResetPtr() ; set the memory address of the string value
				return this._ReturnString(this)
			}
			if (MfObject.IsObjInstance(trimChars, "MfGenericList") && (trimChars.ListType.TypeName = "MfChar"))
			{
				;this.Value := this._TrimHelperC(trimChars, 2)
				tChars := new MfMemoryString(trimChars.Count)
				for i, c in trimChars
				{
					tChars.Append(c.Value)
				}
				mStr := this._GetMStr()
				mStr.TrimEnd(tChars)
				tChars := ""
				this.Value := mStr.Tostring()
				this._ResetPtr() ; set the memory address of the string value
				return this._ReturnString(this)
			}
			if (MfObject.IsObjInstance(trimChars, MfCharList))
			{
				
				mStr := this._GetMStr()
				mStr.TrimEnd(trimChars.ToString())
				this.Value := mStr.Tostring()
				this._ResetPtr() ; set the memory address of the string value
				return this._ReturnString(this)
			}
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType"
				, "trimChars", "MfString or MfGenericList of MfChar"),"trimChars")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		mStr := this._GetMStr()
		mStr.TrimEnd(trimChars)
		this.Value := mStr.Tostring()
		this._ResetPtr() ; set the memory address of the string value
		return this._ReturnString(this)
	}
; End:TrimEnd() ;}
;{	TrimStart()
/*
	TrimStart()

	OutputVar := instance.TrimStart()
	OutputVar := instance.TrimStart(trimChars)

	TrimStart()
		Removes all leading occurrences of white-space from the current MfString.
	

	TrimStart(trimChars)
		Removes all leading occurrences of a set of characters specified in trimchars from the current MfString.
	
	Parameters
		trimChars
			String value containing chars to remove as MfString instance or var containing string; or MfGenericList of MfChar; or null.
	Returns
		Returns The string that remains after all occurrences of the characters in the trimChars parameter are removed from the start
		of the current MfString. If trimChars is null or an empty, White-space characters are removed instead.
		If ReturnAsObject Property for this instance is true then returns MfString;Otherwise returns var containing string.
	Throws
		Throws MfArgumentException if trimChars is incorrect type.
*/
	TrimStart(trimChars = "") {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.m_length = 0)
		{
			return this._ReturnString(this)
		}
		if (MfNull.IsNull(trimChars)) {
			;this.Value := this._TrimHelperA(2)
			; considerable faster then previous line 10 x faster on some test
			mStr := this._GetMStr()
			mStr.TrimStart()
			this.Value := mStr.Tostring() ;Trim(this.Value)
			this._ResetPtr() ; set the memory address of the string value
			return this._ReturnString(this)
		}
		if (IsObject(trimChars)) {
			if (MfObject.IsObjInstance(trimChars, MfString)) {
				;this.Value := this._TrimHelperB(trimChars, 2)
				mStr := this._GetMStr()
				mStr.TrimStart(trimChars)
				this.Value := mStr.Tostring()
				this._ResetPtr() ; set the memory address of the string value
				return this._ReturnString(this)
			}
			if (MfObject.IsObjInstance(trimChars, "MfGenericList") && (trimChars.ListType.TypeName = "MfChar"))
			{
				;this.Value := this._TrimHelperC(trimChars, 2)
				tChars := new MfMemoryString(trimChars.Count)
				for i, c in trimChars
				{
					tChars.Append(c.Value)
				}
				mStr := this._GetMStr()
				mStr.TrimStart(tChars)
				tChars := ""
				this.Value := mStr.Tostring()
				this._ResetPtr() ; set the memory address of the string value
				return this._ReturnString(this)
			}
			if (MfObject.IsObjInstance(trimChars, MfCharList))
			{
				
				mStr := this._GetMStr()
				mStr.TrimStart(trimChars.ToString())
				this.Value := mStr.Tostring()
				this._ResetPtr() ; set the memory address of the string value
				return this._ReturnString(this)
			}
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType"
				, "trimChars", "MfString or MfGenericList of MfChar"),"trimChars")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		mStr := this._GetMStr()
		mStr.TrimStart(trimChars)
		this.Value := mStr.Tostring()
		this._ResetPtr() ; set the memory address of the string value
		return this._ReturnString(this)
	}
; End:TrimStart() ;}
;{ 	UnEscape()
/*
	UnEscape()
	
	OutputVar := instance.UnEscape()
	
	UnEscape()
		UnEscapes current instance of MfString that is encoded for AutoHotkey and returns a copy.
	Returns
		Returns string copy that has been un-escaped.
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.
	

	UnEscape(EscapeChar)
		UnEscapes current instance of MfString that is encoded for AutoHotkey and returns a copy.
	Returns
		Returns string copy that has been un-escaped by EscaptChar.
		If ReturnAsObject Property for this instance is true then returns MfString otherwise returns var containing string.
	
	Parameters
		EscapeChar
			The MfChar to use to escape with. Default to `
	Throws
		Throws MfArgumentNullException if EscapeChar is null.
	Remarks
		UnEscapes ,%`; and double quotes
*/
	UnEscape(EscapeChar = "``") {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		if (this.m_length < 1) {
			return this._ReturnString(MfString.Empty)
		}
		
		if (MfString.IsNullOrEmpty(EscapeChar)) {
			ex := new MfArgumentNullException("EscapeChar",MfEnvironment.Instance.GetResourceString("ArgumentNull_WithParamName","EscapeChar"))
			ex.Source := A_ThisFunc
			throw ex
		}
		strE := this.Value
		_Esc := MfString.GetValue(EscapeChar)
		hs := MfString.Format("{0}([,%{0};])", _Esc) ; `([,%`;])
		r := "$1"
		strE := RegExReplace(strE, hs, r, cFirst) ; replace `, `% `; ``
		hs := """("")" ; "(")
		strE := RegExReplace(strE, hs, r, cSecond) ; replace ""
		if (!Mfunc.IsNumeric(cFirst)) {
			cFirst := 0
		}
		if (!Mfunc.IsNumeric(cSecond)) {
			cSecond := 0
		}
		Count := cFirst + cSecond
		
		return this._ReturnString(strE)
	}
; 	End:UnEscape ;}
; End:Methods ;}
;{ Internal Methods
;{ 	_NewEnum
/*
	Method: _NewEnum()

	_NewEnum()
		Default enumerator
	Returns:
		Returns an enumerator that enumerates each char of the current MfString Instance
*/
	_NewEnum() {
		mStr := this._GetMStr()
		mView := mStr.m_MemView
		return new MfMemStrView.Enumerator(mView, true)
	}
; 	End:_NewEnum ;}
;{ 	_NewEnumCharCode
	; private method
	; gets an enumerator that enum string as charcodes
	; used with GetEnumerator(AsCharCode:=false)
	_NewEnumCharCode() {
		mStr := this._GetMStr()
		mView := mStr.m_MemView
		return new MfMemStrView.Enumerator(mView, false)
	}
; 	End:_NewEnumCharCode ;}
;{ 	compare
	_CompareSISII(strA, indexA, strB, indexB, length) {
		bIgnoreCase := new MfBool()
		bIgnoreCase.Value := (!(A_StringCaseSense = "On"))
		if (this.IsInstance()) {
			bIgnoreCase.Value := this.IgnoreCase
		}
		return MfString._CompareSISIIB(strA, indexA, strB, indexB, length, bIgnoreCase)
	}
	_CompareSISIIB(strA, indexA, strB, indexB, length, ignoreCase) {
		if (strA.m_length = 0) {
			return -1
		}
		if (strB.m_length = 0) {
			return 1
		}
		
		

		intA := length.Value
		intB := intA
		iStartA := indexA.Value
		iStartB := indexB.Value
		LengthA := strA.m_length
		LengthB := strB.m_length
		if (iStartA >= LengthA)
		{
			ex := new MfArgumentOutOfRangeException("strA", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (iStartB >= LengthB)
		{
			ex := new MfArgumentOutOfRangeException("strB", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_IndexString"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		mStrA := strA._GetMStr()
		mStrB := strB._GetMStr()


		if ((LengthA - iStartA) < intA)
		{
			intA := LengthA - iStartA
		}
		if ((LengthB - iStartB) < intB)
		{
			intB := LengthB - iStartB
		}
		ic := MfBool.GetValue(ignoreCase)
		subA := mStrA.SubString(iStartA, intA)
		subB := mStrB.SubString(iStartB, intB)
		return subA.CompareOrdinal(subB, ic)
	}
	_CompareSSB(strA, strB, ignoreCase) {
		mStrA := strA._GetMStr()
		mStrB := strB._GetMStr()
		return mStrA.CompareOrdinal(mStrB, ignoreCase.Value)
	}
	_CompareSSC(strA, strB, comparisonType) {
		if (comparisonType.Value > MfStringComparison.Instance.MaxValue)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("NotSupported_StringComparison"), "comparisonType")
			ex.Source := A_ThisFunc
			throw ex
		}
		mStrA := strA._GetMStr()
		mStrB := strB._GetMStr()
		if (comparisonType.Value = MfStringComparison.Instance.OrdinalIgnoreCase.Value)
		{
			return mStrA.CompareOrdinal(mStrB, true)
		}
		else if (comparisonType.Value = MfStringComparison.Instance.Ordinal.Value)
		{
			return mStrA.CompareOrdinal(mStrB, false)
		}
	}
	_CompareSS(strA, strB) {
		
		; >, <, >=, <= obey StringCaseSense
		; <> and != obey StringCaseSense
		
		ignoreCase := true
		if (this.IsInstance()) {
			ignoreCase := this.IgnoreCase
		} else if(A_StringCaseSense = "On") {
				ignoreCase := false
		}
		if (ignoreCase = true) {
			if (strA.Value = strB.Value) {
				return 0
			}
		} else {
			if (strA.Value == strB.Value) {
				return 0
			}
		}
		
		if (MfString.IsNullOrEmpty(strA)) {
			return -1
		}
		if (MfString.IsNullOrEmpty(strB)) {
			return 1
		}

		if (strA.Value > strB.Value) {
			return -1
		} else {
			return 1
		}
	}
; End:compare ;}
;{ 	CreateTrimmedString()
/*
	Method: _CreateTrimmedString(start, end)
		_CreateTrimmedString() Creates a trimmed string, substring from start and end vaiues
	Parameters:
		start - the zero based index start of the string
		end - the end or the string
	Remarks:
		Internally uses AutoHotkey substring one baseed index.  
		Method is usd by Trim(), _TrimHelperA(), TrimHelperB()
	Returns:
		Returns var containing string that is a substring of this.Value
*/	
	_CreateTrimmedString(start, end) {
		pStart := MfInteger.GetValue(start)
		pEnd := MfInteger.GetValue(end)
		iEnd := pEnd - pStart + 1
		if (iEnd = MfInteger.GetValue(this.Length))
		{
			return this.Value
		}
		if (iEnd = 0)
		{
			return MfString.Empty
		}
		iStart := pStart + 1 ; move to one based index from zero based index
		retval := SubStr(this.Value, iStart, iEnd)
		return retval
	}
; End:CreateTrimmedString() ;}
;{ 	_GetMStr
	; gets a MfMemoryString Representing the current string value
	; instance method
	_GetMStr() {
		; sometime appending string does not change ptr will also check is a new Length set
		if (this.m_ptrChanged || (this.m_mStr.m_CharCount != this.m_Length))
		{
			this._ResetPtr()
			this.m_ptrChanged := false
			this.m_mStr := ""
			this.m_mStr := new MfMemoryString(this.m_length,,,this.m_ptr)
		}
		return this.m_mStr
	}
; 	End:_GetMStr ;}
;{	IndexOf
	_IndexOfC(searchChar) {
		return MfString._IndexOfSC(this, searchChar)
	}
	_IndexOfCI(searchChar, startIndex) {
		mstr := this._GetMStr()
		return mstr.IndexOf(searchChar,startIndex,,this.m_IgnoreCase)
	}
	_IndexOfCII(searchChar, startIndex, count) {
		mstr := this._GetMStr()
		return mstr.IndexOf(searchChar,startIndex, count, this.m_IgnoreCase)

	}
	_IndexOfS(searchString) {
		return MfString._IndexOfSS(this, searchString)
	}
	_IndexofSI(searchString, startIndex) {
		mstr := this._GetMStr()
		return mstr.IndexOf(searchString,startIndex, , this.m_IgnoreCase)
	}
	_IndexofSII(searchString, startIndex, count) {
		mstr := this._GetMStr()
		return mstr.IndexOf(searchString,startIndex, count, this.m_IgnoreCase)
	}
	_IndexOfSC(str, searchChar) {
		c := MfChar.GetValue(searchChar) ; returns null or single MfChar as var
		retVal := -1
		if (str.m_Length = 0) {
			return retVal
		}
		if (MfNull.IsNull(c)) {
			return retVal
		}
		mStr := str._GetMStr()

		return mStr.IndexOf(c,0,,str.IgnoreCase)
	}
	_IndexOfSS(str, searchString) {
		mstr := str._GetMStr()
		if (mstr.Length = 0)
		{
			return -1
		}
		mSearch := searchString._GetMStr()
		if (mSearch.Length = 0)
		{
			return -1
		}
		return mstr.IndexOf(mSearch,0,,str.m_IgnoreCase)
	}
; End:IndexOf ;}
;{	LastIndexOf()
	_LastIndexOfSC(str, searchChar) {
		c := MfChar.GetValue(searchChar) ; returns null or single MfChar as var
		retVal := -1
		if (str.m_Length = 0) {
			return retVal
		}
		if (MfNull.IsNull(c)) {
			return retVal
		}
		mStr := str._GetMStr()

		return mStr.LastIndexOf(searchChar,,,str.IgnoreCase)
	}
	_LastIndexOfC(searchChar) {
		return MfString._LastIndexOfSC(this, searchChar)
	}
	_LastIndexOfCI(searchChar, startIndex) {
		mstr := this._GetMStr()
		if (mstr.Length = 0)
		{
			return -1
		}
		return mstr.LastIndexOf(searchChar,startIndex,,this.m_IgnoreCase)
	}
	_LastIndexOfCII(searchChar, startIndex, count) {
		mstr := this._GetMStr()
		if (mstr.Length = 0)
		{
			return -1
		}
		return mstr.LastIndexOf(searchChar,startIndex, count, this.m_IgnoreCase)
	}
	_LastIndexOfS(searchString) {
		return MfString._LastIndexOfSS(this, searchString)
	}
	_LastIndexOfSS(str,searchString) {
		mstr := str._GetMStr()
		if (mstr.Length = 0)
		{
			return -1
		}
		return mstr.LastIndexOf(searchString,,, str.m_IgnoreCase)
	}
	_LastIndexOfSI(searchString, startIndex) { ; search instance substring for str
		mstr := this._GetMStr()
		if (mstr.Length = 0)
		{
			return -1
		}
		return mstr.LastIndexOf(searchString,,, this.m_IgnoreCase)
	}
	_LastIndexOfSII(searchString, startIndex, count) { ; search instance substring for str
		mstr := this._GetMStr()
		if (mstr.Length = 0)
		{
			return -1
		}
		return mstr.LastIndexOf(searchString, startIndex, count, this.m_IgnoreCase)
	}
; End:LastIndexOf() ;}
;{	PadHelper()
	__PadHelper(Str, PadChar, PadLen, Left:=1) {
	sLen := Str.m_length
	
	if (sLen >= PadLen)
		return str.Value
	
	sDif := PadLen - sLen

	mStrPad := MfMemoryString.FromAny(PadChar)
	if(mStrPad.Length = 0)
	{
		ex := new MfArgumentNullException("PadChar")
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
	cc := mStrPad.CharCode[0]
	mStrPad := ""
	ms := new MfMemoryString(sLen + sDif)

	If (Left=1) 
	{
		ms.AppendCharCode(cc,sDif)
		ms.Append(str._GetMStr())
	}
	else
	{
		ms.Append(str._GetMStr())
		ms.AppendCharCode(cc,sDif)
	}
	return ms.ToString()
}
;	End:__PadHelper() ;}
;{ 	_resetPtr
	; set the internal field m_ptr to the current memory address of the string value of the instance
	_ResetPtr() {
		ptrOld := this.m_ptr
		; sometimes ObjGetAddress(this, "m_value") will return ""
		; this is the case if m_value is a number and not a string
		; append "" to m_value and try again
		; this should work but if it does not then _GetMStr() will throw an error when trying to create a memory string from address
		if (ptrOld = "")
		{
			this.m_value := this.m_value . ""
		}
		this.m_ptr := ObjGetAddress(this, "m_value")
		if (this.m_ptr = "")
		{
			if (this.m_length = 0)
			{
				; all null "" value in AutoHotkey have the same memory address
				; ObjGetAddress(this, "m_value") will return "" when m_value = ""
				; for this reason will assign default null memory address so MfMemoryString has something to read if needed
				; as soon as the MfString.Value is changed in any way this method will be called again and will result in a new
				; memory string being assigned to this.m_ptr
				ptrOld := ""
				this.m_ptr := &ptrOld
				this.m_ptrChanged := true
				return
			}
			else
			{
				; we should never end up here but throw an error so we are notified that something critical happened
				ex := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_Error", "Critical memory error in MfString Class"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			
		}

		if (ptrOld != this.m_ptr)
		{
			this.m_ptrChanged := true
		}
		Else
		{
			this.m_ptrChanged := false
		}
		
	}
; 	End:_resetPtr ;}
;{	ResetLength()
	_ResetLength() {
		this.m_length := StrLen(this.m_value)
	}
; End:_ResetLength() ;}
;{	String2Hex(x)
	; Convert a string to hex digits
	String2Hex(x, hypenate=true) {                             
		mStr := MfMemoryString.FromAny(x)
		lst := mStr.ToByteList()
		mStr := ""
		hex := lst.ToString(,,,hypenate = true?3:2)
		Return hex
	}

	_GetCRC32(x)
	{
	   L := StrLen(x)>>1          ; length in bytes
	   StringTrimLeft L, L, 2     ; remove leading 0x
	   L = 0000000%L%
	   StringRight L, L, 8        ; 8 hex digits
	   x = %x%%L%                 ; standard pad
	   R =  0xFFFFFFFF            ; initial register value
	   Loop Parse, x
	   {
		  y := "0x" A_LoopField   ; one hex digit at a time
		  Loop 4
		  {
			 R := (R << 1) ^ ( (y << (A_Index+28)) & 0x100000000)
			 IfGreater R,0xFFFFFFFF
				R := R ^ 0x104C11DB7
		  }
	   }
	   Return ~R                  ; ones complement is the CRC
	}
; End:String2Hex(x) ;}
;{	TrimHelperA()
/*
	Method: _TrimHelperA(trimType)
		_TrimHelperA() Trims this.Value whitespaces based on trimType
	Parameters:
		trimType - can be 0 or 1
	Remarks:
		some remaarks here
	Returns:
		Returns Trimed string with white spaces removed from start and end of string
*/
	_TrimHelperA(trimType) {
		rao := this.ReturnAsObject ; capture state
		this.ReturnAsObject := true ; set string instance to work with objects
		
		iLen := this.Length - 1
		intVar := 0
		if (trimType != 1)
		{
			intVar := 0
			while (intVar < this.Length && MfChar.IsWhiteSpace(this.Index[intVar]))
			{
				intVar++
			}
		}
		if (trimType != 0)
		{
			iLen := this.Length - 1
			while (iLen >= intVar && MfChar.IsWhiteSpace(this.Index[iLen]))
			{
				iLen--
			}
		}
		this.ReturnAsObject := rao ; set Return as objcet back to original
		
		return this._CreateTrimmedString(intVar, iLen)
	}
; End:TrimHelperA() ;}
;{	TrimHelperB()
/*
	Method: _TrimHelperB(trimChars, trimType)
		_TrimHelperB() Trims values specified in trimChars from the start and the end of this.Value
	Parameters:
		trimChars - String can be String Object or var. Contains the chars to trim with.
		trimType - Can be 0 or 1
	Remarks:
		Used by Trim()
	Returns:
		Returns Trimed string with trimChars values removed from start and end of string
*/
	_TrimHelperB(trimChars, trimType) {
		rao := this.ReturnAsObject ; capture state
		this.ReturnAsObject := true ; set string instance to work with objects
		
		tChars := new MfString(trimChars, true)
		i := this.m_Length - 1
		j := 0
		if (trimType != 1)
		{
			j := 0
			loop, % this.m_Length -1
			{
				objC := this.Index[j]
				k := 0
				while ((k < tChars.Length) && (!tChars.Index[k].Equals(objC)))
				{
					k++
				}
				if (k = tChars.Length) {
					break
				}
				j++
			}
		}
		if (trimType != 0)
		{
			i := this.m_Length -1
			while ( i >= j)
			{
				ch := this.Index[i]
				k := 0
				while ((k < tChars.Length) && (!tChars.Index[k].Equals(ch)))
				{
					k++
				}
				if (k = tChars.Length) {
					break
				}
				i--
			}
		}
		this.ReturnAsObject := rao ; set Return as objcet back to original
		return this._CreateTrimmedString(j, i)
	}
; End:TrimHelperB() ;}
;{ 	_TrimHelperC()
/*
	Method: _TrimHelperC(trimChars, trimType)
		_TrimHelperC() Trims values specified in trimChars from the start and the end of this.Value
	Parameters:
		trimChars - MfGenericList of MfChar
		trimType - Can be 0 or 1
	Remarks:
		Used by Trim()
	Returns:
		Returns Trimed string with trimChars values removed from start and end of string
*/	
	_TrimHelperC(trimChars, trimType) {
		rao := this.ReturnAsObject ; capture state
		this.ReturnAsObject := true ; set string instance to work with objects
		
		i := this.m_Length - 1
		j := 0
		if (trimType != 1)
		{
			j := 0
			loop, % this.m_Length -1
			{
				objC := this.Index[j]
				k := 0
				while ((k < trimChars.Count) && (!trimChars.Item[k].Equals(objC)))
				{
					k++
				}
				if (k = trimChars.Count) {
					break
				}
				j++
			}
		}
		if (trimType != 0)
		{
			i := this.m_Length -1
			while ( i >= j)
			{
				ch := this.Index[i]
				k := 0
				while ((k < trimChars.Count) && (!trimChars.Item[k].Equals(ch)))
				{
					k++
				}
				if (k = trimChars.Count) {
					break
				}
				i--
			}
		}
		this.ReturnAsObject := rao ; set Return as objcet back to original
		return this._CreateTrimmedString(j, i)
	}
; 	End:_TrimHelperC() ;}
; return MfString intance if ReturnAsObject is true otherwise var containing string
	_ReturnString(obj) {
		if (MfObject.IsObjInstance(obj, MfString)) {
			if (obj.ReturnAsObject) {
				return obj
			} else {
				return obj.Value
			}
		}
		retval := this.ReturnAsObject? new MfString(obj,true):obj
		return retval
	}
; End:Internal Methods ;}
;{ Properties
;{	IgnoreCase
/*
		Property: IgnoreCase [get/set]
			Gets or sets if the [MfString](MfString.html) instance should Ignorecase or not.  
		Value:
			Sets the value of the derived MfEnum class
		Remarks:
			IgnoreCase is not affected by the state of [ReturnAsObject](MfString.ReturnAsObject.html) and 
			always returns a var containing a boolean.
*/
	IgnoreCase[]
	{
		get {
			return this.m_IgnoreCase
		}
		set {
			_val := Null
			try
			{
				_val := MfBool.GetValue(value)
				this.m_IgnoreCase := _val
			} catch e {
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToBoolean"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			return this.m_IgnoreCase
		}
	}
;	End:IgnoreCase ;}
;{	Length
/*
		Property: Length [get]
			Gets the length of the [MfString.value](MfString.value.html) as a var containg an Integer.
		Remarks:
			Length is not affected by the state of [ReturnAsObject](MfString.ReturnAsObject.html) and 
			always returns a var containing an Integer.
			> str := new MfString("Hello World") ; Create a new instance of the String Class
			> MsgBox % str.Length ; Displays Messsage box with containgin 11
*/
	Length[]
	{
		get {
			return this.m_length
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:Length ;}
;{	Value
/*
		Property: Value [get/set]
			Gets or sets the value associated with the this instance of [MfString](MfString.html)
		Value:
			Sets the value of the [MfString](MfString.html) instance.
		Remarks:
			Value is not affected by the state of [ReturnAsObject](MfString.ReturnAsObject.html) and 
			always returns a var.
			> str := new MfString("Hello World") ; Create a new instance of the MfString Class
			> MsgBox % str.Value ; Displays Messsage box with containgin Hello World
			> str.Value := "Cool Code" ; Sets the value of MfString Class instance str
			> MsgBox % str.Value ; Displays Messsage box with containging Cool Code
*/
	Value[]
	{
		get {
			return base.Value
			;return base.Value()
		}
		set {
			this.VerifyReadOnly(this, A_LineFile, A_LineNumber, A_ThisFunc)
			try {
				_val := MfString.GetValue(value)
				this.m_length := StrLen(_val)
				base.Value := _val
				this._ResetPtr() ; set the memory address of the string value
				return base.Value
			} catch e {
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToString"), e)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
	}
;	End:Value ;}
; End:Properties;}
}
/*
	End of class
*/
; End:MfString Class ;}
