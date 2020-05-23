; ======================================================================================================================
; Namespace:      GuiControlTips
; AHK version:    AHK 1.1.14.03
; Function:       Helper object to simply assign ToolTips for GUI controls
; Tested on:      Win 7 (x64)
; Change history:
;                 1.1.00.00/2014-03-06/just me - Added SetDelayTimes()
;                 1.0.01.00/2012-07-29/just me
; ======================================================================================================================
; CLASS GuiControlTips
;
; The class provides four public methods to register (Attach), unregister (Detach), update (Update), and
; disable/enable (Suspend) common ToolTips for GUI controls.
;
; Usage:
; To assign ToolTips to GUI controls you have to create a new instance of GuiControlTips per GUI with
;     MyToolTipObject := New GuiControlTips(HGUI)
; passing the HWND of the GUI.
;
; After this you may assign ToolTips to your GUI controls by calling
;     MyToolTipObject.Attach(HCTRL, "ToolTip text")
; passing the HWND of the control and the ToolTip's text. Pass True/1 for the optional third parameter if you
; want the ToolTip to be shown centered below the control.
;
; To remove a ToolTip call
;     MyToolTipObject.Detach(HCTRL)
; passing the HWND of the control.
;
; To update the ToolTip's text call
;     MyToolTipObject.Update(HCTRL, "New text!")
; passing the HWND of the control and the new text.
;
; To deactivate the ToolTips call
;     MyToolTipObject.Suspend(True),
; to activate them again afterwards call
;     MyToolTipObject.Suspend(False).
;
; To adjust the ToolTips delay times call
;     MyToolTipObject.SetDelayTimesd(),
; specifying the delay times in milliseconds.
;
; That's all you can / have to do!
; ======================================================================================================================
Class GuiControlTips {
   ; ===================================================================================================================
   ; INSTANCE variables
   ; ===================================================================================================================
   HTIP := 0
   HGUI := 0
   CTRL := {}
   ; ===================================================================================================================
   ; CONSTRUCTOR           __New()
   ; ===================================================================================================================
   __New(HGUI) {
      Static CLASS_TOOLTIP      := "tooltips_class32"
      Static CW_USEDEFAULT      := 0x80000000
      Static TTM_SETMAXTIPWIDTH := 0x0418
      Static TTM_SETMARGIN      := 0x041A
      Static WS_STYLES          := 0x80000002 ; WS_POPUP | TTS_NOPREFIX
      ; Create a Tooltip control ...
      HTIP := DllCall("User32.dll\CreateWindowEx", "UInt", WS_EX_TOPMOST, "Str", CLASS_TOOLTIP, "Ptr", 0
                    , "UInt", WS_STYLES
                    , "Int", CW_USEDEFAULT, "Int", CW_USEDEFAULT, "Int", CW_USEDEFAULT, "Int", CW_USEDEFAULT
                    , "Ptr", HGUI, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")
      If ((ErrorLevel) || !(HTIP))
         Return False
      ; ... prepare it to display multiple lines if required
      DllCall("User32.dll\SendMessage", "Ptr", HTIP, "Int", TTM_SETMAXTIPWIDTH, "Ptr", 0, "Ptr", 0)
      ; ... set the instance variables
      This.HTIP := HTIP
      This.HGUI := HGUI
      If (DllCall("Kernel32.dll\GetVersion", "UInt") & 0xFF) < 6 ; to avoid some XP issues ...
         This.Attach(HGUI, "") ; ... register the GUI with an empty tiptext
   }
   ; ===================================================================================================================
   ; DESTRUCTOR            __Delete()
   ; ===================================================================================================================
   __Delete() {
      If (This.HTIP) {
         DllCall("User32.dll\DestroyWindow", "Ptr", This.HTIP)
      }
   }
   ; ===================================================================================================================
   ; PRIVATE METHOD        SetToolInfo - Create and fill a TOOLINFO structure
   ; ===================================================================================================================
   SetToolInfo(ByRef TOOLINFO, HCTRL, TipTextAddr, CenterTip = 0) {
      Static TTF_IDISHWND  := 0x0001
      Static TTF_CENTERTIP := 0x0002
      Static TTF_SUBCLASS  := 0x0010
      Static OffsetSize  := 0
      Static OffsetFlags := 4
      Static OffsetHwnd  := 8
      Static OffsetID    := OffsetHwnd + A_PtrSize
      Static OffsetRect  := OffsetID + A_PtrSize
      Static OffsetInst  := OffsetRect + 16
      Static OffsetText  := OffsetInst + A_PtrSize
      Static StructSize  := (4 * 6) + (A_PtrSize * 6)
      Flags := TTF_IDISHWND | TTF_SUBCLASS
      If (CenterTip)
         Flags |= TTF_CENTERTIP
      VarSetCapacity(TOOLINFO, StructSize, 0)
      NumPut(StructSize, TOOLINFO, OffsetSize, "UInt")
      NumPut(Flags, TOOLINFO, OffsetFlags, "UInt")
      NumPut(This.HGUI, TOOLINFO, OffsetHwnd, "Ptr")
      NumPut(HCTRL, TOOLINFO, OffsetID, "Ptr")
      NumPut(TipTextAddr, TOOLINFO, OffsetText, "Ptr")
      Return True
   }
   ; ===================================================================================================================
   ; PUBLIC METHOD         Attach         -  Assign a ToolTip to a certain control
   ; Parameters:           HWND           -  Control's HWND
   ;                       TipText        -  ToolTip's text
   ;                       Optional:      ------------------------------------------------------------------------------
   ;                       CenterTip      -  Centers the tooltip window below the control
   ;                                         Values:  True/False
   ;                                         Default: False
   ; Return values:        On success: True
   ;                       On failure: False
   ; ===================================================================================================================
   Attach(HCTRL, TipText, CenterTip = False) {
      Static TTM_ADDTOOL  := A_IsUnicode ? 0x0432 : 0x0404 ; TTM_ADDTOOLW : TTM_ADDTOOLA
      If !(This.HTIP) {
         Return False
      }
      If This.CTRL.HasKey(HCTRL)
         Return False
      TOOLINFO := ""
      This.SetToolInfo(TOOLINFO, HCTRL, &TipText, CenterTip)
      If DllCall("User32.dll\SendMessage", "Ptr", This.HTIP, "Int", TTM_ADDTOOL, "Ptr", 0, "Ptr", &TOOLINFO) {
		This.CTRL[HCTRL] := TipText
         Return True
      } Else {
        Return False
      }
   }
   ; ===================================================================================================================
   ; PUBLIC METHOD         Detach         -  Remove the ToolTip for a certain control
   ; Parameters:           HWND           -  Control's HWND
   ; Return values:        On success: True
   ;                       On failure: False
   ; ===================================================================================================================
   Detach(HCTRL) {
      Static TTM_DELTOOL  := A_IsUnicode ? 0x0433 : 0x0405 ; TTM_DELTOOLW : TTM_DELTOOLA
      If !This.CTRL.HasKey(HCTRL)
         Return False
      TOOLINFO := ""
      This.SetToolInfo(TOOLINFO, HCTRL, 0)
      DllCall("User32.dll\SendMessage", "Ptr", This.HTIP, "Int", TTM_DELTOOL, "Ptr", 0, "Ptr", &TOOLINFO)
      This.CTRL.Remove(HCTRL, "")
      Return True
   }
   ; ===================================================================================================================
   ; PUBLIC METHOD         Update         -  Update the ToolTip's text for a certain control
   ; Parameters:           HWND           -  Control's HWND
   ;                       TipText        -  New text
   ; Return values:        On success: True
   ;                       On failure: False
   ; ===================================================================================================================
   Update(HCTRL, TipText) {
      Static TTM_UPDATETIPTEXT  := A_IsUnicode ? 0x0439 : 0x040C ; TTM_UPDATETIPTEXTW : TTM_UPDATETIPTEXTA
      If !This.CTRL.HasKey(HCTRL)
         Return False
      TOOLINFO := ""
      This.SetToolInfo(TOOLINFO, HCTRL, &TipText)
      DllCall("SendMessage", "Ptr", This.HTIP, "Int", TTM_UPDATETIPTEXT, "Ptr", 0, "Ptr", &TOOLINFO)
      Return True
   }
   ; ===================================================================================================================
   ; PUBLIC METHOD         Suspend        -  Disable/enable the ToolTip control (don't show / show ToolTips)
   ; Parameters:           Mode           -  True/False (1/0)
   ;                                         Default: True/1
   ; Return values:        On success: True
   ;                       On failure: False
   ; Remarks:              ToolTips are enabled automatically on creation.
   ; ===================================================================================================================
   Suspend(Mode = True) {
      Static TTM_ACTIVATE := 0x0401
      If !(This.HTIP)
         Return False
      DllCall("SendMessage", "Ptr", This.HTIP, "Int", TTM_ACTIVATE, "Ptr", !Mode, "Ptr", 0)
      Return True
   }
   ; ===================================================================================================================
   ; PUBLIC METHOD         SetDelayTimes  -  Set the initial, pop-up, and reshow durations for a tooltip control.
   ; Parameters:           Init           -  Amount of time, in milliseconds, a pointer must remain stationary within
   ;                                         a tool's bounding rectangle before the tooltip window appears.
   ;                                         Default: -1 (system default time)
   ;                       PopUp          -  Amount of time, in milliseconds, a tooltip window remains visible if the
   ;                                         pointer is stationary within a tool's bounding rectangle.
   ;                                         Default: -1 (system default time)
   ;                       ReShow         -  Amount of time, in milliseconds, it takes for subsequent tooltip windows
   ;                                         to appear as the pointer moves from one tool to another.
   ;                                         Default: -1 (system default time)
   ; Return values:        On success: True
   ;                       On failure: False
   ; Remarks:              Times are set per ToolTip control and applied to all added tools.
   ; ===================================================================================================================
   SetDelayTimes(Init = -1, PopUp = -1, ReShow = -1) {
      Static TTM_SETDELAYTIME   := 0x0403
      Static TTDT_RESHOW   := 1
      Static TTDT_AUTOPOP  := 2
      Static TTDT_INITIAL  := 3
      DllCall("SendMessage", "Ptr", This.HTIP, "Int", TTM_SETDELAYTIME, "Ptr", TTDT_INITIAL, "Ptr", Init)
      DllCall("SendMessage", "Ptr", This.HTIP, "Int", TTM_SETDELAYTIME, "Ptr", TTDT_AUTOPOP, "Ptr", PopUp)
      DllCall("SendMessage", "Ptr", This.HTIP, "Int", TTM_SETDELAYTIME, "Ptr", TTDT_RESHOW , "Ptr", ReShow)
   }
}
