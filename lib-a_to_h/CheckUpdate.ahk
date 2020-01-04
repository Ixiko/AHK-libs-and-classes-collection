CheckUpdate(_ReplaceCurrentScript:=1, _SuppressMsgBox:=0, _CallbackFunction:="", ByRef _Information:="") {
	Static Update_URL   := "http://files.wsnhapps.com/hotstrings/Custom%20Hotstrings.text"
		 , Download_URL := "http://files.wsnhapps.com/hotstrings/Custom%20Hotstrings.exe" 
		 , Retry_Count  := 2
		 , Script_Name
	
	;auto_version
	if (!Version)
		return
	if (!Script_Name) {
		SplitPath, A_ScriptFullPath,,,, scrName
		Script_Name := scrName
	}
	Random, Filler, 10000000, 99999999	
	Version_File := A_Temp "\" Filler ".ini", Temp_FileName:=A_Temp "\" Filler ".tmp", VBS_FileName:=A_Temp "\" Filler ".vbs"
	Loop, %Retry_Count% {
		_Information := ""
		UrlDownloadToFile,%Update_URL%,%Version_File%
		Loop, Read, %Version_File%
		{
			UDVersion := A_LoopReadLine ? A_LoopReadLine : "N/A"
			break
		}
		if (UDVersion = "N/A") {
			FileDelete,%Version_File%
			if (A_Index = Retry_Count)
				_Information .= "The version info file doesn't have a ""Version"" key in the ""Info"" section or the file can't be downloaded."
			else
				Sleep, 500
			Continue
		}
		if (UDVersion > Version) {
			if (_SuppressMsgBox != 1 && _SuppressMsgBox != 3)
				if (m("There is a new version of " Script_Name " available.", "Current version: " Version, "New version: " UDVersion," ", "Would you like to download it now?", "title:New version available", "btn:yn", "ico:i") = "Yes")
					MsgBox_Result := 1
			if (_SuppressMsgBox || MsgBox_Result) {
				URL := Download_URL
				SplitPath, URL,,, Extension					
				if (Extension = "ahk" && A_AHKPath = "")
					_Information .= "The new version of the script is an .ahk filetype and you do not have AutoHotKey installed on this computer.`r`nReplacing the current script is not supported."
				else if (Extension != "exe" && Extension != "ahk")
					_Information .= "The new file to download is not an .EXE or an .AHK file type. Replacing the current script is not supported."
				else {
					IniRead,MD5,%Version_File%,Info,MD5,N/A
					Loop, %Retry_Count% {
						UrlDownloadToFile,%URL%,%Temp_FileName%
						if (FileExist(Temp_FileName)) {
							if (MD5 = "N/A") {
								_Information.="The version info file doesn't have a valid MD5 key.", Success:= True
								Break
							}
							else {
								Ptr:=A_PtrSize?"Ptr":"UInt", H:=DllCall("CreateFile",Ptr,&Temp_FileName,"UInt",0x80000000,"UInt",3,"UInt",0,"UInt",3,"UInt",0,"UInt",0), DllCall("GetFileSizeEx",Ptr,H,"Int64*",FileSize), FileSize:=FileSize = -1 ? 0 : FileSize
								if (FileSize != 0) {
									VarSetCapacity(Data,FileSize,0), DllCall("ReadFile",Ptr,H,Ptr,&Data,"UInt",FileSize,"UInt",0,"UInt",0), DllCall("CloseHandle",Ptr,H), VarSetCapacity(MD5_CTX,104,0), DllCall("advapi32\MD5Init",Ptr,&MD5_CTX), DllCall("advapi32\MD5Update",Ptr,&MD5_CTX,Ptr,&Data,"UInt",FileSize), DllCall("advapi32\MD5Final",Ptr,&MD5_CTX), FileMD5:=""
									Loop, % StrLen(Hex:="123456789ABCDEF0")
										N := NumGet(MD5_CTX,87+A_Index,"Char"), FileMD5 .= SubStr(Hex,N>>4,1) SubStr(Hex,N&15,1)
									VarSetCapacity(Data,FileSize,0), VarSetCapacity(Data,0)
									if (FileMD5 != MD5) {
										FileDelete,%Temp_FileName%
										if (A_Index = Retry_Count)
											_Information .= "The MD5 hash of the downloaded file does not match the MD5 hash in the version info file."
										else
											Sleep, 500
										Continue
									}
									else
										Success := True
								}
								else
									DllCall("CloseHandle",Ptr,H), Success := True									
							}
						}
						else {
							if (A_Index = Retry_Count)
								_Information .= "Unable to download the latest version of the file from " URL "."
							else
								Sleep, 500
							Continue
						}
					}
				}
			}
		}
		else
			_Information .= "No update was found."
		FileDelete, %Version_File%
		Break
	}	
	if (_ReplaceCurrentScript && Success) {
		SplitPath, URL,,, Extension
		Process, Exist
		MyPID := ErrorLevel
		VBS_P1 =
		(LTrim Join`r`n
			On Error Resume Next
			Set objShell = CreateObject("WScript.Shell")
			objShell.Run "TaskKill /F /PID %MyPID%", 0, 1
			Set objFSO = CreateObject("Scripting.FileSystemObject")
		)
		if (A_IsCompiled) {
			SplitPath, A_ScriptFullPath,, Dir,, Name
			VBS_P2 =
			(LTrim Join`r`n
				Finished = False
				Count = 0
				Do Until (Finished = True Or Count = 5)
					Err.Clear
					objFSO.CopyFile "%Temp_FileName%", "%Dir%\%Name%.%Extension%", True
					if (Err.Number = 0) then
						Finished = True
						objShell.Run """%Dir%\%Name%.%Extension%"""
					else
						WScript.Sleep(1000)
						Count = Count + 1
					End if
				Loop
				objFSO.DeleteFile "%Temp_FileName%", True
			)
			Return_Val := Temp_FileName
		}
		else {
			if (Extension = "ahk") {
				FileMove,%Temp_FileName%,%A_ScriptFullPath%,1
				if (Errorlevel)
					_Information .= "Error (" Errorlevel ") unable to replace current script with the latest version."
				else {
					VBS_P2 =
					(LTrim Join`r`n
						objShell.Run """%A_ScriptFullPath%"""
					)
					Return_Val :=  A_ScriptFullPath
				}
			}
			else if (Extension = "exe") {
				SplitPath, A_ScriptFullPath,, FDirectory,, FName
				FileMove, %Temp_FileName%, %FDirectory%\%FName%.exe, 1
				FileDelete, %A_ScriptFullPath%
				VBS_P2 =
				(LTrim Join`r`n
					objShell.Run """%FDirectory%\%FName%.exe"""
				)
				Return_Val :=  FDirectory "\" FName ".exe"
			}
			else {
				FileDelete,%Temp_FileName%
				_Information .= "The downloaded file is not an .EXE or an .AHK file type. Replacing the current script is not supported."
			}
		}
		VBS_P3 =
		(LTrim Join`r`n
			objFSO.DeleteFile "%VBS_FileName%", True
		)
		if (_SuppressMsgBox < 2) {
			if (InStr(VBS_P2, "Do Until (Finished = True Or Count = 5)")) {
				VBS_P3.="`r`nif (Finished=False) Then", VBS_P3.="`r`nWScript.Echo ""Update failed.""", VBS_P3.="`r`nelse"
				if (Extension != "exe")
					VBS_P3 .= "`r`nobjFSO.DeleteFile """ A_ScriptFullPath """"
				VBS_P3.="`r`nWScript.Echo ""Update completed successfully.""", VBS_P3.="`r`nEnd if"
			}
			else
				VBS_P3 .= "`r`nWScript.Echo ""Update complected successfully."""
		}
		FileDelete, %VBS_FileName%
		FileAppend, %VBS_P1%`r`n%VBS_P2%`r`n%VBS_P3%, %VBS_FileName%
		if (_CallbackFunction != "") {
			if (IsFunc(_CallbackFunction))
				%_CallbackFunction%()
			else
				_Information .= "The callback function is not a valid function name."
		}
		RunWait, %VBS_FileName%, %A_Temp%, VBS_PID
		Sleep, 2000
		Process, Close, %VBS_PID%
		_Information := "Error (?) unable to replace current script with the latest version.`r`nPlease make sure your computer supports running .vbs scripts and that the script isn't running in a pipe."
	}
	_Information := _Information ? _Information : "None"
	Return Return_Val
}