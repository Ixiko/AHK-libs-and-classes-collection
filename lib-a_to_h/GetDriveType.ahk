/*
    Determina si una unidad de disco es un disco extraíble, fijo, CD-ROM, RAM o unidad de red.
    Parámetros:
        RootPathName  : El directorio raíz de la unidad.
        DriveTypenName: Devuelve el tipo de unidad como una palabra. Puede ser una cadena vacía, UNKNOWN, REMOVABLE, FIXED, REMOTE, CDROM o RAMDISK. 
    Return:
        0 = DRIVE_UNKNOWN     --> El tipo de unidad no se puede determinar.
        1 = DRIVE_NO_ROOT_DIR --> La ruta raíz no es válida; Por ejemplo, no hay volumen montado en la ruta especificada.
        2 = DRIVE_REMOVABLE   --> La unidad tiene medios extraíbles; Por ejemplo, una unidad de disquete, memoria USB o lector de tarjetas flash.
        3 = DRIVE_FIXED       --> La unidad tiene medios fijos; Por ejemplo, una unidad de disco duro (HDD) o una unidad flash (SSD).
        4 = DRIVE_REMOTE      --> La unidad es una unidad remota (red).
        5 = DRIVE_CDROM       --> La unidad es una unidad de CD-ROM.
        6 = DRIVE_RAMDISK     --> La unidad es un disco RAM.
    Ejemplo:
        Loop Parse, DriveGetList()
            List .= A_LoopField . ':\`t' . GetDriveType(A_LoopField, DriveTypenName) . ' [' . DriveTypenName . ']`n'
        MsgBox(List)
*/
GetDriveType(RootPathName, ByRef DriveTypenName := '')
{
    Local DriveType := DllCall('Kernel32.dll\GetDriveTypeW', 'Str', SubStr(RootPathName, 1, 1) . ':\')

    If (IsByRef(DriveTypenName))
        DriveTypenName := {6: 'RAMDISK', 5: 'CDROM', 4: 'REMOTE', 3: 'FIXED', 2: 'REMOVABLE', 1: '', 0: 'UNKNOWN'}[DriveType]

    Return (DriveType)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa364939(v=vs.85).aspx
