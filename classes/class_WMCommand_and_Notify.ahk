; ======================================================================================================================
; ======================================================================================================================
; One script! Two classes!     ### CLASS_ON_WMCOMMAND_AND_NOTIFY ###        by justme  - https://autohotkey.com/board/topic/70445-class-on-wm-command-on-wm-notify-ahk-l
; ======================================================================================================================
; On_WM_COMMAND  	-     	Helper object to handle notification messages sent through WM_COMMAND 	AHK version:      1.1.05.06 (U32)
; On_WM_NOTIFY			- 		Helper object to handle notification messages sent through WM_NOTIFY			AHK version:      1.1.05.06 (U32)
; ======================================================================================================================
; ======================================================================================================================

Class On_WM_COMMAND {
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PRIVATE Properties and Methods ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Static Attached := 0
   Static Controls := {}
   Static MessageHandler := "On_WM_COMMAND_Handler"
   Static WM_COMMAND := 0x0111
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
   ; METHOD Attach         Register control for WM_COMMAND messages
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
         OnMessage(This.WM_COMMAND, This.MessageHandler)
      This.Attached += 1
      This.Controls[Hwnd, Message] := Func(Function)
      Return True
   }
   ; ===================================================================================================================
   ; METHOD Detach         Unregister control for WM_COMMAND messages
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
               OnMessage(This.WM_COMMAND, "")
            }
         }
         Return True   
      }
      Return False
   }
}
; PRIVATE FUNCTIONS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
On_WM_COMMAND_Handler(W, L) { ; wParam, lParam
   Global On_WM_COMMAND
   Critical 1000
   If IsObject(F := On_WM_COMMAND.Controls[L][M := (W >> 16)])
      Return F.(L, M, W, L)
}


Class On_WM_NOTIFY {

	; ========DESCRIPTION=====================================================================================================
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
	; ========DESCRIPTION=END=================================================================================================


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
; PRIVATE FUNCTIONS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
On_WM_NOTIFY_Handler(W, L) { ; wParam, lParam
   Global On_WM_NOTIFY
   Critical 1000
   If IsObject(F := On_WM_NOTIFY.Controls[H := NumGet(L + 0)][M := NumGet(L + 0, A_PtrSize * 2, "Int")])
      Return F.(H, M, W, L)
}



/*				EXAMPLES class_On_WMCommand_and_Notify.ahk 

#NoEnv
#Include Class_On_WM_COMMAND.ahk
#Include Class_On_WM_NOTIFY.ahk
SetBatchLines, -1

EN_SETFOCUS    := 0x0100
EN_KILLFOCUS   := 0x0200
EN_UPDATE      := 0x0400
NM_SETFOCUS    := -7
NM_KILLFOCUS   := -8
WM_NOTIFY      := 0x004E
WM_COMMAND     := 0x0111

Gui, Margin, 20, 20
Gui, Add, Text, xm w300, Edit:
Gui, Add, Edit, xm y+2 wp r5 vVEDIT hwndHEDIT
Gui, Add, Text, xm wp, LV:
Gui, Add, ListView, xm y+2 r5 wp Grid vLVV hwndHLV, Column1
LV_Add("", "Row 1")
LV_ModifyCol(1, "AutoHdr")
Gui, Add, Text, xm wp, Focus:
Gui, Add, Edit, xm y+2 wp vVEDIT1, 
Gui, Add, Text, xm wp, EN_UPDATE notifications:
Gui, Add, Edit, xm y+2 wp vVEDIT2
Gui, Add, Button, xm wp vVBUTTON gGBUTTON, Unregister EN_UPDATE
Gui, Show, , Notifications
On_WM_COMMAND.Attach(HEDIT, EN_KILLFOCUS, "On_EN_KILLFOCUS")
On_WM_COMMAND.Attach(HEDIT, EN_SETFOCUS, "On_EN_SETFOCUS")
On_WM_COMMAND.Attach(HEDIT, EN_UPDATE, "On_EN_UPDATE")
On_WM_NOTIFY.Attach(HLV, NM_KILLFOCUS, "On_LV_KILLFOCUS" )
On_WM_NOTIFY.Attach(HLV, NM_SETFOCUS, "On_LV_SETFOCUS" )
GuiControl, Focus, VBUTTON
GuiControl, Focus, VEDIT
Return

GuiClose:
GuiEscape:
ExitApp

GBUTTON:
   GuiControlGet, Cap, , VBUTTON, Text
   If (Cap = "Unregister EN_UPDATE") {
      On_WM_COMMAND.Detach(HEDIT, EN_UPDATE)
      GuiControl, , VBUTTON, Register EN_UPDATE
   } ELse {
      On_WM_COMMAND.Attach(HEDIT, EN_UPDATE, "On_EN_UPDATE")
      GuiControl, , VBUTTON, Unregister EN_UPDATE
   }
Return
; ======================================================================================================================
On_EN_KILLFOCUS(Hwnd, Message, wParam, lParam) {
   Gui, Font, cC00000
   GuiControl, Font, VEDIT1
   GuiControl, , VEDIT1, Edit lost focus!
}
On_EN_SETFOCUS(Hwnd, Message, wParam, lParam) {
   Gui, Font, c008000
   GuiControl, Font, VEDIT1
   GuiControl, , VEDIT1, Edit got focus!
}
On_EN_UPDATE(Hwnd, Message, wParam, lParam) {
   Static I := 0
   I++
   GuiControl, , VEDIT2, %A_ThisFunc% was called %I% times.
}
On_LV_KILLFOCUS(Hwnd, Message, wParam, lParam) {
   Gui, Font, cC00000
   GuiControl, Font, VEDIT1
   GuiControl, , VEDIT1, LV lost focus!
}
On_LV_SETFOCUS(Hwnd, Message, wParam, lParam) {
   Gui, Font, c008000
   GuiControl, Font, VEDIT1
   GuiControl, , VEDIT1, LV got focus!
}
; ======================================================================================================================

*/
