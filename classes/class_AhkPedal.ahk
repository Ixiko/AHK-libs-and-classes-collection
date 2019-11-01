; Facility for scripting foot pedals.

; This library was adapted from a script at
; http://musingsfromtheunderground.blogspot.com/2011/05/dream-autohotkey-powered-foot-pedal-for.html
; with the modifications for 64-bit coming from 
; https://autohotkey.com/board/topic/91506-broken-dllcall-to-registerrawinputdevices/

class AhkPedal {
    class Handler {
        __New(press) {
            this.Press := press
            this.Release := release
        }
    }

    MessageFunc := 
    AllowRelease := true
    Handlers := []
    LastInput := 0x00

    __New(allowRelease:=true) {
        this.AllowRelease := allowRelease
        this.MessageFunc := ObjBindMethod(this, "_InputMessage")
        OnMessage(0x00FF, this.MessageFunc)
        this._RegisterHIDDevice(12, 3)
    }

    SetHandler(i, onPress:="", onRelease:="") {
        if (not onPress and not onRelease)
            throw "neither onPress nor onRelease set when calling SetHandler"
        if (onPress)
            this.Handlers[i, 0] := onPress
        if (onRelease)
            this.Handlers[i, 1] := onRelease
    }

    _ProcessPedalInput(input) {
        input := input//100

        if (this.AllowRelease) {
            if (input > this.LastInput) {
                idx := 0
                newInput := (this.LastInput & input) ^ input
            } else {
                idx := 1
                newInput := (this.LastInput & input) ^ this.LastInput 
            }
        } else {
            idx := 0
            newInput := input
        }

        if (newInput & 0x1)
            Func(this.Handlers[0,idx]).Call()
        if (newInput & 0x2)
            Func(this.Handlers[1,idx]).Call()
        if (newInput & 0x4)
            Func(this.Handlers[2,idx]).Call()

        this.LastInput := input
    } 

    _InputMessage(wParam, lParam, msg, hwnd) {
        ridInput := 0x10000003
        rimTypeHid := 2
        ridiDeviceInfo := 0x2000000b
        headerSize := 8 + A_PtrSize + A_PtrSize
        ridDeviceInfoSize := 32
        pcbSize :=

        DllCall("GetRawInputData", "Ptr", lParam, "UInt", ridInput, "Ptr", 0, "UIntP", pcbSize, "UInt", headerSize, "UInt")
        VarSetCapacity(buffer, pcbSize)
        DllCall("GetRawInputData", "Ptr", lParam, "UInt", ridInput, "Ptr", &buffer, "UIntP", pcbSize, "UInt", headerSize, "UInt")

        rimType := NumGet(Buffer, 0 * 4, "UInt")
        pcbSize := NumGet(Buffer, 1 * 4, "UInt")
        handle := NumGet(Buffer, 2 * 4, "UPtr")

        VarSetCapacity(info, ridDeviceInfoSize)
        NumPut(ridDeviceInfoSize, info, 0)
        length := ridDeviceInfoSize

        DllCall("GetRawInputDeviceInfo", "Ptr", handle, "UInt", ridiDeviceInfo, "Ptr", &info, "UIntP", ridDeviceInfoSize)

        vendorId := NumGet(Info, 4 * 2, "UInt")
        product := NumGet(Info, 4 * 3, "UInt")

        if (rimType == rimTypeHid) {
            sizeHid := NumGet(buffer, (headerSize + 0), "UInt")
            inputCount := NumGet(buffer, headerSize + 4, "UInt")
            Loop %InputCount% {
                addr := &buffer + headerSize + 8 + ((A_Index - 1) * sizeHid)
                bAddr := &buffer
                input := this._Mem2Hex(addr, sizeHid)
                if (vendorId == 1523 && product == 255)
                    this._ProcessPedalInput(input)
                else if (IsLabel(Input))
                    Gosub, %Input%
            }
        }
    }

    _Mem2Hex(pointer, len) {
        A_FI := A_FormatInteger
        SetFormat, Integer, Hex

        hexDump :=
        Loop, %len% {
            hex := *pointer+0
            StringReplace, hex, hex, 0x, 0x0
            StringRight hex, hex, 2
            hexDump := hexDump . hex
            pointer++
        }

        SetFormat, Integer, %A_FI%
        StringUpper, hexDump, hexDump
        Return hexDump
    }

    ; Keyboards are always Usage 6, Usage Page 1, Mice are Usage 2, Usage Page 1,
    ; HID devices specify their top level collection in the info block
    _RegisterHIDDevice(usagePage, usage) {
        ridevFlags := 0x00000100
        DetectHiddenWindows, on
        hwnd := WinExist("ahk_class AutoHotkey ahk_pid " DllCall("GetCurrentProcessId"))
        DetectHiddenWindows, off

        VarSetCapacity(rawDevice, 8 + A_PtrSize)
        NumPut(usagePage, rawDevice, 0, "UShort")
        NumPut(usage, rawDevice, 2, "UShort")
        NumPut(ridevFlags, rawDevice, 4, "UInt")
        NumPut(hwnd, rawDevice, 8, "UPtr")

        res := DllCall("RegisterRawInputDevices", "Ptr", &rawDevice, "UInt", 1, "UInt", 8 + A_PtrSize, "UInt")
        if (res == 0)
            MsgBox % "Failed to register raw input device."
    }
}
