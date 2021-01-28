; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; ==================================================================================
; Examples
; ==================================================================================
; svcObj := Service_List()
; Msgbox "done / count: " svcObj.Count

; MsgBox "started: " Service_Start("Browser")
; MsgBox "stopped: " Service_Stop("Browser") ; LanmanServer
; MsgBox "state: " Service_State("Browser")

; ==================================================================================
; ==================================================================================
; ==================================================================================

; originally posted by heresy
; URL: https://autohotkey.com/board/topic/32023-service-function-set-for-handling-windows-services/
; Adapted for AHK v2 by TheArkive
; Microsoft Docs Reference:  https://docs.microsoft.com/en-us/windows/win32/api/winsvc/

/* Windows Service Control Functions
    - Return Values
         1 : Success
         0 : Failure
        
        Check A_LastError for additional fail codes.

    - State codes from Service_State() 
        SERVICE_STOPPED (1) : The service is not running.
        SERVICE_START_PENDING (2) : The service is starting.
        SERVICE_STOP_PENDING (3) : The service is stopping.
        SERVICE_RUNNING (4) : The service is running.
        SERVICE_CONTINUE_PENDING (5) : The service continue is pending.
        SERVICE_PAUSE_PENDING (6) : The service pause is pending.
        SERVICE_PAUSED (7) : The service is paused.
*/


Service_List(State:="", Type:="") {
    Static STANDARD_RIGHTS_READ:=0x20000, SC_MANAGER_ENUMERATE_SERVICE:=0x4, SC_MANAGER_QUERY_LOCK_STATUS:=0x10, SC_MANAGER_CONNECT:=0x1, SC_MANAGER_ALL_ACCESS := 0xF003F
    
    Static SERVICE_FILE_SYSTEM_DRIVER:=0x2, SERVICE_KERNEL_DRIVER:=0x1, SERVICE_WIN32_OWN_PROCESS:=0x10, SERVICE_WIN32_SHARE_PROCESS:=0x20, SERVICE_INTERACTIVE_PROCESS:=0x100
    
    Static SERVICE_AUTO_START:=0x2, SERVICE_BOOT_START:=0x0, SERVICE_DEMAND_START:=0x3, SERVICE_DISABLED:=0x4, SERVICE_SYSTEM_START:=0x1
    
    Static SERVICE_ERROR_CRITICAL:=0x3, SERVICE_ERROR_IGNORE:=0x0, SERVICE_ERROR_NORMAL:=0x1, SERVICE_ERROR_SEVERE:=0x2
    
    Static SERVICE_CONFIG_DELAYED_AUTO_START_INFO:=3, SERVICE_CONFIG_DESCRIPTION:=1, SERVICE_CONFIG_FAILURE_ACTIONS:=2, SERVICE_CONFIG_FAILURE_ACTIONS_FLAG:=4, SERVICE_CONFIG_PREFERRED_NODE:=9, SERVICE_CONFIG_PRESHUTDOWN_INFO:=7, SERVICE_CONFIG_REQUIRED_PRIVILEGES_INFO:=6, SERVICE_CONFIG_SERVICE_SID_INFO:=5, SERVICE_CONFIG_TRIGGER_INFO:=8, SERVICE_CONFIG_LAUNCH_PROTECTED:=12
    
    Static SERVICE_DRIVER:=0xB, SERVICE_WIN32:=0x30, SERVICE_ACTIVE:=0x1, SERVICE_INACTIVE:=0x2, SERVICE_STATE_ALL:=0x3
    
    Static ERROR_ACCESS_DENIED:=5, ERROR_INVALID_HANDLE:=6, ERROR_INVALID_NAME:=123, ERROR_SERVICE_DOES_NOT_EXIST:=1060
    
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
    
    ; ServiceType := SERVICE_DRIVER | SERVICE_FILE_SYSTEM_DRIVER | SERVICE_KERNEL_DRIVER | SERVICE_WIN32 | SERVICE_WIN32_OWN_PROCESS | SERVICE_WIN32_SHARE_PROCESS ; all
    
    ; ServiceType := SERVICE_WIN32 | SERVICE_WIN32_OWN_PROCESS | SERVICE_WIN32_SHARE_PROCESS
    
    funcName := (A_PtrSize=4) ? "OpenSCManagerA" : "OpenSCManagerW"
    SCM_HANDLE := DllCall("advapi32\" funcName, "Ptr", 0, "Ptr", 0, "UInt", SC_MANAGER_ENUMERATE_SERVICE)
    
    funcName := (A_PtrSize=4) ? "EnumServicesStatusA" : "EnumServicesStatusW"
    r := DllCall("advapi32\" funcName
                ,"Ptr", SCM_HANDLE                 ; hSCManager
                ,"UInt", ServiceType               ; dwServiceType
                ,"UInt", ServiceState              ; dwServiceState
                ,"Ptr", 0                          ; lpServices -> 0 = get buffer size
                ,"UInt", 0                         ; cbBufSize -> 0 = get buffer size
                ,"UInt*", bSize:=0                 ; pcbBytesNeeded ; was UIntP
                ,"UInt*", 0                        ; lpServicesReturned ; was UIntP
                ,"UInt*", 0)                       ; lpResumeHandle ; was UIntP
    
    ENUM_SERVICE_STATUS := BufferAlloc(bSize, 0) ;prepare struct
    
    DllCall("advapi32\" funcName ;actual enumeration
           ,"Ptr", SCM_HANDLE,"UInt", ServiceType,"UInt", ServiceState,"Ptr", ENUM_SERVICE_STATUS.Ptr
           ,"UInt", bSize,"UInt*", 0,"UInt*", ServiceCount:=0,"UInt*", 0)
    
    result := ""
    funcName1 := (A_PtrSize=4) ? "OpenServiceA" : "OpenServiceW"
    funcName2 := (A_PtrSize=4) ? "QueryServiceConfigA" : "QueryServiceConfigW"
    funcName3 := (A_PtrSize=4) ? "QueryServiceConfig2A" : "QueryServiceConfig2W"
    struct_size1 := (A_PtrSize=4) ? 36 : 48
    encoding := (A_PtrSize=4) ? "UTF-8" : "UTF-16"
    svcObjList := Map()
    
    Loop ServiceCount {
        readOnly := false
        
        SvcName_LPSTR := NumGet(ENUM_SERVICE_STATUS,(A_Index-1)*struct_size1,"UPtr")
        SvcDisp_LPSTR := NumGet(ENUM_SERVICE_STATUS,((A_Index-1)*struct_size1)+A_PtrSize,"UPtr")
        svcType := NumGet(ENUM_SERVICE_STATUS, ((A_Index-1)*struct_size1)+(A_PtrSize * 2),"UInt")
        svcState := NumGet(ENUM_SERVICE_STATUS, ((A_Index-1)*struct_size1)+(A_PtrSize * 2)+4,"UInt")
        
        svcName := StrGet(SvcName_LPSTR,encoding)
        svcDispName := StrGet(SvcDisp_LPSTR,encoding)
        
        hSvc := DllCall("advapi32\" funcName1           ; OpenService
                       ,"Ptr", SCM_HANDLE               ; hSCManager
                       ,"Ptr", StrPtr(SvcName)          ; lpServiceName
                       ,"UInt", SC_MANAGER_ALL_ACCESS)  ; dwDesiredAccess - SC_MANAGER_ALL_ACCESS := 0xF003F
        
        if (!hSvc) {
            readOnly := truehow
            permRequest := STANDARD_RIGHTS_READ | SC_MANAGER_ENUMERATE_SERVICE | SC_MANAGER_QUERY_LOCK_STATUS | SC_MANAGER_CONNECT
            hSvc := DllCall("advapi32\" funcName1, "Ptr", SCM_HANDLE, "Ptr", StrPtr(SvcName), "UInt", permRequest)
        }
        
        r := DllCall("advapi32\" funcName2  ; QueryServiceConfig
                    ,"Ptr", hSvc            ; hService
                    ,"Ptr", 0               ; lpServiceConfig
                    ,"UInt", 0              ; cbBufSize
                    ,"UInt*", bSize:=0)     ; pcbBytesNeeded
        
        QUERY_SERVICE_CONFIG := BufferAlloc(bSize,0)
        r := DllCall("advapi32\" funcName2,"Ptr",hSvc,"Ptr",QUERY_SERVICE_CONFIG.Ptr, "UInt", bSize, "UInt*", 0)
        
        If (bSize) {
            svcStartMode := NumGet(QUERY_SERVICE_CONFIG,4,"UInt")
            svcErrCtl := NumGet(QUERY_SERVICE_CONFIG,8,"UInt")
            binPath_LPSTR := NumGet(QUERY_SERVICE_CONFIG,(A_PtrSize=4) ? 12 : 16, "UPtr")
            svcPathName := StrGet(binPath_LPSTR,encoding)
            depen_LPSTR := NumGet(QUERY_SERVICE_CONFIG,(A_PtrSize=4) ? 24 : 40, "UPtr")
            
            offset := 0, depenList := "", svcDep := Map(), svcTrigger := 0, svcDelayed := false, svcDesc := ""
            While (curDep := StrGet(depen_LPSTR+offset,encoding)) {
                svcDep[curDep] := ""
                offset += (StrLen(curDep) + 1) * ((A_PtrSize=4) ? 1 : 2)
            }
            
            r := DllCall("advapi32\" funcName3 ; QueryServiceConfig2
                       , "Ptr", hSvc, "UInt", SERVICE_CONFIG_DESCRIPTION, "Ptr", 0, "UInt", 0, "UInt*", bSize:=0)
            SERVICE_DESCRIPTION := BufferAlloc(bSize,0)
            
            if (bSize) {
                r := DllCall("advapi32\" funcName3, "Ptr", hSvc, "UInt", SERVICE_CONFIG_DESCRIPTION
                           , "Ptr", SERVICE_DESCRIPTION.ptr, "UInt", bSize, "UInt*", 0)
                str_ptr := NumGet(SERVICE_DESCRIPTION,"UPtr")
                svcDesc := str_ptr ? StrGet(str_ptr,encoding) : ""
            }
            
            r := DllCall("advapi32\" funcName3, "Ptr", hSvc, "UInt", SERVICE_CONFIG_DELAYED_AUTO_START_INFO, "Ptr", 0, "UInt", 0, "UInt*", bSize:=0)
            SERVICE_DELAYED_AUTO_START_INFO := BufferAlloc(bSize,0)
            
            if (bSize) {
                r := DllCall("advapi32\" funcName3, "Ptr", hSvc, "UInt", SERVICE_CONFIG_DELAYED_AUTO_START_INFO
                           , "Ptr", SERVICE_DELAYED_AUTO_START_INFO.ptr, "UInt", bSize, "UInt*", 0)
                svcDelayed := r ? NumGet(SERVICE_DELAYED_AUTO_START_INFO,"Char") : false
            }
            
            r := DllCall("advapi32\" funcName3, "Ptr", hSvc, "UInt", SERVICE_CONFIG_TRIGGER_INFO, "Ptr", 0, "UInt", 0, "UInt*", bSize:=0)
            SERVICE_TRIGGER_INFO := BufferAlloc(bSize,0)
            
            If (bSize) {
                r := DllCall("advapi32\" funcName3, "Ptr", hSvc, "UInt", SERVICE_CONFIG_TRIGGER_INFO
                           , "Ptr", SERVICE_TRIGGER_INFO.ptr, "UInt", bSize, "UInt*", 0)
                svcTrigger := NumGet(SERVICE_TRIGGER_INFO,"UInt")
            }
        }
        
        r := DllCall("advapi32\CloseServiceHandle", "Ptr", hSvc)
        
        svcObj := Map("svcName",svcName,"svcDispName",svcDispName,"svcStartMode",svcStartMode,"svcState",svcState
                     ,"svcDesc",svcDesc,"svcPathName",svcPathName,"svcType",svcType,"svcDep",svcDep ; ,"svcAnt",svcAnt
                     ,"svcRO",readOnly,"svcTrigger",svcTrigger,"svcDelayed",svcDelayed)
        svcObjList[svcName] := svcObj
    }
    
    DllCall("advapi32\CloseServiceHandle", "Ptr", SCM_HANDLE) ; close service manager
    Return svcObjList
}

; typedef struct _ENUM_SERVICE_STATUSW { ; [36|48]
  ; LPWSTR         lpServiceName;
  ; LPWSTR         lpDisplayName;
  ; SERVICE_STATUS ServiceStatus;
; } ENUM_SERVICE_STATUSW, *LPENUM_SERVICE_STATUSW;

; typedef struct _SERVICE_STATUS { ; size: [28|32]
  ; DWORD dwServiceType;
  ; DWORD dwCurrentState;
  ; DWORD dwControlsAccepted;
  ; DWORD dwWin32ExitCode;
  ; DWORD dwServiceSpecificExitCode;
  ; DWORD dwCheckPoint;
  ; DWORD dwWaitHint;
; } SERVICE_STATUS, *LPSERVICE_STATUS;

; typedef struct _QUERY_SERVICE_CONFIGA {
  ; DWORD dwServiceType;                                |4              0
  ; DWORD dwStartType;                                  |4              4
  ; DWORD dwErrorControl;                               |4              8
  ; LPSTR lpBinaryPathName;                             |[4|8]          [12|16]
  ; LPSTR lpLoadOrderGroup;                             |[4|8]          [16|24]
  ; DWORD dwTagId;                                      |4              [20|32]
  ; LPSTR lpDependencies;                               |[4|8]          [24|40]
  ; LPSTR lpServiceStartName;                           |[4|8]          [28|48]
  ; LPSTR lpDisplayName;                                |[4|8]          [32|56]
; } QUERY_SERVICE_CONFIGA, *LPQUERY_SERVICE_CONFIGA;    |


Service_Start(ServiceName) {
    Static STANDARD_RIGHTS_EXECUTE:=0x20000, STANDARD_RIGHTS_READ:=0x20000 SC_MANAGER_ENUMERATE_SERVICE:=0x4, SC_MANAGER_QUERY_LOCK_STATUS:=0x10, SC_MANAGER_CONNECT:=0x1, SC_MANAGER_ALL_ACCESS := 0xF003F, SC_MANAGER_LOCK:=0x8
    
    Static ERROR_ACCESS_DENIED:=5, ERROR_INVALID_HANDLE:=6, ERROR_INVALID_NAME:=123, ERROR_SERVICE_DOES_NOT_EXIST:=1060
    
    funcName1 := (A_PtrSize=4) ? "OpenSCManagerA" : "OpenSCManagerW"
    funcName2 := (A_PtrSize=4) ? "OpenServiceA" : "OpenServiceW"
    funcName3 := (A_PtrSize=4) ? "StartServiceA" : "StartServiceW"
    
    SCM_HANDLE := DllCall("advapi32\" funcName1 ; OpenSCManager
                        , "Ptr", 0, "Ptr", 0, "UInt", SC_MANAGER_CONNECT)
    
    hSvc := DllCall("advapi32\" funcName2 ; OpenService
                  , "Ptr", SCM_HANDLE
                  , "Ptr", StrPtr(ServiceName)
                  , "UInt", SC_MANAGER_QUERY_LOCK_STATUS) ; 0x10 - this seemms to be minimum required permission
    
    If (!hSvc)
        result := 0 ;Service Not Found
    Else {
        result := DllCall("advapi32\" funcName3, "UPtr", hSvc, "UInt", 0, "Ptr", 0) ; StartService
        DllCall("advapi32\CloseServiceHandle", "UInt", hSvc)
    }
    
    DllCall("advapi32\CloseServiceHandle", "UInt", SCM_HANDLE)
    return result
}

Service_Stop(ServiceName) {
    Static STANDARD_RIGHTS_EXECUTE:=0x20000, STANDARD_RIGHTS_READ:=0x20000 SC_MANAGER_ENUMERATE_SERVICE:=0x4, SC_MANAGER_QUERY_LOCK_STATUS:=0x10, SC_MANAGER_CONNECT:=0x1, SC_MANAGER_ALL_ACCESS := 0xF003F, SC_MANAGER_LOCK:=0x8
    
    Static ERROR_ACCESS_DENIED:=5, ERROR_INVALID_HANDLE:=6, ERROR_INVALID_NAME:=123, ERROR_SERVICE_DOES_NOT_EXIST:=1060
    
    funcName1 := (A_PtrSize=4) ? "OpenSCManagerA" : "OpenSCManagerW"
    funcName2 := (A_PtrSize=4) ? "OpenServiceA" : "OpenServiceW"
    
    SCM_HANDLE := DllCall("advapi32\" funcName1 ; OpenSCManager
                        , "Ptr", 0, "Ptr", 0, "UInt", SC_MANAGER_CONNECT)  

    hSvc := DllCall("advapi32\" funcName2 ; OpenService
                  , "Ptr", SCM_HANDLE, "Ptr", StrPtr(ServiceName), "UInt", 0x20) ;SERVICE_STOP (0x0020)
    
    If (!hSvc)
        result := 0, LastErr := 0
    Else {
        SERVICE_STATUS := BufferAlloc((A_PtrSize=4)?28:32,0)
        result := DllCall("advapi32\ControlService", "UPtr", hSvc, "UInt", 1, "Ptr", SERVICE_STATUS.ptr)
        LastErr := A_LastError
        DllCall("advapi32\CloseServiceHandle", "Ptr", hSvc), SERVICE_STATUS := ""
    }
    DllCall("advapi32\CloseServiceHandle", "Ptr", SCM_HANDLE)
    
    A_LastError := LastErr
    return result
}

Service_State(ServiceName) { ; Return Values
    /*
    SERVICE_STOPPED (1) : The service is not running.
    SERVICE_START_PENDING (2) : The service is starting.
    SERVICE_STOP_PENDING (3) : The service is stopping.
    SERVICE_RUNNING (4) : The service is running.
    SERVICE_CONTINUE_PENDING (5) : The service continue is pending.
    SERVICE_PAUSE_PENDING (6) : The service pause is pending.
    SERVICE_PAUSED (7) : The service is paused.
    */
    funcName1 := (A_PtrSize=4) ? "OpenSCManagerA" : "OpenSCManagerW"
    funcName2 := (A_PtrSize=4) ? "OpenServiceA" : "OpenServiceW"
    
    SCM_HANDLE := DllCall("advapi32\" funcName1 ; OpenSCManager
                        , "Ptr", 0, "Ptr", 0, "UInt", 0x1) ;SC_MANAGER_CONNECT (0x0001)
                            
    hSvc := DllCall("advapi32\" funcName2 ; OpenService
                  , "UInt", SCM_HANDLE, "Str", ServiceName, "UInt", 0x4) ;SERVICE_QUERY_STATUS (0x0004)
    
    If (!hSvc)
        result := 0
    Else {
        SC_STATUS := BufferAlloc(28, 0)
        r := DllCall("advapi32\QueryServiceStatus"
                         , "Ptr", hSvc
                         , "Ptr", SC_STATUS.ptr)
        result := NumGet(SC_STATUS,4,"UInt")

        DllCall("advapi32\CloseServiceHandle", "Ptr", hSvc)
    }
    DllCall("advapi32\CloseServiceHandle", "Ptr", SCM_HANDLE)
    return result
}

; Service_Add(ServiceName, BinaryPath, StartType=""){
    ; if !A_IsAdmin
        ; Return False

    ; SCM_HANDLE := DllCall("advapi32\OpenSCManagerA"
                        ; , "Int", 0
                        ; , "Int", 0
                        ; , "UInt", 0x2) ;SC_MANAGER_CREATE_SERVICE (0x0002)
    
    ; StartType := !StartType ? 0x3 : 0x2 ;SERVICE_DEMAND_START(0x00000003) vs SERVICE_AUTO_START(0x00000002)
    
    
    ; SC_HANDLE := DllCall("advapi32\CreateServiceA"
                   ; , "UInt", SCM_HANDLE
                   ; , "Str", ServiceName
                   ; , "Str", ServiceName
                   ; , "UInt", 0xF01FF ;SERVICE_ALL_ACCESS (0xF01FF)
                   ; , "UInt", 0x110 ;SERVICE_WIN32_OWN_PROCESS(0x00000010) | SERVICE_INTERACTIVE_PROCESS(0x00000100)
    ;;;;;;;interactable service with desktop (requires local account)
    ;;;;;;;http://msdn.microsoft.com/en-us/library/ms683502(VS.85).aspx
                   ; , "UInt", StartType
                   ; , "UInt", 0x1 ;SERVICE_ERROR_NORMAL(0x00000001)
                   ; , "Str", BinaryPath
                   ; , "Str", "" ;No Group
                   ; , "UInt", 0 ;No TagId
                   ; , "Str", "" ;No Dependencies
                   ; , "Int", 0 ;Use LocalSystem Account
                   ; , "Str", "")
    ; result := A_LastError ? SC_HANDLE "," A_LastError : 1
    ; DllCall("advapi32\CloseServiceHandle", "UInt", SC_HANDLE)
    ; DllCall("advapi32\CloseServiceHandle", "UInt", SCM_HANDLE)
    ; Return result
; }

; Service_Delete(ServiceName) {
    ; if !A_IsAdmin ;Requires Administrator rights
        ; Return False
    ; ServiceName := _GetName_(ServiceName)    

    ; SCM_HANDLE := DllCall("advapi32\OpenSCManagerA"
                        ; , "Int", 0 ;NULL for local
                        ; , "Int", 0
                        ; , "UInt", 0x1) ;SC_MANAGER_CONNECT (0x0001)

    ; if !(SC_HANDLE := DllCall("advapi32\OpenServiceA"
                            ; , "UInt", SCM_HANDLE
                            ; , "Str", ServiceName
                            ; , "UInt", 0xF01FF)) ;SERVICE_ALL_ACCESS (0xF01FF)
        ; result := -4 ;Service Not Found

    ; if !result
        ; result := DllCall("advapi32\DeleteService", "Uint", SC_HANDLE)

    ; DllCall("advapi32\CloseServiceHandle", "UInt", SC_HANDLE)
    ; Return result    
; }

; _GetName_(DisplayName) { ;Internal, Gets Service Name from Display Name, 
    ; SCM_HANDLE := DllCall("advapi32\OpenSCManagerA", "Int", 0, "Int", 0, "UInt", 0x1) ;SC_MANAGER_CONNECT (0x0001)    

    ; DllCall("advapi32\GetServiceKeyNameA" ;Get Buffer Size
            ; , "Uint", SCM_HANDLE
            ; , "Str", DisplayName
            ; , "Int", 0
            ; , "UintP", Len)

    ; VarSetCapacity(Buffer, Len) ;Prepare Buffer

    ; DllCall("advapi32\GetServiceKeyNameA" ;Get Actual Service Name
        ; , "Uint", SCM_HANDLE
        ; , "Str", DisplayName
        ; , "Uint", &Buffer
        ; , "UintP", Len)

    ; Loop, % Len//2    
        ; Output .= Chr(NumGet(Buffer, A_Index-1, "Char"))

    ; return !Output ? DisplayName : Output
; }
