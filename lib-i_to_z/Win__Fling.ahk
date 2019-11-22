;; -----------------------------------------------------------------------
;; Fling (or shift) a window from one monitor to the next in a multi-monitor system.
;;
;; Function Parameters:
;;
;;      FlingDirection      The direction of the fling, expected to be either +1 or -1.
;;                     The function is not limited to just two monitors; it supports
;;                     as many monitors as are currently connected to the system and
;;                     can fling a window serially through each of them in turn.
;;
;;      WinID            The window ID of the window to move. There are two special WinID
;;                     values supported:
;;
;;                     1) The value "A" means to use the Active window (default).
;;                     2) The value "M" means to use the window currently under the Mouse.
;;
;; The flinged window will be resized to have the same *relative* size in the new monitor.
;; For example, if the window originally occupied the entire right half of the screen,
;; it will again on the new monitor (assuming the window can be resized).
;;
;; Minimized windows are not modified; they are left exactly where they were.
;;
;; The return value of the function is non-zero if the window was successfully flung.
;;
;; Example hotkeys:
;;   #NumpadEnter::   Win__Fling(1, "A")   ; Windows-NumpadEnter flings the active window
;;   #LButton::      Win__Fling(1, "M")   ; Windows-LeftClick flings the window under the mouse
;;
;; Copyright (c) 2010 Patrick Sheppard
;; All Rights Reserved

Win__Fling(FlingDirection = 1, WinID = "A")
{
   ; Figure out which window to move based on the "WinID" function parameter:
   ;   1) The letter "A" means to use the Active window
   ;   2) The letter "M" means to use the window under the Mouse
   ; Otherwise, the parameter value is assumed to be the AHK window ID of the window to use.

   if (WinID = "A")
   {
      ; If the user supplied an "A" as the window ID, we use the Active window
      WinID := WinExist("A")
   }
   else if (WinID = "M")
   {
      ; If the user supplied an "M" as the window ID, we use the window currently under the Mouse
      MouseGetPos, MouseX, MouseY, WinID      ; MouseX & MouseY are retrieved but, for now, not used
   }

   ; Check to make sure we are working with a valid window
   IfWinNotExist, ahk_id %WinID%
   {
      ; Make a short noise so the user knows to stop expecting something fun to happen.
      SoundPlay, *64
      
      ; Debug Support
      ;MsgBox, 16, Window Fling: Error, Specified window does not exist.`nWindow ID = %WinID%

      return 0
   }

   ; Here's where we find out just how many monitors we're dealing with
   SysGet, MonitorCount, MonitorCount

   if (MonitorCount <= 1)
   {
      ; Honestly, there's not much to do in a one-monitor system
      return 1
   }

   ; For each active monitor, we get Top, Bottom, Left, Right of the monitor's
   ;  'Work Area' (i.e., excluding taskbar, etc.). From these values we compute Width and Height.
   ;  Results get put into variables named like "Monitor1Top" and "Monitor2Width", etc.,
   ;  with the monitor number embedded in the middle of the variable name.

   Loop, %MonitorCount%
   {
      SysGet, Monitor%A_Index%, MonitorWorkArea, %A_Index%
      Monitor%A_Index%Width  := Monitor%A_Index%Right  - Monitor%A_Index%Left
      Monitor%A_Index%Height := Monitor%A_Index%Bottom - Monitor%A_Index%Top
   }

   ; Retrieve the target window's original minimized / maximized state
   WinGet, WinOriginalMinMaxState, MinMax, ahk_id %WinID%

   ; We don't do anything with minimized windows (for now... this may change)
   if (WinOriginalMinMaxState = -1)
   {
      ; Debatable as to whether or not this should be flagged as an error
      return 0
   }
   
   ; If the window started out maximized, then the plan is to:
   ;   (a) restore it,
   ;   (b) fling it, then
   ;   (c) re-maximize it on the target monitor.
   ;
   ; The reason for this is so that the usual maximize / restore windows controls
   ; work as you'd expect. You want Windows to use the dimensions of the non-maximized
   ; window when you click the little restore icon on a previously flung (maximized) window.
   
   if (WinOriginalMinMaxState = 1)
   {
      ; Restore a maximized window to its previous state / size ... before "flinging".
      ;
      ; Programming Note: It would be nice to hide the window before doing this ... 
      ; the window does some visual calisthenics that the user may construe as a bug.
      ; Unfortunately, if you hide a window then you can no longer work with it. <Sigh>

      WinRestore, ahk_id %WinID%
   }

   ; Retrieve the target window's original (non-maximized) dimensions
   WinGetPos, WinX, WinY, WinW, WinH, ahk_id %WinID%

   ; Find the point at the centre of the target window then use it
   ; to determine the monitor to which the target window belongs
   ; (windows don't have to be entirely contained inside any one monitor's area).
   
   WinCentreX := WinX + WinW / 2
   WinCentreY := WinY + WinH / 2

   CurrMonitor = 0
   Loop, %MonitorCount%
   {
      if (    (WinCentreX >= Monitor%A_Index%Left) and (WinCentreX < Monitor%A_Index%Right )
          and (WinCentreY >= Monitor%A_Index%Top ) and (WinCentreY < Monitor%A_Index%Bottom))
      {
         CurrMonitor = %A_Index%
         break
      }
   }

   ; Compute the number of the next monitor in the direction of the specified fling (+1 or -1)
   ;  Valid monitor numbers are 1..MonitorCount, and we effect a circular fling.
   NextMonitor := CurrMonitor + FlingDirection
   if (NextMonitor > MonitorCount)
   {
      NextMonitor = 1
   }
   else if (NextMonitor <= 0)
   {
      NextMonitor = %MonitorCount%
   }

   ; Scale the position / dimensions of the target window by the ratio of the monitor sizes.
   ; Programming Note: Do multiplies before divides in order to maintain accuracy in the integer calculation.
   WinFlingX := (WinX - Monitor%CurrMonitor%Left) * Monitor%NextMonitor%Width  // Monitor%CurrMonitor%Width  + Monitor%NextMonitor%Left
   WinFlingY := (WinY - Monitor%CurrMonitor%Top ) * Monitor%NextMonitor%Height // Monitor%CurrMonitor%Height + Monitor%NextMonitor%Top
   WinFlingW :=  WinW                        * Monitor%NextMonitor%Width  // Monitor%CurrMonitor%Width
   WinFlingH :=  WinH                        * Monitor%NextMonitor%Height // Monitor%CurrMonitor%Height
   ;steps  := abs(WinFlingX-WinX)/100
   ;stepsize := (WinFlingX - WinX)/steps
   ;WinStepX := WinX
   ; It's time for the target window to make its big move
  ; loop %steps% {
	;	WinStepX := stepsize + WinStepX
	;	WinMove, ahk_id %WinID%,, WinStepX, WinFlingY, WinFlingW, WinFlingH
	;	}
	WinMove, ahk_id %WinID%,, WinFlingX, WinFlingY, WinFlingW, WinFlingH

   ; If the window used to be maximized, maximize it again on its new monitor
   if (WinOriginalMinMaxState = 1)
   {
      WinMaximize, ahk_id %WinID%
   }

   return 1
}