class Script
{ ; функции управления скриптом

	Force_Single_Instance(File_Names := false, WaitCloseSec := 1, Force := 1)
	{ ; функция автоматического завершения всех копий текущего скрипта (одновременно для .exe и .ahk)
		local
		Detect_Hidden_Windows_Tmp := A_DetectHiddenWindows
		#SingleInstance, Off
		DetectHiddenWindows, On
		Script_Name := RegExReplace(A_ScriptName, "^(.*)\.(.*)$", "$1")
		File_Names := File_Names ? File_Names : [ Script_Name ] ; [ Script_Name . ".exe", Script_Name . ".ahk" ]
		for Index, File_Name in File_Names {
			App_Full_Path := A_ScriptDir . "\" . File_Name
			This.Close_Other_Instances(App_Full_Path . " ahk_class AutoHotkey", WaitCloseSec := 1, Force := 1) ; This.Close_Other_Instances(App_Full_Path . " ahk_class AutoHotkey")
		}
		DetectHiddenWindows, % Detect_Hidden_Windows_Tmp
	}
	
	Close_Process(Process_PID, WaitCloseSec := 1, Force := 1)
	{ ; функция завершения процесса с вызовом сабрутины OnExit
		local
		DHW := A_DetectHiddenWindows
		DetectHiddenWindows, On
		if WinExist("ahk_pid " . Process_PID) {
			PostMessage, 0x111, 65405, 0,, ahk_pid %Process_PID%
			if (WaitCloseSec) {
				; WinWaitClose, ahk_pid %Process_PID%,, %WaitCloseSec%
				Process, WaitClose, ahk_pid %Process_PID%, %WaitCloseSec%
			}
		}
		if (Force) {
			Process, Close, %Process_PID%
		}
		DetectHiddenWindows, %DHW%
		return
	}
	
	Close_Other_Instances(App_Full_Path, WaitCloseSec := 1, Force := 1)
	{ ; функция завершения всех копий текущего скрипта (только для указанного файла)
		local
		App_Full_Path := App_Full_Path ? App_Full_Path : A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Current_ID, ID, % A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Current_PID, PID, % A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Process_List, List, % App_Full_Path . " ahk_class AutoHotkey"
		Process_Count := 1
		; MsgBox, App_Full_Path: %App_Full_Path%
		; MsgBox, Process_List: %Process_List%
		Loop, %Process_List%
		{
			; MsgBox, App_Full_Path: %App_Full_Path%
			; MsgBox, Process_ID: %Process_ID%
			Process_ID := Process_List%Process_Count%
			if (Process_ID and Process_ID != Current_ID) {
				WinGet, Process_PID, PID, % App_Full_Path . " ahk_id " . Process_ID
				; Process, Close, %Process_PID%
				This.Close_Process(Process_PID, WaitCloseSec, Force)
			}
			Process_Count += 1
		}
		;
		Script_Name := RegExReplace(A_ScriptFullPath, "^(.*)(_x32|_x64)\..*", "$1")
		for ProcessObj in ComObjGet("winmgmts:").ExecQuery("Select ProcessId, CommandLine from Win32_Process where name = 'Autohotkey.exe'", "WQL", 0x20 | 0x10 | 0x0) {
			; MsgBox, % "ProcessObj.CommandLine: " . ProcessObj.CommandLine "`nScript_Name: " Script_Name
			if InStr(ProcessObj.CommandLine, Script_Name) {
				; MsgBox, % "processObj.CommandLine: " . processObj.CommandLine
				if (ProcessObj.ProcessId != Current_PID) {
					This.Close_Process(ProcessObj.ProcessId, WaitCloseSec, Force)
				}
			}
		}
	}

	Run_As_Admin(Params := "")
	{ ; функция запуска скрипта с правами администратора
		if (not A_IsAdmin) {
			try {
				Run, *RunAs "%A_ScriptFullPath%" %Params%
			}
			ExitApp
		}
	}

	Name()
	{ ; функция получения имени текущего скрипта
		local
		SplitPath, A_ScriptFullPath,,,, Name
		return Name
	}

	Args()
	{ ; функция получения аргументов коммандной строки в виде текста
		local
		global A_Args
		ret := ""
		for n, param in A_Args
		{
			ret .= " " param
		}
		ret := Trim(ret)
		return ret
	}
	
	InArgs(Arg)
	{ ; функция получения аргументов коммандной строки в виде текста
		local
		for n, param in A_Args
		{
			param := Trim(param)
			if (param = Arg) {
				return n
			}
		}
		return
	}
}
