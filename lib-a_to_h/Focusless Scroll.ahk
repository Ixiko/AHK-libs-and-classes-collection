;http://www.autohotkey.com/forum/topic6772.html
;FocuslessScroll: This code activates the window under the mouse whenever there is a scroll wheel movement.
/*
;Directives
#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 100 ;Avoid warning when mouse wheel turned very fast

;Autoexecute code
CoordMode, Mouse, Screen
MinLinesPerNotch := 1
MaxLinesPerNotch := 5
AccelerationThreshold := 100
AccelerationType := "L" ;Change to "P" for parabolic acceleration
StutterThreshold := 10

;All hotkeys can use the same instance of FocuslessScroll(). No need to have separate calls unless each hotkey requires different parameters (e.g. you want to disable acceleration for Ctrl-WheelUp and Ctrl-WheelDown). If you want a single set of parameters for all scrollwheel actions, you can simply use *WheelUp:: and *WheelDown:: instead.

WheelUp::
^WheelUp:: ;zooms in
WheelDown::
^WheelDown:: ;zoom out
   FocuslessScroll(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold)
Return
So, I came back to this thread, and started using the following script SUCCESSFULLY with FF 4.0: :lol:

;http://www.autohotkey.com/forum/topic6772.html
;FocuslessScroll: This code activates the window under the mouse whenever there is a scroll wheel movement.

Wheelup::
   SetMouseDelay, -1
   MouseGetPos,,,hovwin,hovcontrol
   WinGetClass, hovclass, ahk_id %hovwin%
   IfWinNotActive, ahk_id %hovwin%
      if hovclass <> #32769
      {
         WinActivate ahk_id %hovwin%
         ControlFocus %hovcontrol%, ahk_id %hovwin%
         return
      }
   mouseclick, wheelup
return
Wheeldown::
   SetMouseDelay, -1
   MouseGetPos,,,hovwin,hovcontrol
   WinGetClass, hovclass, ahk_id %hovwin%
   IfWinNotActive, ahk_id %hovwin%
      if hovclass <> #32769
      {
         WinActivate ahk_id %hovwin%
         ControlFocus %hovcontrol%, ahk_id %hovwin%
         return
      }
   mouseclick, wheeldown
return
*/

;Function definitions

;See above for details on parameters
FocuslessScroll(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold) {
   Critical ;Buffer all missed scrollwheel input to prevent missing notches
   SetBatchLines, -1 ;Run as fast as possible

   ;Stutter filter: Prevent stutter caused by cheap mice by ignoring successive WheelUp/WheelDown events that occur to close together.
   If(A_TimeSincePriorHotkey < StutterThreshold) ;Quickest succession time in ms
      If(A_PriorHotkey = "WheelUp" Or A_PriorHotkey ="WheelDown")
         Return

   MouseGetPos, m_x, m_y
   m_x &= 0xFFFF

   MouseGetPos,,,, ControlClass2, 2
   MouseGetPos,,,, ControlClass3, 3

   ControlClass1 := DllCall("WindowFromPoint", "int", m_x, "int", m_y)
   ;64-bit systems use this line
   ;ControlClass1 := DllCall( "WindowFromPoint", "int64", m_x | (m_y << 32), "Ptr")

   lParam := (m_y << 16) | m_x
   wParam := (120 << 16) ;Wheel delta is 120, as defined by MicroSoft

   ;Detect WheelDown event
   If(A_ThisHotkey = "WheelDown" Or A_ThisHotkey = "^WheelDown" Or A_ThisHotkey = "+WheelDown" Or A_ThisHotkey = "*WheelDown")
      wParam := -wParam ;If scrolling down, invert scroll direction

   ;Detect modifer keys held down (only Shift and Control work)
   If(GetKeyState("Shift","p"))
      wParam := wParam | 0x4
   If(GetKeyState("Ctrl","p"))
      wParam := wParam | 0x8

   ;If you don't need scroll acceleration, you can simply remove the LinesPerNotch() function def and set Lines := 1. Additionally you will want to strip out all the related unused function parameters.
   Lines := LinesPerNotch(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType)

   ;Run this loop several times to create the impression of faster scrolling
   Loop, %Lines%
   {
      If(ControlClass2 = "")
         SendMessage, 0x20A, wParam, lParam,, ahk_id %ControlClass1%
      Else
      {
         SendMessage, 0x20A, wParam, lParam,, ahk_id %ControlClass2%
         If(ControlClass2 != ControlClass3)
            SendMessage, 0x20A, wParam, lParam,, ahk_id %ControlClass3%
      }
   }
}

LinesPerNotch(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType) {
   T := A_TimeSincePriorHotkey

   ;Normal slow scrolling, separationg between scroll events is greater than AccelerationThreshold miliseconds.
   If((T > AccelerationThreshold) Or (T = -1)) ;T = -1 if this is the first hotkey ever run
   {
      Lines := MinLinesPerNotch
   }
   ;Fast scrolling, use acceleration
   Else
   {
      If(AccelerationType = "P")
      {
         ;Parabolic scroll speed curve
         ;f(t) = At^2 + Bt + C
         A := (MaxLinesPerNotch-MinLinesPerNotch)/(AccelerationThreshold**2)
         B := -2 * (MaxLinesPerNotch - MinLinesPerNotch)/AccelerationThreshold
         C := MaxLinesPerNotch
         Lines := Round(A*(T**2) + B*T + C)
      }
      Else
      {
         ;Linear scroll speed curve
         ;f(t) = Bt + C
         B := (MinLinesPerNotch-MaxLinesPerNotch)/AccelerationThreshold
         C := MaxLinesPerNotch
         Lines := Round(B*T + C)
      }
   }
   Return Lines
}

