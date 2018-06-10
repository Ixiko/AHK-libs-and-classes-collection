CreateScript(script,pw:=""){
  static mScript
  StringReplace,script,script,`n,`r`n,A
  StringReplace,script,script,`r`r,`r,A
  If RegExMatch(script,"m)^[^:]+:[^:]+|[a-zA-Z0-9#_@]+\{}$"){
    If !(mScript){
      If (A_IsCompiled){
         lib := DllCall("GetModuleHandle", "ptr", 0, "ptr")
        If !(res := DllCall("FindResource", "ptr", lib, "str", "E4847ED08866458F8DD35F94B37001C0", "ptr", Type:=10, "ptr")){
          MsgBox Could not extract script!
          return
        }
        DataSize := DllCall("SizeofResource", "ptr", lib, "ptr", res, "uint")
        ,hresdata := DllCall("LoadResource", "ptr", lib, "ptr", res, "ptr")
        ,pData := DllCall("LockResource", "ptr", hresdata, "ptr")
				,UnZipRawMemory(pData,DataSize,Data2,pw)?pData:=&Data2:""
        If (DataSize){
          mScript:=StrGet(pData,"UTF-8")
          StringReplace,mScript,mScript,`n,`r`n,A
          StringReplace,mScript,mScript,`r,`r`n,A
          StringReplace,mScript,mScript,`r`r,`r,A
          StringReplace,mScript,mScript,`n`n,`n,A
          VarSetCapacity(line,16384*2)
          Loop,Parse,mScript,`n,`r
          {
            DllCall("crypt32\CryptStringToBinary","Str",A_LoopField,"UInt", 0,"UInt", 0x1,"PTR", &line,"UIntP", aSizeEncrypted:=16384*2,"UInt", 0,"UInt", 0)
            if (NumGet(&line,"UInt") != 0x04034b50)
              break
            UnZipRawMemory(&line,aSizeEncrypted,linetext,pw)
            ,aScript .= StrGet(&linetext,"UTF-8") "`r`n"
          }
          if aScript
            mScript:= "`r`n" aScript "`r`n"
          else mScript :="`r`n" mScript "`r`n"
        }
      } else {
        FileRead,mScript,%A_ScriptFullPath%
        StringReplace,mScript,mScript,`n,`r`n,A
        StringReplace,mScript,mScript,`r`r,`r,A
        mScript := "`r`n" mScript "`r`n"
        Loop,Parse,mScript,`n,`r
        {
          If A_Index=1
            mScript:=""
          If RegExMatch(A_LoopField,"i)^\s*#include"){
            temp:=RegExReplace(A_LoopField,"i)^\s*#include[\s+|,]")
            If InStr(temp,"%"){
              Loop,Parse,temp,`%
              {
                If (A_Index=1)
                  temp:=A_LoopField
                else if !Mod(A_Index,2)
                  _temp:=A_LoopField
                else {
                  _temp:=%_temp%
                  temp.=_temp A_LoopField
                  _temp:=""
                }
              }
            }
            If InStr(FileExist(trim(temp,"<>")),"D"){
				SetWorkingDir % trim(temp,"<>")
				continue
			} else if InStr(FileExist(temp),"D"){
				SetWorkingDir % temp
				continue
			} else If (SubStr(temp,1,1) . SubStr(temp,0) = "<>"){
              If !FileExist(_temp:=A_ScriptDir "\lib\" trim(temp,"<>") ".ahk")
                If !FileExist(_temp:=A_MyDocuments "\AutoHotkey\lib\" trim(temp,"<>") ".ahk")
                  If !FileExist(_temp:=SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",1,0)) "lib\" trim(temp,"<>") ".ahk")
                    If FileExist(_temp:=SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",1,0)) "lib.lnk"){
                      FileGetShortcut,_temp,_temp
                      _temp:=_temp "\" trim(temp,"<>") ".ahk"
                    }
				FileRead,_temp,%_temp%
		        mScript.= _temp "`r`n"
            } else {
				FileRead,_temp,%temp%
				mScript.= _temp "`r`n"
			}
          } else mScript.=A_LoopField "`r`n"
        }
      }
    }
    Loop,Parse,script,`n,`r
    {
      If A_Index=1
        script=
      else If A_LoopField=
        Continue
      If (RegExMatch(A_LoopField,"^[^:\s]+:[^:\s=]+$")){
        StringSplit,label,A_LoopField,:
        If (label0=2 and IsLabel(label1) and IsLabel(label2)){
          script .=SubStr(mScript
            , h:=InStr(mScript,"`r`n" label1 ":`r`n")
            , InStr(mScript,"`r`n" label2 ":`r`n")-h) . "`r`n"
        }
      } else if RegExMatch(A_LoopField,"^[^\{}\s]+\{}$"){
        StringTrimRight,label,A_LoopField,2
        script .= SubStr(mScript
          , h:=RegExMatch(mScript,"i)\n" label "\([^\)\n]*\)\n?\s*\{")
          , RegExMatch(mScript "`r`n","\n}\s*\K\n",1,h)-h) . "`r`n"
      } else
        script .= A_LoopField "`r`n"
    }
  }
  StringReplace,script,script,`r`n,`n,All
  Return Script
}