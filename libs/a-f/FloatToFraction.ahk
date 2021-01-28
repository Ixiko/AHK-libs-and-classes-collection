/*
    FloatToFraction.ahk
    Copyright (C) 2012 Antonio França

    This script is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This script is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this script. If not, see <http://www.gnu.org/licenses/>.
*/

;========================================================================
; 
; FloatToFraction
;   https://github.com/MasterFocus/AutoHotkey
;
; Converts a positive float into a fraction
;
; Created by MasterFocus
;   https://git.io/master | http://masterfocus.ahk4.net
;
; Last Update: 2012-10-29 22:00 BRT
;
; Based on a request by smorgasboard
;   http://autohotkey.com/board/topic/86310-recurring-decimal-to-fraction-converter/
;
;========================================================================

FloatToFraction(p_Input,p_MinRep=2,p_MinPatLen=1,p_MaxPatLen=15) {
    If p_Input is not float
    {
        ErrorLevel := 1
        Return ""
    }
    If ( p_Input = 0 )
        Return 0
    If ( p_Input < 0 ) {
        l_Minus := "-" ; store the minus sign for a correct output later
        p_Input := SubStr(p_Input,2) ; remove minus sign (not using 'var *= -1' to avoid problems)
    }
    ; remove 0's from the right side (not using RTrim() to mantain compatibility with AHK v1.0.*)
    p_Input := RegExReplace( p_Input , "0+$" )
    ; separate the integer part from the decimal part
    StringSplit, l_Input, p_Input, .
    ; if the end of the string is like "384004", change it to "38400400"
    If RegExMatch( l_Input2 , "(0+)([1-9]+)$" , l_M ) && RegExMatch( l_Input2 , l_M2 l_M1 l_M2 "$" )
        l_Input2 .= l_M1
    ; store the length of the decimal part (after the adjustments, if any)
    l_Len := StrLen(l_Input2)
    ; loop to find repetitions (if any)
    Loop, % p_MaxPatLen - (p_MinPatLen-1) {
        If !RegExMatch( l_Input2 , "\d{" ( l_Index := p_MaxPatLen-(A_Index-1) ) "}$" , l_M1 )
        || RegExMatch( l_M1 , "^9+$" ) ; skip if the pattern contains only '9' (to avoid problems)...
            Continue ; ... or a pattern of length %l_Index% was not found at the end of the string
        ; reset the variable storing the repetition
        l_RepeatedPattern := ""
        ; set the repetition variable according to the specified minimum
        Loop, %p_MinRep%
            l_RepeatedPattern .= l_M1
        ; skip if the repetition is not found at the end of the string
        If !RegExMatch( l_Input2 , l_RepeatedPattern "$" ) 
            Continue
        If ( (l_T := l_Len-l_Index) <= 0 ) {
            ErrorLevel := 2 ; exceeding the length limit (subtracting too much)
            Return ""
        }
        l_Big := "0" SubStr(l_Input2,1,l_T) , l_Small := "0" SubStr(l_Input2,1,l_A:=l_T-l_Index)
        If ( (l_Num := l_Big-l_Small) < 0 ) {
            ErrorLevel := 3 ; AHK wasn't able to handle the calculation (the number became negative)
            Return ""
        }
        ; add the correct number of 9's and 0's to form the denominator
        Loop, %l_Index%
            l_Temp2 .= "9"
        Loop, %l_A%
            l_Temp1 .= "0"
        ; set the numerator and the denominator, and prepare to calculate the Euclidian GCD
        l_Temp1 := ( l_Num += l_Input1*(l_Temp2 := l_Den := l_Temp2 l_Temp1) )
        While l_Temp2
            l_Temp0 := Mod(l_Temp1,l_Temp2), l_Temp1 := l_Temp2, l_Temp2 := l_Temp0
        If ( ( (l_Num //= l_Temp1) <= 0) || ( (l_Den //= l_Temp1) <= 0 ) ) {
            ErrorLevel := 4 ; AHK wasn't able to handle the calculation (at least 1 number became negative)
            Return ""
        }
        Return ( l_Minus l_Num "/" l_Den )
    }
    ; this point is reached if no pattern or repetition was found
    Loop, % l_Len * ( l_Temp2 := 1 )
        l_Temp2 .= "0" ; add 0's after 1 to form the denominator (power of 10)
    ; set the numerator and the denominator, and prepare to calculate the Euclidian GCD
    l_Num := l_Temp1 := l_Input1 l_Input2, l_Den := l_Temp2
    While l_Temp2
        l_Temp0 := Mod(l_Temp1,l_Temp2), l_Temp1 := l_Temp2, l_Temp2 := l_Temp0
    If ( ( (l_Num //= l_Temp1) <= 0) || ( (l_Den //= l_Temp1) <= 0 ) ) {
        ErrorLevel := 5 ; AHK wasn't able to handle the calculation (at least 1 number became negative)
        Return ""
    }
    Return ( l_Minus l_Num "/" l_Den )
}
