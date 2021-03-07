; Title:   	WaitForServer - Wait for a server to be up and running
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=66826&hilit=TCP
; Author:	cyruz
; Date:   	06 Aug 2019, 07:35
; for:     	AHK_L

/*
    I created this function to avoid importing a full socket implementation when we just need to check for a server to be up and running.
    It uses the WSAConnectByName function, that doesn't need any SOCKADDR structure and whatever else...

*/

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: WaitForServer
; Description ..: Wait for a server socket to be ready and accepting connections.
; Parameters ...: sAddress - Hostname or IP address of the server.
; ..............: sPort    - Socket port.
; ..............: nRetries - How many times to retry before failing.
; ..............: msSleep  - Millisends to sleep between retries.
; Return .......: 1 - Success.
; ..............: 0 - Failure.
; AHK Version ..: 1.1.30.1 x32/x64 Unicode
; Author .......: cyruz - http://ciroprincipe.info
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Jul. 09, 2019 - v0.1.0 - First version.
; ..............: Aug. 17, 2019 - v0.1.1 - Corrected WSAData size, dSocket return type and added LoadLibrary to avoid
; ..............:                          this behavior: https://www.autohotkey.com/boards/viewtopic.php?f=76&t=62000.
; ..............:                          Thanks Helgef :)
; ----------------------------------------------------------------------------------------------------------------------
WaitForServer(sAddress, sPort, nRetries:=5, msSleep:=1000){

    If ( !(hDll := DllCall("LoadLibrary", "Str","Ws2_32.dll", "Ptr")) )
	    Return 0

    Try    {
        ; https://docs.microsoft.com/en-us/windows/win32/api/winsock/nf-winsock-wsastartup
    	VarSetCapacity(WSAData, (A_PtrSize == 8 ? 408 : 400))
	    If ( bWSA := DllCall("Ws2_32.dll\WSAStartup", "UShort",0x0002, "Ptr",&WSAData) )
            Return 0

        While ( A_Index <= nRetries )        {

            ; https://docs.microsoft.com/en-us/windows/win32/api/winsock2/nf-winsock2-socket
            ; AF_INET = 2 / SOCK_STREAM = 1 / IPPROTO_TCP = 6 / INVALID_SOCKET = ~0
            If ( (dSocket := DllCall("Ws2_32.dll\socket", "Int",2, "Int",1, "Int",6, "UPtr")) == -1 )
                Return 0

            ; The WSAConnectByName allows to check if a simple connection to the server can be established.
            ; https://docs.microsoft.com/en-us/windows/win32/api/winsock2/nf-winsock2-wsaconnectbynamew
            bSuccess := DllCall( "Ws2_32.dll\WSAConnectByName", "UPtr",dSocket, "Str",sAddress, "Str",sPort
                               , "Ptr",0, "Ptr",0, "Ptr",0, "Ptr",0, "Ptr",0, "Ptr",0, "Int" )

            ; https://docs.microsoft.com/en-us/windows/win32/api/winsock/nf-winsock-closesocket
            If ( DllCall("Ws2_32.dll\closesocket", "UPtr",dSocket, "Int") == -1 )
                Return 0

            ; Break condition, try to avoid last sleep.
            If ( bSuccess || A_Index == nRetries )
                 Break
            Else Sleep, %msSleep%
        }
    }

    Finally    {
        ; https://docs.microsoft.com/en-us/windows/win32/api/winsock2/nf-winsock2-wsacleanup
        If ( !bWSA )
            DllCall("Ws2_32.dll\WSACleanup")
          , VarSetCapacity(WSAData, 0)

        DllCall("FreeLibrary", "Ptr",hDll)
    }

    Return bSuccess ? 1 : 0
}