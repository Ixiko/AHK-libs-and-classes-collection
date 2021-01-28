/*
    Recupera los privilegios en el Token de acceso espesificado.
    Parámetros:
        hToken: Un identificador al Token de acceso que contiene los privilegios a modificar, el /PID o nombre del proceso.
    Return:
        -3       = Ha ocurrido un error al intentar abrir el Token de acceso asociado con el proceso.
        -2       = Ha ocurrido un error al intentar abrir el proceso.
        -1       = Ha ocurrido un error al intentar obtener los privilegios en el proceso.
        [object] = Si tuvo éxito devuelve un objeto. La clave representa el nombre del privilegio y el valor el estado. Los estados válidos son:
            0x00000000 = SE_PRIVILEGE_DISABLED        --> El privilegio está deshabilitado.
            0x00000002 = SE_PRIVILEGE_ENABLED         --> El privilegio está habilitado.
            0x00000003 = SE_PRIVILEGE_DEFAULT_ENABLED --> El privilegio está habilitado por defecto (no se puede modificar).
    Acceso requerido:
        0x0008 = TOKEN_QUERY_SOURCE.
    Ejemplo:
        g  := GuiCreate('', 'Current Process Token Privileges')
        lv := g.AddListView('x0 y0 w500 h350', 'Token Privilege|Privilege State')
        For Privilege, State In QueryTokenPrivileges('/' . ProcessExist())
            lv.Add('', Privilege, State == 0 ? 'Disabled' : State == 2 ? 'Enabled' : State == 3 ? 'Default Enabled' : 'Unknown')
        g.Show('w500 h350'), lv.ModifyCol(1, 'AutoHdr')
        WinWaitClose('ahk_id' . g.hWnd)
        ExitApp
*/
QueryTokenPrivileges(hToken)
{
    If (Type(hToken) == 'Integer')
    {
        Local Size, TOKEN_PRIVILEGES

        DllCall('Advapi32.dll\GetTokenInformation', 'Ptr', hToken, 'Int', 3, 'Ptr', 0, 'UInt', 0, 'UIntP', Size)
        If (!VarSetCapacity(TOKEN_PRIVILEGES, Size, 0))
            Return (-1)

        If (!DllCall('Advapi32.dll\GetTokenInformation', 'Ptr', hToken, 'Int', 3, 'UPtr', &TOKEN_PRIVILEGES, 'UInt', Size, 'UIntP', Size))
            Return (-1)

        Local Buffer, R, Luid
            , TokenPrivileges := {}
            , Offset          := 0

        VarSetCapacity(Buffer, 100, 0)

        Loop (NumGet(&TOKEN_PRIVILEGES, 'UInt')) ;TOKEN_PRIVILEGES\PrivilegeCount
        {
            R := DllCall('Advapi32.dll\LookupPrivilegeNameW', 'Str', '', 'Int64P', Luid:=NumGet(&TOKEN_PRIVILEGES + (Offset += 4), 'Int64'), 'UPtr', &Buffer, 'UIntP', Size := 50)
            TokenPrivileges[R?StrGet(&Buffer, 'UTF-16'):Luid] := Format('0x{:08X}', NumGet(&TOKEN_PRIVILEGES + (Offset += 8), 'UInt'))
        }

        Return (TokenPrivileges)
    }

    hProcess := SubStr(hToken, 1, 1) == '/' ? SubStr(hToken, 2) : ProcessExist(hToken), hToken := 0
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x400, 'Int', FALSE, 'UInt', hProcess, 'Ptr')))
        Return (-2)

    If (!DllCall('Advapi32.dll\OpenProcessToken', 'Ptr', hProcess, 'UInt', 0x0008, 'PtrP', hToken))
    {
        DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)
        Return (-3)
    }

    Local OutputVar := QueryTokenPrivileges(hToken)

    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hToken)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (OutputVar)
}
