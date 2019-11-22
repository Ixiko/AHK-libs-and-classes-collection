OnMessage(0x00FF, "InputMessage")
  
RegisterHIDDevice(12, 3) ; Register Foot Pedal
  
PedalLastPress := 0
  
Return
  
ProcessPedalInput(input)
{
   global LeftWasPressed
   global CenterWasPressed
   global RightWasPressed
    
    ; The input are combinations of 1, 2, 4 with 00 appended to the end
    ; indicating which pedals are pressed.
    ; For example, pressing the leftmost pedal triggers input 100, middle pedal 200, etc.
    ; all three pedals presses together will trigger 700 (1 ^ 2 ^ 4 = 7)
    
   ; Left = 100
   ; Middle = 200
   ; Right = 400
   ; Multiple = sum of the above
   ; Nothing pressed = 0
   
   if (input = 100) { ; left pedal was pressed
      LeftWasPressed := true
   } else if (input == 200) { ; center pedal was pressed
      CenterWasPressed := true
      Send {F4}
   } else if (input = 400) { ; right pedal was pressed
      RightWasPressed := true
   } else if (input = 0) { ; all pedals released (use previous state to determine what was pressed)
      if (LeftWasPressed) { ; left was previously pressed
         Send {F3}
      }
      if (CenterWasPressed) { ; center was previously pressed
         Send {F4}
      }
      if (RightWasPressed) { ; right was previously pressed
         Send {F5}
      }
      
      LeftWasPressed := false
      CenterWasPressed := false
      RightWasPressed := false
   }
}
  
Mem2Hex( pointer, len )
{
A_FI := A_FormatInteger
SetFormat, Integer, Hex
Loop, %len%  {
Hex := *Pointer+0
StringReplace, Hex, Hex, 0x, 0x0
StringRight Hex, Hex, 2          
hexDump := hexDump . hex
Pointer ++
}
SetFormat, Integer, %A_FI%
StringUpper, hexDump, hexDump
Return hexDump
}
  
; Keyboards are always Usage 6, Usage Page 1, Mice are Usage 2, Usage Page 1,
; HID devices specify their top level collection in the info block  
RegisterHIDDevice(UsagePage,Usage)
{
; local RawDevice,HWND
RIDEV_INPUTSINK := 0x00000100
DetectHiddenWindows, on
HWND := WinExist("ahk_class AutoHotkey ahk_pid " DllCall("GetCurrentProcessId"))
DetectHiddenWindows, off
  
VarSetCapacity(RawDevice, 12)
NumPut(UsagePage, RawDevice, 0, "UShort")
NumPut(Usage, RawDevice, 2, "UShort")    
NumPut(RIDEV_INPUTSINK, RawDevice, 4)
NumPut(HWND, RawDevice, 8)
  
Res := DllCall("RegisterRawInputDevices", "UInt", &RawDevice, UInt, 1, UInt, 12)
if (Res = 0)
MsgBox, Failed to register for HID Device
}     
  
InputMessage(wParam, lParam, msg, hwnd)
{
RID_INPUT   := 0x10000003
RIM_TYPEHID := 2
SizeofRidDeviceInfo := 32
RIDI_DEVICEINFO := 0x2000000b
  
  
DllCall("GetRawInputData", UInt, lParam, UInt, RID_INPUT, UInt, 0, "UInt *", Size, UInt, 16)
VarSetCapacity(Buffer, Size)
DllCall("GetRawInputData", UInt, lParam, UInt, RID_INPUT, UInt, &Buffer, "UInt *", Size, UInt, 16)
  
Type := NumGet(Buffer, 0 * 4)
Size := NumGet(Buffer, 1 * 4)
Handle := NumGet(Buffer, 2 * 4)
  
VarSetCapacity(Info, SizeofRidDeviceInfo)  
NumPut(SizeofRidDeviceInfo, Info, 0)
Length := SizeofRidDeviceInfo
  
DllCall("GetRawInputDeviceInfo", UInt, Handle, UInt, RIDI_DEVICEINFO, UInt, &Info, "UInt *", SizeofRidDeviceInfo)
  
VenderID := NumGet(Info, 4 * 2)
Product := NumGet(Info, 4 * 3)
  
;   tooltip %VenderID% %Product%
  
  
if (Type = RIM_TYPEHID)
{
SizeHid := NumGet(Buffer, (16 + 0))
InputCount := NumGet(Buffer, (16 + 4))
Loop %InputCount% {
Addr := &Buffer + 24 + ((A_Index - 1) * SizeHid)
BAddr := &Buffer
Input := Mem2Hex(Addr, SizeHid)
If (VenderID = 1523 && Product = 255) ; need special function to process foot pedal input
ProcessPedalInput(Input)
Else If (IsLabel(Input))
{
Gosub, %Input%
}
  
}
}
}