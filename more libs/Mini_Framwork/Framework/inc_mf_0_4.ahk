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
#Include <Mini_Framwork\0.4\System\Mfunc>
#Include <Mini_Framwork\0.4\System\MfObject>
#Include <Mini_Framwork\0.4\System\MfInfo>
#Include <Mini_Framwork\0.4\System\MfResourceManager>				; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfType>							; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfEqualityComparerBase>			; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfVersion>						; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfValueType>						; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfSingletonBase>					; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfAttribute>						; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfEnumerableBase>				; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfCast>							; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfConvert>						; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfByteConverter>					; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfNibConverter>					; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfBinaryConverter>				; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfMath>							; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfNumber>						; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfMemoryString>					; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfBigMathInt>					; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfBigInt>						; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfFormatProvider>				; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfNumberFormatInfoBase>			; inherits MfFormatProvider
#Include <Mini_Framwork\0.4\System\MfNumberFormatInfo>				; inherits MfNumberFormatInfoBase
#Include <Mini_Framwork\0.4\System\MfOrdinalComparer>				; inherits MfEqualityComparerBase
#Include <Mini_Framwork\0.4\System\MfNull>							; inherits MfBase:MfObject
#Include <Mini_Framwork\0.4\System\MfResourceSingletonBase>			; inherits MfSingletonBase
#Include <Mini_Framwork\0.4\System\MfEnvironment>					; inherits MfResourceSingletonBase
#Include <Mini_Framwork\0.4\System\MfFlagsAttribute>				; inherits MfAttribute
#Include <Mini_Framwork\0.4\System\MfPrimitive>						; inherits MfValueType
#Include <Mini_Framwork\0.4\System\MfEnum>							; inherits MfValueType
#Include <Mini_Framwork\0.4\System\MfDictionaryEntry>				; inherits MfValueType
#Include <Mini_Framwork\0.4\System\MfFrameWorkOptions>				; inherits MfEnum
#Include <Mini_Framwork\0.4\System\MfTypeCode>						; inherits MfEnum
#Include <Mini_Framwork\0.4\System\MfDigitShapes>					; inherits MfEnum
#Include <Mini_Framwork\0.4\System\MfNumberStyles>					; inherits MfEnum
#Include <Mini_Framwork\0.4\System\MfStringComparison>				; inherits MfEnum
#Include <Mini_Framwork\0.4\System\MfStringSplitOptions>			; inherits MfEnum
#Include <Mini_Framwork\0.4\System\MfUnicodeCategory>				; inherits MfEnum
#Include <Mini_Framwork\0.4\System\MfEqualsOptions>					; inherits MfEnum
#Include <Mini_Framwork\0.4\System\MfSetFormatNumberType>			; inherits MfEnum
#Include <Mini_Framwork\0.4\System\MfMidpointRounding>				; inherits MfEnum
#Include <Mini_Framwork\0.4\System\MfBool>							; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfChar>							; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfByte>							; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfInt16>							; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfInteger>						; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfInt64>							; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfFloat>							; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfString>						; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfTimeSpan>						; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfUint16>						; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfUInt32>						; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfUInt64>						; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfSByte>							; inherits MfPrimitive
#Include <Mini_Framwork\0.4\System\MfCollectionBase>				; inherits MfEnumerableBase
#Include <Mini_Framwork\0.4\System\MfListBase>						; inherits MfEnumerableBase
#Include <Mini_Framwork\0.4\System\MfQueue>							; inherits MfEnumerableBase
#Include <Mini_Framwork\0.4\System\MfStack>							; inherits MfEnumerableBase
#Include <Mini_Framwork\0.4\System\MfHashTable>						; inherits MfEnumerableBase
#Include <Mini_Framwork\0.4\System\MfList>							; inherits MfListBase
#Include <Mini_Framwork\0.4\System\MfGenericList>					; inherits MfListBase
#Include <Mini_Framwork\0.4\System\MfListVar>						; inherits MfListBase
#Include <Mini_Framwork\0.4\System\MfByteList>						; inherits MfListBase
#Include <Mini_Framwork\0.4\System\MfNibbleList>					; inherits MfListBase
#Include <Mini_Framwork\0.4\System\MfBinaryList>					; inherits MfListBase
#Include <Mini_Framwork\0.4\System\MfCharList>						; inherits MfListBase
#Include <Mini_Framwork\0.4\System\MfParams>						; inherits MfCollectionBase
#Include <Mini_Framwork\0.4\System\MfCollection>					; inherits MfCollectionBase
#Include <Mini_Framwork\0.4\System\MfDictionarybase>				; inherits MfEnumerableBase
#Include <Mini_Framwork\0.4\System\MfDictionary>					; inherits MfDictionarybase
#Include <Mini_Framwork\0.4\System\MfCharUnicodeInfo>
#Include <Mini_Framwork\0.4\System\MfBidiCategory>
;{ Exceptions
#Include <Mini_Framwork\0.4\System\MfException>						; inherits MfObject
#Include <Mini_Framwork\0.4\System\MfSystemException> 				; inherits MfException
#Include <Mini_Framwork\0.4\System\MfArgumentException> 			; inherits MfSystemException
#Include <Mini_Framwork\0.4\System\MfFormatException>				; inherits MfSystemException
#Include <Mini_Framwork\0.4\System\MfIndexOutOfRangeException> 		; inherits MfSystemException
#Include <Mini_Framwork\0.4\System\MfMemberAccessException> 		; inherits MfSystemException
#Include <Mini_Framwork\0.4\System\MfNotImplementedException>		; inherits MfSystemException
#Include <Mini_Framwork\0.4\System\MfNullReferenceException> 		; inherits MfSystemException
#Include <Mini_Framwork\0.4\System\MfNotSupportedException>			; inherits MfSystemException
#Include <Mini_Framwork\0.4\System\MfInvalidCastException>			; inherits MfSystemException
#Include <Mini_Framwork\0.4\System\MfInvalidOperationException>		; inherits MfSystemException
#Include <Mini_Framwork\0.4\System\MfArithmeticException>			; inherits MfSystemException
#Include <Mini_Framwork\0.4\System\MfOutOfMemoryException>			; inherits MfSystemException
#Include <Mini_Framwork\0.4\System\MfOverflowException>				; inherits MfArithmeticException
#Include <Mini_Framwork\0.4\System\MfDivideByZeroException>			; inherits MfArithmeticException
#Include <Mini_Framwork\0.4\System\MfArgumentNullException> 		; inherits MfArgumentException
#Include <Mini_Framwork\0.4\System\MfNonMfObjectException> 			; inherits MfArgumentNullException
#Include <Mini_Framwork\0.4\System\MfArgumentOutOfRangeException> 	; inherits MfArgumentException
#Include <Mini_Framwork\0.4\System\MfMissingMemberException> 		; inherits MfMemberAccessException
#Include <Mini_Framwork\0.4\System\MfMissingFieldException> 		; inherits MfMissingMemberException
#Include <Mini_Framwork\0.4\System\MfMissingMethodException> 		; inherits MfMissingMemberException

; System.Text Namespace
#Include <Mini_Framwork\0.4\System\Text\MfText>						; Namespace class
#Include <Mini_Framwork\0.4\System\Text\MfStringBuilder>			; inherits MfObject
; End:System.Text Namespace
; End:Exceptions ;}
;{ MfUcd Namespace
class MfUcd ; namespace MfUcd
{
	#Include <Mini_Framwork\0.4\System\MfUnicode\MfDbUcdAbstract>
	#Include <Mini_Framwork\0.4\System\MfUnicode\MfSQLite_L>
	#Include <Mini_Framwork\0.4\System\MfUnicode\MfUcdDb>
	#Include <Mini_Framwork\0.4\System\MfUnicode\MfDataBaseFactory>
	#Include <Mini_Framwork\0.4\System\MfUnicode\MfRecordSetSqlLite>
	#Include <Mini_Framwork\0.4\System\MfUnicode\UCDSqlite>
}
; End:MfUcd Namespace ;}
