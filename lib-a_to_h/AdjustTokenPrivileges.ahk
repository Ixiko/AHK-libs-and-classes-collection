/*
    Habilita, deshabilita o elimina privilegios en el Token de acceso espesificado.
    Parámetros:
        hToken  : Un identificador al Token de acceso que contiene los privilegios a modificar, el /PID o nombre del proceso.
        NewState: Debe utilizarse de una de las siguientes maneras:
            Un objeto con el nuevo estado para los privilegios espesificados. La clave es el nombre del privilegio, y el valor debe ser uno de los siguientes valores:
                0x00000000 = SE_PRIVILEGE_DISABLED --> La función deshabilita el privilegio.
                0x00000002 = SE_PRIVILEGE_ENABLED  --> La función habilita el privilegio.
                0x00000004 = SE_PRIVILEGE_REMOVED  --> La función elimina el privilegio. Una vez que se elimina un privilegio, éste no puede restaurarse más.
            Si espesifica -1 la función deshabilita todos los privilegios.
    Return:
        -4 = El parámetro es inválido.
        -3 = Ha ocurrido un error al intentar abrir el Token de acceso asociado con el proceso.
        -2 = Ha ocurrido un error al intentar abrir el proceso.
        -1 = Ha ocurrido un error al intentar ajustar los privilegios en el proceso.
         0 = Los privilegios se han cambiado correctamente.
    Acceso requerido:
        0x0020 = TOKEN_ADJUST_PRIVILEGES.
    Ejemplo:
        MsgBox(ProcessExist()) ;Recupera y muestra el identificador del proceso de llamada (PID del script); puede utilizar Process Hacker para comprobar.
        MsgBox(AdjustTokenPrivileges('/' . ProcessExist(), {'SeDebugPrivilege': 2, 'SeCreateSymbolicLinkPrivilege': 2}))
        MsgBox(AdjustTokenPrivileges('/' . ProcessExist(), {'SeDebugPrivilege': 0}))
        MsgBox(AdjustTokenPrivileges('/' . ProcessExist(), {'SeDebugPrivilege': 4}))
*/
AdjustTokenPrivileges(hToken, NewState)
{
    If (!IsObject(NewState) && NewState != -1)
        Return (-4)

    If (Type(hToken) == 'Integer')
    {
        Local Count, TOKEN_PRIVILEGES, Offset, Privilege, Attributes

        If (IsObject(NewState))
        {
            If (!(Count := NumGet(&NewState + 4 * A_PtrSize)))
                Return (-4)

            VarSetCapacity(TOKEN_PRIVILEGES, 4 + 8 * Count + 4 * Count, 0) ;TOKEN_PRIVILEGES + (LUID_AND_ATTRIBUTES * Count)
            NumPut(Count, &TOKEN_PRIVILEGES, 'UInt') ;TOKEN_PRIVILEGES\PrivilegeCount

            Offset := 0
            For Privilege, Attributes In NewState
            {
                If (Type(Privilege) == 'String')
                    DllCall('Advapi32.dll\LookupPrivilegeValueW', 'Str', '', 'Ptr', &Privilege, 'Int64P', Privilege)

                NumPut(Privilege , &TOKEN_PRIVILEGES + (Offset += 4), 'Int64')
                NumPut(Attributes, &TOKEN_PRIVILEGES + (Offset += 8),  'UInt')
            }
        }
        Else
            Return (-4)

        Return (!DllCall('Advapi32.dll\AdjustTokenPrivileges', 'Ptr', hToken, 'Int', NewState == -1, 'UPtr', &TOKEN_PRIVILEGES, 'UInt', 0, 'Ptr', 0, 'Ptr', 0))
    }

    hProcess := SubStr(hToken, 1, 1) == '/' ? SubStr(hToken, 2) : ProcessExist(hToken), hToken := 0
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x400, 'Int', FALSE, 'UInt', hProcess, 'Ptr')))
        Return (-2)

    If (!DllCall('Advapi32.dll\OpenProcessToken', 'Ptr', hProcess, 'UInt', 0x0020, 'PtrP', hToken))
    {
        DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)
        Return (-3)
    }

    Local OutputVar := AdjustTokenPrivileges(hToken, NewState)

    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hToken)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (OutputVar)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa375202(v=vs.85).aspx
