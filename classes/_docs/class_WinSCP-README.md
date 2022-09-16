# [WinSCP.ahk](http://lipkau.github.io/WinSCP.ahk/)  
## Description
This Lib allows the use of [WinSCP](http://winscp.net/) in AHK by creating a wrapper class for WinSCPnet.dll (can be donwloaded [here](http://winscp.net/eng/download.php)).  
> [WinSCP .NET & COM Library Documentation](http://winscp.net/eng/docs/library)  

## Table of Contents  
* [Description](#description)
* [Example](#example)
* [Authors/Contributors](#authorscontributors)
* [Documentation](#documentation)

## Example  
### Loading WinSCP.ahk
1. **The DLL file has to be registered**. This is done with  

      %WINDIR%\Microsoft.NET\Framework\v4.0.30319\RegAsm.exe WinSCPnet.dll /codebase <path_to>WinSCPnet.dll
      %WINDIR%\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe WinSCPnet.dll /codebase <path_to>WinSCPnet.dll  
	  
or by running the included `WinSCP_regDLL.cmd` file  
_The commands must be run with Admin permissions (elevated)_  
2. The library can be included using [#Inclulde](http://ahkscript.org/docs/commands/_Include.htm) or by placing the file inside [Library Folders](http://ahkscript.org/docs/Functions.htm#lib).  

### Connecting to Server  
#### Using normal FTP  

      FTPSession := new WinSCP
	  try
	    FTPSession.OpenConnection("ftp://myserver.com","username","password")
	  catch e
	    msgbox % "Oops. . . Something went wrong``n" e.Message

#### Using FTP with SSL  

      FTPSession := new WinSCP
	  try
	  {
        FTPSession.Hostname		:= "ftp://myserver.com"
        FTPSession.Protocol 		:= WinSCPEnum.FtpProtocol.Ftp
        FTPSession.Secure 		:= WinSCPEnum.FtpSecure.ExplicitSsl
        FTPSession.User			:= "MyUserName"
        FTPSession.Password		:= "P@ssw0rd"
        FTPSession.Fingerprint    := "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx" ;set to false to ignore server certificate
		FTPSession.OpenConnection()
      } catch e
	    msgbox % "Oops. . . Something went wrong``n" e.Message

### Handling files  
#### Upload a single file  

      FTPSession := new WinSCP
	  try
	  {
        FTPSession.OpenConnection("ftp://myserver.com","username","password")
	    
	    fName := "Windows10_InsiderPreview_x64_EN-US_10074.iso"
	    fPath := "C:\temp"
		tPath := "/Win10beta/"
		if (!FTPSession.FileExists(tPath))
		  FTPSession.CreateDirectory(tPath)
	    FTPSession.PutFiles(fPath "\" fName, tPath)
	  } catch e
	    msgbox % "Oops. . . Something went wrong``n" e.Message  

#### Download file  

      FTPSession := new WinSCP
	  try
	  {
        FTPSession.OpenConnection("ftp://myserver.com","username","password")
	    
	    fName := "Windows10_InsiderPreview_x64_EN-US_10074.iso"
	    lPath := "C:\temp"
		rPath := "/Win10beta/"
		if (FTPSession.FileExists(rPath "/" fName))
	      FTPSession.GetFiles(rPath "/" fName, lPath)
	  } catch e
	    msgbox % "Oops. . . Something went wrong``n" e.Message  
		
#### Get File Information  

      FTPSession := new WinSCP
	  try
	  {
        FTPSession.OpenConnection("ftp://myserver.com","username","password")
	    
	    FileCollection := t.ListDirectory("/")
	    for file in FileCollection.Files {
		  if (file.Name != "." && file.Name != "..")
            msgbox % "Name: " file.Name "``nPermission: " file.FilePermissions.Octal "``nIsDir: " file.IsDirectory "``nFileType: " file.FileType "``nGroup: " file.Group "``nLastWriteTime: " file.LastWriteTime "``nLength: " file.Length "``nLength32: " file.Length32 "``nOwner: " file.Owner
	  } catch e
	    msgbox % "Oops. . . Something went wrong``n" e.Message 

### More  
More example will be available in the [wiki](wiki) once it's set up

## Authors/Contributors  
* "Oliver Lipkau" @ [oliver.lipkau.net](http://oliver.lipkau.net)

## Documentation  
_Git Repo Wiki yet to be written_