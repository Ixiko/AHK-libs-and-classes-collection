/*
    Inserta datos binarios en un archivo (RT_RCDATA).
    Parámetros:
        FileName: El archivo en el cual se va a insertar los datos.
        Name    : El nombre del recurso con el cual identificar a estos datos.
        Data    : Los datos a insertar. Puede ser una cadena o una dirección de memoria a datos binarios.
        Size    : El tamaño de Data, en bytes. Este parámetro es válido únicamente si Data es una dirección de memoria.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    Ejemplo:
        Source   := A_AhkPath
        FileName := A_Temp . '\~TMP-AutoHotkey.exe'
        String   := 'Hola Mundo!`nLínea 2'
        ResName  := '<TEXT>'

        MsgBox('FileCopy: ' . FileCopy(Source, FileName, true) . '`n`nSource: ' . Source . '`nTo: ' . FileName)
        MsgBox('FileInsertData: ' . FileInsertData(FileName, ResName, String))
        MsgBox('FileQueryData: ' . FileQueryData(FileName, ResName, Data, Size) . '`n`nData:`n' . StrGet(&Data, Size, 'UTF-8'))
        MsgBox('FileRemoveData: ' . FileRemoveData(FileName, ResName))
        MsgBox('FileDelete: ' . FileDelete(FileName))
*/
FileInsertData(FileName, Name, Data, Size := 0)
{
    Local hUpdate, Buffer, R

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648030(v=vs.85).aspx
    If (!(hUpdate := DllCall('Kernel32.dll\BeginUpdateResourceW', 'UPtr', &FileName, 'Int', FALSE, 'Ptr')))
        Return (FALSE)

    If (Type(Data) == 'String')
    {
        Size := StrPut(Data, 'UTF-8') - 1
        VarSetCapacity(Buffer, Size)
        StrPut(Data, &Buffer, Size, 'UTF-8')
        Data := &Buffer
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648049(v=vs.85).aspx
    R := DllCall('Kernel32.dll\UpdateResourceW', 'Ptr', hUpdate, 'Int', 10, 'UPtr', &Name, 'UShort', 0, 'UPtr', Data, 'UInt', Size)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648032(v=vs.85).aspx
    DllCall('Kernel32.dll\EndUpdateResourceW', 'Ptr', hUpdate, 'Int', !R)

    Return (R)
}




/*
    Remueve datos binarios en un archivo (RT_RCDATA).
    Parámetros:
        FileName: El archivo en el cual se va a remover los datos.
        Name    : El nombre del recurso.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
FileRemoveData(FileName, Name)
{
    Local hUpdate, R

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648030(v=vs.85).aspx
    If (!(hUpdate := DllCall('Kernel32.dll\BeginUpdateResourceW', 'UPtr', &FileName, 'Int', FALSE, 'Ptr')))
        Return (FALSE)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648049(v=vs.85).aspx
    R := DllCall('Kernel32.dll\UpdateResourceW', 'Ptr', hUpdate, 'Int', 10, 'UPtr', &Name, 'UShort', 0, 'Ptr', 0, 'UInt', 0)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648032(v=vs.85).aspx
    DllCall('Kernel32.dll\EndUpdateResourceW', 'Ptr', hUpdate, 'Int', !R)

    Return (R)
}




/*
    Recupera datos binarios en un archivo (RT_RCDATA).
    Parámetros:
        FileName: El archivo en el cual se va a recuperar los datos.
        Name    : El nombre del recurso.
        Data    : Devuelve los datos binarios.
        Size    : Devuelve la longitud de Data, en bytes. Este valor puede ser 0, en cuyo caso Data tambien es 0.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
FileQueryData(FileName, Name, ByRef Data, ByRef Size)
{
    Local hExe, hResInfo, hResData, hResLock

    If (!(hExe := DllCall('Kernel32.dll\LoadLibraryExW', 'UPtr', &FileName, 'UInt', 0, 'UInt', 0x2, 'Ptr')))
        Return (FALSE)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648043(v=vs.85).aspx
    If (!(hResInfo := DllCall('Kernel32.dll\FindResourceExW', 'Ptr', hExe, 'Int', 10, 'UPtr', &Name, 'UShort', 0, 'Ptr')))
    {
        DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hExe)
        Return (FALSE)
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648046(v=vs.85).aspx
    If (!(hResData := DllCall('Kernel32.dll\LoadResource', 'Ptr', hExe, 'Ptr', hResInfo, 'Ptr')))
    {
        DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hExe)
        Return (FALSE)
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648048(v=vs.85).aspx
    If (!(Size := DllCall('Kernel32.dll\SizeofResource', 'Ptr', hExe, 'Ptr', hResInfo, 'UInt')))
    {
        DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hExe)
        Data := Size := 0
        Return (TRUE)
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648047(v=vs.85).aspx
    If (!(hResLock := DllCall('Kernel32.dll\LockResource', 'Ptr', hResData, 'Ptr')))
    {
        DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hExe)
        Return (FALSE)
    }

    ; Copiamos hResLock a Data, debido que al llamar a FreeLibrary se libera hResLock.
    VarSetCapacity(Data, Size)
    DllCall('msvcrt.dll\memcpy_s', 'UPtr', &Data, 'UPtr', Size, 'Ptr', hResLock, 'UPtr', Size, 'Cdecl')

    DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hExe)
    Return (TRUE)
}




/*
    Recupera datos binarios en el proceso de llamada (RT_RCDATA).
    Parámetros:
        Name : El nombre del recurso.
        Data : Devuelve la dirección de memoria de los datos binarios.
        Size : Devuelve la longitud de Data, en bytes. Este valor puede ser 0, en cuyo caso Data tambien es 0.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    Observaciónes:
        El Script debe estar compilado o la función fallará (obviamente).
*/
FileQueryDataOwn(Name, ByRef Data, ByRef Size)
{
    Local hResInfo, hResData, hResLock

    If (!A_IsCompiled)
        Return (FALSE)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648043(v=vs.85).aspx
    If (!(hResInfo := DllCall('Kernel32.dll\FindResourceExW', 'Ptr', 0, 'Int', 10, 'UPtr', &Name, 'UShort', 0, 'Ptr')))
        Return (FALSE)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648046(v=vs.85).aspx
    If (!(hResData := DllCall('Kernel32.dll\LoadResource', 'Ptr', 0, 'Ptr', hResInfo, 'Ptr')))
        Return (FALSE)
    
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648048(v=vs.85).aspx
    If (!(Size := DllCall('Kernel32.dll\SizeofResource', 'Ptr', 0, 'Ptr', hResInfo, 'UInt')))
    {
        Data := Size := 0
        Return (TRUE)
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648047(v=vs.85).aspx
    If (!(hResLock := DllCall('Kernel32.dll\LockResource', 'Ptr', hResData, 'Ptr')))
        Return (FALSE)

    Data := hResLock

    Return (TRUE) 
}




/*
    Crea un archivo DLL válido vacío apto para añadir recursos en él.
    Parámetros:
        DllPath: La ruta al archivo DLL. Si el archivo existe es sobreescrito.
    Return:
            0 = Ha ocurrido un error al crear el archivo.
        [obj] = Si tuvo éxito, devuelve un objeto de archivo con permiso de escritura y sin ningún tipo de acceso compartido.
    Ejemplo:
        DllFile := DllCreateEmpty(A_Desktop . '\~my_dll.dll')
        MsgBox(DllFile ? 'Ok!' : 'Error!')
*/
DllCreateEmpty(DllPath)
{
    Local File

    ; Intentamos abrir el archivo para escritura.
    ; Si el archivo existe lo sobreescribimos.
    ; Si el archivo no existe lo creamos.
    If (!(File := FileOpen(DllPath, 'w-rwd')))
        Return (FALSE)

    ; Establecemos el tamaño del nuevo archivo a 1KB.
    File.Length := 1024

    ; Escribimos datos en el archivo para que sea válido como DLL (signatura PE...).
    ; 5A4D = 'MZ'
    ; 3C   = IMAGE_DOS_HEADER.e_lfanew
    ; C0   = (192) IMAGE_NT_HEADERS.Signature
    ; 4550 = 'PE\0\0'
    Loop Parse, '0|5A4D|3C|C0|C0|4550|D4|210E00E0|D8|A07010B|E0|200|EC|1000|F0|1000|F4|10000|F8|1000|FC|200|100|4|108|4|110|2000|114|200|11C|4000003|120|40000|124|1000|128|100000|12C|1000|134|10|148|1000|14C|10|1B8|7273722E|1BC|63|1C0|10|1C4|1000|1C8|200|1CC|200|1DC|40000040', '|'
        File[Mod(A_Index, 2) ? 'Seek' : 'WriteUInt']('0x' . A_LoopField)

    ; Establecemos la arquitectura de la CPU sobre la cual esta diseñado el archivo para ejecutarse.
    ; (lo dejamos en IMAGE_FILE_MACHINE_I386, x86)
    File.Seek(0xC4)                                      ;IMAGE_NT_HEADERS.IMAGE_FILE_HEADER.Machine
    File.WriteUInt(A_PtrSize*0+4 == 4 ? 0x014C : 0x8664) ;IMAGE_FILE_MACHINE_I386 : IMAGE_FILE_MACHINE_AMD64

    ; Establecemos la fecha de creación del archivo modificando el miembro TimeDateStamp de la estructura IMAGE_FILE_HEADER.
    File.Seek(0xC8)                               ;IMAGE_NT_HEADERS.IMAGE_FILE_HEADER.TimeDateStamp
    File.WriteUInt(DateDiff(A_NowUTC, 1970, 'S')) ;El formato es la cantidad de segundos que han pasado desde el 1 de enero de 1970.

    Return (File)
} ;Credits: By SKAN | https://autohotkey.com/boards/viewtopic.php?p=166657
