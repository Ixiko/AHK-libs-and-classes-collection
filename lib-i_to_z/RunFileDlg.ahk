/*
Muestra el diálogo 'Ejecutar'.
Parámetros:
    Owner: El identificador de la ventana propietaria de este diálogo. Este valor puede ser cero.
    WorkingDir: El directorio de trabajo. Si este parámetro es una cadena vacía o el directorio no existe se utiliza el directorio de trabajo actual.
    Title: El título de la ventana. Si este parámetro es una cadena vacía se utiliza el título por defecto 'Ejecutar'.
    Description: La descripción. Si este parámetro es una cadena vacía se utiliza la descripción por defecto.
    hIcon: El identificador a un icono. Si este parámetro es 0 se utiliza el icono por defecto.
*/
RunFileDlg(Owner := 0, WorkingDir := '', Title := '', Description := '', hIcon := 0)
{
    If (!DirExist(WorkingDir))
        WorkingDir := A_WorkingDir

    DllCall('Kernel32.dll\GetModuleHandleExW', 'UInt', 0, 'Str', 'shell32.dll', 'PtrP', hModule)
    Local RunFileDlg := DllCall('Kernel32.dll\GetProcAddress', 'Ptr', hModule, 'UInt', 61, 'Ptr')
    DllCall(RunFileDlg, 'Ptr', Owner, 'Ptr', hIcon, 'Str', WorkingDir, Title?'Str':'Ptr', Title?Title:0, Description?'Str':'Ptr', Description?Description:0, 'UInt', 0)
} ;https://www.winehq.org/pipermail/wine-patches/2004-June/011280.html | https://www.codeproject.com/articles/2734/using-the-windows-runfile-dialog-the-documented-an
