/*
 * Copyright (C) 2007, 2008, 2009 Windy Hill Technology LLC
 *
 * This file is part of Poker Shortcuts.
 *
 * Poker Shortcuts is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Poker Shortcuts is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FT Table Opener.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Project Home: http://code.google.com/p/pokershortcuts/
 */
 
 ; checks if there is another table on top of this table...  it won't detect if something else is on top (like a hud or lobby)
; we ignore other things, because HUDs are often on top of the table
; check if the 4 corners of the client area on on top for this winid
; returns 0 if on top
; returns 1 if any corner is not on visible
; IF you have to check more than 4 points on the table, then this function is faster than check more points with the WindowOnTopAtXY() function
WindowIsOverlayed(WinId)
{
      ; local  WindowIdList, WinId, WinX, WinY, WinW, WinH


      Margin := 20

      ; get the position info on our window in question
      WindowInfo(WindowX, WindowY, WindowW, WindowH, ClientW, ClientH, WindowTopBorder, WindowBottomBorder, WindowSideBorder, WinId)

      ; check the top left client area
      X := WindowX + WindowSideBorder + Margin
      Y := WindowY + WindowTopBorder  + Margin
      if (WinId != WindowOnTopAtXY(X,Y))
         return 1

      ; check the bottom right client area
      X := WindowX + WindowSideBorder + ClientW - Margin
      Y := WindowY + WindowTopBorder + ClientH - Margin
      if (WinId != WindowOnTopAtXY(X,Y))
         return 1

      ; check the bottom left client area
      X := WindowX + WindowSideBorder + Margin
      Y := WindowY + WindowTopBorder + ClientH - Margin
      if (WinId != WindowOnTopAtXY(X,Y))
         return 1

      ; check the top right client area
      X := WindowX + WindowSideBorder + ClientW - Margin
      Y := WindowY + WindowTopBorder +  Margin
      if (WinId != WindowOnTopAtXY(X,Y))
         return 1

      return 0
}


; check if the XY point (a screen positon) of WinId to see if it is covered
; returns 0 if this point is NOT overlayed and is on top
; returns 1 if this point is overlayed and is NOT on top
; If the covering object is a HUD listed in HudClassList, then that object will be ignored as it is usually see thru.
WindowIsOverlayedAtXY(X,Y,WinId)
{
      global
      local  WindowIdList, WinX, WinY, WinW, WinH, TestWinId, Class

      ; get a list of all windows on the user's computer
      WinGet, WindowIdList, List
      ; loop thru all of these Ids

      Loop, %WindowIdList%
      {
         ; get the next windows id
         TestWinId := WindowIdList%A_index%
         WinGetPos,WinX,WinY,WinW,WinH,ahk_id%TestWinId%

         ; see if our XY is in the range of this window TestWinId
         if ( (X >= WinX) AND (X <= (WinX + WinW)) AND (Y >= WinY) AND (Y <= (WinY + WinH)) )
         {
            ; if this testwinid is the same as the user's, then the user's window is on top at this point... return 0
            if (WinId == TestWinId)
               return 0

            ; check what the class is of this windows
            WinGetClass, Class, ahk_id%TestWinId%
            
            ; kludge fix for Holdem manager class names that are unique for each user.   we'll just shorten the class to 16 characters
            if instr(Class,"Afx:")
               StringLeft,Class,Class,16
            
            ; check if the class just identified is in our HudClassList, if so then continue on the find the next window
            ; we use instr here, because some of the class names in the list are abbreviated from the full class name (holdem manager creates unique class names for each user)
            if instr(HudClassList,Class)
               continue
               
            ; else it must be a something else on top of this XY position, so return 1 indicating that we are not on top
            return 1
         }

      }

      return 1
}


; finds the WinId of the window that is on top of the stack at position X,Y (screen position numbers) on the screen...
; if there is a HUD on top of our table (listed on the HudClassList), then that HUD will be ignored, and we continue on to find the top table
WindowOnTopAtXY(X,Y)
{
      global
      local  WindowIdList, WinId, WinX, WinY, WinW, WinH

      ; get a list of all windows on the user's computer
      WinGet, WindowIdList, List
      ; loop thru all of these dialog boxes and see if we need to operate on any of them

      Loop, %WindowIdList%
      {
         ; get the next windows id
         WinId := WindowIdList%A_index%
         WinGetPos,WinX,WinY,WinW,WinH,ahk_id%WinId%

         ; see if our XY is in the range of this window WinId, AND the WinId is a table
         ;if ( (X >= WinX) AND (X <= (WinX + WinW)) AND (Y >= WinY) AND (Y <= (WinY + WinH)) AND WinExist("ahk_group Tables ahk_id" . WinId)  )
         if ( (X >= WinX) AND (X <= (WinX + WinW)) AND (Y >= WinY) AND (Y <= (WinY + WinH)) )
         {
         
            ; check what the class is of this windows
            WinGetClass, Class, ahk_id%WinId%
            

            ; kludge fix for Holdem manager class names that are unique for each user.   we'll just shorten the class to 16 characters
            if instr(Class,"Afx:")
               StringLeft,Class,Class,16
            
            ; check if the class just identified is in our HudClassList, if so then continue on the find the next window
            ; we use instr here, because some of the class names in the list are abbreviated from the full class name (holdem manager creates unique class names for each user)
            if instr(HudClassList,Class)
               continue
         
            return WinId
         }
      }

      return 0
}


; finds the Class of window that is on top at XY (screen positions)
ClassOnTopAtXY(X,Y)
{
      ; local  WindowIdList, WinId, WinX, WinY, WinW, WinH, Class

      ; get a list of all windows on the user's computer
      WinGet, WindowIdList, List
      ; loop thru all of these dialog boxes and see if we need to operate on any of them

      Loop, %WindowIdList%
      {
         ; get the next windows id
         WinId := WindowIdList%A_index%
         WinGetPos,WinX,WinY,WinW,WinH,ahk_id%WinId%

         ; see if our XY is in the range of this window WinId, AND the WinId is a table
         ;if ( (X >= WinX) AND (X <= (WinX + WinW)) AND (Y >= WinY) AND (Y <= (WinY + WinH)) AND WinExist("ahk_group Tables ahk_id" . WinId)  )
         if ( (X >= WinX) AND (X <= (WinX + WinW)) AND (Y >= WinY) AND (Y <= (WinY + WinH)) )
         {
            WinGetClass, Class, ahk_id%WinId%
            return Class
         }
      }

      return ""
}
