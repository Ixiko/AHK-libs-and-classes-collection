/*
    Recupera el directorio superior al directorio especificado.
    Parámetros:
        DirName: La ruta a el directorio.
    Nota:
        Esta función no comprueba si el directorio especificado existe o no.
*/
GetDirParent(DirName)
{
    If (StrLen(DirName) < 4)
        Return (SubStr(DirName, 1, 1) . ':')
    
    Return (SubStr(DirName, 1, InStr(RTrim(DirName, '\'), '\',, -1) - 1))
}
