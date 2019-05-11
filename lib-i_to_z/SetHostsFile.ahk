SetHostsFile(fnHostsFileLabel,fnOpenFile := 0)
{
	; set the hosts file from an existing text file
	; write permission on the hosts file may need to be provided
	; MsgBox fnHostsFileLabel: %fnHostsFileLabel%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; initialise variables
		StringLower, fnHostsFileLabel, fnHostsFileLabel
		ThisSourceHostsFileName := "hosts" fnHostsFileLabel ".txt"
		ThisSourceHostsFilePath := "C:\Windows\System32\Drivers\etc\" ThisSourceHostsFileName
		DestinationHostsFile := "C:\Windows\System32\Drivers\etc\hosts"
		; DestinationHostsFile := A_Desktop "\hosts" ;testing


		; validate parameters
		If !fnHostsFileLabel
			Throw, Exception("fnHostsFileLabel was empty")
		If !FileExist(ThisSourceHostsFilePath)
			Throw, Exception("Source file does not exist: " ThisSourceHostsFilePath)


		; do something
		FileCopy, %ThisSourceHostsFilePath%, %DestinationHostsFile%, 1 ; overwrite
		If ErrorLevel
		{
			ErrorMessage := GetSystemErrorText(A_LastError)
			Throw, Exception(ErrorMessage)
		}
		; Run, *RunAs notepad.exe %ThisSourceHostsFilePath%
		; WinWait, %ThisSourceHostsFileName% - Notepad
		; WinActivate, %ThisSourceHostsFileName% - Notepad
		; Send, !fa ; File > Save As...
		; WinWait, Save As ahk_class #32770 ahk_exe notepad.exe
		; Send hosts{Tab} ; File name
		; Send {Down 2}{Enter} ; Save as type = All files (*.*)
		; Sleep, 1000
		; ControlClick, Button2, Save As ahk_class #32770 ahk_exe notepad.exe ; Save
		
		If fnOpenFile
		{
			IfWinExist, hosts
				WinActivate
			Else
				Run, Notepad++.exe %DestinationHostsFile%
		}


	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
params := xxx
ReturnValue := SetHostsFile(params)
MsgBox, SetHostsFile`n`nReturnValue: %ReturnValue%
*/