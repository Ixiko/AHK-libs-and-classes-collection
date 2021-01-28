/*
    Determina si el servicio especificado existe en el sistema.
    Parámetros:
        ServiceName: El nombre del servicio en la base de datos del gestor de control de servicios.
    Return:
        Si el servicio existe devuelve 1, caso contrario devuelve 0.
    Ejemplo:
        msgbox(IsService('spooler'))
*/
IsService(ServiceName)
{
    Local ENUM_SERVICE_STATUS_PROCESS, Size, ServicesReturned, n
        , hSCManager := DllCall('AdvApi32.dll\OpenSCManagerW', 'Ptr', 0, 'Ptr', 0, 'UInt', 0x0004, 'Ptr')

    DllCall('AdvApi32.dll\EnumServicesStatusExW', 'Ptr', hSCManager, 'UInt', 0, 'UInt', 0x0000003B, 'UInt', 0x00000003, 'Ptr', 0, 'UInt', 0, 'UIntP', Size, 'UIntP', 0, 'Ptr', 0, 'Ptr', 0)
    VarSetCapacity(ENUM_SERVICE_STATUS_PROCESS, Size, 0)

    DllCall('Advapi32.dll\EnumServicesStatusExW', 'Ptr', hSCManager, 'UInt', 0, 'UInt', 0x0000003B, 'UInt', 0x00000003, 'UPtr', &ENUM_SERVICE_STATUS_PROCESS, 'UInt', Size, 'UIntP', Size, 'UIntP', ServicesReturned, 'Ptr', 0, 'Ptr', 0)

    n := A_PtrSize * 3 + 4 * 8
    Loop (ServicesReturned)
    {
        If (StrGet(NumGet(&ENUM_SERVICE_STATUS_PROCESS + (A_Index - 1) * n), 'UTF-16') = ServiceName)
        {
            DllCall('Advapi32.dll\CloseServiceHandle','Ptr', hSCManager)
            Return (TRUE)
        }
    }

    DllCall('Advapi32.dll\CloseServiceHandle','Ptr', hSCManager)
    Return (FALSE)
}
