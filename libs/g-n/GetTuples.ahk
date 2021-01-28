/*
    GetTuples.ahk
    Copyright (C) 2010,2012,2013 Antonio França

    This script is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This script is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this script.  If not, see <http://www.gnu.org/licenses/>.
*/

;========================================================================
; 
; Function:     GetTuples (aka Arrange)
; Description:  Arranges a given input into all possible N-tuples
; URL (+info):  https://bit.ly/Sip44M
;
; Last Update:  02/February/2013 04:50 BRT
;
; Created by MasterFocus
; - https://github.com/MasterFocus
; - http://masterfocus.ahk4.net
; - http://autohotkey.com/community/viewtopic.php?f=2&t=88198
;
;========================================================================

GetTuples(p_List,p_Pick,p_InputD="",p_InputO=" `t",p_OutputDin=" "
,p_OutputDout="`n",p_Reverse=0,p_Offset=0,p_Count=0,p_Func="",p_Valid=0) {
    If ( p_List = "" ) OR ( p_Pick < 1 )
        Return
    StringSplit, l_Arr, p_List, %p_InputD%, %p_InputO%
    Loop, %p_Pick%
        l_CharIndex%A_Index% := p_Reverse ? l_Arr0 : 1
    l_IsFunc := IsFunc(p_Func), p_Offset := Abs(p_Offset)
    If ( p_Count > (l_TotalTuples := l_Arr0 ** p_Pick) ) OR ( p_Count = 0 )
        p_Count := l_TotalTuples - p_Offset
    If ( p_Valid > l_TotalTuples ) OR ( p_Valid = 0 )
        p_Valid := p_Count
    Loop, %l_TotalTuples% {
        l_Result := ""
        Loop, %p_Pick%
            l_CharIndex := l_CharIndex%A_Index%, l_Result .= p_OutputDin l_Arr%l_CharIndex%
        Loop, %p_Pick% {
            l_Idx := p_Pick-(A_Index-1)
            If p_Reverse {
                If ( ( l_CharIndex%l_Idx% -= 1 ) >= 1 )
                    Break
                l_CharIndex%l_Idx% := l_Arr0
            }
            Else {
                If ( ( l_CharIndex%l_Idx% += 1 ) <= l_Arr0 )
                    Break
                l_CharIndex%l_Idx% := 1
            }
        }
        If ( A_Index-1 < p_Offset )
            Continue
        l_Result := SubStr(l_Result,1+StrLen(p_OutputDin)), l_Output .= l_IsFunc
            ? (((l_Dummy := %p_Func%(l_Result))<>"") ? (p_OutputDout l_Dummy, p_Valid--)
            : "") : (p_OutputDout l_Result, p_Valid--)
        If !( (--p_Count) AND p_Valid )
            Break
    }
    Return SubStr(l_Output,1+StrLen(p_OutputDout))
}