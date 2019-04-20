/*
    Enumera todos los volúmenes en el equipo.
    Return:
        Si tuvo éxito devuelve un Array con el la ruta GUID de todos los volúmenes encontrados, caso contrario devuelve 0.
    Ejemplo:
        For Each, VolumeName In EnumerateVolumes()
            List .= VolumeName . '`n'
        MsgBox(List)
*/
EnumerateVolumes()
{
    Local VolumeName, hFindVolume, List

    VarSetCapacity(VolumeName, 200)

    If (hFindVolume := DllCall('Kernel32.dll\FindFirstVolumeW', 'UPtr', &VolumeName, 'UInt', 100))
    {
        List := [StrGet(&VolumeName, 'UTF-16')]
        
        While (DllCall('Kernel32.dll\FindNextVolumeW', 'Ptr', hFindVolume, 'UPtr', &VolumeName, 'UInt', 100))
            List.Push(StrGet(&VolumeName, 'UTF-16'))

        DllCall('Kernel32.dll\FindVolumeClose', 'Ptr', hFindVolume)
        Return (List)
    }
    
    Return (FALSE)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa364425(v=vs.85).aspx
