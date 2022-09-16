; Title:   	https://raw.githubusercontent.com/tthreeoh/ahk/d412741b8ebf7a828df771a62d6b8db79d638c0c/lib/cmdkey.ahk
; Link:
; Author:
; Date:
; for:     	AHK_L

/*

target:="SampleTarget",username:="SamepleUsername",pass:="Luggage12345"
clipboard:=key.AddGeneric(target,username,pass)
clipboard.=key.List(target)
key.Delete(target)
clipboard.=key.List()

*/


class cmd {

    stdOut(command){

	    return this.hideout(command)

    }
    showout(command) {
        shell := comobjcreate("WScript.shell")
        exec := (shell.exec(comspec " /c " command))
        stdout := exec.stdout.readall()
        Return stdout
    }
    hideout(Target, Size:=""){
        DetectHiddenWindows, On
        pComSpec := A_ComSpec ? A_ComSpec : ComSpec
        Run, % pComSpec,, Hide, pid
        WinWait, % "ahk_pid " pid
        DllCall("kernel32\AttachConsole", "UInt",pid)00
        shell := ComObjCreate("WScript.Shell")
        Exec := shell.Exec(Target)
        StdOut := ""
        if !(Size = "")
            VarSetCapacity(StdOut, Size)
        while !Exec.StdOut.AtEndOfStream
            StdOut := Exec.StdOut.ReadAll()
        DllCall("kernel32\FreeConsole")
        Process, Close, % pid
        return StdOut
    }
}
class key {
    List(target=""){
        command:="cmdkey /List:" target
        return cmd.stdOut(command)
    }
    AddGeneric(targetName,Username,Password){
        if (targetName=""){
            InputBox, targetName, % A_ThisFunc, Enter Target Name,, %Width%, %Height%, %X%, %Y%
        }
        if (Username=""){
            InputBox, Username,  % A_ThisFunc, Enter Username,, %Width%, %Height%, %X%, %Y%
        }
        if (Password=""){
            InputBox, Password, % "Enter Password for " Username, HIDE, %Width%, %Height%, %X%, %Y%
        }
        command:="cmdkey /generic:" targetName " /user:" Username " /pass:" Password
        result:=cmd.stdOut(command)
        if cmd.stdOut(command) ~=successfully
            return result
        else
            return 0

    }
    Delete(targetName){
        if (targetName=""){
            InputBox, targetName, % A_ThisFunc, Enter Target Name To Delete,, %Width%, %Height%, %X%, %Y%
        }
        if cmd.stdOut("cmdkey /Delete:" targetName) ~=successfully
            return 1
        else
            return 0
    }
    Get(targetName) {
        ; DllCall is used to invoke the CredRead API, defined in WinCred.h:
        ;
        ; BOOL CredReadW(
        ;   _In_  LPCWSTR	 TargetName,
        ;   _In_  DWORD	   Type,
        ;   _In_  DWORD	   Flags,
        ;   _Out_ PCREDENTIAL *Credential
        ; );
        ;
        ; VOID CredFree(
        ;   _In_ PVOID Buffer
        ; );
        ;
        ; typedef struct _CREDENTIALW {
        ;  0	   DWORD				 Flags;
        ;  4	   DWORD				 Type;
        ;  8	   LPWSTR				TargetName;
        ;  8 + 1*p LPWSTR				Comment;
        ;  8 + 2*p FILETIME			  LastWritten; { 8+2p DWORD dwLowDateTime; 12+2p DWORD dwHighDateTime; }
        ; 16 + 2*p DWORD				 CredentialBlobSize;
        ;(20 + 2*p DWORD padding on 64-bit)
        ; 16 + 3*p LPBYTE				CredentialBlob;
        ; 16 + 4*p DWORD				 Persist;
        ; 20 + 4*p DWORD				 AttributeCount;
        ; 24 + 4*p PCREDENTIAL_ATTRIBUTE Attributes;
        ; 24 + 5*p LPWSTR				TargetAlias;
        ; 24 + 6*p LPWSTR				UserName;
        ; } CREDENTIAL, *PCREDENTIAL;
        ;
        ; #define CRED_TYPE_GENERIC			   1
        ;#Include, <cmd>
        local pCred := 0
        local ret := DllCall( "ADVAPI32\CredReadW", "WStr", targetName, "UInt", 1, "UInt", 0, "Ptr*", pCred, "Int" )
        if ( 0 != ErrorLevel ) {
            MsgBox % A_LineNumber "`nDllCall error invoking CredReadW: " . ErrorLevel
            return
        }
        if ( 1 != ret ) {
            MsgBox % "Error from CredRead: " . A_LastError
            return
        }
        local credentialBlobSizeOffset := 16 + 2*A_PtrSize
        local uCredentialBlobOffset	:= 24 + 6*A_PtrSize
        local pCredentialBlobOffset	:= 16 + 3*A_PtrSize

        local credentialBlobSize := NumGet( pCred + credentialBlobSizeOffset, "UInt" )
        local uCredentialBlob	:= NumGet( pCred + uCredentialBlobOffset,	"Ptr" )
        local pCredentialBlob	:= NumGet( pCred + pCredentialBlobOffset,	"Ptr" )


        username := StrGet( uCredentialBlob,, "UTF-16" )
        password := StrGet( pCredentialBlob, credentialBlobSize / 2, "UTF-16" )

        DllCall( "ADVAPI32\CredFree", "Ptr", pCred )
        if ( 0 != ErrorLevel ) {
            MsgBox % "DllCall error invoking CredFree: " . ErrorLevel
            ;return
        }

        return {"username": username, "password": password}
    }
}
