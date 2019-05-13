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
	m_CurrencyGroupSizes		:= ""			; array
	m_CurrencyNegativePattern	:= 0			; int
	m_CurrencyPositivePattern	:= 0			; int
	m_CurrencySymbol			:= "$"			; string
	static _currentInfo			:= Null			; MfNumberFormatInfo
	m_DigitSubstitution			:= 1			; int
	; static InvalidNumberStyles := new MfNumberStyles(MfNumberStyles.Instance.AllowLeadingWhite
	; 							, MfNumberStyles.Instance.AllowTrailingWhite, MfNumberStyles.Instance.AllowLeadingSign
	; 							, MfNumberStyles.Instance.AllowTrailingSign, MfNumberStyles.Instance.AllowParentheses
	; 							, MfNumberStyles.Instance.AllowDecimalPoint, MfNumberStyles.Instance.AllowThousands
	; 							, MfNumberStyles.Instance.AllowExponent, MfNumberStyles.Instance.AllowCurrencySymbol
	; 							, MfNumberStyles.Instance.AllowHexSpecifier)
	static InvalidNumberStyles := new MfNumberStyles(1023)
	static _invariantInfo		:= Null			; MfNumberFormatInfo
	m_IsReadOnly				:= false		; MfBool
	m_dataItem					:= 0			; int
	m_isInvariant				:= false		; MfBool
	m_useUserOverride			:= false		; MfBool
	m_NaNSymbol					:= "NaN"		; string
	m_nativeDigits				:= "" ;["0","1","2","3","4","5","6","7","8","9"] int list MfListVar
	m_NegativeInfinitySymbol	:= "-Infinity"	; string
	m_NegativeSign				:= "-"			; string
	m_NumberDecimalDigits		:= 2			; int
	m_NumberDecimalSeparator	:= "."			; string
	m_NumberGroupSeparator		:= ","			; string
	m_NumberGroupSizes			:= ""			; int list MfListVar
	m_NumberNegativePattern		:= 1			; int
	m_PercentDecimalDigits		:= 2			; int
	m_PercentDecimalSeparator 	:= "."			; string
	m_PercentGroupSeparator		:= ","			; string
	m_PercentGroupSizes			:= ""			; int list MfListVar
	m_PercentNegativePattern	:= 0			; int
	m_PercentPositivePattern	:= 0			; int
	m_PercentSymbol				:= "%"			; string
	m_PerMilleSymbol			:= ""			; string
	m_PositiveInfinitySymbol	:= "Infinity"	; string
	m_PositiveSign				:= "+"			; string
	validForParseAsCurrency 	:= true			; MfBool
	validForParseAsNumber		:= true			; MfBool
	static m_instance			:= ""
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
		this.m_NumberGroupSizes := new MfListVar()
		this.m_NumberGroupSizes._Add(3)

		this.m_PercentGroupSizes := new MfListVar()
		this.m_PercentGroupSizes._Add(3)

		this.m_CurrencyGroupSizes := new MfListVar()
		this.m_CurrencyGroupSizes._Add(3)

		this.m_nativeDigits := MfListVar.FromString("0123456789")
		

		if (A_IsUnicode)
		{
			this.m_PerMilleSymbol := Chr(0x2030) ; ‰ is Mile per char
		}
		else
		{
			; ‰ is Mile per char and is 137 in codepage 1252
			; http://www.i18nqa.com/debug/table-iso8859-1-vs-windows-1252.html
			var := ""
			VarSetCapacity(var, 2, 0)
			NumPut(137, var)
			this.m_PerMilleSymbol := StrGet(&var, , "cp1252")
			VarSetCapacity(var, 0)
		}
	}
; End:Constructor: () ;}
;{ Method
;{	CheckGroupSize()
	; groupSizeis instance of MfListVar
	; Every element in the groupSize array should be between 1 and 9
	; excpet the last element could be zero.
	CheckGroupSize(propName, groupSize) {
		if (MfString.IsNullOrEmpty(propName))
		{
			ex := new MfArgumentNullException("propName")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(groupSize))
		{
			ex := new MfArgumentNullException("groupSize")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		for i , v in groupSize
		{
			if (!Mfunc.IsInteger(v))
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_InvalidElement_IntOnly"), propName)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (v < 1)
			{
				if (i = groupSize.m_Count - 1 && v = 0)
				{
					return
				}
				throw new MfArgumentException(MfEnvironment.GetResourceString("Argument_InvalidGroupSize"), propName)
			}
			else if (v > 9)
			{
				throw new MfArgumentException(MfEnvironment.GetResourceString("Argument_InvalidGroupSize"), propName)
			}
		}
	}

;	End:CheckGroupSize() ;}
;{	GetFormat()	- overrides MfFormatProvider
/*
	Method: GetFormat()
	
	OutputVar := MfFormatProvider.GetFormat(formatType)
	
	GetFormat()
		Returns an object that provides formatting services for the specified type.
	Parameters
		formatType
			An object that specifies the type of format object to return.
	Returns
		Returns an instance of the object specified by formatType, if the MfFormatProvider implementation can supply that type of object; otherwise, null.
*/
	GetFormat(formatType) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		If(MfNull.IsNull(formatType))
		{
			return null
		}
		if (!MfType.Equals(this.GetType(),formatType))
		{
			return null
		}
		return this
	}
;	End:GetFormat() ;}
;{ 	GetInstance
	GetInstance(formatProvider:="") {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		; formatProvider is for future expansion at this point
		if (!MfNull.IsNull(formatProvider))
		{
			if (MfObject.IsObjInstance(formatProvider, MfNumberFormatInfo))
			{
				return formatProvider
			}
		}
		if (MfNumberFormatInfo.m_instance = "")
		{
			MfNumberFormatInfo.m_instance := new MfNumberFormatInfo()
		}
		return MfNumberFormatInfo.m_instance
	}
; 	End:GetInstance ;}
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
	ValidateParseStyleInteger(style) {
		if (MfObject.IsObjInstance(style, MfNumberStyles))
		{
			i := style.Value
		}
		else
		{
			i := style
		}
		; AllowLeadingSign, AllowTrailingSign, AllowParentheses, AllowDecimalPoint, AllowThousands, AllowExponent, AllowCurrencySymbol, HexNumber = 1023 when or'ed together
		; -1024 is the two's complement of 1023
		if ((i & -1024) != 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_InvalidNumberStyles"), "style")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		;if ((style & AllowHexSpecifier) != None && (style & ~(AllowLeadingWhite | AllowTrailingWhite | AllowHexSpecifier)) != None)
		if ((i & 512) != 0 && (i & -516) != 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_InvalidHexStyle"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
	ValidateParseStyleFloatingPoint(style) {
		if (MfObject.IsObjInstance(style, MfNumberStyles))
		{
			i := style.Value
		}
		else
		{
			i := style
		}
		; AllowLeadingSign, AllowTrailingSign, AllowParentheses, AllowDecimalPoint, AllowThousands, AllowExponent, AllowCurrencySymbol, HexNumber = 1023 when or'ed together
		; -1024 is the two's complement of 1023
		if ((i & -1024) != 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_InvalidNumberStyles"), "style")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		;if ((style & AllowHexSpecifier) != None && (style & ~(AllowLeadingWhite | AllowTrailingWhite | AllowHexSpecifier)) != None)
		if ((i & 512) != 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_HexStyleNotSupported"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
;{	VerifyDigitSubstitution()
	VerifyDigitSubstitution(digitSub, propertyName)	{
		val := digitSub.Value

		if ((val = 0) || (val = 2) || (val = 3))
		{
			return
		}
		ex := new MfArgumentException(MfEnvironment.GetResourceString("Argument_InvalidDigitSubstitution"), propertyName)
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex

		; MfDigitShapes.Instance.Context.Value = 0
		; MfDigitShapes.Instance.NativeNational.Value = 2
		; MfDigitShapes.Instance.None.Value = 1
	}
;	End:VerifyDigitSubstitution() ;}
;{	VerifyNativeDigits()
	VerifyNativeDigits(nativeDig, propertyName) {
		; http://en.wikipedia.org/wiki/DBCS
		; http://msdn.microsoft.com/en-us/library/613dxh46%28v=vs.90%29.aspx
		; mk:@MSITStore:C:\Program%20Files\AutoHotkey\AutoHotkey.chm::/docs/Scripts.htm#cp
		; http://l.autohotkey.net/docs/commands/StrPutGet.htm
		if (MfNull.IsNull(nativeDig))
		{
			ex := new MfArgumentNullException("nativeDig")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfString.IsNullOrEmpty(propertyName))
		{
			ex := new MfArgumentNullException("propertyName")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (!MfObject.IsObjInstance(nativeDig, MfListBase))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List"), "nativeDig")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
				
		if (nativeDig.Count != 10)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_InvalidNativeDigitCount"), propertyName)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		for i, sVal in nativeDig
		{
			str := new MfString(sVal)
			sLen := str.Length
			if (sLen = 0)
			{
				ex := new MfArgumentNullException(propertyName, MfEnvironment.Instance.GetResourceString("ArgumentNull_ListValue"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (sLen != 1)
			{
				if (sLen != 2 || !A_IsUnicode)
				{
					ex := new MfArgumentException(MfEnvironment.GetResourceString("Argument_InvalidNativeDigitValue"), propertyName)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
				enum := str.GetEnumerator(true) ; get enuerator that returs charcodes
				hc := ""
				lc := ""
				enum.Next(j, hc)
				enum.Next(j, lc)
				enum := ""
				; check and see if both chars make a SurrogatePair
				if (!MfChar._IsSurrogatePairByteHiLoNums(hc,lc))
				{
					ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_InvalidNativeDigitValue"), propertyName)
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			if (MfCharUnicodeInfo.GetDecimalDigitValue(str.Item[0]) != i && MfChar.GetUnicodeCategory(str.Item[0]) != MfUnicodeCategory.Instance.PrivateUse.Value)
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_InvalidNativeDigitValue"), propertyName)
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
		}
	}
	VerifyDecimalSeparator(decSep, propertyName) {
		if (MfString.IsNullOrEmpty(decSep)) {
			ex :=  new MfArgumentNullException(propertyName
			, MfEnvironment.Instance.GetResourceString("ArgumentNull_String"))
		}
	}

	VerifyGroupSeparator(groupSep, propertyName) {
		if (groupSep == "")
		{
			; empty string is allowed
			return
		}
		if (MfNull.IsNull(groupSep))
		{
			ex := new MfArgumentNullException(propertyName
				, MfEnvironment.Instance.GetResourceString("ArgumentNull_String"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
;{ VerifyNativeDigits()
; End:Internal Methods ;}
; Sealed Class Following methods cannot be overriden ; Do Not document for this class
; VerifyIsInstance([ClassName, LineFile, LineNumber, Source])
; VerifyIsNotInstance([MethodName, LineFile, LineNumber, Source])
; Sealed Class Following methods cannot be overriden
; VerifyReadOnly()
;{ MfObject Attribute Overrides - methods not used from MfObject - Do Not document for this class
;{	AddAttribute()
/*
	Method: AddAttribute()
	AddAttribute(attrib)
		Overrides MfObject.AddAttribute Sealed Class will never have attribute
	Parameters:
		attrib
			The object instance derived from MfAttribute to add.
	Throws:
		Throws MfNotSupportedException
*/
	AddAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex		
	}
;	End:AddAttribute() ;}
;{	GetAttribute()
/*
	Method: GetAttribute()

	OutputVar := instance.GetAttribute(index)

	GetAttribute(index)
		Overrides MfObject.GetAttribute Sealed Class will never have attribute
	Parameters:
		index
			the zero-based index. Can be MfInteger or var containing Integer number.
	Throws:
		Throws MfNotSupportedException
*/
	GetAttribute(index) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:GetAttribute() ;}
;	GetAttributes ;}
/*
	Method: GetAttributes()

	OutputVar := instance.GetAttributes()

	GetAttributes()
		Overrides MfObject.GetAttributes Sealed Class will never have attribute
	Throws:
		Throws MfNotSupportedException
*/
	GetAttributes()	{
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:GetAttributes ;}
;{	GetIndexOfAttribute()
/*
	GetIndexOfAttribute(attrib)
		Overrides MfObject.GetIndexOfAttribute. Sealed Class will never have attribute
	Parameters:
		attrib
			The object instance derived from MfAttribute.
	Throws:
		Throws MfNotSupportedException
*/
	GetIndexOfAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:GetIndexOfAttribute() ;}
;{	HasAttribute()
/*
	HasAttribute(attrib)
		Overrides MfObject.HasAttribute. Sealed Class will never have attribute
	Parameters:
		attrib
			The object instance derived from MfAttribute.
	Throws:
		Throws MfNotSupportedException
*/
	HasAttribute(attrib) {
		ex := new MfNotSupportedException()
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
;	End:HasAttribute() ;}
; End:MfObject Attribute Overrides ;}
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
			return this.m_CurrencyGroupSizes.Clone()
		}
		set {
			this.VerifyWritable()
			If (MfNull.IsNull(value))
			{
				ex := new MfArgumentNullException("CurrencyGroupSizes"
					,MfEnvironment.Instance.GetResourceString("ArgumentNull_Obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!MfObject.IsObjInstance(value, MfListBase))
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			If (Value.Count = 0)
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List_Size"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (MfObject.IsObjInstance(value, MfListVar))
			{
				this.m_NumberGroupSizes := value.Clone()
				return
			}
			lst := new MfListVar()
			for i, v in Value
			{
				lst._Add(v)
			}
			MfNumberFormatInfo.CheckGroupSize("CurrencyGroupSizes", lst)
			this.m_CurrencyGroupSizes := lst
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
			this.VerifyWritable()
			_value := MfInteger.GetValue(value)
			if ((_value < 0) || (_value > 15)) {
				ex := new MfArgumentOutOfRangeException("CurrencyNegativePattern"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Range","0","15"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.m_CurrencyNegativePattern := _value
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
			this.VerifyWritable()
			_value := MfInteger.GetValue(value)
			if ((_value < 0) || (_value > 3)) {
				ex := new MfArgumentOutOfRangeException("CurrencyPositivePattern"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Range","0","3"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.m_CurrencyPositivePattern := _value
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
			this.VerifyWritable()
			if (Value == "")
			{
				; can be empty string
				this.m_CurrencySymbol := Value
				return
			}
			if (MfNull.IsNull(Value)) {
				ex := new MfArgumentNullException("CurrencySymbol", MfEnvironment.Instance.GetResourceString("ArgumentNull_String"))
			}
			_value := MfString.GetValue(value)
			this.m_CurrencySymbol := _value
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
			this.VerifyWritable()
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
			MfNumberFormatInfo.VerifyDigitSubstitution(value, "DigitSubstitution")
			this.m_DigitSubstitution := _value
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
			this.VerifyWritable()
			if (Value == "")
			{
				; can be empty string
				this.m_NaNSymbol := Value
				return
			}
			if (MfNull.IsNull(Value)) {
				ex := new ArgumentNullException("NaNSymbol", MfEnvironment.Instance.GetResourceString("ArgumentNull_String"))
			}
			_value := MfString.GetValue(value)
			this.m_NaNSymbol := _value
		}
	}
;		End:NaNSymbol ;}
;{ 	NativeDigits
	NativeDigits[]
	{
		get {
			return this.m_NativeDigits.Clone()
		}
		set {
			this.VerifyWritable()
			If (MfNull.IsNull(value))
			{
				ex := new MfArgumentNullException("NativeDigits"
					,MfEnvironment.Instance.GetResourceString("ArgumentNull_Obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!MfObject.IsObjInstance(value, MfListBase))
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			If (Value.Count = 0)
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List_Size"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (MfObject.IsObjInstance(value, MfListVar))
			{
				this.m_NumberGroupSizes := value.Clone()
				return
			}
			lst := new MfListVar()
			for i, v in Value
			{
				lst._Add(v)
			}
			MfNumberFormatInfo.VerifyNativeDigits("NativeDigits", lst)
			this.m_CurrencyGroupSizes := lst
		}
	}
; 	End:NativeDigits ;}
	;{ NegativeInfinitySymbol
/*!
	Property: NegativeInfinitySymbol [get/set]
		Gets or sets the NegativeInfinitySymbol value associated with the this instance
	Value:
		Var representing the NegativeInfinitySymbol property of the instance
*/
	NegativeInfinitySymbol[]
	{
		get {
			return this.m_NegativeInfinitySymbol
		}
		set {
			this.VerifyWritable()
			if (Value == "")
			{
				; can be empty string
				this.m_NegativeInfinitySymbol := Value
				return
			}
			if (MfNull.IsNull(Value))
			{
				ex := new MfArgumentNullException("NegativeInfinitySymbol"
				, MfEnvironment.Instance.GetResourceString("ArgumentNull_String"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.m_NegativeInfinitySymbol := value
		}
	}
	; End:NegativeInfinitySymbol ;}
;{ NumberDecimalDigits
/*!
	Property: NumberDecimalDigits [get/set]
		Gets or sets the NumberDecimalDigits value associated with the this instance
	Value:
		Var representing the NumberDecimalDigits property of the instance
*/
	NumberDecimalDigits[]
	{
		get {
			return this.m_NumberDecimalDigits
		}
		set {
			this.VerifyWritable()
			_val := MfInteger.GetValue(value, -1)
			if (value < 0 || value > 99)
			{
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Range", 0, 99))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.m_NumberDecimalDigits := _val
		}
	}
; End:NumberDecimalDigits ;}
	;{ PositiveInfinitySymbol
/*!
	Property: PositiveInfinitySymbol [get/set]
		Gets or sets the PositiveInfinitySymbol value associated with the this instance
	Value:
		Var representing the PositiveInfinitySymbol property of the instance
*/
	PositiveInfinitySymbol[]
	{
		get {
			return this.m_PositiveInfinitySymbol
		}
		set {
			this.VerifyWritable()
			if (value == "")
			{
				; empty string is allowed
				this.m_PositiveInfinitySymbol := value
				return
			}
			if (MfNull.IsNull(Value))
			{
				ex := new MfArgumentNullException("PositiveInfinitySymbol"
				, MfEnvironment.Instance.GetResourceString("ArgumentNull_String"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_value := MfString.GetValue(value)
			this.m_PositiveInfinitySymbol := _value
		}
	}
	; End:PositiveInfinitySymbol ;}
;{ PositiveSign
	/*!
		Property: PositiveSign [get/set]
			Gets or sets the PositiveSign value associated with the this instance
		Value:
			Var representing the PositiveSign property of the instance
	*/
	PositiveSign[]
	{
		get {
			return this.m_PositiveSign
		}
		set {
			this.VerifyWritable()
			if (value == "")
			{
				; can be empty string
				this.m_PositiveSign := value
				return
			}
			if (MfNull.IsNull(Value))
			{
				ex := new MfArgumentNullException("PositiveSign"
				, MfEnvironment.Instance.GetResourceString("ArgumentNull_String"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_value := MfString.GetValue(Value)
			this.m_PositiveSign := _value
		}
	}
; End:PositiveSign ;}
;{ NegativeSign
/*!
	Property: NegativeSign [get/set]
		Gets or sets the NegativeSign value associated with the this instance
	Value:
		Var representing the NegativeSign property of the instance
*/
	NegativeSign[]
	{
		get {
			return this.m_NegativeSign
		}
		set {
			this.VerifyWritable()
			if (Value == "")
			{
				; can be empty string
				this.m_NegativeSign := Value
				return
			}
			if (MfNull.IsNull(Value))
			{
				ex := new MfArgumentNullException("NegativeSign"
				, MfEnvironment.Instance.GetResourceString("ArgumentNull_String"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_value := MfString.GetValue(Value)
			this.m_NegativeSign := _value
		}
	}
; End:NegativeSign ;}
;{ NumberDecimalSeparator
/*!
	Property: NumberDecimalSeparator [get/set]
		Gets or sets the NumberDecimalSeparator value associated with the this instance
	Value:
		Var representing the NumberDecimalSeparator property of the instance
*/
	NumberDecimalSeparator[]
	{
		get {
			return this.m_NumberDecimalSeparator
		}
		set {
			this.VerifyWritable()
			_val := MfString.GetValue(value)
			MfNumberFormatInfo.VerifyDecimalSeparator(_val, "NumberDecimalSeparator")
			this.m_NumberDecimalSeparator := _val
		}
	}
; End:NumberDecimalSeparator ;}
;{ NumberGroupSeparator
/*!
	Property: NumberGroupSeparator [get/set]
		Gets or sets the NumberGroupSeparator value associated with the this instance
	Value:
		Var representing the NumberGroupSeparator property of the instance
*/
	NumberGroupSeparator[]
	{
		get {
			return this.m_NumberGroupSeparator
		}
		set {
			this.VerifyWritable()
			_value := MfString.GetValue(value)
			MfNumberFormatInfo.VerifyGroupSeparator(_value, "NumberGroupSeparator")
			this.m_NumberGroupSeparator := _value
		}
	}
; End:NumberGroupSeparator ;}
;{ NumberGroupSizes
/*!
	Property: NumberGroupSizes [get/set]
		Gets or sets the NumberGroupSizes value associated with the this instance
	Value:
		Var representing the NumberGroupSizes property of the instance
*/
	NumberGroupSizes[]
	{
		get {
			return this.m_NumberGroupSizes.Clone()
		}
		set {
			this.VerifyWritable()
			If (MfNull.IsNull(value))
			{
				ex := new MfArgumentNullException("NumberGroupSizes"
					,MfEnvironment.Instance.GetResourceString("ArgumentNull_Obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!MfObject.IsObjInstance(value, MfListBase))
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			If (Value.Count = 0)
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List_Size"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (MfObject.IsObjInstance(value, MfListVar))
			{
				this.m_NumberGroupSizes := value.Clone()
				return
			}
			lst := new MfListVar()
			for i, v in Value
			{
				lst._Add(v)
			}
			MfNumberFormatInfo.CheckGroupSize("NumberGroupSizes", lst)
			this.m_NumberGroupSizes := lst
		}
	}
; End:NumberGroupSizes ;}
;{ NumberNegativePattern
/*!
	Property: NumberNegativePattern [get/set]
		Gets or sets the NumberNegativePattern value associated with the this instance
	Value:
		Var representing the NumberNegativePattern property of the instance
*/
	NumberNegativePattern[]
	{
		get {
			return this.m_NumberNegativePattern
		}
		set {
			this.VerifyWritable()
			_val := MfInteger.GetValue(value, -1)
			if (_val < 0 || _val > 4)
			{
				ex := new MfArgumentOutOfRangeException("NumberNegativePattern"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Range", 0, 4))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.m_NumberNegativePattern := _val
		}
	}
; End:NumberNegativePattern ;}
;{ PercentDecimalDigits
/*!
	Property: PercentDecimalDigits [get/set]
		Gets or sets the PercentDecimalDigits value associated with the this instance
	Value:
		Var representing the PercentDecimalDigits property of the instance
*/
	PercentDecimalDigits[]
	{
		get {
			return this.m_PercentDecimalDigits
		}
		set {
			this.VerifyWritable()
			_val := MfInteger.GetValue(value, -1)
			if (_val < 0 || _val > 99)
			{
				ex := new MfArgumentOutOfRangeException("PercentDecimalDigits"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Range", 0, 99))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.m_PercentDecimalDigits := _val
		}
	}
; End:PercentDecimalDigits ;}
;{ PercentDecimalSeparator
/*!
	Property: PercentDecimalSeparator [get/set]
		Gets or sets the PercentDecimalSeparator value associated with the this instance
	Value:
		Var representing the PercentDecimalSeparator property of the instance
*/
	PercentDecimalSeparator[]
	{
		get {
			return this.m_PercentDecimalSeparator
		}
		set {
			this.VerifyWritable()
			_val := MfString.GetValue(value)
			MfNumberFormatInfo.VerifyDecimalSeparator(_val, "PercentDecimalSeparator")
			this.m_PercentDecimalSeparator := _val
		}
	}
; End:PercentDecimalSeparator ;}
;{ PercentGroupSeparator
/*!
	Property: PercentGroupSeparator [get/set]
		Gets or sets the PercentGroupSeparator value associated with the this instance
	Value:
		Var representing the PercentGroupSeparator property of the instance
*/
	PercentGroupSeparator[]
	{
		get {
			return this.m_PercentGroupSeparator
		}
		set {
			this.VerifyWritable()
			_value := MfString.GetValue(value)
			MfNumberFormatInfo.VerifyGroupSeparator(_value, "PercentGroupSeparator")
			this.m_PercentGroupSeparator := _value
		}
	}
; End:PercentGroupSeparator ;}
;{ PercentGroupSizes
/*!
	Property: PercentGroupSizes [get/set]
		Gets or sets the PercentGroupSizes value associated with the this instance
	Value:
		Var representing the PercentGroupSizes property of the instance
*/
	PercentGroupSizes[]
	{
		get {
			return this.m_PercentGroupSizes.Clone()
		}
		set {
			this.VerifyWritable()
			If (MfNull.IsNull(value))
			{
				ex := new MfArgumentNullException("PercentGroupSizes"
					,MfEnvironment.Instance.GetResourceString("ArgumentNull_Obj"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (!MfObject.IsObjInstance(value, MfListBase))
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			If (Value.Count = 0)
			{
				ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List_Size"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (MfObject.IsObjInstance(value, MfListVar))
			{
				this.m_NumberGroupSizes := value.Clone()
				return
			}
			lst := new MfListVar()
			for i, v in Value
			{
				lst._Add(v)
			}
			MfNumberFormatInfo.CheckGroupSize("PercentGroupSizes", lst)
			this.m_PercentGroupSizes := lst
		}
	}
; End:PercentGroupSizes ;}
;{ PercentNegativePattern
/*!
	Property: PercentNegativePattern [get/set]
		Gets or sets the PercentNegativePattern value associated with the this instance
	Value:
		Var representing the PercentNegativePattern property of the instance
*/
	PercentNegativePattern[]
	{
		get {
			return this.m_PercentNegativePattern
		}
		set {
			this.VerifyWritable()
			_val := MfInteger.GetValue(value, -1)
			if (_val < 0 || _val > 11)
			{
				ex := new MfArgumentOutOfRangeException("PercentNegativePattern"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Range", 0, 11))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.m_PercentNegativePattern := _val
		}
	}
; End:PercentNegativePattern ;}
;{ PercentPositivePattern
/*!
	Property: PercentPositivePattern [get/set]
		Gets or sets the PercentPositivePattern value associated with the this instance
	Value:
		Var representing the PercentPositivePattern property of the instance
*/
	PercentPositivePattern[]
	{
		get {
			return this.m_PercentPositivePattern
		}
		set {
			this.VerifyWritable()
			_val := MfInteger.GetValue(value, -1)
			if (_val < 0 || _val > 3)
			{
				ex := new MfArgumentOutOfRangeException("PercentPositivePattern"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Range", 0, 3))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			this.m_PercentPositivePattern := _val
		}
	}
; End:PercentPositivePattern ;}
;{ PercentSymbol
/*!
	Property: PercentSymbol [get/set]
		Gets or sets the PercentSymbol value associated with the this instance
	Value:
		Var representing the PercentSymbol property of the instance
*/
	PercentSymbol[]
	{
		get {
			return this.m_PercentSymbol
		}
		set {
			this.VerifyWritable()
			if (value == "")
			{
				; empty string is allowed
				this.m_PercentSymbol := value
				return
			}
			if (MfNull.IsNull(Value))
			{
				ex := new MfArgumentNullException("PercentSymbol"
				, MfEnvironment.Instance.GetResourceString("ArgumentNull_String"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_value := MfString.GetValue(Value)
			this.m_PercentSymbol := _value
		}
	}
; End:PercentSymbol ;}
;{ PerMilleSymbol
/*!
	Property: PerMilleSymbol [get/set]
		Gets or sets the PerMilleSymbol value associated with the this instance
	Value:
		Var representing the PerMilleSymbol property of the instance
*/
	PerMilleSymbol[]
	{
		get {
			return this.m_PerMilleSymbol
		}
		set {
			this.VerifyWritable()
			if (value == "")
			{
				; empty string is allowed
				this.m_PerMilleSymbol := value
				return
			}
			if (MfNull.IsNull(value))
			{
				ex := new MfArgumentNullException("PerMilleSymbol"
				, MfEnvironment.Instance.GetResourceString("ArgumentNull_String"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_value := MfString.GetValue(Value)
			return this.m_PerMilleSymbol
		}
	}
; End:PerMilleSymbol ;}
; End:Properties ;}	
}
/*!
	End of class
*/
; End:Class MfNumberFormatInfo ;}