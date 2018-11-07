; ================================================================================================================================
; Raw Input
;     -> msdn.microsoft.com/en-us/library/windows/desktop/ms645536(v=vs.85).aspx
; RIDEV_... (Flag) constants
;     -> msdn.microsoft.com/en-us/library/windows/desktop/ms645565(v=vs.85).aspx
; RIM_TYPE... constants
;     -> msdn.microsoft.com/en-us/library/windows/desktop/ms645568(v=vs.85).aspx
; HID Clients Supported in Windows
;     -> docs.microsoft.com/en-us/windows-hardware/drivers/hid/hid-clients-supported-in-windows
; Top-Level Collections Opened by Windows for System Use
;     -> docs.microsoft.com/en-us/windows-hardware/drivers/hid/top-level-collections-opened-by-windows-for-system-use
; --------------------------------------------------------------------------------------------------------------------------------
; Some notes about RIDEV_... flags as a result of my testing on Win 10:
;     RIDEV_DEVNOTIFY and RIDEV_EXINPUTSINK require Win Vista+
;     Seemingly,
;        -  RIDEV_DEVNOTIFY can be used alone or combined with all other flags.
;           Apparently, the flag is stripped from the values returned by GetRegisteredRawInputDevices().
;     Also seemingly,
;        -  RIDEV_EXCLUDE, RIDEV_PAGEONLY, and RIDEV_NOLEGACY are exclusive and cannot be combined.
;           If you registered devices with RIDEV_PAGEONLY you must add this flag to RIDEV_REMOVE, too.
;        -  If both REDEV_INPUTSINK and RIDEV_EXINPUTSINK are specified RIDEV_EXINPUTSINK supersedes RIDEV_INPUTSINK.
;        -  RIDEV_APPKEYS is only valid for keyboard devices (Page: 1, Usage: 6) and requires RIDEV_NOLEGACY.
;        -  RIDEV_NOLEGACY, RIDEV_CAPTUREMOUSE, and RIDEV_NOHOTKEYS are only valid for keyboard/mouse devices
;           (Page: 1, Usage: 6/2). RIDEV_CAPTUREMOUSE and RIDEV_NOHOTKEYS share the same flag value 0x00000200.
;     Consider carefully testing raw input using the RIDEV_NOLEGACY flag. It prevents all normal keyboard/mouse notifications.
; ================================================================================================================================
; GetRawInputDeviceList() -> msdn.microsoft.com/en-us/library/windows/desktop/ms645598(v=vs.85).aspx
; On success, the function returns a simple array of objects containung the following key-value pairs:
;     Handle   -  The handle to the raw input device.
;     Type     -  The type of device: 0 = TYPEMOUSE, 1 = TYPEKEYBOARD, 2 = TYPEHID
;     Page     -  The top-level collection Usage Page for the device (always 1 for type 0 and 1).
;     Usage    -  The top-level collection Usage for the device (always 2 for type 0 and 6 for type 1).
;     Name     -  The name of the device.
; ================================================================================================================================
RI_GetDeviceList() {
   Static RIM := {0: "M", 1: "K", 2: "H"} ; RIM_TYPE...
   StructSize := A_PtrSize * 2 ; size of a RAWINPUTDEVICELIST structure
   DevCount := 0
   DllCall("GetRawInputDeviceList", "Ptr", 0, "UIntP", DevCount, "UInt", StructSize)
   If (DevCount) {
      VarSetCapacity(ListArr, StructSize * DevCount, 0) ; array of RAWINPUTDEVICELIST structures
      If (DllCall("GetRawInputDeviceList", "Ptr", &ListArr, "UIntP", DevCount, "UInt", StructSize, "Int") = DevCount) {
         DevObj := {Cnt: {H: 0, K: 0, M: 0, T: DevCount}, Lst: {}} ; Cnt = counters, Lst = device list
         Addr := &ListArr
         Loop, %DevCount% {
            DevType := NumGet(Addr + A_PtrSize, "UInt")
            DevHandle := Format("0x{:X}", NumGet(Addr + 0, "UPtr"))
            DevObj.Cnt[RIM[DevType]]++
            DevObj.Lst.Push({Handle: DevHandle, Type: DevType})
            Addr += StructSize
         }
         Return DevObj
      }
   }
   Return False
}
; ================================================================================================================================
; GetRawInputDeviceInfo() -> msdn.microsoft.com/en-us/library/windows/desktop/ms645597(v=vs.85).aspx
; On success, the dunction returns the name of the device.
; ================================================================================================================================
RI_GetDeviceName(DevHandle) {
   ; RIDI_DEVICENAME = 0x20000007
   DevName := ""
   Length := 0
   DllCall("GetRawInputDeviceInfo", "Ptr", DevHandle, "UInt", 0x20000007, "Ptr", 0, "UIntP", Length)
   If (Length) {
      VarSetCapacity(DevName, Length << !!A_IsUnicode, 0)
      DllCall("GetRawInputDeviceInfo", "Ptr", DevHandle, "UInt", 0x20000007, "Str", DevName, "UIntP", Length)
   }
   Return DevName
}
; ================================================================================================================================
; GetRawInputDeviceInfo() -> msdn.microsoft.com/en-us/library/windows/desktop/ms645597(v=vs.85).aspx
; On success, the function returns an object containing the following key-value pairs:
;     All devices:
;        DevType     -  The type of device: 0 = TYPEMOUSE, 1 = TYPEKEYBOARD, 2 = TYPEHID
;        Page        -  The top-level collection Usage Page for the device (always 1 for type 0 and 1).
;        Usage       -  The top-level collection Usage for the device (always 2 for type 0 and 6 for type 1).
;     Mouse devices (DevType = 0):
;        ID          -  The identifier of the mouse device.
;        Buttons     -  The number of buttons for the mouse.
;        Rate        -  The number of data points per second. This information may not be applicable for every mouse device.
;        HWheel      -  True if the mouse has a wheel for horizontal scrolling; otherwise, False (Win Vista+).
;     Keyboard devices (DevType = 1):
;        Type        -  The type of the keyboard.
;        SubType     -  The subtype of the keyboard.
;        ScanMode    -  The scan code mode.
;        FnKeys      -  The number of function keys on the keyboard.
;        Indicators  -  The number of LED indicators on the keyboard.
;        TotalKeys   -  The total number of keys on the keyboard.
;     HID devices (DevType = 2:
;        VendorID    -  The vendor identifier for the HID.
;        ProductID   -  The product identifier for the HID.
;        Version     -  The version number for the HID.
; ================================================================================================================================
RI_GetDeviceInfo(DevHandle) {
   ; RIDI_DEVICEINFO = 0x2000000B
   Static OSV := DllCall("GetVersion", "UChar")
   DevInfo := ""
   Length := 0
   DllCall("GetRawInputDeviceInfo", "Ptr", DevHandle, "UInt", 0x2000000B, "Ptr", 0, "UIntP", Length)
   If (Length) {
      VarSetCapacity(DevInfoBuffer, Length, 0)
      If (DllCall("GetRawInputDeviceInfo", "Ptr", DevHandle, "UInt", 0x2000000B, "Ptr", &DevInfoBuffer, "UIntP", Length) > 0) {
         DevType := NumGet(DevInfoBuffer, 4, "UInt")
         If (DevType = 0) {      ; RIM_TYPEMOUSE - for the mouse, the Usage Page is 1 and the Usage is 2.
            DevInfo := {DevType: DevType}
            DevInfo.ID := NumGet(DevInfoBuffer, 8, "UInt")
            DevInfo.Buttons := NumGet(DevInfoBuffer, 12, "UInt")
            DevInfo.Rate := NumGet(DevInfoBuffer, 16, "UInt")
            DevInfo.HWheel := OSV > 5 ? NumGet(DevInfoBuffer, 20, "UInt") : 0
            DevInfo.Page := 1
            DevInfo.Usage := 2
         }
         Else If (DevType = 1) { ; RIM_TYPEKEYBOARD - for the keyboard, the Usage Page is 1 and the Usage is 6.                                                 ;
            DevInfo := {DevType: DevType}
            DevInfo.Type := NumGet(DevInfoBuffer, 8, "UInt")
            DevInfo.SubType := NumGet(DevInfoBuffer, 12, "UInt")
            DevInfo.ScanMode := NumGet(DevInfoBuffer, 16, "UInt")
            DevInfo.FnKeys := NumGet(DevInfoBuffer, 20, "UInt")
            DevInfo.Indicators := NumGet(DevInfoBuffer, 24, "UInt")
            DevInfo.TotalKeys := NumGet(DevInfoBuffer, 28, "UInt")
            DevInfo.Page := 1
            DevInfo.Usage := 6
         }
         Else If (DevType = 2) { ; RIM_TYPEHID
            DevInfo := {DevType: DevType}
            DevInfo.VendorID := NumGet(DevInfoBuffer, 8, "UInt")
            DevInfo.ProductID := NumGet(DevInfoBuffer, 12, "UInt")
            DevInfo.Version := NumGet(DevInfoBuffer, 16, "UInt")
            DevInfo.Page := NumGet(DevInfoBuffer, 20, "UShort")
            DevInfo.Usage := NumGet(DevInfoBuffer, 22, "UShort")
         }
      }
   }
   Return DevInfo
}
; ================================================================================================================================
; GetRawInputData() -> msdn.microsoft.com/en-us/library/windows/desktop/ms645596(v=vs.85).aspx
; You must pass the lParam of the WM_INPUT message as the data handle.
; On success, the function returns an object containing the following key-value pairs:
;     All devices:
;        *Keys       -  A simple array containing the valid keys for this object.
;        DevType     -  The type of device: 0 = TYPEMOUSE, 1 = TYPEKEYBOARD, 2 = TYPEHID
;        Handle      -  The handle to the device generating the raw input data.
;        Param       -  The value passed in the wParam parameter of the WM_INPUT message.
;     Mouse devices (DevType = 0) -> msdn.microsoft.com/en-us/library/windows/desktop/ms645578(v=vs.85).aspx:
;        State       -  The mouse state.
;        BtnFlags    -  The transition state of the mouse buttons.
;        BtnData     -  If BtnFlags is RI_MOUSE_WHEEL, this member is a signed value that specifies the wheel delta.
;        RawBtns     -  The raw state of the mouse buttons.
;        LastX       -  The motion in the X direction, signed relative or absolute motion, depending on the value of State.
;        LastY       -  The motion in the Y direction, signed relative or absolute motion, depending on the value of State.
;        Extra       -  The device-specific additional information for the event.
;     Keyboard devices (DevType = 1) -> msdn.microsoft.com/en-us/library/windows/desktop/ms645575(v=vs.85).aspx:
;        SC          -  The scan code from the key depression.
;        Flags       -  Flags for scan code information.
;        VK          -  Windows message compatible virtual-key code.
;        Msg         -  The corresponding window message, for example WM_KEYDOWN, WM_SYSKEYDOWN, and so forth
;        Extra       -  The device-specific additional information for the event.
;     HID devices (DevType = 2) ->  msdn.microsoft.com/en-us/library/windows/desktop/ms645549(v=vs.85).aspx:
;        Size        -  The size, in bytes, of each HID input in Data.
;        Count       -  The number of HID inputs in Data.
;        Data        -  The raw input data, as hexadecial strings separated by one space.
; ================================================================================================================================
RI_GetData(Handle) {
   ; RID_INPUT = 0x10000003
   Static Keys := {0: ["DevType", "Handle", "Param", "State", "BtnFlags", "BtnData", "RawBtns", "LastX", "LastY", "Extra"]
                 , 1: ["DevType", "Handle", "Param", "SC", "Flags", "VK", "Msg", "Extra"]
                 , 2: ["DevType", "Handle", "Param", "Size", "Count", "Data"]}
   HdrSize := 8 + (A_PtrSize * 2)
   Size := 0
   DllCall("GetRawInputData", "Ptr", Handle, "UInt", 0x10000003, "Ptr", 0, "UIntP", Size, "UInt", HdrSize)
   If (Size) {
      VarSetCapacity(Data, Size, 0)
      If (DllCall("GetRawInputData", "Ptr", Handle, "UInt", 0x10000003, "Ptr", &Data, "UIntP", Size, "UInt", HdrSize) = Size) {
         DevType := NumGet(Data, 0, "UInt")
         DataObj := {}
         DataObj["*Keys"]   := Keys[DevType]
         DataObj["DevType"] := DevType
         DataObj["Handle"]  := NumGet(Data, 8, "UPtr")
         DataObj["Param"]   := NumGet(Data, 8 + A_PtrSize, "UPtr")
         DataAddr := &Data + HdrSize
         If (DevType = 0) { ; RIM_TYPEMOUSE
            DataObj["State"]    := Format("0x{:04X}", NumGet(DataAddr + 0, "UShort"))
            DataObj["BtnFlags"] := Format("0x{:04X}", NumGet(DataAddr + 4, "UShort"))
            DataObj["BtnData"]  := Format("0x{:04X}", NumGet(DataAddr + 6, "UShort"))
            DataObj["RawBtns"]  := Format("0x{:08X}", NumGet(DataAddr + 8, "UInt"))
            DataObj["LastX"]    := NumGet(DataAddr + 12, "Int")
            DataObj["LastY"]    := NumGet(DataAddr + 16, "Int")
            DataObj["Extra"]    := Format("0x{:08X}", NumGet(DataAddr + 20, "UInt"))
            Return DataObj
         }
         If (DevType = 1) { ; RIM_TYPEKEYBOARD
            DataObj["SC"]    := Format("{:03X}", NumGet(DataAddr + 0, "UShort"))
            DataObj["Flags"] := NumGet(DataAddr + 2, "UShort")
            DataObj["VK"]    := Format("{:02X}", NumGet(DataAddr + 6, "UShort"))
            DataObj["Msg"]   := Format("0x{:04X}", NumGet(DataAddr + 8, "UInt"))
            DataObj["Extra"] := Format("0x{:08X}", NumGet(DataAddr + 12, "UInt"))
            Return DataObj
         }
         If (DevType = 2) { ; RIM_TYPEHID
            SizeHID := NumGet(DataAddr + 0, "UInt")
            CountHID := NumGet(DataAddr + 4, "UInt")
            RawData := ""
            DataAddr += 8
            Loop, %CountHID% {
               Loop, %SizeHID%
                  RawData .= Format("{:02X}", NumGet(DataAddr++, "UChar"))
               RawData .= " "
            }
            DataObj["Size"]  := SizeHID
            DataObj["Count"] := CountHID
            DataObj["Data"]  := RTrim(RawData)
            Return DataObj
         }
      }
   }
   Return False
}
; ================================================================================================================================
; GetRegisteredRawInputDevices() -> msdn.microsoft.com/en-us/library/windows/desktop/ms645599(v=vs.85).aspx
; On success, the function returns a simple array of objects containing the following key-value pairs:
;     Page     -  The top-level collection Usage Page for the device (always 1 for type 0 and 1).
;     Usage    -  The top-level collection Usage for the device (always 2 for type 0 and 6 for type 1).
;     Flags    -  The mode flag that specifies how to interpret the information provided by Page and Usage.
;     HWND     -  The handle to the target window. If NULL it follows the keyboard focus.
; ================================================================================================================================
RI_GetRegisteredDevices() {
   StructSize := 8 + A_PtrSize ; size of a RAWINPUTDEVICE structure
   DevCount := 0
   DllCall("GetRegisteredRawInputDevices", "Ptr", 0, "UIntP", DevCount, "UInt", StructSize)
   If (DevCount) {
      VarSetCapacity(DevArr, StructSize * DevCount, 0) ; array of RAWINPUTDEVICE structures
      If (DllCall("GetRegisteredRawInputDevices", "Ptr", &DevArr, "UIntP", DevCount, "UInt", StructSize, "Int") = DevCount) {
         Registered := []
         Addr := &DevArr
         Loop, %DevCount% {
            Page  := NumGet(Addr + 0, "UShort")
            Usage := NumGet(Addr + 2, "UShort")
            Flags := Format("0x{:04X}", NumGet(Addr + 4, "UInt"))
            HWND  := NumGet(Addr + 8, "UPtr")
            Registered.Push({Flags: Flags, HWND: (HWND = 0 ? HWND : Format("0x{:X}", HWND)), Page: Page, Usage: Usage})
            Addr += StructSize
         }
         Return Registered
      }
   }
   Return False
}
; ================================================================================================================================
; RegisterRawInputDevices() -> msdn.microsoft.com/en-us/library/windows/desktop/ms645600(v=vs.85).aspx
; Surprisingly, it's not possible to register devices by handle!!!
; ================================================================================================================================
RI_RegisterDevices(Page, Usage, Flags := 0, HGUI := "") {
   Flags &= 0x3731 ; valid flags
   If Flags Is Not Integer
      Return False
   If (Flags & 0x01) ; for RIDEV_REMOVE you must call RI_UnRegisterDevices()
      Return False
   StructSize := 8 + A_PtrSize ; size of a RAWINPUTDEVICE structure
   ; Usage has to be zero in case of RIDEV_PAGEONLY, flags must include RIDEV_PAGEONLY if Usage is zero.
   If ((Flags & 0x30) = 0x20)
      Usage := 0
   Else If (Usage = 0)
      Flags |= 0x20
   ; HWND needs to be zero in case of RIDEV_EXCLUDE
   If ((Flags & 0x30) = 0x10)
      HGUI := 0
   Else If (HGUI = "")
      HGUI := A_ScriptHwnd
   VarSetCapacity(RID, StructSize, 0) ; RAWINPUTDEVICE structure
   NumPut(Page,  RID, 0, "UShort")
   NumPut(Usage, RID, 2, "UShort")
   NumPut(Flags, RID, 4, "UInt")
   NumPut(HGUI,  RID, 8, "Ptr")
   Return DllCall("RegisterRawInputDevices", "Ptr", &RID, "UInt", 1, "UInt", StructSize, "UInt")
}
; ================================================================================================================================
; RegisterRawInputDevices() -> msdn.microsoft.com/en-us/library/windows/desktop/ms645600(v=vs.85).aspx
; ================================================================================================================================
RI_UnRegisterDevices(Page, Usage) {
   StructSize := 8 + A_PtrSize ; size of a RAWINPUTDEVICE structure
   Flags := Usage = 0 ? 0x21 : 0x01
   VarSetCapacity(RID, StructSize, 0) ; RAWINPUTDEVICE structure
   NumPut(Page,  RID, 0, "UShort")
   NumPut(Usage, RID, 2, "UShort")
   NumPut(Flags, RID, 4, "UInt")
   Return DllCall("RegisterRawInputDevices", "Ptr", &RID, "UInt", 1, "UInt", StructSize, "UInt")
}
; ================================================================================================================================
; RIM_... constants -> msdn.microsoft.com/en-us/library/windows/desktop/ms645581(v=vs.85).aspx
; ================================================================================================================================
RI_RIM(DevType) {
   Static RIM := {0: "TYPEMOUSE", 1: "TYPEKEYBOARD", 2: "TYPEHID", TYPEHID: 2, TYPEKEYBOARD: 1, TYPEMOUSE: 0}
   Return RIM[DevType]
}
; ================================================================================================================================
; RIDEV_... constants -> msdn.microsoft.com/en-us/library/windows/desktop/ms645565(v=vs.85).aspx
; ================================================================================================================================
RI_RIDEV(Flag) {
   Static RIDEV := {APPKEYS:      0x0400 ; only valid for keyboard devices (Page: 1, Usage: 6)
                  , CAPTUREMOUSE: 0x0200 ; only valid for mouse devices (Page: 1, Usage: 2)
                  , DEFAULT:      0x0000
                  , DEVNOTIFY:    0x2000 ; Win Vista+
                  , EXCLUDE:      0x0010
                  , EXINPUTSINK:  0x1000 ; Win Vista+
                  , INPUTSINK:    0x0100
                  , NOHOTKEYS:    0x0200 ; only valid for keyboard devices (Page: 1, Usage: 6)
                  , NOLEGACY:     0x0030 ; not valid for HID devices
                  , PAGEONLY:     0x0020
                  , REMOVE:       0x0001}
   Return RIDEV[Flag]
}
; ================================================================================================================================
; RIDEV_... constants valid for the specied device type
; ================================================================================================================================
RI_RIDEV_ForType(DevType) {
   ; H = HID, K = Keyboard (Page: 1, Usage: 6), M = Mouse (Page: 1, Usage: 2)
   Static Types := {0: "M", 1: "K", 2: "H", TYPEHID: "H", TYPEKEYBOARD: "K", TYPEMOUSE: "M"}
   Static RIDEV := {H: ["DEFAULT", "DEVNOTIFY", "EXCLUDE", "EXINPUTSINK", "INPUTSINK", "PAGEONLY", "REMOVE"]
                  , K: ["APPKEYS", "DEFAULT", "DEVNOTIFY", "EXCLUDE", "EXINPUTSINK", "INPUTSINK", "NOHOTKEYS", "NOLEGACY"
                        , "PAGEONLY", "REMOVE"]
                  , M: ["CAPTUREMOUSE", "DEFAULT", "DEVNOTIFY", "EXCLUDE", "EXINPUTSINK", "INPUTSINK", "NOLEGACY", "PAGEONLY"
                        , "REMOVE"]}
   Return RIDEV[Types[DevType]]
}