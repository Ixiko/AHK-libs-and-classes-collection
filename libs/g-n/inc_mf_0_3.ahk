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
#Include <Mini_Framwork\0.3\System\Mfunc>
#Include <Mini_Framwork\0.3\System\MfObject>
#Include <Mini_Framwork\0.3\System\MfInfo>
#Include <Mini_Framwork\0.3\System\MfResourceManager>				; inherits MfObject
#Include <Mini_Framwork\0.3\System\MfType>							; inherits MfObject
#Include <Mini_Framwork\0.3\System\MfEqualityComparerBase>			; inherits MfObject
#Include <Mini_Framwork\0.3\System\MfVersion>						; inherits MfObject
#Include <Mini_Framwork\0.3\System\MfValueType>						; inherits MfObject
#Include <Mini_Framwork\0.3\System\MfSingletonBase>					; inherits MfObject
#Include <Mini_Framwork\0.3\System\MfAttribute>						; inherits MfObject
#Include <Mini_Framwork\0.3\System\MfEnumerableBase>				; inherits MfObject
#Include <Mini_Framwork\0.3\System\MfOrdinalComparer>				; inherits MfEqualityComparerBase
#Include <Mini_Framwork\0.3\System\MfNull>							; inherits MfBase:MfObject
#Include <Mini_Framwork\0.3\System\MfResourceSingletonBase>			; inherits MfSingletonBase
#Include <Mini_Framwork\0.3\System\MfEnvironment>					; inherits MfResourceSingletonBase
#Include <Mini_Framwork\0.3\System\MfFlagsAttribute>				; inherits MfAttribute
#Include <Mini_Framwork\0.3\System\MfPrimitive>						; inherits MfValueType
#Include <Mini_Framwork\0.3\System\MfEnum>							; inherits MfValueType
#Include <Mini_Framwork\0.3\System\MfDictionaryEntry>				; inherits MfValueType
#Include <Mini_Framwork\0.3\System\MfFrameWorkOptions>				; inherits MfEnum
#Include <Mini_Framwork\0.3\System\MfTypeCode>						; inherits MfEnum
#Include <Mini_Framwork\0.3\System\MfDigitShapes>					; inherits MfEnum
#Include <Mini_Framwork\0.3\System\MfNumberStyles>					; inherits MfEnum
#Include <Mini_Framwork\0.3\System\MfStringComparison>				; inherits MfEnum
#Include <Mini_Framwork\0.3\System\MfStringSplitOptions>			; inherits MfEnum
#Include <Mini_Framwork\0.3\System\MfUnicodeCategory>				; inherits MfEnum
#Include <Mini_Framwork\0.3\System\MfEqualsOptions>					; inherits MfEnum
#Include <Mini_Framwork\0.3\System\MfSetFormatNumberType>			; inherits MfEnum
#Include <Mini_Framwork\0.3\System\MfBool>							; inherits MfPrimitive
#Include <Mini_Framwork\0.3\System\MfChar>							; inherits MfPrimitive
#Include <Mini_Framwork\0.3\System\MfByte>							; inherits MfPrimitive
#Include <Mini_Framwork\0.3\System\MfInt16>							; inherits MfPrimitive
#Include <Mini_Framwork\0.3\System\MfInteger>						; inherits MfPrimitive
#Include <Mini_Framwork\0.3\System\MfInt64>							; inherits MfPrimitive
#Include <Mini_Framwork\0.3\System\MfFloat>							; inherits MfPrimitive
#Include <Mini_Framwork\0.3\System\MfString>						; inherits MfPrimitive
#Include <Mini_Framwork\0.3\System\MfTimeSpan>						; inherits MfPrimitive
#Include <Mini_Framwork\0.3\System\MfCollectionBase>				; inherits MfEnumerableBase
#Include <Mini_Framwork\0.3\System\MfListBase>						; inherits MfEnumerableBase
#Include <Mini_Framwork\0.3\System\MfQueue>							; inherits MfEnumerableBase
#Include <Mini_Framwork\0.3\System\MfStack>							; inherits MfEnumerableBase
#Include <Mini_Framwork\0.3\System\MfHashTable>						; inherits MfEnumerableBase
#Include <Mini_Framwork\0.3\System\MfList>							; inherits MfListBase
#Include <Mini_Framwork\0.3\System\MfGenericList>					; inherits MfListBase
#Include <Mini_Framwork\0.3\System\MfParams>						; inherits MfCollectionBase
#Include <Mini_Framwork\0.3\System\MfCollection>					; inherits MfCollectionBase
#Include <Mini_Framwork\0.3\System\MfDictionarybase>				; inherits MfEnumerableBase
#Include <Mini_Framwork\0.3\System\MfDictionary>					; inherits MfDictionarybase
#Include <Mini_Framwork\0.3\System\MfCharUnicodeInfo>
#Include <Mini_Framwork\0.3\System\MfBidiCategory>
;{ Exceptions
#Include <Mini_Framwork\0.3\System\MfException>						; inherits MfObject
#Include <Mini_Framwork\0.3\System\MfSystemException> 				; inherits MfException
#Include <Mini_Framwork\0.3\System\MfArgumentException> 			; inherits MfSystemException
#Include <Mini_Framwork\0.3\System\MfFormatException>				; inherits MfSystemException
#Include <Mini_Framwork\0.3\System\MfIndexOutOfRangeException> 		; inherits MfSystemException
#Include <Mini_Framwork\0.3\System\MfMemberAccessException> 		; inherits MfSystemException
#Include <Mini_Framwork\0.3\System\MfNotImplementedException>		; inherits MfSystemException
#Include <Mini_Framwork\0.3\System\MfNullReferenceException> 		; inherits MfSystemException
#Include <Mini_Framwork\0.3\System\MfNotSupportedException>			; inherits MfSystemException
#Include <Mini_Framwork\0.3\System\MfInvalidCastException>			; inherits MfSystemException
#Include <Mini_Framwork\0.3\System\MfInvalidOperationException>		; inherits MfSystemException
#Include <Mini_Framwork\0.3\System\MfArithmeticException>			; inherits MfSystemException
#Include <Mini_Framwork\0.3\System\MfOverflowException>				; inherits MfArithmeticException
#Include <Mini_Framwork\0.3\System\MfDivideByZeroException>			; inherits MfArithmeticException
#Include <Mini_Framwork\0.3\System\MfArgumentNullException> 		; inherits MfArgumentException
#Include <Mini_Framwork\0.3\System\MfNonMfObjectException> 			; inherits MfArgumentNullException
#Include <Mini_Framwork\0.3\System\MfArgumentOutOfRangeException> 	; inherits MfArgumentException
#Include <Mini_Framwork\0.3\System\MfMissingMemberException> 		; inherits MfMemberAccessException
#Include <Mini_Framwork\0.3\System\MfMissingFieldException> 		; inherits MfMissingMemberException
#Include <Mini_Framwork\0.3\System\MfMissingMethodException> 		; inherits MfMissingMemberException
; End:Exceptions ;}
;{ MfUcd Namespace
class MfUcd ; namespace MfUcd
{
	#Include <Mini_Framwork\0.3\System\MfUnicode\MfDbUcdAbstract>
	#Include <Mini_Framwork\0.3\System\MfUnicode\MfSQLite_L>
	#Include <Mini_Framwork\0.3\System\MfUnicode\MfUcdDb>
	#Include <Mini_Framwork\0.3\System\MfUnicode\MfDataBaseFactory>
	#Include <Mini_Framwork\0.3\System\MfUnicode\MfRecordSetSqlLite>
	#Include <Mini_Framwork\0.3\System\MfUnicode\UCDSqlite>
}
; End:MfUcd Namespace ;}
