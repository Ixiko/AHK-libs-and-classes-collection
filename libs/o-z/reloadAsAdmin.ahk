reloadAsAdmin(force:=True){
    if A_IsAdmin
        return 0
    Run % "*RunAs " ( A_IsCompiled ? "" : """"  A_AhkPath """" )  " """ A_ScriptFullpath """", %A_ScriptDir%, UseErrorLevel
    return _reloadAsAdmin_Error(e,force)
}

;http://ahkscript.org/boards/viewtopic.php?t=4334
reloadAsAdmin_Task(force:=True) { ;  By SKAN,  http://goo.gl/yG6A1F,  CD:19/Aug/2014 | MD:22/Aug/2014
; Asks for UAC only first time

  TASK_CREATE := 0x2,  TASK_LOGON_INTERACTIVE_TOKEN := 3

  Try TaskSchd := ComObjCreate( "Schedule.Service" ),    TaskSchd.Connect()
  Catch e
      return _reloadAsAdmin_Error(e,force)


  CmdLine       := ( A_IsCompiled ? "" : """"  A_AhkPath """" )  A_Space  ( """" A_ScriptFullpath """"  )
  TaskName      := A_ScriptName " @" SubStr( "000000000"  DllCall( "NTDLL\RtlComputeCrc32"
                   , "Int",0, "WStr",CmdLine, "UInt",StrLen( CmdLine ) * 2, "UInt" ), -9 )

  Try {
    Try TaskRoot := TaskSchd.GetFolder("\AHK-ReloadAsAdmin")
    catch
        TaskRoot := TaskSchd.GetFolder("\"), TaskName:="[AHK-ReloadAsAdmin]" TaskName
    RunAsTask := TaskRoot.GetTask( TaskName )
  }
  TaskExists    := !A_LastError


  if !A_IsAdmin {
    if TaskExists {
        RunAsTask.Run("")
        ExitApp
    } else reloadAsAdmin(force)
  }

  else if !TaskExists {
    XML := "
    ( LTrim Join
      <?xml version=""1.0"" ?><Task xmlns=""http://schemas.microsoft.com/windows/2004/02/mit/task""><Regi
      strationInfo /><Triggers /><Principals><Principal id=""Author""><LogonType>InteractiveToken</LogonT
      ype><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolic
      y>Parallel</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><
      StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>false</AllowHardTerminate>
      <StartWhenAvailable>false</StartWhenAvailable><RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAva
      ilable><IdleSettings><StopOnIdleEnd>true</StopOnIdleEnd><RestartOnIdle>false</RestartOnIdle></IdleS
      ettings><AllowStartOnDemand>true</AllowStartOnDemand><Enabled>true</Enabled><Hidden>false</Hidden><
      RunOnlyIfIdle>false</RunOnlyIfIdle><DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteApp
      Session><UseUnifiedSchedulingEngine>false</UseUnifiedSchedulingEngine><WakeToRun>false</WakeToRun><
      ExecutionTimeLimit>PT0S</ExecutionTimeLimit></Settings><Actions Context=""Author""><Exec>
      <Command>"   (  A_IsCompiled ? A_ScriptFullpath : A_AhkPath )       "</Command>
      <Arguments>" ( !A_IsCompiled ? """" A_ScriptFullpath  """" : "" )   "</Arguments>
      <WorkingDirectory>" A_ScriptDir "</WorkingDirectory></Exec></Actions></Task>
    )"

    TaskRoot.RegisterTask( TaskName, XML, TASK_CREATE, "", "", TASK_LOGON_INTERACTIVE_TOKEN )

  }

  Return TaskName
}

_reloadAsAdmin_Error(e,force){
    if force {
        MsgBox, 4112, FATAL ERROR!!, Couldn't restart script!!`nError Code: %e%
        ExitApp
    }
    return 1
}