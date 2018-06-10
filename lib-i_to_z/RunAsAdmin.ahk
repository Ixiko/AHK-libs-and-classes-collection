RunAsAdmin(FullPath := "", WorkingDir := "", Exit := True) {
  Loop, %0%  ; For each parameter:
    {
      param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
      params .= A_Space . param
    }
  ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"
      
   
    If (FullPath && WorkingDir) ;will run the app if params passed regardless of if compiled or not
       DllCall(ShellExecute, uint, 0, str, "RunAs", str, FullPath, str, params , str, WorkingDir, int, 1)
    Else If A_IsCompiled
       DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)   
    Else
       DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)      
    if Exit
      ExitApp

}