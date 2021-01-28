/* Windows Service Control Functions
-heresy

- Return Values
     1 : Success
     0 : Failure
    -4 : Service Not Found

- State codes from Service_State() 
    SERVICE_STOPPED (1) : The service is not running.
    SERVICE_START_PENDING (2) : The service is starting.
    SERVICE_STOP_PENDING (3) : The service is stopping.
    SERVICE_RUNNING (4) : The service is running.
    SERVICE_CONTINUE_PENDING (5) : The service continue is pending.
    SERVICE_PAUSE_PENDING (6) : The service pause is pending.
    SERVICE_PAUSED (7) : The service is paused.
*/

	/*                              	EXAMPLE(s)
	
			MsgBox % Service_List("Active") ;Get List of Running Win32 Service
			
			if Service_State("Print Spooler")=4 ;if Print Spooler service is running
			    Service_Stop("Print Spooler") ;stop
			else if Service_State("Print Spooler")=1 ;if Print Spooler service is not running
			    Service_Start("Print Spooler") ;start
			
			MsgBox % Service_State("Print Spooler")
			
	*/
	
Service_List(State="", Type="", delimiter="`n") {
    if !State
        ServiceState := 0x3 ;SERVICE_STATE_ALL (0x00000003)
    else if (State="Active")
        ServiceState := 0x1 ;SERVICE_ACTIVE (0x00000001)
    else if (State="Inactive")
        ServiceState := 0x2 ;SERVICE_INACTIVE (0x00000002)
    else
        ServiceState := 0x3
    
    if !Type
        ServiceType := 0x30 ;SERVICE_WIN32 (0x00000030)
    else if (Type="Driver")
        ServiceType := 0xB ;SERVICE_DRIVER (0x0000000B)
    else if (Type="All")
        ServiceType := 0x3B ;sum of both
    else
        ServiceType := 0x30
       
    SCM_HANDLE := DllCall("advapi32\OpenSCManagerA"
                        , "Int", 0
                        , "Int", 0
                        , "UInt", 0x4) ;SC_MANAGER_ENUMERATE_SERVICE (0x0004)    

    DllCall("advapi32\EnumServicesStatusA"
        , "UInt", SCM_HANDLE
        , "UInt", ServiceType
        , "UInt", ServiceState
        , "UInt", 0
        , "UInt", 0
        , "UIntP", bSize ;get required buffer size first
        , "UIntP", 0
        , "UIntP", 0)
    
    VarSetCapacity(ENUM_SERVICE_STATUS, bSize, 0) ;prepare struct
    
    DllCall("advapi32\EnumServicesStatusA" ;actual enumeration
        , "UInt", SCM_HANDLE
        , "UInt", ServiceType
        , "UInt", ServiceState
        , "UInt", &ENUM_SERVICE_STATUS
        , "UInt", bSize
        , "UIntP", 0
        , "UIntP", ServiceCount
        , "UIntP", 0)
    
    Loop, %ServiceCount%
        result .= DllCall("MulDiv"
                        , "Int", NumGet(ENUM_SERVICE_STATUS, (A_Index-1)*36+4)
                        , "Int", 1
                        , "Int", 1, "str") . delimiter

    DllCall("advapi32\CloseServiceHandle", "UInt", SCM_HANDLE)
    Return result
    
}

Service_Start(ServiceName) {
    ServiceName := _GetName_(ServiceName) 

    SCM_HANDLE := DllCall("advapi32\OpenSCManagerA"
                        , "Int", 0 ;NULL for local
                        , "Int", 0
                        , "UInt", 0x1) ;SC_MANAGER_CONNECT (0x0001)    

    if !(SC_HANDLE := DllCall("advapi32\OpenServiceA"
                            , "UInt", SCM_HANDLE
                            , "Str", ServiceName
                            , "UInt", 0x10)) ;SERVICE_START (0x0010)
        result := -4 ;Service Not Found

    if !result
        result := DllCall("advapi32\StartServiceA"
                        , "UInt", SC_HANDLE
                        , "Int", 0
                        , "Int", 0)

    DllCall("advapi32\CloseServiceHandle", "UInt", SC_HANDLE)
    DllCall("advapi32\CloseServiceHandle", "UInt", SCM_HANDLE)
    return result
}

Service_Stop(ServiceName) {
    ServiceName := _GetName_(ServiceName)

    SCM_HANDLE := DllCall("advapi32\OpenSCManagerA"
                        , "Int", 0 ;NULL for local
                        , "Int", 0
                        , "UInt", 0x1) ;SC_MANAGER_CONNECT (0x0001)    

    if !(SC_HANDLE := DllCall("advapi32\OpenServiceA"
                            , "UInt", SCM_HANDLE
                            , "Str", ServiceName
                            , "UInt", 0x20)) ;SERVICE_STOP (0x0020)
        result := -4 ;Service Not Found

    if !result
        result := DllCall("advapi32\ControlService"
                        , "UInt", SC_HANDLE
                        , "Int", 1
                        , "Str", "")

    DllCall("advapi32\CloseServiceHandle", "UInt", SC_HANDLE)
    DllCall("advapi32\CloseServiceHandle", "UInt", SCM_HANDLE)
    return result
}

Service_State(ServiceName) { ; Return Values
; SERVICE_STOPPED (1) : The service is not running.
; SERVICE_START_PENDING (2) : The service is starting.
; SERVICE_STOP_PENDING (3) : The service is stopping.
; SERVICE_RUNNING (4) : The service is running.
; SERVICE_CONTINUE_PENDING (5) : The service continue is pending.
; SERVICE_PAUSE_PENDING (6) : The service pause is pending.
; SERVICE_PAUSED (7) : The service is paused.
    ServiceName := _GetName_(ServiceName)

    SCM_HANDLE := DllCall("advapi32\OpenSCManagerA"
                        , "Int", 0 ;NULL for local
                        , "Int", 0
                        , "UInt", 0x1) ;SC_MANAGER_CONNECT (0x0001)
                            
    if !(SC_HANDLE := DllCall("advapi32\OpenServiceA"
                            , "UInt", SCM_HANDLE
                            , "Str", ServiceName
                            , "UInt", 0x4)) ;SERVICE_QUERY_STATUS (0x0004)
        result := -4 ;Service Not Found

    VarSetCapacity(SC_STATUS, 28, 0) ;SERVICE_STATUS Struct

    if !result
        result := !DllCall("advapi32\QueryServiceStatus"
                         , "UInt", SC_HANDLE
                         , "UInt", &SC_STATUS)
                         ? False : NumGet(SC_STATUS, 4) ;-1 or dwCurrentState

    DllCall("advapi32\CloseServiceHandle", "UInt", SC_HANDLE)
    DllCall("advapi32\CloseServiceHandle", "UInt", SCM_HANDLE)
    return result
}

Service_Add(ServiceName, BinaryPath, StartType=""){
    if !A_IsAdmin
        Return False

    SCM_HANDLE := DllCall("advapi32\OpenSCManagerA"
                        , "Int", 0
                        , "Int", 0
                        , "UInt", 0x2) ;SC_MANAGER_CREATE_SERVICE (0x0002)
    
    StartType := !StartType ? 0x3 : 0x2
    ;SERVICE_DEMAND_START(0x00000003) vs SERVICE_AUTO_START(0x00000002)
    
    SC_HANDLE := DllCall("advapi32\CreateServiceA"
                   , "UInt", SCM_HANDLE
                   , "Str", ServiceName
                   , "Str", ServiceName
                   , "UInt", 0xF01FF ;SERVICE_ALL_ACCESS (0xF01FF)
                   , "UInt", 0x110 ;SERVICE_WIN32_OWN_PROCESS(0x00000010) | SERVICE_INTERACTIVE_PROCESS(0x00000100)
    ;interactable service with desktop (requires local account)
    ;http://msdn.microsoft.com/en-us/library/ms683502(VS.85).aspx
                   , "UInt", StartType
                   , "UInt", 0x1 ;SERVICE_ERROR_NORMAL(0x00000001)
                   , "Str", BinaryPath
                   , "Str", "" ;No Group
                   , "UInt", 0 ;No TagId
                   , "Str", "" ;No Dependencies
                   , "Int", 0 ;Use LocalSystem Account
                   , "Str", "")
    result := A_LastError ? SC_HANDLE "," A_LastError : 1
    DllCall("advapi32\CloseServiceHandle", "UInt", SC_HANDLE)
    DllCall("advapi32\CloseServiceHandle", "UInt", SCM_HANDLE)
    Return result
}

Service_Delete(ServiceName) {
	
    if !A_IsAdmin ;Requires Administrator rights
        Return False
    ServiceName := _GetName_(ServiceName)    

    SCM_HANDLE := DllCall("advapi32\OpenSCManagerA"
                        , "Int", 0 ;NULL for local
                        , "Int", 0
                        , "UInt", 0x1) ;SC_MANAGER_CONNECT (0x0001)

    if !(SC_HANDLE := DllCall("advapi32\OpenServiceA"
                            , "UInt", SCM_HANDLE
                            , "Str", ServiceName
                            , "UInt", 0xF01FF)) ;SERVICE_ALL_ACCESS (0xF01FF)
        result := -4 ;Service Not Found

    if !result
        result := DllCall("advapi32\DeleteService", "Uint", SC_HANDLE)

    DllCall("advapi32\CloseServiceHandle", "UInt", SC_HANDLE)
    Return result    
}

_GetName_(DisplayName) { ;Internal, Gets Service Name from Display Name, 
    SCM_HANDLE := DllCall("advapi32\OpenSCManagerA", "Int", 0, "Int", 0, "UInt", 0x1) ;SC_MANAGER_CONNECT (0x0001)    

    DllCall("advapi32\GetServiceKeyNameA" ;Get Buffer Size
            , "Uint", SCM_HANDLE
            , "Str", DisplayName
            , "Int", 0
            , "UintP", Len)

    VarSetCapacity(Buffer, Len) ;Prepare Buffer

    DllCall("advapi32\GetServiceKeyNameA" ;Get Actual Service Name
        , "Uint", SCM_HANDLE
        , "Str", DisplayName
        , "Uint", &Buffer
        , "UintP", Len)

    Loop, % Len//2    
        Output .= Chr(NumGet(Buffer, A_Index-1, "Char"))

    return !Output ? DisplayName : Output
}