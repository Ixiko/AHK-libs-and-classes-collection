/*           ,---,                                          ,--,   
           ,--.' |                                        ,--.'|   
           |  |  :                      .--.         ,--, |  | :   
  .--.--.  :  :  :                    .--,`|       ,'_ /| :  : '   
 /  /    ' :  |  |,--.  ,--.--.       |  |.   .--. |  | : |  ' |   
|  :  /`./ |  :  '   | /       \      '--`_ ,'_ /| :  . | '  | |   
|  :  ;_   |  |   /' :.--.  .-. |     ,--,'||  ' | |  . . |  | :   
 \  \    `.'  :  | | | \__\/: . .     |  | '|  | ' |  | | '  : |__ 
  `----.   \  |  ' | : ," .--.; |     :  | |:  | : ;  ; | |  | '.'|
 /  /`--'  /  :  :_:,'/  /  ,.  |   __|  : ''  :  `--'   \;  :    ;
'--'.     /|  | ,'   ;  :   .'   \.'__/\_: |:  ,      .-./|  ,   / 
  `--'---' `--''     |  ,     .-./|   :    : `--`----'     ---`-'   
                      `--`---'     \   \  /                         
                                    `--`-' 
------------------------------------------------------------------
Class        : FTP
Library      : FTPv2
Requires     : Autohotkey_L 1.1+
URL          : http://www.autohotkey.com/forum/viewtopic.php?t=73544
Documentation: http://www.autohotkey.net/~shajul/Projects/FTPv2/docs/
------------------------------------------------------------------
*/

/*
Original FTP Functions by Olfen & Andreone -> http://www.autohotkey.com/forum/viewtopic.php?t=10393
Modified by ahklerner
Modified by me for AHK_L -> http://www.autohotkey.com/forum/viewtopic.php?t=67370

Version 2: 2011-06-26
---------------------
- All the functions wrapped into a class (NO global variables)
- Multiple FTP connections possible with same class
- Asynchronous mode is now fully functional! (Read notes below also)
- No need to call .Close(), clean-up is done when ftp object is deleted.
*/

/* ASYNCHRONOUS MODE
-----------------------------
Please read the notes on asynchronous mode in the documentation first!
*/

;
; Function: FTPv2
; Description:
;      Initializes and returns the FTP object. It is an alias for the FTP Class.
; Syntax: oFTP := FTPv2([AsyncMode, Proxy, ProxyBypass])
; Parameters:
;      AsyncMode - (Optional) Asynchronous callback function name. If it is number/true, built in function is used. (default: off) (see notes on asynchronous mode)
;      Proxy - (Optional) Connect via proxy (TIS FTP gateway, Socks only if IE installed)
;      ProxyBypass - (Optional) Bypass addresses from proxy (localhost bypassed by default)
; Return Value:
;      Creates an object with Methods and Properties as described below
; Remarks:
;      It is an alias for FTP class, creating and returning the FTP object.
;      An alias is required so that this class is Lib compatible. Jut put this library in your Lib folder,
;      no need to include.
; Related: FTP, oFTP.Open
; Example:
;      see example in FTP Class
;
FTPv2( AsyncMode=0 , Proxy = "" , ProxyBypass = "") {
	global FTP
	return (ftp := new FTP(AsyncMode,Proxy,ProxyBypass))
}


;
; Function: FTP
; Description:
;      Initializes and returns the FTP object
; Syntax: oFTP := new FTP([AsyncMode, Proxy, ProxyBypass])
; Parameters:
;      AsyncMode - (Optional) Asynchronous callback function name. If it is number/true, built in function is used. (default: off) (see notes on asynchronous mode)
;      Proxy - (Optional) Connect via proxy (TIS FTP gateway, Socks only if IE installed)
;      ProxyBypass - (Optional) Bypass addresses from proxy (localhost bypassed by default)
; Return Value:
;      Creates an object with Methods and Properties as described below
; Remarks:
;      Options can be set (see Properties) before calling .Open() method
; Related: oFTP.Open, FTPv2
; Example:
;      file:Example.ahk
;
class FTP
{
	__New( AsyncMode=0 , Proxy = "" , ProxyBypass = "") {
		static context := 0
		If AsyncMode
		{
			If AsyncMode is integer
				FTPCallbackAddress := RegisterCallback("FTP_Callback","",5)
			else
				FTPCallbackAddress := RegisterCallback(AsyncMode,"",5)
			Flags := 0x10000000, context := context+1
			OnMessage(DllCall("RegisterWindowMessage","Str","AHK FTP Library Async Message"),"FTP_Status")
		}
		else
			Flags := 0, this.Async := 0
		AccessType := (Proxy = "") ? 1 : 3  ;0-registry conf, 1-direct, 3-named proxy, 4- prevent using java/script
		if !(this.hModule := DllCall("LoadLibrary", "str", "wininet.dll", "Ptr"))
			Return 0
		this.hInternetOpen := DllCall("wininet\InternetOpen"
		, "str" , A_ScriptName ;lpszAgent
		, "UInt", AccessType , "str" , Proxy , "str", ProxyBypass , "UInt", Flags, "Ptr")

		If (ErrorLevel != 0 or this.hInternetOpen = 0)
			Return 0 , this.Close()

		if (AsyncMode && (DllCall("wininet\InternetSetStatusCallback", "Ptr", this.hInternetOpen, "Int", FTPCallbackAddress, "UInt") <> -1))
			this.Async := context
	 
		this.InternetConnectFlags := 0
		this.Port := 21
		this["File","BufferSize"] := 4096
	}

	;
	; Function: oFTP.Open
	; Description:
	;      Opens an FTP connection and returns the InternetConnect handle on success, 0 on failure
	; Syntax: oFTP.Open(Server, [Username, Password])
	; Parameters:
	;      Server - FTP server
	;      Username - (Optional) Username
	;      Password - (Optional) Password
	; Return Value:
	;      Handle of InternetConnect on success, false otherwise.
	; Remarks:
	;      Port, InternetConnectFlags can be set beforehand [see Properties of FTP class]
	; Related: FTP , oFTP.CloseHandle
	; Example:
	;      oFTP.Open("ftp.autohotkey.net", "myUserName", "myPassword")
	;
	Open(Server, Username=0, Password=0) {
		if this.Async
			this.base.AsyncRequestComplete := 0, this.base.AsynchInternet := 0
		IfEqual, Username, 0, SetEnv, Username, anonymous
		IfEqual, Password, 0, SetEnv, Password, anonymous
		
		r := DllCall("wininet\InternetConnect" , "PTR", this.hInternetOpen , "str", Server , "uint", this.Port
		, "str", Username , "str", Password
		, "uint" , 1 ;dwService (INTERNET_SERVICE_FTP = 1)
		, "uint", this.InternetConnectFlags ;dwFlags
		, "uint", this.Async, "Ptr") ;dwContext
		
		If (ErrorLevel or !(r || this.Async))
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)
		If this.Async
		{
			while !this.base.AsyncRequestComplete
				sleep 10
			this.hInternet := this.base.AsynchInternet
		}
		else
			this.hInternet := r
		Return this.hInternet , this.LastError := 0
	}

	;
	; Function: oFTP.GetCurrentDirectory
	; Description:
	;      Gets the current directory path on FTP server
	; Syntax: oFTP.GetCurrentDirectory()
	; Remarks:
	;      This function does not (yet) support Async mode, see Asynchronous mode remarks.
	; Return Value:
	;      Current directory path, 0 on error
	; Related: oFTP.SetCurrentDirectory
	; Example:
	;      sCurrentDir := oFTP.GetCurrentDirectory()
	;
	GetCurrentDirectory() {
		if this.Async
			Return 0 ;This function does not (yet) support Async. See Asynchronous mode remarks in help file.
		nSize := A_IsUnicode ? (2*260) : 260 ;Maxpath
		VarSetCapacity(ic_currdir, nSize)
		r := DllCall("wininet\FtpGetCurrentDirectory", "PTR", this.hInternet, "PTR", &ic_currdir, "UIntP", &nSize)
		If (ErrorLevel or !(r || this.Async))
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)

		Return StrGet(&ic_currdir,nSize) , this.LastError := 0
	}

	;
	; Function: oFTP.SetCurrentDirectory
	; Description:
	;      Sets the current directory path on FTP server
	; Syntax: oFTP.SetCurrentDirectory(DirName)
	; Parameters:
	;      DirName - Existing directory name on FTP server
	; Remarks:
	;      None
	; Return Value:
	;      True on success
	; Related: oFTP.GetCurrentDirectory
	; Example:
	;      oFTP.SetCurrentDirectory("testing")
	;
	SetCurrentDirectory(DirName) {
		if this.Async
			this.base.AsyncRequestComplete := 0
		r := DllCall("wininet\FtpSetCurrentDirectory", "PTR", this.hInternet, "str", DirName)
		If (ErrorLevel or !(r || this.Async))
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)
		Return 1 , this.LastError := 0
	}

	;
	; Function: oFTP.CreateDirectory
	; Description:
	;      Creates a new directory on FTP server
	; Syntax: oFTP.CreateDirectory(DirName)
	; Parameters:
	;      DirName - New directory name on FTP server
	; Remarks:
	;      None
	; Return Value:
	;      True on success
	; Related: oFTP.RemoveDirectory
	; Example:
	;      oFTP.CreateDirectory("testing")
	;
	CreateDirectory(DirName) {
		if this.Async
			this.base.AsyncRequestComplete := 0
		r := DllCall("wininet\FtpCreateDirectory", "PTR", this.hInternet, "str", DirName)
		If (ErrorLevel or !(r || this.Async))
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)
		Return 1 , this.LastError := 0
	}

	;
	; Function: oFTP.RemoveDirectory
	; Description:
	;      Deletes a directory on FTP server
	; Syntax: oFTP.RemoveDirectory(DirName)
	; Parameters:
	;      DirName - Existing directory name on FTP server
	; Remarks:
	;      None
	; Return Value:
	;      True on success
	; Related: oFTP.CreateDirectory
	; Example:
	;      oFTP.RemoveDirectory("testing")
	;
	RemoveDirectory(DirName) {
		if this.Async
			this.base.AsyncRequestComplete := 0
		r := DllCall("wininet\FtpRemoveDirectory", "PTR", this.hInternet, "str", DirName)
		If (ErrorLevel or !(r || this.Async))
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)
		Return 1 , this.LastError := 0
	}


	OpenFile(FileName,Write = 0) {
		if this.Async
			this.base.AsyncRequestComplete := 0
		access := Write ? 0x40000000 : 0x80000000
		r := DllCall( "wininet\FtpOpenFile", "PTR", this.hInternet ,"str" , FileName
		 ,"UInt" , access ;dwAccess
		 ,"UInt" , 0 ;dwFlags
		 ,"UInt" , this.Async) ;dwContext
		If (ErrorLevel or !(r || this.Async))
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)
		if this.Async
		{
			while !this.base.AsynchInternet
				sleep 10
			return this.base.AsynchInternet
		}
		else
			return r , this.LastError := 0
	}

	;
	; Function: oFTP.InternetWriteFile
	; Description:
	;      Uploads a file (with progress bar)
	; Syntax: oFTP.InternetWriteFile(LocalFile, [NewRemoteFile, FnProgress])
	; Parameters:
	;      LocalFile - Path of local file to upload
	;      NewRemoteFile - (Optional) Remote file name/path (if omitted, defaults to name of Local file)
	;      FnProgress - (Optional) Name of function to handle progress (similar to registercallback). If not specified, built in function to show progress is used. (see example)
	; Return Value:
	;      True on success, false otherwise.
	; Remarks:
	;      Use .LastError property to get error data
	; Related: oFTP.InternetReadFile
	; Example:
	;      oFTP.InternetWriteFile("TestFile.zip", "RTestFile.zip", "MyProgressFunction")
	;      MyProgressFunction() {
	;        global oFTP
	;        static init                                                                                   
	;        my := oFTP.File                                                                               
	;        ntotal := my.BytesTotal                                                                       
	;        if ( my.TransferComplete )                                                                    
	;        	{                                                                                           
	;        	Progress, Off                                                                               
	;        	return 1 , init := 0                                                                        
	;        	}                                                                                           
	;        str_sub := "Time Elapsed - " . Round((my.CurrentTime - my.StartTime)/1000) . " seconds"       
	;        if !init                                                                                      
	;        	{                                                                                           
	;        	str_main := my.LocalName . A_Tab . (my.TransferDownload ? "<-":"->") . A_Tab . my.RemoteName
	;        	Progress,M R0-%ntotal% P0,%str_sub%, %str_main% ,FTP Transfer Progress                      
	;        	return 1, init :=1                                                                          
	;        	}                                                                                           
	;        Progress, % my.BytesTransfered                                                                
	;        Progress,,%str_sub%                                                                           
	;       }
	;
	InternetWriteFile(LocalFile, NewRemoteFile="", FnProgress = "") {
		if this.Async
			 return 0 ; does not yet support async mode

		my := this.File
		my.BytesTransfered := my.TransferComplete := my.TransferDownload := 0 
		SplitPath,LocalFile,tvar
		my.RemoteName := (NewRemoteFile="") ? tvar : NewRemoteFile
		my.LocalName := tvar
	 
		hFile := this.OpenFile(my.RemoteName,1) ;Write
		if !hFile
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)

		oFile := FileOpen(LocalFile,"r")
		if !oFile
			Return 0 , DllCall("wininet\InternetCloseHandle",  "PTR", hFile) , this.LastError := "File not found!"

		my.BytesTotal := oFile.Length , blocks := Floor(oFile.Length/my.BufferSize) , my.StartTime := A_TickCount
		VarSetCapacity(Buffer,my.BufferSize)
		Loop, %blocks%
		{
		oFile.RawRead(Buffer,my.BufferSize)
		if ( DllCall("wininet\InternetWriteFile", "PTR", hFile  , "PTR", &Buffer  , "UInt",  my.BufferSize , "UIntP", outSize) )
		{
			my.BytesTransfered := my.BytesTransfered + my.BufferSize , my.CurrentTime := A_TickCount
			FnProgress ? %FnProgress%() : this.ShowProgress()
		}
		else
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError) , DllCall("wininet\InternetCloseHandle",  "PTR", hFile)
		}
		if (lastBufferSize := my.BytesTotal - my.BytesTransfered)
			{
			oFile.RawRead(Buffer,lastBufferSize)
			DllCall("wininet\InternetWriteFile", "PTR", hFile  , "PTR", &Buffer  , "UInt",  lastBufferSize , "UIntP", outSize)
			}
		DllCall("wininet\InternetCloseHandle",  "PTR", hFile)
		oFile.Close()
		my.TransferComplete := 1
		FnProgress ? %FnProgress%() : this.ShowProgress()
		Return 1 , this.LastError := 0
	}

	;
	; Function: oFTP.InternetReadFile
	; Description:
	;      Downloads a file (with progress bar)
	; Syntax: oFTP.InternetReadFile(RemoteFile, [NewLocalFile, FnProgress])
	; Parameters:
	;      RemoteFile - Path of remote file to download
	;      NewLocalFile - (Optional) Local file name/path (if omitted, defaults to name of remote file, saved to script directory)
	;      FnProgress - (Optional) Name of function to handle progress data (similar to registercallback). If not specified, built in function to show progress is used. (see example)
	; Return Value:
	;      True on success, false otherwise.
	; Remarks:
	;      Use .LastError property to get error data
	; Related: oFTP.InternetWriteFile
	; Example:
	;      oFTP.InternetReadFile("RTestFile.zip", "LTestFile.zip", "MyProgressFunction")
	;      MyProgressFunction() {
	;        global oFTP
	;        static init                                                                                   
	;        my := oFTP.File                                                                               
	;        ntotal := my.BytesTotal                                                                       
	;        if ( my.TransferComplete )                                                                    
	;        	{                                                                                           
	;        	Progress, Off                                                                               
	;        	return 1 , init := 0                                                                        
	;        	}                                                                                           
	;        str_sub := "Time Elapsed - " . Round((my.CurrentTime - my.StartTime)/1000) . " seconds"       
	;        if !init                                                                                      
	;        	{                                                                                           
	;        	str_main := my.LocalName . A_Tab . (my.TransferDownload ? "<-":"->") . A_Tab . my.RemoteName
	;        	Progress,M R0-%ntotal% P0,%str_sub%, %str_main% ,FTP Transfer Progress                      
	;        	return 1, init :=1                                                                          
	;        	}                                                                                           
	;        Progress, % my.BytesTransfered                                                                
	;        Progress,,%str_sub%                                                                           
	;       }
	;
	InternetReadFile(RemoteFile, NewLocalFile = "", FnProgress = "") {
		if this.Async
			 return 0 ; does not yet support async mode

		my := this.File
		my.BytesTransfered := my.TransferComplete := 0  
		SplitPath,RemoteFile,tvar
		my.LocalName := (NewLocalFile="") ? tvar : NewLocalFile
		my.RemoteName := tvar, my.TransferDownload := 1
	 
		hFile := this.OpenFile(RemoteFile) ;Read
		if !hFile
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)

		oFile := FileOpen(NewLocalFile,"w")
		if !oFile
			Return 0 , DllCall("wininet\InternetCloseHandle",  "PTR", hFile) , this.LastError := "File could not be created!"

		my.BytesTotal := DllCall("wininet\FtpGetFileSize", "PTR", hFile, "uint", 0)
		blocks := Floor(my.BytesTotal/my.BufferSize) , my.StartTime := A_TickCount
		VarSetCapacity(Buffer,my.BufferSize)

		Loop, %blocks%
		{
		if ( DllCall("wininet\InternetReadFile", "PTR", hFile , "PTR", &Buffer , "UInt", my.BufferSize , "UIntP", outSize) )
			{
			oFile.RawWrite(Buffer,my.BufferSize)
			my.BytesTransfered := my.BytesTransfered + my.BufferSize , my.CurrentTime := A_TickCount ,
			FnProgress ? %FnProgress%() : this.ShowProgress()
			}
		else
			Return 0 , DllCall("wininet\InternetCloseHandle",  "PTR", hFile) , this.LastError := this.GetModuleErrorText(A_LastError)
		}
		if (lastBufferSize := my.BytesTotal - my.BytesTransfered)
			{
			DllCall("wininet\InternetReadFile", "PTR", hFile , "PTR", &Buffer , "UInt",  lastBufferSize , "UIntP", outSize)
			; VarSetCapacity(Buffer,-1)
			oFile.RawWrite(Buffer,lastBufferSize)
			}
		DllCall("wininet\InternetCloseHandle",  "PTR", hFile)
		oFile.Close()
		my.TransferComplete := 1
		FnProgress ? %FnProgress%() : this.ShowProgress()
		Return 1 , this.LastError := 0
	}


	ShowProgress() {
		static init
		my := this.File
		ntotal := my.BytesTotal
		if ( my.TransferComplete )
			{
			Progress, Off
			return 1 , init := 0
			}
		str_sub := "Time Elapsed - " . Round((my.CurrentTime - my.StartTime)/1000) . " seconds"
		if !init
			{
			str_main := my.LocalName . A_Tab . (my.TransferDownload ? "<-":"->") . A_Tab . my.RemoteName
			Progress,M R0-%ntotal% P0,%str_sub%, %str_main% ,FTP Transfer Progress
			return 1, init :=1
			}
		Progress, % my.BytesTransfered
		Progress,,%str_sub%
	}

	;
	; Function: oFTP.PutFile
	; Description:
	;      Puts a file to FTP location
	; Syntax: oFTP.PutFile(LocalFile, [NewRemoteFile, Flags])
	; Parameters:
	;      LocalFile - Existing file name
	;      NewRemoteFile - Remote path to the file to be created (fully qualified path or relative path to current dir)
	;      Flags - See remarks
	; Remarks:
	;      Flags:
	;      FTP_TRANSFER_TYPE_UNKNOWN = 0 (Defaults to FTP_TRANSFER_TYPE_BINARY)
	;      FTP_TRANSFER_TYPE_ASCII = 1
	;      FTP_TRANSFER_TYPE_BINARY = 2
	; Return Value:
	;      True on success
	; Related: oFTP.GetFile
	; Example:
	;      oFTP.PutFile("LocalFile.ahk", "MyTestScript.ahk", 0)
	;
	PutFile(LocalFile, NewRemoteFile="", Flags=0) {
		If NewRemoteFile=
			SplitPath,LocalFile,NewRemoteFile
		
		if this.Async
		{
			FileGetSize, nFilesize, % LocalFile
			my := this.File, this.base.AsyncRequestComplete := 0
			my.BytesTransfered := 0, my.TransferComplete := 0, my.BytesTotal := nFilesize, my.TransferDownload := 0
			SplitPath,LocalFile,LocalName
			my.LocalName := LocalName, my.RemoteName := NewRemoteFile
		}

		r := DllCall("wininet\FtpPutFile" , "PTR", this.hInternet , "str", LocalFile , "str", NewRemoteFile , "uint", Flags 
					, "PTR", this.Async) ;dwContext

		If (ErrorLevel or !(r || this.Async))
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)
		Return 1 , this.LastError := 0
	}

	;
	; Function: oFTP.GetFile
	; Description:
	;      Retrieves a file
	; Syntax: oFTP.GetFile(RemoteFile, [NewFile, Flags])
	; Parameters:
	;      RemoteFile - Existing file name (fully qualified path or relative path to current dir)
	;      NewFile - Local path to the file to be created
	;      Flags - See remarks
	; Remarks:
	;      Flags:
	;      FTP_TRANSFER_TYPE_UNKNOWN = 0 (Defaults to FTP_TRANSFER_TYPE_BINARY)
	;      FTP_TRANSFER_TYPE_ASCII = 1
	;      FTP_TRANSFER_TYPE_BINARY = 2
	; Return Value:
	;      True on success
	; Related: oFTP.PutFile
	; Example:
	;      oFTP.GetFile("MyTestScript.ahk", "LocalFile.ahk", 0)
	;
	GetFile(RemoteFile, NewFile="", Flags=0) {
		If NewFile=
			NewFile := RemoteFile
		
		if this.Async
			{
			my := this.File, this.base.AsyncRequestComplete := 0
			my.BytesTransfered := 0, my.TransferComplete := 0, my.TransferDownload := 1
			SplitPath,NewFile,LocalName
			my.LocalName := LocalName, my.RemoteName := RemoteFile
			}

		r := DllCall("wininet\FtpGetFile" , "PTR", this.hInternet , "str", RemoteFile , "str", NewFile
		, "int", 1 ;do not overwrite existing files
		, "uint", 0 ;dwFlagsAndAttributes
		, "uint", Flags
		, "PTR", this.Async) ;dwContext
		If (ErrorLevel or !(r || this.Async))
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)
		Return 1 , this.LastError := 0
	}

	;
	; Function: oFTP.GetFileSize
	; Description:
	;      Renames a file
	; Syntax: oFTP.GetFileSize(FileName [, Flags])
	; Parameters:
	;      FileName - Existing file name (fully qualified path or relative path to current dir)
	;      Flags - See remarks
	; Remarks:
	;      Flags:
	;      FTP_TRANSFER_TYPE_UNKNOWN = 0 (Defaults to FTP_TRANSFER_TYPE_BINARY)
	;      FTP_TRANSFER_TYPE_ASCII = 1
	;      FTP_TRANSFER_TYPE_BINARY = 2
	; Return Value:
	;      Size of file in bytes (-1 on error)
	; Related: oFTP.FindFirstFile , oFTP.FindNextFile
	; Example:
	;      oFTP.GetFileSize("MyTestScript.ahk", 0)
	;
	GetFileSize(FileName, Flags=0) {
		if this.Async
			this.base.AsyncRequestComplete := 0

		r := DllCall("wininet\FtpOpenFile", "PTR", this.hInternet, "str", FileName
		, "uint", 0x80000000 ;dwAccess: GENERIC_READ
		, "uint", Flags
		, "PTR", this.Async) ;dwContext
		If (ErrorLevel or !(r || this.Async))
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)
		if this.Async
		{
			while !this.base.AsyncRequestComplete
				sleep 10
			if this.base.AsyncRequestComplete = -1
				return 0
			FileSize := DllCall("wininet\FtpGetFileSize", "PTR", this.hInternet, "PTR", 0)
		}
		else
			FileSize := DllCall("wininet\FtpGetFileSize", "PTR", r, "PTR", 0)
		DllCall("wininet\InternetCloseHandle",  "PTR", r)
		if this.Async
			{
			while !this.base.AsyncRequestComplete
				sleep 10
			}
		Return FileSize , this.LastError := 0
	}

	;
	; Function: oFTP.DeleteFile
	; Description:
	;      Deletes a remote file
	; Syntax: oFTP.Deletefile(FileName)
	; Parameters:
	;      FileName - Existing file name (fully qualified path or relative path to current dir)
	; Remarks:
	;      none
	; Return Value:
	;      True on success, false otherwise
	; Related: oFTP.RenameFile
	; Example:
	;      oFTP.DeleteFile("MyTestScript.ahk")
	;
	DeleteFile(FileName) {
		if this.Async
			this.base.AsyncRequestComplete := 0
		r :=  DllCall("wininet\FtpDeleteFile", "PTR", this.hInternet, "str", FileName)
		If (ErrorLevel or !(r || this.Async))
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)
		Return 1 , this.LastError := 0
	}

	;
	; Function: oFTP.RenameFile
	; Description:
	;      Renames a file
	; Syntax: oFTP.RenameFile(Existing, New)
	; Parameters:
	;      Existing - Existing file name, fully qualified path or relative path to current dir
	;      New - New file name
	; Return Value:
	;      True on success, false otherwise
	; Remarks:
	;      none
	; Related: oFTP.DeleteFile
	; Example:
	;      oFTP.RenameFile("MyScript.ahk", "MyTestScript.ahk")
	;
	RenameFile(Existing, New) {
		if this.Async
			this.base.AsyncRequestComplete := 0
		r := DllCall("wininet\FtpRenameFile", "PTR", this.hInternet, "str", Existing, "str", New)
		If (ErrorLevel or !(r || this.Async))
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)
		Return 1 , this.LastError := 0
	}

	;
	; Function: oFTP.CloseHandle
	; Description:
	;      Closes session created by oFTP.Open
	; Syntax: oFTP.CloseHandle()
	; Return Value:
	;      True on success, false otherwise
	; Remarks:
	;      The wininet module and wininet Internet open handles are not released.
	; Related: oFTP.Open
	; Example:
	;      oFTP.CloseHandle() ;you can now create a new session with oFTP.Open
	;
	CloseHandle() {
		if this.Async
			this.base.AsyncRequestComplete := 0
		DllCall("wininet\InternetCloseHandle",  "PTR", this.hInternet)
		If (ErrorLevel or !(r || this.Async))
			Return 0 , this.LastError := this.GetModuleErrorText(A_LastError)
		Return 1 , this.LastError := 0, this.hInternet := 0
	}

	__Delete() {
		DllCall("wininet\InternetCloseHandle",  "PTR", this.hInternet)
		DllCall("wininet\InternetCloseHandle",  "PTR", this.hInternetOpen)
		DllCall("FreeLibrary", "PTR", this.hModule)
	}

	;
	; Function: oFTP.FindFirstFile
	; Description:
	;      Get first file
	; Syntax: oFTP.FindFirstFile(SearchFile)
	; Parameters:
	;      SearchFile - file(mask) to search for
	; Return Value:
	;      Returns an object (oFile) with file details (properties described below)
	;      oFile.Name - Name of File
	;      oFile.CreationTime - Creation Time (0 if absent)
	;      oFile.LastAccessTime - Last Access Time (0 if absent)
	;      oFile.LastWriteTime - Last Write Time (0 if absent)
	;      oFile.Size - File Size in bytes
	;      oFile.Attribs - String of file attributes
	; Related: oFTP.GetFileInfo, oFTP.FindNextFile
	;
	FindFirstFile(SearchFile) {
		 ; WIN32_FIND_DATA structure size is 4 + 3*8 + 4*4 + 260*4 + 14*4 = 1140
		this.LastError := 0

		VarSetCapacity(@FindData, 1140, 0)
		r := DllCall("wininet\FtpFindFirstFile"
			, "PTR", this.hInternet
			, "str", SearchFile
			, "PTR", &@FindData
			, "uint", 0
			, "PTR", 0, "PTR") ;dwContext - see notes on asynchronous mode
		If (ErrorLevel or !(r || this.Async))
			Return 0 , VarSetCapacity(@FindData, 0) , this.LastError := this.GetModuleErrorText(A_LastError)
		this.hEnum := r
		Return this.GetFileInfo(@FindData)
	}

	;
	; Function: oFTP.FindNextFile
	; Description:
	;      Get next file
	; Syntax: oFTP.FindNextFile()
	; Return Value:
	;      Returns an object (oFile) with file details (properties described below)
	;      oFile.Name - Name of File
	;      oFile.CreationTime - Creation Time (0 if absent)
	;      oFile.LastAccessTime - Last Access Time (0 if absent)
	;      oFile.LastWriteTime - Last Write Time (0 if absent)
	;      oFile.Size - File Size in bytes
	;      oFile.Attribs - String of file attributes
	; Related: oFTP.GetFileInfo, oFTP.FindFirstFile
	;
	FindNextFile() {
		this.LastError := 0 , A_LastError := 0

		VarSetCapacity(@FindData, 1140, 0)
		r := DllCall("wininet\InternetFindNextFile" , "PTR", this.hEnum , "PTR", &@FindData)
	;  if (A_LastError = 18) ;ERROR_NO_MORE_FILES
	;    return 0
		If (ErrorLevel or !r)
			Return 0 , VarSetCapacity(@FindData, 0) , this.LastError := this.GetModuleErrorText(A_LastError)
		Return this.GetFileInfo(@FindData)
	}
	
	;
	; Function: oFTP.GetFileInfo
	; Description:
	;      Get File info from WIN32_FIND_DATA structure
	; Syntax: oFTP.GetFileInfo(DataStruct)
	; Parameters:
	;      DataStruct - Data structure retrieved by .FindFirstFile() / .FindNextFile() functions
	; Return Value:
	;      Returns an object with file details (properties described below)
	;      oFile.Name - Name of File
	;      oFile.CreationTime - Creation Time (0 if absent)
	;      oFile.LastAccessTime - Last Access Time (0 if absent)
	;      oFile.LastWriteTime - Last Write Time (0 if absent)
	;      oFile.Size - File Size in bytes
	;      oFile.Attribs - String of file attributes
	; Related: oFTP.FindFirstFile , oFTP.FindNextFile
	;
	GetFileInfo(ByRef @FindData) { ;http://www.autohotkey.com/forum/viewtopic.php?p=408830#408830
	static fiObj
	if !IsObject(fiObj)
	   fiObj := Object()

	VarSetCapacity(value, 1040, 0)
	DllCall("RtlMoveMemory", "str", value, "uint", &@FindData + 44, "uint", 1040)
	VarSetCapacity(value, -1)
	fiObj.Name := value

	VarSetCapacity(ftstr, 8)
	DllCall("RtlMoveMemory", "str", ftstr, "uint", &@FindData + 4, "uint", 8)
	fiObj.CreationTime := this.FileTimeToStr(ftstr)
	DllCall("RtlMoveMemory", "str", ftstr, "uint", &@FindData + 12, "uint", 8)
	fiObj.LastAccessTime := this.FileTimeToStr(ftstr)
	DllCall("RtlMoveMemory", "str", ftstr, "uint", &@FindData + 20, "uint", 8)
	fiObj.LastWriteTime := this.FileTimeToStr(ftstr)
	fiObj.Size := NumGet(@FindData, 28, "UInt") << 32 | NumGet(@FindData, 32, "UInt")

	value := ""
	value .= (NumGet(@FindData, 0, "UInt") & 1) != 0 ? "R" : ""
	value .= (NumGet(@FindData, 0, "UInt") & 2) != 0 ? "H" : ""
	value .= (NumGet(@FindData, 0, "UInt") & 4) != 0 ? "S" : ""
	value .= (NumGet(@FindData, 0, "UInt") & 16) != 0 ? "D" : ""
	value .= (NumGet(@FindData, 0, "UInt") & 32) != 0 ? "A" : ""
	value .= (NumGet(@FindData, 0, "UInt") & 128) != 0 ? "N" : ""
	value .= (NumGet(@FindData, 0, "UInt") & 256) != 0 ? "T" : ""
	value .= (NumGet(@FindData, 0, "UInt") & 2048) != 0 ? "O" : ""
	value .= (NumGet(@FindData, 0, "UInt") & 4096) != 0 ? "E" : ""
	value .= (NumGet(@FindData, 0, "UInt") & 16384) != 0 ? "C" : ""
	value .= (NumGet(@FindData, 0, "UInt") & 65536) != 0 ? "V" : ""
	fiObj.Attribs := value

	Return fiObj
	}
	
	FileTimeToStr(FileTime) {
	   VarSetCapacity(SystemTime, 16, 0)
	   If (!NumGet(FileTime,"UInt") && !NumGet(FileTime,4,"UInt"))
		 Return 0
	   DllCall("FileTimeToSystemTime", "PTR", &FileTime, "PTR", &SystemTime)
	   Return NumGet(SystemTime,6,"short") ;date
		  . "/" . NumGet(SystemTime,2,"short") ;month
		  . "/" . NumGet(SystemTime,0,"short") ;year
		  . " " . NumGet(SystemTime,8,"short") ;hours
		  . ":" . ((StrLen(tvar := NumGet(SystemTime,10,"short")) = 1) ? "0" . tvar : tvar) ;minutes
		  . ":" . ((StrLen(tvar := NumGet(SystemTime,12,"short")) = 1) ? "0" . tvar : tvar) ;seconds
	;      . "." . NumGet(SystemTime,14,"short") ;milliseconds
	}
	
	GetModuleErrorText(errNr) ;http://msdn.microsoft.com/en-us/library/ms679351
	{
	   bufferSize = 1024 ; Arbitrary, should be large enough for most uses
	   VarSetCapacity(buffer, bufferSize)
		if (errNr = 12003)  ;ERROR_INTERNET_EXTENDED_ERROR
	   {
		  VarSetCapacity(ErrorMsg,4)
		  DllCall("wininet\InternetGetLastResponseInfo", "UIntP", &ErrorMsg, "PTR", &buffer, "UIntP", &bufferSize)
		  Msg := StrGet(&buffer,bufferSize)
		  Return "Error : " errNr . "`n" . Msg
	   }
	   DllCall("FormatMessage"
		, "UInt", FORMAT_MESSAGE_FROM_HMODULE := 0x00000800
		, "PTR", this.hModule , "UInt", errNr
		, "UInt", 0 ;0 - looks in following order -> langNuetral->thread->user->system->USEnglish
		, "Str", buffer , "UInt", bufferSize
		, "PTR", 0)
	   Return "Error : " . errNr . " - " . buffer
	}
}



FTP_Status(wParam,lParam) {
	global FTP
	if (wParam=1)
		FTP.AsyncRequestComplete := lParam
	else if (wParam=2)
		FTP.AsynchInternet := lParam
}


;This function by default logs to console.
;This function is for demo only. You can specify the callback function as the first parameter
;  when creating a new FTP object.
FTP_Callback(hInternet, dwContext, dwInternetStatus, lpvStatusInformation, dwStatusInformationLength) {
	static nMsg := DllCall("RegisterWindowMessage","Str","AHK FTP Library Async Message")
	static status := { 10 : "INTERNET_STATUS_RESOLVING_NAME"
									, 11  : "INTERNET_STATUS_NAME_RESOLVED"
									, 20  : "INTERNET_STATUS_CONNECTING_TO_SERVER"
									, 21  : "INTERNET_STATUS_CONNECTED_TO_SERVER"
									, 30  : "INTERNET_STATUS_SENDING_REQUEST"
									, 31  : "INTERNET_STATUS_REQUEST_SENT"
									, 40  : "INTERNET_STATUS_RECEIVING_RESPONSE"
									, 41  : "INTERNET_STATUS_RESPONSE_RECEIVED"
									, 42  : "INTERNET_STATUS_CTL_RESPONSE_RECEIVED"
									, 43  : "INTERNET_STATUS_PREFETCH"
									, 50  : "INTERNET_STATUS_CLOSING_CONNECTION"
									, 51  : "INTERNET_STATUS_CONNECTION_CLOSED"
									, 60  : "INTERNET_STATUS_HANDLE_CREATED"
									, 70  : "INTERNET_STATUS_HANDLE_CLOSING"
									, 100 : "INTERNET_STATUS_REQUEST_COMPLETE"
									, 120 : "INTERNET_STATUS_INTERMEDIATE_RESPONSE"
									, 110 : "INTERNET_STATUS_REDIRECT"
									, 200 : "INTERNET_STATUS_STATE_CHANGE"}
	static state := { 1   : "INTERNET_STATE_CONNECTED"           
									, 2   : "INTERNET_STATE_DISCONNECTED"        
									, 16  : "INTERNET_STATE_DISCONNECTED_BY_USER"
									, 256 : "INTERNET_STATE_IDLE"                
									, 512 : "INTERNET_STATE_BUSY"}
	static BytesTransfered := 0
	iCritical := A_IsCritical
	Critical

	FileAppend , % "`n" . A_TickCount . ": " . dwInternetStatus . " = " . status[dwInternetStatus], *

	if (dwInternetStatus = 60)
	{
		FileAppend, % ": handle is " (hInternet := Numget(lpvStatusInformation+0,"Ptr")), *
		PostMessage, nMsg, 2, hInternet,,ahk_id 0xFFFF  ;HWND_BROADCAST
	}
	else if (dwInternetStatus = 100)
	{
		BytesTransfered := 0
		FileAppend, % ": result is " (AsyncRequestComplete := Numget(lpvStatusInformation+0,"UInt") ? 1 : -1), * ; -1 is request complete but failed
		PostMessage, nMsg, 1, 1,,ahk_id 0xFFFF  ;HWND_BROADCAST
	}
	else if (dwInternetStatus = 200)
		FileAppend, % " : state = " . state[Numget(lpvStatusInformation+0,"UInt")], *
	else if (dwInternetStatus = 31)
		FileAppend, % " : bytes sent is " . (BytesTransfered += Numget(lpvStatusInformation+0,"UInt")), *
	else if (dwInternetStatus = 41)
		FileAppend, % " : bytes recieved is " . (BytesTransfered += Numget(lpvStatusInformation+0,"UInt")), *

	Critical, %iCritical%
}



;
; Property: oFTP
; Description:
;      Properties of object (oFTP) returned by FTP Class
; Parameters:
;      .Port - Port 21 by default                                                            
;      .hModule - Handle of Wininet module                                                   
;      .hInternetOpen - Handle of Internet open                                              
;      .hInternet - Handle of Internet connection (FTP connection)                           
;      .LastError - Error message + Extended error message (if any) in human readable format.
;      .InternetConnectFlags - 0 by default, 0x08000000 for INTERNET_FLAG_PASSIVE
;      

;
; Property: oFile
; Description:
;      Properties of object (oFile) returned by .FindFirstFile()/.FindNextFile()
; Parameters:
;      oFile.Name - Name of File
;      oFile.CreationTime - Creation Time (0 if absent)
;      oFile.LastAccessTime - Last Access Time (0 if absent)
;      oFile.LastWriteTime - Last Write Time (0 if absent)
;      oFile.Size - File Size in bytes
;      oFile.Attribs - String of file attributes
;

FTP_TestFunction() {
	MsgBox Test
}