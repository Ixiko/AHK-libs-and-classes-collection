/*
    Recupera una lista de letras de unidad y rutas de carpetas montadas para el volumen especificado.
    Parámetros:
        VolumeName: La ruta GUID de volumen. Una ruta GUID de volumen es de la forma '\\?\Volume{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}\'.
    Return:
        Si tuvo éxito devuelve un Array con la información, caso contrario devuelve 0.
    Ejemplo:
        #Include EnumerateVolumes.ahk
        For Each, VolumeName In EnumerateVolumes()
        {
            List .= VolumeName . '`n'
            For Each, PathName In GetVolumePathNames(VolumeName)
                List .= '`t' . PathName . '`n'

        }
        MsgBox(List)
*/
GetVolumePathNames(VolumeName)
{
    Local Size, Buffer, PathName
        , List   := []
        , Offset := 0

    DllCall('Kernel32.dll\GetVolumePathNamesForVolumeNameW', 'UPtr', &VolumeName, 'Ptr', 0, 'UInt', 0, 'UIntP', Size)
    If (!VarSetCapacity(Buffer, Size, 0))
        Return (FALSE)

    If (!DllCall('Kernel32.dll\GetVolumePathNamesForVolumeNameW', 'UPtr', &VolumeName, 'UPtr', &Buffer, 'UInt', Size, 'UIntP', Size))
        Return (FALSE)

    Loop
    {
        If ((PathName := StrGet(&Buffer + Offset, 'UTF-16')) == '')
            Break

        List[A_Index] := PathName
        Offset        += StrLen(PathName) * 2 + 2 ;StrPut(PathName, 'UTF-16') * 2
    }

    Return (List)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa364998(v=vs.85).aspx
