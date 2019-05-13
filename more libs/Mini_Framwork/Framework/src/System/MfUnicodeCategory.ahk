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

; Defines the Unicode category of a character.
/*!
	Class: MfUnicodeCategory
		Provides implementation methods and properties for MfEnum type classes.Defines the Unicode category of a character.
		MfUnicodeCategory is an MfEnum style class.
		MfUnicodeCategory is a Sealed Class and cannot be inherited.
	Inherits: MfValueType
*/
class MfUnicodeCategory extends MfEnum
{
	static m_Instance := ""
;{ Constructor
/*
	Constructor()
	
	OutputVar := new MfUnicodeCategory()
	OutputVar := new MfUnicodeCategory(num)
	OutputVar := new MfUnicodeCategory(instanceEnum)
	OutputVar := new MfUnicodeCategory(enumItem)
	
	Constructor ()
		Creates a new instance of MfUnicodeCategory class and set initial value to the value of UppercaseLetter.
	
	Constructor (num)
		Creates a new instance of MfUnicodeCategory class and sets initial value to value of num.
	Parameters
	num
		An integer value representing an Enumeration Value of MfUnicodeCategory.
	Example
		MyEnum := new MfUnicodeCategory(4) ; OtherLetter
	
	Constructor (instanceEnum)
		Creates a new instance of MfUnicodeCategory class an set the intial value to the value of instanceEnum.
	Parameters
		instanceEnum
		an instance of MfUnicodeCategory whose Value is used to construct this instance.
	Example
		MyEnum := new MfUnicodeCategory() ; create instance with default value
		MyEnum.Value := MfUnicodeCategory.Instance.SpacingCombiningMark.Value
		MfE := new MfUnicodeCategory(MyEnum) ; create a new instance and sets it value to the value of MyEnum
	
	Constructor (enumItem)
		Creates a new instance of MfUnicodeCategory and set its value enumItem value.
	Parameters
		enumItem
			MfEnum.EnumItem value must Enumeration of MfUnicodeCategory
	Example
		MyEnum := new MfUnicodeCategory(MfUnicodeCategory.Instance.SpacingCombiningMark)
	
	Throws
		Throws MfNotSupportedException if this sealed class is extended or inherited.
		Throws MfArgumentException if arguments are not correct.
*/
	__New(args*) {
		; Throws MfNotSupportedException if MfUnicodeCategory Sealed class is extended
		if (this.__Class != "MfUnicodeCategory") {
			throw new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Sealed_Class","MfUnicodeCategory"))
		}
		base.__New(args*)
		this.m_isInherited := this.__Class != "MfUnicodeCategory"
	}
; End:Constructor ;}
;{ MfEnum values
	/*!
		Property: ClosePunctuation [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Closing character of one of the paired punctuation marks, such as parentheses, square brackets, and braces. Signified by the Unicode designation "Pe" (punctuation, close). The value is 21.
	*/
	/*!
		Property: ConnectorPunctuation [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Connector punctuation character that connects two characters. Signified by the Unicode designation "Pc" (punctuation, connector). The value is 18.
	*/
	/*!
		Property: Control [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Control code character, with a Unicode value of U+007F or in the range U+0000 through U+001F or U+0080 through U+009F. Signified by the Unicode designation "Cc" (other, control). The value is 14.
	*/
	/*!
		Property: CurrencySymbol [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Currency symbol character. Signified by the Unicode designation "Sc" (symbol, currency). The value is 26.
	*/
	/*!
		Property: DashPunctuation [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Dash or hyphen character. Signified by the Unicode designation "Pd" (punctuation, dash). The value is 19.
	*/
	/*!
		Property: DecimalDigitNumber [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Decimal digit character, that is, a character in the range 0 through 9. Signified by the Unicode designation "Nd" (number, decimal digit). The value is 8.
	*/
	/*!
		Property: EnclosingMark [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Enclosing mark character, which is a nonspacing combining character that surrounds all previous characters up to and including a base character. Signified by the Unicode designation "Me" (mark, enclosing). The value is 7.
	*/
	/*!
		Property: FinalQuotePunctuation [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Closing or final quotation mark character. Signified by the Unicode designation "Pf" (punctuation, final quote). The value is 23.
	*/
	/*!
		Property: Format [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Format character that affects the layout of text or the operation of text processes, but is not normally rendered. Signified by the Unicode designation "Cf" (other, format). The value is 15.
	*/
	/*!
		Property: InitialQuotePunctuation [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Opening or initial quotation mark character. Signified by the Unicode designation "Pi" (punctuation, initial quote). The value is 22.
	*/
	/*!
		Property: LetterNumber [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Number represented by a letter, instead of a decimal digit, for example, the Roman numeral for five, which is "V". The indicator is signified by the Unicode designation "Nl" (number, letter). The value is 9.
	*/
	/*!
		Property: LineSeparator [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Character that is used to separate lines of text. Signified by the Unicode designation "Zl" (separator, line). The value is 12.
	*/
	/*!
		Property: LowercaseLetter [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Lowercase letter. Signified by the Unicode designation "Ll" (letter, lowercase). The value is 1.
	*/
	/*!
		Property: MathSymbol [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Mathematical symbol character, such as "+" or ":= ". Signified by the Unicode designation "Sm" (symbol, math). The value is 25.
	*/
	/*!
		Property: ModifierLetter [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Modifier letter character, which is free-standing spacing character that indicates modifications of a preceding letter. Signified by the Unicode designation "Lm" (letter, modifier). The value is 3.
	*/
	/*!
		Property: ModifierSymbol [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Modifier symbol character, which indicates modifications of surrounding characters. For example, the fraction slash indicates that the number to the left is the numerator and the number to the right is the denominator. The indicator is signified by the Unicode designation "Sk" (symbol, modifier). The value is 27.
	*/
	/*!
		Property: NonSpacingMark [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Nonspacing character that indicates modifications of a base character. Signified by the Unicode designation "Mn" (mark, nonspacing). The value is 5.
	*/
	/*!
		Property: OpenPunctuation [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Opening character of one of the paired punctuation marks, such as parentheses, square brackets, and braces. Signified by the Unicode designation "Ps" (punctuation, open). The value is 20.
	*/
	/*!
		Property: OtherLetter [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Letter that is not an uppercase letter, a lowercase letter, a titlecase letter, or a modifier letter. Signified by the Unicode designation "Lo" (letter, other). The value is 4.
	*/
	/*!
		Property: OtherNotAssigned [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Character that is not assigned to any Unicode category. Signified by the Unicode designation "Cn" (other, not assigned). The value is 29.
	*/
	/*!
		Property: OtherNumber [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Number that is neither a decimal digit nor a letter number, for example, the fraction 1/2. The indicator is signified by the Unicode designation "No" (number, other). The value is 10.
	*/
	/*!
		Property: OtherPunctuation [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Punctuation character that is not a connector, a dash, open punctuation, close punctuation, an initial quote, or a final quote. Signified by the Unicode designation "Po" (punctuation, other). The value is 24.
	*/
	/*!
		Property: OtherSymbol [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Symbol character that is not a mathematical symbol, a currency symbol or a modifier symbol. Signified by the Unicode designation "So" (symbol, other). The value is 28.
	*/
	/*!
		Property: ParagraphSeparator [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Character used to separate paragraphs. Signified by the Unicode designation "Zp" (separator, paragraph). The value is 13.
	*/
	/*!
		Property: PrivateUse [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Private-use character, with a Unicode value in the range U+E000 through U+F8FF. Signified by the Unicode designation "Co" (other, private use). The value is 17.
	*/
	/*!
		Property: SpaceSeparator [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Space character, which has no glyph but is not a control or format character. Signified by the Unicode designation "Zs" (separator, space). The value is 11.
	*/
	/*!
		Property: SpacingCombiningMark [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Spacing character that indicates modifications of a base character and affects the width of the glyph for that base character. Signified by the Unicode designation "Mc" (mark, spacing combining). The value is 6.
	*/
	/*!
		Property: Surrogate [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			High surrogate or a low surrogate character. Surrogate code values are in the range U+D800 through U+DFFF. Signified by the Unicode designation "Cs" (other, surrogate). The value is 16.
	*/
	/*!
		Property: TitlecaseLetter [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Titlecase letter. Signified by the Unicode designation "Lt" (letter, titlecase). The value is 2.
	*/
	/*!
		Property: UppercaseLetter [get]
			Gets the [MfEnum.EnumItem](MfEnum.enumitem.html) associated with the MfEnum property.  
			Uppercase letter. Signified by the Unicode designation "Lu" (letter, uppercase). The value is 0.
	*/
; End:MfEnum values ;}
;{ Methods
;{ 	AddEnums()
/*
	Method: AddEnums()
		Overrides MfEnum.AddEnums.
	AddEnums()
		Processes adding of new Enum values to class.
	Remarks:
		Protected Method
		This method is call by base class and does not need to be call manually.
		Example
*/
	AddEnums() {
		this.AddEnumValue("UppercaseLetter", 0)
		this.AddEnumValue("LowercaseLetter", 1)
		this.AddEnumValue("TitlecaseLetter", 2)
		this.AddEnumValue("ModifierLetter", 3)
		this.AddEnumValue("OtherLetter", 4)
		this.AddEnumValue("NonSpacingMark", 5)
		this.AddEnumValue("SpacingCombiningMark", 6)
		this.AddEnumValue("EnclosingMark", 7)
		this.AddEnumValue("DecimalDigitNumber", 8)
		this.AddEnumValue("LetterNumber", 9)
		this.AddEnumValue("OtherNumber", 10)
		this.AddEnumValue("SpaceSeparator", 11)
		this.AddEnumValue("LineSeparator", 12)
		this.AddEnumValue("ParagraphSeparator", 13)
		this.AddEnumValue("Control", 14)
		this.AddEnumValue("Format", 15)
		this.AddEnumValue("Surrogate", 16)
		this.AddEnumValue("PrivateUse", 17)
		this.AddEnumValue("ConnectorPunctuation", 18)
		this.AddEnumValue("DashPunctuation", 19)
		this.AddEnumValue("OpenPunctuation", 20)
		this.AddEnumValue("ClosePunctuation", 21)
		this.AddEnumValue("InitialQuotePunctuation", 22)
		this.AddEnumValue("FinalQuotePunctuation", 23)
		this.AddEnumValue("OtherPunctuation", 24)
		this.AddEnumValue("MathSymbol", 25)
		this.AddEnumValue("CurrencySymbol", 26)
		this.AddEnumValue("ModifierSymbol", 27)
		this.AddEnumValue("OtherSymbol", 28)
		this.AddEnumValue("OtherNotAssigned", 29)
	}
; 	End:AddEnums() ;}

;{	DestroyInstance()
/*
	Method: DestroyInstance()
		Overrides MfEnum.DestroyInstance()
	DestroyInstance()
		Set current instance of class to null.
	Remarks:
		Static Method
*/
	DestroyInstance() {
		MfUnicodeCategory.m_Instance := Null
	}
; End:DestroyInstance() ;}

;{ 	GetInstance()
/*
	Method: GetInstance()
		Overrides MfEnum.GetInstance().

	OutputVar := MfUnicodeCategory.GetInstance()

	GetInstance()
		Gets the instance for the MfUnicodeCategory class.
	Returns:
		Returns Singleton instance for MfUnicodeCategory class.
	Remarks:
		Protected static Method.
		DestroyInstance() can be called to destroy instance.
		Use Instance to access the singleton instance.
*/
	GetInstance() {
		if (MfNull.IsNull(MfUnicodeCategory.m_Instance)) {
			MfUnicodeCategory.m_Instance := new MfUnicodeCategory(0)
		}
		return MfUnicodeCategory.m_Instance
	}
; End:GetInstance() ;}

; End:Methods ;}
}
/*!
	End of class
*/