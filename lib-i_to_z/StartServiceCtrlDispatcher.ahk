/*
    Conecta el subproceso principal de un proceso de servicio al gestor de control de servicios, lo que hace que el subproceso sea el subproceso distribuidor de control de servicio para el proceso de llamada.
    Parámetros:
        ServiceName: El nombre de un servicio que se ejecutará en este proceso de servicio. Asegurarse de que este parámetro sea una cadena.
            Si el servicio se instala con el tipo de servicio SERVICE_WIN32_OWN_PROCESS, este parámetro se ignora y puede ser una cadena vacía.
            Si el servicio se instala con el tipo de servicio SERVICE_WIN32_SHARE_PROCESS, este parámetro especifica el nombre del servicio que utiliza la función ServiceProc señalada por el parámetro ServiceProc.
        ServiceProc: La función a llamar. Puede ser el nombre o dirección de una función. La función recibe los siguientes parámetros:
            Argc = El número de argumentos en el Array Argv.
            Argv = Un Array de punteros a cadenas terminadas con el caracter de terminación nulo.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
StartServiceCtrlDispatcher(ServiceName := '', ServiceProc := 'ServiceMain')
{
    Local SERVICE_TABLE_ENTRY
    
    VarSetCapacity(SERVICE_TABLE_ENTRY, A_PtrSize * 2, 0)
    NumPut(&ServiceName, &SERVICE_TABLE_ENTRY)
    NumPut(Type(ServiceProc) == 'String' ? RegisterCallback(ServiceProc) : ServiceProc, &SERVICE_TABLE_ENTRY + A_PtrSize)

    Return (DllCall('Advapi32.dll\StartServiceCtrlDispatcherW', 'UPtr', &SERVICE_TABLE_ENTRY))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms686324(v=vs.85).aspx




/*
    ; NOTA: ESTE EJEMPLO SERÍA EL SCRIPT COMPILADO, ARCHIVO EJECUTADO POR EL SERVICIO AL SER INICIADO.
    ; CUANDO ESTABLECEMOS UN ARCHIVO A UN SERVICIO, AL INICIAR EL SERVICIO, ÉSTE INICIA EL ARCHIVO ESPECIFICADO Y ESPERA POR LA LLAMADA A LA FUNCIÓN WINAPI
    ;   StartServiceCtrlDispatcher. ESTA FUNCIÓN DESIGNA A UNA FUNCIÓN (ServiceMain) QUE SERÁ EJECUTADA AUTOMÁTICAMENTE POR EL SERVICIO.
    ; CON UN SERVICIO EN LA CUENTA LOCAL DEL SISTEMA (LocalSystem) PODEMOS EJECUTAR APLICACIONES EN LA CUENTA DEL SISTEMA, PARA ELLO DEBEMOS UTILIZAR ALGUNAS
    ;   FUNCIONES WINAPI EN EL SIGUIENTE ORDEN:
    ;       1) El programa envía el identificador de sesión al servicio.
    ;       2) El servicio llama a OpenProcessToken y DuplicateTokenEx para crear un Token local del sistema.
    ;       3) El servicio llama a SetTokenInformation para cambiar el identificador de sesión del Token para que coincida con el del programa.
    ;       4) El servicio llama a DuplicateHandle para crear un identificador a el Token.
    ;       5) El servicio envia el identificador a el programa.
    ;       6) El programa llama SetThreadToken usando el identificador recibido. 

    ; EL SIGUIENTE ES UN EJEMPLO QUE ESCRIBE LOS ARGUMENTOS PASADOS A UN ARCHIVO.


    If (!StartServiceCtrlDispatcher())
        ExitApp

    ServiceMain(Argc, Argv)
    {
        Args := [] ;Almacenamos todos los argumentos en un Array AHK para fácil acceso.

        ; Buscamos todos los argumentos y los añadimos al Array Args.
        Loop (Argc)
             Args.Push(StrGet(NumGet(Argv + (A_Index - 1) * A_PtrSize), 'UTF-16'))

        ; Guardamos todos los argumentos a un archivo de texto en la partición 'D:\'.
        For Each, Arg In Args
            List .= Arg . '`n'
        FileAppend(List, 'D:\~ServiceMain.txt')

        ExitApp
    }
*/
