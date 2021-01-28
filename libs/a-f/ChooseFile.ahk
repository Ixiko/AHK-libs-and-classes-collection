/*
Muestra un diálogo para seleccionar uno o varios archivos.
Parámetros:
    Owner: El identificador de la ventana propietaria de este diálogo. Este valor puede ser cero.
    FileName: La ruta al archivo o directorio seleccioado por defecto. Si especifica un directorio, éste debe terminar con una barra invertida.
    Filter: Especifica un filtro de archivos. Si se utiliza, debe especificar un objeto, cada clave representa la descripción y el valor los tipos de archivos. Ejemplo: {'Imágenes': '*.jpg;*.png', 'Documentos': '*.txt'}.
	CustomPlaces: Especifica directorios personalizados en el panel izquierdo. Si se utiliza, debe especificar un Array de directorios; los directorios que no existan serán omitidos.
    Options: Opciones para este diálogo. Este parámetro debe ser una cadena con una o más de las siguientes palabras:
        All         = Los archivos ocultos y del sistema son mostrados en el diálogo.
        HPP         = Oculta los elementos del panel izquierdo (Equipo, Bibliotecas, Favoritos, Red, ...).
        Limit       = Solo permite seleccionar archivos con una de las extensiones espesificadas en Filter.
        Multi       = Habilita la selección de múltiples archivos en el diálogo. Si esta opción está presente, la función devuelve un Array.
Return:
    Devuelve 0 si el usuario canceló el diálogo, caso contrario devuelve la ruta al archivo seleccionado.
*/
ChooseFile(Owner := 0, FileName := '', Filter := 0, CustomPlaces := 0, Options := '') ;WIN_V+
{
    Local hObj, pType, pDescription, Found, Directory, File, PIDL, IShellItem, Descriptions, Types, OffSet, TotalFilters, Description, FileTypes, COMDLG_FILTERSPEC, Each, IShellItemArray, Count, OutputVar, PATH, FilePath
        , aObj                := []
        , Flags               := 0x02000000 | 0x00001000 | (InStr(Options, 'All')?0x10000000:0) | (InStr(Options, 'HPP')?0x00040000:0) | (InStr(Options, 'Limit')?0x00000004:0) | (InStr(Options, 'Multi')?0x00000200:0)
        , IFileOpenDialog	  := ComObjCreate('{DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7}', '{D57C7288-D4AD-4768-BE02-9D969532D960}')

    If (FileName != '') ;FileName?
    {
        If (InStr(FileName, '\')) ;Directory or File?
        {
            If (SubStr(FileName, -1) != '\') ;File
            {
                SplitPath(FileName, File, Directory) ;Get FileName and DirName
                If (File != '')
                    DllCall(NumGet(NumGet(IFileOpenDialog)+15*A_PtrSize), 'Ptr', IFileOpenDialog, 'Ptr', &File) ;Set FileName
            }
            
            Directory   := SubStr(Directory == '' ? (StrLen(FileName) > 2 ? FileName : '') : (StrLen(Directory) > 1 ? (SubStr(Directory, -1) == '\' ? Directory : Directory . '\') : ''), 1, -1)
            If (FileExist(Directory))
            {
                DllCall('Shell32.dll\SHParseDisplayName', 'Ptr', &Directory, 'Ptr', 0, 'PtrP', PIDL, 'UInt', 0, 'UInt', 0)
                DllCall('Shell32.dll\SHCreateShellItem', 'Ptr', 0, 'Ptr', 0, 'Ptr', PIDL, 'PtrP', IShellItem)
                DllCall('Ole32.dll\CoTaskMemFree', 'Ptr', PIDL), aObj.Push(IShellItem)
                DllCall(NumGet(NumGet(IFileOpenDialog)+12*A_PtrSize), 'Ptr', IFileOpenDialog, 'Ptr', IShellItem) ;Set Directory
            }
        }
        Else ;Only FileName. No Path
            DllCall(NumGet(NumGet(IFileOpenDialog)+15*A_PtrSize), 'Ptr', IFileOpenDialog, 'Ptr', &FileName)
    }

    If (IsObject(Filter)) ;Filter?
    {
        Descriptions    := []
        Types           := []
        OffSet          := -1

        TotalFilters    := 0
        For Description, FileTypes in Filter
            ++TotalFilters
        VarSetCapacity(COMDLG_FILTERSPEC, (TotalFilters * 2) * A_PtrSize, 0)
        
        For Description, FileTypes in Filter
        {
            Descriptions.Push(DllCall('Kernel32.dll\GlobalAlloc', 'UInt', 0x40, 'UPtr', StrLen(Description) * 2 + 2, 'UPtr'))
            StrPut(Description, Descriptions[A_Index], StrLen(Description) + 1, 'UTF-16')
            NumPut(Descriptions[A_Index], &COMDLG_FILTERSPEC + A_PtrSize * ++OffSet)

            Types.Push(DllCall('Kernel32.dll\GlobalAlloc', 'UInt', 0x40, 'UPtr', StrLen(FileTypes) * 2 + 2, 'UPtr'))
            StrPut(FileTypes, Types[A_Index], StrLen(FileTypes) + 1, 'UTF-16')
            NumPut(Types[A_Index], &COMDLG_FILTERSPEC + A_PtrSize * ++OffSet)
        }
        
        DllCall(NumGet(NumGet(IFileOpenDialog)+4*A_PtrSize), 'Ptr', IFileOpenDialog, 'UInt', TotalFilters, 'Ptr', &COMDLG_FILTERSPEC)
    }

    If (IsObject(CustomPlaces))
    {
        For Each, Directory in CustomPlaces ;CustomPlaces?
        {
            Directory   := StrLen(Directory) > 1 ? (SubStr(Directory, -1) == '\' ? SubStr(Directory, 1, -1) : Directory) : ''
            If (DirExist(Directory))
            {
                DllCall('Shell32.dll\SHParseDisplayName', 'Ptr', &Directory, 'Ptr', 0, 'PtrP', PIDL, 'UInt', 0, 'UInt', 0)
                DllCall('Shell32.dll\SHCreateShellItem', 'Ptr', 0, 'Ptr', 0, 'Ptr', PIDL, 'PtrP', IShellItem)
                DllCall('Ole32.dll\CoTaskMemFree', 'Ptr', PIDL), aObj.Push(IShellItem)
                DllCall(NumGet(NumGet(IFileOpenDialog)+21*A_PtrSize), 'Ptr', IFileOpenDialog, 'Ptr', IShellItem, 'UInt', 0)
            }
        }
    }
    
    DllCall(NumGet(NumGet(IFileOpenDialog)+9*A_PtrSize), 'Ptr', IFileOpenDialog, 'UInt', Flags) ;Flags

    If (DllCall(NumGet(NumGet(IFileOpenDialog)+3*A_PtrSize), 'Ptr', IFileOpenDialog, 'Ptr', Owner) == 0) ;Show Dialog
    {
        If (DllCall(NumGet(NumGet(IFileOpenDialog)+27*A_PtrSize), 'Ptr', IFileOpenDialog, 'PtrP', IShellItemArray) == 0) ;Get Files
        {
            If (DllCall(NumGet(NumGet(IShellItemArray)+7*A_PtrSize), 'Ptr', IShellItemArray, 'UIntP', Count) == 0) ;Get Count
            {
                OutputVar   := []
                VarSetCapacity(PATH, 32767 * 2, 0)

                Loop (Count)
                {
                    If (DllCall(NumGet(NumGet(IShellItemArray)+8*A_PtrSize), 'Ptr', IShellItemArray, 'UInt', A_Index-1, 'PtrP', IShellItem) == 0) ;Get File
                    {
                        DllCall('Shell32.dll\SHGetIDListFromObject', 'Ptr', IShellItem, 'PtrP', PIDL)
                        DllCall('Shell32.dll\SHGetPathFromIDListEx', 'Ptr', PIDL, 'Ptr', &PATH, 'UInt', 32767, 'UInt', 0)
                        DllCall('Ole32.dll\CoTaskMemFree', 'Ptr', PIDL)

                        FilePath    := StrGet(&PATH, 'UTF-16')

                        ;Check for duplicate file
                        Found       := FALSE
                        For Each, Directory in OutputVar
                        {
                            If (Directory == FilePath)
                            {
                                Found := TRUE
                                Break
                            }
                        }

                        ;Append file and release object
                        If (!Found)
                            OutputVar.Push(FilePath)
                        ObjRelease(IShellItem)
                    }
                }
            }

            ObjRelease(IShellItemArray)
        }
    }

    ;Free memory
    For Each, pDescription in Descriptions
        DllCall('Kernel32.dll\GlobalFree', 'UPtr', pDescription, 'UPtr')
    For Each, pType in Types
        DllCall('Kernel32.dll\GlobalFree', 'UPtr', pType, 'UPtr')
    For Each, hObj in aObj
        ObjRelease(hObj)
    ObjRelease(IFileOpenDialog)

    Return (IsObject(OutputVar) ? (InStr(Options, 'Multi') ? OutputVar : OutputVar[1]) : FALSE)
}
