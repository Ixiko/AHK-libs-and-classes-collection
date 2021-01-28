; ==========================================
;
; Library: GPF v1.1c
; Author: MasterFocus
; Info: www.autohotkey.net/~MasterFocus
;
; Direct3D game overlaying
; DLLs provided by www.mikoweb.eu/index.php?node=28
;
; Please give credits and refer to one of the following
; links when using this library in your project:
;   www.autohotkey.net/~MasterFocus
;   www.autohotkey.com/forum/viewtopic.php?t=45689
;
; ==========================================

GPF_SetSingleLine(ObjNum,PosX,PosY,Text,ARGB,UseBlackBG,FontSize,UseBold,FontFamily)
{
  static proc_GPSL_SetTextLineData
  If ( proc_GPSL_SetTextLineData = "" )
  proc_GPSL_SetTextLineData := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "gpcomms"), str, "GPSL_SetTextLineData")
  DllCall(proc_GPSL_SetTextLineData, UChar, ObjNum, "UShort", PosX, "UShort", PosY, "str", GPF_AuxGetFilledStr(Text,False), "UInt", ARGB, "Int", UseBlackBG, "UChar", FontSize, "Int", UseBold, "UChar", FontFamily)
  return ErrorLevel
}

; ==========================================

GPF_SetMultiLine(ObjNum,PosX,PosY,Text,ARGB,UseBlackBG,FontSize,UseBold,SizeX,SizeY,FontFamily)
{
  static proc_GPML_SetTextMultilineData
  If ( proc_GPML_SetTextMultilineData = "" )
  proc_GPML_SetTextMultilineData := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "gpcomms"), str, "GPML_SetTextMultilineData")
  DllCall(proc_GPML_SetTextMultilineData, UChar, ObjNum, "UShort", PosX, "UShort", PosY, "str", GPF_AuxGetFilledStr(Text,True), "UInt", ARGB, "Int", UseBlackBG, "UChar", FontSize, "Int", UseBold, "UChar", SizeX, "UChar", SizeY, "UChar", FontFamily)
  return ErrorLevel
}

; ==========================================

GPF_ShowSingleLine(ObjNum,ShowText)
{
  static proc_GPSL_ShowText
  If ( proc_GPSL_ShowText = "" )
    proc_GPSL_ShowText := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "gpcomms"), str, "GPSL_ShowText")
  DllCall(proc_GPSL_ShowText, UChar, ObjNum, "Int", ShowText)
  return ErrorLevel
}

; ==========================================

GPF_ShowMultiLine(ObjNum,ShowText)
{
  static proc_GPML_ShowText
  If ( proc_GPML_ShowText = "" )
    proc_GPML_ShowText := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "gpcomms"), str, "GPML_ShowText")
  DllCall(proc_GPML_ShowText, UChar, ObjNum, "Int", ShowText)
  return ErrorLevel
}

; ==========================================

GPF_SetPicture(FullPath)
{
  static proc_GPPIC_LoadNewPicture
  If ( proc_GPPIC_LoadNewPicture = "" )
    proc_GPPIC_LoadNewPicture := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "gpcomms"), str, "GPPIC_LoadNewPicture")
  DllCall(proc_GPPIC_LoadNewPicture, str, FullPath)
  return ErrorLevel
}

; ==========================================

GPF_ShowPicture(ShowPic,PosX,PosY)
{
  static proc_GPPIC_ShowPicturePos
  If ( proc_GPPIC_ShowPicturePos = "" )
    proc_GPPIC_ShowPicturePos := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "gpcomms"), str, "GPPIC_ShowPicturePos")
  DllCall(proc_GPPIC_ShowPicturePos, "Int", ShowPic, "UShort", PosX, "UShort", PosY)
  return ErrorLevel
}

; ==========================================

GPF_ShowFPS(bShowFPS)
{
  static proc_GPSI_ShowFPS
  If ( proc_GPSI_ShowFPS = "" )
    proc_GPSI_ShowFPS := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "gpcomms"), str, "GPSI_ShowFPS")
  DllCall(proc_GPSI_ShowFPS, "Int", bShowFPS)
  return ErrorLevel
}

; ==========================================

GPF_GetScreenSize(ByRef SizeX,ByRef SizeY)
{
  static proc_GPSI_GetScreenSize
  If ( proc_GPSI_GetScreenSize = "" )
    proc_GPSI_GetScreenSize := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "gpcomms"), str, "GPSI_GetScreenSize")
  DllCall(GPSI_GetScreenSize, "Int *", SizeX, "Int *", SizeY)
  return ErrorLevel
}

; ==========================================

GPF_TakeScreenShot(bFormat,SaveFullPath)
{
  static proc_GPSS_MakeScreenshot
  If ( proc_GPSS_MakeScreenshot = "" )
    proc_GPSS_MakeScreenshot := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "gpcomms"), str, "GPSS_MakeScreenshot")
  DllCall(GPSS_MakeScreenshot, "Int *", SizeX, "Int *", SizeY)
  return ErrorLevel
}

; ==========================================

GPF_Main()
{
  static hModule
  If !hModule
    hModule := DllCall("LoadLibrary", "str", "gpcomms.dll")
  Else
  {
    temp := hModule
    hModule := 0
    If ( DllCall("FreeLibrary", "UInt", temp) != 1 )
      return -2 ; --- FREE FAIL
    Else
      return 2 ; ---- FREE SUCCESS
  }
  If !hModule
    return -1 ; --- LOAD FAIL
  Else
    return 1 ; ---- LOAD SUCCESS
}

; ==========================================

GPF_AuxGetFilledStr(str,multiline)
{
  Loop, % ( multiline ? 1023 : 127 ) - StrLen(str)
    str .= " "
  return str
}

; ==========================================