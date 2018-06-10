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

;{ Class MfNumberFormatInfo
;{ Class Comments
/*!
	Class: MfNumberFormatInfo
		Defines how numeric values are formatted and displayed.	
	Inherits: MfNumberFormatInfoBase
*/
; End:Class Comments ;}
class MfNumberFormatInfo extends MfNumberFormatInfoBase
{

;{ internal members
	ansiCurrencySymbol			:= Null			; string
	m_currencyDecimalDigits		:= 2			; int
	m_CurrencyDecimalSeparator	:= "."			; string
	m_CurrencyGroupSeparator	:= ","			; string
	m_CurrencyGroupSizes		:= [3]			; array
	m_CurrencyNegativePattern	:= 0			; int
	m_CurrencyPositivePattern	:= 0			; int
	m_CurrencySymbol			:= "$"			; string
	static _currentInfo			:= Null			; MfNumberFormatInfo
	m_DigitSubstitution			:= 1			; int
	static InvalidNumberStyles := new MfNumberStyles(MfNumberStyles.Instance.AllowLeadingWhite
								, MfNumberStyles.Instance.AllowTrailingWhite, MfNumberStyles.Instance.AllowLeadingSign
								, MfNumberStyles.Instance.AllowTrailingSign, MfNumberStyles.Instance.AllowParentheses
								, MfNumberStyles.Instance.AllowDecimalPoint, MfNumberStyles.Instance.AllowThousands
								, MfNumberStyles.Instance.AllowExponent, MfNumberStyles.Instance.AllowCurrencySymbol
								, MfNumberStyles.Instance.AllowHexSpecifier)
	static _invariantInfo		:= Null			; MfNumberFormatInfo
	m_IsReadOnly				:= false		; MfBool
	m_dataItem					:= 0			; int
	m_isInvariant				:= false		; MfBool
	m_useUserOverride			:= false		; MfBool
	m_NaNSymbol					:= "NaN"		; string
	m_nativeDigits				:= ["0","1","2","3","4","5","6","7","8","9"]
	negativeInfinitySymbol 		:= "-Infinity"	; string
	negativeSign				:= "-"			; string
	numberDecimalDigits			:= 2			; int
	numberDecimalSeparator		:= "."			; string
	numberGroupSeparator		:= ","			; string
	numberGroupSizes			:= [3]			; int array
	numberNegativePattern		:= 1			; int
	percentDecimalDigits		:= 2			; int
	percentDecimalSeparator 	:= "."			; string
	percentGroupSeparator		:= ","			; string
	percentGroupSizes			:= [3]			; int array
	percentNegativePattern		:= 0			; int
	percentPositivePattern		:= 0			; int
	percentSymbol				:= "%"			; string
	perMilleSymbol				:= "�"			; string
	positiveInfinitySymbol		:= "Infinity"	; string
	positiveSign				:= "+"			; string
	validForParseAsCurrency 	:= true			; MfBool
	validForParseAsNumber		:= true			; MfBool

; End:internal members ;}
	;{ Constructor: ()
/*
	Method: Constructor()
		Constructor for class MfNumberFormatInfo Class

	OutputVar := new MfNumberFormatInfo()
	
	Thorws:
		Throws MfNotSupportedException if class is extended
	Remarks:
		Sealed Class
*/
	__New() {
		; Throws MfNotSupportedException if MfNumberFormatInfo Sealed class is extended
		if (this.__Class != "MfNumberFormatInfo") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfNumberFormatInfo"))
		}
		base.__New()
		this.m_isInherited := false
	}
; End:Constructor: () ;}
;{ Method
;{	CheckGroupSize()
	CheckGroupSize(propName, groupSize) {
		index := 0
		iCount := groupSize.Count
		Loop, %iCount%
		{
			if (groupSize.Item[index].value < 1) {
				if ((index = iCount) && (groupSize.Item[index].value = 0)) {
					return
				}
				throw new MfArgumentException(MfEnvironment.GetResourceString("Argument_InvalidGroupSize"), propName)
			} else {
				if (groupSize[index].Value > 9)
				{
					throw new MfArgumentException(MfEnvironment.GetResourceString("Argument_InvalidGroupSize"), propName)
				}
			}
			index++
		}
	}

;	End:CheckGroupSize() ;}
;{	ReadOnly()
/*
	Method: ReadOnly()

	OutputVar := instance.ReadOnly()

	ReadOnly(nfi)
		Returns a read-only MfNumberFormatInfo wrapper.
	Parameters:
		nfi
			The MfNumberFormatInfo to wrap.
	Returns:
		Returns a read-only MfNumberFormatInfo wrapper around nfi.
	Throws:
		Throws MfArgumentNullException if nfi is null.
		Throws MfArgumentException if nfi is not MfNumberFormatInfo instance.
*/
	ReadOnly(nfi) {
		if (MfNull.IsNull(nfi))
		{
			ex := new MfArgumentNullException("nfi")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (!MfObject.IsObjInstance(nfi, "MfNumberFormatInfo")) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType", "nfi", "MfNumberFormatInfo"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (nfi.IsReadOnly)
		{
			return nfi
		}
		_numberFormatInfo := nfi.MemberwiseClone()
		_numberFormatInfo.m_IsReadOnly := true
		return _numberFormatInfo
	}
;	End:ReadOnly() ;}
; End:Method ;}
;{ Internal Methods
;{	VerifyDigitSubstitution()
	VerifyDigitSubstitution(digitSub, propertyName)
	{
		if ((digitSub.Value = MfDigitShapes.Instance.Context.Value)
			|| (digitSub.Value = MfDigitShapes.Instance.None.Value)
			|| (digitSub.Value = MfDigitShapes.Instance.NativeNational.Value))
		{
			return
		}
		throw new MfArgumentException(MfEnvironment.GetResourceString("Argument_InvalidDigitSubstitution"), propertyName)
	}
;	End:VerifyDigitSubstitution() ;}
;{	VerifyNativeDigits()
	VerifyNativeDigits(nativeDig, propertyName)
	{
		; http://en.wikipedia.org/wiki/DBCS
		; http://msdn.microsoft.com/en-us/library/613dxh46%28v=vs.90%29.aspx
		; mk:@MSITStore:C:\Program%20Files\AutoHotkey\AutoHotkey.chm::/docs/Scripts.htm#cp
		; http://l.autohotkey.net/docs/commands/StrPutGet.htm
		
		if (MfNull.IsNull(nativeDig)) {
			ex := new MfArgumentNullException(propertyName,MfEnvironment.Instance.GetResourceString("ArgumentNull_Obj"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if ((!MfObject.IsObjInstance(nativeDig,MfGenericList)) || (!nativeDig.ListType.Equals(MfString.GetType()))) {
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_GenericListType","MfString"),propertyName)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (nativeDig.Count != 10)
		{
			throw new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_InvalidNativeDigitCount"), propertyName)
		}
		i := 0
		iCount := nativeDig.Count
		Loop, %iCount%
		{
			nd := nativeDig.Item[i] 
			if (MfNull.IsNullOrEmpty(nd)) {
				throw new MfArgumentNullException(propertyName, MfEnvironment.GetResourceString("ArgumentNull_ListValue"))
			}
			
			i++
		}
		
		i := 0
		while, i < nativeDig.Length
		{
			i++
			if (nativeDig[i] == null)
			{
				throw new ArgumentNullException(propertyName, MfEnvironment.GetResourceString("ArgumentNull_ArrayValue"))
			}
			if (nativeDig[i].Length != 1)
			{
				if (nativeDig[i].Length != 2)
				{
					throw new ArgumentException(MfEnvironment.GetResourceString("Argument_InvalidNativeDigitValue"), propertyName)
				}
				if (!MfChar.IsSurrogatePair(nativeDig[i][0], nativeDig[i][1]))
				{
					throw new ArgumentException(MfEnvironment.GetResourceString("Argument_InvalidNativeDigitValue"), propertyName)
				}
			}
			if ((MfCharUnicodeInfo.GetDecimalDigitValue(nativeDig[i], 0) != i) 
				&& (MfCharUnicodeInfo.GetUnicodeCategory(nativeDig[i], 0) != MfUnicodeCategory.Instance.PrivateUse.Value))
			{
				throw new ArgumentException(MfEnvironment.GetResourceString("Argument_InvalidNativeDigitValue"), propertyName)
			}
			
		}
	}
;{ VerifyNativeDigits()
; End:Internal Methods ;}
;{ Properties
;{		CurrencyDecimalDigits
/*
	Property: CurrencyDecimalDigits [get\set]
		Gets or sets the number of decimal places to use in currency values.
	Value:
		MfInteger instance or var containing integer.
	Gets:
		Gets the number as an Integer var of decimal places to use in currency values. The default for is 2.
	Sets:
		Sets the number of decimal places to use in currency values.
	Throws:
		Throws MfArgumentOutOfRangeException if the property is being set to a value that is less than 0 or greater than 99.
		Throws MfInvalidOperationException if the property is being set and the MfNumberFormatInfo is read-only.
*/
	CurrencyDecimalDigits[]
	{
		get {
			return this.m_currencyDecimalDigits
		}
		set {
			_value := MfInteger.GetValue(value)
			if ((_value < 0) || (_value > 99)) {
				ex := new MfArgumentOutOfRangeException("CurrencyDecimalDigits"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Range","0","99"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.VerifyWritable()
			this.m_CurrencyDecimalDigits := _value
			return this.m_CurrencyDecimalDigits
		}
	}
;	End:CurrencyDecimalDigits ;}
;{		CurrencyDecimalSeparator
/*
	Property: CurrencyDecimalSeparator [get\set]
		Gets or sets the string to use as the decimal separator in currency values.
	Value:
		MfString instance or var containing string.
	Gets:
		Gets a string var to use as the decimal separator in currency values. The default for is ".".
	Sets:
		Sets the string to use as the decimal separator in currency values.
	Throws:
		Throws MfInvalidOperationException if the property is being set and the MfNumberFormatInfo is read-only.
		Throws MfArgumentNullException if the property is being set to null.
		Throws MfArgumentException The property is being set to an empty string.
*/
	CurrencyDecimalSeparator[]
	{
		get {
			return this.m_CurrencyDecimalSeparator
		}
		set {
			this.VerifyWritable()
			_value := MfString.GetValue(value)
			MfNumberFormatInfo.VerifyDecimalSeparator(_value, "CurrencyDecimalSeparator")
			this.m_CurrencyDecimalSeparator := _value
			return this.m_CurrencyDecimalSeparator
		}
	}
;	End:CurrencyDecimalSeparator ;}
;{		CurrencyGroupSeparator
/*
	Property: CurrencyGroupSeparator [get\set]
		Gets or sets the string that separates groups of digits to the left of the decimal in currency values.
	Value:
		MfString instance or var containing string.
	Gets:
		Gets the string var that separates groups of digits to the left of the decimal in currency values. The default is ",".
	Sets:
		Sets the string that separates groups of digits to the left of the decimal in currency values.
	Throws:
		Throws MfInvalidOperationException if the property is being set and the MfNumberFormatInfo is read-only.
		Throws MfArgumentNullException if the property is being set to null.
*/
	CurrencyGroupSeparator[]
	{
		get {
			return this.m_CurrencyGroupSeparator
		}
		set {
			this.VerifyWritable()
			_value := MfString.GetValue(value)
			MfNumberFormatInfo.VerifyGroupSeparator(_value, "CurrencyGroupSeparator")
			this.m_CurrencyGroupSeparator := _value
			return this.m_CurrencyGroupSeparator
		}
	}
;	End:CurrencyGroupSeparator ;}
;{		CurrencyGroupSizes
/*
	Property: CurrencyGroupSizes [get\set]
		Gets or sets the number of digits in each group to the left of the decimal in currency values.
	Value:
		MfGenericList of MfInteger
	Gets:
		Gets the number of digits in each group to the left of the decimal in currency values as MfGenericList of MfInteger.
		The default for MfNumberFormatInfo.InvariantInfo is a MfGenericList of MfInteger with only one element, which is set to a value of 3.
	Sets:
		Sets the number of digits in each group to the left of the decimal in currency values.
	Throws:
		Throws MfInvalidOperationException if the property is being set and the MfNumberFormatInfo is read-only.
		Throws MfArgumentNullException if the property is being set to null.
		Throws MfArgumentException if the property is being set and the MfGenericList of MfInteger contains an
		entry that is less than 0 or greater than 9.-or- The property is being set and the MfGenericList of
		MfInteger contains an entry, other than the last entry, that is set to 0.-or- value is not a MfGenericList of MfInteger.
*/
	CurrencyGroupSizes[]
	{
		get {
			intList := new MfGenericList(MfInteger)
			for k, v in this.m_CurrencyGroupSizes
			{
				intList.Add(new MfInteger(v))
			}
			return intList
		}
		set {
			if (MfNull.IsNull(value)) {
				ex := new MfArgumentNullException("value",MfEnvironment.Instance.GetResourceString("ArgumentNull_Obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if ((!MfObject.IsObjInstance(value,MfGenericList)) || (!value.ListType.Equals(MfInteger.GetType()))) {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_GenericListType","MfInteger"),"value")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.VerifyWritable()
			MfNumberFormatInfo.CheckGroupSize("CurrencyGroupSizes", value)
			this.m_CurrencyGroupSizes := []
			index := 0
			iCount := value.Count
			Loop, %iCount%
			{
				_index := index + 1 ; set for one base array
				this.m_CurrencyGroupSizes[_index] := value.Item[index].Value
				index++
			}
		}
	}
;	End:CurrencyGroupSizes ;}
;{		CurrentInfo
/*
	Property: CurrentInfo [get]
		Overrides MfNumberFormatInfoBase.CurrentInfo
	Value:
		Instance of MfNumberFormatInfo
	Gets:
		Gets a read-only MfNumberFormatInfo that formats values based on the current culture.
*/
	CurrentInfo[]
	{
		get
		{
			if (MfNull.IsNull(MfNumberFormatInfo._currentInfo))
			{
				MfNumberFormatInfo._currentInfo := new MfNumberFormatInfo()
			}
			return MfNumberFormatInfo._currentInfo
		}
		set
		{
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;		End:CurrentInfo ;}
;{		CurrencyNegativePattern
/*
	Property: CurrencyNegativePattern [get\set]
		Gets or sets the format pattern for negative currency values.
	Value:
		MfInteger instance or var containing integer.
	Gets:
		Gets the format pattern for negative currency values as an integer var.
		The default for InvariantInfo is 0, which represents "($n)", where "$" is the CurrencySymbol and n is a number.
	Sets:
		Sets the format pattern for negative currency values.
	Throws:
		Throws MfArgumentOutOfRangeException if the property is being set to a value that is less than 0 or greater than 15.
		Throws MfInvalidOperationException if the property is being set and the MfNumberFormatInfo is read-only.
*/
	CurrencyNegativePattern[]
	{
		get {
			return this.m_CurrencyNegativePattern
		}
		set {
			_value := MfInteger.GetValue(value)
			if ((_value < 0) || (_value > 15)) {
				ex := new MfArgumentOutOfRangeException("CurrencyNegativePattern"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Range","0","15"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.VerifyWritable()
			this.m_CurrencyNegativePattern := _value
			return this.m_CurrencyNegativePattern
		}
	}
;	End:CurrencyNegativePattern ;}
;{		CurrencyPositivePattern
/*
	Property: CurrencyPositivePattern [get\set]
		Gets or sets the format pattern for positive currency values.
	Value:
		MfInteger instance or var containing integer.
	Gets:
		Gets the format pattern for positive currency values as an integer var.
		The default for InvariantInfo is 0, which represents "$n", where "$" is the CurrencySymbol and n is a number.
	Sets:
		Sets the format pattern for positive currency values.
	Throws:
		Throws MfArgumentOutOfRangeException if the property is being set to a value that is less than 0 or greater than 3.
		Throws MfInvalidOperationException if the property is being set and the MfNumberFormatInfo is read-only.
*/
	CurrencyPositivePattern[]
	{
		get {
			return this.m_CurrencyPositivePattern
		}
		set {
			_value := MfInteger.GetValue(value)
			if ((_value < 0) || (_value > 3)) {
				ex := new MfArgumentOutOfRangeException("CurrencyPositivePattern"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Range","0","3"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.VerifyWritable()
			this.m_CurrencyPositivePattern := _value
			return this.m_CurrencyPositivePattern
		}
	}
;	End:CurrencyPositivePattern ;}
;{		CurrencySymbol
/*
	Property: CurrencySymbol [get\set]
		Gets or sets the string to use as the currency symbol.
	Value:
		MfString instance or var containing string.
	Gets:
		Gets the  string var to use as the currency symbol. The default for InvariantInfo is "$".
	Sets:
		Sets the string to use as the currency symbol.
	Throws:
		Throws MfInvalidOperationException if the property is being set and the MfNumberFormatInfo is read-only.
		Throws MfArgumentNullException if the property is being set to null.
*/
	CurrencySymbol[]
	{
		get {
			return this.m_CurrencySymbol
		}
		set {
			if (MfString.IsNullOrEmpty(value)) {
				ex := new MfArgumentNullException("CurrencySymbol", MfEnvironment.Instance.GetResourceString("ArgumentNull_String"))
			}
			this.VerifyWritable()
			_value := MfString.GetValue(value)
			this.m_CurrencySymbol := _value
			return this.m_CurrencySymbol
		}
	}
;	End:CurrencySymbol ;}
;{		DigitSubstitution()
/*
	Property: DigitSubstitution [get\set]
		Gets or sets a value that specifies how the graphical user interface displays the shape of a digit.
	Value:
		MfDigitShapes
	Gets:
		Gets one of the enumeration values that specifies the culture-specific digit shape as in instance of MfDigitShapes.
	Sets:
		Sets a value that specifies how the graphical user interface displays the shape of a digit.
	Throws:
		Throws MfArgumentException if value is not a valid MfDigitShapes instance.
		Throws MfArgumentNullException if the property is being set to null.
		Throws MfInvalidOperationException if the property is being set and the MfNumberFormatInfo is read-only.
*/
	DigitSubstitution[]
	{
		get {
			return new MfDigitShapes(this.m_DigitSubstitution)
		}
		set {
			if (MfNull.IsNull(value)) {
				ex := new MfArgumentNullException("value",MfEnvironment.Instance.GetResourceString("ArgumentNull_Obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_value := 0
			try {
				_value := MfEnum.GetValue(value,"MfDigitShapes")
			} catch e {
				err := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_IncorrectObjType"
					,"value","MfDigitShapes"),"value", e)
				err.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw err
			}
			this.VerifyWritable()
			MfNumberFormatInfo.VerifyDigitSubstitution(value, "DigitSubstitution")
			this.m_DigitSubstitution := _value
			return this.m_DigitSubstitution
		}
	}
;		End:DigitSubstitution() ;}
;{		InvariantInfo
/*
	Property: InvariantInfo [get]
		Gets the default read-only MfNumberFormatInfo that is culture-independent (invariant).
		Overrides MfNumberFormatInfoBase.InvariantInfo
	Value:
		MfNumberFormatInfo instance.
	Gets:
		Gets the default read-only MfNumberFormatInfo that is culture-independent (invariant).
*/
	InvariantInfo[]
	{
		get
		{
			if (MfNull.IsNull(MfNumberFormatInfo._invariantInfo))
			{
				nfi := new MfNumberFormatInfo()
				nfi.m_isInvariant := true
				MfNumberFormatInfo._invariantInfo := MfNumberFormatInfo.ReadOnly(nfi)
			}
			return MfNumberFormatInfo._invariantInfo
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;		End:InvariantInfo ;}
;{		IsReadOnly
/*
	Property: IsReadOnly [get]
		Gets a value indicating whether the MfNumberFormatInfo is read-only.
	Value:
		var boolean.
	Gets:
		Gets true if the MfNumberFormatInfo is read-only; Otherwise, false.
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
;		End:IsReadOnly ;}
;{		NaNSymbol
/*
	Property: NaNSymbol [get\set]
		Gets or sets the string that represents the IEEE NaN (not a number) value.
	Value:
		MfString instance or var containing string.
	Gets:
		Gets the string var that represents the IEEE NaN (not a number) value.
		The default for InvariantInfo is "NaN".
	Sets:
		Sets the string that represents the IEEE NaN (not a number) value.
	Throws:
		Throws MfInvalidOperationException if the property is being set and the MfNumberFormatInfo is read-only.
		Throws MfArgumentNullException if the property is being set to null.
*/
	NaNSymbol[]
	{
		get {
			return this.m_NaNSymbol
		}
		set  {
			if (MfString.IsNullOrEmpty(value)) {
				ex := new ArgumentNullException("CurrencySymbol", MfEnvironment.Instance.GetResourceString("ArgumentNull_String"))
			}
			this.VerifyWritable()
			_value := MfString.GetValue(value)
			this.m_NaNSymbol := _value
			return this.m_NaNSymbol
		}
	}
;		End:NaNSymbol ;}
;{ 	NativeDigits
	NativeDigits[]
	{
		get {
			return this.m_NativeDigits
		}
		set {
			if (MfNull.IsNull(value)) {
				ex := new MfArgumentNullException("value",MfEnvironment.Instance.GetResourceString("ArgumentNull_Obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if ((!MfObject.IsObjInstance(value,MfGenericList)) || (!value.ListType.Equals(MfString.GetType()))) {
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_GenericListType","MfString"),"value")
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.VerifyWritable()
			MfNumberFormatInfo.CheckGroupSize("CurrencyGroupSizes", value)
			this.m_CurrencyGroupSizes := []
			index := 0
			iCount := value.Count
			Loop, %iCount%
			{
				this.m_CurrencyGroupSizes.Insert(value.Item[index].Value)
				index++
			}
			this.m_NativeDigits := value
			return this.m_NativeDigits
		}
	}
; 	End:NativeDigits ;}
; End:Properties ;}	
}
/*!
	End of class
*/
; End:Class MfNumberFormatInfo ;}