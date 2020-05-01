class Task_Sheduler
{
	static Tasks_Dir := A_WinDir . "\System32\Tasks"
	static Tasks_Dir_Lenght := StrLen( Task_Sheduler.Tasks_Dir . "\" )
	
	/*
	Create_Auto_Run_Task( ByRef Task_Name, ByRef Admin_Rights := False )
	{ 
		static Command
		Command = "%A_WinDir%\System32\schtasks.exe" /create /TN "%Task_Name%" /TR """"%A_ScriptFullPath%"""" /SC ONLOGON
		Command .= Admin_Rights ? " /RL HIGHEST /F" : " /F"
		RunWait, *RunAs %Command%
	}

	Delete_Auto_Run_Task( ByRef Task_Name )
	{ 
		static Command
		Command = "%A_WinDir%\System32\schtasks.exe" /delete /TN "%Task_Name%" /F
		RunWait, *RunAs %Command%
	}
	*/
	
	Create_Auto_Run_Task( ByRef Task_Name, ByRef Admin_Rights := False, ByRef Delete_Task_XML := 0 )
	{ 
		static Task_XML
		Task_XML := A_Temp "\" RegExReplace( Task_Name, ".*\\(.*)$", "$1" ) ".xml"
		This.Create_Auto_Start_XML( A_ScriptFullPath, Admin_Rights, Task_XML )
		If FileExist( Task_XML ) {
			This.Delete_Task( Task_Name )
			This.Create_Task_From_XML( Task_Name, Task_XML )
			If ( Delete_Task_XML ) {
				FileDelete, %Task_XML%
			}
		}
	}
	
	Create_Task_From_XML( ByRef Task_Name, ByRef Task_XML )
	{ 
		static Command
		Command = schtasks.exe /Create /XML "%Task_XML%" /tn "%Task_Name%"
		
		RunWait, *RunAs %Command%
	}

	Delete_Task( ByRef Task_Name )
	{ 
		static Command
		Command = "%A_WinDir%\System32\schtasks.exe" /delete /TN "%Task_Name%" /F
		RunWait, *RunAs %Command%
	}
	
	Create_Auto_Start_XML( ByRef Command, ByRef Admin_Rights := false, ByRef Task_XML := "my_task.xml" )
	{ 
		static XML_Text
		static Registration_Time
		
		FormatTime, Registration_Time,, yyyy-MM-ddThh:mm:ss
		FormatTime, Start_Time,, yyyy-MM-ddThh:mm:00
		
		If FileExist( Task_XML ) {
			FileDelete, %Task_XML%
		}
		
		Privilege := Admin_Rights ? "HighestAvailable" : "LeastPrivilege"

		XML_Text =
		( /*LTrim*/ RTrim Join`r`n
		<?xml version="1.0" encoding="UTF-16"?>
		<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
		  <RegistrationInfo>
		    <Date>%Registration_Time%</Date>
		    <Author>%A_UserName%</Author>
		  </RegistrationInfo>
		  <Triggers>
		    <LogonTrigger>
		      <StartBoundary>%Start_Time%</StartBoundary>
		      <Enabled>true</Enabled>
		    </LogonTrigger>
		  </Triggers>
		  <Settings>
		    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
		    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
		    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
		    <AllowHardTerminate>true</AllowHardTerminate>
		    <StartWhenAvailable>false</StartWhenAvailable>
		    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
		    <IdleSettings>
		      <Duration>PT10M</Duration>
		      <WaitTimeout>PT1H</WaitTimeout>
		      <StopOnIdleEnd>true</StopOnIdleEnd>
		      <RestartOnIdle>false</RestartOnIdle>
		    </IdleSettings>
		    <AllowStartOnDemand>true</AllowStartOnDemand>
		    <Enabled>true</Enabled>
		    <Hidden>false</Hidden>
		    <RunOnlyIfIdle>false</RunOnlyIfIdle>
		    <WakeToRun>false</WakeToRun>
		    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
		    <Priority>7</Priority>
		  </Settings>
		  <Actions Context="Author">
		    <Exec>
		      <Command>"%Command%"</Command>
		    </Exec>
		  </Actions>
		  <Principals>
		    <Principal id="Author">
		      <UserId>%A_ComputerName%\%A_UserName%</UserId>
		      <LogonType>InteractiveToken</LogonType>
		      <RunLevel>%Privilege%</RunLevel>
		    </Principal>
		  </Principals>
		</Task>
		)
		
		XML_Text := RegExReplace( XML_Text, "m)^\t{2}", "" )
		
		FileAppend, %XML_Text%, %Task_XML%
	}
	
	Task_Exists( ByRef Task_Name, ByRef Command := 0 )
	{ 
		static Task_File
		static Task_Command
		Task_File := This.Tasks_Dir "\" RegExReplace( Task_Name, "^\\", "" )
		If FileExist( Task_File ) {
			If ( Command ) {
				Loop, Read, %Task_File%
				{
					Loop, Parse, A_LoopReadLine, `n, `r
					{
						Task_Full_Name := SubStr( A_LoopFileFullPath, This.Tasks_Dir_Lenght )
						If RegExMatch( A_LoopReadLine, ".*<Command>(.*?)<\/Command>", Match) {
							Task_Command := Trim( Match1, """" )
							
							If ( Task_Command = Command ) {
								Return, True
							}
						}
					}
				}
			} Else {
				Return, True
			}
		}
		Return, False
	}
}