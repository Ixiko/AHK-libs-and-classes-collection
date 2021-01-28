/*
    Recupera el nombre que corresponde al privilegio representado en un sistema específico por un identificador único local especificado (LUID).
    Parámetros:
        SystemName: El nombre del sistema en el que se recupera el nombre del privilegio. Si se especifica una cadena vacía, la función intenta encontrar el nombre del privilegio en el sistema local.
        Luid      : El identificador único local (LUID).
    Return:
        Si tuvo éxito devuelve el nombre del privilegio, caso contrario devuelve una cadena vacía. 
    Ejemplo:
        MsgBox(LookupPrivilegeName(, 20))
*/
LookupPrivilegeName(SystemName := 0, Luid := 0)
{
    Local Buffer, Size, R

    SystemName := SystemName == 0 || SystemName == '' ? '' : SystemName . ''

    VarSetCapacity(Buffer, 100, 0)
    R := DllCall('Advapi32.dll\LookupPrivilegeNameW', 'UPtr', &SystemName, 'Int64P', Luid, 'UPtr', &Buffer, 'UIntP', Size := 50)

    Return (R ? StrGet(&Buffer, 'UTF-16') : '')
} ;https://msdn.microsoft.com/en-us/library/aa379176(v=vs.85).aspx
