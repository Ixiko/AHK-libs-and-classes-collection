;-- Monitor library - only copied from https://autohotkey.com/board/topic/96884-change-monitor-input-source/
;-- Edited by lifeweaver, 01 September 2013
;-- So to set the monitor input source to HDMI I would do setMonitorSource(4), I'm sure you could pretty this up a bit all into one function.

/*					EXAMPLE
; Msgbox with current monitor input source
!r::
msgbox % getMonitorSource()
return
*/

getMonitorHandle() { ; Finds monitor handle

  ; Initialize Monitor handle
  hMon := DllCall("MonitorFromPoint"
    , "int64", 0 ; point on monitor
    , "uint", 1) ; flag to return primary monitor on failure


  ; Get Physical Monitor from handle
  VarSetCapacity(Physical_Monitor, 8 + 256, 0)

  DllCall("dxva2\GetPhysicalMonitorsFromHMONITOR"
    , "int", hMon   ; monitor handle
    , "uint", 1   ; monitor array size
    , "int", &Physical_Monitor)   ; point to array with monitor

  return hPhysMon := NumGet(Physical_Monitor)
}

getMonitorHandleFromMouse() { ; Finds monitor handle from mouse position

  MouseGetPos, xpos, ypos
  point := ( ( xpos ) & 0xFFFFFFFF ) | ( ( ypos ) << 32 )

  ; Initialize Monitor handle
  hMon := DllCall("MonitorFromPoint"
    , "int64", point ; point on monitor
    , "uint", 1) ; flag to return primary monitor on failure


  ; Get Physical Monitor from handle
  VarSetCapacity(Physical_Monitor, 8 + 256, 0)

  DllCall("dxva2\GetPhysicalMonitorsFromHMONITOR"
    , "int", hMon   ; monitor handle
    , "uint", 1   ; monitor array size
    , "int", &Physical_Monitor)   ; point to array with monitor

  return hPhysMon := NumGet(Physical_Monitor)
}

destroyMonitorHandle(handle) {
  DllCall("dxva2\DestroyPhysicalMonitor", "int", handle)
}

getMonitorInputSource() {

  handle := getMonitorHandle()
  DllCall("dxva2\GetVCPFeatureAndVCPFeatureReply"
    , "int", handle
    , "char", 0x60 ;VCP code for Input Source Select
    , "Ptr", 0
    , "uint*", currentValue
    , "uint*", maximumValue)
  destroyMonitorHandle(handle)
  return currentValue
}

setMonitorInputSource(source) { ;Used to set the monitor source, I do not know what happens if you send it a value higher than the maximum.

	; Used to change the monitor source
	; DVI = 3
	; HDMI = 4
	; YPbPr = 12

  handle := getMonitorHandle()
  DllCall("dxva2\SetVCPFeature"
    , "int", handle
    , "char", 0x60 ;VCP code for Input Source Select
    , "uint", source)
  destroyMonitorHandle(handle)
}

