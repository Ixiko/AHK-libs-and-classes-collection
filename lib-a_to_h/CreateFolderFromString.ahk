CreateFolderFromString(fnPathString,fnOpenFolderWindow := 0)
{
	; creates a new folder from the input string
	; MsgBox fnPathString: %fnPathString%`nfnOpenFolderWindow: %fnOpenFolderWindow%


	; declare local, global, static variables
	Global LocalSourceControlRootFolder


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If !fnPathString
			Throw, Exception("fnPathString was empty")
		If !RegExMatch(fnPathString,"imS)([A-Z]?[:\\]\\).*") ; network share (\\abc) or drive (D:\abc)
			Throw, Exception("fnPathString was not valid")


		; initialise variables
		PathString := fnPathString


		; clean up the path string
		StringReplace, PathString, PathString, $, %LocalSourceControlRootFolder%
		StringReplace, PathString, PathString, /, \, All
		
		
		; get the folder path
		SplitPath, PathString, PathFileName, PathDir, PathExtension, PathNameNoExt, PathDrive
		If !PathExtension ; if extension is empty, it's a folder path
			PathDir = %PathDir%\%PathFileName% ; add the name to the folder path
		
		
		; create the folder
		ReturnValue := -1
		IfNotExist, %PathDir%
		{
			InputBox, CreatePathString, %ApplicationName%, Create this folder?:,,700,150,,,,,%PathDir%
			If ErrorLevel
				Return ReturnValue
			FileCreateDir, %PathDir%
			ReturnValue := 0
			Sleep, 100 ; slight delay for creation to complete
		}
		
		; open the folder
		If fnOpenFolderWindow
		{
			IfWinNotExist, ahk_class CabinetWClass, %PathDir%
				Run, %PathDir%
			WinActivate, ahk_class CabinetWClass, %PathDir%
			WinWaitActive, ahk_class CabinetWClass, %PathDir%
			Send !d ; select address bar
		}
		; Clipboard := PathDir


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
SomeNewFolder := "C:\abc"
ReturnValue := CreateFolderFromString(SomeNewFolder,1)
MsgBox, CreateFolderFromString`n`nReturnValue: %ReturnValue%
FileRemoveDir, %SomeNewFolder%
*/