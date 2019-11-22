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
  
   VarSetCapacity(RawDevice, 8 + A_PtrSize)
   NumPut(UsagePage, RawDevice, 0, "UShort")
   NumPut(Usage, RawDevice, 2, "UShort")    
   NumPut(RIDEV_INPUTSINK, RawDevice, 4, "UInt")
   NumPut(HWND, RawDevice, A_PtrSize, "UPtr")
  
   Res := DllCall("RegisterRawInputDevices", "UPtr", &RawDevice, "UInt", 1, "UInt", 8 + A_PtrSize)
   if (Res = 0)
      MsgBox, Failed to register for HID Device
}     

InputMessage(wParam, lParam, msg, hwnd)
{
   RID_INPUT   := 0x10000003
   RIM_TYPEHID := 2
   SizeOfHeader := 8 + A_PtrSize + A_PtrSize ; <<<
   SizeofRidDeviceInfo := 32
   RIDI_DEVICEINFO := 0x2000000b

   DllCall("GetRawInputData", "Ptr", lParam, "UInt", RID_INPUT, "Ptr", 0, "UIntP", Size, "UInt", SizeOfHeader, "UInt") ; <<<
   VarSetCapacity(Buffer, Size)
   DllCall("GetRawInputData", "Ptr", lParam, "UInt", RID_INPUT, "Ptr", &Buffer, "UIntP", Size, "UInt", SizeOfHeader, "UInt") ; <<<

   Type := NumGet(Buffer, 0 * 4, "UInt") ; <<<
   Size := NumGet(Buffer, 1 * 4, "UInt") ; <<<
   Handle := NumGet(Buffer, 2 * 4, "UPtr") ; <<<

   VarSetCapacity(Info, SizeofRidDeviceInfo)
   NumPut(SizeofRidDeviceInfo, Info, 0)
   Length := SizeofRidDeviceInfo

   DllCall("GetRawInputDeviceInfo", "Ptr", Handle, "UInt", RIDI_DEVICEINFO, "Ptr", &Info, "UIntP", SizeofRidDeviceInfo) ; <<<

   VendorID := NumGet(Info, 4 * 2, "UInt") ; <<<
   Product := NumGet(Info, 4 * 3, "UInt") ; <<<

   ;   tooltip %VendorID% %Product%

   if (Type = RIM_TYPEHID)
   {
      SizeHid := NumGet(Buffer, (SizeOfHeader + 0), "UInt") ; <<<
      InputCount := NumGet(Buffer, (SizeOfHeader + 4), "UInt") ; <<<
      Loop %InputCount% {
         Addr := &Buffer + SizeOfHeader + 8 + ((A_Index - 1) * SizeHid) ; <<<
         BAddr := &Buffer
         Input := Mem2Hex(Addr, SizeHid)
         If (VendorID = 1523 && Product = 255) ; need special function to process foot pedal input
            ProcessPedalInput(Input)
         Else If (IsLabel(Input))
         {
            Gosub, %Input%
         }
      }
   }
}