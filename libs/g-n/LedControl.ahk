/*

    Keyboard LED control for AutoHotkey_L
        http://www.autohotkey.com/forum/viewtopic.php?p=468000#468000

    KeyboardLED(LEDvalue, "Cmd", Kbd)
        LEDvalue  - ScrollLock=1, NumLock=2, CapsLock=4
        Cmd       - on/off/switch
        Kbd       - index of keyboard (probably 0 or 2)

*/

;Loop, 3 ; flash all LEDs
;  {
;  KeyboardLED(7,"on")
;  Sleep, 500
;  KeyboardLED(7,"off")
;  Sleep, 500
;  }
; 
;Loop, 3 ; flash ScrollLock LED
;  {
;  KeyboardLED(7,"off")
;  KeyboardLED(4,"switch")
;  Sleep, 500
;  KeyboardLED(7,"off")
;  Sleep, 500
;  }
;
;Loop, 3 ; cycle all LEDs left to right
;  {
;  KeyboardLED(7,"off")
;  Sleep, 250
;  KeyboardLED(2,"switch")
;  Sleep, 250
;  KeyboardLED(4,"switch")
;  Sleep, 250
;  KeyboardLED(1,"switch")
;  Sleep, 250
;  }
;
;Loop, 3 ; progress bar in LEDs
;  {
;  KeyboardLED(7,"off")
;  Sleep, 500
;  KeyboardLED(2,"switch")
;  Sleep, 500
;  KeyboardLED(6,"switch")
;  Sleep, 500
;  KeyboardLED(7,"switch")
;  Sleep, 500
;  }
;
Loop, 2 ; Knight Rider KITT cycling all LEDs ;-)
  {
  KeyboardLED(2,"switch")
  Sleep, 200
  KeyboardLED(4,"switch")
  Sleep, 200
  KeyboardLED(2,"switch")
  Sleep, 200
  KeyboardLED(1,"switch")
  Sleep, 200
  }

KeyboardLED(0,"off")  ; all LED('s) according to keystate (Command = on or off) 
Return




KeyboardLED(LEDvalue, Cmd, Kbd=1)
{
  SetUnicodeStr(fn,"\Device\KeyBoardClass" Kbd)
  h_device:=NtCreateFile(fn,0+0x00000100+0x00000080+0x00100000,1,1,0x00000040+0x00000020,0)
  
  If Cmd= switch  ;switches every LED according to LEDvalue
   KeyLED:= LEDvalue
  If Cmd= on  ;forces all choosen LED's to ON (LEDvalue= 0 ->LED's according to keystate)
   KeyLED:= LEDvalue | (GetKeyState("ScrollLock", "T") + 2*GetKeyState("NumLock", "T") + 4*GetKeyState("CapsLock", "T"))
  If Cmd= off  ;forces all choosen LED's to OFF (LEDvalue= 0 ->LED's according to keystate)
    {
    LEDvalue:= LEDvalue ^ 7
    KeyLED:= LEDvalue & (GetKeyState("ScrollLock", "T") + 2*GetKeyState("NumLock", "T") + 4*GetKeyState("CapsLock", "T"))
    }
  
  success := DllCall( "DeviceIoControl"
              ,  "ptr", h_device
              , "uint", CTL_CODE( 0x0000000b     ; FILE_DEVICE_KEYBOARD
                        , 2
                        , 0             ; METHOD_BUFFERED
                        , 0  )          ; FILE_ANY_ACCESS
              , "int*", KeyLED << 16
              , "uint", 4
              ,  "ptr", 0
              , "uint", 0
              ,  "ptr*", output_actual
              ,  "ptr", 0 )
  
  NtCloseFile(h_device)
  return success
}

CTL_CODE( p_device_type, p_function, p_method, p_access )
{
  Return, ( p_device_type << 16 ) | ( p_access << 14 ) | ( p_function << 2 ) | p_method
}


NtCreateFile(ByRef wfilename,desiredaccess,sharemode,createdist,flags,fattribs)
{
  VarSetCapacity(objattrib,6*A_PtrSize,0)
  VarSetCapacity(io,2*A_PtrSize,0)
  VarSetCapacity(pus,2*A_PtrSize)
  DllCall("ntdll\RtlInitUnicodeString","ptr",&pus,"ptr",&wfilename)
  NumPut(6*A_PtrSize,objattrib,0)
  NumPut(&pus,objattrib,2*A_PtrSize)
  status:=DllCall("ntdll\ZwCreateFile","ptr*",fh,"UInt",desiredaccess,"ptr",&objattrib
                  ,"ptr",&io,"ptr",0,"UInt",fattribs,"UInt",sharemode,"UInt",createdist
                  ,"UInt",flags,"ptr",0,"UInt",0, "UInt")
  return % fh
}

NtCloseFile(handle)
{
  return DllCall("ntdll\ZwClose","ptr",handle)
}


SetUnicodeStr(ByRef out, str_)
{
  VarSetCapacity(out,2*StrPut(str_,"utf-16"))
  StrPut(str_,&out,"utf-16")
}