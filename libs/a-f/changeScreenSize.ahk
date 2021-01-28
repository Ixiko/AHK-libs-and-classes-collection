;~ #NoEnv
;~ MsgBox, % ChangeDisplaySettings("1920|1080") . " - " . ErrorLevel
;~ Pause
;~ ChangeDisplaySettings()
;~ ExitApp

; ==================================================================================================================================
; Namespace:         ChangeDisplaySettings()
; Function:          Dynamically changes the display resolution, color resolution, and/or frequency of the display.
;                    Additionally you may change the position of a display in multi-monitor environments.
; AHK version:       AHK 1.1.+ (required)
; Language:          English
; Tested on:         Win Vista SP2 (U32 / ANSI) (with only one display)
; Version:           1.0.00.00/2012-10-20/just me
; MSDN:              msdn.microsoft.com/en-us/library/dd183413(v=vs.85).aspx
; ==================================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ==================================================================================================================================
ChangeDisplaySettings(DispRes := False, ColorRes := False, Frequency := False, DispNum := 0, DispPos := False) {
   ; ===================================================================================================================
   ;
   ; Parameters:
   ; DispRes         Specifies the width and height, in pixels, of the visible device surface.
   ;                 The new width and height have to be passed as a pipe-separated string (i.e. "1440|900")
   ;                 False (0) : don't change
   ; ColorRes        Specifies the color resolution, in bits per pixel, of the display device
   ;                 (for example: 4 for 16, 8 for 256, or 16 for 65,536 colors).
   ;                 False (0) : don't change
   ; Frequency       Specifies the frequency, in hertz (cycles per second), of the display device in a particular mode.
   ;                 False (0) : don't change
   ; --------------- For multi-monitor environments only ---------------------------------------------------------------
   ; DispNum         Specifies the number of the display to change the settings for in a multiple-monitor environment.
   ;                 0 : default display device
   ; DispPos         Specifies the positional coordinates, in pixel, of the display device in reference to the
   ;                 desktop area. The primary display device is always located at coordinates (0,0).
   ;                 The new x- and y-coordinates have to be passed as a pipe-separated string (i.e. "1680|0")
   ;                 False (0) : don't change
   ;
   ; If all parameters are omitted (i.e. default to zero / False), all the values currently in the registry will be
   ; used for the display setting. This is the easiest way to return to the default mode after a dynamic mode change.
   ;
   ; Return values:
   ; Returns True on success, otherwise False, ErrorLevel contains a message or one of the following error codes:
   ; DISP_CHANGE_RESTART          1
   ; DISP_CHANGE_FAILED          -1
   ; DISP_CHANGE_BADMODE         -2
   ; DISP_CHANGE_NOTUPDATED      -3
   ; DISP_CHANGE_BADFLAGS        -4
   ; DISP_CHANGE_BADPARAM        -5
   ; DISP_CHANGE_BADDUALVIEW     -6
   ; ===============================================================================================================================
   ; MS constants
   Static CDS_TEST               := 0x00000002
   Static DISP_CHANGE_SUCCESSFUL := 0
   Static DM_ORIENTATION         := 0x00000001
   Static DM_POSITION            := 0x00000020
   Static DM_BITSPERPEL          := 0x00040000
   Static DM_PELSWIDTH           := 0x00080000
   Static DM_PELSHEIGHT          := 0x00100000
   Static DM_DISPLAYFREQUENCY    := 0x00400000
   ; ===============================================================================================================================
   ; AHK constants
   Static TCHARsize     := A_IsUnicode ? 64 : 32  ; size of TCHAR members dmDeviceName and dmFormName
   Static DEVMODEsize   := 92 + (TCHARsize * 2)   ; size of DEVMODE structure
   Static offSize       :=  4 +  TCHARsize        ; dmSize
   Static offFields     :=  8 +  TCHARsize        ; dmFields
   Static offPosition   := 12 +  TCHARsize        ; dmPosition
   Static offColorRes   := 40 + (TCHARsize * 2)   ; dmBitsPerPel
   Static offWidth      := 44 + (TCHARsize * 2)   ; dmPelsWidth
   Static offHeight     := 48 + (TCHARsize * 2)   ; dmPelsHeight
   Static offFrequency  := 56 + (TCHARsize * 2)   ; dmDisplayFrequency
   ; ===============================================================================================================================
   ; Create the DEVMODE structure
   VarSetCapacity(DEVMODE, DEVMODEsize, 0)
   NumPut(DEVMODEsize, DEVMODE, offSize, "UShort")
   ; ===============================================================================================================================
   ; Initialize DEVMODEaddr and Fields with zero (NULL) in case the default registry settings shall be set
   DEVMODEaddr := 0
   Fields := 0
   ; ===============================================================================================================================
   ; Check optional parameters.
   If (DispRes) {
      StringSplit, Part, DispRes, |
      If (Part0 <> 2) {
         ErrorLevel := "Bad parameter DispRes!"
         Return False
      }
      NumPut(Part1, DEVMODE, offWidth, "UInt")
      NumPut(Part2, DEVMODE, offHeight, "UInt")
      Fields |= DM_PELSWIDTH | DM_PELSHEIGHT
   }
   If (ColorRes) {
      NumPut(ColorRes, DEVMODE, offColorRes, "UInt")
      Fields |= DM_BITSPERPEL
   }
   If (Frequency) {
      NumPut(Frequency, DEVMODE, offFrequency, "UInt")
      Fields |= DM_DISPLAYFREQUENCY
   }
   If (DispNum < 1)
      SysGet, DispNum, MonitorPrimary
   If (DispPos) {
      StringSplit, Part, DispPos, |
      SysGet, Displays, MonitorCount
      If (Part0 <> 2) || (Displays < 2) {
         ErrorLevel := "Bad parameter DispPos!"
         Return False
      }
      If (DispNum > Displays) {
         ErrorLevel := "Bad parameter DispNum!"
         Return False
      }
      NumPut(Part1, DEVMODE, offPosition + 0, "UInt")
      NumPut(Part2, DEVMODE, offPosition + 4, "UInt")
      Fields |= DM_POSITION
   }
   ; ===============================================================================================================================
   ; Get the device name.
   SysGet, DevName, MonitorName, %DispNum%
   If (DevName = "") {
      ErrorLevel := "Bad parameter DispNum!"
      Return False
   }
   ; ===============================================================================================================================
   ; New settings will be checked, if any. If the DllCall returns an error the new settings won't be set.
   If (Fields) {
      NumPut(Fields, DEVMODE, offFields, "UInt")
      DEVMODEaddr := &DEVMODE
      If (RetVal := DllCall("ChangeDisplaySettingsEx", "Str", DevName, "Ptr", DEVMODEaddr, "Ptr", 0, "UInt", CDS_TEST, "Ptr", 0, "Int")) {
         ErrorLevel := RetVal
         Return False
      }
   }
   ; ===============================================================================================================================
   ; New settings will be set dynamically.
   If (RetVal := DllCall("ChangeDisplaySettingsEx", "Str", DevName, "Ptr", DEVMODEaddr, "Ptr", 0, "UInt", 0, "Ptr", 0, "Int")) {
      ErrorLevel := RetVal
      Return False
   }
   ; ===============================================================================================================================
   ; All done successfully.
   ErrorLevel := 0
   Return True
}