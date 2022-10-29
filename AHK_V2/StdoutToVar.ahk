; ----------------------------------------------------------------------------------------------------------------------
; Function .....: StdoutToVar
; Description ..: Runs a command line program and returns its output.
; Parameters ...: sCmd - Commandline to be executed.
; ..............: sDir - Working directory.
; ..............: sEnc - Encoding used by the target process. Look at StrGet() for possible values.
; Return .......: Command output as a string on success, empty string on error.
; AHK Version ..: AHK v2 x32/64 Unicode
; Author .......: Sean (http://goo.gl/o3VCO8), modified by nfl and by Cyruz
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Feb. 20, 2007 - Sean version.
; ..............: Sep. 21, 2011 - nfl version.
; ..............: Nov. 27, 2013 - Cyruz version (code refactored and exit code).
; ..............: Mar. 09, 2014 - Removed input, doesn't seem reliable. Some code improvements.
; ..............: Mar. 16, 2014 - Added encoding parameter as pointed out by lexikos.
; ..............: Jun. 02, 2014 - Corrected exit code error.
; ..............: Nov. 02, 2016 - Fixed blocking behavior due to ReadFile thanks to PeekNamedpipe.
; ..............: Apr. 13, 2021 - Code restyling. Fixed deprecated DllCall types.
; ..............: Oct. 06, 2022 - AHK v2 version. Throw exceptions on failure.
; ----------------------------------------------------------------------------------------------------------------------
StdoutToVar(sCmd, sDir:="", sEnc:="CP0") {
    If !DllCall( "CreatePipe"
               , "PtrP" , &hStdOutRd:=0
               , "PtrP" , &hStdOutWr:=0
               , "Ptr"  , 0
               , "UInt" , 0 )
        Throw("Error creating pipe.")
    If !DllCall( "SetHandleInformation"
               , "Ptr"  , hStdOutWr
               , "UInt" , 1
               , "UInt" , 1 )
    {
        DllCall( "CloseHandle", "Ptr" , hStdOutWr )
        DllCall( "CloseHandle", "Ptr" , hStdOutRd )
        Throw("Error setting handle information.")
    }

    PI := Buffer(A_PtrSize == 4 ? 16 : 24,  0)
    SI := Buffer(A_PtrSize == 4 ? 68 : 104, 0)
    NumPut( "UInt", SI.Size,   SI,  0 )
    NumPut( "UInt", 0x100,     SI, A_PtrSize == 4 ? 44 : 60 )
    NumPut( "Ptr",  hStdOutWr, SI, A_PtrSize == 4 ? 60 : 88 )
    NumPut( "Ptr",  hStdOutWr, SI, A_PtrSize == 4 ? 64 : 96 )

    If !DllCall( "CreateProcess"
               , "Ptr"  , 0
               , "Str"  , sCmd
               , "Ptr"  , 0
               , "Ptr"  , 0
               , "Int"  , True
               , "UInt" , 0x08000000
               , "Ptr"  , 0
               , "Ptr"  , sDir ? StrPtr(sDir) : 0
               , "Ptr"  , SI
               , "Ptr"  , PI )
    {
        DllCall( "CloseHandle", "Ptr" , hStdOutWr )
        DllCall( "CloseHandle", "Ptr" , hStdOutRd )
        Throw("Error creating process.")
    }

    ; The write pipe must be closed before reading the stdout.
    DllCall( "CloseHandle", "Ptr" , hStdOutWr )

    ; Before reading, we check if the pipe has been written to, so we avoid freezings.
    nAvail := 0, nLen := 0
    While DllCall( "PeekNamedPipe"
                 , "Ptr"   , hStdOutRd
                 , "Ptr"   , 0
                 , "UInt"  , 0
                 , "Ptr"   , 0
                 , "UIntP" , &nAvail
                 , "Ptr"   , 0 ) != 0
    {
        ; If the pipe buffer is empty, sleep and continue checking.
        If !nAvail && DllCall( "Sleep", "UInt",100 )
            Continue
        cBuf := Buffer(nAvail+1)
        DllCall( "ReadFile"
               , "Ptr"  , hStdOutRd
               , "Ptr"  , cBuf
               , "UInt" , nAvail
               , "PtrP" , &nLen
               , "Ptr"  , 0 )
        sOutput .= StrGet(cBuf, nLen, sEnc)
    }
    
    DllCall( "GetExitCodeProcess"
           , "Ptr"   , NumGet(PI, 0, "Ptr")
           , "UIntP" , &nExitCode:=0 )
    DllCall( "CloseHandle", "Ptr" , NumGet(PI, 0, "Ptr") )
    DllCall( "CloseHandle", "Ptr" , NumGet(PI, A_PtrSize, "Ptr") )
    DllCall( "CloseHandle", "Ptr" , hStdOutRd )
    
    Return { Output: sOutput, ExitCode: nExitCode } 
}
