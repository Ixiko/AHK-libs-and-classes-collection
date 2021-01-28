/*
    Recupera la ruta a un archivo temporal inexistente.
    Parámetros:
        Prefix: El prefijo (cadena a añadir al inicio del nombre del archivo).
        Sufix : El sufijo (cadena a añadir al final del nombre del archivo).
    Return:
        Devuelve la ruta al archivo.
    Ejemplo:
        MsgBox(GetTempFile(, '.txt'))
*/
GetTempFile(Prefix := '~tmp', Sufix := '')
{
    Local FileName

    Loop
        FileName := A_Temp . '\' . Prefix . A_Index . Sufix
    Until (!FileExist(FileName))

    Return (FileName)
}




/*
    Recupera un objeto de archivo temporal válido para escribir en él.
    Parámetros:
        Prefix: El prefijo (cadena a añadir al inicio del nombre del archivo).
        Sufix : El sufijo (cadena a añadir al final del nombre del archivo).
    Return:
        Devuelve un objeto de archivo con permiso de escritura. El objeto devuelto no comparte ningún acceso (lectura, escritura, eliminación).
    ErrorLevel:
        Se establece en la ruta al archivo.
    Ejemplo:
        MsgBox(GetTempFileObj() . ErrorLevel)
*/
GetTempFileObj(Prefix := '~tmp', Sufix := '')
{
    Local FileObj, FileName

    Loop
        FileName := A_Temp . '\' . Prefix . A_Index . Sufix
    Until (!FileExist(FileName) && (FileObj := FileOpen(FileName, 'w-rwd', 'UTF-16')))

    ErrorLevel := FileName

    Return (FileObj)
}
