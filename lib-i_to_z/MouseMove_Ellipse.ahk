/*
    MouseMove_Ellipse.ahk
    Copyright (C) 2010,2013 Antonio França

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
; MouseMove_Ellipse
;   http://bit.ly/YNKpPy | https://github.com/MasterFocus/AutoHotkey
;
; Moves the mouse using an ellipse instead of a straight line
;
; Created by MasterFocus
;   https://git.io/master | http://masterfocus.ahk4.net
;
; Last Update: 2013-03-06 07:00 BRT
;
; Based on previous work by Wicked
;   http://autohotkey.com/board/topic/56830-function-mousemove-ellipse-91210/
;
;========================================================================

MouseMove_Ellipse(pos_X1, pos_Y1, param_Options="") {

    StringUpper, param_Options, param_Options

    MouseGetPos, loc_MouseX, loc_MouseY ; Use mouse coordinates if origin is omitted
    pos_X0 := !RegExMatch(param_Options,"i)OX\d+",loc_Match) ? loc_MouseX : SubStr(loc_Match,3)
    pos_Y0 := !RegExMatch(param_Options,"i)OY\d+",loc_Match) ? loc_MouseY : SubStr(loc_Match,3)

    ; set speed (default is 1)
    loc_Speed := !RegExMatch(param_Options,"i)S\d+\.?\d*",loc_Match) ? 1 : SubStr(loc_Match,2)

    If !RegExMatch(param_Options,"i)I[01]",loc_Match)
        Random, loc_Inv, 0, 1 ; randomly invert by default
    Else
        loc_Inv := SubStr(loc_Match,2)

    If InStr(param_Options,"R") ; support relative movements
        pos_X1 += pos_X0  ,  pos_Y1 += pos_Y0

    If ( loc_Block := InStr(param_Options,"B") ) ; Block any mouse input
        BlockInput, Mouse

    loc_B := Abs(pos_X0-pos_X1) , loc_A := Abs(pos_Y0-pos_Y1) ; B: Width , A: Height

    loc_Temp := loc_Inv ^ (pos_X0<pos_X1) ^ (pos_Y0<pos_Y1)
    loc_H := pos_X%loc_Temp% ; Center point X
    loc_Temp := !loc_Temp
    loc_K := pos_Y%loc_Temp% ; Center point Y

    loc_MDelay := A_MouseDelay ; Save current mouse delay before changing it
    SetMouseDelay, 1

    If ( loc_B > loc_A ) { ; If distance from pos_X0 to pos_X1 is greater then pos_Y0 to pos_Y1
        loc_MultX := ( pos_X0 < pos_X1 ) ? 1 : (-1)
        loc_MultY := loc_MultX * ( loc_Inv ? 1 : (-1) )
        Loop, % ( loc_B / loc_Speed ) {
            loc_X := pos_X0 + ( A_Index * loc_Speed * loc_MultX ) ; Add or subtract loc_Speed from X
            loc_Y := ( loc_MultY * Sqrt(loc_A**2*((loc_X-loc_H)**2/loc_B**2-1)*-1) ) + loc_K ; Formula for Y with a given X
            MouseMove, %loc_X%, %loc_Y%, 0
        }
    } Else { ; If distance from pos_Y0 to pos_Y1 is greater then pos_X0 to pos_X1
        loc_MultY := ( pos_Y0 < pos_Y1 ) ? 1 : (-1)
        loc_MultX := loc_MultY * ( loc_Inv ? (-1) : 1 )
        Loop, % ( loc_A / loc_Speed ) {
            loc_Y := pos_Y0 + ( A_Index * loc_Speed * loc_MultY ) ; Add or subtract loc_Speed from Y
            loc_X := ( loc_MultX * Sqrt(loc_B**2*(1-(loc_Y-loc_K)**2/loc_A**2)) ) + loc_H ; Formula for X with a given Y
            MouseMove, %loc_X%, %loc_Y%, 0 ; Move mouse to new position
        }
    }

    ; Sometimes loop would end with mouse more than "loc_Speed" pixels away from pos_X1,pos_Y1
    MouseMove, %pos_X1%, %pos_Y1%, 0

    If ( loc_Block )
        BlockInput, Off

    SetMouseDelay, %loc_MDelay% ; Restore previous mouse delay

}
