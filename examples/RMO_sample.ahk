#NoEnv
; ----------------------------------------------------------------------------------------------------------------------
; Originally adapted from lexikos' ControlGetTabs() at autohotkey.com -> /board/topic/70727-ahk-l-controlgettabs/
; This sample as is will only work with an open PSPad 4.5.4 window. To use another programm, you have to adjust
; the values of WindowClass (main window) and ControlClass (tab control).
; ----------------------------------------------------------------------------------------------------------------------
WindowClass := "ahk_class TfPSPad.UnicodeClass"   ; PSPad editor 4.5.4 (2356)
ControlClass := "TTntPageControl.UnicodeClass1"   ; PSPad editor 4.5.4 (2356)
; Some 'constants' -----------------------------------------------------------------------------------------------------
TCIF_TEXT := 1 ; get tab item text
TCITEM_SIZE := 16 + A_PtrSize * 3 ; size of TCITEM structure in bytes
MAX_TEXT_LENGTH := 260 ; maximum length of the tab item text in characters
MAX_TEXT_SIZE := MAX_TEXT_LENGTH * (A_IsUnicode ? 2 : 1) ; maximum length of the tab item text in bytes
REMOTE_SIZE := TCITEM_SIZE + MAX_TEXT_SIZE ; size of the remote buffer -> size of TCITEM + MAX_TEXT_SIZE
; Get control's HWND  --------------------------------------------------------------------------------------------------
ControlGet, HTab, Hwnd, , %ControlClass%, %WindowClass%
If (ErrorLevel) {
   MsgBox, 0, ControlGet, Couldn't get the tab control!
   ExitApp
}
; Get the 'process identifier' (HWND or PID) ---------------------------------------------------------------------------
; WinGet Proc, PID, ahk_id %HTab% ; using the PID
; WinGet Proc, ID, %WindowClass%  ; using the class of the main window
Proc := HTab  ; using the HWND of the control
; Create the remote buffer ---------------------------------------------------------------------------------------------
Remote := RMO_Create(Proc, REMOTE_SIZE)
If !IsObject(Remote) {
   MsgBox, 0, RMO_Create(), Couldn't allocate remote memory!
   ExitApp
}
; Compute the address of the end of the remote buffer, TabItemText will be stored there --------------------------------
RemoteTextAddr := Remote.Ptr + TCITEM_SIZE
; Create and fill a "local" variable for the TCITEM structure ----------------------------------------------------------
VarSetCapacity(LocalVar, REMOTE_SIZE, 0)
NumPut(TCIF_TEXT,       LocalVar, 0, "UInt")
NumPut(RemoteTextAddr,  LocalVar, 8 + A_PtrSize, "Ptr")
NumPut(MAX_TEXT_LENGTH, LocalVar, 8 + (A_PtrSize * 2), "Int")
; Store the content of the local variable into the remote buffer -------------------------------------------------------
Remote.Put(LocalVar) ; object syntax
; Retrieve the tab items from the remote process -----------------------------------------------------------------------
Tabs := []
TCM_GETITEMCOUNT := 0x1304
TCM_GETITEM := A_IsUnicode ? 0x133C : 0x1305
SendMessage, %TCM_GETITEMCOUNT%, , , , ahk_id %HTab%
Loop % ((ErrorLevel != "FAIL") ? ErrorLevel : 0) {
   ; Retrieve the item text.
   SendMessage, %TCM_GETITEM%, % (A_Index - 1), % Remote.Ptr, , ahk_id %HTab%
   If (ErrorLevel = 1) ; Success
      ; Get TabItemText from remote buffer with offset TCITEM_SIZE and size MAX_TEXT_SIZE
      RMO_Get(Remote, LocalText, TCITEM_SIZE, MAX_TEXT_SIZE) ; function syntax
   Else
      LocalText := ""
   ; Store a value even on failure
   VarSetCapacity(LocalText, -1) ; LocalText contains a string
   Tabs[A_Index] := LocalText
}
; Free the remote buffer -----------------------------------------------------------------------------------------------
Remote := ""
; Show the retrieved captions ------------------------------------------------------------------------------------------
Gui, Add, ListView, w300 r10, #|Caption
LV_ModifyCol(1, "Int")
For I, V In Tabs
   LV_Add("", I, V)
LV_ModifyCol()
Gui, Show, , Tab Captions
Return
GuiClose:
GuiEscape:
ExitApp
; ----------------------------------------------------------------------------------------------------------------------
#Include RMO.ahk