OpenFilepaths(fnPathListCSV,ByRef fnCountOfItems := 0,ByRef fnCountOfErrors := 0,ByRef fnCountOfSuccesses := 0,fnBrowserId := 0)
{
	; opens a list of file or folder paths
	; MsgBox fnPathListCSV: %fnPathListCSV%`nfnCountOfItems: %fnCountOfItems%`nfnCountOfErrors: %fnCountOfErrors%`nfnCountOfSuccesses: %fnCountOfSuccesses%`nfnBrowserId: %fnBrowserId%


	; declare local, global, static variables
	Global ErrorListFileName, USERPROFILE


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If !fnPathListCSV
			Throw, Exception("fnPathListCSV was empty")
		
		If fnBrowserId not in 0,1,2,3 ;,4
			fnBrowserId := 0 ;use default


		; initialise variables
		PathListCSV := fnPathListCSV
		ErrorListFilePath := A_Temp "\" ErrorListFileName
		Browser := fnBrowserId = 1 ? "firefox.exe"
		        :  fnBrowserId = 2 ? "chrome.exe"
		        :  fnBrowserId = 3 ? "iexplore.exe" ;IE
		        ; :  fnBrowserId = 4 ? "Edge"
				:                    ""       ; Default


		; remove old error file
		Try
		{
			FileDelete, %ErrorListFilePath%
		}

		
		; clean up list
		PathListCSV := RegExReplace(PathListCSV,"imS)[ \t]*\R[ \t]*","") ; remove line breaks and trim strings
		StringReplace, PathListCSV, PathListCSV, `%A_MyDocuments`%, %A_MyDocuments%, All
		StringReplace, PathListCSV, PathListCSV, `%A_Desktop`%    , %A_Desktop%    , All
		StringReplace, PathListCSV, PathListCSV, `%A_UserName`%   , %A_UserName%   , All
		StringReplace, PathListCSV, PathListCSV, `%A_Temp`%       , %A_Temp%       , All
		StringReplace, PathListCSV, PathListCSV, `%A_WinDir`%     , %A_WinDir%     , All
		StringReplace, PathListCSV, PathListCSV, `%WinDir`%       , %A_WinDir%     , All
		StringReplace, PathListCSV, PathListCSV, `%USERPROFILE`%  , %USERPROFILE%  , All
		StringReplace, PathListCSV, PathListCSV, xCompanyNamex    , %CompanyName%  , All
		StringReplace, PathListCSV, PathListCSV, >                ,                , All
		StringReplace, PathListCSV, PathListCSV, <                ,                , All
		PathListCSV := RegExReplace(PathListCSV,"imS)[ \t]*\R[ \t]*","") ; remove line breaks and trim strings
		
		fnCountOfItems := 0
		fnCountOfErrors := 0
		fnCountOfSuccesses := 0
		Loop, Parse, PathListCSV, `,,%A_Space%%A_Tab%
		{
			fnCountOfItems := A_Index
			RunString := A_LoopField
			
			If (RegExMatch(A_LoopField,"imS)^([A-Z]:)?[\\/][\\/]?.*") || !fnBrowserId) ; network share (\\abc) or drive (D:\abc)
			{
				Run, %RunString%,,UseErrorLevel
				ThisError := ErrorLevel
			}
			Else If (RegExMatch(A_LoopField,"imS)^https?://.*") || RegExMatch(A_LoopField,"imS)^www\..*")) ; web page
			{
				If (SubStr(A_LoopField,1,3) = "www")
					RunString := "http://" RunString
				Run, %Browser% %RunString%,,UseErrorLevel
				ThisError := ErrorLevel
			}
			Else
				++fnCountOfErrors
			
			If ThisError
			{
				fnCountOfErrors++
				FileAppend, %RunString%`n, %ErrorListFilePath%
				MsgBox ThisError %ThisError%
			}
			Else
				++fnCountOfSuccesses
		}
		
		IfExist, %ErrorListFilePath%
			Run, Notepad.exe %ErrorListFilePath%

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
GetEnvironmentVariables()
ErrorListFileName := "TestERr.txt"
SomePathListCSV := "https://cloud.githubusercontent.com/assets/23632110/22274091/465feac8-e259-11e6-9188-51d87cbc3c1c.png,%A_MyDocuments%\_%A_UserName%\_AHK,%A_MyDocuments%\_%A_UserName%\Test,C:\abc"
ReturnValue := OpenFilepaths(SomePathListCSV)
MsgBox, OpenFilepaths`n`nReturnValue: %ReturnValue%
*/