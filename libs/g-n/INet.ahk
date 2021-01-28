;Inet.ahk 유니코드 L버전에서 작동하는 스크립트입니다.

; script Title:
;    INet.ahk
;    Requires AutoHotkey 1.0.47+
;
; script Function:
;   Wraps usage of WinINet.dll functions.
;   For now, mostly only FTP functions are available.
;
; Sources:
;    WinINet Functions: http://msdn2.microsoft.com/en-us/library/aa385473.aspx
;    FTP Sessions: http://msdn2.microsoft.com/en-us/library/aa384180.aspx
;
; Example:
;   ; init internet resources
;   INetOpen()
;   ; connection to the FTP server
;   hFTP = INetConnect(Server, Port, User, Pwd, "ftp")
;   if(hFTP)
;   {
;      if(FtpPutFile(hFTP, "somefile.txt"))
;         Msgbox File uploaded successfuly
;      else
;         Msgbox "Upload failed: " %A_LastError%
;      ; close the FTP connection
;      INetCloseHandle(hFTP)
;   }
;   ; release internet resources
;   INetClose()
;
; ******************************************************************************
; ------------------------------------------------------------------------------
; This function loads and tells the Internet DLL to initialize internal data structures
; and prepare for future calls from the application.
;
; Internet functions are not available before this function is called.
;
; param Proxy [in]
;   Specifies an optional name of a proxy server.
; param ProxyBypass [in]
;   Specifies an optional list of host names or IP addresses, or both, that should not be routed
;   through the proxy when a proxy is used.
; param Agent [in]
;    Specifies the name of the application or entity calling the WinINet functions.
;    This name is used as the user agent in the HTTP protocol.
;    When empty, the name of the script is used
; return
;   [bool] true if the function succeeds, otherwise false
;
INetOpen(Proxy="", ProxyBypass="", Agent="")
{
   global
   ; get a handle to the WinINet library
   inet_hModule := DllCall("LoadLibrary", "str", "wininet.dll")
   if(!inet_hModule) {
      inet_hModule = 0
      return false
   }
;   INTERNET_OPEN_TYPE_PRECONFIG                    0   // use registry configuration
;   INTERNET_OPEN_TYPE_DIRECT                       1   // direct to net
;   INTERNET_OPEN_TYPE_PROXY                        3   // via named proxy
;   INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY  4   // prevent using java/script/INS
   inet_hInternet := DllCall("wininet\InternetOpen"
      , "str", (Agent != "" ? Agent : A_scriptName)
      , "UInt", (Proxy != "" ? 3 : 1)
      , "str", Proxy
      , "str", ProxyBypass
      , "Ptr", 0)
   If(!inet_hInternet) {
      INetCloseHandle(inet_hModule)
      return false
   }
   return true
}
; ------------------------------------------------------------------------------
; Terminates the application's use of WinINet functions and unloads the Internet DLL.
;
; Internet functions are not available after this function call is called.
;
INetClose()
{
   global
   INetCloseHandle(inet_hInternet)
   DllCall("FreeLibrary", "Ptr", inet_hModule)
   inet_hModule = inet_hInternet = 0
}
; ------------------------------------------------------------------------------
; Closes a single Internet handle, previously opened by INetConnect, FtpOpenFile, ...
;
; param hConnection [in]
;   The connection handle to be closed.
; return
;   [bool] true if the function succeeds, otherwise false
;
INetCloseHandle(hInternet)
{
   return DllCall("wininet\InternetCloseHandle", "Ptr", hInternet)
}
; ------------------------------------------------------------------------------
; Opens an File Transfer Protocol (FTP), Gopher, or HTTP session for a given site.
;
; FtpPassive [in]
;   The value 1 causes the application to use passive FTP semantics
;
; param Server [in]
;   The host name or IP number of a server.
; param Server [in]
;   The TCP/IP port to connect to.
; param Username [in]
;   The name of the user to log on (default is anonymous)
; param Password [in]
;   The password to use to log on (default is anonymous)
; param Service [in]
;   Type of service to access. Must be of the following value: http (default), ftp, url or gopher
; param FtpPassive [in]
;   Option specific to ftp service. Setting 1 causes the application to use passive FTP semantics.
; return
;   the handle of the opened connection
;
INetConnect(Server, Port, Username="anonymous", Password="anonymous", Service="http", FtpPassive=0)
{
   global inet_hInternet
   hConnection := DllCall("wininet\InternetConnect"
      , "Ptr", inet_hInternet
      , "str", Server
      , "uint", Port
      , "str", Username
      , "str", Password
      , "uint", (Service = "ftp" ? 1 : (Service = "gopher" ? 2 : 3)) ; INTERNET_SERVICE_xxx
      , "uint", (FtpPassive != 0 ? 0x08000000 : 0) ; INTERNET_FLAG_PASSIVE
      , "Ptr", 0)
   return hConnection
}
; ------------------------------------------------------------------------------
; Creates a directory on a FTP server.
;
; param hConnection [in]
;   A valid connection handle returned by an INetConnect call (using Type="ftp").
; param Directory [in]
;   The name of the directory to be created. This can be a fully qualified path
;   or a name relative to the current directory.
; return
;   [bool] true if the function succeeds, otherwise false
;
FtpCreateDirectory(hConnection, Directory)
{
   return DllCall("wininet\FtpCreateDirectory", "Ptr", hConnection, "str", Directory)
}
; ------------------------------------------------------------------------------
; Removes a directory on a FTP server.
;
; param hConnection [in]
;   A valid connection handle returned by an INetConnect call (using Type="ftp").
; param Directory [in]
;   The name of the directory to be deleted. This can be a fully qualified path
;   or a name relative to the current directory.
; return
;   [bool] true if the function succeeds, otherwise false
;
FtpRemoveDirectory(hConnection, Directory)
{
   return DllCall("wininet\FtpRemoveDirectory", "Ptr", hConnection, "str", Directory)
}
; ------------------------------------------------------------------------------
; Sets the current working directory for a specified FTP session.
;
; param hConnection [in]
;   A valid connection handle returned by an INetConnect call (using Type="ftp").
; param Directory [in]
;   The name of the directory to become the current working directory. This can be a fully qualified path
;   or a name relative to the current directory.
; return
;   [bool] true if the function succeeds, otherwise false
;
FtpSetCurrentDirectory(hConnection, Directory)
{
   return DllCall("wininet\FtpSetCurrentDirectory", "Ptr", hConnection, "str", Directory)
}
; ------------------------------------------------------------------------------
; Gets the current working directory of a specified FTP session.
;
; param hConnection [in]
;   a valid connection handle returned by an INetConnect call (using Type="ftp")
; param Directory [in]
;   a variable that receives the absolute path of the current directory
; return
;   [bool] true if the function succeeds, otherwise false
;
FtpGetCurrentDirectory(hConnection, ByRef Directory)
{
   len := 2*261   ; MAX_PATH 260
   VarSetCapacity(Directory, len)
   result := DllCall("wininet\FtpGetCurrentDirectory", "Ptr", hConnection, "Ptr", Directory, "uint*", len)
   VarSetCapacity(Directory, -1)
   return result
}
; ------------------------------------------------------------------------------
; Uploads a file to a FTP server (the remote file is overwritten if it already exists).
;
; param hConnection [in]
;   a valid connection handle returned by an INetConnect call (using Type="ftp")
; param LocalFile [in]
;   name of the local file to upload
; param RemoteFile [in]
;   name of the remote file to create (when empty, the remote file created will have the same name than the local one)
; param TransferType [in]
;   "A" for ascii transfert or "B" (default) for binary mode
; return
;   [bool] true if the function succeeds, otherwise false
;
FtpPutFile(hConnection, LocalFile, RemoteFile="", TransferType="B")
{
   return DllCall("wininet\FtpPutFile"
      , "Ptr", hConnection
      , "str", LocalFile
      , "str", (RemoteFile != "" ? RemoteFile : LocalFile)
      , "uint", (TransferType == "A" ? 1 : 2)   ; FTP_TRANSFER_TYPE_ASCII or FTP_TRANSFER_TYPE_BINARY
      , "Ptr", 0)
}
; ------------------------------------------------------------------------------
; Downloads a file from a FTP server and stores it localy.
; No caching options for now.
;
; param hConnection [in]
;   a valid connection handle returned by an INetConnect call (using Type="ftp")
; param RemoteFile [in]
;   name of the remote file to download
; param LocalFile [in]
;   name of the local file to create (when empty, the local file created will have the same name than the remote one)
; param TransferType [in]
;   "A" for ascii transfert or "B" (default) for binary mode
; param OverWrite [in]
;   0 (default) or 1 to allow the function to proceed if a local file with the specified name already exist
; param LocalAttrib [in]
;   File attributes for the new file. This parameter can be any combination of the FILE_ATTRIBUTE_* below.
;   FILE_ATTRIBUTE_READONLY         1      0x0001
;   FILE_ATTRIBUTE_HIDDEN           2      0x0002
;   FILE_ATTRIBUTE_SYSTEM           4      0x0004
;   FILE_ATTRIBUTE_NORMAL         128      0x0080
;   FILE_ATTRIBUTE_TEMPORARY      256      0x0100
;   FILE_ATTRIBUTE_ENCRYPTED      16384   0x4000
; return
;   [bool] true if the function succeeds, otherwise false
;
; Caching option:
;    INTERNET_FLAG_HYPERLINK         0x00000400  // asking wininet to do hyperlinking semantic which works right for scripts
;    INTERNET_FLAG_NEED_FILE         0x00000010  // need a file for this request
;    INTERNET_FLAG_RELOAD            0x80000000  // retrieve the original item
;    INTERNET_FLAG_RESYNCHRONIZE     0x00000800  // asking wininet to update an item if it is newer
FtpGetFile(hConnection, RemoteFile, LocalFile="", TransferType="B", OverWrite=0, LocalAttrib=0)
{
   return DllCall("wininet\FtpGetFile"
      , "Ptr", hConnection
      , "str", RemoteFile
      , "str", (LocalFile != "" ? LocalFile : RemoteFile)
      , "int", !OverWrite
      , "uint", LocalAttrib
      , "uint", (TransferType == "A" ? 1 : 2)   ; FTP_TRANSFER_TYPE_ASCII or FTP_TRANSFER_TYPE_BINARY
      , "Ptr", 0)
}
; ------------------------------------------------------------------------------
; Gets the size in bytes of a file stored on a FTP server
;
; param hConnection [in]
;   a valid connection handle returned by an INetConnect call (using Type="ftp")
; param File [in]
;   name of the remote file
; param TransferType [in]
;   "A" for ascii transfert or "B" (default) for binary mode
; return
;   [uint] the size in bytes of the remote file
;
FtpGetFileSize(hConnection, File, TransferType="B")
{
   hFile := DllCall("wininet\FtpOpenFile"
      , "Ptr", hConnection
      , "str", File
      , "uint", 0x80000000 ; GENERIC_READ
      , "uint", (TransferType = "A" ? 1 : 2)   ; FTP_TRANSFER_TYPE_ASCII or FTP_TRANSFER_TYPE_BINARY
      , "uint", 0)
   if(!hFile)
      return -1
   size := DllCall("wininet\FtpGetFileSize", "uint", hFile, "uint*", size)
   INetCloseHandle(hFile)
   return size
}
; ------------------------------------------------------------------------------
; Renames (or moves) a file stored on a FTP server
;
; param hConnection [in]
;   a valid connection handle returned by an INetConnect call (using Type="ftp")
; param ExistingName [in]
;   name of the remote file to be renamed (can be a relative path from the current working directory)
; param NewName [in]
;   new name of the remote file (can be a relative path from the current working directory)
; return
;   [bool] true if the function succeeds, otherwise false
;
FtpRenameFile(hConnection, ExistingName, NewName)
{
   return DllCall("wininet\FtpRenameFile", "Ptr", hConnection, "str", ExistingName, "str", NewName)
}
; ------------------------------------------------------------------------------
; Deletes a file stored on a FTP server
;
; param hConnection [in]
;   a valid connection handle returned by an INetConnect call (using Type="ftp")
; param File [in]
;   the name of the file to be deleted
; return
;   [bool] true if the function succeeds, otherwise false
;
FtpDeleteFile(hConnection, File)
{
   return DllCall("wininet\FtpDeleteFile", "Ptr", hConnection, "str", File)
}