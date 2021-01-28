/*
    RandomVar.ahk
    Copyright (C) 2009 Antonio França

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
; Function:     RandomVar
; Description:  Returns a random content (with optional type)
; URL (+info):  http://bit.ly/QJUt8A
;
; Last Update:  25/August/2009 01:30 BRT
;
; Created by MasterFocus
; - https://github.com/MasterFocus
; - http://masterfocus.ahk4.net
; - http://autohotkey.com/community/viewtopic.php?f=2&t=88198
;
;========================================================================

RandomVar(p_MinLength,p_MaxLength,p_Type="",p_MinAsc=32,p_MaxAsc=126)
{
; Old method, using RegExReplace - slower and harder to understand
; p_Type := RegExReplace(RegExReplace(RegExReplace(p_Type,"!","",l_Neg),"#","@",l_Cse),"@","",l_Rep)
; New method, using StringReplace - better in performance and readability
  StringReplace,p_Type,p_Type,!,,All
  l_Neg := !ErrorLevel
  StringReplace,p_Type,p_Type,#,@,All
  l_Cse := !ErrorLevel
  StringReplace,p_Type,p_Type,@,,All
  l_Rep := !ErrorLevel
  Random, l_Aux, %p_MinLength%, %p_MaxLength%
  Loop, %l_Aux% {
    Loop {
      Random, l_Aux, %p_MinAsc%, %p_MaxAsc%
      l_Aux := Chr(l_Aux)
      If ( !l_Rep ) OR ( l_Rep AND !InStr(l_Output,l_Aux,l_Cse) ) {
        If p_Type not in integer,number,digit,xdigit,alpha,upper,lower,alnum,space
          break
        Else
          If l_Neg {
            If l_Aux is not %p_Type%
              break
          }
          Else
            If l_Aux is %p_Type%
              break
      }
    }
    l_Output .= l_Aux
  }
  return l_Output
}