; Title:   	EjectEx() : Call Eject() from File Explorer
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=77319
; Author:	SKAN
; Date:   	14.06.2020
; for:     	AHK_L

/*

  #NoEnv
  #SingleInstance, Force

  #IfWinActive ahk_class CabinetWClass
   ^q:: EjectEx(WinExist())
  #IfWinActive

*/

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
EjectEx(hWnd) {                                                  ; By SKAN on D36F @ tiny.cc/ejectex
Local
Critical On
  For Window in ComObjCreate("Shell.Application").Windows
    If (hWnd=Window.HWND) and (sfv := Window.Document)
        Break

  epath := sfv.selecteditems.count
        ?  sfv.selecteditems.item(0).path
        :  sfv.folder.self.path

  If not FileExist(ePath)
     Return

  epath := SubStr(epath,1,2)
  DriveGet, Title, Label, %epath%
  MainText := Format("{:} ({:})", Title, epath)
  OSDTIP_Pop(MainText, "Ejecting...`n`n`n`n", 0, "W340 ZH3 FS9 Cw404040 CTF0F0F0 U2"
                     ,,, 0xF0F0F0, 0x808080, 40)
  Sleep 250
  dObj  := Eject(epath)
  Msg := ErrorLevel
   ? "Eject failed.   `n`nModel :`t" . dObj.Model . "`nStatus :`t" . StrSplit(ErrorLevel,"`n").Pop()
   : "Eject succeeded.`n`nModel :`t" . dObj.Model . "`nStatus :`t" . "Safely removed hardware"
  OSDTIP_Pop("", Msg, ErrorLevel ? -6000 : -3000)
  Critical Off
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Eject(DRV, DontCheck:=0, DontEject:=0) {  ;       By SKAN on CT91/D29R @ goo.gl/pUUGRt
Local  STORAGE_DEVICE_NUMBER, IOCTL_STORAGE_GET_DEVICE_NUMBER:=0x2D1080
Local  OPEN_EXISTING:=3, hVol:=0, sPHDRV:="", qStr:="", qEnum:= "", nDID:=0, nVT:=1
Local  AMT := "[Removable Media][External hard disk media]", dObj:={}, VT, VAR

  hVol := DllCall("CreateFile", "Str","\\.\" . (DRV:=SubStr(DRV,1,1) . ":"), "UInt",0
                    ,"UInt",0, "Ptr",0,"UInt",OPEN_EXISTING, "UInt",0, "Ptr",0, "Ptr")
  If (hVol = -1 )
   {
     ErrorLevel := FileExist(DRV) ? "Mapped/substitute drive" : "Invalid drive letter"
     Return dObj
   }

  VarSetcapacity(STORAGE_DEVICE_NUMBER,12,0)
  DllCall("DeviceIoControl", "Ptr",hVol, "UInt",IOCTL_STORAGE_GET_DEVICE_NUMBER
         ,"Int",0, "Int",0, "Ptr",&STORAGE_DEVICE_NUMBER, "Int",12, "PtrP",0, "Ptr",0)
  DllCall( "CloseHandle", "Ptr",hVol )

  sPHDRV := "\\\\.\\PHYSICALDRIVE" . NumGet(STORAGE_DEVICE_NUMBER,4,"UInt")
  qStr   := "Select * from Win32_DiskDrive where DeviceID='$$$'"
  qEnum  := ComObjGet("winmgmts:").ExecQuery(StrReplace(qStr,"$$$",sPHDRV))._NewEnum()
  qEnum[dObj]

  If ( DontEject )
    {
      ErrorLevel := ""
      Return dObj
    }

  If ! ( DontCheck || InStr(AMT, "[" . dObj.MediaType . "]", True) )
    {
      ErrorLevel := (dObj.MediaType=="Fixed hard disk media"
                 ?  "Media is a Fixed hard disk" : "Media type Unknown")
      Return dObj
    }

  If ! ( DllCall("GetModuleHandle", "Str","SetupAPI.dll", "Ptr") )
    {
         DllCall("LoadLibrary", "Str","SetupAPI.dll", "Ptr")
    }

  DllCall("SetupAPI\CM_Locate_DevNode", "PtrP",nDID, "Str",dObj.PNPDeviceID, "Int",0)
  DllCall("SetupAPI\CM_Get_Parent", "PtrP",nDID, "UInt",nDID, "Int",0)

  VarSetCapacity(VAR,520,0)
  DllCall("SetupAPI\CM_Request_Device_Eject"
          ,"UInt",nDID, "PtrP",nVT,"Str",VAR, "Int",260, "Int",0)

  ErrorLevel := ( nVT=0 ? 0 : ["PNP_VetoTypeUnknown`nThe specified operation was reje"
  . "cted for an unknown reason.","PNP_VetoLegacyDevice`nThe device does not support "
  . "the specified PnP operation.","PNP_VetoPendingClose`nThe specified operation can"
  . "not be completed because of a pending close operation.","PNP_VetoWindowsApp`nA M"
  . "icrosoft Win32 application vetoed the specified operation.","PNP_VetoWindowsServ"
  . "ice`nA Win32 service vetoed the specified operation.","PNP_VetoOutstandingOpen`n"
  . "The requested operation was rejected because of outstanding open handles.","PNP_"
  . "VetoDevice`nThe device supports the specified operation, but the device rejected"
  . " the operation.","PNP_VetoDriver`nThe driver supports the specified operation, b"
  . "ut the driver rejected the operation.","PNP_VetoIllegalDeviceRequest`nThe device"
  . " does not support the specified operation.","PNP_VetoInsufficientPower`nThere is"
  . " insufficient power to perform the requested operation.","PNP_VetoNonDisableable"
  . "`nThe device cannot be disabled.","PNP_VetoLegacyDriver`nThe driver does not sup"
  . "port the specified PnP operation.","PNP_VetoInsufficientRights`nThe caller has i"
  . "nsufficient privileges to complete the operation.","PNP_VetoAlreadyRemoved`nThe "
  . "device has been already removed"][nVT] )

Return dObj
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
OSDTIP_Pop(P*) {                            ; OSDTIP_Pop v0.55 by SKAN on D361/D36E @ tiny.cc/osdtip
Local
Static FN:="", ID:=0, PM:="", PS:=""

  If !IsObject(FN)
    FN := Func(A_ThisFunc).Bind(A_ThisFunc)

  If (P.Count()=0 || P[1]==A_ThisFunc) {
    OnMessage(0x202, FN, 0),  OnMessage(0x010, FN, 0)                   ; WM_LBUTTONUP, WM_CLOSE
    SetTimer, %FN%, OFF
    DllCall("AnimateWindow", "Ptr",ID, "Int",200, "Int",0x50004)        ; AW_VER_POSITIVE | AW_SLIDE
    Progress, 10:OFF                                                    ; | AW_HIDE
    Return ID:=0
  }

  MT:=P[1], ST:=P[2], TMR:=P[3], OP:=P[4], FONT:=P[5] ? P[5] : "Segoe UI"
  Title := (TMR=0 ? "0x0" : A_ScriptHwnd) . ":" . A_ThisFunc

  If (ID) {
    Progress, 10:, % (ST=PS ? "" : PS:=ST), % (MT=PM ? "" : PM:=MT), %Title%
    OnMessage(0x202, FN, TMR=0 ? 0 : -1)                                ; v0.55
    SetTimer, %FN%, % Round(TMR)<0 ? TMR : "OFF"
    Return ID
  }

  If ( InStr(OP,"U2",1) && FileExist(WAV:=A_WinDir . "\Media\Windows Notify.wav") )
    DllCall("winmm\PlaySoundW", "WStr",WAV, "Ptr",0, "Int",0x220013)    ; SND_FILENAME | SND_ASYNC
                                                                        ; | SND_NODEFAULT
  DetectHiddenWindows, % ("On", DHW:=A_DetectHiddenWindows)             ; | SND_NOSTOP | SND_SYSTEM
  SetWinDelay, % (-1, SWD:=A_WinDelay)
  DllCall("uxtheme\SetThemeAppProperties", "Int",0)
  Progress, 10:C00 ZH1 FM9 FS10 CWF0F0F0 CT101010 %OP% B1 M HIDE,% PS:=ST, % PM:=MT, %Title%, %FONT%
  DllCall("uxtheme\SetThemeAppProperties", "Int",7)                     ; STAP_ALLOW_NONCLIENT
                                                                        ; | STAP_ALLOW_CONTROLS
  WinWait, %Title% ahk_class AutoHotkey2                                ; | STAP_ALLOW_WEBCONTENT
  WinGetPos, X, Y, W, H
  SysGet, M, MonitorWorkArea
  WinMove,% "ahk_id" . WinExist(),,% MRight-W,% MBottom-(H:=InStr(OP,"U1",1) ? H : Max(H,100)), W, H
  If ( TRN:=Round(P[6]) & 255 )
    WinSet, Transparent, %TRN%
  ControlGetPos,,,,H, msctls_progress321
  If (H>2) {
    ColorMQ:=Round(P[7]),  ColorBG:=P[8]!="" ? Round(P[8]) : 0xF0F0F0,  SpeedMQ:=Round(P[9])
    Control, ExStyle, -0x20000,        msctls_progress321               ; v0.55 WS_EX_STATICEDGE
    Control, Style, +0x8,              msctls_progress321               ; PBS_MARQUEE
    SendMessage, 0x040A, 1, %SpeedMQ%, msctls_progress321               ; PBM_SETMARQUEE
    SendMessage, 0x0409, 1, %ColorMQ%, msctls_progress321               ; PBM_SETBARCOLOR
    SendMessage, 0x2001, 1, %ColorBG%, msctls_progress321               ; PBM_SETBACKCOLOR
  }
  DllCall("AnimateWindow", "Ptr",WinExist(), "Int",200, "Int",0x40008)  ; AW_VER_NEGATIVE | AW_SLIDE
  SetWinDelay, %SWD%
  DetectHiddenWindows, %DHW%
  If (Round(TMR)<0)
    SetTimer, %FN%, %TMR%
  OnMessage(0x202, FN, TMR=0 ? 0 : -1),  OnMessage(0x010, FN)           ; WM_LBUTTONUP,  WM_CLOSE
Return ID:=WinExist()
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -