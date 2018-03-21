WinGetPidList(WinTitle:="",WinText:="",ExcludeTitle:="",ExcludeText:=""){
  static p,i,EnumProcesses
  if !EnumProcesses
    i:=VarSetCapacity(p,4096),EnumProcesses:=DynaCall(DllCall("GetProcAddress","PTR",DllCall("LoadLibrary","STR","psapi","PTR"),"AStr","EnumProcesses","PTR"),"tuiui",&p,4096,getvar(i))
  EnumProcesses[],ps:=[]
  Loop % i/4
    If WinExist(WinTitle " ahk_pid " pid:=NumGet(p,(A_Index-1)*4,"UInt"),WinText,ExcludeTitle,ExcludeText)
      ps.Push(pid)
  return ps.Count()?ps:""
}