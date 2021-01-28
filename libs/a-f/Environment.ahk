; Script:    Environment.ahk
; Author:    iseahound
; Date:      2017-02-11
; Recent:    2017-11-12
;
; ExpandEnvironmentStrings(), RefreshEnvironment()   by NoobSawce + DavidBiesack (modified by BatRamboZPM)
;   https://autohotkey.com/board/topic/63312-reload-systemuser-environment-variables/
;
; RPath_Absolute()   Modified by Iggy_
;   https://autohotkey.com/board/topic/17922-func-relativepath-absolutepath/page-3

; Global Error Values
;  0 - Success.
; -1 - Error when writing value to registry.
; -2 - Value already added or value already deleted.
; -3 - Need to Run As Administrator.

Env_UserAdd(name, value, type := "", location := ""){
   RegRead, registry, % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name
   if (!ErrorLevel) {
      Loop, parse, registry, `;
      {
         if (A_LoopField == value)
            return -2
      }
      registry .= (registry ~= "(;$|^$)") ? "" : ";"
      value := registry . value
   }
   type := (type) ? type : (value ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite, % type , % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name, % value
   SendMessage, 0x1A,0,"Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
   RefreshEnvironment()
   return (ErrorLevel) ? -1 : 0
}

Env_SystemAdd(name, value, type := ""){
   return (A_IsAdmin) ? Env_UserAdd(name, value, type, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserSub(name, value, type := "", location := ""){
   RegRead, registry, % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name
   if ErrorLevel
      return -2

   Loop, parse, registry, `;
   {
      if (A_LoopField != value) {
         output .= (A_Index > 1 && output != "") ? ";" : ""
         output .= A_LoopField
      }
   }

   if (output != "") {
      type := (type) ? type : (output ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
      RegWrite, % type , % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name, % output
   }
   else
      RegDelete, % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name
   SendMessage, 0x1A,0,"Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
   RefreshEnvironment()
   return (ErrorLevel) ? -1 : 0
}

Env_SystemSub(name, value, type := ""){
   return (A_IsAdmin) ? Env_UserSub(name, value, type, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserNew(name, value := "", type := "", location := ""){
   type := (type) ? type : (value ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite, % type , % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name, % value
   SendMessage, 0x1A,0,"Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
   RefreshEnvironment()
   return (ErrorLevel) ? -1 : 0
}

Env_SystemNew(name, value := "", type := ""){
   return (A_IsAdmin) ? Env_UserNew(name, value, type, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

; Value does nothing except let me easily change between functions.
Env_UserDel(name, value := "", location := ""){
   RegDelete, % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name
   SendMessage, 0x1A,0,"Environment",, ahk_id 0xFFFF ; 0x1A is WM_SETTINGCHANGE
   RefreshEnvironment()
   return 0
}

Env_SystemDel(name, value := ""){
   return (A_IsAdmin) ? Env_UserDel(name, value, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserRead(name, value := "", location := ""){
   RegRead, registry, % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name
   if (value) {
      Loop, parse, registry, `;
      {
         if (A_LoopField = value) {
            return A_LoopField
         }
      }
      return ; Value not found
   }
   return registry
}

Env_SystemRead(name, value := ""){
   return Env_UserRead(name, value, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
}

; Value does nothing except let me easily change between functions.
Env_UserSort(name, value := "", location := ""){
   RegRead, registry, % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name
   Sort, registry, D`;
   type := (type) ? type : (registry ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite, % type , % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name, % registry
   return (ErrorLevel) ? -1 : 0
}

Env_SystemSort(name, value := ""){
   return (A_IsAdmin) ? Env_UserSort(name, value, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

; Value does nothing except let me easily change between functions.
Env_UserRemoveDuplicates(name, value := "", location := ""){
   RegRead, registry, % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name
   Sort, registry, U D`;
   type := (type) ? type : (registry ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
   RegWrite, % type , % (location == "") ? "HKEY_CURRENT_USER\Environment" : location, % name, % registry
   return (ErrorLevel) ? -1 : 0
}

Env_SystemRemoveDuplicates(name, value := ""){
   return (A_IsAdmin) ? Env_UserRemoveDuplicates(name, value, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment") : -3
}

Env_UserBackup(fileName := "UserEnvironment.reg", location := ""){
   _cmd .= (A_Is64bitOS <> A_PtrSize >> 3)    ? A_WinDir "\SysNative\cmd.exe"   : ComSpec
   _cmd .= " /K " Chr(0x22) "reg export " Chr(0x22)
   _cmd .= (location == "")                   ? "HKEY_CURRENT_USER\Environment" : location
   _cmd .= Chr(0x22) " " Chr(0x22)
   _cmd .= fileName
   _cmd .= Chr(0x22) . Chr(0x22) . " && pause && exit"
   try RunWait % _cmd
   catch
      return "FAIL"
   return "SUCCESS"
}

Env_SystemBackup(fileName := "SystemEnvironment.reg"){
   return Env_UserBackup(fileName, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
}

Env_UserRestore(fileName := "UserEnvironment.reg"){
   try RunWait % fileName
   catch
      return "FAIL"
   return "SUCCESS"
}

Env_SystemRestore(fileName := "SystemEnvironment.reg"){
   try RunWait % fileName
   catch
      return "FAIL"
   return "SUCCESS"
}


RefreshEnvironment()
{
   Path := ""
   PathExt := ""
   RegKeys := "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment,HKCU\Environment"
   Loop, Parse, RegKeys, CSV
   {
      Loop, Reg, %A_LoopField%, V
      {
         RegRead, Value
         If (A_LoopRegType == "REG_EXPAND_SZ" && !ExpandEnvironmentStrings(Value))
            Continue
         If (A_LoopRegName = "PATH")
            Path .= Value . ";"
         Else If (A_LoopRegName = "PATHEXT")
            PathExt .= Value . ";"
         Else
            EnvSet, %A_LoopRegName%, %Value%
      }
   }
   EnvSet, PATH, %Path%
   EnvSet, PATHEXT, %PathExt%
}

ExpandEnvironmentStrings(ByRef vInputString)
{
   ; get the required size for the expanded string
   vSizeNeeded := DllCall("ExpandEnvironmentStrings", "Str", vInputString, "Int", 0, "Int", 0)
   If (vSizeNeeded == "" || vSizeNeeded <= 0)
      return False ; unable to get the size for the expanded string for some reason

   vByteSize := vSizeNeeded + 1
   If (A_IsUnicode) { ; Only 64-Bit builds of AHK_L will return 8, all others will be 4 or blank
      vByteSize *= 2 ; need to expand to wide character sizes
   }
   VarSetCapacity(vTempValue, vByteSize, 0)

   ; attempt to expand the environment string
   If (!DllCall("ExpandEnvironmentStrings", "Str", vInputString, "Str", vTempValue, "Int", vSizeNeeded))
      return False ; unable to expand the environment string
   vInputString := vTempValue

   ; return success
   Return True
}

; Modified: AbsolutePath
RPath_Absolute(AbsolutPath, RelativePath, s="\") {

   len := InStr(AbsolutPath, s, "", InStr(AbsolutPath, s . s) + 2) - 1   ;get server or drive string length
   pr := SubStr(AbsolutPath, 1, len)                                     ;get server or drive name
   AbsolutPath := SubStr(AbsolutPath, len + 1)                           ;remove server or drive from AbsolutPath
   If InStr(AbsolutPath, s, "", 0) = StrLen(AbsolutPath)                 ;remove last \ from AbsolutPath if any
      StringTrimRight, AbsolutPath, AbsolutPath, 1

   If InStr(RelativePath, s) = 1                                         ;when first char is \ go to AbsolutPath of server or drive
      AbsolutPath := "", RelativePath := SubStr(RelativePath, 2)        ;set AbsolutPath to nothing and remove one char from RelativePath
   Else If InStr(RelativePath,"." s) = 1                                 ;when first two chars are .\ add to current AbsolutPath directory
      RelativePath := SubStr(RelativePath, 3)                           ;remove two chars from RelativePath
   Else If InStr(RelativePath,".." s) = 1 {                              ;otherwise when first 3 char are ..\
      StringReplace, RelativePath, RelativePath, ..%s%, , UseErrorLevel     ;remove all ..\ from RelativePath
      Loop, %ErrorLevel%                                                    ;for all ..\
         AbsolutPath := SubStr(AbsolutPath, 1, InStr(AbsolutPath, s, "", 0) - 1)  ;remove one folder from AbsolutPath
   } Else                                                                ;relative path does not need any substitution
      pr := "", AbsolutPath := "", s := ""                              ;clear all variables to just return RelativePath

   Return, pr . AbsolutPath . s . RelativePath                           ;concatenate server + AbsolutPath + separator + RelativePath
}
