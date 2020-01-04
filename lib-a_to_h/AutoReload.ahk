AutoReload()
{
  SetTimer, ReloadScriptIfChanged, 1000
  ReloadScriptIfChanged:
  {
    FileGetAttrib, FileAttribs, %A_ScriptFullPath%
    IfInString, FileAttribs, A
    {
      FileSetAttrib, -A, %A_ScriptFullPath%
      ; TrayTip, Reloading Script..., %A_ScriptName%, , 1
      Sleep, 1000
      Reload
      ; TrayTip
    }
    Return
  }
}