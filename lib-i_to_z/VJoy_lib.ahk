; VJoy_lib.ahk Ver1.2

    VJD_MAXDEV := 16

    ; ported from VjdStat in vjoyinterface.h
    VJD_STAT_OWN := 0   ; The  vJoy Device is owned by this application.
    VJD_STAT_FREE := 1  ; The  vJoy Device is NOT owned by any application (including this one).
    VJD_STAT_BUSY := 2  ; The  vJoy Device is owned by another application. It cannot be acquired by this application.
    VJD_STAT_MISS := 3  ; The  vJoy Device is missing. It either does not exist or the driver is down.
    VJD_STAT_UNKN := 4  ; Unknown

    ; HID Descriptor definitions(ported from public.h
    HID_USAGE_X := 0x30
    HID_USAGE_Y := 0x31
    HID_USAGE_Z := 0x32
    HID_USAGE_RX:= 0x33
    HID_USAGE_RY:= 0x34
    HID_USAGE_RZ:= 0x35
    HID_USAGE_SL0:= 0x36
    HID_USAGE_SL1:= 0x37

    VJDev := Object()

; Load lib from already load or current/system directory
VJoy_LoadLibrary() {
    Global hVJDLL
    if (hVJDLL) {
        return hVJDLL
    }

    ; Load dll from any path or get handle of already loaded
    hVJDLL := DLLCall("LoadLibrary", "Str", "libs\vJoyInterface")
    if (hVJDLL) {
        return hVJDLL
    }

    ; If dll deployed into current and it was wrong, warn
    dllpath = %A_ScriptDir%\vJoyInterface.dll
    if (FileExist(dllpath)) {
        if (A_Is64bitOS) {
            is64bit = 64-bitOS
        }
        AHKEd := (A_PtrSize = 4) ? "32-bit" : "64-bit"
        RequiredDLL := (A_PtrSize = 4) ? "x86" : "x64"
        dll_info := GetFileVersion(dllpath)
        if (dll_info and !InStr(dll_info, RequiredDLL)) {
            isWrong = =wrong!
        }
        MsgBox,
        (
LoadLibrary %dllpath% failed!
Exiting.
Make sure %RequiredDLL% vJoyInterface.dll is in %A_ScriptDir%
    (%dll_info%%isWrong%)
    AutoHotkey: %AHKEd%
    OSVersion:%A_OSVersion% %is64bit%
        )
    }
    return 0
}

GetFileVersion(pszFilePath) {
    dwSize := DLLCall("Version\GetFileVersionInfoSize", "Str", pszFilePath)
    if (!dwSize) {
        return
    }
    VarSetCapacity(pvData, dwSize)
    if (!DLLCall("Version\GetFileVersionInfo", "Str", pszFilePath
        , "Int", 0, "Int", dwSize, "Ptr", &pvData)) {
        return
    }
    ; Get British product version string
    if (!DLLCall("Version\VerQueryValue", "UInt", &pvData, "Str"
        , "\\StringFileInfo\\040904b0\\ProductVersion", "UIntP"
        , lpTranslate, "UInt", 0)) {
        return
    }
    return StrGet(lpTranslate)
}

Class VJoyDev {
    __New(dev_id) {

        Global NoticeDone, hVJDLL, VJD_STAT_OWN, VJD_STAT_FREE, VJD_STAT_BUSY, VJD_STAT_MISS, VJD_STAT_UNKN,HID_USAGE_X,HID_USAGE_Y,HID_USAGE_Z,HID_USAGE_RX,HID_USAGE_RY,HID_USAGE_RZ,HID_USAGE_SL0,HID_USAGE_SL1

        if (!hVJDLL) {
            hVJDLL := VJoy_LoadLibrary()
        }
        if (!hVJDLL) {
            if (!NoticeDone) {
                NoticeDone := True
                MsgBox, [VJoy Constructer] LoadLibrary vJoyInterface.dll failed!
            }
            return
        }

        this.DeviceEnabled := DllCall("vJoyInterface.dll\vJoyEnabled")
        if (ErrorLevel = 4) {
            MsgBox, Error! VJoy library "vJoyInterface.dll" is not found!`nErrorLevel:%ErrorLevel%
            return
        }
        if (!this.DeviceEnabled) {
           ;MsgBox, Error! VJoy interface is not installed!`nErrorLevel:%ErrorLevel%
            return
        }

        DeviceStatus := DllCall("vJoyInterface\GetVJDStatus", "UInt", dev_id)
        if (DeviceStatus = VJD_STAT_OWN) {
            stat_str = VJD_STAT_OWN
           ;ToolTip, vJoy Device %dev_id% is already owned by this feeder
        } else if (DeviceStatus = VJD_STAT_FREE) {
           ;ToolTip, vJoy Device %dev_id% is free
            stat_str = VJD_STAT_FREE
        } else if (DeviceStatus = VJD_STAT_BUSY) {
            MsgBox vJoy Device %dev_id% is already owned by another feeder`nCannot continue`n
            stat_str = VJD_STAT_BUSY
            return
        } else if (DeviceStatus = VJD_STAT_MISS) {
           ;MsgBox vJoy Device %dev_id% is not installed or disabled`nCannot continue`n
            stat_str = VJD_STAT_MISS
            return
        } else {
            stat_str = VJD_STAT_UNKN
            MsgBox vJoy Device %dev_id% general error`nCannot continue`n
            return
        }
        ;ToolTip

        ; Get the number of buttons and POV Hat switchessupported by this vJoy device
        this.ContPovNumber := DllCall("vJoyInterface\GetVJDContPovNumber", "UInt", dev_id)
        this.ContPov := Object()
        Loop, % this.ContPovNumber ; insert dummy
            this.ContPov.Insert(A_Index, 0)

        this.DiscPovNumber := DllCall("vJoyInterface\GetVJDDiscPovNumber", "UInt", dev_id)
        this.DiscPov := Object()
        Loop, % this.DiscPovNumber ; insert dummy
            this.DiscPov.Insert(A_Index, 0)

        this.NumberOfButtons := DllCall("vJoyInterface\GetVJDButtonNumber", "Int", dev_id)
        this.Btn := Object()
        Loop, % this.NumberOfButtons ; insert dummy
            this.Btn.Insert(A_Index, 0)

        this.AxisExist_X   := DllCall("vJoyInterface\GetVJDAxisExist", "Int", dev_id, "Int",   HID_USAGE_X  )
        this.AxisExist_Y   := DllCall("vJoyInterface\GetVJDAxisExist", "Int", dev_id, "Int",   HID_USAGE_Y  )
        this.AxisExist_Z   := DllCall("vJoyInterface\GetVJDAxisExist", "Int", dev_id, "Int",   HID_USAGE_Z  )
        this.AxisExist_RX  := DllCall("vJoyInterface\GetVJDAxisExist", "Int", dev_id, "Int",   HID_USAGE_RX )
        this.AxisExist_RY  := DllCall("vJoyInterface\GetVJDAxisExist", "Int", dev_id, "Int",   HID_USAGE_RY )
        this.AxisExist_RZ  := DllCall("vJoyInterface\GetVJDAxisExist", "Int", dev_id, "Int",   HID_USAGE_RZ )
        this.AxisExist_SL0 := DllCall("vJoyInterface\GetVJDAxisExist", "Int", dev_id, "Int",   HID_USAGE_SL0)
        this.AxisExist_SL1 := DllCall("vJoyInterface\GetVJDAxisExist", "Int", dev_id, "Int",   HID_USAGE_SL1)

        if (DllCall("vJoyInterface\GetVJDAxisMax", "Int", dev_id, "Int",   HID_USAGE_X,    "IntP", nResult)) {
            this.AxisMax_X := nResult
		}
        if (DllCall("vJoyInterface\GetVJDAxisMax", "Int", dev_id, "Int",   HID_USAGE_Y,    "IntP", nResult)) {
            this.AxisMax_Y := nResult
        }
        if (DllCall("vJoyInterface\GetVJDAxisMax", "Int", dev_id, "Int",   HID_USAGE_Z,    "IntP", nResult)) {
            this.AxisMax_Z := nResult
        }
        if (DllCall("vJoyInterface\GetVJDAxisMax", "Int", dev_id, "Int",   HID_USAGE_RX,   "IntP", nResult)) {
            this.AxisMax_RX := nResult
        }
        if (DllCall("vJoyInterface\GetVJDAxisMax", "Int", dev_id, "Int",   HID_USAGE_RY,   "IntP", nResult)) {
            this.AxisMax_RY := nResult
        }
        if (DllCall("vJoyInterface\GetVJDAxisMax", "Int", dev_id, "Int",   HID_USAGE_RZ,   "IntP", nResult)) {
            this.AxisMax_RZ := nResult
        }
        if (DllCall("vJoyInterface\GetVJDAxisMax", "Int", dev_id, "Int",   HID_USAGE_SL0,  "IntP", nResult)) {
            this.Slider0_Max := nResult
        }
        if (DllCall("vJoyInterface\GetVJDAxisMax", "Int", dev_id, "Int",   HID_USAGE_SL1,  "IntP", nResult)) {
            this.Slider1_Max := nResult
        }

        ; Acquire the target device
        if (DeviceStatus = VJD_STAT_FREE) {
            ac_jvd := DllCall("vJoyInterface\AcquireVJD", "UInt", dev_id)
            if (!ac_jvd) {
                MsgBox, Dev:%dev_id% aquire fail ErrorLevel: %ErrorLevel%
            }
        }

        if (DeviceStatus = VJD_STAT_OWN) {
            MsgBox % "Failed to acquire vJoy device number: " dev_id "`n(Other process owned device)"
            return
        } else if (DeviceStatus = VJD_STAT_FREE and !ac_jvd ) {
            MsgBox % "Failed to acquire vJoy device number: " dev_id "`nAcquired: " ac_jvd
            return
        } else {
           ;ToolTip, % "Acquired: vJoy device number: " dev_id
        }
       ;ToolTip

        this.DeviceID := dev_id
        this.DeviceStatus := DeviceStatus
        this.Reset()
        this.DeviceReady := True

        return this
    }

    __Delete() {
        this.Relinquish()
    }

    SetAxis(axis_val, usage) {
        res := DllCall("vJoyInterface\SetAxis", "Int", axis_val, "UInt", this.DeviceID, "UInt", usage)
        if (!res) {
            MsgBox, SetAxis(%axis_val%`,%usage%) Error!`nErrorLevel:%ErrorLevel%
        }
        return res
    }

    SetAxis_X(axis_val) {
        Global HID_USAGE_X
		new_val := parse_rel_val(axis_val, this.Axis_X, this.AxisMax_X)
        res := this.SetAxis(new_val, HID_USAGE_X)
        if (res) {
            this.Axis_X := new_val
        }
        return res
    }
    SetAxis_Y(axis_val) {
        Global HID_USAGE_Y
		new_val := parse_rel_val(axis_val, this.Axis_Y, this.AxisMax_Y)
        res := this.SetAxis(new_val, HID_USAGE_Y)
        if (res) {
            this.Axis_Y := new_val
        }
        return res
    }
    SetAxis_Z(axis_val) {
        Global HID_USAGE_Z
		new_val := parse_rel_val(axis_val, this.Axis_Z, this.AxisMax_Z)
        res := this.SetAxis(new_val, HID_USAGE_Z)
        if (res) {
            this.Axis_Z := new_val
        }
        return res
    }
    SetAxis_RX(axis_val) {
        Global HID_USAGE_RX
		new_val := parse_rel_val(axis_val, this.Axis_RX, this.AxisMax_RX)
        res := this.SetAxis(new_val, HID_USAGE_RX)
        if (res) {
            this.Axis_RX := new_val
        }
        return res
    }
    SetAxis_RY(axis_val) {
        Global HID_USAGE_RY
		new_val := parse_rel_val(axis_val, this.Axis_RY, this.AxisMax_RY)
        res := this.SetAxis(new_val, HID_USAGE_RY)
        if (res) {
            this.Axis_RY := new_val
        }
        return res
    }
    SetAxis_RZ(axis_val) {
        Global HID_USAGE_RZ
		new_val := parse_rel_val(axis_val, this.Axis_RZ, this.AxisMax_RZ)
        res := this.SetAxis(new_val, HID_USAGE_RZ)
        if (res) {
            this.Axis_RZ := new_val
        }
        return res
    }
    SetAxis_SL0(axis_val) {
        Global HID_USAGE_SL0
		new_val := parse_rel_val(axis_val, this.Axis_SL0, this.AxisMax_SL0)
        res := this.SetAxis(new_val, HID_USAGE_SL0)
        if (res) {
            this.Slider0 := new_val
        }
        return res
    }
    SetAxis_SL1(axis_val) {
        Global HID_USAGE_SL1
		new_val := parse_rel_val(axis_val, this.Axis_SL1, this.AxisMax_SL1)
        res := this.SetAxis(new_val, HID_USAGE_SL1)
        if (res) {
            this.Slider1 := new_val
        }
        return res
    }

    GetBtn(bid) {
        if (bid < 1 or bid > this.NumberOfButtons) {
            return 0
        }
        return this.Btn[bid]
    }

    SetBtn(sw, btn_id) {
        if (btn_id < 1 or btn_id > this.NumberOfButtons) {
            MsgBox, SetBtn: range check error!
            return 0
        }
        res := DllCall("vJoyInterface\SetBtn", "Int", sw, "UInt", this.DeviceID, "UChar", btn_id)
        if (res) {
            this.Btn[btn_id] := sw
        }
        return res
    }

    SetDiscPov(Value, nPov) {
        _res := DllCall("vJoyInterface\SetDiscPov", "Int", Value, "UInt", this.DeviceID, "UChar", nPov)
        if (!_res) {
            MsgBox, SetDiscPov err: %ErrorLevel%
        } else {
            this.DiscPov[nPov] := Value
        }
        return _res
    }

    SetContPov(Value, nPov) {
        _res := DllCall("vJoyInterface\SetContPov", "Int", Value, "UInt", this.DeviceID, "UChar", nPov)
        if (!_res) {
            MsgBox, SetContPov err: %ErrorLevel%
        } else {
            this.ContPov[nPov] := Value
        }
        return _res
    }

    Reset() {
        ; Reset local state values
        this.Axis_X := 0
        this.Axis_Y := 0
        this.Axis_Z := 0
        this.Axis_RX := 0
        this.Axis_RY := 0
        this.Axis_RZ := 0
        this.Slider0 := 0
        this.Slider1 := 0

        for i in this.ContPov
            this.ContPov[i] := 0
        for i in this.DiscPov
            this.DiscPov[i] := 0
        for i in this.Btn
            this.Btn[i] := 0
        return DllCall("vJoyInterface\ResetVJD", "UInt", this.DeviceID)
    }

    Relinquish() {
        return DllCall("vJoyInterface\RelinquishVJD", "UInt", this.DeviceID)
    }
}

VJoy_init(id := 1) {
    Global VJDev, VJD_MAXDEV
    if (id < 1 || id > VJD_MAXDEV) {
        MsgBox, [%A_ThisFunc%] Device %id% is invalid. Please specify 1-%VJD_MAXDEV%.
        return
    }
    VJDev[id] := new VJoyDev(id)
    return VJDev[id]
}

VJoy_DeviceErr(id) {
    Global VJD_MAXDEV, VJDev
    if (id < 1 or id > VJD_MAXDEV) {
        MsgBox, [%A_ThisFunc%] Device %id% is invalid. Please specify 1-%VJD_MAXDEV%.
        return True
    }
    if (!VJDev[id].DeviceReady) {
        MsgBox, [%A_ThisFunc%] Device %id% is not ready.
        return True
    }
    return False
}
VJoy_Ready(id) {
    Global VJD_MAXDEV, VJDev
    if (id < 1 || id > VJD_MAXDEV) {
        return False
    }
    return VJDev[id].DeviceReady
}

VJoy_ResetVJD(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].Reset()
}

VJoy_ResetAll() {
    return DllCall("vJoyInterface\ResetAll")
}

; Release device
VJoy_RelinquishVJD(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].Relinquish()
}

; destructor
VJoy_Close() {
    Global VJDev

    VJoy_ResetAll()

    for idx, dev in VJDev
        dev.delete
    if (hVJDLL) {
        DLLCall("FreeLibraly", "Ptr", hVJDLL)
        hVJDLL:=
    }
}

VJoy_GetContPovNumber(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].ContPovNumber
}

VJoy_GetDiscPovNumber(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].DiscPovNumber
}

VJoy_GetVJDButtonNumber(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].NumberOfButtons
}

VJoy_GetAxisExist_X(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisExist_X
}
VJoy_GetAxisExist_Y(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisExist_Y
}
VJoy_GetAxisExist_Z(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisExist_Z
}
VJoy_GetAxisExist_RX(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisExist_RX
}
VJoy_GetAxisExist_RY(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisExist_RY
}
VJoy_GetAxisExist_RZ(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisExist_RZ
}
VJoy_GetAxisExist_SL0(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisExist_SL0
}
VJoy_GetAxisExist_SL1(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisExist_SL1
}


VJoy_GetAxisMax_X(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisMax_X
}
VJoy_GetAxisMax_Y(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisMax_Y
}
VJoy_GetAxisMax_Z(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisMax_Z
}
VJoy_GetAxisMax_RX(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisMax_RX
}
VJoy_GetAxisMax_RY(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisMax_RY
}
VJoy_GetAxisMax_RZ(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].AxisMax_RZ
}
VJoy_GetAxisMax_SL0(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].Slider0_Max
}
VJoy_GetAxisMax_SL1(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].Slider1_Max
}

; for compatibility
VJoy_GetVJDAxisMax(id, usage) {

    Global VJDev, HID_USAGE_X,HID_USAGE_Y,HID_USAGE_Z,HID_USAGE_RX,HID_USAGE_RY,HID_USAGE_RZ,HID_USAGE_SL0,HID_USAGE_SL1
    if (VJoy_DeviceErr(id))
        return False

	if (usage == HID_USAGE_X){
		return VJDev[id].AxisMax_X
	} else if (usage == HID_USAGE_Y){
		return VJDev[id].AxisMax_Y
	} else if (usage == HID_USAGE_Z){
		return VJDev[id].AxisMax_Z
	} else if (usage == HID_USAGE_RX){
		return VJDev[id].AxisMax_RX
	} else if (usage == HID_USAGE_RY){
		return VJDev[id].AxisMax_RY
	} else if (usage == HID_USAGE_RZ){
		return VJDev[id].AxisMax_RZ
	} else if (usage == HID_USAGE_SL0){
		return VJDev[id].AxisMax_SL0
	} else if (usage == HID_USAGE_SL1){
		return VJDev[id].AxisMax_SL1
	} else {
		MsgBox, [%A_ThisFunc%] Unknown Axis: %usage%
	}
}

VJoy_GetVJDAxisExist(id, usage) {

    Global VJDev, HID_USAGE_X,HID_USAGE_Y,HID_USAGE_Z,HID_USAGE_RX,HID_USAGE_RY,HID_USAGE_RZ,HID_USAGE_SL0,HID_USAGE_SL1
    if (VJoy_DeviceErr(id))
        return False

	if (usage == HID_USAGE_X){
		return VJDev[id].AxisExist_X
	} else if (usage == HID_USAGE_Y){
		return VJDev[id].AxisExist_Y
	} else if (usage == HID_USAGE_Z){
		return VJDev[id].AxisExist_Z
	} else if (usage == HID_USAGE_RX){
		return VJDev[id].AxisExist_RX
	} else if (usage == HID_USAGE_RY){
		return VJDev[id].AxisExist_RY
	} else if (usage == HID_USAGE_RZ){
		return VJDev[id].AxisExist_RZ
	} else if (usage == HID_USAGE_SL0){
		return VJDev[id].AxisExist_SL0
	} else if (usage == HID_USAGE_SL1){
		return VJDev[id].AxisExist_SL1
	} else {
		MsgBox, [%A_ThisFunc%] Unknown Axis: %usage%
	}
}

VJoy_GetBtn(id, btn_id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].GetBtn(btn_id)
}

VJoy_SetBtn(sw, id, btn_id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    res := VJDev[id].SetBtn(sw, btn_id)
    if (!res) {
        MsgBox, SetBtn(%sw%, %id%, %btn_id%) err: %ErrorLevel%`nnLastError: %A_LastError%
    }
    return res
}

VJoy_GetAxis_X(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].Axis_X
}
VJoy_GetAxis_Y(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].Axis_Y
}
VJoy_GetAxis_Z(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].Axis_Z
}
VJoy_GetAxis_RX(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].Axis_RX
}
VJoy_GetAxis_RY(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].Axis_RY
}
VJoy_GetAxis_RZ(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].Axis_RZ
}
VJoy_GetAxis_SL0(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].Slider0
}
VJoy_GetAxis_SL1(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].Slider1
}

VJoy_SetAxis_X(axis_val, id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].SetAxis_X(axis_val)
}
VJoy_SetAxis_Y(axis_val, id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].SetAxis_Y(axis_val)
}
VJoy_SetAxis_Z(axis_val, id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].SetAxis_Z(axis_val)
}
VJoy_SetAxis_RX(axis_val, id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].SetAxis_RX(axis_val)
}
VJoy_SetAxis_RY(axis_val, id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].SetAxis_RY(axis_val)
}
VJoy_SetAxis_RZ(axis_val, id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].SetAxis_RZ(axis_val)
}
VJoy_SetAxis_SL0(axis_val, id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].SetAxis_SL0(axis_val)
}
VJoy_SetAxis_SL1(axis_val, id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].SetAxis_SL1(axis_val)
}

; for compatibility
VJoy_SetAxis(axis_val, id, usage) {
    Global VJDev, HID_USAGE_X,HID_USAGE_Y,HID_USAGE_Z,HID_USAGE_RX,HID_USAGE_RY,HID_USAGE_RZ,HID_USAGE_SL0,HID_USAGE_SL1
    if (VJoy_DeviceErr(id))
        return False

	if (usage == HID_USAGE_X){
		return VJDev[id].SetAxis_X(axis_val)
	} else if (usage == HID_USAGE_Y){
		return VJDev[id].SetAxis_Y(axis_val)
	} else if (usage == HID_USAGE_Z){
		return VJDev[id].SetAxis_Z(axis_val)
	} else if (usage == HID_USAGE_RX){
		return VJDev[id].SetAxis_RX(axis_val)
	} else if (usage == HID_USAGE_RY){
		return VJDev[id].SetAxis_RY(axis_val)
	} else if (usage == HID_USAGE_RZ){
		return VJDev[id].SetAxis_RZ(axis_val)
	} else if (usage == HID_USAGE_SL0){
		return VJDev[id].SetAxis_SL0(axis_val)
	} else if (usage == HID_USAGE_SL1){
		return VJDev[id].SetAxis_SL1(axis_val)
	} else {
		MsgBox, [%A_ThisFunc%] Unknown Axis: %usage%
	}
}

VJoy_GetDiscPov(id, nPov) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].DiscPov[nPov]
}
VJoy_SetDiscPov(Value, id, nPov) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].SetDiscPov(Value, nPov)
}

VJoy_GetContPov(id, nPov) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].ContPov[nPov]
}
VJoy_SetContPov(Value, id, nPov) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False
    return VJDev[id].SetContPov(Value, nPov)
}

; for debug: dump value of structure
VJoy_Dump(id) {
    Global VJDev
    if (VJoy_DeviceErr(id))
        return False

    num := VJoy_GetVJDButtonNumber(id)
    for idx, btn in VJDev[id].Btn
    {
        if (idx<10)
            buf1 .= "_"
        buf1 .= idx . "|"
        buf2 .= "_" . btn . "|"
    }
    str_btn = Button(%num%):`n  %buf1%`n  %buf2%`n

    if (VJoy_GetAxisMax_X(id)) {
        str_btn .= "Axis_X: " . VJoy_GetAxis_X(id) . "`n"
    }
    if (VJoy_GetAxisMax_Y(id)) {
        str_btn .= "Axis_Y: " . VJoy_GetAxis_Y(id) . "`n"
    }
    if (VJoy_GetAxisMax_Z(id)) {
        str_btn .= "Axis_Z: " . VJoy_GetAxis_Z(id) . "`n"
    }
    if (VJoy_GetAxisMax_RX(id)) {
        str_btn .= "Axis_RX: " . VJoy_GetAxis_RX(id) . "`n"
    }
    if (VJoy_GetAxisMax_RY(id)) {
        str_btn .= "Axis_RY: " . VJoy_GetAxis_RY(id) . "`n"
    }
    if (VJoy_GetAxisMax_RZ(id)) {
        str_btn .= "Axis_RZ: " . VJoy_GetAxis_RZ(id) . "`n"
    }
    if (VJoy_GetAxisMax_SL0(id)) {
        str_btn .= "Axis_SL0: " . VJoy_GetAxis_SL0(id) . "`n"
    }
    if (VJoy_GetAxisMax_SL1(id)) {
        str_btn .= "Axis_SL1: " . VJoy_GetAxis_SL1(id) . "`n"
    }

    num := VJoy_GetContPovNumber(id)
    if (num) {
        for idx, btn in VJDev[id].ContPov
        {
            Loop, % (StrLen(btn) - 1)
                buf3 .= "_"
            buf3 .= idx . "|"
            buf4 .= btn . "|"
        }
        str_cont = ContPov(%num%):`n  %buf3%`n  %buf4%`n
    } else {
        str_cont = No Continuous Button.`n
    }
    str_btn .= str_cont

    num := VJoy_GetDiscPovNumber(id)
    if (num) {
        for idx, btn in VJDev[id].DiscPov
        {
            Loop, % (StrLen(btn) - 1)
                buf5 .= "_"
            buf5 .= idx . "|"
            buf6 .= btn . "|"
        }
        str_Disc = DiscPov(%num%):`n  %buf5%`n  %buf6%`n
    } else {
        str_Disc = No Discrete Button.`n
    }
    str_btn .= str_Disc
    ToolTip, %str_btn%
}

parse_rel_val(invar, curval, max) {
    if (InStr(invar, "+")) {
        StringReplace, _buffer, invar, +
        res := curval + _buffer
        if (res > max)
            return max
        return res
    } else if (InStr(invar, "-")) {
        StringReplace, _buffer, invar, -
        res := curval - _buffer
        if (res < 0)
            return 0
        return res
    }
    return invar
}