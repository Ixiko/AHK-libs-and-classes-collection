/*
    Muestra un diálogo para guardar uno archivo.
    Parámetros:
        Owner / Title:
            El identificador de la ventana propietaria de este diálogo. Este valor puede ser cero.
            Un Array con el identificador de la ventana propietaria y el título. Si el título es una cadena vacía se establece al por defecto "Guardar como".
        FileName:
            La ruta al archivo o directorio seleccioado por defecto. Si especifica un directorio, éste debe terminar con una barra invertida.
        Filter:
            Especifica un filtro de archivos. Debe especificar un objeto, cada clave representa la descripción y el valor los tipos de archivos.
            Para especificar el filtro seleccionado por defecto, agrege el caracter "#" al valor de la clave.
        CustomPlaces:
            Especifica un Array con los directorios personalizados que se mostrarán en el panel izquierdo. Los directorios inexistentes serán omitidos.
            Para especificar la hubicación en la lista, especifique un Array con el directorio y la hubicación de este (0 = Inferior, 1 = Superior).
            Generalmente se suelte utilizar con la opción FOS_HIDEPINNEDPLACES.
        Options:
            Determina el comportamiento del diálogo. Este parámetro debe ser uno o más de los siguientes valores.
                0x00000002  (FOS_OVERWRITEPROMPT) = Ppreguntar antes de sobrescribir un archivo existente con el mismo nombre.
                0x00000004  (FOS_STRICTFILETYPES) = Solo permite al usuario elegir un archivo que tenga una de las extensiones de nombre de archivo especificadas a través del filtro.
                0x00040000 (FOS_HIDEPINNEDPLACES) = Ocultar elementos que se muestran de forma predeterminada en el panel de navegación de la vista.
                0x10000000  (FOS_FORCESHOWHIDDEN) = Incluye elementos ocultos y del sistema.
                0x02000000  (FOS_DONTADDTORECENT) = No agregue el elemento que se abre o guarda en la lista de documentos recientes (SHAddToRecentDocs function).
            Puede consultar todos los valores disponibles en https://msdn.microsoft.com/en-us/library/windows/desktop/dn457282(v=vs.85).aspx.
            Los valores por defecto son FOS_OVERWRITEPROMPT y FOS_STRICTFILETYPES.
    Return:
        Devuelve 0 si el usuario canceló el diálogo, en caso contrario devuelve la ruta del archivo seleccionado.
    Ejemplo:
        MsgBox SaveFile( [0, "Título del diálogo - Guardar como.."]
                       , A_ComSpec
                       , {Música: "*.mp3", Imágenes: "#*.jpg;*.png", Videos: "*.avi;*.mp4;*.mkv;*.wmp", Documentos: "*.txt"}    ; # = Default
                       , [A_WinDir,A_Desktop,A_Temp,A_Startup,A_ProgramFiles]
                       , 0x10000000|0x02000000 )
*/
SaveFile(Owner, FileName := "", Filter := "", CustomPlaces := "", Options := 0x6)
{
    ; IFileSaveDialog interface
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775688(v=vs.85).aspx
    Local IFileSaveDialog := ComObjCreate("{C0B4E2F3-BA21-4773-8DBA-335EC946EB8B}", "{84BCCD23-5FDE-4CDB-AEA4-AF64B83D78AB}")
        ,           Title := IsObject(Owner) ? Owner[2] . "" : ""
        ,           Flags := Options    ; FILEOPENDIALOGOPTIONS enumeration (https://msdn.microsoft.com/en-us/library/windows/desktop/dn457282(v=vs.85).aspx)
        ,      IShellItem := PIDL := i := 0    ; PIDL recibe la dirección de memoria a la estructura ITEMIDLIST que debe ser liberada con la función CoTaskMemFree
        ,             Obj := {}
        ,       Directory := FileName
    Owner := IsObject(Owner) ? Owner[1] : (WinExist("ahk_id" . Owner) ? Owner : 0)
    Filter := IsObject(Filter) ? Filter : {"All files": "*.*"}
    CustomPlaces := IsObject(CustomPlaces) || CustomPlaces == "" ? CustomPlaces : [CustomPlaces]


    If (FileName != "")    ; ¿se especificó un nombre de archivo y/o directorio?
    {
        If (InStr(FileName, "\"))    ; ¿se especificó un directorio?
        {
            If (SubStr(FileName, -1) != "\")    ; ¿se especificó un archivo?
            {
                Local File := ""
                SplitPath(FileName, File, Directory)
                ; IFileDialog::SetFileName
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775974(v=vs.85).aspx
                DllCall(NumGet(NumGet(IFileSaveDialog)+15*A_PtrSize), "UPtr", IFileSaveDialog, "UPtr", &File)
            }
            
            While (InStr(Directory, "\") && !DirExist(Directory))    ; si el directorio no existe buscamos directorios superiores
                Directory := SubStr(Directory, 1, InStr(Directory, "\",, -1) - 1)
            If (DirExist(Directory))
            {
                DllCall("Shell32.dll\SHParseDisplayName", "UPtr", &Directory, "Ptr", 0, "UPtrP", PIDL, "UInt", 0, "UInt", 0)
                DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "UPtr", PIDL, "UPtrP", IShellItem)
                DllCall("Ole32.dll\CoTaskMemFree", "UPtr", PIDL), ObjRawSet(Obj, IShellItem, 0)
                ; IFileDialog::SetFolder method
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761828(v=vs.85).aspx
                DllCall(NumGet(NumGet(IFileSaveDialog)+12*A_PtrSize), "Ptr", IFileSaveDialog, "Ptr", IShellItem, "UInt") ;Set Directory
            }
        }
        Else    ; solo se especificó un nombre de archivo
            DllCall(NumGet(NumGet(IFileSaveDialog)+15*A_PtrSize), "UPtr", IFileSaveDialog, "UPtr", &FileName, "UInt")
    }


    ; COMDLG_FILTERSPEC structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773221(v=vs.85).aspx
    Local TotalFilters := 0, Description := "", FileTypes := "", FileTypeIndex := 1
    For Description, FileTypes in Filter
        ++TotalFilters
    Local COMDLG_FILTERSPEC := ""
    VarSetCapacity(COMDLG_FILTERSPEC, 2*TotalFilters * A_PtrSize, i:=0)
        
    For Description, FileTypes in Filter
    {
        FileTypeIndex := InStr(FileTypes, "#") ? A_Index : FileTypeIndex
        ObjRawSet(Obj, "#" . A_Index, Trim(Description)), ObjRawSet(Obj, "@" . A_Index, Trim(StrReplace(FileTypes, "#")))
        NumPut(ObjGetAddress(Obj, "#" . A_Index), &COMDLG_FILTERSPEC + A_PtrSize * i++)    ; COMDLG_FILTERSPEC.pszName
        NumPut(ObjGetAddress(Obj, "@" . A_Index), &COMDLG_FILTERSPEC + A_PtrSize * i++)    ; COMDLG_FILTERSPEC.pszSpec
    }
    
    ; IFileDialog::SetFileTypes method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775980(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileSaveDialog)+4*A_PtrSize), "UPtr", IFileSaveDialog, "UInt", TotalFilters, "UPtr", &COMDLG_FILTERSPEC, "UInt")

    ; IFileDialog::SetFileTypeIndex method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775978(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileSaveDialog)+5*A_PtrSize), "UPtr", IFileSaveDialog, "UInt", FileTypeIndex, "UInt")


    If (IsObject(CustomPlaces))
    {
        For i, Directory in CustomPlaces
        {
            i := IsObject(Directory) ? Directory[2] : 0    ; FDAP enumeration (https://msdn.microsoft.com/en-us/library/windows/desktop/bb762502(v=vs.85).aspx)
            Directory := IsObject(Directory) ? Directory[1] : Directory
            If (DirExist(Directory))
            {
                DllCall("Shell32.dll\SHParseDisplayName", "UPtr", &Directory, "Ptr", 0, "UPtrP", PIDL, "UInt", 0, "UInt", 0)
                DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "UPtr", PIDL, "UPtrP", IShellItem)
                DllCall("Ole32.dll\CoTaskMemFree", "UPtr", PIDL), ObjRawSet(Obj, IShellItem, 0)
                ; IFileDialog::AddPlace method
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775946(v=vs.85).aspx
                DllCall(NumGet(NumGet(IFileSaveDialog)+21*A_PtrSize), "UPtr", IFileSaveDialog, "UPtr", IShellItem, "UInt", i, "UInt")
            }
        }
    }


    ; IFileDialog::SetTitle method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761834(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileSaveDialog)+17*A_PtrSize), "UPtr", IFileSaveDialog, "UPtr", Title == "" ? 0 : &Title, "UInt")

    ; IFileDialog::SetOptions method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761832(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileSaveDialog)+9*A_PtrSize), "UPtr", IFileSaveDialog, "UInt", Flags, "UInt")


    ; IModalWindow::Show method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761688(v=vs.85).aspx
    Local Result := FALSE
    If (!DllCall(NumGet(NumGet(IFileSaveDialog)+3*A_PtrSize), "UPtr", IFileSaveDialog, "Ptr", Owner, "UInt"))
    {
        ; IFileDialog::GetResult method
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775964(v=vs.85).aspx
        If (!DllCall(NumGet(NumGet(IFileSaveDialog)+20*A_PtrSize), "UPtr", IFileSaveDialog, "UPtrP", IShellItem, "UInt"))
        {
            VarSetCapacity(Result, 32767 * 2, 0)
            DllCall("Shell32.dll\SHGetIDListFromObject", "UPtr", IShellItem, "UPtrP", PIDL)
            DllCall("Shell32.dll\SHGetPathFromIDListEx", "UPtr", PIDL, "Str", Result, "UInt", 2000, "UInt", 0)
            DllCall("Ole32.dll\CoTaskMemFree", "UPtr", PIDL), ObjRelease(IShellItem)
        }
    }


    For i in Obj
        If (Type(i) == "Integer")    ; IShellItem?
            ObjRelease(i)
    ObjRelease(IFileSaveDialog)

    Return Result
}