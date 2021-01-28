/*
    Cambia el ícono que se muestra en el menú de la ventana especificada, en el boton de la barra de tareas y en el diálogo ALT-TAB.
    Parámetros:
        hWnd : El identificador de la ventana.
        hIcon: El identificador del icono o la ruta a un icono. Si este valor es 0, el icono actual es removido.
        Icon : El índice del icono en hIcon. Este parámetro es válido si hIcon es un archivo que contiene iconos (por ej. exe, dll, ...).
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    Ejemplo:
        MsgBox(SetWindowIcon(WinExist('ahk_class Notepad'), A_ComSpec))
*/
SetWindowIcon(hWnd, hIcon := 0, Icon := 1)
{
    If (!DllCall('User32.dll\IsWindow', 'Ptr', hWnd))
        Return (FALSE)

    If (Type(hIcon) == 'String')
    {
        If (!(hIcon := LoadPicture(hIcon, 'Icon' . Icon . ' w' . SysGet(49) . ' h' . SysGet(50), ImageType)))
            Return (FALSE)

        If (ImageType != 1)
        {
            DllCall(ImageType ? 'User32.dll\DestroyCursor' : 'Gdi32.dll\DeleteObject', 'Ptr', hIcon)
            Return (FALSE)
        }
    }

    DllCall('User32.dll\DestroyIcon', 'Ptr', DllCall('User32.dll\SendMessageW', 'Ptr', hWnd, 'UInt', 0x0080, 'Int', 0, 'Ptr', hIcon, 'Ptr'))
    DllCall('User32.dll\DestroyIcon', 'Ptr', DllCall('User32.dll\SendMessageW', 'Ptr', hWnd, 'UInt', 0x0080, 'Int', 1, 'Ptr', hIcon, 'Ptr'))

    Return (TRUE)
}
