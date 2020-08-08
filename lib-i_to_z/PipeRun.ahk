; ----------------------------------------------------------------------------------------------------------------------
; Function .....: PipeRun
; Description ..: Runs an AutoHotkey script dynamically through a pipe.
; Parameters ...: sScript - Script to execute.
; ..............: sExe    - Path to the desired AutoHotkey executable.
; Return .......: -1 if the executable doesn't exists, 0 on pipe error, 1 on success.
; AHK Version ..: AHK_L x32/64 Unicode
; Author .......: Cyruz (http://ciroprincipe.info) - from a lexikos idea and code (http://goo.gl/6H4UPB)
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Dic. 07, 2013 - v0.1 - First version.
; ----------------------------------------------------------------------------------------------------------------------
PipeRun(sScript, sExe:="") {
    If ( !sExe || !FileExist(sExe) ) {
        If ( A_AhkPath )
             sExe := A_AhkPath
        Else Return -1
    }
    
    ; Before reading the file, AutoHotkey calls GetFileAttributes(). This causes the
    ; pipe to close, so we must create a second pipe for the actual file contents.
    hPipe_fake := DllCall( "CreateNamedPipe", Str,"\\.\pipe\AHKPipe", UInt,2, UInt,0
                                            , UInt,255, UInt,0, UInt,0, UInt,0, Ptr,0, Ptr )
    hPipe_real := DllCall( "CreateNamedPipe", Str,"\\.\pipe\AHKPipe", UInt,2, UInt,0
                                            , UInt,255, UInt,0, UInt,0, UInt,0, Ptr,0, Ptr )
    If ( hPipe_fake == -1 || hPipe_real == -1 )
        Return 0
    
    ; Standard AHK needs a UTF-8 BOM to work via pipe.
    sScript := ((A_IsUnicode) ? chr(0xfeff) : chr(239) chr(187) chr(191)) . sScript
    nSize   := (StrLen(sScript)+1)*((A_IsUnicode) ? 2 : 1)
    Run, %sExe% "\\.\pipe\AHKPipe"
    DllCall( "ConnectNamedPipe", Ptr,hPipe_fake, Ptr,0                                  )
    DllCall( "CloseHandle",      Ptr,hPipe_fake                                         )
    DllCall( "ConnectNamedPipe", Ptr,hPipe_real, Ptr,0                                  )
    DllCall( "WriteFile",        Ptr,hPipe_real, Str,sScript, UInt,nSize, UInt,0, Ptr,0 )
    DllCall( "CloseHandle",      Ptr,hPipe_real                                         )
    Return 1
}