/*
    Muestra el diálogo donde aparece la version de Windows.
    Parámetros:
        Owner: El identificador de la ventana propietaria de este diálogo. Este valor puede ser cero.
        Title: El título de la ventana. Si Title contiene '#' el texto se divide en dos partes, la primera se asigna al título y la otra a la primera línea del diálogo.
        Text : El texto a mostrar en el diálogo despues de la información de versión y copyright.
*/
ShellAbout(Owner := 0, Title := '', Text := '', Icon := 0)
{
    DllCall('Shell32.dll\ShellAbout', 'Ptr', Owner, 'Str', Title, 'Str', Text, 'Ptr', Icon)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb762152(v=vs.85).aspx
