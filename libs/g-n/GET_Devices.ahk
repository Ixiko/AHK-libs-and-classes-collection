; INFO =========================================================================
/*
Functions for identify devices from two different directions
(SetupAPI and DriveLetter) and compare.

Infos:
https://docs.microsoft.com/de-de/windows-hardware/drivers/install/device-information-sets

*/

; WINDOWS FLAGS ================================================================
; SetupAPI.h
global DIGCF_DEFAULT           :=      0x00000001  ; only valid with DIGCF_DEVICEINTERFACE
global DIGCF_PRESENT           :=      0x00000002
global DIGCF_ALLCLASSES        :=      0x00000004
global DIGCF_PROFILE           :=      0x00000008
global DIGCF_DEVICEINTERFACE   :=      0x00000010

;Windows.h
global GENERIC_READ            :=      0x80000000
global GENERIC_WRITE           :=      0x40000000
global GENERIC_EXECUTE         :=      0x20000000
global GENERIC_ALL             :=      0x10000000

global FILE_SHARE_READ         :=      0x00000001
global FILE_SHARE_WRITE        :=      0x00000002
global FILE_SHARE_DELETE       :=      0x00000004

global CREATE_NEW              :=      1
global CREATE_ALWAYS           :=      2
global OPEN_EXISTING           :=      3
global OPEN_ALWAYS             :=      4
global TRUNCATE_EXISTING       :=      5

;Ntddstor.h
global IOCTL_STORAGE_GET_DEVICE_NUMBER := 0x2D1080


; FUNCTIONS ====================================================================
GetDevices_from_SetupAPI()
{


    ; DEFINE ===================================================================
    ; DEVICEINFOLIST -----------------------------------------------------------
    ; variable holding "device setup class" or "device interface class" GUID
    ; The GUID_DEVINTERFACE_DISK device interface class is defined for hard disk storage devices.
    VarSetCapacity(GUID_DEVINTERFACE_DISK, 16)
    ,DllCall("ole32\CLSIDFromString", "Str", "{53F56307-B6BF-11D0-94F2-00A0C91EFB8B}", "Ptr", &GUID_DEVINTERFACE_DISK) ; fill in fmtid member of DEVPROPKEY struct


    ; DEVICEINFO ---------------------------------------------------------------
    ; structure SP_DEVINFO_DATA (SP_DEVINFO_DATA structure)
    StructSize := 4 + 16 + 4 + A_PtrSize
    ,VarSetCapacity(SP_DEVINFO_DATA, StructSize, 0)
    ,NumPut(StructSize, SP_DEVINFO_DATA, 0, "UInt") ; fill in cbSize

    ; structure DEVPKEY_Device_FriendlyName (DEVPROPKEY structure)
    VarSetCapacity(DEVPKEY_Device_FriendlyName, 20) ; you might consider looking at DEVPKEY_Device_BusReportedDeviceDesc too/instead
    ,DllCall("ole32\CLSIDFromString", "Str", "{A45C254E-DF1C-4EFD-8020-67D146A850E0}", "Ptr", &DEVPKEY_Device_FriendlyName)
    ,NumPut(14, DEVPKEY_Device_FriendlyName, 16, "UInt")


    ; DEVICEINTERFACE ----------------------------------------------------------
    ; structure SP_DEVICE_INTERFACE_DATA (SP_DEVICE_INTERFACE_DATA structure)
    StructSize := 4 + 16 + 4 + A_PtrSize
    ,VarSetCapacity(SP_DEVICE_INTERFACE_DATA, StructSize, 0)
    ,NumPut(StructSize, SP_DEVICE_INTERFACE_DATA, 0, "UInt") ; fill in cbSize

    ; structure SP_DEVICE_INTERFACE_DETAIL_DATA (SP_DEVICE_INTERFACE_DETAIL_DATA structure)
    ; defined and allocated on call SetupDiGetDeviceInterfaceDetail


    ; DEVICEHANDEL -------------------------------------------------------------
    ; structure STORAGE_DEVICE_NUMBER (STORAGE_DEVICE_NUMBER structure)
    StructSize := 4 + 4 + 4
    ,VarSetCapacity(STORAGE_DEVICE_NUMBER, StructSize, 0)


    ; SAVE RESULT ----------------------------------------------------------
    ; multidimensional array holding result (DevicePath + Device Number)
    i_disk_seApi := Object() ; index disk trough setupapi


    ; MAIN =====================================================================
    ; Ensure setupapi.dll remains loaded between each DllCall
    hModule := DllCall("LoadLibrary", "Str", "setupapi.dll", "Ptr")
    if (!hModule) {
        MsgBox % "LoadLibrary failed. A_LastError: " . A_LastError
        ExitApp 1
    }

    ; get handle (DeviceInfoList)
    handle := DllCall("setupapi\SetupDiGetClassDevs", "Ptr", &GUID_DEVINTERFACE_DISK, "Ptr", 0, "Ptr", 0, "UInt", DIGCF_PRESENT | DIGCF_DEVICEINTERFACE, "Ptr")
    If (!handle) {
        MsgBox SetupDiGetClassDevs call failed.`nReturn value: %r%`nErrorLevel: %ErrorLevel%`nLine: %A_LineNumber%`nLast Error: %A_LastError%
    }

    ; enumerate devices from DeviceInfoList
    Loop
    {
        ; GET DEVICE INTERFACE INFO --------------------------------------------
        ; clear previous variables, in case a call fails
        devicePath := device_number := ""

        ; get SP_DEVICE_INTERFACE_DATA
        If (!DllCall("setupapi\SetupDiEnumDeviceInterfaces", "Ptr", handle, "Ptr", 0, "Ptr", &GUID_DEVINTERFACE_DISK, "UInt", A_Index - 1, "Ptr", &SP_DEVICE_INTERFACE_DATA )) {
            If (A_LastError != 259) ;ERROR_NO_MORE_ITEMS
                MsgBox SetupDiEnumDeviceInterfaces call failed.`nReturn value: %r%`nErrorLevel: %ErrorLevel%`nLine: %A_LineNumber%`nLast Error: %A_LastError%`nA_Index: %A_Index%
            break
        }

        ; get devicePath
        if (!DllCall("setupapi\SetupDiGetDeviceInterfaceDetail", "Ptr", handle, "Ptr", &SP_DEVICE_INTERFACE_DATA, "Ptr", 0, "UInt", 0, "UInt*", RequiredSize, "Ptr", 0) && A_LastError == 122) { ; ERROR_INSUFFICIENT_BUFFER
            VarSetCapacity(SP_DEVICE_INTERFACE_DETAIL_DATA, RequiredSize)
            ; fill in cbSize ;very bad solution, needs a better detection ; See: https://stackoverflow.com/questions/10728644/properly-declare-sp-device-interface-detail-data-for-pinvoke
            If (A_PtrSize == 8)
                NumPut(8, SP_DEVICE_INTERFACE_DETAIL_DATA, 0, "UInt")
            else if (A_PtrSize == 4 && A_IsUnicode)
                NumPut(6, SP_DEVICE_INTERFACE_DETAIL_DATA, 0, "UInt")
            else
                NumPut(5, SP_DEVICE_INTERFACE_DETAIL_DATA, 0, "UInt")

            if (!DllCall("setupapi\SetupDiGetDeviceInterfaceDetail", "Ptr", handle, "Ptr", &SP_DEVICE_INTERFACE_DATA, "Ptr", &SP_DEVICE_INTERFACE_DETAIL_DATA, "UInt", RequiredSize, "Ptr", &RequiredSize, "Ptr", 0))
                MsgBox SetupDiGetDeviceInterfaceDetail (SP_DEVICE_INTERFACE_DETAIL_DATA) call failed.`nReturn value: %r%`nErrorLevel: %ErrorLevel%`nLine: %A_LineNumber%`nLast Error: %A_LastError%`nA_Index: %A_Index%
        }
        else
            MsgBox SetupDiGetDeviceInterfaceDetail (get size) call failed.`nReturn value: %r%`nErrorLevel: %ErrorLevel%`nLine: %A_LineNumber%`nLast Error: %A_LastError%`nA_Index: %A_Index%

        devicePath := StrGet(&SP_DEVICE_INTERFACE_DETAIL_DATA+4, "UTF-16")


        ; GET DEVICE INFO ------------------------------------------------------
        ; clear previous variables, in case a call fails
        FriendlyName := ""

        ; get SP_DEVINFO_DATA
        If (!DllCall("setupapi.dll\SetupDiEnumDeviceInfo", "Ptr", handle, "UInt", A_Index - 1, "Ptr", &SP_DEVINFO_DATA)) {
            If (A_LastError != 259) ;ERROR_NO_MORE_ITEMS
                MsgBox SetupDiEnumDeviceInfo call failed.`nReturn value: %r%`nErrorLevel: %ErrorLevel%`nLine: %A_LineNumber%`nLast Error: %A_LastError%`nA_Index: %A_Index%
            break
        }

        ; get property
        if (!DllCall("setupapi\SetupDiGetDeviceProperty", "Ptr", handle, "Ptr", &SP_DEVINFO_DATA, "Ptr", &DEVPKEY_Device_FriendlyName, "UInt*", PropType, "Ptr", 0, "UInt", 0, "UInt*", RequiredSize, "UInt", 0) && A_LastError == 122) { ; ERROR_INSUFFICIENT_BUFFER
            VarSetCapacity(FriendlyName, RequiredSize)
            if (!DllCall("setupapi\SetupDiGetDeviceProperty", "Ptr", handle, "Ptr", &SP_DEVINFO_DATA, "Ptr", &DEVPKEY_Device_FriendlyName, "UInt*", PropType, "Str", FriendlyName, "UInt", RequiredSize, "Ptr", 0, "UInt", 0))
                MsgBox SetupDiGetDevicePropertyW (DEVPKEY_Device_FriendlyName) call failed.`nReturn value: %r%`nErrorLevel: %ErrorLevel%`nLine: %A_LineNumber%`nLast Error: %A_LastError%`nA_Index: %A_Index%
        }

        ; GET DEVICE HANDLER ---------------------------------------------------
        ; kernel32.dll is automatically loaded with AHK
        device_handle := DllCall("CreateFile", "Str", devicePath, "UInt", 0, "UInt", FILE_SHARE_WRITE, "Ptr", NULL, "UInt", OPEN_EXISTING, "UInt", 0, "Ptr", NULL)
        if (device_handle = -1)
            MsgBox CreateFile call failed.`nReturn value: %r%`nErrorLevel: %ErrorLevel%`nLine: %A_LineNumber%`nLast Error: %A_LastError%`nA_Index: %A_Index%

        ; get device number
        if (DllCall("DeviceIoControl", "Ptr", device_handle, "UInt", IOCTL_STORAGE_GET_DEVICE_NUMBER, "Ptr", 0, "UInt", 0, "Ptr", &STORAGE_DEVICE_NUMBER, "UInt", 12, "UInt*", RequiredSize, "Ptr", 0))
            device_number := NumGet(&STORAGE_DEVICE_NUMBER, 4, "UInt")
        else
            MsgBox DeviceIoControl call failed.`nReturn value: %r%`nErrorLevel: %ErrorLevel%`nLine: %A_LineNumber%`nLast Error: %A_LastError%`nA_Index: %A_Index%


        ; Save -----------------------------------------------------------------
        if (devicePath && (device_number || device_number == 0)) {
            i_disk_seApi[A_Index] := {devicePath: devicePath, device_number: device_number, FriendlyName: FriendlyName}
        }
        else
            continue

    }

    ; destroy handle (DeviceInfoList)
    DllCall("setupapi\SetupDiDestroyDeviceInfoList", "Ptr", handle)  ; you don't need error checking here: if it frees, it frees. No point in otherwise fretting. You already checked to see if handle != NULL and you got the DllCall right for this function

    ; Unload setupapi.dll
    DllCall("FreeLibrary", "Ptr", hModule)

    return i_disk_seApi
}

GetDevices_from_driveLetters()
{
    ; DEFINE ==================================================================
    ; multidimensional array holding result (DevicePath + Device Number)
    i_disk_letter := Object() ; index disk trough drive letter

    ; string holding drive path prefix
    drivePrefix := "\\?\"

    ; array holding drive letters
    driveLetters := Object()
    driveLetters.Push("A:","B:","C:","D:","E:","F:","G:","H:","I:","J:","K:","L:","M:","N:","O:","P:","Q:","R:","S:","T:","U:","V:","W:","X:","Y:","Z:")

    ; structure STORAGE_DEVICE_NUMBER (STORAGE_DEVICE_NUMBER structure)
    StructSize := 4 + 4 + 4
    ,VarSetCapacity(STORAGE_DEVICE_NUMBER, StructSize, 0)


    ; MAIN =====================================================================
    ; enumerate devices from drive letter
    for v, k in driveLetters
    {
        ; clear previous variables, in case a call fails
        devicePath := device_number := ""

        ; join to device Path
        devicePath := drivePrefix . k

        ; get device handel from drive letter (kernel32.dll is automatically loaded with AHK)
        device_handle := DllCall("CreateFile", "Str", devicePath, "UInt", 0, "UInt", FILE_SHARE_WRITE, "Ptr", NULL, "UInt", OPEN_EXISTING, "UInt", 0, "Ptr", NULL)
            if (device_handle = -1) {
                If (A_LastError != 2)
                    MsgBox CreateFile call failed.`nReturn value: %r%`nErrorLevel: %ErrorLevel%`nLine: %A_LineNumber%`nLast Error: %A_LastError%`nA_Index: %A_Index%
                continue
            }

        ; get device number
        if (DllCall("DeviceIoControl", "Ptr", device_handle, "UInt", IOCTL_STORAGE_GET_DEVICE_NUMBER, "Ptr", 0, "UInt", 0, "Ptr", &STORAGE_DEVICE_NUMBER, "UInt", 12, "UInt*", RequiredSize, "Ptr", 0)) {
            if (NumGet(&STORAGE_DEVICE_NUMBER, 0, "UInt") == 7) ; is FILE_DEVICE_DISK
                device_number := NumGet(&STORAGE_DEVICE_NUMBER, 4, "UInt")
            else
                continue
        }
        else
            MsgBox DeviceIoControl call failed.`nReturn value: %r%`nErrorLevel: %ErrorLevel%`nLine: %A_LineNumber%`nLast Error: %A_LastError%`nA_Index: %A_Index%

        ; save result
        if (devicePath && (device_number || device_number == 0)) {
            i_disk_letter[v] := {devicePath: devicePath, device_number: device_number}
        }
        else
            continue
    }
    return i_disk_letter
}

notify_change()
{


    ; DEFINE ===================================================================
    USB_device_number := ""
    USB_drive_letter := Object()


    ; MAIN =====================================================================
    ;wait for full attachment
    Sleep, 2500 ;need a better solution

    i_disk_seApi := GetDevices_from_SetupAPI()
    i_disk_letter := GetDevices_from_driveLetters()

    ; compare results, to get device number of USB Stick
    for k, v in i_disk_seApi {
        if (v.devicePath == USB_ident)
            USB_device_number := v.device_number
    }

    ; compare results, get drive Letters of USB Stick
    count := 0
    for k, v in i_disk_letter {
        if (v.device_number == USB_device_number) {
            USB_drive_letter[count++] := LTrim(v.devicePath, "\?")
        }
    }

    ; Debug
    /*
    ; display result 1
    for k, v in i_disk_seApi {
        for k2, v2 in v {
            Msgbox, Index: %k%`nKey: %k2%`nValue: %v2%
        }
    }

    ; display result 2
    for k, v in i_disk_letter {
        for k2, v2 in v {
            Msgbox, Index: %k%`nKey: %k2%`nValue: %v2%
        }
    }
     */

    ; check if found and not already attached
    If(USB_drive_letter.GetCapacity() && !state_attached) {
        state_attached := 1
        Execute(USB_drive_letter, count)
    }
    else if(!USB_drive_letter.GetCapacity()){
        state_attached := 0
    }

    ;discard any new call in time
    Sleep, 2500 ;need a better solution
}