; ======================================================================================================================
; AHK 1.1 +
; ======================================================================================================================
; Namespace:        On_WM_NOTIFY
; Function:         Helper object to handle notification messages sent through WM_NOTIFY
; AHK version:      1.1.05.06 (U32)
; Language:         English
; Tested on:        WinXPSP3, WinVistaSP2 (32 bit)
; Version:          1.0.00.00/2012-02-10/just me
; Remarks:          To register a function to be called on notification call On_WM_NOTIFY.Attach()
;                   passing three parameters:
;                      Hwnd      - HWND of the GUI control                                   (Integer)
;                      Message   - Notification message number                               (Integer)
;                      Function  - Name of the function which handles the message            (String)
;
;                   To unregister notification handling call On_WM_NOTIFY.Detach()
;                   passing two parameters:
;                      Hwnd      - see above
;                      Message   - see above
;
;                   To get a control's HWND use either the option "HwndOutputVar" with "Gui, Add" or the command
;                   "GuiControlGet" with sub-command "Hwnd".
;
;                   The function to be called on notification has to accept exactly four parameters:
;                      Hwnd      - Hwnd of the GUI control sending the notification message
;                      Message   - Notification message number
;                      wParam    - wParam passed to On_WM_NOTIFY_Handler
;                      lParam    - lParam passed to On_WM_NOTIFY_Handler
;
;                   For notifications through WM_NOTIFY the contents of wParam and lParam is described at
;                      http://msdn.microsoft.com/en-us/library/bb775583%28VS.85%29.aspx
;                   (the content of the structure lParam points to is message specific in this case).
;                   Look at the documentation for OnMessage(), too.
;
;                   To get the sort of notification please look at
;                      http://msdn.microsoft.com/en-us/library/bb773173%28VS.85%29.aspx
;                   in particular at "Control Library".
;
;                   The class registers On_WM_COMMAND_Handler as message handler for WM_COMMAND notfications
;                   per OnMessage() as long as controls are attached. You cannot use own handlers for this message
;                   at the same time.
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
Class On_WM_NOTIFY {
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PRIVATE PROPERTIES ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Static Attached := 0
   Static Controls := {}
   Static MessageHandler := "On_WM_NOTIFY_Handler"
   Static WM_NOTIFY  = 0x4E
   ; ===================================================================================================================
   ; META FUNCTIONS
   ; ===================================================================================================================
   __New() {
      Return False   ; there is no reason to instantiate this class
   }
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PUBLIC INTERFACE ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ===================================================================================================================
   ; METHOD Attach         Register control for WM_NOTIFY messages
   ; Parameters:           Hwnd        - HWND of the GUI control                                   (Integer)
   ;                       Message     - message number                                            (Integer)
   ;                       Function    - name of the function to be called                         (String)
   ; Return values:        On success  - True
   ;                       On failure  - False
   ; ===================================================================================================================
   Attach(Hwnd, Message, Function) {
      If Message Is Not Integer
         Return False
      If !IsFunc(Function)
      Or (Func(Function).MaxParams <> 4)
      Or !DllCall("User32.dll\IsWindow", "UPtr", Hwnd)
         Return False
      If This.Controls.HasKey(Hwnd) {
         This.Controls[Hwnd][Message] := Func(Function)
         Return True
      }
      If (This.Attached = 0)
         OnMessage(This.WM_NOTIFY, This.MessageHandler)
      This.Attached += 1
      This.Controls[Hwnd, Message] := Func(Function)
      Return True
   }
   ; ===================================================================================================================
   ; METHOD Detach         Unregister control for WM_NOTIFY messages
   ; Parameters:           Hwnd        - HWND of the GUI control                                   (Integer)
   ;                       Message     - message number                                            (Integer)
   ; Return values:        On success  - True
   ;                       On failure  - False
   ; ===================================================================================================================
   Detach(Hwnd, Message) {
      If This.Controls[Hwnd].HasKey(Message) {
         This.Controls[Hwnd].Remove(Message, "")
         If !This.Controls[Hwnd].MaxIndex() {
            This.Controls.Remove(Hwnd, "")
            This.Attached -= 1
            If (This.Attached = 0) {
               OnMessage(This.WM_NOTIFY, "")
            }
         }
         Return True
      }
      Return False
   }
}
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; PRIVATE FUNCTIONS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ======================================================================================================================
On_WM_NOTIFY_Handler(W, L) { ; wParam, lParam
   Global On_WM_NOTIFY
   Critical 1000
   If IsObject(F := On_WM_NOTIFY.Controls[H := NumGet(L + 0)][M := NumGet(L + 0, A_PtrSize * 2, "Int")])
      Return F.(H, M, W, L)
}
; ======================================================================================================================