;------------------------------
;
; Function: Convert2Hex
;
; Description:
;
;   Converts an integer to hexadecimal format.
;
; Parameters:
;
;   p_Integer - An integer in any format.
; 
;   p_MinDigits - The minimum number of hexadecimal digits the return value
;       should have.  Set to 0 (the default) or 1 to use the smallest number of
;       digits needed.  See the *Remarks* section for more information.
; 
; Returns:
;
;   An integer in hexadecimal format.
;
; Remarks:
;
; * Only integer values that can be stored in a 64-bit signed integer are
;   supported.  Numbers smaller than -9223372036854775808 (-0x8000000000000000)
;   or larger than 9223372036854775807 (0x7FFFFFFFFFFFFFFF) will return
;   inconsistent results.
;
; * The p_MinDigits parameter can be used to set the return value to a fixed
;   number of hexadecimal digits.  For example, if p_MinDigits is to 0 (the
;   default), an integer value of 255 will be returned with the minimum number
;   of hexadecimal digits needed to represent this value, i.e. "0xFF".  If
;   p_MinDigits is set to 6, the same integer value of 255 will be returned with
;   6 hexadecimal digits, i.e. "0x0000FF".
;
;-------------------------------------------------------------------------------
Convert2Hex(p_Integer,p_MinDigits=0)
{
    ;-- Workaround for AutoHotkey Basic
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"
 
    ;-- Negative?
    if (p_Integer<0)
        {
        l_NegativeChar:="-"
        p_Integer:=-p_Integer
        }
 
    ;-- Determine the width (in characters) of the output buffer
    nSize:=(p_Integer=0) ? 1:Floor(Ln(p_Integer)/Ln(16))+1
    if (p_MinDigits>nSize)
        nSize:=p_MinDigits+0
 
    ;-- Build Format string
    l_Format:="`%0" . nSize . "I64X"
 
    ;-- Create and populate l_Argument
    VarSetCapacity(l_Argument,8)
    NumPut(p_Integer,l_Argument,0,"Int64")
 
    ;-- Convert
    VarSetCapacity(l_Buffer,A_IsUnicode ? nSize*2:nSize,0)
    DllCall(A_IsUnicode ? "msvcrt\_vsnwprintf":"msvcrt\_vsnprintf"
        ,"Str",l_Buffer             ;-- Storage location for output
        ,"UInt",nSize               ;-- Maximum number of characters to write
        ,"Str",l_Format             ;-- Format specification
        ,PtrType,&l_Argument)       ;-- Argument
 
    ;-- Assemble and return the final value
    Return l_NegativeChar . "0x" . l_Buffer
}