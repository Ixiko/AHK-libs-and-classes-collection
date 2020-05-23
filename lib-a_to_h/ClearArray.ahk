/*
    RegExSort.ahk
    Copyright (C) 2010 Antonio França

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
; Function:     ClearArray
; Description:  Clears array elements (makes them become empty)
;
; Last Update:  16/March/2010 19:00 BRT
;
; Created by MasterFocus
; - https://github.com/MasterFocus
; - http://masterfocus.ahk4.net
; - http://autohotkey.com/community/viewtopic.php?f=2&t=88198
;
; Thanks to SKAN, Laszlo, PhiLho and Titan (aka polyethene) for VarExist()
; - http://autohotkey.com/community/viewtopic.php?p=83371#p83371
;
;========================================================================

ClearArray(p_ArrayName,p_Start=0,p_End=0)
{
  local l_tmp, l_count
  If ( p_Start < 0 ) OR ( p_End < 0 ) OR ( p_End > p_Start )
    Return 2
  If !p_End
    Loop {
      tmp := p_ArrayName . p_Start
      If !varExist(%tl_tmp%)
        Break
      %l_tmp% := "" , l_count++ , p_Start++
    }
  Else
    Loop {
      %p_ArrayName%%p_Start% := "" , l_count++
      If ( p_Start = p_End )
        Break
      p_Start++
    }
  Return !l_count
}
varExist(ByRef v) {
   return &v = &n ? 0 : v = "" ? 2 : 1
}