/* TheGood
Wrapper to catch Power Management events

;http://msdn.microsoft.com/en-us/library/aa373162(VS.85).aspx
;SUPPORTED ONLY BY WINDOWS 2000 AND UP
WM_POWERBROADCAST           := 536          ;Notifies applications that a power-management event has occurred.
PBT_APMQUERYSUSPEND         := 0            ;Requests permission to suspend the computer. An application
                                            ;that grants permission should carry out preparations for the
                                            ;suspension before returning.
BROADCAST_QUERY_DENY        := 1112363332   ;Return this value to deny the request.
PBT_APMQUERYSUSPENDFAILED   := 2            ;Notifies applications that permission to suspend the computer
                                            ;was denied. This event is broadcast if any application or
                                            ;driver returned BROADCAST_QUERY_DENY to a previous
                                            ;PBT_APMQUERYSUSPEND event.
PBT_APMSUSPEND              := 4            ;Notifies applications that the computer is about to enter a
                                            ;suspended state. This event is typically broadcast when all
                                            ;applications and installable drivers have returned TRUE to a
                                            ;previous PBT_APMQUERYSUSPEND event.
PBT_APMRESUMECRITICAL       := 6            ;Notifies applications that the system has resumed operation.
                                            ;This event can indicate that some or all applications did not
                                            ;receive a PBT_APMSUSPEND event. For example, this event can be
                                            ;broadcast after a critical suspension caused by a failing
                                            ;battery.
PBT_APMRESUMESUSPEND        := 7            ;Notifies applications that the system has resumed operation
                                            ;after being suspended.
PBT_APMBATTERYLOW           := 9            ;Notifies applications that the battery power is low.
PBT_APMPOWERSTATUSCHANGE    := 10           ;Notifies applications of a change in the power status of the
                                            ;computer, such as a switch from battery power to A/C. The
                                            ;system also broadcasts this event when remaining battery power
                                            ;slips below the threshold specified by the user or if the
                                            ;battery power changes by a specified percentage.
PBT_APMOEMEVENT             := 11           ;Notifies applications that the APM BIOS has signaled an APM
                                            ;OEM event.
PBT_APMRESUMEAUTOMATIC      := 18           ;Notifies applications that the computer has woken up
                                            ;automatically to handle an event. An application will not
                                            ;generally respond unless it is handling the event, because
                                            ;the user is not present.
*/

OnMessage(536, "OnPBMsg")   ;WM_POWERBROADCAST
Return

OnPBMsg(wParam, lParam, msg, hwnd) {
   If (wParam = 0) {   ;PBT_APMQUERYSUSPEND
      If (lParam & 1)   ;Check action flag
         MsgBox The computer is trying to suspend, and user interaction is permitted.
      Else MsgBox The computer is trying to suspend, and no user interaction is allowed.
      ;Return TRUE to grant the request, or BROADCAST_QUERY_DENY to deny it.
   } Else If (wParam = 2)   ;PBT_APMQUERYSUSPENDFAILED
      MsgBox The computer tried to suspend, but failed.
   Else If (wParam = 4)   ;PBT_APMSUSPEND
      MsgBox The computer is about to enter a suspended state.
   Else If (wParam = 6)   ;PBT_APMRESUMECRITICAL
      MsgBox The computer is now resuming from a suspended state, which may have taken place unexpectedly.
   Else If (wParam = 7)   ;PBT_APMRESUMESUSPEND
      MsgBox The computer is now resuming from a suspended state.
   Else If (wParam = 9)   ;PBT_APMBATTERYLOW
      MsgBox The computer battery is running low.
   Else If (wParam = 10)   ;PBT_APMPOWERSTATUSCHANGE
      MsgBox The computer power status has changed.
   Else If (wParam = 11)   ;PBT_APMOEMEVENT
      MsgBox The APM BIOS has signaled an APM OEM event with event code %lParam%
   Else If (wParam = 18)   ;PBT_APMRESUMEAUTOMATIC
      MsgBox The computer is now automatically resuming from a suspended state.
   
   ;Must return True after processing
   Return True
}