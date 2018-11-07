;CreateScript AHK V2 Version
;https://autohotkey.com/board/topic/56142-createscript-create-script-from-main-script/

CreateScript(script){
  static mScript
  WorkingDir:=A_WorkingDir
  StrReplace,script,%script%,`n,`r`n
  StrReplace,script,%script%,`r`r,`r
  If RegExMatch(script,"m)^[^:]+:[^:]+|[a-zA-Z0-9#_@]+\{}$"){
    If !(mScript){
      If (A_IsCompiled){
        lib := DllCall("GetModuleHandle", "ptr", 0, "ptr")
        If !(res := DllCall("FindResource", "ptr", lib, "str", ">AUTOHOTKEY SCRIPT<", "ptr", Type:=10, "ptr"))
          If !(res := DllCall("FindResource", "ptr", lib, "str", ">AHK WITH ICON<", "ptr", Type:=10, "ptr")){
            MsgBox Could not extract script!
            return
          }
        DataSize := DllCall("SizeofResource", "ptr", lib, "ptr", res, "uint")
        ,hresdata := DllCall("LoadResource", "ptr", lib, "ptr", res, "ptr")
        ,pData := DllCall("LockResource", "ptr", hresdata, "ptr")
        If (DataSize)
          mScript:="`r`n" StrReplace(StrReplace(StrReplace(StrReplace(StrGet(pData,"UTF-8"),"`n","`r`n"),"`r`r","`r"),"`r`r","`r"),"`n`n","`n") "`r`n"
      } else {
        mScript:="`r`n" StrReplace(StrReplace(FileRead(A_ScriptFullPath),"`n","`r`n"),"`r`r","`r") "`r`n"
        LoopParse,%mScript%,`n,`r
        {
          If A_Index=1,mScript:=""
          If RegExMatch(A_LoopField,"i)^\s*#include"){
            temp:=RegExReplace(A_LoopField,"i)^\s*#include[\s+|,]")
            If InStr(temp,"`%")
              LoopParse,%temp%,`%
                If A_Index=1,temp:=A_LoopField
                else if !Mod(A_Index,2),_temp:=A_LoopField
                else _temp:=%_temp%,temp.=_temp A_LoopField,_temp:=""
   If InStr(FileExist(trim(temp,"<>")),"D"){
    SetWorkingDir % trim(temp,"<>")
    continue
   } else If InStr(FileExist(temp),"D"){
    SetWorkingDir % temp
    continue
   } else If (SubStr(temp,1,1) . SubStr(temp,-1) = "<>"){
              If !FileExist(_temp:=A_ScriptDir "\lib\" trim(temp,"<>") ".ahk")
                If !FileExist(_temp:=A_MyDocuments "\AutoHotkey\lib\" trim(temp,"<>") ".ahk")
                  If !FileExist(_temp:=SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",1,-1)) "lib\" trim(temp,"<>") ".ahk")
                    If FileGetShortcut(SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",1,-1)) "lib.lnk",_temp)
                      _temp:=_temp "\" trim(temp,"<>") ".ahk"
    mScript.= FileRead(_temp) "`r`n"
   } else mScript.= FileRead(temp) "`r`n"
          } else mScript.=A_LoopField "`r`n"
        }
      }
    }
    LoopParse,%script%,`n,`r
    {
      If A_Index=1,script:=""
      else If A_LoopField="",Continue
      If (RegExMatch(A_LoopField,"^[^:\s]+:[^:\s=]+$")){
        StrSplit,label,%A_LoopField%,:
        If (label.Length()=2 and IsLabel(label.1) and IsLabel(label.2))
          script .=SubStr(mScript
            , h:=InStr(mScript,"`r`n" label.1 ":`r`n")
            , InStr(mScript,"`r`n" label.2 ":`r`n")-h) . "`r`n"
      } else if RegExMatch(A_LoopField,"^[^\{}\s]+\{}$")
        label := SubStr(A_LoopField,1,-2),script .= SubStr(mScript
          , h:=RegExMatch(mScript,"i)\n" label "\([^\\)\n]*\)\n?\s*\{")
          , RegExMatch(mScript,"\n\s*}\s*\K\n",1,h)-h) . "`r`n"
      else script .= A_LoopField "`r`n"
    }
  }
  StrReplace,script,%script%,`r`n,`n
  SetWorkingDir % WorkingDir
  Return Script
}