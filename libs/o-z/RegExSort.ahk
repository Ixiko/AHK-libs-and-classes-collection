/*
    RegExSort.ahk
    Copyright (C) 2009,2010,2012 Antonio França

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
; RegExSort
;   http://bit.ly/Puh5eH | https://github.com/MasterFocus/AutoHotkey
;
; Sorts an input list based on RegEx needle and matching order
;
; Created by MasterFocus
;   https://git.io/master | http://masterfocus.ahk4.net
;
; Last Update: 2012-07-05 15:00 BRT
;
; Based on previous work by cnoiz
;   http://autohotkey.com/community/viewtopic.php?f=2&t=51924
;
;========================================================================

RegExSort(p_InputList, p_RegExNeedle, p_Order="", p_OptString="", p_Din="`r`n", p_Dout="`n") {
    l_PrivChar1 := Chr(4) , l_PrivChar2 := Chr(5)
    Loop, Parse, p_InputList, %p_Din%
    {
        If ( !RegExMatch( A_LoopField , p_RegExNeedle , l_Output ) || ErrorLevel )
            Return
        If ( p_Order <> ( l_Matched := "" ) ) {
            If InStr( p_Order , "R" )
                While ( l_Output%A_Index% <> "" )
                    l_Matched := l_Output%A_Index% l_Matched
            Else
                Loop, Parse, p_Order, `,
                    l_Matched .= l_Output%A_LoopField%
        }
        Else
            l_Matched := l_Output
        If ( l_Matched <> "" )
            l_FinalStr .= A_LoopField l_PrivChar1 "\" l_Matched l_PrivChar2 p_Dout
    }
    Sort, l_FinalStr, \ %p_OptString% D%p_Dout%
    Return RegExReplace( l_FinalStr , l_PrivChar1 ".*?" l_PrivChar2 )
}
