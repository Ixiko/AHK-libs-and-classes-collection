Check_ForUpdate(_ReplaceCurrentScript = 1, _SuppressMsgBox = 0, _CallbackFunction = "", ByRef _Information = "")
{
	;Version.ini file format - this is just an example of what the version.ini file would look like
	;
	;[Info]
	;Version=1.9
	;URL=http://www.mywebsite.com/my%20file.ahk or .exe
	;MD5=00000000000000000000000000000000 or omit this key completly to skip the MD5 file validation
	
	Static Script_Name := "Self Script Updater" ;Your script name
	, Version_Number := 1.8 ;The script's version number
	, Update_URL := "http://www.autohotkey.net/~Rseding91/Self%20Script%20Updater/Version.ini" ;The URL of the version.ini file for your script
	, Retry_Count := 3 ;Retry count for if/when anything goes wrong
	
	Random,Filler,10000000,99999999
	Version_File := A_Temp . "\" . Filler . ".ini"
	, Temp_FileName := A_Temp . "\" . Filler . ".tmp"
	, VBS_FileName := A_Temp . "\" . Filler . ".vbs"
	
	Loop,% Retry_Count
	{
		_Information := ""
		
		UrlDownloadToFile,%Update_URL%,%Version_File%
		
		IniRead,Version,%Version_File%,Info,Version,N/A
		
		If (Version = "N/A"){
			FileDelete,%Version_File%
			
			If (A_Index = Retry_Count)
				_Information .= "The version info file doesn't have a ""Version"" key in the ""Info"" section or the file can't be downloaded."
			Else
				Sleep,500
			
			Continue
		}
		
		If (Version > Version_Number){
			If (_SuppressMsgBox != 1 and _SuppressMsgBox != 3){
				MsgBox,0x4,New version available,There is a new version of %Script_Name% available.`nCurrent version: %Version_Number%`nNew version: %Version%`n`nWould you like to download it now?
				
				IfMsgBox,Yes
					MsgBox_Result := 1
			}
			
			If (_SuppressMsgBox or MsgBox_Result){
				IniRead,URL,%Version_File%,Info,URL,N/A
				
				If (URL = "N/A")
					_Information .= "The version info file doesn't have a valid URL key."
				Else {
					SplitPath,URL,,,Extension
					
					If (Extension = "ahk" And A_AHKPath = "")
						_Information .= "The new version of the script is an .ahk filetype and you do not have AutoHotKey installed on this computer.`r`nReplacing the current script is not supported."
					Else If (Extension != "exe" And Extension != "ahk")
						_Information .= "The new file to download is not an .EXE or an .AHK file type. Replacing the current script is not supported."
					Else {
						IniRead,MD5,%Version_File%,Info,MD5,N/A
						
						Loop,% Retry_Count
						{
							UrlDownloadToFile,%URL%,%Temp_FileName%
							
							IfExist,%Temp_FileName%
							{
								If (MD5 = "N/A"){
									_Information .= "The version info file doesn't have a valid MD5 key."
									, Success := True
									Break
								} Else {
									Ptr := A_PtrSize ? "Ptr" : "UInt"
									, H := DllCall("CreateFile",Ptr,&Temp_FileName,"UInt",0x80000000,"UInt",3,"UInt",0,"UInt",3,"UInt",0,"UInt",0)
									, DllCall("GetFileSizeEx",Ptr,H,"Int64*",FileSize)
									, FileSize := FileSize = -1 ? 0 : FileSize
									
									If (FileSize != 0){
										VarSetCapacity(Data,FileSize,0)
										, DllCall("ReadFile",Ptr,H,Ptr,&Data,"UInt",FileSize,"UInt",0,"UInt",0)
										, DllCall("CloseHandle",Ptr,H)
										, VarSetCapacity(MD5_CTX,104,0)
										, DllCall("advapi32\MD5Init",Ptr,&MD5_CTX)
										, DllCall("advapi32\MD5Update",Ptr,&MD5_CTX,Ptr,&Data,"UInt",FileSize)
										, DllCall("advapi32\MD5Final",Ptr,&MD5_CTX)
										
										FileMD5 := ""
										Loop % StrLen(Hex:="123456789ABCDEF0")
											N := NumGet(MD5_CTX,87+A_Index,"Char"), FileMD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
										
										VarSetCapacity(Data,FileSize,0)
										, VarSetCapacity(Data,0)
										
										If (FileMD5 != MD5){
											FileDelete,%Temp_FileName%
											
											If (A_Index = Retry_Count)
												_Information .= "The MD5 hash of the downloaded file does not match the MD5 hash in the version info file."
											Else										
												Sleep,500
											
											Continue
										} Else
											Success := True
									} Else {
										DllCall("CloseHandle",Ptr,H)
										Success := True
									}
								}
							} Else {
								If (A_Index = Retry_Count)
									_Information .= "Unable to download the latest version of the file from " . URL . "."
								Else
									Sleep,500
								Continue
							}
						}
					}
				}
			}
		} Else
			_Information .= "No update was found."
		
		FileDelete,%Version_File%
		Break
	}
	
	If (_ReplaceCurrentScript And Success){
		SplitPath,URL,,,Extension
		Process,Exist
		MyPID := ErrorLevel
		
		VBS_P1 =
		(LTrim Join`r`n
			On Error Resume Next
			Set objShell = CreateObject("WScript.Shell")
			objShell.Run "TaskKill /F /PID %MyPID%", 0, 1
			Set objFSO = CreateObject("Scripting.FileSystemObject")
		)
		
		If (A_IsCompiled){
			SplitPath,A_ScriptFullPath,,Dir,,Name
			VBS_P2 =
			(LTrim Join`r`n
				Finished = False
				Count = 0
				Do Until (Finished = True Or Count = 5)
					Err.Clear
					objFSO.CopyFile "%Temp_FileName%", "%Dir%\%Name%.%Extension%", True
					If (Err.Number = 0) then
						Finished = True
						objShell.Run """%Dir%\%Name%.%Extension%"""
					Else
						WScript.Sleep(1000)
						Count = Count + 1
					End If
				Loop
				objFSO.DeleteFile "%Temp_FileName%", True
			)
			
			Return_Val :=  Temp_FileName
		} Else {
			If (Extension = "ahk"){
				FileMove,%Temp_FileName%,%A_ScriptFullPath%,1
				If (Errorlevel)
					_Information .= "Error (" . Errorlevel . ") unable to replace current script with the latest version."
				Else {
					VBS_P2 = 
					(LTrim Join`r`n
						objShell.Run """%A_ScriptFullPath%"""
					)
					
					Return_Val :=  A_ScriptFullPath
				}
			} Else If (Extension = "exe"){
				SplitPath,A_ScriptFullPath,,FDirectory,,FName
				FileMove,%Temp_FileName%,%FDirectory%\%FName%.exe,1
				FileDelete,%A_ScriptFullPath%
				
				VBS_P2 =
				(LTrim Join`r`n
					objShell.Run """%FDirectory%\%FName%.exe"""
				)
				
				Return_Val :=  FDirectory . "\" . FName . ".exe"
			} Else {
				FileDelete,%Temp_FileName%
				_Information .= "The downloaded file is not an .EXE or an .AHK file type. Replacing the current script is not supported."
			}
		}
		
		VBS_P3 =
		(LTrim Join`r`n
			objFSO.DeleteFile "%VBS_FileName%", True
		)
		
		If (_SuppressMsgBox < 2)
		{
			If (InStr(VBS_P2, "Do Until (Finished = True Or Count = 5)"))
			{
				VBS_P3 .= "`r`nIf (Finished = False) Then"
				VBS_P3 .= "`r`nWScript.Echo ""Update failed."""
				VBS_P3 .= "`r`nElse"
				If (Extension != "exe")
					VBS_P3 .= "`r`nobjFSO.DeleteFile """ A_ScriptFullPath """"
				VBS_P3 .= "`r`nWScript.Echo ""Update completed successfully."""
				VBS_P3 .= "`r`nEnd If"
			} Else
				VBS_P3 .= "`r`nWScript.Echo ""Update complected successfully."""
		}
		
		FileDelete,%VBS_FileName%
		FileAppend,%VBS_P1%`r`n%VBS_P2%`r`n%VBS_P3%,%VBS_FileName%
		
		If (_CallbackFunction != ""){
			If (IsFunc(_CallbackFunction))
				%_CallbackFunction%()
			Else
				_Information .= "The callback function is not a valid function name."
		}
		
		RunWait,%VBS_FileName%,%A_Temp%,VBS_PID
		Sleep,2000
		
		Process,Close,%VBS_PID%
		_Information := "Error (?) unable to replace current script with the latest version.`r`nPlease make sure your computer supports running .vbs scripts and that the script isn't running in a pipe."
	}
	
	_Information := _Information = "" ? "None" : _Information
	
	Return Return_Val
}