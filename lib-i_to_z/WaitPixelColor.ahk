/*
    WaitPixelColor.ahk
    Copyright (C) 2009,2012 Antonio França

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
; WaitPixelColor
;   https://bit.ly/R7gT8a | https://github.com/MasterFocus/AutoHotkey
;
; Waits until a pixel is a certain color (w/ optional timeout)
;
; Created by MasterFocus
;   https://git.io/master | http://masterfocus.ahk4.net
;
; Last Update: 2012-09-06 09:00 BRT
;
;========================================================================

WaitPixelColor(p_DesiredColor,p_PosX,p_PosY,p_TimeOut=0,p_GetMode="",p_ReturnColor=0) {
    l_Start := A_TickCount
    Loop {
        PixelGetColor, l_OutputColor, %p_PosX%, %p_PosY%, %p_GetMode%
        If ( ErrorLevel )
            Return ( p_ReturnColor ? l_OutputColor : 1 )
        If ( l_OutputColor = p_DesiredColor )
            Return ( p_ReturnColor ? l_OutputColor : 0 )
        If ( p_TimeOut ) && ( A_TickCount - l_Start >= p_TimeOut )
            Return ( p_ReturnColor ? l_OutputColor : 2 )
    }
}
