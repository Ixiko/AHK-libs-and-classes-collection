; ===============================================================================================================================
; Upload to & download from FTP-Server
; ===============================================================================================================================

Class FTP
{
    static hWININET := DllCall("LoadLibrary", "str", "wininet.dll", "ptr")

    ; ===========================================================================================================================
    ; InternetOpen                                                https://msdn.microsoft.com/en-us/library/aa385096(v=vs.85).aspx
    ; ===========================================================================================================================
    InternetOpen(Agent)
    {
        static INTERNET_OPEN_TYPE_DIRECT := 1
        if !(HINTERNET := DllCall("wininet\InternetOpen", "ptr",  &Agent
                                                        , "uint", INTERNET_OPEN_TYPE_DIRECT
                                                        , "ptr",  0
                                                        , "ptr",  0
                                                        , "uint", 0
                                                        , "ptr"))
            throw Exception("InternetOpen failed: " A_LastError, -1)
        return HINTERNET
    }

    ; ===========================================================================================================================
    ; InternetConnect                                             https://msdn.microsoft.com/en-us/library/aa384363(v=vs.85).aspx
    ; ===========================================================================================================================
    InternetConnect(HINTERNET, ServerName, Username, Password)
    {
        static INTERNET_DEFAULT_FTP_PORT := 21
        static INTERNET_SERVICE_FTP      := 1
        static INTERNET_FLAG_PASSIVE     := 0x08000000
        if !(HCONNECT := DllCall("wininet\InternetConnect", "ptr",    HINTERNET
                                                          , "ptr",    &ServerName
                                                          , "ushort", INTERNET_DEFAULT_FTP_PORT
                                                          , "ptr",    &Username
                                                          , "ptr",    &Password
                                                          , "uint",   INTERNET_SERVICE_FTP
                                                          , "uint",   INTERNET_FLAG_PASSIVE
                                                          , "uptr",   0
                                                          , "ptr"))
            throw Exception("InternetConnect failed: " A_LastError, -1)
        return HCONNECT
    }

    ; ===========================================================================================================================
    ; FtpCreateDirectory                                          https://msdn.microsoft.com/en-us/library/aa384136(v=vs.85).aspx
    ; ===========================================================================================================================
    FtpCreateDirectory(HCONNECT, Directory)
    {
        if !(DllCall("wininet\FtpCreateDirectory", "ptr", HCONNECT
                                                 , "ptr", &Directory))
            throw Exception("FtpCreateDirectory failed: " A_LastError, -1)
        return True
    }

    ; ===========================================================================================================================
    ; FtpDeleteFile                                               https://msdn.microsoft.com/en-us/library/aa384142(v=vs.85).aspx
    ; ===========================================================================================================================
    FtpDeleteFile(HCONNECT, FileName)
    {
        if !(DllCall("wininet\FtpDeleteFile", "ptr", HCONNECT
                                            , "ptr", &FileName))
            throw Exception("FtpDeleteFile failed: " A_LastError, -1)
        return true
    }

    ; ===========================================================================================================================
    ; FtpGetCurrentDirectory                                      https://msdn.microsoft.com/en-us/library/aa384153(v=vs.85).aspx
    ; ===========================================================================================================================
    FtpGetCurrentDirectory(HCONNECT)
    {
        static MAX_PATH := VarSetCapacity(CurrentDirectory, 260)
        if !(DllCall("wininet\FtpGetCurrentDirectory", "ptr",   HCONNECT
                                                     , "ptr",   &CurrentDirectory
                                                     , "uint*", MAX_PATH))
            throw Exception("FtpGetCurrentDirectory failed: " A_LastError, -1)
        return StrGet(&CurrentDirectory)
    }

    ; ===========================================================================================================================
    ; FtpGetFile                                                  https://msdn.microsoft.com/en-us/library/aa384157(v=vs.85).aspx
    ; ===========================================================================================================================
    FtpGetFile(HCONNECT, RemoteFile, LocaleFile)
    {
        if !(DllCall("wininet\FtpGetFile", "ptr",  HCONNECT
                                         , "ptr",  &RemoteFile
                                         , "ptr",  &LocaleFile
                                         , "int",  0
                                         , "uint", 0
                                         , "uint", 0
                                         , "uptr", 0))
            throw Exception("FtpGetFile failed: " A_LastError, -1)
        return true
    }

    ; ===========================================================================================================================
    ; FtpGetFileSize                                              https://msdn.microsoft.com/en-us/library/aa384159(v=vs.85).aspx
    ; ===========================================================================================================================
    FtpGetFileSize(HFTPSESSION)
    {
        if !(FileSizeHigh := DllCall("wininet\FtpGetFileSize", "ptr", HFTPSESSION
                                                             , "uint*", 0))
            throw Exception("FtpGetFileSize failed: " A_LastError, -1)
        return FileSizeHigh
    }

    ; ===========================================================================================================================
    ; FtpOpenFile                                                 https://msdn.microsoft.com/en-us/library/aa384166(v=vs.85).aspx
    ; ===========================================================================================================================
    FtpOpenFile(HCONNECT, FileName)
    {
        if !(HFTPSESSION := DllCall("wininet\FtpOpenFile", "ptr",  HCONNECT
                                                         , "ptr",  &FileName
                                                         , "uint", 0x80000000
                                                         , "uint", 0
                                                         , "uptr", 0))
            throw Exception("FtpOpenFile failed: " A_LastError, -1)
        return HFTPSESSION
    }

    ; ===========================================================================================================================
    ; FtpPutFile                                                  https://msdn.microsoft.com/en-us/library/aa384170(v=vs.85).aspx
    ; ===========================================================================================================================
    FtpPutFile(HCONNECT, LocaleFile, RemoteFile)
    {
        if !(DllCall("wininet\FtpPutFile", "ptr",  HCONNECT
                                         , "ptr",  &LocaleFile
                                         , "ptr",  &RemoteFile
                                         , "uint", 0
                                         , "uptr", 0))
            throw Exception("FtpPutFile failed: " A_LastError, -1)
        return true
    }

    ; ===========================================================================================================================
    ; FtpRemoveDirectory                                          https://msdn.microsoft.com/en-us/library/aa384172(v=vs.85).aspx
    ; ===========================================================================================================================
    FtpRemoveDirectory(HCONNECT, Directory)
    {
        if !(DllCall("wininet\FtpRemoveDirectory", "ptr", HCONNECT
                                                 , "ptr", &Directory))
            throw Exception("FtpRemoveDirectory failed: " A_LastError, -1)
        return true
    }

    ; ===========================================================================================================================
    ; FtpRenameFile                                               https://msdn.microsoft.com/en-us/library/aa384175(v=vs.85).aspx
    ; ===========================================================================================================================
    FtpRenameFile(HCONNECT, ExistingFile, NewFile)
    {
        if !(DllCall("wininet\FtpRenameFile", "ptr", HCONNECT
                                            , "ptr", &ExistingFile
                                            , "ptr", &NewFile))
            throw Exception("FtpRenameFile failed: " A_LastError, -1)
        return true
    }

    ; ===========================================================================================================================
    ; FtpSetCurrentDirectory                                      https://msdn.microsoft.com/en-us/library/aa384178(v=vs.85).aspx
    ; ===========================================================================================================================
    FtpSetCurrentDirectory(HCONNECT, Directory)
    {
        if !(DllCall("wininet\FtpSetCurrentDirectory", "ptr", HCONNECT
                                                     , "ptr", &Directory))
            throw Exception("FtpSetCurrentDirectory failed: " A_LastError, -1)
        return true
    }

    ; ===========================================================================================================================
    ; InternetCloseHandle                                         https://msdn.microsoft.com/en-us/library/aa384350(v=vs.85).aspx
    ; ===========================================================================================================================
    InternetCloseHandle(HINTERNET)
    {
        if !(DllCall("wininet\InternetCloseHandle", "ptr", HINTERNET))
            throw Exception("InternetCloseHandle failed: " A_LastError, -1)
        return true
    }
}

; ===============================================================================================================================

hInternet := FTP.InternetOpen("Upload Test")
hConnect  := FTP.InternetConnect(hInternet, "example.net", "username", "password")

FTP.FtpSetCurrentDirectory(hConnect, "Upload_Folder")
FTP.FtpPutFile(hConnect, "C:\Temp\testfile.txt", "testfile.txt")

hFTPSession := FTP.FtpOpenFile(hConnect, "testfile.txt")
MsgBox % FTP.FtpGetFileSize(hFTPSession) " Bytes"
FTP.InternetCloseHandle(hFTPSession)

FTP.FtpGetFile(hConnect, "testfile.txt", "C:\Temp\testfile.txt")
FTP.FtpDeleteFile(hConnect, "testfile.txt")

FTP.InternetCloseHandle(hConnect)
FTP.InternetCloseHandle(hInternet)