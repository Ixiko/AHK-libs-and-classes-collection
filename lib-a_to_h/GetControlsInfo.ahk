/*
    GetControlsInfo.ahk
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
; Function:     GetControlsInfo
; Description:  Retrieves name, HWND, position, width and height
; URL (+info):  http://bit.ly/Q9Ddcs
;
; Last Update:  11/august/2012 23:50 BRT
;
; Created by MasterFocus
; - https://github.com/MasterFocus
; - http://masterfocus.ahk4.net
; - http://autohotkey.com/community/viewtopic.php?f=2&t=88198
;
; Thanks to SKAN for the original initial code responding a request
; - http://autohotkey.com/community/viewtopic.php?p=272857#p272857
;
;========================================================================

GetControlsInfo(p_WinTitle="",p_WinText="",p_ExcludeTitle="",p_ExcludeText="") {
  If ( ( p_WinTitle . p_WinText . p_ExcludeTitle . p_ExcludeText ) = "" )
    p_WinTitle := "A"
  l_ahkID := "ahk_id " WinExist(p_WinTitle,p_WinText,p_ExcludeTitle,p_ExcludeText)
  WinGet, l_List, ControlList, %ahkID%
  Loop, Parse, l_List, `n
  {
    ControlGetPos, l_X, l_Y, l_W, l_H, %A_LoopField%, %l_ahkID%
    ControlGet, l_Hwnd, Hwnd,, %A_LoopField%, %l_ahkID%
    l_Info .= "`n" A_LoopField "|" l_Hwnd "|x" l_X "|y" l_Y "|w" l_W "|h" l_H
  }
  Return SubStr(l_Info,2)
}