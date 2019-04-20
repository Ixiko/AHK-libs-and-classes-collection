/*
    Vacía la Papelera de reciclaje en la unidad especificada.
    Parámetros:
        RootPath: La ruta de la unidad raíz en la que se encuentra la papelera de reciclaje. Si este parámetro es una cadena vacía o 0 afecta a todas las unidades.
        hWnd: El identificador de la ventana propietaria. Este parámetro puede ser 0.
        Confirmation: Determina si se debe mostrar un diálogo para pedir la confirmación de la operación del usuario.
        Progress: Determina si se debe mostrar el progreso de la operación.
        Sound: Determina si se debe reproducir un sonido al terminar la operacións.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
EmptyRecycleBin(RootPath := 0, hWnd := 0, Confirmation := FALSE, Progress := FALSE, Sound := FALSE)
{
    Local Flags := !Confirmation | (Progress ? 0 : 2) | (Sound ? 0 : 4)

    RootPath := RootPath ? SubStr(RootPath, 1, 1) . ':' : 0

    Return (!DllCall('Shell32.dll\SHEmptyRecycleBinW', 'Ptr', hWnd, 'UPtr', &RootPath, 'UInt', Flags, 'UInt'))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb762160(v=vs.85).aspx
