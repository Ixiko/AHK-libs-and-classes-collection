/*
WindowScaledPos()
   Purpose: This function scales PosX,PosY for the current window size
      to find the new position coordinates for a different size table (compared to the
      standard Client window size)
      If the window is a poker table, then the XY position is scaled proportionally to a standard size table, based on what the current table size is.
      If the window is not a poker table, then no scaling takes place
   Requires:
      nothing special
   Returns:
      nothing
   Parameters:
      ByRef PosX: Client window x position... returns scaled position
      ByRef PosY: Client window y position... returns scaled position
      ByRef ClientScaleFactor: not needed in fcn... returns the table scale factor for current table
               (note: the horiz and vertical scale factors are about the same, so we just return 1 of them - width one)
      ScaleType:
         if = "Window", then return position relative to the WinId window
         if = "Screen", then return position relative to the screen
         if = "Client", then return position relative to the client area of WinId
      WinId: window id.
*/
WindowScaledPos(ByRef PosX, ByRef PosY, ByRef ClientScaleFactor, ScaleType="Screen", WinId=""){
   global   ; we need some settings   %CasinoName%StandardClientWidth, %CasinoName%StandardClientHeight

   local TitleBarHeight, WindowBottomBorder, WindowSideBorder, WindowTopBorder ,WindowX,WindowY,WindowWidth,WindowHeight
   local ClientWidth, ClientHeight , ClientWidthScaleFactor, ClientHeightScaleFactor
   local CasinoName

   if NOT (CasinoName := CasinoName(WinId,A_ThisFunc))
      return


   SysGet, TitleBarHeight, 4

   SysGet, WindowBottomBorder, 32
   SysGet, WindowSideBorder, 33

   WindowTopBorder := TitleBarHeight + WindowBottomBorder

   ; get the current window info (includes borders)
   WinGetPos,WindowX,WindowY,WindowWidth,WindowHeight,ahk_id%WinId%


   ; if this is a poker table, then scale the XY position based on the size of the current table to a standard table size
   ifWinExist, ahk_id%WinId%  ahk_group Tables
   {
      ; calc the Client area in this window (window - borders)
      ClientWidth := WindowWidth - 2 * WindowSideBorder
      ClientHeight := WindowHeight - TitleBarHeight - 2 * WindowBottomBorder
   
   
   
      ; calculate the current Client area scale factors
      ClientWidthScaleFactor := ClientWidth / %CasinoName%StandardClientWidth
      ClientHeightScaleFactor := ClientHeight / %CasinoName%StandardClientHeight
   
   ;outputdebug, scale factors  %ClientWidthScaleFactor%, %ClientHeightScaleFactor%
   
   
      ClientScaleFactor := ClientWidthScaleFactor     ; pass back the scaling factor in case the calling function needs it
   
      ; scale the positions within the client area
      PosX := Round(PosX * ClientWidthScaleFactor)
      PosY := Round(PosY * ClientHeightScaleFactor)
   }
   
   
   if (ScaleType == "Client")
   {
      return
   }
   ; if position is needed relative to the window, then add in the borders of the window
   else if (ScaleType == "Window")
   {
      PosX += WindowSideBorder
      PosY += WindowTopBorder
   }

   ; if position is needed relative to the screen, then add in borders and the screen position of the window
   else if (ScaleType == "Screen")
   {
      PosX += WindowX + WindowSideBorder
      PosY += WindowY + WindowTopBorder
   }



;outputdebug, in windowscaledpos   CasinoName:%CasinoName%   X%PosX%  Y%PosY%   WScaleFactor%ClientWidthScaleFactor%   HScaleFactor%ClientHeightScaleFactor%   TopBorder%WindowTopBorder%   SideBorder%WindowSideBorder%
}
; -----------------------------------------------------------------------------------------