/*! TheGood
    AHKsock - A simple AHK implementation of Winsock.
    AHKsock Example 4 - Hostname & IP Lookups
    http://www.autohotkey.com/forum/viewtopic.php?p=355775
    Last updated: August 24th, 2010
    
    This is just a very simple example that demonstrates the use of two inverse functions: AHKsock_GetAddrInfo and
    AHKsock_GetNameInfo. The code should be simple enough to follow.
*/
    ;We'll need to allow more than one instance to test it on the same machine
    #SingleInstance, Off
    
    ;Needed if AHKsock isn't in one of your lib folders
    ;#Include %A_ScriptDir%\AHKsock.ahk
    
    ;Set up an OnExit routine
    OnExit, GuiClose
    
    ;Make the GUI
    Gui, Add, Text,, What would you like to do?
    Gui, Add, Button, wp gbtnGAI, Hostname to IP(s)
    Gui, Add, Button, wp gbtnGNI, IP to Hostname
    Gui, Show
Return

GuiClose:
GuiEscape:
    AHKsock_Close() ;No sockets to actually close here. We just do it to cleanup WinSock.
ExitApp

btnGAI:
    Gui, +OwnDialogs
    
    ;Random examples for the default value of the InputBox
    sEx1 := "www.google.com"
    sEx2 := "localhost"
    sEx3 := A_ComputerName
    Random, Default, 1, 3
    
    ;Ask for the hostname
    InputBox, sName, Hostname to IP(s), Please enter the hostname to look up:,,, 120,,,,, % sEx%Default%
    If ErrorLevel
        Return
    
    ;Get the IPs
    If (i := AHKsock_GetAddrInfo(sName, sIPList)) {
        MsgBox 0x10, Error, % "AHKsock_GetAddrInfo failed.`nReturn value = " i ".`nErrorLevel = " ErrorLevel
        Return
    }
    
    ;Display
    MsgBox 0x40, Results, % "Hostname:`n" sName "`n`nIP addresses found:`n" sIPList
    
Return

btnGNI:
    Gui, +OwnDialogs
    
    ;Random service examples for the default value of the InputBox
    sEx1 := 7  ;echo
    sEx2 := 21 ;ftp
    sEx3 := 25 ;SMTP
    sEx4 := 80 ;http
    Random, Default, 1, 4
    
    ;Ask for the IP
    InputBox, sIPandPort, IP to Hostname, Please enter the IP address (and optionally the port) to look up:,,, 120,,,,, % "127.0.0.1:" sEx%Default%
    If ErrorLevel
        Return
    
    ;Separate the IP and the port
    If Not (i := InStr(sIPandPort, ":"))
        sIP := sIPandPort, sPort := 0
    Else sIP := SubStr(sIPandPort, 1, i - 1), sPort := SubStr(sIPandPort, i + 1)
    
    ;Get the hostname
    If (i := AHKsock_GetNameInfo(sIP, sName, sPort, sService)) {
        MsgBox 0x10, Error, % "AHKsock_GetNameInfo failed.`nReturn value = " i ".`nErrorLevel = " ErrorLevel
        Return
    }
    
    ;Display
    MsgBox 0x40, Results, % "IP address: " sIP (sPort ? "`nPort: " sPort : "") "`n`nHostname: " sName (sPort ? "`nService: " sService : "")
    
Return
