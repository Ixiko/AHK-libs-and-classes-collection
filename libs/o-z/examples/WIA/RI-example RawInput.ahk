#NoEnv
; ================================================================================================================================
; Auto-execute section
; ================================================================================================================================
; Context menu LV Devices
Menu, CtxDev, Add, &Register, CtxDevRegister
Menu, CtxDev, Add, &Copy, CtxDevCopy
Menu, CtxDev, Add
Menu, CtxDev, Add, Refresh, CtxDevRefresh
; --------------------------------------------------------------------------------------------------------------------------------
; Context menu LV Info
Menu, CtxInf, Add, &Copy, CtxInfCopy
; --------------------------------------------------------------------------------------------------------------------------------
; Context menu LV Registered
Menu, CtxReg, Add, &Unregister, CtxRegUnregister
Menu, CtxReg, Add, &Copy, CtxRegCopy
Menu, CtyReg, Add
Menu, CtxReg, Add, Unregister All, CtxRegUnregisterAll
; --------------------------------------------------------------------------------------------------------------------------------
; Context menu LV RawInput
Menu, CtxRaw, Add, &Clear, CtxRawClear
Menu, CtxRaw, Add, &Copy, CtxRawCopy
; --------------------------------------------------------------------------------------------------------------------------------
Gui, Main: New, +OwnDialogs +HwndHMAIN
Gui, Add, Text, xm, Device List:
Gui, Add, ListView, xm y+2 w810 r10 vDevices gMainShowInfo -LV0x10 -Multi AltSubmit, Handle|Type|Page|Usage|Name
Gui, Add, Text, xm, Additional Device Info:
Gui, Add, Text, xm+410 yp, Registered Devices:
Gui, Add, ListView, xm y+2 w400 r6 vInfo NoSortHdr -LV0x10, Key|Value
Gui, Add, ListView, xm+410 yp w400 r6 vRegistered NoSortHdr -LV0x10, Page|Usage|Flags|HWND
Gui, Add, Text, xm, Raw Input:
Gui, Add, ListView, xm y+2 w810 r10 vRawInput -LV0x10 -Multi -Hdr, Raw Input
LV_Add("", "DummyEntry")
Gui, Add, StatusBar
; --------------------------------------------------------------------------------------------------------------------------------
GoSub, MainRefreshDevices
Gui, Main: Show, , RawInput Devices (Main GUI HWND = %HMAIN%)
; --------------------------------------------------------------------------------------------------------------------------------
OnMessage(0x00FF, "OnRawInput")  ; WM_INPUT
OnMessage(0x00FE, "OnDevChange") ; WM_INPUT_DEVICE_CHANGE - Win Vista+
Return
; ================================================================================================================================
; Main GUI
; ================================================================================================================================
MainGuiClose:
MainGuiEscape:
Gosub, MainUnregisterAll
ExitApp
; --------------------------------------------------------------------------------------------------------------------------------
MainGuiContextMenu:
If (A_GuiControl = "Devices") {
   Gui, ListView, Devices
   If (Selected := LV_GetNext())
      Menu, CtxDev, Show
}
Else If (A_GuiControl = "Registered") {
   Gui, ListView, Registered
   If (Selected := LV_GetNext())
      Menu, CtxReg, Show
}
Else If (A_GuiControl = "Info") {
   Gui, ListView, Info
   If LV_GetCount()
      Menu, CtxInf, Show
}
Else If (A_GuiControl = "RawInput") {
   Gui, ListView, RawInput
   If LV_GetCount() {
      Selected := LV_GetNext()
      Menu, CtxRaw, % Selected ? "Enable" : "Disable", &Copy
      Menu, CtxRaw, Show
   }
}
Return
; --------------------------------------------------------------------------------------------------------------------------------
MainRefreshDevices:
Gui, Main: Default
Gui, ListView, Devices
DevArr := RI_GetDeviceList()
GuiControl, -g, Devices
LV_Delete()
For Index, Dev In DevArr.Lst {
   DevName := RI_GetDeviceName(Dev.Handle)
   DevInfo := RI_GetDeviceInfo(Dev.Handle)
   LV_Add("", Dev.Handle, Dev.Type, DevInfo.Page, DevInfo.Usage, DevName)
}
Loop, % LV_GetCount("Column")
   LV_ModifyCol(A_Index, "AutoHdr")
Gui, ListView, Info
LV_Delete()
Loop, % LV_GetCount("Column")
   LV_ModifyCol(A_Index, "AutoHdr")
GuiControl, +gMainShowInfo, Devices
Cnt := DevArr.Cnt
SB_SetText("   Devices: Total = " . Cnt.T . ", HID = " . Cnt.H . ", Keyboard = " . Cnt.K . ", Mouse = " . Cnt.M)
Return
; --------------------------------------------------------------------------------------------------------------------------------
MainRefreshRegistered:
Gui, Main: Default
Gui, ListView, Registered
DevArr := RI_GetRegisteredDevices()
LV_Delete()
For Index, Dev In DevArr
   LV_Add("", Dev.Page, Dev.Usage, Dev.Flags, Dev.HWND)
Loop, % LV_GetCount("Column")
   LV_ModifyCol(A_Index, "AutoHdr")
Return
; --------------------------------------------------------------------------------------------------------------------------------
MainUnregisterAll:
Gui, Main: Default
Gui, ListView, Registered
GuiControl, -Redraw, Registered
CurrentRow := LV_GetCount()
Loop, % LV_GetCount() {
   LV_GetText(Page, CurrentRow, 1)
   LV_GetText(Usage, CurrentRow, 2)
   If !RI_UnRegisterDevices(Page, Usage)
      MsgBox, 16, %A_ThisLabel%, Could not unregister device!`nPage: %Page%`nUsage: %Usage%`nFlags: %Flags%`nError: %A_LastError%
   Else
      LV_Delete(CurrentRow)
   CurrentRow--
}
Loop, % LV_GetCount("Column")
   LV_ModifyCol(A_Index, "AutoHdr")
GuiControl, +Redraw, Registered
Return
; --------------------------------------------------------------------------------------------------------------------------------
MainShowInfo:
Critical
Gui, ListView, Devices
If (A_GuiEvent == "I") && InStr(ErrorLevel, "S", 1) {
   LV_GetText(DevHandle, A_EventInfo, 1)
   DevInfo := RI_GetDeviceInfo(DevHandle)
   Gui, ListView, Info
   LV_Delete()
   For Key, Value In DevInfo
      If Key Not In DevType,Page,Usage
         LV_Add("", Key, Value)
   Loop, % LV_GetCount("Column")
      LV_ModifyCol(A_Index, "AutoHdr")
}
Return
; ================================================================================================================================
; Register GUI
; ================================================================================================================================
RegisterApply:
Gui, +OwnDialogs
Gui, Submit, NoHide
GuiControlGet, Page
Flags := 0
For Each, Flag In CheckBoxes
   Flags |= (%Flag%) ? RI_RIDEV(Flag) : 0
If !RI_RegisterDevices(Page, Usage, Flags, HWND) {
   MsgBox, 16, %A_ThisLabel%, Could not register devices!`nPage: %Page%`nUsage: %Usage%`nFlags: %Flags%`nError: %A_LastError%
   Return
}
GoSub, MainRefreshRegistered
; We don't want to return here!
; --------------------------------------------------------------------------------------------------------------------------------
RegisterGuiClose:
Gui, Main: -Disabled
Gui, Register: Destroy
GuiControl, Main:Focus, Devices
Return
; --------------------------------------------------------------------------------------------------------------------------------
RegisterCheckFlags:
If (A_GuiControl = "PAGEONLY") {
   GuiControl, , EXCLUDE, 0
   GuiControl, , NOLEGACY, 0
}
Else If (A_GuiControl = "EXCLUDE") {
   GuiControl, , PAGEONLY, 0
   GuiControl, , NOLEGACY, 0
}
Else If (A_GuiControl = "NOLEGACY") {
   GuiControl, , EXCLUDE, 0
   GuiControl, , PAGEONLY, 0
}
Return
; ================================================================================================================================
; CtxDev menu
; ================================================================================================================================
CtxDevRegister:
Gui, Main: Default
Gui, ListView, Devices
LV_GetText(DevHandle, Selected, 1)
LV_GetText(DevType, Selected, 2)
LV_GetText(DevPage, Selected, 3)
LV_GetText(DevUsage, Selected, 4)
TypeStr := RI_RIM(DevType)
Gui, Register: New, +OwnerMain +HwndHREG, Register %TypeStr% Devices
Gui, Margin, 10, 10
Gui, Add, Text, xm, Usage Page:
Gui, Add, Edit, xm y+2 w400 vPage Disabled, % DevInfo.Page
Gui, Add, Text, xm, Usage:
Gui, Add, Edit, xm y+2 w400 vUsage Number, % DevInfo.Usage
Gui, Add, Text, xm, HWND:
Gui, Add, Edit, xm y+2 w400 vHWND, %HMAIN%
Gui, Add, Text, xm, Flags:
CheckBoxes := RI_RIDEV_ForType(DevType)
For Each, Flag In CheckBoxes {
   If (Flag = "DEFAULT") || (Flag = "REMOVE")
      Continue
   Gui, Add, CheckBox, v%Flag% gRegisterCheckFlags, %Flag%
}
Gui, Add, Button, xm w100 gRegisterApply, &Apply
Gui, Add, Button, xm+300 yp wp gRegisterGuiClose, &Cancel
Gui, Main: +Disabled
Gui, Register: Show
Return
; --------------------------------------------------------------------------------------------------------------------------------
CtxDevCopy:
Gui, Main: Default
Gui, +OwnDialogs
Gui, ListView, Devices
LV_GetText(DevType, Selected, 2)
LV_GetText(DevPage, Selected, 3)
LV_GetText(DevUsage, Selected, 4)
LV_GetText(DevName, Selected, 5)
Device := Format("Type: {:}`r`nPage: {:}`r`nUsage: {:}`r`nName: {:}", DevType, DevPage, DevUsage, DevName)
Clipboard := Device
MsgBox, 0, %A_ThisLabel%, Content of the selected row has been copied to the clipboard:`r`n`r`n%Device%
Return
; --------------------------------------------------------------------------------------------------------------------------------
CtxDevRefresh:
GoSub, MainRefreshDevices
Return
; ================================================================================================================================
; CtxInf menu
; ================================================================================================================================
CtxInfCopy:
Gui, Main: Default
Gui, +OwnDialogs
Gui, ListView, Info
Info := ""
Loop, % LV_GetCount() {
   LV_GetText(Key, A_Index, 1)
   LV_GetText(Val, A_Index, 2)
   Info .= (A_Index > 1 ? "`r`n" : "") . Key . ": " . Val
}
If (Info) {
   Clipboard := Info
   MsgBox, 0, %A_ThisLabel%, The content has been copied to the clipboard:`r`n`r`n%Info%
}
Return
; ================================================================================================================================
; CtxReg menu
; ================================================================================================================================
CtxRegUnregister:
Gui, Main: Default
Gui, ListView, Registered
LV_GetText(Page, Selected, 1)
LV_GetText(Usage, Selected, 2)
If !RI_UnRegisterDevices(Page, Usage) {
   MsgBox, 16, %A_ThisLabel%
         , Could not remove registered device!`nPage: %Page% - Usage: %Usage% - Flags: %Flags% Error: %A_LastError%
   Return
}
GoSub, MainRefreshRegistered
Return
; --------------------------------------------------------------------------------------------------------------------------------
CtxRegCopy:
Gui, ListView, Registered
LV_GetText(Page, Selected, 1)
LV_GetText(Usage, Selected, 2)
LV_GetText(Flags, Selected, 3)
Registered := "Page: " . Page . "`r`nUsage: " . Usage . "`r`nFlags: " . Flags
Clipboard := Registered
MsgBox, 0, %A_ThisLabel%, The content of the selected row has been copied to the clipboard:`r`n`r`n%Registered%
Return
; --------------------------------------------------------------------------------------------------------------------------------
CtxRegUnregisterAll:
GoSub, MainUnregisterAll
Return
; ================================================================================================================================
; CtxReg menu
; ================================================================================================================================
CtxRawClear:
Gui, Main: Default
Gui, ListView, RawInput
LV_Delete()
Return
; --------------------------------------------------------------------------------------------------------------------------------
CtxRawCopy:
Gui, Main: Default
Gui, ListView, RawInput
LV_GetText(Rawdata, Selected)
If (Rawdata) {
   Clipboard := Rawdata
   MsgBox, 0, %A_ThisLabel%, The content of the selected row has been copied to the clipboard:`r`n`r`n%Rawdata%
}
Return
; ================================================================================================================================
; Raw input message handlers
; ================================================================================================================================
OnRawInput(Type, RawInput, Msg, HWND) { ; WM_INPUT
   Gui, Main: Default
   Gui, ListView, RawInput
   If (InputObj := RI_GetData(RawInput)) {
      InputStr := ""
      For Each, Key In InputObj["*Keys"]
         InputStr .= (InputStr ? ", " : "") . Key . ": " . InputObj[Key]
      LV_Add("", InputStr)
   }
   Return DllCall("DefWindowProc", "Ptr", HWND, "UInt", Msg, "Ptr", Type, "Ptr", RawInput, "Ptr")
}
; --------------------------------------------------------------------------------------------------------------------------------
OnDevChange(Action, Handle) { ; WM_INPUT_DEVICE_CHANGE - Win Vista+
   Static GIDC := {0: "REMOVAL", 1: "ARRIVAL"}
   Critical
   ; MsgBox, 0, %A_ThisFunc%, % Format("Called with action {:} for device 0x{:X}.", GIDC[Action], Handle)
   Refresh := True
   If (Action = 1) { ; GIDC_ARRIVAL
      Gui, Main: Default
      Gui, ListView, RawInput
      Loop, % LV_GetCount {
         LV_GetText(DevHandle, A_Index)
         If (DevHandle = Handle)
            Refresh := False
      } Until (Refresh = False)
   }
   If (Refresh)
      SetTimer, MainRefreshDevices, -20
}
; ================================================================================================================================
#Include RI.ahk