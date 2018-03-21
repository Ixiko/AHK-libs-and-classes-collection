;http://www.autohotkey.com/forum/topic6290.html

; ---- Taskbar Clock v1.2 ---- ;
#NoTrayIcon                ; Save space w/o icon/menu
Process Priority,,High
SetWinDelay 0
SetKeyDelay -1
BlockInput Send

;----- edit here for best look -----

ClockX    = 0              ; Left edge of the clock
FieldW    = 179            ; Width of the clock and progress bars (fit to taskbar)
ProgressH = 8              ; Height of the progress bars

ProcLoadY = 164           ; Y coordinate of the processor load bar
ProcColor = Black

ClockColor= White          ; Background
ClockFColr= Black          ; Font
ClockFont = Arial Narrow
ClockPts  = 13
ClockStyle= bold

ClockPatt = M/dd  ddd  hh:mm:ss
ClockPaste= h:mm:ss tt     ; Time format pasted
ClockY   := ProcLoadY + ProgressH
ClockH    = 23             ; Height of the clock
DtX       = 2              ; DateTime margin from left
DtY       = -2             ; ... from top

MonthColor= FF0000         ; Boarder
MonthFColr= Black          ; Font
MonthFont = Arial
MonthPts  = 12
MonthStyle=
MonthBordr= 4
MonthX    = 180            ; Left edge of the calendar
MonthY    = 890            ; Top ...
MonthPaste= MMMM d, yyyy

MemLoadY := ClockY + ClockH - 1
MemColor  = Red

;----- code starts here -----

VarSetCapacity( IdleTicks,    2*4 )
VarSetCapacity( memorystatus, 100 )
hw_tray := DllCall( "FindWindowEx", "uint",0, "uint",0, "str","Shell_TrayWnd", "uint",0 )

Menu ClockMenu, Add, &Adjust Date/Time, DTSet
Menu ClockMenu, Add, &Copy Date/Time, DTcopy
Menu ClockMenu, Add, E&xit,  7GuiClose
Menu ClockMenu, Add, Canc&el,DTCancel

Progress 1:b x%X0% y%ProcLoadY% w%FieldW% ZX-2 ZY0 ZH%ProgressH% CB%ProcColor%
GoSub Dock2TaskBar
Progress 2:b x%X0% y%MemLoadY% w%FieldW% ZX-2 ZY0 ZH%ProgressH% CB%MemColor%
GoSub Dock2TaskBar

Gui 7:-Caption ToolWindow ; no title, no taskbar icon
Gui 7:Color, %ClockColor%
Gui 7:font, S%ClockPts% %ClockStyle% c%ClockFColr%, %ClockFont%
Gui 7:Add, Text, x%DtX% y%DtY% vDT, __________________
Gui 7:Show, x%ClockX% y%ClockY% h%ClockH% w%FieldW%, Clock
WinActivate Clock
GoSub Dock2TaskBar
WinGet ClockID, ID, A      ; ID of Clock window

Gui 8:-Caption +AlwaysOnTop ToolWindow +Owner7
Gui 8:Margin, %MonthBordr%, %MonthBordr%
Gui 8:Color, %MonthColor%
Gui 8:Font, S%MonthPts% %MonthStyle% c%MonthFColr%, %MonthFont%
Gui 8:Add, MonthCal, AltSubmit g8Month vMonth

SetTimer ClockUpdate, 1000 ; Update bars, redraw clock, tooltip
OnMessage(0x200,"Hover7")  ; 0x200 = WM_MOUSEMOVE instead of WM_MOUSEHOVER -> MAIN AHK
OnMessage(0x201,"LClick7") ; 0x201 = WM_LBUTTONDOWN -> MAIN AHK

DTCancel:                  ; Do nothing in popup menu
Return

7GuiContextMenu:           ; Right click popup menu
   ToolTip                 ; Erase
   Menu ClockMenu, Show    ; Show context menu
Return

7GuiClose:                 ; Exit
ExitApp                    ; Terminate

8Month:                    ; Click on a date
   If (MonthTick > A_TickCount - 300)
   {                       ; Click again shortly after last click
      FormatTime date, %Month%, %MonthPaste%
      Send !{TAB}%date%    ; Paste date to last window
      Gui 8:Show
   }
   Else                    ; Remember time of last click
      MonthTick = %A_TickCount%
   Sleep 50                ; Prevent problems with double gLabel activations
Return

8GuiEscape:                ; ESC hides calendar
   Gui 8:Hide
Return

LClick7()                  ; CALENDAR
{
   Global MonthX, MonthY, ClockTick, ClockPaste
   IfNotEqual A_Gui,7, Return
   If (ClockTick > A_TickCount - 300)
   {                       ; Click again shortly after last click
      FormatTime t,,%ClockPaste%
      Send !{TAB}%t%       ; Paste time to last window
      Gui 8:Hide           ; Remove calendar
      Return
   }
   ClockTick=%A_TickCount% ; Remember time of last click
   GuiControlGet VisibleMonth, 8:Visible, Month
   if (A_GuiControl <> "Month")
      if VisibleMonth      ; Toggle visibility
         Gui 8:Hide
      else
         Gui 8:Show, x%MonthX% y%MonthY%
}

DTSet:                     ; Adjust date and time
   Run timedate.cpl
Return

DTcopy:                    ; Copy Date/Time to the ClipBoard
   Clipboard := FullDT()
Return

Hover7()                   ; When the mouse hovers DT
{                          ; Smoother move than MouseGetPos
   Global ClockTip
   IfNotEqual A_Gui,7, Return
   ClockTip = 1
   ToolTip % FullDT()      ; Show full date/time info
}

ClockUpdate:
   FormatTime time,,%ClockPatt%
   GuiControl 7:,DT,%time% ; Update date/time in preset format
   MouseGetPos,,,WinID
   If WinID = %ClockID%    ; Mouse in Clock
   {
      ClockTip = 1
      ToolTip % FullDT()   ; Show full date/time info
   }
   Else If ClockTip        ; Only clear ours
   {
      ClockTip =           ; ClockTip: tip removed
      ToolTip
   }
   IdleTime0 = %IdleTime%  ; Save previous values
   Tick0 = %Tick%
   DllCall("kernel32.dll\GetSystemTimes", "uint",&IdleTicks, "uint",0, "uint",0)
   IdleTime := *(&IdleTicks)
   Loop 7                  ; Ticks when Windows was idle
      IdleTime += *( &IdleTicks + A_Index ) << ( 8 * A_Index )
   Tick := A_TickCount     ; #Ticks all together
   load := 100 - 0.01*(IdleTime - IdleTime0)/(Tick - Tick0)
   Progress 1:%load%       ; Update progress bar

   DllCall("kernel32.dll\GlobalMemoryStatus", "uint",&memorystatus)
   mem:=*(&memorystatus+4) ; LS byte is enough, mem = 0..100
   Progress 2:%mem%        ; Update progress bar
Return

Dock2TaskBar:              ; Active window to be docked to the taskbar, NEEDS hw_tray value
   Process Exist           ; PID -> ErrorLevel
   WinGet hw_gui, ID, ahk_pid %ErrorLevel%
   DllCall( "SetParent", "uint", hw_gui, "uint", hw_tray )
Return

FullDT()                   ; Returns current date/time info
{                          ; Called very frequently if mouse hovers Clock
   Now = %A_Now%           ; Only one access to time: faster, no synchron problems
   FormatTime wday,Now,dddd
   FormatTime day, Now,yDay
   FormatTime week,Now,yWeek
   StringTrimLeft week, week, 4
;----- edit here for best look -----
   FormatTime DT,Now,yyyy MMMM d, h:mm:ss tt
   Return DT "`n" wday ". Day: " day ", Week: " week
;----- edit here for best look -----
}