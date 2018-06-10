/*
    RomanNumbers.ahk
    Copyright (C) 2010,2012 Antonio França

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
; Functions:    Dec2Roman & Roman2Dec
; Description:  Functions to perform convertions between roman and decimal
; URL (+info):  http://bit.ly/RoIP9H
;
; Last Update:  17/august/2012 19:50 BRT
;
; Created by MasterFocus
; - https://github.com/MasterFocus
; - http://masterfocus.ahk4.net
; - http://autohotkey.com/community/viewtopic.php?f=2&t=88198
;
;========================================================================

Dec2Roman(p_Number,p_AllowNegative=false) {
  If p_Number is not integer
    Return 0
  If (p_Number=0 OR (p_Number<0 AND !p_AllowNegative))
    Return 0
  p_Number := p_Number<0 ? (Abs(p_Number),l_Signal:="-") : p_Number
  static st_Romans := "[M] [C][M] [D] [C][D] [C] [X][C] [L] [X][L] [X] M[X] [V] M[V] M CM D CD C XC L XL X IX V IV I"
  ,st_[M]:=1000000,st_[C][M]:=900000,st_[D]:=500000,st_[C][D]:=400000,st_[C]:=100000,st_[X][C]:=90000,st_[L]:=50000
  ,st_[X][L]:=40000,st_[X]:=10000,st_M[X]:=9000,st_[V]:=5000,st_M[V]:=4000,st_M:=1000,st_CM:=900,st_D:=500,st_CD:=400
  ,st_C:=100,st_XC:=90,st_L:=50,st_XL:=40,st_X:=10,st_IX:=9,st_V:=5,st_IV:=4,st_I:=1
  Loop Parse, st_Romans, %A_Space%
    While ( p_Number >= st_%A_LoopField% )
      l_String .= A_LoopField , p_Number -= st_%A_LoopField%
  Return l_Signal l_String
}

;---------------------------------------------------------------

Roman2Dec(p_RomanStr,p_AllowNegative=false) {
  static st_Romans := "[M] [C][M] [D] [C][D] [C] [X][C] [L] [X][L] [X] M[X] [V] M[V] M CM D CD C XC L XL X IX V IV I"
  ,st_[M]:=1000000,st_[C][M]:=900000,st_[D]:=500000,st_[C][D]:=400000,st_[C]:=100000,st_[X][C]:=90000,st_[L]:=50000
  ,st_[X][L]:=40000,st_[X]:=10000,st_M[X]:=9000,st_[V]:=5000,st_M[V]:=4000,st_M:=1000,st_CM:=900,st_D:=500,st_CD:=400
  ,st_C:=100,st_XC:=90,st_L:=50,st_XL:=40,st_X:=10,st_IX:=9,st_V:=5,st_IV:=4,st_I:=1
  StringReplace, l_Needle, st_Romans, [, \[, All
  StringReplace, l_Needle, l_Needle, % " ", |, All
  If ( !RegExMatch( p_RomanStr , "i)^(-?)(" l_Needle ")+$" , l_Match ) || ErrorLevel
       || ( ( l_Match1 = "-" ) AND !p_AllowNegative ) )
    Return 0
  StringReplace, l_Match, l_Match, %l_Match1%, , All
  l_Previous := l_Match2
  While ( l_Match <> "" ) {
    StringRight, l_Removed, l_Match, 1
    StringTrimRight, l_Match, l_Match, 1
    If ( l_Removed = "]" ) {
      StringRight, l_Match2, l_Match, 2
      StringTrimRight, l_Match, l_Match, 2
      l_Removed := l_Match2 l_Removed
    }
    If ( st_%l_Removed% < st_%l_Previous% ) {
      l_Match2 := l_Removed l_Previous
      If ( st_%l_Previous% - st_%l_Removed% <> st_%l_Match2% )
        Return 0
      l_Sum -= ( st_%l_Removed% )
    }
    Else
      l_Sum += ( st_%l_Removed% ) , l_Previous := l_Removed
  }
  Return l_Match1 l_Sum
}