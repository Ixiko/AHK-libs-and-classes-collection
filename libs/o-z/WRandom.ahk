/*
    WRandom.ahk
    Copyright (C) 2009,2012 Antonio França

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
; Function:     WRandom
; Description:  Gets a random field from a weighted set
; Old version:  http://www.autohotkey.com/forum/viewtopic.php?t=47586
;
; Last Update:  13/July/2012 15:00 BRT
;
; Created by MasterFocus
; - https://github.com/MasterFocus
; - http://masterfocus.ahk4.net
; - http://autohotkey.com/community/viewtopic.php?f=2&t=88198
;
; Based on original code/algorithm by [VxE]
; - www.autohotkey.com/forum/viewtopic.php?p=287940#287940
;
;========================================================================

WRandom(p_FieldStr,ByRef out_Chance=0,ByRef out_P2D=0,ByRef out_D2P=0) {
  Loop, Parse, p_FieldStr, `,
    l_Total += A_LoopField
  Random, l_RandomSum, 0, % l_Total
  Loop, Parse, p_FieldStr, `,
    If ( 0 >= l_RandomSum -= A_LoopField )
      Return A_Index, out_Chance := 100*A_LoopField/l_Total, 
      out_P2D := l_Total/100, out_D2P := 100/l_Total
}