/*
    Enumera servicios en la base de datos de control de servicios especificada. El nombre y el estado de cada servicio se proporcionan, junto con datos adicionales basados ​​en el nivel de información especificado.
    Parámetros:
        hSCManager  : Un identificador a la base de datos del gestor de control de servicios. Si este valor es 0, la función se conecta al administrador de control de servicios en el equipo local.
        ServiceType : El tipo de servicios a enumerar. Este parámetro puede ser uno o más de los siguientes valores.
            0x00000001 = SERVICE_KERNEL_DRIVER       --> Servicios de controlador.
            0x00000002 = SERVICE_FILE_SYSTEM_DRIVER  --> Servicios de controlador de sistema de archivos.
            0x00000010 = SERVICE_WIN32_OWN_PROCESS   --> Servicios que funcionan en sus propios procesos.
            0x00000020 = SERVICE_WIN32_SHARE_PROCESS --> Servicios que comparten un proceso con uno o más servicios.
        ServiceState: El estado de los servicios a enumerar. Este parámetro puede ser uno o más de los siguientes valores.
            0x00000001 = SERVICE_ACTIVE   --> Enumera los servicios que se encuentran en los estados siguientes: SERVICE_START_PENDING, SERVICE_STOP_PENDING, SERVICE_RUNNING, SERVICE_CONTINUE_PENDING, SERVICE_PAUSE_PENDING, y SERVICE_PAUSED.
            0x00000002 = SERVICE_INACTIVE --> Enumera los servicios que están en el estado SERVICE_STOPPED.
    Return:
        -2      = Hubo un error al intentar establecer una conexión con el gestor de control de servicios.
        -1      = Hubo un error al intentar recuperar la lista con todos los servicios.
        [array] = Si tuvo éxito devuelve un Array de objetos. Cada objeto tiene las siguientes claves disponibles:
            ServiceName             = El nombre del servicio en la base de datos del gestor de control de servicios. La longitud máxima de la cadena es de 256 caracteres.
            DisplayName             = Un nombre visible que puede utilizar los programas de control de servicios, normalmente es la descripción.
            ServiceType             = El tipo de servicio. Este miembro puede ser uno de los siguientes valores.
                0x00000001 = SERVICE_KERNEL_DRIVER       --> El servicio es un controlador de dispositivo.
                0x00000002 = SERVICE_FILE_SYSTEM_DRIVER  --> El servicio es un controlador de sistema de archivos.
                0x00000010 = SERVICE_WIN32_OWN_PROCESS   --> El servicio se ejecuta en su propio proceso.
                0x00000020 = SERVICE_WIN32_SHARE_PROCESS --> El servicio comparte un proceso con otros servicios.
                0x00000100 = SERVICE_INTERACTIVE_PROCESS --> El servicio puede interactuar con el escritorio.
            CurrentState            = El estado actual del servicio. Este miembro puede ser uno de los siguientes valores.
                0x00000001 = SERVICE_STOPPED          --> El servicio se ha detenido.
                0x00000002 = SERVICE_START_PENDING    --> El servicio está comenzando.
                0x00000003 = SERVICE_STOP_PENDING     --> El servicio se detiene.
                0x00000004 = SERVICE_RUNNING          --> El servicio se está ejecutando.
                0x00000005 = SERVICE_CONTINUE_PENDING --> El servicio está a punto de continuar.
                0x00000006 = SERVICE_PAUSE_PENDING    --> El servicio está pausando.
                0x00000007 = SERVICE_PAUSED           --> El servicio está en pausa.
            ControlsAccepted        = Los códigos de control que el servicio acepta y procesa en su función de manejo.
            Win32ExitCode           = El código de error que el servicio utiliza para informar de un error que se produce cuando se inicia o se detiene.
            ServiceSpecificExitCode = El código de error específico del servicio que devuelve el servicio cuando se produce un error mientras se inicia o se detiene el servicio.
            CheckPoint              = El valor de punto de verificación que el servicio incrementa periódicamente para informar de su progreso durante un arranque, parada, pausa o funcionamiento prolongado.
            WaitHint                = El tiempo estimado necesario para una operación de inicio, detención, pausa o continuación pendiente, en milisegundos.
            ProcessId               = El identificador de proceso del servicio. Si el servicio no se está ejecutando este valor es 0.
            ServiceFlags            = Este miembro puede ser uno de los siguientes valores.
                0x00000000 = El servicio se ejecuta en un proceso que no es un proceso del sistema o no se está ejecutando.
                0x00000001 = SERVICE_RUNS_IN_SYSTEM_PROCESS --> El servicio se ejecuta en un proceso del sistema que debe estar siempre en ejecución.
    Acceso requerido:
        0x0004 = SC_MANAGER_ENUMERATE_SERVICE.
    Ejemplo:
        For Each, Srv In EnumerateServices()
            List .= '[' . Srv.ServiceName . '] --> ' . Srv.DisplayName . '`n'
        MsgBox(List)
*/
EnumerateServices(hSCManager := 0, ServiceType := 0x0000003B, ServiceState := 0x00000003)
{
    Local Size, List, Offset, Info, OutputVar

    If (hSCManager)
    {
        DllCall('AdvApi32.dll\EnumServicesStatusExW', 'Ptr', hSCManager, 'UInt', 0, 'UInt', ServiceType, 'UInt', ServiceState, 'Ptr', 0, 'UInt', 0, 'UIntP', Size, 'UIntP', 0, 'Ptr', 0, 'Ptr', 0)
        If (!VarSetCapacity(ENUM_SERVICE_STATUS_PROCESS, Size, 0))
            Return (-1)

        If (!DllCall('Advapi32.dll\EnumServicesStatusExW', 'Ptr', hSCManager, 'UInt', 0, 'UInt', ServiceType, 'UInt', ServiceState, 'UPtr', &ENUM_SERVICE_STATUS_PROCESS, 'UInt', Size, 'UIntP', Size, 'UIntP', ServicesReturned, 'Ptr', 0, 'Ptr', 0))
            Return (-1)
        
        List   := []
        Offset := -A_PtrSize

        Loop (ServicesReturned)
        {
            Info := {}
            Info.ServiceName             := StrGet(NumGet(&ENUM_SERVICE_STATUS_PROCESS + (Offset += A_PtrSize)), 'UTF-16')    ;ENUM_SERVICE_STATUS_PROCESS\lpServiceName
            Info.DisplayName             := StrGet(NumGet(&ENUM_SERVICE_STATUS_PROCESS + (Offset += A_PtrSize)), 'UTF-16')    ;ENUM_SERVICE_STATUS_PROCESS\lpDisplayName
            Info.ServiceType             := NumGet(&ENUM_SERVICE_STATUS_PROCESS + (Offset += A_PtrSize), 'UInt')              ;SERVICE_STATUS_PROCESS\dwServiceType
            Info.CurrentState            := NumGet(&ENUM_SERVICE_STATUS_PROCESS + (Offset +=         4), 'UInt')              ;SERVICE_STATUS_PROCESS\dwCurrentState
            Info.ControlsAccepted        := NumGet(&ENUM_SERVICE_STATUS_PROCESS + (Offset +=         4), 'UInt')              ;SERVICE_STATUS_PROCESS\dwControlsAccepted
            Info.Win32ExitCode           := NumGet(&ENUM_SERVICE_STATUS_PROCESS + (Offset +=         4), 'UInt')              ;SERVICE_STATUS_PROCESS\dwWin32ExitCode
            Info.ServiceSpecificExitCode := NumGet(&ENUM_SERVICE_STATUS_PROCESS + (Offset +=         4), 'UInt')              ;SERVICE_STATUS_PROCESS\dwServiceSpecificExitCode
            Info.CheckPoint              := NumGet(&ENUM_SERVICE_STATUS_PROCESS + (Offset +=         4), 'UInt')              ;SERVICE_STATUS_PROCESS\dwCheckPoint
            Info.WaitHint                := NumGet(&ENUM_SERVICE_STATUS_PROCESS + (Offset +=         4), 'UInt')              ;SERVICE_STATUS_PROCESS\dwWaitHint
            Info.ProcessId               := NumGet(&ENUM_SERVICE_STATUS_PROCESS + (Offset +=         4), 'UInt')              ;SERVICE_STATUS_PROCESS\dwProcessId
            Info.ServiceFlags            := NumGet(&ENUM_SERVICE_STATUS_PROCESS + (Offset +=         4), 'UInt')              ;SERVICE_STATUS_PROCESS\dwServiceFlags

            List.Push(Info)
        }

        Return (List)
    }

    If (!(hSCManager := DllCall('AdvApi32.dll\OpenSCManagerW', 'Ptr', 0, 'Ptr', 0, 'UInt', 0x0004, 'Ptr')))
        Return (-2)

    OutputVar := EnumerateServices(hSCManager)
    DllCall('Advapi32.dll\CloseServiceHandle','Ptr', hSCManager)

    Return (OutputVar)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms682640(v=vs.85).aspx
